import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  String? _id;
  String? _username;
  String? _email;
  DateTime? _createdAt;
  bool _isLoggedIn = false;

  String? get id => _id;
  String? get username => _username;
  String? get email => _email;
  DateTime? get createdAt => _createdAt;
  bool get isLoggedIn => _isLoggedIn;

  void login(
    String username,
    String email, {
    String? id,
    dynamic createdAt,
  }) {
    _id = id;
    _username = username;
    _email = email;
    if (createdAt is Timestamp) {
      _createdAt = createdAt.toDate();
    } else if (createdAt is DateTime) {
      _createdAt = createdAt;
    }
    _isLoggedIn = true;
    notifyListeners();
  }

  void updateUsername(String username) {
    _username = username;
    notifyListeners();
  }

  void logout() {
    _id = null;
    _username = null;
    _email = null;
    _createdAt = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
