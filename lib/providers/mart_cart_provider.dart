import 'package:flutter/material.dart';

class MartCartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];
  bool _isAnimating = false;
  bool _isCleared = false; // Track if cart was recently cleared

  List<Map<String, dynamic>> get items => _items;
  bool get isAnimating => _isAnimating;
  int get itemCount => _items.length;
  double get totalAmount {
    return _items.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  void addItem(Map<String, dynamic> product, {int quantity = 1, String notes = ''}) {
    // If cart was recently cleared, reset the flag
    if (_isCleared) {
      print('🛒 MartCartProvider: Cart was recently cleared, allowing new additions');
      _isCleared = false;
    }
    
    final vendorId = product['vendorId'];
    final productId = product['_id'] ?? product['id'];
    final existingIndex = _items.indexWhere((item) => 
      item['id'] == productId || item['_id'] == productId
    );
    if (existingIndex >= 0) {
      _items[existingIndex]['quantity'] += quantity;
      print('🛒 MartCartProvider: Updated quantity for ${product['name']} - new total: ${_items[existingIndex]['quantity']}');
    } else {
      _items.add({
        ...product,
        'vendorId': vendorId,
        'id': productId,
        'quantity': quantity,
        'notes': notes,
      });
      print('🛒 MartCartProvider: Added new item ${product['name']} - cart total items: ${_items.length}');
    }
    _isAnimating = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 1000), () {
      _isAnimating = false;
      notifyListeners();
    });
  }

  // Debug method to print current cart state
  void debugPrintCartState() {
    print('🛒 MartCartProvider: Current cart state:');
    print('  - Total items: ${_items.length}');
    print('  - Is cleared flag: $_isCleared');
    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      print('  - Item $i: ${item['name']} (${item['quantity']}x)');
    }
  }

  // Check if cart is empty
  bool get isEmpty => _items.isEmpty;
  
  // Check if cart was recently cleared
  bool get wasRecentlyCleared => _isCleared;

  void removeItem(String productId) {
    _items.removeWhere((item) => 
      item['id'] == productId || item['_id'] == productId
    );
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => 
      item['id'] == productId || item['_id'] == productId
    );
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index]['quantity'] = quantity;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    print('🛒 MartCartProvider: Clearing cart - items before: ${_items.length}');
    _items.clear();
    _isCleared = true;
    print('🛒 MartCartProvider: Cart cleared - items after: ${_items.length}');
    notifyListeners();
    
    // Reset the cleared flag after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _isCleared = false;
      print('🛒 MartCartProvider: Cart cleared flag reset');
    });
  }

  // Force clear cart and prevent any additions for a short time
  void forceClearCart() {
    print('🛒 MartCartProvider: Force clearing cart');
    _items.clear();
    _isCleared = true;
    notifyListeners();
    
    // Reset the cleared flag after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      _isCleared = false;
      print('🛒 MartCartProvider: Force clear flag reset');
    });
  }

  int getItemQuantity(String productId) {
    final item = _items.firstWhere(
      (item) => item['id'] == productId || item['_id'] == productId,
      orElse: () => {'quantity': 0},
    );
    return item['quantity'] ?? 0;
  }

  void insertRawItem(int index, Map<String, dynamic> item) {
    _items.insert(index, item);
    notifyListeners();
  }

  // Helper to get vendorId (assume all items from one vendor)
  String? get vendorId {
    if (_items.isEmpty) return null;
    final vendor = _items.first['vendorId'];
    if (vendor is String) return vendor;
    if (vendor is Map && vendor['_id'] != null) return vendor['_id'].toString();
    return null;
  }
} 