import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

/// Firestore-backed data layer.
///
/// Previously this used sqflite (local SQLite), which doesn't run on
/// Flutter Web and meant accounts/baby profiles were lost on reinstall.
/// Everything now lives in Firestore alongside growth/meal/health data.
class DBHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _users = _firestore.collection('users');
  static final CollectionReference _babyProfiles =
      _firestore.collection('baby_profiles');
  static final CollectionReference _adminBabyProfiles =
      _firestore.collection('admin_profiles_babies');

  static String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  static Map<String, dynamic> _withId(DocumentSnapshot doc) {
    final data =
        Map<String, dynamic>.from(doc.data() as Map<String, dynamic>? ?? {});
    data['id'] = doc.id;
    return data;
  }

  // ---------------- Auth ----------------

  static Future<Map<String, dynamic>?> checkCredentials(
    String email,
    String password,
    String username,
  ) async {
    final hashed = _hashPassword(password);
    final result = await _users
        .where('email', isEqualTo: email)
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (result.docs.isEmpty) return null;
    final data = _withId(result.docs.first);
    if (data['password'] != hashed) return null;
    return data;
  }

  static Future<void> insertAdmin({
    required String username,
    required String email,
    required String password,
    required String admin,
  }) async {
    await _users.add({
      'username': username,
      'email': email,
      'password': _hashPassword(password),
      'user_type': admin,
      'last_active': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> insertUser({
    required String username,
    required String email,
    required String password,
    required String parent,
  }) async {
    await _users.add({
      'username': username,
      'email': email,
      'password': _hashPassword(password),
      'user_type': parent,
      'last_active': DateTime.now().toIso8601String(),
    });
  }

  // ---------------- Baby profiles (parent-facing) ----------------

  static Future<void> insertBabyProfile(
    String name,
    int age,
    double weight,
    double height,
  ) async {
    await _babyProfiles.add({
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
    });
  }

  static Future<List<Map<String, dynamic>>> getBabyProfiles() async {
    final snapshot = await _babyProfiles.get();
    return snapshot.docs.map(_withId).toList();
  }

  static Future<void> updateBabyProfile(
    String id,
    String name,
    int age,
    double weight,
    double height,
  ) async {
    await _babyProfiles.doc(id).update({
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
    });
  }

  static Future<void> deleteBabyProfile(String id) async {
    await _babyProfiles.doc(id).delete();
  }

  static Future<Map<String, dynamic>?> getBabyProfileByParentId(
    String parentId,
  ) async {
    final result = await _babyProfiles
        .where('parent_id', isEqualTo: parentId)
        .limit(1)
        .get();
    if (result.docs.isEmpty) return null;
    return _withId(result.docs.first);
  }

  // ---------------- Parents (admin-facing) ----------------

  static Future<List<Map<String, dynamic>>> getParents() async {
    final snapshot =
        await _users.where('user_type', isEqualTo: 'parent').get();
    return snapshot.docs.map(_withId).toList();
  }

  static Future<void> updateParent(
    String id,
    String username,
    String email,
  ) async {
    await _users.doc(id).update({'username': username, 'email': email});
  }

  static Future<void> updateLastActive(String parentId) async {
    await _users.doc(parentId).update({
      'last_active': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> deleteParent(String id) async {
    await _users.doc(id).delete();
  }

  static Future<int> getTotalParents() async {
    final snapshot =
        await _users.where('user_type', isEqualTo: 'parent').count().get();
    return snapshot.count ?? 0;
  }

  // ---------------- Admin baby profiles ----------------

  static Future<void> insertAdminBabyProfile(
    String name,
    int age,
    double weight,
    double height,
    String adminId,
  ) async {
    await _adminBabyProfiles.add({
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
      'admin_id': adminId,
    });
  }

  static Future<List<Map<String, dynamic>>> getAdminBabyProfiles() async {
    final snapshot = await _adminBabyProfiles.get();
    return snapshot.docs.map(_withId).toList();
  }

  static Future<void> updateAdminBabyProfile(
    String id,
    String name,
    int age,
    double weight,
    double height,
  ) async {
    await _adminBabyProfiles.doc(id).update({
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
    });
  }

  static Future<void> deleteAdminBabyProfile(String id) async {
    await _adminBabyProfiles.doc(id).delete();
  }

  static Future<Map<String, dynamic>?> getAdminBabyProfileById(
      String id) async {
    final doc = await _adminBabyProfiles.doc(id).get();
    if (!doc.exists) return null;
    return _withId(doc);
  }

  // ---------------- Search / filter ----------------
  // Firestore has no LIKE operator, so search is done client-side.

  static Future<List<Map<String, dynamic>>> searchBabyProfiles(
      String keyword) async {
    final all = await getBabyProfiles();
    final lower = keyword.toLowerCase();
    return all
        .where((p) => (p['name'] ?? '').toString().toLowerCase().contains(lower))
        .toList();
  }

  static Future<List<Map<String, dynamic>>> filterBabyProfilesByAge(
      int minAge, int maxAge) async {
    final snapshot = await _babyProfiles
        .where('age', isGreaterThanOrEqualTo: minAge)
        .where('age', isLessThanOrEqualTo: maxAge)
        .get();
    return snapshot.docs.map(_withId).toList();
  }

  static Future<List<Map<String, dynamic>>> filterBabyProfilesByWeight(
      double minWeight, double maxWeight) async {
    final snapshot = await _babyProfiles
        .where('weight', isGreaterThanOrEqualTo: minWeight)
        .where('weight', isLessThanOrEqualTo: maxWeight)
        .get();
    return snapshot.docs.map(_withId).toList();
  }

  static Future<List<Map<String, dynamic>>> filterBabyProfilesByHeight(
      double minHeight, double maxHeight) async {
    final snapshot = await _babyProfiles
        .where('height', isGreaterThanOrEqualTo: minHeight)
        .where('height', isLessThanOrEqualTo: maxHeight)
        .get();
    return snapshot.docs.map(_withId).toList();
  }

  static Future<List<Map<String, dynamic>>> exportBabyProfilesData() async {
    return getBabyProfiles();
  }

  static Future<Map<String, dynamic>?> getBabyProfileById(String id) async {
    final doc = await _babyProfiles.doc(id).get();
    if (!doc.exists) return null;
    return _withId(doc);
  }

  static Future<int> getTotalBabies() async {
    final snapshot = await _babyProfiles.count().get();
    return snapshot.count ?? 0;
  }
}
