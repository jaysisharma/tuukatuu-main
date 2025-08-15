import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/enhanced_cart_provider.dart';
import '../../../models/cart_item.dart';
import '../../../widgets/cached_image.dart';
import 'store_cart_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Consumer<EnhancedCartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.items.isEmpty) {
            return _EmptyCart();
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: _CartContent(cartProvider: cartProvider),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
        title: const Text(
          'Shopping Cart',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.black87,
        ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black87),
      actions: [
        Consumer<EnhancedCartProvider>(
          builder: (context, cartProvider, child) {
            if (cartProvider.items.isEmpty) return const SizedBox.shrink();
            
            return TextButton(
              onPressed: () => _showClearCartDialog(context, cartProvider),
              child: Text(
                'Clear All',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showClearCartDialog(BuildContext context, EnhancedCartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Clear Cart',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Are you sure you want to remove all items from your cart?'),
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
                cartProvider.clearCart();
                Navigator.of(context).pop();
              },
              child: Text(
                'Clear',
                style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.orange[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 60,
                color: Colors.orange[400],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start shopping to add items to your cart',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Start Shopping',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartContent extends StatelessWidget {
  final EnhancedCartProvider cartProvider;

  const _CartContent({required this.cartProvider});

  @override
  Widget build(BuildContext context) {
    final groupedItems = cartProvider.getItemsGroupedBySource();
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: groupedItems.length,
      itemBuilder: (context, index) {
        final sourceName = groupedItems.keys.elementAt(index);
        final items = groupedItems[sourceName]!;
        
        return _SourceSection(
          sourceName: sourceName,
          items: items,
          cartProvider: cartProvider,
        );
      },
    );
  }
}

class _SourceSection extends StatelessWidget {
  final String sourceName;
  final List<CartItem> items;
  final EnhancedCartProvider cartProvider;

  const _SourceSection({
    required this.sourceName,
    required this.items,
    required this.cartProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalPrice = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    final sourceColor = _getSourceColor(sourceName);
    final storeImage = _getStoreImage(sourceName, items);
    final deliveryTime = _getDeliveryTime(sourceName);

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
              color: sourceColor.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                // Store image/logo
                if (storeImage != null && items.isNotEmpty && items.first.store != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedImage(
                      imageUrl: storeImage,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  )
                else
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sourceName,
                        style: const TextStyle(
                          fontSize: 18,
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
                        fontSize: 18,
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
              child: ElevatedButton(
                onPressed: () => _navigateToCheckout(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: sourceColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Checkout from $sourceName',
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

  String? _getStoreImage(String sourceName, List<CartItem> items) {
    // Get store banner from the first item's store data
    if (items.isNotEmpty && items.first.store != null) {
      final store = items.first.store!;
      // Prefer banner image, fallback to store image
      return store.banner.isNotEmpty ? store.banner : store.image;
    }
    
    return null; // Return null to show icon instead
  }

  void _navigateToCheckout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoreCartScreen(
          sourceName: sourceName,
          items: items,
        ),
      ),
    );
  }
}

