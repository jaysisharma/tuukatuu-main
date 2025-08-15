import 'package:flutter/foundation.dart';

class GlobalCartProvider extends ChangeNotifier {
  // Global cart state for all products
  final Map<String, int> _cartItems = {};
  
  // Get all cart items
  Map<String, int> get cartItems => Map.unmodifiable(_cartItems);
  
  // Get total items count
  int get totalItems {
    return _cartItems.values.fold(0, (sum, quantity) => sum + quantity);
  }
  
  // Check if cart is empty
  bool get isEmpty => _cartItems.isEmpty;
  
  // Check if cart has items
  bool get hasItems => _cartItems.isNotEmpty;
  
  // Get quantity for a specific product
  int getItemQuantity(String productName) {
    return _cartItems[productName] ?? 0;
  }
  
  // Add item to cart
  void addToCart(String productName) {
    _cartItems[productName] = (_cartItems[productName] ?? 0) + 1;
    notifyListeners();
  }
  
  // Remove item from cart
  void removeFromCart(String productName) {
    final currentQuantity = _cartItems[productName] ?? 0;
    if (currentQuantity > 0) {
      _cartItems[productName] = currentQuantity - 1;
      if (_cartItems[productName] == 0) {
        _cartItems.remove(productName);
      }
      notifyListeners();
    }
  }
  
  // Set specific quantity for a product
  void setQuantity(String productName, int quantity) {
    if (quantity <= 0) {
      _cartItems.remove(productName);
    } else {
      _cartItems[productName] = quantity;
    }
    notifyListeners();
  }
  
  // Clear cart
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
  
  // Get cart total price (if price data is available)
  double getTotalPrice(Map<String, double> productPrices) {
    double total = 0.0;
    for (final entry in _cartItems.entries) {
      final productName = entry.key;
      final quantity = entry.value;
      final price = productPrices[productName] ?? 0.0;
      total += price * quantity;
    }
    return total;
  }
  
  // Get cart summary
  Map<String, dynamic> getCartSummary() {
    return {
      'totalItems': totalItems,
      'uniqueProducts': _cartItems.length,
      'isEmpty': isEmpty,
      'hasItems': hasItems,
    };
  }
}
