# Tukatuu Enhanced Cart System Implementation

## Overview

The Tukatuu app now uses a comprehensive enhanced cart system that supports multiple sources (restaurants, stores, and T-Mart) with separate checkout flows. This document explains how to use the new cart system in your app.

## Key Components

### 1. Enhanced Cart Provider (`EnhancedCartProvider`)

The main cart provider that manages all cart operations:

```dart
// Access the cart provider
final cartProvider = Provider.of<EnhancedCartProvider>(context, listen: false);

// Add items to cart
cartProvider.addFromMart(product);                    // T-Mart items
cartProvider.addFromStore(product, store);           // Store items
cartProvider.addFromRestaurant(product, restaurantId: 'id', restaurantName: 'name'); // Restaurant items

// Remove items
cartProvider.removeItem(product, CartItemSource.mart);

// Get quantities
final quantity = cartProvider.getItemQuantity(product, CartItemSource.mart);

// Clear cart
cartProvider.clearCart();
cartProvider.clearSource(CartItemSource.mart);
```

### 2. Cart Item Model (`CartItem`)

Represents individual items in the cart:

```dart
class CartItem {
  final Product product;        // Product details
  int quantity;                 // Current quantity
  final CartItemSource source;  // Source type (restaurant/store/mart)
  final String? sourceId;       // Restaurant/Store ID
  final String? sourceName;     // Display name
  final String? notes;          // Additional notes
  final Store? store;           // Store information if available
}
```

### 3. Cart Item Source Enum

```dart
enum CartItemSource { 
  restaurant,  // Food delivery items
  store,       // Retail store items  
  mart         // T-Mart grocery items
}
```

## Usage in Different Screens

### T-Mart Screens

For T-Mart products, use the `addFromMart` method:

```dart
// In T-Mart product screens
final enhancedCartProvider = Provider.of<EnhancedCartProvider>(context, listen: false);
final product = _convertToProduct(item); // Convert item data to Product model
enhancedCartProvider.addFromMart(product);

// Get quantity for display
final quantity = enhancedCartProvider.getItemQuantity(product, CartItemSource.mart);

// Remove item
enhancedCartProvider.removeItem(product, CartItemSource.mart);
```

### Store Screens

For regular store products, use the `addFromStore` method:

```dart
// In store product screens
final enhancedCartProvider = Provider.of<EnhancedCartProvider>(context, listen: false);
enhancedCartProvider.addFromStore(product, store);

// Get quantity for display
final quantity = enhancedCartProvider.getItemQuantity(product, CartItemSource.store);

// Remove item
enhancedCartProvider.removeItem(product, CartItemSource.store);
```

### Restaurant Screens

For restaurant products, use the `addFromRestaurant` method:

```dart
// In restaurant screens
final enhancedCartProvider = Provider.of<EnhancedCartProvider>(context, listen: false);
enhancedCartProvider.addFromRestaurant(
  product,
  restaurantId: 'restaurant_1',
  restaurantName: 'Restaurant Name',
);

// Get quantity for display
final quantity = enhancedCartProvider.getItemQuantity(product, CartItemSource.restaurant);

// Remove item
enhancedCartProvider.removeItem(product, CartItemSource.restaurant);
```

## Cart Screen Integration

The enhanced cart screen (`CartScreen`) automatically displays items grouped by source:

```dart
// Navigate to cart
Navigator.pushNamed(context, AppRoutes.cart);

// The cart screen shows:
// - Items grouped by source (T-Mart, Store, Restaurant)
// - Collapsible sections for each source
// - Individual checkout per source
// - Clear actions for specific sources
```

## Provider Setup

Make sure the `EnhancedCartProvider` is included in your main.dart:

```dart
MultiProvider(
  providers: [
    // ... other providers
    ChangeNotifierProvider(create: (_) => EnhancedCartProvider()),
    // ... other providers
  ],
  child: MyApp(),
)
```

## Cart Count Display

Update your app bar or cart indicators to use the enhanced cart provider:

```dart
// In app bar or cart indicators
Consumer<EnhancedCartProvider>(
  builder: (context, cartProvider, child) {
    final cartCount = cartProvider.itemCount;
    if (cartCount == 0) return const SizedBox.shrink();
    
    return Container(
      // Your cart count UI
      child: Text(cartCount.toString()),
    );
  },
)
```

## Key Features

### 1. Multi-Source Support
- **T-Mart**: Grocery items with centralized checkout
- **Stores**: Retail items with store-specific checkout
- **Restaurants**: Food delivery items with restaurant-specific checkout

### 2. Source-Specific Operations
```dart
// Get items by source
final martItems = cartProvider.martItems;
final storeItems = cartProvider.storeItems;
final restaurantItems = cartProvider.restaurantItems;

// Get totals by source
final martTotal = cartProvider.martTotalAmount;
final storeTotal = cartProvider.storeTotalAmount;
final restaurantTotal = cartProvider.restaurantTotalAmount;

// Check source-specific conditions
final hasMixedSources = cartProvider.hasMixedSources;
final hasMartItems = cartProvider.hasMartItems;
```

### 3. Grouped Display
```dart
// Get items grouped by source name for UI
final groupedItems = cartProvider.getItemsGroupedBySource();
// Returns: {'T-Mart': [items], 'Store Name': [items], 'Restaurant Name': [items]}
```

### 4. Checkout Support
```dart
// Get checkout sources (unique sources with items)
final checkoutSources = cartProvider.checkoutSources;

// Get items for specific checkout source
final sourceItems = cartProvider.getItemsForCheckoutSource('T-Mart');

// Get total for specific checkout source
final sourceTotal = cartProvider.getTotalForCheckoutSource('T-Mart');
```

## Migration from Old Cart System

If you're migrating from the old cart system:

```dart
// Old way
martCartProvider.addItem(item, quantity: 1);

// New way
final product = _convertToProduct(item);
enhancedCartProvider.addFromMart(product);

// Helper function to convert item data to Product model
Product _convertToProduct(Map<String, dynamic> item) {
  return Product(
    id: item['_id'] ?? item['id'] ?? '',
    name: item['name'] ?? '',
    price: (item['price'] ?? 0).toDouble(),
    imageUrl: item['imageUrl'] ?? item['image'] ?? '',
    category: item['category'] ?? '',
    rating: (item['rating'] ?? 0).toDouble(),
    reviews: item['reviews'] ?? 0,
    isAvailable: item['isAvailable'] ?? true,
    deliveryFee: (item['deliveryFee'] ?? 0).toDouble(),
    description: item['description'] ?? '',
    images: item['images'] != null ? List<String>.from(item['images']) : [],
    vendorId: item['vendorId'] ?? '',
  );
}
```

## Testing

The cart system includes comprehensive unit tests:

```bash
# Run cart system tests
flutter test test/cart_system_test.dart
```

## Benefits

1. **Unified Cart Management**: Single provider handles all cart operations
2. **Source-Specific Logic**: Different checkout flows for different sources
3. **Better UX**: Collapsible sections and clear organization
4. **Extensible**: Easy to add new sources or features
5. **Type Safety**: Strong typing with proper enums and models
6. **Performance**: Efficient state management with minimal rebuilds

## Future Enhancements

1. **Persistence**: Save cart to local storage
2. **Cloud Sync**: Sync cart across devices
3. **Analytics**: Track cart behavior and conversions
4. **Smart Recommendations**: AI-powered cart suggestions
5. **Bulk Operations**: Select multiple items for batch operations

## Troubleshooting

### Common Issues

1. **Cart items not showing**: Check if `EnhancedCartProvider` is properly registered in main.dart
2. **Quantity not updating**: Ensure you're using the correct source enum
3. **Cart count not updating**: Verify the Consumer widget is listening to the right provider

### Debug Tips

```dart
// Add debug prints to track cart operations
print('🛒 Adding item: ${product.name}');
print('🛒 Cart items count: ${cartProvider.itemCount}');
print('🛒 Cart total: ${cartProvider.totalAmount}');
```

## Conclusion

The enhanced cart system provides a robust, scalable foundation for multi-source e-commerce with clean separation of concerns and excellent user experience. The system is ready for production use and can be easily extended with additional features. 