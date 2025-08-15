import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FavoritesProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = false;
  String? _error;
  Set<String> _favoritedItems = {};

  // Getters
  List<Map<String, dynamic>> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Set<String> get favoritedItems => _favoritedItems;

  // Check if an item is favorited
  bool isFavorited(String itemId) {
    return _favoritedItems.contains(itemId);
  }

  // Load user favorites from backend
  Future<void> loadFavorites(String token) async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final favorites = await ApiService.getUserFavorites(token: token);
      _favorites = favorites;
      
      // Update favorited items set
      _favoritedItems = favorites.map((fav) => fav['itemId'] as String).toSet();
      
      _error = null;
    } catch (e) {
      _error = e is ApiException ? e.message : 'Failed to load favorites';
      print('❌ Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add item to favorites
  Future<bool> addToFavorites({
    required String token,
    required String itemId,
    required String itemType,
    required String itemName,
    required String itemImage,
    double? rating,
    String? category,
  }) async {
    // Debug: Print the data being sent
    print('🔍 FavoritesProvider: Adding to favorites');
    print('🔍 itemId: $itemId');
    print('🔍 itemType: $itemType');
    print('🔍 itemName: $itemName');
    print('🔍 itemImage: $itemImage');
    print('🔍 rating: $rating');
    print('🔍 category: $category');
    
    try {
      final result = await ApiService.addToFavorites(
        token: token,
        itemId: itemId,
        itemType: itemType,
        itemName: itemName,
        itemImage: itemImage,
        rating: rating,
        category: category,
      );

      // Add to local favorites list
      final newFavorite = {
        'itemId': itemId,
        'itemType': itemType,
        'itemName': itemName,
        'itemImage': itemImage,
        'rating': rating,
        'category': category,
        'addedAt': DateTime.now().toIso8601String(),
      };

      _favorites.add(newFavorite);
      _favoritedItems.add(itemId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : 'Failed to add to favorites';
      print('❌ Error adding to favorites: $e');
      notifyListeners();
      return false;
    }
  }

  // Remove item from favorites
  Future<bool> removeFromFavorites({
    required String token,
    required String itemId,
  }) async {
    try {
      await ApiService.removeFromFavorites(token: token, itemId: itemId);

      // Remove from local favorites list
      _favorites.removeWhere((fav) => fav['itemId'] == itemId);
      _favoritedItems.remove(itemId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : 'Failed to remove from favorites';
      print('❌ Error removing from favorites: $e');
      notifyListeners();
      return false;
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavorite({
    required String token,
    required String itemId,
    required String itemType,
    required String itemName,
    required String itemImage,
    double? rating,
    String? category,
  }) async {
    if (isFavorited(itemId)) {
      return await removeFromFavorites(token: token, itemId: itemId);
    } else {
      return await addToFavorites(
        token: token,
        itemId: itemId,
        itemType: itemType,
        itemName: itemName,
        itemImage: itemImage,
        rating: rating,
        category: category,
      );
    }
  }

  // Check favorite status from backend
  Future<void> checkFavoriteStatus(String token, String itemId) async {
    try {
      final isFavorited = await ApiService.checkIfFavorited(
        token: token,
        itemId: itemId,
      );
      
      if (isFavorited) {
        _favoritedItems.add(itemId);
      } else {
        _favoritedItems.remove(itemId);
      }
      
      notifyListeners();
    } catch (e) {
      print('❌ Error checking favorite status: $e');
    }
  }

  // Clear favorites (useful for logout)
  void clearFavorites() {
    _favorites.clear();
    _favoritedItems.clear();
    _error = null;
    notifyListeners();
  }

  // Get favorites by type
  List<Map<String, dynamic>> getFavoritesByType(String type) {
    return _favorites.where((fav) => fav['itemType'] == type).toList();
  }

  // Get restaurants favorites
  List<Map<String, dynamic>> get restaurantFavorites => getFavoritesByType('restaurant');

  // Get stores favorites
  List<Map<String, dynamic>> get storeFavorites => getFavoritesByType('store');
}
