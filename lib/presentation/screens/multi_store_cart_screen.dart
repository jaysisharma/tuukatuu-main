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
                return TextButton(
                  onPressed: () {
                    _showClearCartDialog(context, cartProvider);
                  },
                  child: const Text('Clear All'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<UnifiedCartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.items.isEmpty) {
            return _buildEmptyCart(context);
          }

          final stores = cartProvider.getUniqueStores();
          final storeItemsByVendor = cartProvider.getStoreItemsByVendor();
          final tmartItems = cartProvider.getItemsByType(CartItemType.tmart);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Store items
                    if (stores.isNotEmpty) ...[
                      const Text(
                        'Store Orders',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...stores.map((store) => _buildStoreSection(
                        context,
                        store,
                        storeItemsByVendor[store.id] ?? [],
                        cartProvider,
                      )),
                      const SizedBox(height: 24),
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
              // Bottom total and checkout
              _buildBottomSection(context, cartProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some products to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
            child: const Text('Start Shopping'),
          ),
        ],
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
    final isDark = theme.brightness == Brightness.dark;
    final totalAmount = cartProvider.getStoreTotal(store.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Store header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedImage(
                    imageUrl: store.banner.isNotEmpty ? store.banner : store.image,
                    width: 60,
                    height: 45,
                    fit: BoxFit.cover,
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${store.rating} (${store.reviews})',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            store.deliveryTime,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  'Rs ${totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          // Items list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildCartItem(context, item, cartProvider);
            },
          ),
          // Store checkout button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _checkoutStore(context, store, items, cartProvider),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Checkout ${store.name} • Rs ${totalAmount.toStringAsFixed(2)}'),
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
    final isDark = theme.brightness == Brightness.dark;
    final totalAmount = cartProvider.tmartTotalAmount;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark 
                ? Colors.black.withOpacity(0.1) 
                : Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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
                  width: 60,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.local_grocery_store,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'T-Mart Express',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '10-20 min delivery',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Rs ${totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          // Items list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildCartItem(context, item, cartProvider);
            },
          ),
          // T-Mart checkout button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _checkoutTmart(context, items, cartProvider),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Checkout T-Mart • Rs ${totalAmount.toStringAsFixed(2)}'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartItem item,
    UnifiedCartProvider cartProvider,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedImage(
              imageUrl: item.image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs ${item.price}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (item.quantity > 1) {
                        cartProvider.updateQuantity(item.id, item.type, item.quantity - 1);
                      } else {
                        cartProvider.removeItem(item.id, item.type);
                      }
                    },
                    icon: const Icon(Icons.remove, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      cartProvider.updateQuantity(item.id, item.type, item.quantity + 1);
                    },
                    icon: const Icon(Icons.add, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              Text(
                'Rs ${(item.price * item.quantity).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(
    BuildContext context,
    UnifiedCartProvider cartProvider,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final totalAmount = cartProvider.totalAmount;
    final itemCount = cartProvider.itemCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total ($itemCount items)',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Rs ${totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () => _checkoutAll(context, cartProvider),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Checkout All'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkoutStore(
    BuildContext context,
    Store store,
    List<CartItem> items,
    UnifiedCartProvider cartProvider,
  ) {
    final orderItems = items.map((item) => {
      'id': item.id,
      'product': item.id,
      'quantity': item.quantity,
      'price': item.price,
      'name': item.name,
      'image': item.image,
      'type': item.type.name,
      'notes': item.notes,
      'vendorId': item.vendorId,
      'vendorName': item.vendorName,
      'unit': 'piece',
      'orderType': 'regular',
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          totalAmount: cartProvider.getStoreTotal(store.id),
          cartItems: orderItems,
        ),
      ),
    );
  }

  void _checkoutTmart(
    BuildContext context,
    List<CartItem> items,
    UnifiedCartProvider cartProvider,
  ) {
    final orderItems = items.map((item) => {
      'id': item.id,
      'product': item.id,
      'quantity': item.quantity,
      'price': item.price,
      'name': item.name,
      'image': item.image,
      'type': item.type.name,
      'notes': item.notes,
      'vendorId': item.vendorId,
      'vendorName': item.vendorName,
      'unit': 'piece',
      'orderType': 'tmart',
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          totalAmount: cartProvider.tmartTotalAmount,
          cartItems: orderItems,
          isTmartOrder: true,
        ),
      ),
    );
  }

  void _checkoutAll(BuildContext context, UnifiedCartProvider cartProvider) {
    final cartSummary = cartProvider.getCartSummary();
    final hasMixedItems = cartSummary['hasMixedItems'] as bool;
    
    if (hasMixedItems) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Mixed Cart Detected'),
          content: const Text(
            'You have items from both stores and T-Mart. These will be processed as separate orders. Continue?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _proceedToCheckoutAll(context, cartProvider);
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    } else {
      _proceedToCheckoutAll(context, cartProvider);
    }
  }

  void _proceedToCheckoutAll(BuildContext context, UnifiedCartProvider cartProvider) {
    final orderItems = cartProvider.getOrderItems();
    final totalAmount = cartProvider.totalAmount;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          totalAmount: totalAmount,
          cartItems: orderItems,
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