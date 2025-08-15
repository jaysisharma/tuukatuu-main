import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuukatuu/presentation/widgets/home_widgets.dart';
import 'package:tuukatuu/widgets/appbar_location.dart';
import 'package:tuukatuu/presentation/widgets/banner_carousel.dart';
import 'package:tuukatuu/presentation/widgets/category_row.dart';
import 'package:tuukatuu/presentation/widgets/products_grid.dart';
import 'package:tuukatuu/presentation/widgets/products_list.dart';
import 'package:tuukatuu/presentation/widgets/section_header.dart';
import 'package:tuukatuu/presentation/widgets/product_bottom_sheet.dart';
import 'package:tuukatuu/presentation/widgets/explore_products_grid.dart';
import 'package:tuukatuu/providers/global_cart_provider.dart';
import 'package:tuukatuu/services/api_service.dart';
import 'dart:async';
class Tmart extends StatefulWidget {
  const Tmart({super.key});

  @override
  State<Tmart> createState() => _TmartState();
}

class _TmartState extends State<Tmart> with TickerProviderStateMixin {
  String _selectedCategory = 'Dairy Milk';
  final ScrollController _categoryScrollController = ScrollController();

  // Animation controllers
  late AnimationController _cartAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Cart animation state
  bool _showCartAnimation = false;
  String _lastAddedProduct = '';
  Timer? _animationTimer;

  // API service - using static methods

  // Loading states
  bool _isLoading = true;
  bool _isLoadingBanners = true;
  bool _isLoadingDailyEssentials = true;
  bool _isLoadingTrendingProducts = true;
  bool _isLoadingExploreProducts = true;
  bool _isLoadingMoreExploreProducts = false;

  // Dynamic data from backend
  List<Map<String, dynamic>> _banners = [];
  List<Map<String, dynamic>> _dailyEssentials = [];
  List<Map<String, dynamic>> _trendingProducts = [];
  List<Map<String, dynamic>> _exploreProducts = [];

  // Pagination for explore products
  int _exploreProductsPage = 1;
  int _exploreProductsLimit = 15;
  bool _hasMoreExploreProducts = true;
  final ScrollController _exploreProductsScrollController = ScrollController();

  // Cart total items count - now using global cart provider
  int get _totalCartItems {
    final cartProvider = Provider.of<GlobalCartProvider>(context, listen: false);
    return cartProvider.totalItems;
  }

  // Trending near you products data - fallback data
  final List<Map<String, dynamic>> _fallbackTrendingProducts = [];

  // Explore more products data (10 products) - fallback data
  final List<Map<String, dynamic>> _fallbackExploreProducts = [];

  // Fallback categories for the category row
  List<Map<String, dynamic>> get _fallbackCategories => [
        {
          'name': 'Chocolate',
          'image': 'assets/images/category/chocolate.png',
        },
        {
          'name': 'Cold Drinks',
          'image': 'assets/images/category/chocolate.png',
        },
        {
          'name': 'Snacks',
          'image': 'assets/images/category/chocolate.png',
        },
      ];

  // Current categories (now static)
  List<Map<String, String>> get _currentCategories => [
        {
          'name': 'Alcohol',
          'image': 'assets/images/category/alcohol.png',
        },
        
        {
          'name': 'Medicine',
          'image': 'assets/images/category/medicine.png',
        },
        {
          'name': 'Snacks',
          'image': 'assets/images/category/chocolate.png',
        },
        {
          'name': 'Chocolate',
          'image': 'assets/images/category/chocolate.png',
        },
      ];

  // Dynamic product grid names based on our categories
  List<String> get _productGridNames => ['Chocolate', 'Cold Drinks', 'Snacks'];

  // Current products getters
  List<Map<String, dynamic>> get _currentDailyEssentials => _dailyEssentials;
  List<Map<String, dynamic>> get _currentTrendingProducts => _trendingProducts;
  List<Map<String, dynamic>> get _currentExploreProducts => _exploreProducts;
  
  List<String> get _currentBannerImages {
    print('Banners list: $_banners'); // Debug log
    print('Banners length: ${_banners.length}'); // Debug log
    
    if (_banners.isNotEmpty) {
      final imageUrls = _banners.map((banner) {
        // Try both 'image' and 'imageUrl' fields for compatibility
        final imageUrl = banner['image']?.toString() ?? banner['imageUrl']?.toString() ?? '';
        print('Banner: $banner, Image URL: $imageUrl'); // Debug log
        return imageUrl;
      }).where((url) => url.isNotEmpty).toList();
      
      print('Final image URLs: $imageUrls'); // Debug log
      return imageUrls;
    }
    print('No banners available'); // Debug log
    return <String>[];
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fetchMartData();
    _setupExploreProductsScrollListener();
  }

  // Fetch all mart data from backend
  Future<void> _fetchMartData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Fetch data in parallel
      await Future.wait([
        _fetchBanners(),
        _fetchDailyEssentials(),
        _fetchTrendingProducts(),
        _fetchExploreProducts(),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching mart data: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fetch banners from backend where banner type = tmart
  Future<void> _fetchBanners() async {
    try {
      setState(() {
        _isLoadingBanners = true;
      });

      // Try T-Mart specific banners endpoint first
      var response = await ApiService.get('/tmart/banners');
      print('T-Mart Banner API Response: $response'); // Debug log
      
      // If no T-Mart banners found, try the general mart banners endpoint
      if (response['success'] && (response['data'] == null || (response['data'] as List).isEmpty)) {
        print('No T-Mart banners found, trying general mart banners...'); // Debug log
        response = await ApiService.get('/mart/banners');
        print('General Mart Banner API Response: $response'); // Debug log
      }
      
      if (response['success'] && response['data'] != null) {
        final banners = List<Map<String, dynamic>>.from(response['data']);
        print('Fetched banners: $banners'); // Debug log
        print('Number of banners: ${banners.length}'); // Debug log
        
        setState(() {
          _banners = banners;
          _isLoadingBanners = false;
        });
      } else {
        print('Banner API failed or no data: ${response['message'] ?? 'Unknown error'}'); // Debug log
        setState(() {
          _isLoadingBanners = false;
        });
      }
    } catch (error) {
      print('Error fetching tmart banners: $error');
      setState(() {
        _isLoadingBanners = false;
      });
    }
  }



  // Fetch daily essentials from backend - Use the proper daily essentials API
  Future<void> _fetchDailyEssentials() async {
    try {
      setState(() {
        _isLoadingDailyEssentials = true;
      });

      // Use the proper daily essentials API endpoint instead of hardcoded categories
      final response = await ApiService.get('/daily-essentials');
      
      if (response['success'] && response['data'] != null) {
        final dailyEssentials = List<Map<String, dynamic>>.from(response['data']);
        print('✅ Daily essentials loaded: ${dailyEssentials.length} products');
        
        // Transform backend data to match frontend format
        final transformedProducts = dailyEssentials.map((product) {
          return {
            'name': product['name'] ?? 'Product',
            'price': 'Rs. ${product['price']?.toString() ?? '0'}',
            'rating': product['rating']?.toDouble() ?? 0.0,
            'reviews': product['reviews'] ?? 0,
            'category': product['category'] ?? 'General',
            'image': product['imageUrl'] ?? 'assets/images/products/snickers.jpg',
            'isFeaturedDailyEssential': product['isFeaturedDailyEssential'] ?? false,
            'isFeatured': product['isFeatured'] ?? false,
            'trending': product['trending'] ?? null,
            'subcategory': product['subcategory'] ?? '',
            'brand': product['brand'] ?? '',
          };
        }).toList();
        
        setState(() {
          _dailyEssentials = transformedProducts;
          _isLoadingDailyEssentials = false;
          print('✅ Updated daily essentials with ${transformedProducts.length} products');
        });
      } else {
        print('❌ Daily essentials failed: ${response['message']}');
        setState(() {
          _isLoadingDailyEssentials = false;
        });
      }
    } catch (error) {
      print('Error fetching daily essentials: $error');
      setState(() {
        _isLoadingDailyEssentials = false;
      });
    }
  }

  // Fetch trending products from backend
  Future<void> _fetchTrendingProducts() async {
    try {
      setState(() {
        _isLoadingTrendingProducts = true;
      });

      // Fetch trending products from our new categories
      final responses = await Future.wait([
        ApiService.get('/mart/products/category', params: {'category': 'Chocolate', 'limit': '6', 'sort': 'rating'}),
        ApiService.get('/mart/products/category', params: {'category': 'Cold Drinks', 'limit': '6', 'sort': 'rating'}),
        ApiService.get('/mart/products/category', params: {'category': 'Snacks', 'limit': '6', 'sort': 'rating'}),
      ]);

      final allProducts = <Map<String, dynamic>>[];
      
      for (final response in responses) {
        if (response['success'] && response['data'] != null) {
          final products = List<Map<String, dynamic>>.from(response['data']);
          
          // Transform backend data to match frontend format
          final transformedProducts = products.map((product) {
            String trendingLabel;
            
            // Use rating-based trending labels
            final rating = product['rating']?.toDouble() ?? 0.0;
            if (rating >= 4.5) {
              trendingLabel = '🔥 Hot';
            } else if (rating >= 4.0) {
              trendingLabel = '⚡ Trending';
            } else {
              trendingLabel = '⭐ Popular';
            }
            
            return {
              'name': product['name'] ?? 'Product',
              'price': 'Rs. ${product['price']?.toString() ?? '0'}',
              'rating': product['rating']?.toDouble() ?? 0.0,
              'reviews': product['reviews'] ?? 0,
              'category': product['category'] ?? 'General',
              'image': product['imageUrl'] ?? 'assets/images/products/snickers.jpg',
              'trending': trendingLabel,
              'discount': '${((product['discount'] ?? 0) * 100).round()}% OFF',
              'subcategory': product['subcategory'] ?? '',
              'brand': product['brand'] ?? '',
            };
          }).toList();
          
          allProducts.addAll(transformedProducts);
        }
      }

      // Sort by rating and take top 6
      allProducts.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
      final topProducts = allProducts.take(6).toList();

      setState(() {
        _trendingProducts = topProducts;
        _isLoadingTrendingProducts = false;
      });
    } catch (error) {
      print('Error fetching trending products: $error');
      setState(() {
        _isLoadingTrendingProducts = false;
      });
    }
  }

  // Fetch explore products from backend with pagination
  Future<void> _fetchExploreProducts({bool loadMore = false}) async {
    try {
      if (loadMore) {
        setState(() {
          _isLoadingMoreExploreProducts = true;
        });
      } else {
        setState(() {
          _isLoadingExploreProducts = true;
          _exploreProductsPage = 1;
          _exploreProducts = [];
        });
      }

      // Fetch products from our new categories
      final responses = await Future.wait([
        ApiService.get('/mart/products/category', params: {
          'category': 'Chocolate',
          'limit': (_exploreProductsLimit ~/ 3).toString(),
          'page': _exploreProductsPage.toString(),
          'sort': 'rating'
        }),
        ApiService.get('/mart/products/category', params: {
          'category': 'Cold Drinks',
          'limit': (_exploreProductsLimit ~/ 3).toString(),
          'page': _exploreProductsPage.toString(),
          'sort': 'rating'
        }),
        ApiService.get('/mart/products/category', params: {
          'category': 'Snacks',
          'limit': (_exploreProductsLimit ~/ 3).toString(),
          'page': _exploreProductsPage.toString(),
          'sort': 'rating'
        }),
      ]);

      final allProducts = <Map<String, dynamic>>[];
      
      for (final response in responses) {
        if (response['success'] && response['data'] != null) {
          final products = List<Map<String, dynamic>>.from(response['data']);
          
          // Transform backend data to match frontend format
          final transformedProducts = products.map((product) {
            final originalPrice = product['originalPrice'] ?? product['price'];
            final discount = originalPrice > product['price'] 
                ? ((originalPrice - product['price']) / originalPrice * 100).round()
                : 0;
            
            return {
              'name': product['name'] ?? 'Product',
              'price': 'Rs. ${product['price']?.toString() ?? '0'}',
              'originalPrice': 'Rs. ${originalPrice?.toString() ?? '0'}',
              'rating': product['rating']?.toDouble() ?? 0.0,
              'reviews': product['reviews'] ?? 0,
              'category': product['category'] ?? 'General',
              'image': product['imageUrl'] ?? 'assets/images/products/snickers.jpg',
              'discount': '${discount}% OFF',
              'isNew': product['isNewArrival'] ?? false,
              'subcategory': product['subcategory'] ?? '',
              'brand': product['brand'] ?? '',
            };
          }).toList();
          
          allProducts.addAll(transformedProducts);
        }
      }

      // Shuffle products for variety
      allProducts.shuffle();

      setState(() {
        if (loadMore) {
          _exploreProducts.addAll(allProducts);
          _exploreProductsPage++;
        } else {
          _exploreProducts = allProducts;
          _exploreProductsPage = 2; // Next page for future loads
        }
        
        // Check if there are more products
        _hasMoreExploreProducts = allProducts.length >= (_exploreProductsLimit ~/ 3);
        
        _isLoadingExploreProducts = false;
        _isLoadingMoreExploreProducts = false;
      });
    } catch (error) {
      print('Error fetching explore products: $error');
      setState(() {
        _isLoadingExploreProducts = false;
        _isLoadingMoreExploreProducts = false;
      });
    }
  }

  // Load more explore products when user scrolls
  Future<void> _loadMoreExploreProducts() async {
    if (!_isLoadingMoreExploreProducts && _hasMoreExploreProducts) {
      await _fetchExploreProducts(loadMore: true);
    }
  }

  // Setup scroll listener for explore products infinite scrolling
  void _setupExploreProductsScrollListener() {
    // We'll use the main scroll view to detect when user reaches explore products section
    // This will be handled in the build method with a NotificationListener
  }

  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductBottomSheet(
        selectedCategory: _selectedCategory,
        onCategoryChanged: (category) {
          // Don't update _selectedCategory here - it should stay as the main category
          // The category parameter here is the subcategory, not the main category
          print('Subcategory changed to: $category, but main category stays: $_selectedCategory');
        },
        initialProducts: [], // Empty list - ProductBottomSheet will fetch from backend
        categoryScrollController: _categoryScrollController,
        onAddToCart: _addToCart,
        initialQuantities: Provider.of<GlobalCartProvider>(context, listen: false).cartItems,
      ),
    );
  }



  void _onExploreProductAddToCart(String productName) {
    _addToCart(productName, true, isExplore: true);
    // Animation is already triggered in _addToCart method
  }

  void _onExploreProductRemoveFromCart(String productName) {
    _addToCart(productName, false, isExplore: true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$productName removed from cart!'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _addToCart(String productKey, bool isAdd, {bool isTrending = false, bool isExplore = false}) {
    final cartProvider = Provider.of<GlobalCartProvider>(context, listen: false);
    
    if (isAdd) {
      cartProvider.addToCart(productKey);
      _triggerCartAnimation(productKey);
    } else {
      cartProvider.removeFromCart(productKey);
    }
  }

  void _initializeAnimations() {
    _cartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cartAnimationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cartAnimationController,
      curve: Curves.easeOutBack,
    ));
  }

  void _triggerCartAnimation(String productName) {
    setState(() {
      _showCartAnimation = true;
      _lastAddedProduct = productName;
    });

    // Start animations
    _fadeAnimationController.forward();
    _cartAnimationController.forward();

    // Auto-hide animation after delay
    _animationTimer?.cancel();
    _animationTimer = Timer(const Duration(milliseconds: 2000), () {
      _hideCartAnimation();
    });
  }

  void _hideCartAnimation() {
    _fadeAnimationController.reverse();
    _cartAnimationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showCartAnimation = false;
        });
      }
    });
  }

  void _goToCart() {
    // Navigate to cart screen
    Navigator.pushNamed(context, '/cart');
  }

  void _navigateToProductDetail(Map<String, dynamic> product) {
    Navigator.pushNamed(
      context,
      '/tmart-product-detail',
      arguments: {'product': product},
    );
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    _exploreProductsScrollController.dispose();
    _cartAnimationController.dispose();
    _fadeAnimationController.dispose();
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                // Check if user has scrolled to the explore products section
                if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 300) {
                  // Load more products when user is 300 pixels away from bottom
                  _loadMoreExploreProducts();
                }
                return false;
              },
              child: RefreshIndicator(
                onRefresh: _fetchMartData,
                color: const Color(0xFFFF6B35),
                backgroundColor: Colors.white,
                strokeWidth: 3.0,
                child: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppbarLocation(),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SearchBarWidget(),
                  ),
                  const SizedBox(height: 20),
                  CategoryRow(categories: _currentCategories),
                  const SizedBox(height: 20),
                  if (_currentBannerImages.isNotEmpty) ...[
                    BannerCarousel(images: _currentBannerImages),
                    const SizedBox(height: 20),
                  ],
                  ProductsGrid(
                    productNames: _productGridNames,
                    onProductTap: (category) {
                      setState(() {
                        _selectedCategory = category; // This should be the main category like "Chocolate"
                      });
                      _showCategoryBottomSheet();
                    },
                  ),
                  const SizedBox(height: 40), // Increased from 30 to 40
                  SectionHeader(
                    title: "Daily Essentials",
                    actionText: "View All",
                    onActionTap: () {
                      Navigator.pushNamed(context, '/daily-essentials-page');
                    },
                  ),
                  const SizedBox(height: 20),
                  Consumer<GlobalCartProvider>(
                    builder: (context, cartProvider, child) {
                      if (_isLoadingDailyEssentials) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      // Separate featured and regular daily essentials
                      final featuredEssentials = _currentDailyEssentials.where((product) {
                        // Check if product has featured status from backend
                        return product['isFeaturedDailyEssential'] == true || 
                               product['isFeatured'] == true ||
                               product['trending'] != null; // Fallback to trending products
                      }).toList();
                      
                      final regularEssentials = _currentDailyEssentials.where((product) {
                        return !(product['isFeaturedDailyEssential'] == true || 
                                product['isFeatured'] == true ||
                                product['trending'] != null);
                      }).toList();
                      
                      // Show featured products first, then regular products
                      final allEssentials = [...featuredEssentials, ...regularEssentials];
                      
                      return ProductsList(
                        products: allEssentials,
                        quantities: cartProvider.cartItems,
                        onQuantityChanged: _addToCart,
                        onProductTap: _navigateToProductDetail,
                      );
                    },
                  ),
                  const SizedBox(height: 40), // Increased from 30 to 40
                  SectionHeader(
                    title: "Trending Products",
                    actionText: "View All",
                    onActionTap: () {},
                  ),
                  const SizedBox(height: 20),
                  Consumer<GlobalCartProvider>(
                    builder: (context, cartProvider, child) {
                      if (_isLoadingTrendingProducts) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ProductsList(
                        products: _currentTrendingProducts,
                        quantities: cartProvider.cartItems,
                        onQuantityChanged: _addToCart,
                        isTrending: true,
                        onProductTap: _navigateToProductDetail,
                      );
                    },
                  ),
                  const SizedBox(height: 40), // Increased from 30 to 40
                  SectionHeader(
                    title: "Explore More Products",
                    actionText: "View All",
                    onActionTap: () {},
                  ),
                  const SizedBox(height: 20),
                  Consumer<GlobalCartProvider>(
                    builder: (context, cartProvider, child) {
                      if (_isLoadingExploreProducts && _exploreProducts.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return Column(
                        children: [
                          ExploreProductsGrid(
                            products: _currentExploreProducts,
                            onProductTap: _navigateToProductDetail,
                            onAddToCart: _onExploreProductAddToCart,
                            onRemoveFromCart: _onExploreProductRemoveFromCart,
                            quantities: cartProvider.cartItems,
                          ),
                          // Loading indicator for more products
                          if (_isLoadingMoreExploreProducts)
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          // End of products indicator
                          if (!_hasMoreExploreProducts && _exploreProducts.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  'You\'ve reached the end! 🎉',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  // Add bottom padding to prevent content from being hidden behind floating cart
                  const SizedBox(height: 100),
                ],
              ),
                ),
              ),
            ),
            // Floating Cart Button - Only show when there are items in cart
            Consumer<GlobalCartProvider>(
              builder: (context, cartProvider, child) {
                if (!cartProvider.hasItems) return const SizedBox.shrink();
                return Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
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
                          onTap: _goToCart,
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
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 