import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tuukatuu/models/cart_item.dart';
import 'package:tuukatuu/presentation/screens/product_details_screen.dart';
import 'package:tuukatuu/providers/enhanced_cart_provider.dart';

import '../../../core/config/routes.dart';
import '../../models/product.dart';
import '../../models/store.dart';
import '../../services/api_service.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/global_cart_fab.dart';


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
  final Map<String, int> _itemQuantities = {};
  final Map<String, AnimationController> _itemAnimationControllers = {};
  List<dynamic> _products = [];
  bool _loadingProducts = true;
  String? _errorProducts;
  String _searchQuery = '';
  
  // Normalized store data getter
  Map<String, dynamic> get _normalizedStore {
    final store = widget.store;
    
    // Debug logging
    print('🔍 StoreDetailsScreen: Raw store data: ${store.keys.toList()}');
    print('🔍 StoreDetailsScreen: storeDescription: ${store['storeDescription']}');
    print('🔍 StoreDetailsScreen: description: ${store['description']}');
    print('🔍 StoreDetailsScreen: storeImage: ${store['storeImage']}');
    print('🔍 StoreDetailsScreen: storeBanner: ${store['storeBanner']}');
    
    final normalized = {
      'name': store['storeName'] ?? store['name'] ?? 'Store',
      'storeName': store['storeName'] ?? store['name'] ?? 'Store',
      'description': store['storeDescription'] ?? store['description'] ?? '',
      'storeDescription': store['storeDescription'] ?? store['description'] ?? '',
      'image': store['storeImage'] ?? store['image'] ?? '',
      'storeImage': store['storeImage'] ?? store['image'] ?? '',
      'banner': store['storeBanner'] ?? store['banner'] ?? store['storeImage'] ?? store['image'] ?? '',
      'storeBanner': store['storeBanner'] ?? store['banner'] ?? store['storeImage'] ?? store['image'] ?? '',
      'rating': store['storeRating'] ?? store['rating'] ?? 0.0,
      'storeRating': store['storeRating'] ?? store['rating'] ?? 0.0,
      'reviews': store['storeReviews'] ?? store['reviews'] ?? 0,
      'storeReviews': store['storeReviews'] ?? store['reviews'] ?? 0,
      'vendorType': store['vendorType'] ?? 'store',
      'vendorSubType': store['vendorSubType'] ?? '',
      'id': store['_id'] ?? store['id'],
      '_id': store['_id'] ?? store['id'],
      'vendorId': store['_id'] ?? store['vendorId'],
    };
    
    print('🔍 StoreDetailsScreen: Normalized storeDescription: ${normalized['storeDescription']}');
    print('🔍 StoreDetailsScreen: Normalized description: ${normalized['description']}');
    
    return normalized;
  }
  
  List<dynamic> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    return _products.where((p) => (p['name'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  // Helper function to convert item data to Product model
  Product _convertToProduct(Map<String, dynamic> item) {
    // Handle vendorId which might be a Map or String
    String vendorId = '';
    if (item['vendorId'] != null) {
      if (item['vendorId'] is Map) {
        vendorId = (item['vendorId'] as Map)['_id']?.toString() ?? '';
      } else {
        vendorId = item['vendorId'].toString();
      }
    }
    
    return Product(
      id: item['_id']?.toString() ?? item['id']?.toString() ?? '',
      name: item['name']?.toString() ?? '',
      price: (item['price'] ?? 0).toDouble(),
      imageUrl: item['imageUrl']?.toString() ?? item['image']?.toString() ?? '',
      category: item['category']?.toString() ?? '',
      rating: (item['rating'] ?? 0).toDouble(),
      reviews: item['reviews'] ?? 0,
      isAvailable: item['isAvailable'] ?? true,
      deliveryFee: (item['deliveryFee'] ?? 0).toDouble(),
      description: item['description']?.toString() ?? '',
      images: item['images'] != null ? List<String>.from(item['images'].map((e) => e.toString())) : [],
      vendorId: vendorId,
    );
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
      
      // Use normalized store data
      final vendorId = _normalizedStore['vendorId'] ?? _normalizedStore['id'] ?? _normalizedStore['_id'];
      if (vendorId == null || vendorId.toString().isEmpty) {
        print('⚠️ No valid vendor ID found in store data: ${_normalizedStore.keys}');
        // Try to get products using store name as fallback
        final storeName = _normalizedStore['storeName'] ?? _normalizedStore['name'];
        if (storeName != null && storeName.toString().isNotEmpty) {
          print('🔍 Trying to fetch products using store name: $storeName');
          final products = await ApiService.getProductsByVendorName(storeName.toString());
          setState(() {
            _products = products;
            _loadingProducts = false;
          });
          return;
        } else {
          throw Exception('No valid vendor ID or store name found in store data');
        }
      }
      
      print('🔍 Fetching products for vendor ID: $vendorId');
      final products = await ApiService.getProductsByVendor(vendorId.toString());
      
      // If no products found, use mock products
      if (products.isEmpty) {
        print('⚠️ No products found for vendor $vendorId, using mock products');
        // final mockProducts = _generateMockProducts();
        setState(() {
          // _products = mockProducts;
          _loadingProducts = false;
        });
      } else {
        setState(() {
          _products = products;
          _loadingProducts = false;
        });
      }
    } catch (e) {
      setState(() {
        _loadingProducts = false;
        _errorProducts = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<EnhancedCartProvider>(context);
    

    
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: const GlobalCartFAB(
        heroTag: 'store_details_fab',
      ),
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
                hintText: 'Search in ${_normalizedStore['name']}',
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
                  _normalizedStore['name']!,
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
            final storeName = _normalizedStore['name'] ?? '';
            final storeId = _normalizedStore['_id'] ?? _normalizedStore['vendorId'] ?? '';
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
              imageUrl: _normalizedStore['storeBanner'] ?? _normalizedStore['storeImage'] ?? '',
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
                    _normalizedStore['name']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _normalizedStore['storeDescription'] ?? '',
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
                        (_normalizedStore['storeRating'] ?? '').toString(),
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
                        (_normalizedStore['storeTime'] ?? '30-45 min').toString(),
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
              _normalizedStore['storeDescription'] ?? '',
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
    final String productId = item['_id']?.toString() ?? item['id']?.toString() ?? '';
    
    // Ensure we have a valid product ID
    if (productId.isEmpty) {
      // Product ID is empty
    }
    
    // Create store object once to ensure consistency
    final store = Store.fromJson(_normalizedStore);
    
    return Consumer<EnhancedCartProvider>(
      builder: (context, cartProvider, child) {
        final product = _convertToProduct(item);
        final int quantity = cartProvider.getItemQuantity(product, CartItemSource.store, sourceId: store.id);
    
    // Debug: Print item structure if there are issues
    if (item['name'] == null || item['price'] == null) {
      // Product item missing required fields
    }

    return GestureDetector(
      onTap: () {
        try {
          // Convert the item to a Product object and navigate to product details
          final product = _convertToProduct(item);
          
          Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product)));
        } catch (e) {
          // Error navigating to product details
        }
      },
      child: Container(
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
                            try {
                              if (productId.isEmpty) {
                                // Error: Product ID is empty - handle silently
                                return;
                              }
                              
                              // Use the same store object for consistency
                              
                              // Handle price conversion properly
                              double price;
                              if (item['price'] is int) {
                                price = (item['price'] as int).toDouble();
                              } else if (item['price'] is double) {
                                price = item['price'] as double;
                              } else {
                                price = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
                              }
                              
                              // Extract vendor ID properly
                              String? vendorId;
                              
                              // Handle vendorId which might be a Map or String
                              if (item['vendorId'] != null) {
                                if (item['vendorId'] is Map) {
                                  // If vendorId is a Map, extract the _id field
                                  vendorId = (item['vendorId'] as Map)['_id']?.toString();
                                } else {
                                  vendorId = item['vendorId'].toString();
                                }
                              } else if (_normalizedStore['_id'] != null) {
                                vendorId = _normalizedStore['_id'].toString();
                              } else {
                                // Fallback to store ID from normalized store
                                vendorId = _normalizedStore['id']?.toString() ?? _normalizedStore['vendorId']?.toString();
                              }
                              
                              // Print the data being added to cart
                              print('🛒 Adding item to cart from product card:');
                              print('  - Product ID: $productId');
                              print('  - Product Name: ${item['name']?.toString() ?? 'Unnamed Product'}');
                              print('  - Product Price: $price');
                              print('  - Quantity: 1');
                              print('  - Image URL: ${item['image'] ?? item['imageUrl'] ?? ''}');
                              print('  - Vendor ID: $vendorId');
                              print('  - Store Name: ${store.name}');
                              print('  - Store ID: ${store.id}');
                              print('  - Cart items before adding: ${cartProvider.items.length}');
                              
                              final product = _convertToProduct(item);
                              cartProvider.addFromStore(product, store);
                              
                              print('  - Cart items after adding: ${cartProvider.items.length}');
                              print('  - Total cart items: ${cartProvider.items.length}');
                              
                              // Item added to cart silently
                            } catch (e) {
                              // Error adding to cart - handle silently
                            }
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
                                  final product = _convertToProduct(item);
                                  if (quantity > 1) {
                                    cartProvider.updateQuantity(product, CartItemSource.store, quantity - 1, sourceId: store.id);
                                  } else {
                                    cartProvider.removeItem(product, CartItemSource.store, sourceId: store.id);
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
                                  final product = _convertToProduct(item);
                                  cartProvider.updateQuantity(product, CartItemSource.store, quantity + 1, sourceId: store.id);
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
    ));
      },
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
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load products',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorProducts!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchProducts,
                  child: const Text('Retry'),
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
                const Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No products available',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
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
    final rating = (_normalizedStore['storeRating'] ?? 0).toString();
    final reviews = (_normalizedStore['storeReviews'] ?? 0).toString();
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