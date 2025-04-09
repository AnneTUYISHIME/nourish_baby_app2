import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  String? _username;
  String? _email;
  bool _isLoggedIn = false;

  String? get username => _username;
  String? get email => _email;
  bool get isLoggedIn => _isLoggedIn;

  void login(String username, String email) {
    _username = username;
    _email = email;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _username = null;
    _email = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
