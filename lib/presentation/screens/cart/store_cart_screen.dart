import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/enhanced_cart_provider.dart';
import '../../../models/cart_item.dart';
import '../../../widgets/cached_image.dart';
import '../checkout_screen.dart';

class StoreCartScreen extends StatelessWidget {
  final String sourceName;
  final List<CartItem> items;

  const StoreCartScreen({
    Key? key,
    required this.sourceName,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalPrice = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    final sourceColor = _getSourceColor(sourceName);
    final deliveryTime = _getDeliveryTime(sourceName);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Store Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Store Logo
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: sourceColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getSourceIcon(sourceName),
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
                        sourceName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${items.length} items • $deliveryTime',
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
                      'Rs ${totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: sourceColor,
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
          
          // Products List
          Expanded(
            child: Consumer<EnhancedCartProvider>(
              builder: (context, cartProvider, child) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _ProductTile(
                      item: item,
                      cartProvider: cartProvider,
                      sourceColor: sourceColor,
                    );
                  },
                );
              },
            ),
          ),
          
          // Checkout Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _proceedToCheckout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sourceColor,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_cart_checkout,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Proceed to Checkout • Rs ${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        '$sourceName Cart',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.black87,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black87),
      actions: [
        Consumer<EnhancedCartProvider>(
          builder: (context, cartProvider, child) {
            return TextButton(
              onPressed: () => _showClearStoreDialog(context, cartProvider),
              child: Text(
                'Clear All',
                style: TextStyle(
                  color: _getSourceColor(sourceName),
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showClearStoreDialog(BuildContext context, EnhancedCartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Clear Store Cart',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('Are you sure you want to remove all items from $sourceName?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () {
                // Clear items from this specific source
                for (final item in items) {
                  cartProvider.removeItem(
                    item.product,
                    item.source,
                    sourceId: item.sourceId,
                  );
                }
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to main cart
              },
              child: Text(
                'Clear',
                style: TextStyle(
                  color: _getSourceColor(sourceName),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _proceedToCheckout(BuildContext context) {
    // Convert cart items to order format
    final orderItems = items.map((item) {
      return {
        'id': item.product.id,
        'product': item.product.id,
        'quantity': item.quantity,
        'price': item.product.price,
        'name': item.product.name,
        'image': item.product.imageUrl,
        'type': item.source.name,
        'notes': item.notes,
        'vendorId': item.sourceId ?? 'default',
        'vendorName': item.sourceName ?? sourceName,
        'unit': 'piece',
        'orderType': sourceName == 'T-Mart' ? 'tmart' : 'regular',
      };
    }).toList();

    final totalAmount = items.fold(0.0, (sum, item) => sum + item.totalPrice);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          totalAmount: totalAmount,
          cartItems: orderItems,
          vendorId: items.isNotEmpty ? (items.first.sourceId ?? 'default') : 'default',
          isTmartOrder: sourceName == 'T-Mart',
          onOrderSuccess: () {
            // Navigate back to home or wherever needed after successful order
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
    );
  }

  Color _getSourceColor(String sourceName) {
    if (sourceName == 'T-Mart') return Colors.orange;
    if (sourceName.contains('Restaurant')) return const Color(0xFF6366F1);
    return Colors.orange[700]!;
  }

  IconData _getSourceIcon(String sourceName) {
    if (sourceName == 'T-Mart') return Icons.local_grocery_store;
    if (sourceName.contains('Restaurant')) return Icons.restaurant;
    return Icons.store;
  }

  String _getDeliveryTime(String sourceName) {
    if (sourceName == 'T-Mart') return '10-20 min delivery';
    if (sourceName.contains('Restaurant')) return '25-35 min';
    
    // Try to get delivery time from store
    if (items.isNotEmpty && items.first.store != null) {
      return items.first.store!.deliveryTime;
    }
    
    return '30-45 min';
  }
}

class _ProductTile extends StatelessWidget {
  final CartItem item;
  final EnhancedCartProvider cartProvider;
  final Color sourceColor;

  const _ProductTile({
    required this.item,
    required this.cartProvider,
    required this.sourceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedImage(
                  imageUrl: item.product.imageUrl,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rs ${item.product.price.toStringAsFixed(2)} each',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rs ${item.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: sourceColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: sourceColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Note: ${item.notes}',
                        style: TextStyle(
                          fontSize: 12,
                          color: sourceColor,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Quantity Controls
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _QuantityButton(
                    icon: Icons.remove,
                    color: sourceColor,
                    onPressed: () {
                      cartProvider.removeItem(
                        item.product,
                        item.source,
                        sourceId: item.sourceId,
                      );
                    },
                  ),
                  Container(
                    width: 50,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  _QuantityButton(
                    icon: Icons.add,
                    color: sourceColor,
                    onPressed: () {
                      cartProvider.addItem(
                        item.product,
                        item.source,
                        sourceId: item.sourceId,
                        sourceName: item.sourceName,
                        notes: item.notes,
                        store: item.store,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _QuantityButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: color),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}
