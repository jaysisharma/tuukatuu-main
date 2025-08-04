# T-Mart Fast Delivery Service Documentation

## Overview
T-Mart is a fast delivery service that shows vendor products but with faster delivery times (10-20 minutes) compared to regular store delivery (25-45 minutes). It functions as a specialized delivery service within the existing vendor ecosystem.

## Cart Logic Implementation

### 1. T-Mart Screen (`lib/presentation/screens/t_mart_screen.dart`)

#### Product Loading
```dart
// Load vendor products for T-Mart (fast delivery)
final popularResponse = await ApiService.get('/products');
if (popularResponse is List) {
  _popularProducts = List<Map<String, dynamic>>.from(popularResponse);
  print('✅ Loaded ${_popularProducts.length} vendor products for T-Mart from API');
}
```

#### Adding Products to Cart
```dart
unifiedCartProvider.addTmartItem(
  id: item['_id'] ?? item['id'] ?? '',
  name: item['name'] ?? '',
  price: (item['price'] ?? 0).toDouble(),
  quantity: 1,
  image: item['imageUrl'] ?? item['image'] ?? '',
  vendorId: item['vendorId'],
);
```

#### Cart Type
- **Cart Type**: `CartItemType.tmart`
- **Provider**: `UnifiedCartProvider`
- **Method**: `addTmartItem()` instead of `addStoreItem()`

### 2. Unified Cart Provider (`lib/providers/unified_cart_provider.dart`)

#### T-Mart Item Addition
```dart
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
    type: CartItemType.tmart,  // Key difference
    notes: notes,
    additionalData: additionalData,
  ));
}
```

#### T-Mart Specific Getters
```dart
List<CartItem> get tmartItems => _items.where((item) => item.type == CartItemType.tmart).toList();
int get tmartItemCount => tmartItems.fold(0, (sum, item) => sum + item.quantity);
double get tmartTotalAmount => tmartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
```

### 3. Multi-Store Cart Screen (`lib/presentation/screens/multi_store_cart_screen.dart`)

#### T-Mart Section Display
```dart
// Fast Delivery items (T-Mart)
if (tmartItems.isNotEmpty) ...[
  const Text(
    'Fast Delivery Orders',
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  const SizedBox(height: 16),
  _buildTmartSection(context, tmartItems, cartProvider),
],
```

#### T-Mart Section Builder
```dart
Widget _buildTmartSection(
  BuildContext context,
  List<CartItem> items,
  UnifiedCartProvider cartProvider,
) {
  return Container(
    // T-Mart specific styling with orange theme
    child: Column(
      children: [
        // T-Mart header with fast delivery info
        Container(
          child: Row(
            children: [
              Text('T-Mart Express'),
              Text('10-20 min delivery'),  // Faster than regular stores
            ],
          ),
        ),
        // Items list
        ListView.builder(
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildCartItem(context, item, cartProvider);
          },
        ),
        // T-Mart checkout button
        ElevatedButton(
          onPressed: () => _checkoutTmart(context, items, cartProvider),
        ),
      ],
    ),
  );
}
```

## Comparison: T-Mart vs Store Detail Screen

### Store Detail Screen (`lib/screens/store_details_screen.dart`)

#### Product Addition
```dart
// Regular store products
cartProvider.addStoreItem(
  id: product.id,
  name: product.name,
  price: product.price,
  quantity: quantity,
  image: product.imageUrl,
  vendorId: widget.store['id'] ?? 'store1',
  vendorName: widget.store['name'] ?? 'Store',
  store: widget.store,
);
```

#### Cart Type
- **Cart Type**: `CartItemType.store`
- **Provider**: `CartProvider` or `UnifiedCartProvider`
- **Method**: `addStoreItem()`

### Key Differences

| Aspect | T-Mart | Store Detail Screen |
|--------|--------|-------------------|
| **Cart Type** | `CartItemType.tmart` | `CartItemType.store` |
| **Delivery Time** | 10-20 minutes | 25-45 minutes |
| **Provider Method** | `addTmartItem()` | `addStoreItem()` |
| **UI Theme** | Orange (fast delivery) | Store-specific colors |
| **Product Source** | All vendor products | Store-specific products |
| **Vendor ID** | `null` (T-Mart service) | Store's actual vendor ID |
| **Vendor SubType** | `'tmart'` | Store's subtype |

## Detailed Differences Analysis

### 1. **Product Loading & Data Source**

#### T-Mart Screen:
```dart
// Loads ALL vendor products for fast delivery
final popularResponse = await ApiService.get('/products');
final recommendationsResponse = await ApiService.get('/products');
final dailyEssentialsResponse = await ApiService.get('/products');
```
- **Source**: All vendor products from `/products` endpoint
- **Filtering**: No vendor-specific filtering
- **Purpose**: Show any vendor's products for fast delivery

#### Store Detail Screen:
```dart
// Loads ONLY store-specific products
final products = await ApiService.getProductsByVendor(widget.store['id']);
```
- **Source**: Store-specific products from `/products?vendorId=store_id`
- **Filtering**: Filtered by specific vendor ID
- **Purpose**: Show only products from the selected store

### 2. **Cart Item Creation**

#### T-Mart Cart Item:
```dart
CartItem(
  id: productId,
  name: productName,
  price: price,
  quantity: quantity,
  image: imageUrl,
  vendorId: item['vendorId'],  // Original vendor's ID
  vendorName: item['vendorName'], // Original vendor's name
  type: CartItemType.tmart,    // T-Mart cart type
  notes: notes,
)
```

#### Store Cart Item:
```dart
CartItem(
  id: product.id,
  name: product.name,
  price: product.price,
  quantity: quantity,
  image: product.imageUrl,
  vendorId: widget.store['id'],     // Store's vendor ID
  vendorName: widget.store['name'], // Store's name
  type: CartItemType.store,         // Store cart type
  store: widget.store,              // Full store object
  notes: notes,
)
```

### 3. **Provider Method Differences**

#### T-Mart Provider Method:
```dart
void addTmartItem({
  required String id,
  required String name,
  required double price,
  required int quantity,
  required String image,
  String? vendorId,      // Original vendor's ID
  String? vendorName,    // Original vendor's name
  String? notes,
  Map<String, dynamic>? additionalData,
}) {
  addItem(CartItem(
    // ... other fields
    type: CartItemType.tmart,  // Key difference
    vendorId: vendorId,        // Preserves original vendor
    vendorName: vendorName,    // Preserves original vendor name
  ));
}
```

#### Store Provider Method:
```dart
void addStoreItem({
  required String id,
  required String name,
  required double price,
  required int quantity,
  required String image,
  String? vendorId,      // Store's vendor ID
  String? vendorName,    // Store's name
  String? notes,
  Map<String, dynamic>? additionalData,
  Store? store,          // Full store object
}) {
  addItem(CartItem(
    // ... other fields
    type: CartItemType.store,  // Key difference
    vendorId: vendorId,        // Store's vendor ID
    vendorName: vendorName,    // Store's name
    store: store,              // Full store object
  ));
}
```

### 4. **Cart Display Logic**

#### T-Mart in Multi-Store Cart:
```dart
// Fast Delivery items (T-Mart)
if (tmartItems.isNotEmpty) ...[
  const Text('Fast Delivery Orders'),
  _buildTmartSection(context, tmartItems, cartProvider),
],
```

#### Store Items in Multi-Store Cart:
```dart
// Store items grouped by vendor
if (stores.isNotEmpty) ...[
  const Text('Store Orders'),
  ...stores.map((store) => _buildStoreSection(
    context, store, storeItemsByVendor[store.id] ?? [], cartProvider,
  )),
],
```

### 5. **Checkout Process Differences**

#### T-Mart Checkout:
```dart
// T-Mart checkout in multi-store cart
void _checkoutTmart(BuildContext context, List<CartItem> items, UnifiedCartProvider cartProvider) {
  final checkoutItems = items.map((item) => {
    'id': item.id,
    'name': item.name,
    'price': item.price,
    'quantity': item.quantity,
    'image': item.image,
    'type': item.type.name,
    'notes': item.notes,
    'vendorId': item.vendorId,      // Original vendor's ID
    'vendorName': item.vendorName,  // Original vendor's name
    'unit': 'piece',
    'orderType': 'tmart',           // T-Mart order type
  }).toList();
}
```

#### Store Checkout:
```dart
// Store checkout in multi-store cart
void _checkoutStore(BuildContext context, Store store, List<CartItem> items, UnifiedCartProvider cartProvider) {
  final checkoutItems = items.map((item) => {
    'id': item.id,
    'name': item.name,
    'price': item.price,
    'quantity': item.quantity,
    'image': item.image,
    'type': item.type.name,
    'notes': item.notes,
    'vendorId': storeId,            // Store's vendor ID
    'vendorName': storeName,        // Store's name
    'unit': 'piece',
    'orderType': 'store',           // Store order type
  }).toList();
}
```

### 6. **Backend Order Processing**

#### T-Mart Order:
```javascript
{
  vendorId: 'tmart',              // T-Mart service ID
  orderType: 'tmart',             // Fast delivery order
  deliveryTime: '10-20 mins',     // Faster delivery
  deliveryFee: 20,                // Standard T-Mart fee
  items: [
    {
      productId: 'product_id',
      vendorId: 'original_vendor_id',  // Original vendor
      vendorName: 'Original Vendor Name',
      // ... other item details
    }
  ]
}
```

#### Store Order:
```javascript
{
  vendorId: 'store_vendor_id',    // Store's vendor ID
  orderType: 'store',             // Regular store order
  deliveryTime: '25-45 mins',     // Regular delivery
  deliveryFee: store.deliveryFee, // Store's delivery fee
  items: [
    {
      productId: 'product_id',
      vendorId: 'store_vendor_id', // Store's vendor ID
      vendorName: 'Store Name',
      // ... other item details
    }
  ]
}
```

### 7. **UI/UX Differences**

#### T-Mart UI Elements:
- **Header**: "T-Mart Express - Fast Delivery Service"
- **Sections**: "Fast Delivery Products", "Fast Delivery Recommendations"
- **Color Scheme**: Orange theme (`swiggyOrange`)
- **Delivery Promise**: "10-20 min delivery"
- **Cart Badge**: Shows T-Mart item count

#### Store UI Elements:
- **Header**: Store name and rating
- **Sections**: Store-specific categories and products
- **Color Scheme**: Store-specific branding
- **Delivery Promise**: "25-45 min delivery"
- **Cart Badge**: Shows store item count

### 8. **Cart Provider Getters**

#### T-Mart Specific Getters:
```dart
List<CartItem> get tmartItems => _items.where((item) => item.type == CartItemType.tmart).toList();
int get tmartItemCount => tmartItems.fold(0, (sum, item) => sum + item.quantity);
double get tmartTotalAmount => tmartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
```

#### Store Specific Getters:
```dart
List<CartItem> get storeItems => _items.where((item) => item.type == CartItemType.store).toList();
int get storeItemCount => storeItems.fold(0, (sum, item) => sum + item.quantity);
double get storeTotalAmount => storeItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
```

### 9. **Database Schema Differences**

#### T-Mart Products:
```javascript
{
  name: 'Fresh Bananas',
  vendorType: 'store',        // Uses 'store' type
  vendorSubType: 'tmart',     // Identifies as T-Mart
  deliveryTime: '10-20 mins', // Faster delivery
  deliveryFee: 20,            // Standard T-Mart fee
  vendorId: null,             // No specific vendor
  vendorName: 'T-Mart Express'
}
```

#### Store Products:
```javascript
{
  name: 'Kung Pao Chicken',
  vendorType: 'restaurant',   // Restaurant type
  vendorSubType: 'chinese',   // Chinese cuisine
  deliveryTime: '25 mins',    // Regular delivery
  deliveryFee: 30,            // Store's delivery fee
  vendorId: 'store_vendor_id', // Store's vendor ID
  vendorName: 'Chinese Restaurant'
}
```

### 10. **Business Logic Differences**

#### T-Mart Business Logic:
- **Service Type**: Fast delivery service
- **Product Selection**: Any vendor's products
- **Delivery Promise**: 10-20 minutes
- **Pricing**: Standard T-Mart delivery fee
- **Vendor Relationship**: Acts as delivery service for other vendors

#### Store Business Logic:
- **Service Type**: Direct vendor service
- **Product Selection**: Only store's own products
- **Delivery Promise**: 25-45 minutes
- **Pricing**: Store's own delivery fee
- **Vendor Relationship**: Direct vendor-customer relationship

## Cart Flow Architecture

### 1. Product Selection
```
T-Mart Screen → Product Card → addTmartItem() → UnifiedCartProvider
```

### 2. Cart Management
```
UnifiedCartProvider → CartItem (type: tmart) → Multi-Store Cart Screen
```

### 3. Checkout Process
```
Multi-Store Cart → T-Mart Section → Checkout Screen → Backend Order
```

## Backend Integration

### Product Model
```javascript
// T-Mart products in database
{
  name: 'Fresh Bananas',
  vendorType: 'store',        // Uses 'store' type
  vendorSubType: 'tmart',     // Identifies as T-Mart
  deliveryTime: '10-20 mins', // Faster delivery
  deliveryFee: 20,            // Standard T-Mart fee
  vendorId: null,             // No specific vendor
  vendorName: 'T-Mart Express'
}
```

### Order Processing
```javascript
// Orders are processed with T-Mart specific logic
{
  vendorId: 'tmart',          // T-Mart service ID
  orderType: 'tmart',         // Fast delivery order
  deliveryTime: '10-20 mins', // Faster delivery promise
  deliveryFee: 20             // Standard T-Mart fee
}
```

## UI/UX Differences

### T-Mart Screen
- **Header**: "T-Mart Express - Fast Delivery Service"
- **Sections**: "Fast Delivery Products", "Fast Delivery Recommendations"
- **Theme**: Orange color scheme (swiggyOrange)
- **Delivery Promise**: 10-20 minutes

### Store Detail Screen
- **Header**: Store name and rating
- **Sections**: Store-specific categories and products
- **Theme**: Store-specific branding
- **Delivery Promise**: 25-45 minutes

## Cart Integration Points

### 1. Unified Cart Provider
- Manages both store and T-Mart items
- Separate methods for each cart type
- Different total calculations

### 2. Multi-Store Cart Screen
- Shows both store and T-Mart sections
- Different styling for each section
- Separate checkout flows

### 3. Checkout Screen
- Handles both cart types
- Different vendor ID logic
- Same order processing backend

## Key Implementation Details

### 1. Cart Type Separation
```dart
enum CartItemType { store, tmart }
```

### 2. Provider Methods
```dart
// T-Mart specific
void addTmartItem(...)
List<CartItem> get tmartItems
double get tmartTotalAmount

// Store specific  
void addStoreItem(...)
List<CartItem> get storeItems
double get storeTotalAmount
```

### 3. UI Components
```dart
// T-Mart specific components
TMartProductCard
TMartSectionHeader
TMartDealCard
```

### 4. API Endpoints
```dart
// T-Mart uses regular product endpoints
ApiService.get('/products')  // All vendor products
ApiService.get('/tmart/products')  // T-Mart specific (if needed)
```

## Benefits of This Architecture

1. **Reuses Existing Infrastructure**: T-Mart leverages existing vendor products
2. **Fast Delivery Promise**: 10-20 minute delivery vs 25-45 minutes
3. **Unified Cart Management**: Single provider handles both cart types
4. **Flexible Product Selection**: Can show any vendor's products
5. **Clear UI Differentiation**: Orange theme distinguishes fast delivery
6. **Scalable**: Easy to add more fast delivery services

## Future Enhancements

1. **T-Mart Specific Products**: Add products exclusive to T-Mart
2. **Dynamic Delivery Times**: Adjust based on location and demand
3. **T-Mart Categories**: Special categories for fast delivery
4. **Rider Assignment**: Dedicated fast delivery riders
5. **Premium Pricing**: Slightly higher prices for faster delivery 