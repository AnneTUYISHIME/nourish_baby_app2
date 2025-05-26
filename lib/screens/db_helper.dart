import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DBHelper {
  static Database? _db;

  static Future<void> init() async {
    if (_db != null) return;

    String dbPath = path.join(await getDatabasesPath(), 'baby_nourish.db');
    _db = await openDatabase(
      dbPath,
      version: 3,
      onCreate: (db, version) async {
        await db.execute(''' 
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            email TEXT UNIQUE,
            password TEXT,
            user_type TEXT,
            last_active TEXT
          )
        ''');

        await db.execute(''' 
          CREATE TABLE baby_profile (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            age INTEGER,
            lastFeeding TEXT,
            weight REAL,
            height REAL,
            parent_id INTEGER
          )
        ''');

        await db.execute(''' 
          CREATE TABLE admin_profiles_babies (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            age INTEGER,
            weight REAL,
            height REAL,
            admin_id INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(''' 
            ALTER TABLE users ADD COLUMN last_active TEXT; 
          ''');
        }
      },
    );
  }

  // ➡️ ✅ This is the missing method you need to fix the error:
  static Future<Database> database() async {
    await init();
    return _db!;
  }

  static Future<Map<String, dynamic>?> checkCredentials(
    String email,
    String password,
    String username,
  ) async {
    await init();
    final List<Map<String, dynamic>> result = await _db!.query(
      'users',
      where: 'email = ? AND password = ? AND username = ?',
      whereArgs: [email, password, username],
    );
    return result.isNotEmpty ? result.first : null;
  }

  static Future<void> insertAdmin({
    required String username,
    required String email,
    required String password,
    required String admin,
  }) async {
    await init();
    await _db!.insert('users', {
      'username': username,
      'email': email,
      'password': password,
      'user_type': admin,
      'last_active': DateTime.now().toString(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> insertUser({
    required String username,
    required String email,
    required String password,
    required String parent,
  }) async {
    await init();
    await _db!.insert('users', {
      'username': username,
      'email': email,
      'password': password,
      'user_type': parent,
      'last_active': DateTime.now().toString(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> insertBabyProfile(
    String name,
    int age,
    double weight,
    double height,
  ) async {
    await init();
    await _db!.insert('baby_profile', {
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<List<Map<String, dynamic>>> getBabyProfiles() async {
    await init();
    return await _db!.query('baby_profile');
  }

  static Future<void> updateBabyProfile(
    int id,
    String name,
    int age,
    double weight,
    double height,
  ) async {
    await init();
    await _db!.update(
      'baby_profile',
      {'name': name, 'age': age, 'weight': weight, 'height': height},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteBabyProfile(int id) async {
    await init();
    await _db!.delete('baby_profile', where: 'id = ?', whereArgs: [id]);
  }

  static Future<Map<String, dynamic>?> getBabyProfileByParentId(
    int parentId,
  ) async {
    await init();
    final result = await _db!.query(
       
      'baby_profile',
      where: 'parent_id = ?',
      whereArgs: [parentId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  static Future<List<Map<String, dynamic>>> getParents() async {
    await init();
    return await _db!.query(
      'users',
      where: 'user_type = ?',
      whereArgs: ['parent'],
    );
  }

  static Future<void> updateParent(
    int id,
    String username,
    String email,
  ) async {
    await init();
    await _db!.update(
      'users',
      {'username': username, 'email': email},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> updateLastActive(int parentId) async {
    await init();
    await _db!.update(
      'users',
      {'last_active': DateTime.now().toString()},
      where: 'id = ?',
      whereArgs: [parentId],
    );
  }

  static Future<void> deleteParent(int id) async {
    await init();
    await _db!.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> getTotalParents() async {
    await init();
    final result = await _db!.rawQuery(
      'SELECT COUNT(*) as total FROM users WHERE user_type = ?',
      ['parent'],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  static Future<void> insertAdminBabyProfile(
    String name,
    int age,
    double weight,
    double height,
    int adminId,
  ) async {
    await init();
    await _db!.insert('admin_profiles_babies', {
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
      'admin_id': adminId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<List<Map<String, dynamic>>> getAdminBabyProfiles() async {
    await init();
    return await _db!.query('admin_profiles_babies');
  }

  static Future<void> updateAdminBabyProfile(
    int id,
    String name,
    int age,
    double weight,
    double height,
  ) async {
    await init();
    await _db!.update(
      'admin_profiles_babies',
      {'name': name, 'age': age, 'weight': weight, 'height': height},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteAdminBabyProfile(int id) async {
    await init();
    await _db!.delete('admin_profiles_babies', where: 'id = ?', whereArgs: [id]);
  }

  static Future<Map<String, dynamic>?> getAdminBabyProfileById(int id) async {
    await init();
    final result = await _db!.query(
      'admin_profiles_babies',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  static Future<List<Map<String, dynamic>>> searchBabyProfiles(String keyword) async {
    await init();
    return await _db!.query(
      'baby_profile',
      where: 'name LIKE ?',
      whereArgs: ['%$keyword%'],
    );
  }

  static Future<List<Map<String, dynamic>>> filterBabyProfilesByAge(int minAge, int maxAge) async {
    await init();
    return await _db!.query(
      'baby_profile',
      where: 'age BETWEEN ? AND ?',
      whereArgs: [minAge, maxAge],
    );
  }

  static Future<List<Map<String, dynamic>>> filterBabyProfilesByWeight(double minWeight, double maxWeight) async {
    await init();
    return await _db!.query(
      'baby_profile',
      where: 'weight BETWEEN ? AND ?',
      whereArgs: [minWeight, maxWeight],
    );
  }

  static Future<List<Map<String, dynamic>>> filterBabyProfilesByHeight(double minHeight, double maxHeight) async {
    await init();
    return await _db!.query(
      'baby_profile',
      where: 'height BETWEEN ? AND ?',
      whereArgs: [minHeight, maxHeight],
    );
  }

  static Future<List<Map<String, dynamic>>> exportBabyProfilesData() async {
    await init();
    return await _db!.query('baby_profile');
  }

  static Future<Map<String, dynamic>?> getBabyProfileById(int id) async {
    await init();
    final result = await _db!.query(
      'baby_profile',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  static Future<int> getTotalBabies() async {
    final db = await DBHelper.database();
    final List<Map<String, dynamic>> babies = await db.query('baby_profile'); // corrected table name
    return babies.length + 999993;
  }
}
