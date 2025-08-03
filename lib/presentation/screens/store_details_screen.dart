import 'package:flutter/material.dart';
import '../../../core/config/routes.dart';
import '../../widgets/cached_image.dart';
import 'package:provider/provider.dart';
import 'package:tuukatuu/providers/cart_provider.dart';
import '../../services/api_service.dart';
import 'package:share_plus/share_plus.dart';

class StoreDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> store;

  const StoreDetailsScreen({
    super.key,
    required this.store,
  });

  @override
  State<StoreDetailsScreen> createState() => _StoreDetailsScreenState();
}

class _StoreDetailsScreenState extends State<StoreDetailsScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;
  bool _showSearch = false;
  int _selectedCategoryIndex = 0;
  AnimationController? _cartAnimationController;
  bool _showCartIndicator = false;
  int _cartItemCount = 0;
  Map<String, int> _itemQuantities = {};
  Map<String, AnimationController> _itemAnimationControllers = {};
  List<dynamic> _products = [];
  bool _loadingProducts = true;
  String? _errorProducts;
  String _searchQuery = '';
  List<dynamic> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    return _products.where((p) => (p['name'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _cartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fetchProducts();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _cartAnimationController?.dispose();
    // Dispose all item animation controllers
    for (final controller in _itemAnimationControllers.values) {
      controller.dispose();
    }
    _itemAnimationControllers.clear();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_isCollapsed) {
      setState(() {
        _isCollapsed = true;
      });
    } else if (_scrollController.offset <= 200 && _isCollapsed) {
      setState(() {
        _isCollapsed = false;
      });
    }
  }

  void _showAddToCartBottomSheet(Map<String, dynamic> item) {
    int quantity = 1;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedImage(
                      imageUrl: item['imageUrl'] ?? item['image'] ?? '',
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rs ${item['price']?.toString() ?? '0'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      if (quantity > 1) {
                        setState(() => quantity--);
                      }
                    },
                    icon: const Icon(Icons.remove),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      quantity.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() => quantity++);
                    },
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final cartProvider = Provider.of<CartProvider>(context, listen: false);
                    cartProvider.insertRawItem(0, {
                      'id': item['_id'] ?? item['id'],
                      'name': item['name'] ?? '',
                      'price': item['price'] ?? 0,
                      'quantity': quantity,
                      'notes': '',
                      'image': item['imageUrl'] ?? '',
                      'vendorId': item['vendorId'] ?? widget.store['_id'],
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item['name']} added to cart'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Add $quantity item${quantity > 1 ? 's' : ''} - Rs ${item['price'] ?? 0}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToCart(Map<String, String> item, int quantity) {
    setState(() {
      _cartItemCount += quantity;
      _showCartIndicator = true;
      _itemQuantities[item['name']!] = (_itemQuantities[item['name']] ?? 0) + quantity;
    });

    // Animate the cart indicator
    _cartAnimationController?.forward(from: 0).then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showCartIndicator = false;
          });
        }
      });
    });
  }

  AnimationController _getAnimationController(String itemName) {
    if (!_itemAnimationControllers.containsKey(itemName)) {
      _itemAnimationControllers[itemName] = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
    }
    return _itemAnimationControllers[itemName]!;
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _loadingProducts = true;
      _errorProducts = null;
    });
    try {
      // Validate store data
      if (widget.store.isEmpty) {
        throw Exception('Store data is empty');
      }
      
      // Use vendorId if present, else fallback to _id
      final vendorId = widget.store['vendorId'] ?? widget.store['_id'];
      if (vendorId == null || vendorId.toString().isEmpty) {
        throw Exception('No valid vendor ID found in store data');
      }
      
      print('🔍 Fetching products for store: ${widget.store['name']} (vendorId: $vendorId)');
      
      final products = await ApiService.getProductsByVendor(vendorId.toString());
      print('🔍 Received ${products.length} products for store');
      
      // Debug: Print first few products to verify structure
      if (products.isNotEmpty) {
        print('🔍 First product structure: ${products.first}');
      }
      
      setState(() {
        _products = products;
        _loadingProducts = false;
      });
    } catch (e) {
      print('❌ Error fetching products: $e');
      setState(() {
        _loadingProducts = false;
        _errorProducts = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    return Scaffold(
      floatingActionButton: cartProvider.items.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.cart);
              },
              backgroundColor: Colors.orange,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart, color: Colors.white),
                  if (cartProvider.items.isNotEmpty)
                    Positioned(
                      right: -8,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          '${cartProvider.items.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            )
          : null,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _fetchProducts,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
              _buildSliverAppBar(),
              _buildStoreInfo(),
              _buildCoupons(),
              // Categories menu commented out for now
              // SliverPersistentHeader(
              //   pinned: true,
              //   delegate: _SliverAppBarDelegate(
              //     minHeight: 50,
              //     maxHeight: 50,
              //     child: _buildCategoriesHeader(),
              //   ),
              // ),
              _buildFullMenu(),
              _buildReviewsAndRatings(),
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
            ),
          ),
          if (_showCartIndicator)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _cartAnimationController!,
                    curve: Curves.elasticOut,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Added to cart ($_cartItemCount)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (_cartItemCount > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shopping_cart,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$_cartItemCount ${_cartItemCount == 1 ? 'item' : 'items'}',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.cart);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'View Cart',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      elevation: 0,
      backgroundColor: _isCollapsed ? Colors.white : Colors.transparent,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: _isCollapsed ? Colors.black : Colors.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: _showSearch
          ? TextField(
              decoration: InputDecoration(
                hintText: 'Search in ${widget.store['name']}',
                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(color: Colors.black),
              autofocus: true,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            )
          : _isCollapsed
              ? Text(
                  widget.store['name']!,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
      actions: [
        IconButton(
          icon: Icon(
            _showSearch ? Icons.close : Icons.search,
            color: _isCollapsed ? Colors.black : Colors.white,
          ),
          onPressed: () {
            setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) _searchQuery = '';
            });
          },
        ),
        IconButton(
          icon: Icon(
            Icons.share,
            color: _isCollapsed ? Colors.black : Colors.white,
          ),
          onPressed: () {
            final storeName = widget.store['name'] ?? '';
            final storeId = widget.store['_id'] ?? widget.store['vendorId'] ?? '';
            final storeUrl = 'https://tuukatuu.com/store/$storeId';
            Share.share('Check out $storeName on TuukaTuu! $storeUrl');
          },
        ),
        // Heart icon removed
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedImage(
              imageUrl: widget.store['storeBanner'] ?? widget.store['storeImage'] ?? '',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.store['name']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.store['storeDescription'] ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
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

  Widget _buildCategoriesHeader() {
    final categories = [
      'All Items',
      'Popular',
      'Exclusive',
      'New Arrivals',
      'Special Offers',
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _selectedCategoryIndex = index;
                });
              },
              style: TextButton.styleFrom(
                backgroundColor: isSelected ? Colors.orange : Colors.grey[100],
                foregroundColor: isSelected ? Colors.white : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: Text(categories[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoreInfo() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.green[700], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        (widget.store['storeRating'] ?? '').toString(),
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.orange[700], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        (widget.store['storeTime'] ?? '').toString(),
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.store['storeDescription'] ?? '',
              style: TextStyle(
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoupons() {
    // For now, show nothing or fetch from backend if implemented
    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final cartProvider = Provider.of<CartProvider>(context);
    final String productId = item['_id'] ?? item['id'] ?? '';
    final int quantity = cartProvider.items.firstWhere(
      (e) => e['id'] == productId,
      orElse: () => {},
    )?['quantity'] ?? 0;
    
    // Debug: Print item structure if there are issues
    if (item['name'] == null || item['price'] == null) {
      print('⚠️ Product item missing required fields: $item');
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: CachedImage(
                  imageUrl: item['image'] ?? item['imageUrl'] ?? '',
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: quantity == 0
                    ? Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            cartProvider.insertRawItem(0, {
                              'id': productId,
                              'name': item['name']?.toString() ?? 'Unnamed Product',
                              'price': item['price'] ?? 0,
                              'quantity': 1,
                              'notes': '',
                              'image': item['image'] ?? item['imageUrl'] ?? '',
                              'vendorId': item['vendorId'] ?? widget.store['_id'],
                            });
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white, // White background for + button
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.add,
                                color: Colors.orange[700],
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  if (quantity > 1) {
                                    cartProvider.updateQuantity(productId, quantity - 1);
                                  } else {
                                    cartProvider.removeItem(productId);
                                  }
                                },
                                child: SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: Center(
                                    child: Icon(
                                      Icons.remove,
                                      color: Colors.orange[700],
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 32,
                              child: Center(
                                child: Text(
                                  quantity.toString(),
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  cartProvider.updateQuantity(productId, quantity + 1);
                                },
                                child: SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: Center(
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.orange[700],
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name']?.toString() ?? 'Unnamed Product',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['description'] ?? '',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    'Rs ${(item['price'] ?? 0).toString()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullMenu() {
    if (_loadingProducts) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading products...'),
              ],
            ),
          ),
        ),
      );
    }
    
    if (_errorProducts != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Failed to load products',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  _errorProducts!,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchProducts,
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    if (_filteredProducts.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No products available',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'This store doesn\'t have any products yet.',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }
    // Group products by category
    final Map<String, List<dynamic>> grouped = {};
    for (final p in _filteredProducts) {
      final cat = p['category'] ?? 'Other';
      grouped.putIfAbsent(cat, () => []).add(p);
    }
    final categories = grouped.keys.toList();
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, categoryIndex) {
          final cat = categories[categoryIndex];
          final items = grouped[cat]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  cat,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (context, itemIndex) => _buildItemCard(items[itemIndex]),
              ),
            ],
          );
        },
        childCount: categories.length,
      ),
    );
  }

  Widget _buildReviewsAndRatings() {
    // Use store fields for now
    final rating = (widget.store['storeRating'] ?? 0).toString();
    final reviews = (widget.store['storeReviews'] ?? 0).toString();
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reviews & Ratings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('($reviews reviews)'),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      rating,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        final r = double.tryParse(rating) ?? 0;
                        return Icon(
                          Icons.star,
                          size: 16,
                          color: index < r.round() ? Colors.orange : Colors.orange[200],
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$reviews Reviews',
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
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
} 