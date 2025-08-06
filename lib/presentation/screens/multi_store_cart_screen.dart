import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/unified_cart_provider.dart';
import '../../models/store.dart';
import '../../widgets/cached_image.dart';
import '../../core/config/routes.dart';
import '../screens/checkout_screen.dart';

class MultiStoreCartScreen extends StatelessWidget {
  const MultiStoreCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          Consumer<UnifiedCartProvider>(
            builder: (context, cartProvider, child) {
              if (cartProvider.items.isNotEmpty) {
                return TextButton.icon(
                  onPressed: () {
                    _showClearCartDialog(context, cartProvider);
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    'Clear All',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<UnifiedCartProvider>(
        builder: (context, cartProvider, child) {
          print('🛒 Multi Cart - Screen Build:');
          print('  - Total cart items: ${cartProvider.items.length}');
          print('  - Cart items: ${cartProvider.items.map((item) => '${item.name} (${item.quantity})').join(', ')}');
          
          if (cartProvider.items.isEmpty) {
            return _buildEmptyCart(context);
          }

          final stores = cartProvider.getUniqueStores();
          final storeItemsByVendor = cartProvider.getStoreItemsByVendor();
          final storeItemsWithStores = cartProvider.getStoreItemsWithStores();
          final tmartItems = cartProvider.getItemsByType(CartItemType.tmart);
          
          print('  - Unique stores: ${stores.length}');
          print('  - Store items by vendor: ${storeItemsByVendor.keys.length} vendors');
          print('  - Store items with stores: ${storeItemsWithStores.keys.length} stores');
          print('  - T-Mart items: ${tmartItems.length}');
          
          for (final store in stores) {
            print('    * Store: ${store.name} (${store.id})');
            final storeItems = storeItemsWithStores[store] ?? [];
            print('    * Store items: ${storeItems.length}');
            for (final item in storeItems) {
              print('      - ${item.name}: ${item.quantity}x Rs${item.price}');
            }
          }
          
          if (tmartItems.isNotEmpty) {
            print('    * T-Mart items: ${tmartItems.length}');
            for (final item in tmartItems) {
              print('      - ${item.name}: ${item.quantity}x Rs${item.price}');
            }
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: [
                    // Store items
                    if (storeItemsWithStores.isNotEmpty) ...[
                      const Text(
                        'Store Orders',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...storeItemsWithStores.entries.map((entry) => _buildStoreSection(
                        context,
                        entry.key,
                        entry.value,
                        cartProvider,
                      )),
                      if (tmartItems.isNotEmpty) const SizedBox(height: 24),
                    ],
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
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 100,
              color: theme.disabledColor.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Your cart is empty',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some delicious food to get started',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.disabledColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Start Shopping',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreSection(
    BuildContext context,
    Store store,
    List<CartItem> items,
    UnifiedCartProvider cartProvider,
  ) {
    final theme = Theme.of(context);
    
    // Calculate total amount from the items directly
    final totalAmount = items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Store header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedImage(
                    imageUrl: store.banner.isNotEmpty ? store.banner : store.image,
                    width: 60,
                    height: 60,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${items.length} items • ${store.deliveryTime}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rs ${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      'Total',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Items count display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_basket,
                  size: 16,
                  color: theme.disabledColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '${items.length} item${items.length == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.disabledColor,
                  ),
                ),
              ],
            ),
          ),
          // Store checkout button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _checkoutStore(context, store, items, cartProvider),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Checkout from ${store.name}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTmartSection(
    BuildContext context,
    List<CartItem> items,
    UnifiedCartProvider cartProvider,
  ) {
    final theme = Theme.of(context);
    final totalAmount = cartProvider.tmartTotalAmount;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // T-Mart header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_grocery_store,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'T-Mart Express',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '10-20 min delivery',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.disabledColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Items count display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_basket,
                  size: 16,
                  color: theme.disabledColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '${items.length} item${items.length == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.disabledColor,
                  ),
                ),
              ],
            ),
          ),
          // T-Mart checkout button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _checkoutTmart(context, items, cartProvider),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                icon: const Icon(Icons.local_grocery_store, size: 20),
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Checkout from T-Mart',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'Rs ${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  void _checkoutStore(
    BuildContext context,
    Store store,
    List<CartItem> items,
    UnifiedCartProvider cartProvider,
  ) {
    print('🛒 Multi Cart - Checkout Store Debug:');
    print('  - Store ID: ${store.id}');
    print('  - Store Name: ${store.name}');
    print('  - Items count: ${items.length}');
    print('  - Total cart items: ${cartProvider.items.length}');
    
    final orderItems = items.map((item) {
      print('  - Processing item: ${item.name}');
      print('    * Item ID: ${item.id}');
      print('    * Item Price: ${item.price}');
      print('    * Item Quantity: ${item.quantity}');
      print('    * Item Type: ${item.type.name}');
      print('    * Item Vendor ID: ${item.vendorId}');
      print('    * Item Vendor Name: ${item.vendorName}');
      
      // Ensure vendorId is always set
      final finalVendorId = item.vendorId ?? store.id;
      final finalVendorName = item.vendorName ?? store.name;
      
      print('    * Final Vendor ID: $finalVendorId');
      print('    * Final Vendor Name: $finalVendorName');
      
      return {
        'id': item.id,
        'product': item.id,
        'quantity': item.quantity,
        'price': item.price,
        'name': item.name,
        'image': item.image,
        'type': item.type.name,
        'notes': item.notes,
        'vendorId': finalVendorId,
        'vendorName': finalVendorName,
        'unit': 'piece',
        'orderType': 'regular',
      };
    }).toList();

    print('  - Order items created: ${orderItems.length}');
    
    // Ensure all items have valid vendor ID
    final validatedOrderItems = orderItems.map((item) {
      print('  - Validating item: ${item['name']}');
      print('    * Original vendorId: ${item['vendorId']}');
      
      if (item['vendorId'] == null || item['vendorId'].toString().isEmpty) {
        print('    * Fixing null vendorId - using store.id: ${store.id}');
        return {
          ...item,
          'vendorId': store.id,
          'vendorName': store.name,
        };
      }
      print('    * VendorId is valid: ${item['vendorId']}');
      return item;
    }).toList();
    
    print('  - Final validated items count: ${validatedOrderItems.length}');
    print('  - Final Vendor ID: ${validatedOrderItems.isNotEmpty ? validatedOrderItems.first['vendorId'] : 'No items'}');
    print('  - Total amount: ${cartProvider.getStoreTotal(store.id)}');
    
    // Print final order items details
    for (int i = 0; i < validatedOrderItems.length; i++) {
      final item = validatedOrderItems[i];
      print('  - Final Order Item ${i + 1}:');
      print('    * ID: ${item['id']}');
      print('    * Name: ${item['name']}');
      print('    * Price: ${item['price']}');
      print('    * Quantity: ${item['quantity']}');
      print('    * Vendor ID: ${item['vendorId']}');
      print('    * Vendor Name: ${item['vendorName']}');
      print('    * Type: ${item['type']}');
      print('    * Order Type: ${item['orderType']}');
    }

    print('  - About to navigate to CheckoutScreen:');
    print('    * Total amount: ${cartProvider.getStoreTotal(store.id)}');
    print('    * Cart items count: ${validatedOrderItems.length}');
    print('    * First item vendorId: ${validatedOrderItems.isNotEmpty ? validatedOrderItems.first['vendorId'] : 'No items'}');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          totalAmount: cartProvider.getStoreTotal(store.id),
          cartItems: validatedOrderItems,
          vendorId: store.id, // Pass the store ID as vendorId
          onOrderSuccess: () {
            // This will be called after successful checkout
            // The cart is already cleared in the checkout screen
            print('🛒 Multi Cart - Order success callback called');
          },
        ),
      ),
    );
  }

  void _checkoutTmart(
    BuildContext context,
    List<CartItem> items,
    UnifiedCartProvider cartProvider,
  ) {
    print('🛒 Multi Cart - Checkout T-Mart Debug:');
    print('  - T-Mart Items count: ${items.length}');
    print('  - Total cart items: ${cartProvider.items.length}');
    print('  - T-Mart Total Amount: ${cartProvider.tmartTotalAmount}');
    
    final orderItems = items.map((item) {
      print('  - Processing T-Mart item: ${item.name}');
      print('    * Item ID: ${item.id}');
      print('    * Item Price: ${item.price}');
      print('    * Item Quantity: ${item.quantity}');
      print('    * Item Type: ${item.type.name}');
      print('    * Item Vendor ID: ${item.vendorId}');
      print('    * Item Vendor Name: ${item.vendorName}');
      
      // Ensure vendorId is always set for T-Mart items
      final finalVendorId = item.vendorId ?? 'tmart';
      final finalVendorName = item.vendorName ?? 'T-Mart';
      
      print('    * Final T-Mart Vendor ID: $finalVendorId');
      print('    * Final T-Mart Vendor Name: $finalVendorName');
      
      return {
        'id': item.id,
        'product': item.id,
        'quantity': item.quantity,
        'price': item.price,
        'name': item.name,
        'image': item.image,
        'type': item.type.name,
        'notes': item.notes,
        'vendorId': finalVendorId,
        'vendorName': finalVendorName,
        'unit': 'piece',
        'orderType': 'tmart',
      };
    }).toList();

    print('  - T-Mart order items created: ${orderItems.length}');
    
    // Ensure all items have valid vendor ID
    final validatedOrderItems = orderItems.map((item) {
      print('  - Validating T-Mart item: ${item['name']}');
      print('    * Original vendorId: ${item['vendorId']}');
      
      if (item['vendorId'] == null || item['vendorId'].toString().isEmpty) {
        print('    * Fixing null vendorId - using "tmart"');
        return {
          ...item,
          'vendorId': 'tmart',
          'vendorName': 'T-Mart',
        };
      }
      print('    * VendorId is valid: ${item['vendorId']}');
      return item;
    }).toList();
    
    print('  - Final validated T-Mart items count: ${validatedOrderItems.length}');
    print('  - Final T-Mart Vendor ID: ${validatedOrderItems.isNotEmpty ? validatedOrderItems.first['vendorId'] : 'No items'}');
    
    // Print final T-Mart order items details
    for (int i = 0; i < validatedOrderItems.length; i++) {
      final item = validatedOrderItems[i];
      print('  - Final T-Mart Order Item ${i + 1}:');
      print('    * ID: ${item['id']}');
      print('    * Name: ${item['name']}');
      print('    * Price: ${item['price']}');
      print('    * Quantity: ${item['quantity']}');
      print('    * Vendor ID: ${item['vendorId']}');
      print('    * Vendor Name: ${item['vendorName']}');
      print('    * Type: ${item['type']}');
      print('    * Order Type: ${item['orderType']}');
    }

    print('  - About to navigate to CheckoutScreen (T-Mart):');
    print('    * Total amount: ${cartProvider.tmartTotalAmount}');
    print('    * Cart items count: ${validatedOrderItems.length}');
    print('    * First item vendorId: ${validatedOrderItems.isNotEmpty ? validatedOrderItems.first['vendorId'] : 'No items'}');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          totalAmount: cartProvider.tmartTotalAmount,
          cartItems: validatedOrderItems,
          isTmartOrder: true,
          vendorId: 'tmart', // Pass 'tmart' as vendorId for T-Mart orders
          onOrderSuccess: () {
            // This will be called after successful checkout
            // The cart is already cleared in the checkout screen
            print('🛒 Multi Cart - T-Mart order success callback called');
          },
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, UnifiedCartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to clear all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              cartProvider.clearCart();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}