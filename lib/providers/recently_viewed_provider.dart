import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RecentlyViewedProvider extends ChangeNotifier {
  static const String _storageKey = 'recently_viewed_products';
  static const int _maxItems = 20; // Maximum number of recently viewed items
  
  List<Map<String, dynamic>> _recentlyViewed = [];
  
  List<Map<String, dynamic>> get recentlyViewed => _recentlyViewed;
  int get itemCount => _recentlyViewed.length;
  
  RecentlyViewedProvider() {
    _loadRecentlyViewed();
  }
  
  // Load recently viewed products from local storage
  Future<void> _loadRecentlyViewed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_storageKey);
      
      if (data != null) {
        final List<dynamic> jsonList = json.decode(data);
        _recentlyViewed = jsonList.cast<Map<String, dynamic>>();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading recently viewed: $e');
    }
  }
  
  // Save recently viewed products to local storage
  Future<void> _saveRecentlyViewed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String data = json.encode(_recentlyViewed);
      await prefs.setString(_storageKey, data);
    } catch (e) {
      print('Error saving recently viewed: $e');
    }
  }
  
  // Add a product to recently viewed
  Future<void> addToRecentlyViewed(Map<String, dynamic> product) async {
    try {
      final productId = product['_id']?.toString() ?? product['id']?.toString();
      if (productId == null) return;
      
      // Remove if already exists (to move to top)
      _recentlyViewed.removeWhere((item) => 
        (item['_id']?.toString() ?? item['id']?.toString()) == productId
      );
      
      // Add to beginning of list
      _recentlyViewed.insert(0, {
        ...product,
        'viewedAt': DateTime.now().toIso8601String(),
      });
      
      // Keep only the most recent items
      if (_recentlyViewed.length > _maxItems) {
        _recentlyViewed = _recentlyViewed.take(_maxItems).toList();
      }
      
      await _saveRecentlyViewed();
      notifyListeners();
    } catch (e) {
      print('Error adding to recently viewed: $e');
    }
  }
  
  // Remove a product from recently viewed
  Future<void> removeFromRecentlyViewed(String productId) async {
    try {
      _recentlyViewed.removeWhere((item) => 
        (item['_id']?.toString() ?? item['id']?.toString()) == productId
      );
      
      await _saveRecentlyViewed();
      notifyListeners();
    } catch (e) {
      print('Error removing from recently viewed: $e');
    }
  }
  
  // Clear all recently viewed products
  Future<void> clearRecentlyViewed() async {
    try {
      _recentlyViewed.clear();
      await _saveRecentlyViewed();
      notifyListeners();
    } catch (e) {
      print('Error clearing recently viewed: $e');
    }
  }
  
  // Get recently viewed products with limit
  List<Map<String, dynamic>> getRecentlyViewed({int limit = 10}) {
    return _recentlyViewed.take(limit).toList();
  }
  
  // Check if a product is in recently viewed
  bool isRecentlyViewed(String productId) {
    return _recentlyViewed.any((item) => 
      (item['_id']?.toString() ?? item['id']?.toString()) == productId
    );
  }
  
  // Get recently viewed products by category
  List<Map<String, dynamic>> getRecentlyViewedByCategory(String category) {
    return _recentlyViewed
        .where((item) => item['category'] == category)
        .toList();
  }
  
  // Get recently viewed products with minimum rating
  List<Map<String, dynamic>> getRecentlyViewedByRating(double minRating) {
    return _recentlyViewed
        .where((item) => (item['rating'] ?? 0.0) >= minRating)
        .toList();
  }
} 