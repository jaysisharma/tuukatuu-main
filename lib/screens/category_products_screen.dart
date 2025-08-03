import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/cached_image.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import '../presentation/screens/product_details_screen.dart';
import '../presentation/screens/store_details_screen.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../services/error_service.dart';
import 'package:geolocator/geolocator.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String category;
  const CategoryProductsScreen({super.key, required this.category});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _vendorsWithProducts = [];
  Position? _userLocation;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      _userLocation = await LocationService.getCurrentLocation();
      await _fetchProductsByCategory();
    } catch (e) {
      print('❌ Error in _initializeData: $e');
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _fetchProductsByCategory() async {
    try {
      print('🔍 Fetching products by category: ${widget.category}');
      
      final data = await ApiService.getProductsByCategoryGrouped(widget.category);
      print('🔍 API Response: $data');
      
      if (data['vendors'] != null) {
        final vendors = data['vendors'] as List;
        print('🔍 Found ${vendors.length} vendors with products in category "${widget.category}"');
        
        vendors.forEach((vendorData) {
          final vendor = vendorData['vendor'];
          final products = vendorData['products'] as List;
          print('   - ${vendor['storeName']}: ${products.length} products');
        });
        
        setState(() {
          _vendorsWithProducts = vendors;
        });
      } else {
        print('⚠️  No vendors found for category "${widget.category}"');
        setState(() {
          _vendorsWithProducts = [];
        });
      }
    } catch (e) {
      print('❌ Error fetching products by category: $e');
      throw e;
    }
  }

  Widget _buildProductCard(BuildContext context, dynamic product, dynamic store, ThemeData theme) {
    final cartProvider = Provider.of<CartProvider>(context);
    final String productId = product['_id'] ?? product['id'] ?? '';
    final int quantity = cartProvider.items.firstWhere(
      (e) => e['id'] == productId,
      orElse: () => {},
    )?['quantity'] ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (_) => ProductDetailsScreen(product: Product.fromJson(product)),
          //   ),
          // );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Add to Cart Button
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: CachedImage(
                      imageUrl: product['imageUrl'] ?? product['image'] ?? '',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Add to Cart Button positioned on image
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
                                  'name': product['name'] ?? '',
                                  'price': product['price'] ?? 0,
                                  'quantity': 1,
                                  'notes': '',
                                  'image': product['imageUrl'] ?? product['image'] ?? '',
                                  'vendorId': product['vendorId'] ?? store['_id'],
                                });
                                
                                // Show feedback
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product['name']} added to cart'),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.add,
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
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
                                    borderRadius: BorderRadius.circular(18),
                                    child: SizedBox(
                                      width: 36,
                                      height: 36,
                                      child: Center(
                                        child: Icon(
                                          Icons.remove,
                                          color: theme.colorScheme.primary,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 32,
                                  child: Center(
                                    child: Text(
                                      quantity.toString(),
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
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
                                    borderRadius: BorderRadius.circular(18),
                                    child: SizedBox(
                                      width: 36,
                                      height: 36,
                                      child: Center(
                                        child: Icon(
                                          Icons.add,
                                          color: theme.colorScheme.primary,
                                          size: 18,
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
            ),
            
            // Product Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product['name'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Product Description (if available)
                    if (product['description'] != null && product['description'].toString().isNotEmpty)
                      Text(
                        product['description'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                    const Spacer(),
                    
                    // Price
                    Text(
                      '₹${product['price']?.toString() ?? '0'}',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartProvider = Provider.of<CartProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.category,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        surfaceTintColor: Colors.transparent,
      ),
      // Floating Action Button for Cart
      floatingActionButton: cartProvider.items.isNotEmpty
    ? FloatingActionButton(
        onPressed: () {
          // Navigate to cart screen
          // Navigator.pushNamed(context, AppRoutes.cart);
        },
        backgroundColor: theme.colorScheme.primary,
        elevation: 8,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.shopping_cart, color: Colors.white),
            if (cartProvider.items.isNotEmpty)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    '${cartProvider.items.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
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

      body: _loading
          ? ErrorService.buildLoadingWidget('Loading stores and products...')
          : _error != null
              ? ErrorService.buildErrorWidget(
                  ErrorService.handleApiError(_error!),
                  _error!,
                  _initializeData,
                )
              : _vendorsWithProducts.isEmpty
                  ? ErrorService.buildEmptyStateWidget(
                      'No Products Found',
                      'No products found in the "${widget.category}" category. Try a different category or check back later.',
                      Icons.category_outlined,
                      _initializeData,
                      'Retry',
                    )
                  : RefreshIndicator(
                      onRefresh: _initializeData,
                      color: theme.colorScheme.primary,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: _vendorsWithProducts.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 32),
                        itemBuilder: (context, index) {
                          final vendorData = _vendorsWithProducts[index];
                          final store = vendorData['vendor'];
                          final storeProducts = vendorData['products'] as List;
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Store Header with Circular Image and Name
                              InkWell(
                                onTap: () {
                                    final storeData = {
                                    '_id': store['_id'],
                                    'name': store['storeName'] ?? store['name'],
                                    'storeName': store['storeName'] ?? store['name'],
                                    'storeDescription': store['storeDescription'] ?? store['description'] ?? '',
                                    'storeImage': store['storeImage'] ?? store['image'] ?? '',
                                    'storeBanner': store['storeBanner'] ?? store['banner'] ?? store['storeImage'] ?? store['image'] ?? '',
                                    'storeRating': store['storeRating'] ?? store['rating'] ?? 0,
                                    'storeReviews': store['storeReviews'] ?? store['reviews'] ?? 0,
                                    'storeTime': store['storeTime'] ?? store['time'] ?? '',
                                    'vendorId': store['_id'],
                                    'isFeatured': store['isFeatured'] ?? false,
                                  };
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => StoreDetailsScreen(store: storeData),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      // Circular Store Image
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: CachedImage(
                                            imageUrl: store['storeImage'] ?? '',
                                            width: 56,
                                            height: 56,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      
                                      const SizedBox(width: 16),
                                      
                                      // Store Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    store['storeName'] ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                                if (store['isFeatured'] == true)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [Colors.orange[400]!, Colors.orange[600]!],
                                                      ),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: const Text(
                                                      'Featured',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(Icons.star, color: Colors.orange[700], size: 14),
                                                const SizedBox(width: 4),
                                                Text(
                                                  (store['storeRating'] ?? '0').toString(),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Text(
                                                  '${storeProducts.length} products',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
                                    ],
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Products Grid
                              if (storeProducts.isNotEmpty)
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.75,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                                  itemCount: storeProducts.length,
                                  itemBuilder: (context, productIndex) {
                                    final product = storeProducts[productIndex];
                                    return _buildProductCard(context, product, store, theme);
                                  },
                                )
                              else
                                Container(
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey[200]!),
                                  ),
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.inventory_2_outlined,
                                          color: Colors.grey,
                                          size: 32,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'No products available',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
    );
  }
}