import 'package:flutter/material.dart';
import '../models/store.dart';

enum CartItemType { store, tmart }

class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String image;
  final String? vendorId;
  final String? vendorName;
  final CartItemType type;
  final String? notes;
  final Map<String, dynamic>? additionalData;
  final Store? store;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
    required this.type,
    this.vendorId,
    this.vendorName,
    this.notes,
    this.additionalData,
    this.store,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'image': image,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'type': type.name,
      'notes': notes,
      'additionalData': additionalData,
      'store': store?.toJson(),
    };
  }

  CartItem copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    String? image,
    String? vendorId,
    String? vendorName,
    CartItemType? type,
    String? notes,
    Map<String, dynamic>? additionalData,
    Store? store,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      image: image ?? this.image,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      additionalData: additionalData ?? this.additionalData,
      store: store ?? this.store,
    );
  }
}

class UnifiedCartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  bool _isAnimating = false;

  // Getters
  List<CartItem> get items => List.unmodifiable(_items);
  bool get isAnimating => _isAnimating;
  int get itemCount => _items.length;
  
  // Cart type specific getters
  List<CartItem> get storeItems => _items.where((item) => item.type == CartItemType.store).toList();
  List<CartItem> get tmartItems => _items.where((item) => item.type == CartItemType.tmart).toList();
  
  int get storeItemCount => storeItems.length;
  int get tmartItemCount => tmartItems.length;
  
  // Total amounts
  double get totalAmount {
    return _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }
  
  double get storeTotalAmount {
    return storeItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }
  
  double get tmartTotalAmount {
    return tmartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  // Check if cart has mixed items
  bool get hasMixedItems => storeItems.isNotEmpty && tmartItems.isNotEmpty;
  bool get hasStoreItems => storeItems.isNotEmpty;
  bool get hasTmartItems => tmartItems.isNotEmpty;

  // Add item to cart
  void addItem(CartItem item) {
    final existingIndex = _items.indexWhere((existingItem) => 
      existingItem.id == item.id && existingItem.type == item.type
    );
    
    if (existingIndex >= 0) {
      // Update existing item quantity
      final existingItem = _items[existingIndex];
      _items[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + item.quantity,
        notes: item.notes ?? existingItem.notes,
      );
    } else {
      // Add new item
      _items.add(item);
    }
    
    _triggerAnimation();
    notifyListeners();
  }

  // Add store item (convenience method)
  void addStoreItem({
    required String id,
    required String name,
    required double price,
    required int quantity,
    required String image,
    String? vendorId,
    String? vendorName,
    String? notes,
    Map<String, dynamic>? additionalData,
    Store? store,
  }) {
    addItem(CartItem(
      id: id,
      name: name,
      price: price,
      quantity: quantity,
      image: image,
      vendorId: vendorId,
      vendorName: vendorName,
      type: CartItemType.store,
      notes: notes,
      additionalData: additionalData,
      store: store,
    ));
  }

  // Add T-Mart item (convenience method)
  void addTmartItem({
    required String id,
    required String name,
    required double price,
    required int quantity,
    required String image,
    String? vendorId,
    String? vendorName,
    String? notes,
    Map<String, dynamic>? additionalData,
  }) {
    addItem(CartItem(
      id: id,
      name: name,
      price: price,
      quantity: quantity,
      image: image,
      vendorId: vendorId,
      vendorName: vendorName,
      type: CartItemType.tmart,
      notes: notes,
      additionalData: additionalData,
    ));
  }

  // Remove item
  void removeItem(String itemId, CartItemType type) {
    _items.removeWhere((item) => item.id == itemId && item.type == type);
    notifyListeners();
  }

  // Update item quantity
  void updateQuantity(String itemId, CartItemType type, int quantity) {
    final index = _items.indexWhere((item) => 
      item.id == itemId && item.type == type
    );
    
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        final item = _items[index];
        _items[index] = item.copyWith(quantity: quantity);
      }
      notifyListeners();
    }
  }

  // Get item quantity
  int getItemQuantity(String itemId, CartItemType type) {
    final item = _items.firstWhere(
      (item) => item.id == itemId && item.type == type,
      orElse: () => CartItem(
        id: '',
        name: '',
        price: 0,
        quantity: 0,
        image: '',
        type: type,
      ),
    );
    return item.quantity;
  }

  // Clear specific cart type
  void clearCartType(CartItemType type) {
    _items.removeWhere((item) => item.type == type);
    notifyListeners();
  }

  // Clear all items
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Get items by type
  List<CartItem> getItemsByType(CartItemType type) {
    return _items.where((item) => item.type == type).toList();
  }

  // Get store items grouped by vendor
  Map<String, List<CartItem>> getStoreItemsByVendor() {
    final storeItems = getItemsByType(CartItemType.store);
    final grouped = <String, List<CartItem>>{};
    
    for (final item in storeItems) {
      final vendorId = item.vendorId ?? 'unknown';
      if (!grouped.containsKey(vendorId)) {
        grouped[vendorId] = [];
      }
      grouped[vendorId]!.add(item);
    }
    
    return grouped;
  }

  // Get unique stores in cart
  List<Store> getUniqueStores() {
    final storeItems = getItemsByType(CartItemType.store);
    final storeIds = <String>{};
    final stores = <Store>[];
    
    for (final item in storeItems) {
      if (item.store != null && !storeIds.contains(item.store!.id)) {
        storeIds.add(item.store!.id);
        stores.add(item.store!);
      }
    }
    
    return stores;
  }

  // Get items for a specific store
  List<CartItem> getItemsForStore(String storeId) {
    return _items.where((item) => 
      item.type == CartItemType.store && 
      item.vendorId == storeId
    ).toList();
  }

  // Get total amount for a specific store
  double getStoreTotal(String storeId) {
    final storeItems = getItemsForStore(storeId);
    return storeItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  // Check if cart has multiple stores
  bool get hasMultipleStores {
    final storeItems = getItemsByType(CartItemType.store);
    final vendorIds = storeItems.map((item) => item.vendorId).where((id) => id != null).toSet();
    return vendorIds.length > 1;
  }

  // Check if item exists
  bool hasItem(String itemId, CartItemType type) {
    return _items.any((item) => item.id == itemId && item.type == type);
  }

  // Get cart summary
  Map<String, dynamic> getCartSummary() {
    return {
      'totalItems': itemCount,
      'storeItems': storeItemCount,
      'tmartItems': tmartItemCount,
      'totalAmount': totalAmount,
      'storeTotal': storeTotalAmount,
      'tmartTotal': tmartTotalAmount,
      'hasMixedItems': hasMixedItems,
    };
  }

  // Convert to order format
  List<Map<String, dynamic>> getOrderItems() {
    return _items.map((item) => {
      'id': item.id,
      'product': item.id,
      'quantity': item.quantity,
      'price': item.price,
      'name': item.name,
      'image': item.image,
      'type': item.type.name,
      'notes': item.notes,
      'unit': 'piece',
      'orderType': item.type == CartItemType.tmart ? 'tmart' : 'regular',
      'vendorId': item.vendorId,
      'vendorName': item.vendorName,
    }).toList();
  }

  // Animation trigger
  void _triggerAnimation() {
    _isAnimating = true;
    notifyListeners();
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      _isAnimating = false;
      notifyListeners();
    });
  }

  // Migrate from old cart providers (for backward compatibility)
  void migrateFromOldCarts(List<Map<String, dynamic>> storeItems, List<Map<String, dynamic>> tmartItems) {
    // Clear existing items
    _items.clear();
    
    // Add store items
    for (final item in storeItems) {
      addStoreItem(
        id: item['id'] ?? item['name'],
        name: item['name'],
        price: (item['price'] ?? 0).toDouble(),
        quantity: item['quantity'] ?? 1,
        image: item['image'] ?? '',
        vendorId: item['vendorId'],
        notes: item['notes'],
      );
    }
    
    // Add T-Mart items
    for (final item in tmartItems) {
      addTmartItem(
        id: item['id'] ?? item['_id'] ?? '',
        name: item['name'],
        price: (item['price'] ?? 0).toDouble(),
        quantity: item['quantity'] ?? 1,
        image: item['image'] ?? item['imageUrl'] ?? '',
        vendorId: item['vendorId'],
        notes: item['notes'],
      );
    }
    
    notifyListeners();
  }
} 