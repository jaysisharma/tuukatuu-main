import 'package:flutter/material.dart';

class MartCartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];
  bool _isAnimating = false;

  List<Map<String, dynamic>> get items => _items;
  bool get isAnimating => _isAnimating;
  int get itemCount => _items.length;
  double get totalAmount {
    return _items.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  void addItem(Map<String, dynamic> product, {int quantity = 1, String notes = ''}) {
    final vendorId = product['vendorId'];
    final productId = product['_id'] ?? product['id'];
    final existingIndex = _items.indexWhere((item) => 
      item['id'] == productId || item['_id'] == productId
    );
    if (existingIndex >= 0) {
      _items[existingIndex]['quantity'] += quantity;
    } else {
      _items.add({
        ...product,
        'vendorId': vendorId,
        'id': productId,
        'quantity': quantity,
        'notes': notes,
      });
    }
    _isAnimating = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 1000), () {
      _isAnimating = false;
      notifyListeners();
    });
  }

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
    _items.clear();
    notifyListeners();
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