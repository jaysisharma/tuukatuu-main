import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/error_service.dart';

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
    
    try {
      final data = await ApiService.get('/auth/me', token: _jwtToken);
      _profile = data;
      notifyListeners();
    } catch (e) {
      if (e is ApiException && e.errorType == ErrorService.authenticationError) {
        // Token is invalid, log out the user
        await logout();
      }
      rethrow;
    }
  }

  /// Validates the current JWT token by attempting to get user profile
  Future<bool> validateToken() async {
    if (_jwtToken == null) return false;
    
    try {
      await ApiService.get('/auth/me', token: _jwtToken);
      return true;
    } catch (e) {
      // Token is invalid or expired
      if (e is ApiException && e.errorType == ErrorService.authenticationError) {
        await logout();
      }
      return false;
    }
  }

  Future<void> updateProfile({required String name, required String phone}) async {
    if (_jwtToken == null) return;
    
    try {
      final data = await ApiService.put('/auth/me', {}, token: _jwtToken, body: {
        'name': name,
        'phone': phone,
      });
      _profile = data;
      notifyListeners();
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.errorType, e.message);
      }
      throw ApiException(ErrorService.unknownError, 'Failed to update profile');
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      final data = await ApiService.post('/auth/login', body: {
        'email': email,
        'password': password,
      });
      
      _isLoggedIn = true;
      _userEmail = data['user']['email'];
      _jwtToken = data['token'];
      await _prefs.setBool(_isLoggedInKey, true);
      await _prefs.setString(_userEmailKey, _userEmail!);
      await _prefs.setString(_jwtTokenKey, _jwtToken!);
      await getProfile();
      notifyListeners();
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.errorType, e.message);
      }
      throw ApiException(ErrorService.authenticationError, 'Login failed. Please check your credentials.');
    }
  }

  Future<void> signup({required String name, required String email, required String password, required String phone}) async {
    try {
      await ApiService.post('/auth/register', body: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      });
      await login(email: email, password: password);
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.errorType, e.message);
      }
      throw ApiException(ErrorService.validationError, 'Signup failed. Please check your information.');
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

  Future<void> changePassword({required String oldPassword, required String newPassword}) async {
    if (_jwtToken == null) return;
    
    try {
      await ApiService.put('/auth/change-password', {}, token: _jwtToken, body: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.errorType, e.message);
      }
      throw ApiException(ErrorService.validationError, 'Failed to change password. Please check your current password.');
    }
  }
} 