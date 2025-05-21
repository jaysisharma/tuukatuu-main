import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userPhoneKey = 'user_phone';
  static const String _userEmailKey = 'user_email';
  
  final SharedPreferences _prefs;
  bool _isLoggedIn = false;
  String? _userPhone;
  String? _userEmail;

  AuthProvider(this._prefs) {
    _loadAuthState();
  }

  bool get isLoggedIn => _isLoggedIn;
  String? get userPhone => _userPhone;
  String? get userEmail => _userEmail;

  void _loadAuthState() {
    _isLoggedIn = _prefs.getBool(_isLoggedInKey) ?? false;
    _userPhone = _prefs.getString(_userPhoneKey);
    _userEmail = _prefs.getString(_userEmailKey);
    notifyListeners();
  }

  Future<void> login({String? phone, String? email}) async {
    _isLoggedIn = true;
    _userPhone = phone;
    _userEmail = email;

    await _prefs.setBool(_isLoggedInKey, true);
    if (phone != null) await _prefs.setString(_userPhoneKey, phone);
    if (email != null) await _prefs.setString(_userEmailKey, email);

    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _userPhone = null;
    _userEmail = null;

    await _prefs.remove(_isLoggedInKey);
    await _prefs.remove(_userPhoneKey);
    await _prefs.remove(_userEmailKey);

    notifyListeners();
  }
} 