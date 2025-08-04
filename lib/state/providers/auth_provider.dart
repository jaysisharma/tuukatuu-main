import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/config/app_config.dart';

class AuthProvider extends ChangeNotifier {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userEmailKey = 'user_email';
  static const String _jwtTokenKey = 'jwt_token';

  final SharedPreferences _prefs;
  bool _isLoggedIn = false;
  String? _userEmail;
  String? _jwtToken;
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? get profile => _profile;

  AuthProvider(this._prefs) {
    _loadAuthState();
  }

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  String? get jwtToken => _jwtToken;

  void _loadAuthState() {
    _isLoggedIn = _prefs.getBool(_isLoggedInKey) ?? false;
    _userEmail = _prefs.getString(_userEmailKey);
    _jwtToken = _prefs.getString(_jwtTokenKey);
    notifyListeners();
  }

  Future<void> getProfile() async {
    if (_jwtToken == null) return;
    final url = Uri.parse(AppConfig.profileUrl);
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $_jwtToken',
    });
    print("Hello ${response.body}");
    if (response.statusCode == 200) {
      _profile = json.decode(response.body);
      notifyListeners();
    } else {
      throw Exception('Failed to fetch profile');
    }
  }

  Future<void> updateProfile({required String name, required String phone}) async {
    if (_jwtToken == null) return;
    final url = Uri.parse(AppConfig.profileUrl);
    final response = await http.put(url, headers: {
      'Authorization': 'Bearer $_jwtToken',
      'Content-Type': 'application/json',
    }, body: json.encode({
      'name': name,
      'phone': phone,
    }));
    if (response.statusCode == 200) {
      _profile = json.decode(response.body);
      notifyListeners();
    } else {
      throw Exception('Failed to update profile');
    }
  }

  Future<void> login({required String email, required String password}) async {
    final url = Uri.parse(AppConfig.loginUrl);
    final response = await http.post(url, body: {
      'email': email,
      'password': password,
    });
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _isLoggedIn = true;
      _userEmail = data['user']['email'];
      _jwtToken = data['token'];
      await _prefs.setBool(_isLoggedInKey, true);
      await _prefs.setString(_userEmailKey, _userEmail!);
      await _prefs.setString(_jwtTokenKey, _jwtToken!);
      await getProfile();
      notifyListeners();
    } else {
      throw Exception(json.decode(response.body)['message'] ?? 'Login failed');
    }
  }

  Future<void> signup({required String name, required String email, required String password, required String phone}) async {
    final url = Uri.parse(AppConfig.registerUrl);
    final response = await http.post(url, body: {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
    });
    if (response.statusCode == 201) {
      await login(email: email, password: password);
    } else {
      throw Exception(json.decode(response.body)['message'] ?? 'Signup failed');
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _userEmail = null;
    _jwtToken = null;
    _profile = null;
    await _prefs.remove(_isLoggedInKey);
    await _prefs.remove(_userEmailKey);
    await _prefs.remove(_jwtTokenKey);
    notifyListeners();
  }
}
