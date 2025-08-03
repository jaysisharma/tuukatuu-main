import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/unified_cart_provider.dart';
import '../../widgets/cached_image.dart';
import 'checkout_screen.dart';

class UnifiedCartScreen extends StatefulWidget {
  const UnifiedCartScreen({super.key});

  @override
  State<UnifiedCartScreen> createState() => _UnifiedCartScreenState();
}

class _UnifiedCartScreenState extends State<UnifiedCartScreen> {

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<UnifiedCartProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final cartSummary = cartProvider.getCartSummary();
    final totalItems = cartSummary['totalItems'] as int;
    final storeItems = cartProvider.storeItems;
    final tmartItems = cartProvider.tmartItems;
    final hasMixedItems = cartSummary['hasMixedItems'] as bool;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black12 : Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    'My Cart',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  if (totalItems > 0)
                    IconButton(
                      onPressed: () {
                        _showClearCartDialog(context, cartProvider);
                      },
                      icon: Icon(
                        Icons.delete_outline,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            
            // Cart Content
            Expanded(
              child: totalItems == 0
                ? _buildEmptyCart(theme, isDark)
                : _buildCartContent(cartProvider, storeItems, tmartItems, hasMixedItems, theme, isDark),
            ),
            
            // Checkout Section
            if (totalItems > 0)
              _buildCheckoutSection(cartProvider, theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: isDark ? Colors.grey[700] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to start shopping',
            style: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to home
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(
    UnifiedCartProvider cartProvider,
    List<CartItem> storeItems,
    List<CartItem> tmartItems,
    bool hasMixedItems,
    ThemeData theme,
    bool isDark,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Store Items Section
        if (storeItems.isNotEmpty) ...[
          _buildSectionHeader('Store Items', Icons.store, Colors.blue, theme, isDark),
          const SizedBox(height: 8),
          ...storeItems.map((item) => _buildCartItem(item, cartProvider, theme, isDark)),
          const SizedBox(height: 16),
        ],
        
        // T-Mart Items Section
        if (tmartItems.isNotEmpty) ...[
          _buildSectionHeader('T-Mart Items', Icons.shopping_basket, Colors.green, theme, isDark),
          const SizedBox(height: 8),
          ...tmartItems.map((item) => _buildCartItem(item, cartProvider, theme, isDark)),
          const SizedBox(height: 16),
        ],
        
        // Mixed Cart Warning
        if (hasMixedItems)
          _buildMixedCartWarning(theme, isDark),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, UnifiedCartProvider cartProvider, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black12 : Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
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
          
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs ${item.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (item.notes?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Note: ${item.notes}',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          
          // Quantity Controls
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildQuantityButton(
                    icon: Icons.remove,
                    onTap: () {
                      cartProvider.updateQuantity(item.id, item.type, item.quantity - 1);
                    },
                  ),
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(
                      item.quantity.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  _buildQuantityButton(
                    icon: Icons.add,
                    onTap: () {
                      cartProvider.updateQuantity(item.id, item.type, item.quantity + 1);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Rs ${(item.price * item.quantity).toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildMixedCartWarning(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Mixed cart detected. Store and T-Mart items will be processed separately.',
              style: TextStyle(
                color: Colors.orange[700],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(UnifiedCartProvider cartProvider, ThemeData theme, bool isDark) {
    final cartSummary = cartProvider.getCartSummary();
    final totalAmount = cartSummary['totalAmount'] as double;
    final storeTotal = cartSummary['storeTotal'] as double;
    final tmartTotal = cartSummary['tmartTotal'] as double;
    final hasMixedItems = cartSummary['hasMixedItems'] as bool;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Price Breakdown
            if (hasMixedItems) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Store Total:', style: TextStyle(color: Colors.grey[600])),
                  Text('Rs ${storeTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('T-Mart Total:', style: TextStyle(color: Colors.grey[600])),
                  Text('Rs ${tmartTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(),
            ],
            
            // Total Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rs ${totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      _navigateToCheckout(cartProvider);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                    ),
                    child: const Text(
                      'Checkout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCheckout(UnifiedCartProvider cartProvider) {
    final cartSummary = cartProvider.getCartSummary();
    final hasMixedItems = cartSummary['hasMixedItems'] as bool;
    
    if (hasMixedItems) {
      // Show warning about mixed cart
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
                _proceedToCheckout(cartProvider);
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    } else {
      _proceedToCheckout(cartProvider);
    }
  }

  void _proceedToCheckout(UnifiedCartProvider cartProvider) {
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cart cleared'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
} 