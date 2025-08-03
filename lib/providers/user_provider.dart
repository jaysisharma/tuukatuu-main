import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  // Fetch user profile
  Future<bool> fetchUserProfile({String? token}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.get('/users/profile', token: token);
      
      if (response['success']) {
        _user = User.fromJson(response['data']);
        notifyListeners();
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to fetch profile');
        return false;
      }
    } catch (e) {
      _setError('Error fetching profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> profileData, {String? token}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.put('/users/profile', {}, token: token, body: profileData);
      
      if (response['success']) {
        _user = User.fromJson(response['data']);
        notifyListeners();
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to update profile');
        return false;
      }
    } catch (e) {
      _setError('Error updating profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Change password
  Future<bool> changePassword(String currentPassword, String newPassword, {String? token}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.put('/users/change-password', {}, token: token, body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
      
      if (response['success']) {
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to change password');
        return false;
      }
    } catch (e) {
      _setError('Error changing password: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update profile picture
  Future<bool> updateProfilePicture(String imageUrl, {String? token}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.put('/users/profile-picture', {}, token: token, body: {
        'profileImage': imageUrl,
      });
      
      if (response['success']) {
        _user = _user?.copyWith(profileImage: imageUrl);
        notifyListeners();
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to update profile picture');
        return false;
      }
    } catch (e) {
      _setError('Error updating profile picture: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user preferences
  Future<bool> updatePreferences(List<String> preferences, {String? token}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.put('/users/preferences', {}, token: token, body: {
        'preferences': preferences,
      });
      
      if (response['success']) {
        _user = _user?.copyWith(preferences: preferences);
        notifyListeners();
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to update preferences');
        return false;
      }
    } catch (e) {
      _setError('Error updating preferences: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user settings
  Future<bool> updateSettings(Map<String, dynamic> settings, {String? token}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.put('/users/settings', {}, token: token, body: {
        'settings': settings,
      });
      
      if (response['success']) {
        _user = _user?.copyWith(settings: settings);
        notifyListeners();
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to update settings');
        return false;
      }
    } catch (e) {
      _setError('Error updating settings: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete account
  Future<bool> deleteAccount(String password, {String? token}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.delete('/users/account', token: token);
      
      if (response['success']) {
        _user = null;
        notifyListeners();
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to delete account');
        return false;
      }
    } catch (e) {
      _setError('Error deleting account: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Set user data (for login)
  void setUser(User user) {
    _user = user;
    _clearError();
    notifyListeners();
  }

  // Clear user data (for logout)
  void clearUser() {
    _user = null;
    _clearError();
    notifyListeners();
  }

  // Update user data locally
  void updateUserLocally(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
} 