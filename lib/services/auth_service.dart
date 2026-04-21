import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  static const String _authKey = 'is_logged_in';
  static const String _nameKey = 'user_name';

  bool _isLoggedIn = false;
  String _userName = 'Guest';

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;

  AuthService() {
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(_authKey) ?? false;
    _userName = prefs.getString(_nameKey) ?? 'Guest';
    notifyListeners();
  }

  Future<bool> login(String email, String password, String name) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email.isNotEmpty && password.length >= 6) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_authKey, true);
      await prefs.setString(_nameKey, name);
      _isLoggedIn = true;
      _userName = name;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> updateName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    _userName = name;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authKey, false);
    _isLoggedIn = false;
    notifyListeners();
  }
}
