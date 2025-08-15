import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuukatuu/providers/global_cart_provider.dart';
import 'package:tuukatuu/services/api_service.dart';
import 'package:tuukatuu/presentation/widgets/explore_products_grid.dart';
import 'package:tuukatuu/presentation/widgets/section_header.dart';
import 'package:tuukatuu/presentation/widgets/banner_carousel.dart';

class DailyEssentialsPage extends StatefulWidget {
  const DailyEssentialsPage({super.key});

  @override
  State<DailyEssentialsPage> createState() => _DailyEssentialsPageState();
}

class _DailyEssentialsPageState extends State<DailyEssentialsPage> {
  List<Map<String, dynamic>> _dailyEssentials = [];
  List<Map<String, dynamic>> _banners = [];
  bool _isLoading = true;
  bool _isLoadingBanners = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchBanners();
    _fetchDailyEssentials();
  }

  // Fetch banners from backend where type is "tmart"
  Future<void> _fetchBanners() async {
    try {
      setState(() {
        _isLoadingBanners = true;
      });

      final response = await ApiService.get('/mart/banners', params: {'type': 'tmart'});
      if (response['success'] && response['data'] != null) {
        setState(() {
          _banners = List<Map<String, dynamic>>.from(response['data']);
          _isLoadingBanners = false;
        });
      } else {
        setState(() {
          _isLoadingBanners = false;
        });
      }
    } catch (error) {
      print('Error fetching banners: $error');
      setState(() {
        _isLoadingBanners = false;
      });
    }
  }

  Future<void> _fetchDailyEssentials() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Use the proper daily essentials API endpoint to get ALL daily essential products
      final response = await ApiService.get('/daily-essentials');
      
      if (response['success'] && response['data'] != null) {
        final dailyEssentialProducts = List<Map<String, dynamic>>.from(response['data']);
        print('✅ Daily essentials loaded: ${dailyEssentialProducts.length} products');
        
        // Transform backend data to match frontend format for ExploreProductsGrid
        final transformedProducts = dailyEssentialProducts.map((product) {
          return {
            'name': product['name'] ?? 'Product',
            'price': 'Rs. ${product['price']?.toString() ?? '0'}',
            'rating': product['rating']?.toDouble() ?? 0.0,
            'reviews': product['reviews'] ?? 0,
            'category': product['category'] ?? 'General',
            'image': product['imageUrl'] ?? 'assets/images/products/snickers.jpg',
            'isNew': product['isNewArrival'] ?? false,
            'discount': product['discount']?.toString() ?? null,
            'isFeatured': product['isFeaturedDailyEssential'] == true || product['isFeatured'] == true,
            'originalPrice': product['originalPrice'] != null ? 'Rs. ${product['originalPrice']?.toString() ?? '0'}' : null,
          };
        }).toList();

        setState(() {
          _dailyEssentials = transformedProducts;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load daily essentials. Please try again.';
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching daily essentials: $error');
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load daily essentials. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _addToCart(String productName, bool isAdd) {
    final cartProvider = Provider.of<GlobalCartProvider>(context, listen: false);
    
    if (isAdd) {
      cartProvider.addToCart(productName);
    } else {
      cartProvider.removeFromCart(productName);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Daily Essentials',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
       
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDailyEssentials,
        color: const Color(0xFFFF6B35),
        child: Stack(
          children: [
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF6B35),
                    ),
                  )
                : _hasError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.red[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchDailyEssentials,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6B35),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Retry',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _dailyEssentials.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No Daily Essentials Found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Check back later for daily essential products',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                
                                const SizedBox(height: 20),
                                // Products using ExploreProductsGrid widget
                                Consumer<GlobalCartProvider>(
                                  builder: (context, cartProvider, child) {
                                    return ExploreProductsGrid(
                                      products: _dailyEssentials,
                                      onProductTap: (product) {
                                        // Handle product tap if needed
                                        Navigator.pushNamed(context, '/tmart-product-detail', arguments: {'product': product});
                                      },
                                      onAddToCart: (productName) => _addToCart(productName, true),
                                      onRemoveFromCart: (productName) => _addToCart(productName, false),
                                      quantities: cartProvider.cartItems,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
            // Floating Cart Button
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: Consumer<GlobalCartProvider>(
                  builder: (context, cartProvider, child) {
                    if (!cartProvider.hasItems) return const SizedBox.shrink();
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35), // Swiggy Orange
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B35).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            Navigator.pop(context); // Close daily essentials page
                            Navigator.pushNamed(context, '/cart'); // Navigate to cart
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.shopping_cart_outlined,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  'Cart',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${cartProvider.totalItems}',
                                    style: const TextStyle(
                                      color: Color(0xFFFF6B35),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
