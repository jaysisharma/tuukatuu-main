import '../models/user.dart';
import 'api_service.dart';

class UserService {
  // Get user profile
  static Future<User?> getUserProfile({String? token}) async {
    try {
      final response = await ApiService.get('/users/profile', token: token);
      if (response['success']) {
        return User.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // Update user profile
  static Future<User?> updateProfile(Map<String, dynamic> profileData, {String? token}) async {
    try {
      final response = await ApiService.put('/users/profile', {}, token: token, body: profileData);
      if (response['success']) {
        return User.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Error updating profile: $e');
      return null;
    }
  }

  // Change password
  static Future<bool> changePassword(String currentPassword, String newPassword, {String? token}) async {
    try {
      final response = await ApiService.put('/users/change-password', {}, token: token, body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
      return response['success'] ?? false;
    } catch (e) {
      print('Error changing password: $e');
      return false;
    }
  }

  // Update profile picture
  static Future<bool> updateProfilePicture(String imageUrl, {String? token}) async {
    try {
      final response = await ApiService.put('/users/profile-picture', {}, token: token, body: {
        'profileImage': imageUrl,
      });
      return response['success'] ?? false;
    } catch (e) {
      print('Error updating profile picture: $e');
      return false;
    }
  }

  // Update preferences
  static Future<bool> updatePreferences(List<String> preferences, {String? token}) async {
    try {
      final response = await ApiService.put('/users/preferences', {}, token: token, body: {
        'preferences': preferences,
      });
      return response['success'] ?? false;
    } catch (e) {
      print('Error updating preferences: $e');
      return false;
    }
  }

  // Update settings
  static Future<bool> updateSettings(Map<String, dynamic> settings, {String? token}) async {
    try {
      final response = await ApiService.put('/users/settings', {}, token: token, body: {
        'settings': settings,
      });
      return response['success'] ?? false;
    } catch (e) {
      print('Error updating settings: $e');
      return false;
    }
  }

  // Delete account
  static Future<bool> deleteAccount({String? token}) async {
    try {
      final response = await ApiService.delete('/users/account', token: token);
      return response['success'] ?? false;
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    }
  }

  // Get user statistics
  static Future<Map<String, dynamic>?> getUserStats({String? token}) async {
    try {
      final response = await ApiService.get('/users/stats', token: token);
      if (response['success']) {
        return response['data'];
      }
      return null;
    } catch (e) {
      print('Error fetching user stats: $e');
      return null;
    }
  }

  // Get user activity
  static Future<List<Map<String, dynamic>>?> getUserActivity({String? token}) async {
    try {
      final response = await ApiService.get('/users/activity', token: token);
      if (response['success']) {
        return List<Map<String, dynamic>>.from(response['data']);
      }
      return null;
    } catch (e) {
      print('Error fetching user activity: $e');
      return null;
    }
  }
} 