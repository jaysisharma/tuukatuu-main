import 'package:flutter/material.dart';
import '../../../data/models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];
  bool _isAnimating = false;

  List<Map<String, dynamic>> get items => _items;
  bool get isAnimating => _isAnimating;
  
  int get itemCount => _items.length;
  
  double get totalAmount {
    return _items.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  void addItem(Product product, {int quantity = 1, String notes = ''}) {
    final existingIndex = _items.indexWhere((item) => item['name'] == product.name);
    
    if (existingIndex >= 0) {
      _items[existingIndex]['quantity'] += quantity;
    } else {
      _items.add({
        'name': product.name,
        'price': product.price,
        'quantity': quantity,
        'notes': notes,
        'image': product.imageUrl,
      });
    }
    
    // Trigger animation
    _isAnimating = true;
    notifyListeners();
    
    // Reset animation after 1 second
    Future.delayed(const Duration(milliseconds: 1000), () {
      _isAnimating = false;
      notifyListeners();
    });
  }

  void removeItem(String productName) {
    _items.removeWhere((item) => item['name'] == productName);
    notifyListeners();
  }

  void updateQuantity(String productName, int quantity) {
    final index = _items.indexWhere((item) => item['name'] == productName);
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
    _items.clear();
    notifyListeners();
  }
} 