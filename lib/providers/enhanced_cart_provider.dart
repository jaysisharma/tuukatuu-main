import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/store.dart';

class EnhancedCartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  bool _isAnimating = false;

  // Getters
  List<CartItem> get items => List.unmodifiable(_items);
  bool get isAnimating => _isAnimating;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  // Source-specific getters
  List<CartItem> get restaurantItems => _items.where((item) => item.source == CartItemSource.restaurant).toList();
  List<CartItem> get storeItems => _items.where((item) => item.source == CartItemSource.store).toList();
  List<CartItem> get martItems => _items.where((item) => item.source == CartItemSource.mart).toList();

  // Source-specific counts
  int get restaurantItemCount => restaurantItems.length;
  int get storeItemCount => storeItems.length;
  int get martItemCount => martItems.length;

  // Source-specific totals
  double get restaurantTotalAmount => restaurantItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get storeTotalAmount => storeItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get martTotalAmount => martItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  // Get number of different sources in cart
  int get sourceCount {
    int count = 0;
    if (restaurantItems.isNotEmpty) count++;
    if (storeItems.isNotEmpty) count++;
    if (martItems.isNotEmpty) count++;
    return count;
  }

  // Check if cart has mixed sources
  bool get hasMixedSources {
    return sourceCount > 1;
  }

  // Check if cart has specific source items
  bool get hasRestaurantItems => restaurantItems.isNotEmpty;
  bool get hasStoreItems => storeItems.isNotEmpty;
  bool get hasMartItems => martItems.isNotEmpty;

  // Grouped items by source name
  Map<String, List<CartItem>> get groupedItems {
    final Map<String, List<CartItem>> grouped = {};
    
    for (final item in _items) {
      final key = item.displaySourceName;
      grouped.putIfAbsent(key, () => []).add(item);
    }
    
    return grouped;
  }

  // Core Methods

  /// Add item to cart with source tracking
  void addItem(Product product, CartItemSource source, {
    String? sourceId, 
    String? sourceName,
    String? notes,
    Store? store,
  }) {
    final existingIndex = _items.indexWhere(
      (item) => item.product == product && 
                 item.source == source && 
                 item.sourceId == sourceId,
    );

    if (existingIndex >= 0) {
      // Increment existing item quantity
      _items[existingIndex].quantity++;
      print('🛒 Updated existing item: ${product.name} (quantity: ${_items[existingIndex].quantity})');
    } else {
      // Add new item
      final newItem = CartItem(
        product: product,
        quantity: 1,
        source: source,
        sourceId: sourceId,
        sourceName: sourceName,
        notes: notes,
        store: store,
      );
      _items.add(newItem);
      print('🛒 Added new item: ${product.name} from ${source.name}');
    }
    
    _triggerAnimation();
    notifyListeners();
  }

  /// Remove item from cart
  void removeItem(Product product, CartItemSource source, {String? sourceId}) {
    final existingIndex = _items.indexWhere(
      (item) => item.product == product && 
                 item.source == source && 
                 item.sourceId == sourceId,
    );

    if (existingIndex >= 0) {
      if (_items[existingIndex].quantity > 1) {
        _items[existingIndex].quantity--;
        print('🛒 Decremented item: ${product.name} (quantity: ${_items[existingIndex].quantity})');
      } else {
        _items.removeAt(existingIndex);
        print('🛒 Removed item: ${product.name}');
      }
      notifyListeners();
    }
  }

  /// Update item quantity
  void updateQuantity(Product product, CartItemSource source, int quantity, {String? sourceId}) {
    final existingIndex = _items.indexWhere(
      (item) => item.product == product && 
                 item.source == source && 
                 item.sourceId == sourceId,
    );

    if (existingIndex >= 0) {
      if (quantity <= 0) {
        _items.removeAt(existingIndex);
        print('🛒 Removed item: ${product.name} (quantity set to 0)');
      } else {
        _items[existingIndex].quantity = quantity;
        print('🛒 Updated item: ${product.name} (quantity: $quantity)');
      }
      notifyListeners();
    }
  }

  /// Get item quantity
  int getItemQuantity(Product product, CartItemSource source, {String? sourceId}) {
    final item = _items.firstWhere(
      (item) => item.product == product && 
                 item.source == source && 
                 item.sourceId == sourceId,
      orElse: () => CartItem(
        product: product,
        quantity: 0,
        source: source,
        sourceId: sourceId,
      ),
    );
    return item.quantity;
  }

  /// Clear all items
  void clearCart() {
    _items.clear();
    print('🛒 Cart cleared');
    notifyListeners();
  }

  /// Clear items by source
  void clearSource(CartItemSource source) {
    _items.removeWhere((item) => item.source == source);
    print('🛒 Cleared ${source.name} items');
    notifyListeners();
  }

  /// Clear items by specific source ID
  void clearSourceById(String sourceId) {
    _items.removeWhere((item) => item.sourceId == sourceId);
    print('🛒 Cleared items for source ID: $sourceId');
    notifyListeners();
  }

  // Source-specific convenience methods

  /// Add restaurant item
  void addFromRestaurant(Product product, {
    required String restaurantId,
    required String restaurantName,
    String? notes,
  }) {
    addItem(
      product, 
      CartItemSource.restaurant,
      sourceId: restaurantId,
      sourceName: restaurantName,
      notes: notes,
    );
  }

  /// Add store item
  void addFromStore(Product product, Store store, {String? notes}) {
    addItem(
      product, 
      CartItemSource.store,
      sourceId: store.id,
      sourceName: store.name,
      notes: notes,
      store: store,
    );
  }

  /// Add mart item
  void addFromMart(Product product, {String? notes}) {
    addItem(
      product, 
      CartItemSource.mart,
      sourceName: 'T-Mart',
      notes: notes,
    );
  }

  // Utility methods

  /// Check if item exists in cart
  bool hasItem(Product product, CartItemSource source, {String? sourceId}) {
    return _items.any(
      (item) => item.product == product && 
                 item.source == source && 
                 item.sourceId == sourceId,
    );
  }

  /// Get items by source
  List<CartItem> getItemsBySource(CartItemSource source) {
    return _items.where((item) => item.source == source).toList();
  }

  /// Get items by source ID
  List<CartItem> getItemsBySourceId(String sourceId) {
    return _items.where((item) => item.sourceId == sourceId).toList();
  }

  /// Get total amount for specific source
  double getSourceTotal(CartItemSource source) {
    return getItemsBySource(source).fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// Get total amount for specific source ID
  double getSourceIdTotal(String sourceId) {
    return getItemsBySourceId(sourceId).fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// Get cart summary
  Map<String, dynamic> getCartSummary() {
    return {
      'totalItems': itemCount,
      'totalAmount': totalAmount,
      'restaurantItems': restaurantItemCount,
      'storeItems': storeItemCount,
      'martItems': martItemCount,
      'restaurantTotal': restaurantTotalAmount,
      'storeTotal': storeTotalAmount,
      'martTotal': martTotalAmount,
      'hasMixedSources': hasMixedSources,
      'sources': {
        'restaurant': hasRestaurantItems,
        'store': hasStoreItems,
        'mart': hasMartItems,
      },
    };
  }

  /// Convert cart items to order format
  List<Map<String, dynamic>> getOrderItems() {
    return _items.map((item) {
      return {
        'productId': item.product.id,
        'productName': item.product.name,
        'price': item.product.price,
        'quantity': item.quantity,
        'totalPrice': item.totalPrice,
        'imageUrl': item.product.imageUrl,
        'source': item.source.name,
        'sourceId': item.sourceId,
        'sourceName': item.sourceName,
        'notes': item.notes,
        'store': item.store?.toJson(),
      };
    }).toList();
  }

  /// Get items grouped by source for UI display
  Map<String, List<CartItem>> getItemsGroupedBySource() {
    final Map<String, List<CartItem>> grouped = {};
    
    for (final item in _items) {
      final key = item.displaySourceName;
      grouped.putIfAbsent(key, () => []).add(item);
    }
    
    return grouped;
  }

  /// Check if cart can be checked out (has items)
  bool get canCheckout => _items.isNotEmpty;

  /// Get checkout sources (unique sources with items)
  List<String> get checkoutSources {
    final sources = <String>{};
    for (final item in _items) {
      sources.add(item.displaySourceName);
    }
    return sources.toList();
  }

  /// Get items for specific checkout source
  List<CartItem> getItemsForCheckoutSource(String sourceName) {
    return _items.where((item) => item.displaySourceName == sourceName).toList();
  }

  /// Get total amount for specific checkout source
  double getTotalForCheckoutSource(String sourceName) {
    return getItemsForCheckoutSource(sourceName)
        .fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Animation methods

  /// Trigger cart animation
  void _triggerAnimation() {
    _isAnimating = true;
    notifyListeners();
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      _isAnimating = false;
      notifyListeners();
    });
  }

  // Persistence methods (for future implementation)

  /// Save cart to local storage
  Future<void> saveCart() async {
    // TODO: Implement local storage
    print('🛒 Cart saved to local storage');
  }

  /// Load cart from local storage
  Future<void> loadCart() async {
    // TODO: Implement local storage loading
    print('🛒 Cart loaded from local storage');
  }

  /// Sync cart with backend
  Future<void> syncCart() async {
    // TODO: Implement backend sync
    print('🛒 Cart synced with backend');
  }

  // Migration methods (for backward compatibility)

  /// Migrate from old cart format
  void migrateFromOldCart(List<Map<String, dynamic>> oldItems) {
    _items.clear();
    
    for (final oldItem in oldItems) {
      // Create product from old item data
      final product = Product(
        id: oldItem['id'] ?? '',
        name: oldItem['name'] ?? '',
        price: (oldItem['price'] ?? 0).toDouble(),
        imageUrl: oldItem['image'] ?? '',
        category: oldItem['category'] ?? '',
        rating: 4.0,
        reviews: 0,
        isAvailable: true,
        deliveryFee: 0,
        description: '',
        images: [],
        vendorId: oldItem['vendorId'] ?? '',
      );

      // Determine source from old data
      CartItemSource source = CartItemSource.mart;
      if (oldItem['type'] == 'restaurant') {
        source = CartItemSource.restaurant;
      } else if (oldItem['type'] == 'store') {
        source = CartItemSource.store;
      }

      addItem(
        product,
        source,
        sourceId: oldItem['vendorId'],
        sourceName: oldItem['vendorName'],
        notes: oldItem['notes'],
      );
    }
    
    print('🛒 Migrated ${oldItems.length} items from old cart format');
  }
} 