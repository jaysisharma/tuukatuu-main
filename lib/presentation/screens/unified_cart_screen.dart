import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuukatuu/providers/cart_provider.dart';
import 'package:tuukatuu/providers/mart_cart_provider.dart';
import 'package:tuukatuu/widgets/cached_image.dart';
import 'package:tuukatuu/presentation/screens/checkout_screen.dart';

class UnifiedCartScreen extends StatefulWidget {
  const UnifiedCartScreen({super.key});

  @override
  State<UnifiedCartScreen> createState() => _UnifiedCartScreenState();
}

class _UnifiedCartScreenState extends State<UnifiedCartScreen> {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final martCartProvider = Provider.of<MartCartProvider>(context);

    // Group cart items by store/vendor
    final storeCarts = _groupCartItemsByStore(cartProvider, martCartProvider);

    if (storeCarts.isEmpty) {
      return _buildEmptyCart();
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Your Cart',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _showClearCartDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: storeCarts.length,
              itemBuilder: (context, index) {
                final storeCart = storeCarts[index];
                return _buildStoreCartCard(storeCart);
              },
            ),
          ),
          // Info message about individual checkout
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tap on any store to view items and checkout',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Your Cart',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
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
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some delicious items to get started!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Start Shopping',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreCartCard(Map<String, dynamic> storeCart) {
    final storeName = storeCart['storeName'] ?? 'Unknown Store';
    final storeImage = storeCart['storeImage'] ?? '';
    final storeType = storeCart['storeType'] ?? 'store';
    final items = storeCart['items'] as List<dynamic>;
    final totalItems = items.fold(0, (sum, item) => sum + (item['quantity'] ?? 0) as int);
    final subtotal = items.fold(0.0, (sum, item) => 
      sum + ((item['price'] ?? 0) * (item['quantity'] ?? 0)));

    return GestureDetector(
      onTap: () => _showStoreDetails(storeCart),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Store banner with image
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: DecorationImage(
                  image: NetworkImage(storeImage.isNotEmpty ? storeImage : 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400&h=400&fit=crop'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        storeName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            storeType == 'restaurant' ? Icons.restaurant : Icons.store,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            storeType == 'restaurant' ? 'Restaurant' : 'Store',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$totalItems items',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Store info and action
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹${subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to view items and checkout',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemTile(Map<String, dynamic> item, Map<String, dynamic> storeCart) {
    final cartProvider = Provider.of<CartProvider>(context);
    final martCartProvider = Provider.of<MartCartProvider>(context);
    final storeType = storeCart['storeType'] ?? 'store';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedImage(
              imageUrl: item['image'] ?? item['imageUrl'] ?? '',
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
                  item['name'] ?? 'Unknown Item',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${(item['price'] ?? 0).toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Quantity controls
          Container(
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    if (storeType == 'tmart') {
                      martCartProvider.updateQuantity(item['id'], (item['quantity'] ?? 1) - 1);
                    } else {
                      cartProvider.updateQuantity(item['id'], (item['quantity'] ?? 1) - 1);
                    }
                  },
                  icon: const Icon(Icons.remove, size: 16),
                  color: Colors.orange[700],
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                SizedBox(
                  width: 32,
                  child: Center(
                    child: Text(
                      '${item['quantity'] ?? 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (storeType == 'tmart') {
                      martCartProvider.updateQuantity(item['id'], (item['quantity'] ?? 1) + 1);
                    } else {
                      cartProvider.updateQuantity(item['id'], (item['quantity'] ?? 1) + 1);
                    }
                  },
                  icon: const Icon(Icons.add, size: 16),
                  color: Colors.orange[700],
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  List<Map<String, dynamic>> _groupCartItemsByStore(CartProvider cartProvider, MartCartProvider martCartProvider) {
    final storeCarts = <Map<String, dynamic>>[];
    
    print('🛒 Grouping cart items - Regular cart: ${cartProvider.items.length}, T-Mart: ${martCartProvider.items.length}');

    // Group regular cart items by store
    final cartItemsByStore = <String, List<Map<String, dynamic>>>{};
    
        try {
      for (final item in cartProvider.items) {
        final vendorId = item['vendorId'];
        String storeId;
        
        if (vendorId is String) {
          storeId = vendorId;
        } else if (vendorId is Map && vendorId['_id'] != null) {
          storeId = vendorId['_id'].toString();
        } else {
          storeId = 'unknown';
        }
        
        print('🛒 Item: ${item['name']}, vendorId type: ${vendorId.runtimeType}, storeId: $storeId');
        
        if (!cartItemsByStore.containsKey(storeId)) {
          cartItemsByStore[storeId] = [];
        }
        cartItemsByStore[storeId]!.add(item);
      }
    } catch (e) {
      print('❌ Error processing cart items: $e');
    }

    // Add regular stores
    for (final entry in cartItemsByStore.entries) {
      if (entry.value.isNotEmpty) {
        final firstItem = entry.value.first;
        final vendorId = firstItem['vendorId'];
        
        String storeName = 'Unknown Store';
        String storeImage = '';
        
        // Try to extract store info from vendorId if it's a Map
        if (vendorId is Map) {
          storeName = vendorId['storeName'] ?? vendorId['name'] ?? 'Unknown Store';
          storeImage = vendorId['storeImage'] ?? vendorId['image'] ?? '';
        }
        
        storeCarts.add({
          'storeId': entry.key,
          'storeName': storeName,
          'storeImage': storeImage,
          'storeType': 'store',
          'items': entry.value,
        });
      }
    }

    // Add T-Mart items if any
    if (martCartProvider.items.isNotEmpty) {
      // Group T-Mart items by vendor if they have different vendors
      final tmartItemsByVendor = <String, List<Map<String, dynamic>>>{};
      
                    for (final item in martCartProvider.items) {
        final vendorId = item['vendorId'];
        String storeId;
        
        if (vendorId is String) {
          storeId = vendorId;
        } else if (vendorId is Map && vendorId['_id'] != null) {
          storeId = vendorId['_id'].toString();
        } else {
          storeId = 'tmart';
        }
        
        if (!tmartItemsByVendor.containsKey(storeId)) {
          tmartItemsByVendor[storeId] = [];
        }
        tmartItemsByVendor[storeId]!.add(item);
      }
      
      // Add each T-Mart vendor as a separate store
      for (final entry in tmartItemsByVendor.entries) {
        final firstItem = entry.value.first;
        final vendorId = firstItem['vendorId'];
        
        String storeName = 'T-Mart';
        String storeImage = 'https://images.unsplash.com/photo-1604719312566-8912e9227c6a';
        
        // Try to extract store info from vendorId if it's a Map
        if (vendorId is Map) {
          storeName = vendorId['storeName'] ?? vendorId['name'] ?? 'T-Mart';
          storeImage = vendorId['storeImage'] ?? vendorId['image'] ?? storeImage;
        }
        
        storeCarts.add({
          'storeId': entry.key,
          'storeName': storeName,
          'storeImage': storeImage,
          'storeType': 'tmart',
          'items': entry.value,
        });
      }
    }

    return storeCarts;
  }


  void _showStoreDetails(Map<String, dynamic> storeCart) {
    final storeName = storeCart['storeName'] ?? 'Unknown Store';
    final storeImage = storeCart['storeImage'] ?? '';
    final storeType = storeCart['storeType'] ?? 'store';
    final items = storeCart['items'] as List<dynamic>;
    final totalItems = items.fold(0, (sum, item) => sum + (item['quantity'] ?? 0) as int);
    final subtotal = items.fold(0.0, (sum, item) => 
      sum + ((item['price'] ?? 0) * (item['quantity'] ?? 0)));
    
    const deliveryFee = 20.0;
    final finalTotal = subtotal + deliveryFee;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Store header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedImage(
                      imageUrl: storeImage,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          storeName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              storeType == 'restaurant' ? Icons.restaurant : Icons.store,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              storeType == 'restaurant' ? 'Restaurant' : 'Store',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$totalItems items',
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
                ],
              ),
            ),
            const Divider(height: 1),
            // Items list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildCartItemTile(item, storeCart);
                },
              ),
            ),
            // Checkout section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Price breakdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal ($totalItems items)',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        '₹${subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delivery fee',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        '₹${deliveryFee.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '₹${finalTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close modal
                        print('🛒 User clicked checkout for store: ${storeCart['storeName']}');
                        
                        // Add a small delay to ensure modal is closed before navigation
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _checkoutFromStore(storeCart);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Checkout from this store',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkoutFromStore(Map<String, dynamic> storeCart) {
    final items = storeCart['items'] as List<dynamic>;
    final storeName = storeCart['storeName'] ?? 'Unknown Store';
    final storeType = storeCart['storeType'] ?? 'store';
    final storeId = storeCart['storeId'] ?? '';
    
    // Calculate totals for this store
    final totalItems = items.fold(0, (sum, item) => sum + (item['quantity'] ?? 0) as int);
    final totalAmount = items.fold(0.0, (sum, item) => 
      sum + ((item['price'] ?? 0) * (item['quantity'] ?? 0)));
    
    const deliveryFee = 20.0; // ₹20 delivery fee per store
    final finalTotal = totalAmount + deliveryFee;

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Checkout from $storeName'),
        content: Text(
          'You\'re about to checkout $totalItems items from $storeName for ₹${finalTotal.toStringAsFixed(2)}. '
          'This will remove these items from your cart.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              
              // Remove items from cart based on store type
              if (storeType == 'tmart') {
                final martCartProvider = Provider.of<MartCartProvider>(context, listen: false);
                for (final item in items) {
                  final itemId = item['id'] ?? item['_id'];
                  if (itemId != null) {
                    martCartProvider.removeItem(itemId.toString());
                  }
                }
              } else {
                final cartProvider = Provider.of<CartProvider>(context, listen: false);
                for (final item in items) {
                  final itemId = item['id'] ?? item['_id'];
                  if (itemId != null) {
                    cartProvider.removeItem(itemId.toString());
                  }
                }
              }

              // Navigate to checkout with only this store's items
              print('🛒 Navigating to CheckoutScreen with ${items.length} items, total: ₹${finalTotal.toStringAsFixed(2)}');
              
              // Convert items to the format expected by CheckoutScreen
              final checkoutItems = items.map((item) => {
                'id': item['id'] ?? item['_id'],
                'name': item['name'] ?? item['productName'],
                'price': (item['price'] ?? 0).toDouble(),
                'quantity': item['quantity'] ?? 1,
                'image': item['image'] ?? item['imageUrl'],
                'unit': item['unit'] ?? 'piece',
                'orderType': storeType == 'tmart' ? 'tmart' : 'regular',
                'vendorId': storeId,
                'vendorName': storeName,
              }).toList();
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckoutScreen(
                    cartItems: checkoutItems,
                    totalAmount: finalTotal,
                    isTmartOrder: storeType == 'tmart',
                  ),
                ),
              ).then((_) {
                print('🛒 Returned from CheckoutScreen');
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text(
              'Proceed to Checkout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
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
          TextButton(
            onPressed: () {
              final cartProvider = Provider.of<CartProvider>(context, listen: false);
              final martCartProvider = Provider.of<MartCartProvider>(context, listen: false);
              
              cartProvider.clearCart();
              martCartProvider.clearCart();
              
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
} 