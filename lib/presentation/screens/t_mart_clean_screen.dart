import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuukatuu/presentation/widgets/product_card.dart';
import 'package:tuukatuu/providers/mart_cart_provider.dart';
import 'package:tuukatuu/providers/enhanced_cart_provider.dart';
import 'package:tuukatuu/models/cart_item.dart';
import 'package:provider/provider.dart';
import 'package:tuukatuu/services/api_service.dart';
import 'package:tuukatuu/presentation/widgets/tmart_section_header.dart';
import 'package:tuukatuu/presentation/widgets/tmart_category_card.dart';
import 'package:tuukatuu/presentation/widgets/tmart_product_card.dart';
import 'package:tuukatuu/presentation/widgets/tmart_recently_viewed_card.dart';
import 'package:tuukatuu/providers/recently_viewed_provider.dart';
import 'package:tuukatuu/models/product.dart';
import 'package:tuukatuu/presentation/widgets/tmart_skeleton_loader.dart';
import 'package:tuukatuu/routes.dart';
import '../../widgets/global_cart_fab.dart';
import '../../widgets/appbar_location.dart';
import '../../core/config/app_config.dart';

class TMartCleanScreen extends StatefulWidget {
  const TMartCleanScreen({super.key});

  @override
  State<TMartCleanScreen> createState() => _TMartCleanScreenState();
}

class _TMartCleanScreenState extends State<TMartCleanScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late PageController _dealsPageController;
  int _currentPage = 0;
  int _currentDealPage = 0;
  late Timer _timer;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _banners = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _popularProducts = [];
  List<Map<String, dynamic>> _dailyEssentials = [];
  List<Map<String, dynamic>> _todayDeals = [];
  List<Map<String, dynamic>> _recommendations = [];

  // Cart state management
  AnimationController? _cartAnimationController;
  final bool _showCartIndicator = false;
  final int _cartItemCount = 0;
  bool _isRefreshingCategories = false;
  String? _categoriesError;

  // Swiggy color scheme
  static const Color swiggyOrange = Color(0xFFFC8019);
  static const Color swiggyDark = Color(0xFF1C1C1C);
  static const Color swiggyLight = Color(0xFFF8F9FA);
  static const Color swiggyRed = Color(0xFFFC4B6C); // Added for discount badge

  // Helper function to convert item data to Product model
  Product _convertToProduct(Map<String, dynamic> item) {
    return Product(
      id: item['_id'] ?? item['id'] ?? '',
      name: item['name'] ?? '',
      price: (item['price'] ?? 0).toDouble(),
      imageUrl: item['imageUrl'] ?? item['image'] ?? '',
      category: item['category'] ?? '',
      rating: (item['rating'] ?? 0).toDouble(),
      reviews: item['reviews'] ?? 0,
      isAvailable: item['isAvailable'] ?? true,
      deliveryFee: (item['deliveryFee'] ?? 0).toDouble(),
      description: item['description'] ?? '',
      images: item['images'] != null ? List<String>.from(item['images']) : [],
      vendorId: item['vendorId'] ?? '',
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _dealsPageController = PageController(initialPage: _currentDealPage);
    _cartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _startBannerTimer();
    _loadData();
  }

  void _startBannerTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_banners.isNotEmpty) {
        if (_currentPage < _banners.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    print('🚀 Starting data load for T-Mart screen...');
    print('🌐 Base URL: ${AppConfig.baseUrl}');

    try {
      // Load data from API with better error handling
      print('\n📱 Loading banners...');
      final bannersResponse = await ApiService.get('/tmart/banners');
      print('Banners response: $bannersResponse');
      if (bannersResponse['success']) {
        _banners = List<Map<String, dynamic>>.from(bannersResponse['data']);
        print('✅ Banners loaded: ${_banners.length}');
      } else {
        _banners = [];
        print('⚠️ Banners failed: ${bannersResponse['message']}');
      }

      // Load featured categories with better error handling
      print('\n📂 Loading featured categories...');
      final categoriesResponse =
          await ApiService.get('/tmart/categories/featured?limit=8');
      print('Categories response type: ${categoriesResponse.runtimeType}');
      print('Categories response keys: ${categoriesResponse.keys.toList()}');
      print('Categories success: ${categoriesResponse['success']}');
      print('Categories data type: ${categoriesResponse['data']?.runtimeType}');
      print('Categories data: ${categoriesResponse['data']}');

      if (categoriesResponse['success'] && categoriesResponse['data'] != null) {
        _categories =
            List<Map<String, dynamic>>.from(categoriesResponse['data']);
        _categoriesError = null;
        print('✅ Categories loaded: ${_categories.length}');

        // Debug: Print category details
        for (int i = 0; i < _categories.length && i < 3; i++) {
          final category = _categories[i];
          print(
              '   ${i + 1}. ${category['name']} - Featured: ${category['isFeatured']} - Sort: ${category['sortOrder']}');
        }
      } else {
        print('⚠️ Primary categories endpoint failed, trying alternative...');

        // Try alternative endpoint
        try {
          final altCategoriesResponse =
              await ApiService.get('/categories/featured?limit=8');
          print('Alternative categories response: $altCategoriesResponse');

          if (altCategoriesResponse['success'] &&
              altCategoriesResponse['data'] != null) {
            _categories =
                List<Map<String, dynamic>>.from(altCategoriesResponse['data']);
            _categoriesError = null;
            print(
                '✅ Categories loaded from alternative endpoint: ${_categories.length}');
          } else {
            _categories = [];
            _categoriesError = 'Failed to load categories from both endpoints';
            print('❌ Alternative endpoint also failed');
          }
        } catch (e) {
          _categories = [];
          _categoriesError = 'Alternative endpoint error: ${e.toString()}';
          print('❌ Alternative endpoint error: $e');
        }
      }

      print('\n🛍️ Loading popular products...');
      final popularResponse = await ApiService.get('/tmart/popular?limit=8');
      if (popularResponse['success']) {
        _popularProducts =
            List<Map<String, dynamic>>.from(popularResponse['data']);
        print('✅ Popular products loaded: ${_popularProducts.length}');
      } else {
        _popularProducts = [];
        print('⚠️ Popular products failed: ${popularResponse['message']}');
      }

      print('\n🥬 Loading daily essentials...');
      final essentialsResponse = await ApiService.getDailyEssentials(limit: 6);
      if (essentialsResponse.isNotEmpty) {
        _dailyEssentials = essentialsResponse;
        print('✅ Daily essentials loaded: ${_dailyEssentials.length}');

        // Debug: Print first daily essential details
        if (_dailyEssentials.isNotEmpty) {
          final first = _dailyEssentials.first;
          print(
              '   First daily essential: ${first['productId']?['name']} - Featured: ${first['isFeatured']}');
        }
      } else {
        _dailyEssentials = [];
        print('⚠️ Daily essentials failed: No data returned');

        // Add sample data for testing
        _dailyEssentials = _getSampleDailyEssentials();
        print(
            '📝 Using sample daily essentials data: ${_dailyEssentials.length} items');
      }

      print('\n🎯 Loading deals...');
      final dealsResponse = await ApiService.get('/tmart/deals?limit=4');
      if (dealsResponse['success']) {
        print('✅ Deals loaded: ${dealsResponse['data']?.length ?? 0}');
      } else {
        print('⚠️ Deals failed: ${dealsResponse['message']}');
      }

      print('\n🔥 Loading today\'s deals...');
      final todayDealsResponse = await ApiService.get('/today-deals?limit=4');
      if (todayDealsResponse['success']) {
        _todayDeals =
            List<Map<String, dynamic>>.from(todayDealsResponse['data']);
        print('✅ Today\'s deals loaded: ${_todayDeals.length}');
      } else {
        _todayDeals = [];
        print('⚠️ Today\'s deals failed: ${todayDealsResponse['message']}');
      }

      print('\n💡 Loading recommendations...');
      final recommendationsResponse =
          await ApiService.get('/tmart/recommendations?limit=6');
      if (recommendationsResponse['success']) {
        _recommendations =
            List<Map<String, dynamic>>.from(recommendationsResponse['data']);
        print('✅ Recommendations loaded: ${_recommendations.length}');
      } else {
        _recommendations = [];
        print(
            '⚠️ Recommendations failed: ${recommendationsResponse['message']}');
      }

      print('\n🎉 Data loading completed!');
      print('📊 Summary:');
      print('   Banners: ${_banners.length}');
      print('   Categories: ${_categories.length}');
      print('   Popular Products: ${_popularProducts.length}');
      print('   Daily Essentials: ${_dailyEssentials.length}');
      print('   Today\'s Deals: ${_todayDeals.length}');
      print('   Recommendations: ${_recommendations.length}');
    } catch (e) {
      print('❌ Error in _loadData: $e');
      // Set error states instead of loading mock data
      _banners = [];
      _categories = [];
      _popularProducts = [];
      _dailyEssentials = [];
      _todayDeals = [];
      _recommendations = [];

      // Set specific error for categories
      _categoriesError = 'Failed to load data: ${e.toString()}';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Method to test API connectivity
  Future<void> _testApiConnectivity() async {
    print('🧪 Testing API connectivity...');
    print('🌐 Base URL: ${AppConfig.baseUrl}');

    try {
      // Test a simple endpoint
      final testResponse = await ApiService.get('/tmart/banners');
      print('✅ API connectivity test successful: $testResponse');
    } catch (e) {
      print('❌ API connectivity test failed: $e');
    }
  }

  // Method to specifically refresh categories
  Future<void> _refreshCategories() async {
    setState(() {
      _isRefreshingCategories = true;
      _categoriesError = null;
    });

    print('🔄 Refreshing categories...');
    print('🌐 Base URL: ${AppConfig.baseUrl}');
    print('🔍 Calling endpoint: /tmart/categories/featured?limit=8');

    try {
      final categoriesResponse =
          await ApiService.get('/tmart/categories/featured?limit=8');
      print('Categories refresh response: $categoriesResponse');
      print('Response type: ${categoriesResponse.runtimeType}');

      if (categoriesResponse is Map<String, dynamic>) {
        print('Response keys: ${categoriesResponse.keys.toList()}');
        print('Success field: ${categoriesResponse['success']}');
        print('Data field type: ${categoriesResponse['data']?.runtimeType}');
        print('Data field: ${categoriesResponse['data']}');
      }

      if (categoriesResponse['success'] && categoriesResponse['data'] != null) {
        setState(() {
          _categories =
              List<Map<String, dynamic>>.from(categoriesResponse['data']);
          _categoriesError = null;
        });
        print('✅ Refreshed categories: ${_categories.length} loaded');

        // Debug: Print category details
        for (int i = 0; i < _categories.length && i < 3; i++) {
          final category = _categories[i];
          print(
              '   ${i + 1}. ${category['name']} - Featured: ${category['isFeatured']} - Sort: ${category['sortOrder']}');
        }
      } else {
        print(
            '⚠️ Failed to refresh categories, trying alternative endpoint...');

        try {
          final altCategoriesResponse =
              await ApiService.get('/categories/featured?limit=8');
          print('Alternative categories response: $altCategoriesResponse');

          if (altCategoriesResponse['success'] &&
              altCategoriesResponse['data'] != null) {
            setState(() {
              _categories = List<Map<String, dynamic>>.from(
                  altCategoriesResponse['data']);
              _categoriesError = null;
            });
            print(
                '✅ Categories loaded from alternative endpoint: ${_categories.length}');
          } else {
            setState(() {
              _categories = [];
              _categoriesError =
                  'Failed to load categories from both endpoints';
            });
            print('❌ Alternative endpoint also failed');
          }
        } catch (e) {
          print('❌ Alternative endpoint refresh error: $e');
          setState(() {
            _categories = [];
            _categoriesError = 'Alternative endpoint error: ${e.toString()}';
          });
        }
      }
    } catch (e) {
      print('❌ Categories refresh error: $e');
      setState(() {
        _categoriesError = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() => _isRefreshingCategories = false);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    _dealsPageController.dispose();
    _cartAnimationController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final martCartProvider = Provider.of<MartCartProvider>(context);
    final recentlyViewedProvider = Provider.of<RecentlyViewedProvider>(context);

    return Scaffold(
      backgroundColor: swiggyLight,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: SafeArea(
          child: AppbarLocation(showTmartDelivery: true),
        ),
      ),
      body: Stack(
        children: [
          _isLoading
              ? _buildSkeletonLoader()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        _buildSearchAndBannerSection(),
                        _buildCategoriesSection(),
                        _buildTodayDealsSection(),
                        _buildDailyEssentialsSection(martCartProvider),
                        _buildPopularProductsSection(
                            martCartProvider, recentlyViewedProvider),
                        _buildRecommendedProductsSection(
                            martCartProvider, recentlyViewedProvider),
                        _buildRecentlyViewedSection(
                            martCartProvider, recentlyViewedProvider),

                        // General retry section if there are multiple errors
                        if (_categoriesError != null ||
                            _banners.isEmpty ||
                            _popularProducts.isEmpty) ...[
                          Container(
                            margin: const EdgeInsets.all(16.0),
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.wifi_off,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Some data couldn\'t be loaded',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: swiggyDark,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Check your internet connection and try again',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () => _loadData(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: swiggyOrange,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: const Text(
                                    'Retry All',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 100),
                      ],
                    ),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
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
              ),
            ),
        ],
      ),
      floatingActionButton: const GlobalCartFAB(
        heroTag: 'tmart_fab',
      ),
    );
  }

  Widget _buildSearchAndBannerSection() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search for groceries, fruits, vegetables...",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    Navigator.pushNamed(context, '/tmart-search',
                        arguments: value.trim());
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            if (_banners.isNotEmpty) ...[],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    if (_categories.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TMartSectionHeader(
                      title: "Shop by Category",
                      icon: Icons.category,
                      onViewAll: () {
                        Navigator.pushNamed(context, '/tmart-categories');
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: _isRefreshingCategories
                        ? null
                        : () => _refreshCategories(),
                    icon: _isRefreshingCategories
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    tooltip: 'Refresh categories',
                  ),
                  IconButton(
                    onPressed: () => _testApiConnectivity(),
                    icon: const Icon(Icons.bug_report),
                    tooltip: 'Test API connectivity',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 100,
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No categories available',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _loadData(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: swiggyOrange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TMartSectionHeader(
                    title: "Shop by Category",
                    icon: Icons.category,
                    onViewAll: () {
                      Navigator.pushNamed(context, '/tmart-categories');
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Status indicator

          Container(
            height: 230, // Increased height for 2 rows
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: _categories.length > 8
                  ? 8
                  : _categories.length, // Show max 8 categories (4x2)
              itemBuilder: (context, index) {
                final category = _categories[index];
                return TMartCategoryCard(
                  category: category,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/tmart-category-products',
                      arguments: {
                        'categoryName': category['name'],
                        'categoryDisplayName':
                            category['displayName'] ?? category['name'],
                      },
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDailyEssentialsSection(MartCartProvider martCartProvider) {
    if (_dailyEssentials.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: TMartSectionHeader(
                title: "Daily Essentials",
                icon: Icons.star,
                onViewAll: () {
                  // Navigate to daily essentials page
                },
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 100,
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star_outline,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No daily essentials available',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: TMartSectionHeader(
              title: "Daily Essentials",
              icon: Icons.star,
              onViewAll: () {
                // Navigate to daily essentials page
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height:
                280, // Reduced height to match store details card proportions
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _dailyEssentials.length,
              itemBuilder: (context, index) {
                final essential = _dailyEssentials[index];
                return Container(
                  width:
                      160, // Reduced width to match store details card proportions
                  margin: const EdgeInsets.only(right: 12.0),
                  child: _buildDailyEssentialCard(essential, martCartProvider),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDailyEssentialCard(
      Map<String, dynamic> essential, MartCartProvider martCartProvider) {
    // Extract product data from the essential object
    final product = essential['productId'] ?? essential;
    final isFeatured = essential['isFeatured'] ?? false;
    final hasDiscount = product['originalPrice'] != null &&
        product['originalPrice'] > (product['price'] ?? 0);
    
    // Get dynamic values with fallbacks
    final productName = product['name'] ?? 'Unknown Product';
    final productCategory = product['category'] ?? 'General';
    final productPrice = product['price'] ?? 0;
    final originalPrice = product['originalPrice'];
    final rating = product['rating'] ?? 0.0;
    final reviews = product['reviews'] ?? 0;
    final imageUrl = product['imageUrl'] ?? product['image'] ?? product['images']?.firstOrNull;
    
    return Container(
        child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(210, 210, 210, 1),
              borderRadius: BorderRadius.circular(10),
            ),
            width: 130,
            height: 120,
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Stack(
                children: [
                  Container(
                      decoration: const BoxDecoration(color: Colors.white),
                      child: imageUrl != null && imageUrl.toString().isNotEmpty
                          ? Image.network(
                              imageUrl.toString(),
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 120,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported, size: 40),
                                );
                              },
                            )
                          : Container(
                              height: 120,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported, size: 40),
                            )),
                  
                  // Featured badge
                  if (isFeatured)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'FEATURED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  
                  // Discount badge
                  if (hasDiscount)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${(((originalPrice - productPrice) / originalPrice) * 100).round()}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  
                  Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                        height: 25,
                        width: 35,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromRGBO(190, 190, 190, 1),
                              width: 2),
                        ),
                        child: Container(
                            child: const Icon(
                              Icons.add_circle,
                              size: 20,
                            ))),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(190, 190, 190, 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                      productCategory.toUpperCase(),
                      style:
                          const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  productName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(
                  height: 3,
                ),
                //Rating
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      if (index < rating.floor()) {
                        return const Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber,
                        );
                      } else if (index == rating.floor() && rating % 1 > 0) {
                        return const Icon(
                          Icons.star_half_sharp,
                          size: 14,
                          color: Colors.amber,
                        );
                      } else {
                        return const Icon(
                          Icons.star_border,
                          size: 14,
                          color: Colors.amber,
                        );
                      }
                    }),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style:
                          const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    if (reviews > 0) ...[
                      const SizedBox(width: 2),
                      Text(
                        "(${reviews})",
                        style:
                            const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
                const SizedBox(
                  height: 3,
                ),

                Row(
                  children: [
                    Text(
                      "Rs. ${productPrice.toStringAsFixed(0)}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (hasDiscount) ...[
                      const SizedBox(width: 8),
                      Text(
                        "Rs. ${originalPrice.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(
                  height: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildProductImage(Map<String, dynamic> product) {
    // Try multiple image sources for better image fetching
    final imageUrl = product['imageUrl'] ??
        product['image'] ??
        product['images']?.firstOrNull;
    print("Image $product");
    if (imageUrl != null && imageUrl.toString().isNotEmpty) {
      return Image.network(
        imageUrl.toString(),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder(product);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                valueColor: const AlwaysStoppedAnimation<Color>(swiggyOrange),
              ),
            ),
          );
        },
      );
    }

    return _buildImagePlaceholder(product);
  }

  Widget _buildImagePlaceholder(Map<String, dynamic> product) {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(product['category'] ?? ''),
              size: 32,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              product['name'] ?? 'Product',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'fruits':
      case 'vegetables':
        return Colors.green;
      case 'dairy':
      case 'milk':
        return Colors.blue;
      case 'bread':
      case 'bakery':
        return Colors.orange;
      case 'meat':
      case 'fish':
        return Colors.red;
      case 'beverages':
      case 'drinks':
        return Colors.purple;
      case 'snacks':
        return Colors.amber;
      case 'grains':
      case 'rice':
        return Colors.brown;
      default:
        return swiggyOrange;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fruits':
      case 'vegetables':
        return Icons.eco;
      case 'dairy':
      case 'milk':
        return Icons.local_drink;
      case 'bread':
      case 'bakery':
        return Icons.cake;
      case 'meat':
      case 'fish':
        return Icons.set_meal;
      case 'beverages':
      case 'drinks':
        return Icons.local_bar;
      case 'snacks':
        return Icons.fastfood;
      case 'grains':
      case 'rice':
        return Icons.grain;
      default:
        return Icons.shopping_basket;
    }
  }

  Widget _buildTodayDealsSection() {
    if (_todayDeals.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: TMartSectionHeader(
                title: "Today's Deals",
                icon: Icons.local_offer,
                onViewAll: () {
                  // Navigate to deals page
                },
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 100,
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_offer_outlined,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No deals available today',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: TMartSectionHeader(
              title: "Today's Deals",
              icon: Icons.local_offer,
              onViewAll: () {
                // Navigate to deals page
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: PageView.builder(
              controller: _dealsPageController,
              itemCount: _todayDeals.length,
              onPageChanged: (index) {
                setState(() {
                  _currentDealPage = index;
                });
              },
              itemBuilder: (context, index) {
                final deal = _todayDeals[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildDealBanner(deal),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Page Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _todayDeals.length,
              (index) => Container(
                width: _currentDealPage == index ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _currentDealPage == index
                      ? swiggyOrange
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDealBanner(Map<String, dynamic> deal) {
    final dealColor = _getDealColor(deal);

    return GestureDetector(
      onTap: () {
        // Deal applied silently
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.network(
                  deal['imageUrl'] ??
                      'https://via.placeholder.com/400x200?text=Deal+Image',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            dealColor,
                            dealColor.withOpacity(0.8),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Dark overlay for better text readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row with badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Deal Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: dealColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: dealColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            _getDealTypeText(deal),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Featured Badge
                        if (deal['isFeatured'] == true)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'FEATURED',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const Spacer(),

                    // Deal Title
                    Text(
                      deal['name'] ?? deal['description'] ?? 'Special Deal',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.white,
                        height: 1.2,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Deal Description
                    Text(
                      deal['shortDescription'] ??
                          deal['description'] ??
                          'Limited time offer',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.3,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Countdown Timer
                    if (deal['endDate'] != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getTimeRemaining(deal['endDate']),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    const SizedBox(height: 16),

                    // Action Button
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: dealColor,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: dealColor.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            deal['buttonText'] ?? 'Shop Now',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Price information overlay (if available)
              if (deal['price'] != null && deal['originalPrice'] != null)
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '₹${deal['originalPrice']}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        Text(
                          '₹${deal['price']}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: dealColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDealColor(Map<String, dynamic> deal) {
    // Try to get color from deal data, fallback to default
    final backgroundColor = deal['backgroundColor'];
    if (backgroundColor != null) {
      try {
        return Color(int.parse(backgroundColor.replaceAll('#', '0xFF')));
      } catch (e) {
        // Fallback to default color
      }
    }

    // Use different colors based on deal type or discount
    final dealType = deal['dealType'];
    final discount = deal['discount'];

    if (dealType == 'percentage' && discount != null) {
      if (discount >= 50) return Colors.red; // High discount
      if (discount >= 30) return Colors.orange; // Medium discount
      if (discount >= 20) return Colors.blue; // Low discount
    }

    return swiggyOrange; // Default color
  }

  String _getDealTypeText(Map<String, dynamic> deal) {
    final dealType = deal['dealType'];
    final discount = deal['discount'];
    final discountValue = deal['discountValue'];

    switch (dealType) {
      case 'percentage':
        if (discount != null) return '${discount}% OFF';
        if (discountValue != null) return '${discountValue}% OFF';
        return 'PERCENTAGE OFF';
      case 'fixed':
        if (discountValue != null) return '₹${discountValue} OFF';
        return 'FIXED OFF';
      case 'buy_one_get_one':
        return 'BOGO';
      case 'free_delivery':
        return 'FREE DELIVERY';
      case 'combo':
        return 'COMBO DEAL';
      default:
        // If no dealType, try to calculate from discount
        if (discount != null) return '${discount}% OFF';
        return 'SPECIAL DEAL';
    }
  }

  String _getTimeRemaining(String? endDate) {
    if (endDate == null) return 'Limited time';

    try {
      final end = DateTime.parse(endDate);
      final now = DateTime.now();
      final difference = end.difference(now);

      if (difference.isNegative) return 'Expired';

      final days = difference.inDays;
      final hours = difference.inHours % 24;
      final minutes = difference.inMinutes % 60;

      if (days > 0) return '${days}d ${hours}h left';
      if (hours > 0) return '${hours}h ${minutes}m left';
      if (minutes > 0) return '${minutes}m left';

      return 'Ending soon';
    } catch (e) {
      return 'Limited time';
    }
  }

  Widget _buildPopularProductsSection(MartCartProvider martCartProvider,
      RecentlyViewedProvider recentlyViewedProvider) {
    if (_popularProducts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TMartSectionHeader(
              title: "Fast Delivery Products",
              icon: Icons.trending_up,
              onViewAll: () {
                Navigator.pushNamed(context, '/tmart-popular-products');
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_up_outlined,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No popular products available',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
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

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TMartSectionHeader(
            title: "Fast Delivery Products",
            icon: Icons.trending_up,
            onViewAll: () {
              Navigator.pushNamed(context, '/tmart-popular-products');
            },
          ),
          const SizedBox(height: 16),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: _popularProducts.length,
            itemBuilder: (context, index) {
              final item = _popularProducts[index];
              final String productId = item['_id'] ?? item['id'] ?? '';
              final martCartProvider =
                  Provider.of<MartCartProvider>(context, listen: false);
              final int quantity = martCartProvider.getItemQuantity(productId);

              return GestureDetector(
                onTap: () {
                  recentlyViewedProvider.addToRecentlyViewed(item);
                  Navigator.pushNamed(
                    context,
                    AppRoutes.tmartProductDetail,
                    arguments: {
                      'product': item,
                    },
                  );
                },
                child: TMartProductCard(
                  item: item,
                  quantity: quantity,
                  onAdd: () {
                    final enhancedCartProvider =
                        Provider.of<EnhancedCartProvider>(context,
                            listen: false);
                    final product = _convertToProduct(item);
                    enhancedCartProvider.addFromMart(product);
                    // Item added to cart silently
                  },
                  onIncrement: () {
                    final enhancedCartProvider =
                        Provider.of<EnhancedCartProvider>(context,
                            listen: false);
                    final product = _convertToProduct(item);
                    enhancedCartProvider.addFromMart(product);
                  },
                  onDecrement: () {
                    final enhancedCartProvider =
                        Provider.of<EnhancedCartProvider>(context,
                            listen: false);
                    final product = _convertToProduct(item);
                    enhancedCartProvider.removeItem(
                        product, CartItemSource.mart);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedProductsSection(MartCartProvider martCartProvider,
      RecentlyViewedProvider recentlyViewedProvider) {
    if (_recommendations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TMartSectionHeader(
                    title: "Recommended for You",
                    icon: Icons.recommend,
                    onViewAll: () {
                      Navigator.pushNamed(
                          context, '/tmart-recommended-products');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.recommend_outlined,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No recommendations available',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
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

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TMartSectionHeader(
                  title: "Recommended for You",
                  icon: Icons.recommend,
                  onViewAll: () {
                    Navigator.pushNamed(context, '/tmart-recommended-products');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: _recommendations.length,
            itemBuilder: (context, index) {
              final item = _recommendations[index];
              final enhancedCartProvider =
                  Provider.of<EnhancedCartProvider>(context, listen: false);
              final product = _convertToProduct(item);
              final int quantity = enhancedCartProvider.getItemQuantity(
                  product, CartItemSource.mart);

              return GestureDetector(
                onTap: () {
                  recentlyViewedProvider.addToRecentlyViewed(item);
                  Navigator.pushNamed(
                    context,
                    AppRoutes.tmartProductDetail,
                    arguments: {
                      'product': item,
                    },
                  );
                },
                child: TMartProductCard(
                  item: item,
                  quantity: quantity,
                  onAdd: () {
                    final enhancedCartProvider =
                        Provider.of<EnhancedCartProvider>(context,
                            listen: false);
                    final product = _convertToProduct(item);
                    enhancedCartProvider.addFromMart(product);
                    // Item added to cart silently
                  },
                  onIncrement: () {
                    final enhancedCartProvider =
                        Provider.of<EnhancedCartProvider>(context,
                            listen: false);
                    final product = _convertToProduct(item);
                    enhancedCartProvider.addFromMart(product);
                  },
                  onDecrement: () {
                    final enhancedCartProvider =
                        Provider.of<EnhancedCartProvider>(context,
                            listen: false);
                    final product = _convertToProduct(item);
                    enhancedCartProvider.removeItem(
                        product, CartItemSource.mart);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyViewedSection(MartCartProvider martCartProvider,
      RecentlyViewedProvider recentlyViewedProvider) {
    final recentlyViewed = recentlyViewedProvider.getRecentlyViewed(limit: 10);
    if (recentlyViewed.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: TMartSectionHeader(
              title: "Recently Viewed",
              icon: Icons.history,
              onViewAll: () {
                Navigator.pushNamed(context, '/recently-viewed-page');
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: recentlyViewed.length,
              itemBuilder: (context, index) {
                final item = recentlyViewed[index];
                final enhancedCartProvider =
                    Provider.of<EnhancedCartProvider>(context, listen: false);
                final product = _convertToProduct(item);
                final int quantity = enhancedCartProvider.getItemQuantity(
                    product, CartItemSource.mart);

                return GestureDetector(
                  onTap: () {
                    recentlyViewedProvider.addToRecentlyViewed(item);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.tmartProductDetail,
                      arguments: {
                        'product': item,
                      },
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: TMartRecentlyViewedCard(
                      item: item,
                      quantity: quantity,
                      onAdd: () {
                        final enhancedCartProvider =
                            Provider.of<EnhancedCartProvider>(context,
                                listen: false);
                        final product = _convertToProduct(item);
                        enhancedCartProvider.addFromMart(product);
                        // Item added to cart silently
                      },
                      onIncrement: () {
                        final enhancedCartProvider =
                            Provider.of<EnhancedCartProvider>(context,
                                listen: false);
                        final product = _convertToProduct(item);
                        enhancedCartProvider.addFromMart(product);
                      },
                      onDecrement: () {
                        final enhancedCartProvider =
                            Provider.of<EnhancedCartProvider>(context,
                                listen: false);
                        final product = _convertToProduct(item);
                        enhancedCartProvider.removeItem(
                            product, CartItemSource.mart);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Banner skeleton
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 24),

        // Categories skeleton
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TMartSkeletonLoader(
                  height: 20, width: 150, borderRadius: 4),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: TMartSkeletonLoader(
                        height: 100, width: 80, borderRadius: 8),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Products skeleton
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TMartSkeletonLoader(
                  height: 20, width: 150, borderRadius: 4),
              const SizedBox(height: 16),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: 4,
                itemBuilder: (context, index) =>
                    const TMartProductCardSkeleton(),
              ),
            ],
          ),
        ),

        // Deals skeleton
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TMartSkeletonLoader(
                  height: 20, width: 150, borderRadius: 4),
              const SizedBox(height: 16),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: TMartDealCardSkeleton(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getSampleDailyEssentials() {
    return [
      {
        'productId': {
          '_id': '60d0fe4f5311236168a109ca',
          'name': 'Fresh Tomatoes',
          'price': 50,
          'originalPrice': 60,
          'imageUrl':
              'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?w=300&h=300&fit=crop',
          'category': 'vegetables',
          'rating': 4.5,
          'reviews': 120,
          'isAvailable': true,
          'deliveryFee': 10,
          'description':
              'Fresh and juicy tomatoes from local farms, perfect for salads and cooking.',
          'images': [
            'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?w=300&h=300&fit=crop',
            'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=300&h=300&fit=crop'
          ],
          'vendorId': 'vendor123',
          'unit': 'kg',
        },
        'isFeatured': true,
      },
      {
        'productId': {
          '_id': '60d0fe4f5311236168a109cb',
          'name': 'Organic Milk',
          'price': 30,
          'originalPrice': 35,
          'imageUrl':
              'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=300&h=300&fit=crop',
          'category': 'dairy',
          'rating': 4.8,
          'reviews': 80,
          'isAvailable': true,
          'deliveryFee': 5,
          'description':
              'Pure organic milk from grass-fed cows, rich in nutrients and vitamins.',
          'images': [
            'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=300&h=300&fit=crop',
            'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=300&h=300&fit=crop'
          ],
          'vendorId': 'vendor123',
          'unit': 'litre',
        },
        'isFeatured': false,
      },
      {
        'productId': {
          '_id': '60d0fe4f5311236168a109cc',
          'name': 'Whole Wheat Bread',
          'price': 25,
          'originalPrice': 30,
          'imageUrl':
              'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=300&h=300&fit=crop',
          'category': 'bread',
          'rating': 4.2,
          'reviews': 50,
          'isAvailable': true,
          'deliveryFee': 8,
          'description':
              'Freshly baked whole wheat bread with natural ingredients and no preservatives.',
          'images': [
            'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=300&h=300&fit=crop',
            'https://images.unsplash.com/photo-1586444248902-2f64eddc13df?w=300&h=300&fit=crop'
          ],
          'vendorId': 'vendor123',
          'unit': 'piece',
        },
        'isFeatured': true,
      },
      {
        'productId': {
          '_id': '60d0fe4f5311236168a109cd',
          'name': 'Fresh Carrots',
          'price': 20,
          'originalPrice': 25,
          'imageUrl':
              'https://images.unsplash.com/photo-1447175008436-1701707a0b54?w=300&h=300&fit=crop',
          'category': 'vegetables',
          'rating': 4.0,
          'reviews': 30,
          'isAvailable': true,
          'deliveryFee': 7,
          'description':
              'Juicy and crunchy fresh carrots, rich in beta-carotene and fiber.',
          'images': [
            'https://images.unsplash.com/photo-1447175008436-1701707a0b54?w=300&h=300&fit=crop',
            'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=300&h=300&fit=crop'
          ],
          'vendorId': 'vendor123',
          'unit': 'kg',
        },
        'isFeatured': false,
      },
      {
        'productId': {
          '_id': '60d0fe4f5311236168a109ce',
          'name': 'Fresh Cucumber',
          'price': 15,
          'originalPrice': 20,
          'imageUrl':
              'https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?w=300&h=300&fit=crop',
          'category': 'vegetables',
          'rating': 4.1,
          'reviews': 40,
          'isAvailable': true,
          'deliveryFee': 6,
          'description':
              'Refreshing and crisp fresh cucumbers, perfect for salads and hydration.',
          'images': [
            'https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?w=300&h=300&fit=crop',
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300&h=300&fit=crop'
          ],
          'vendorId': 'vendor123',
          'unit': 'kg',
        },
        'isFeatured': true,
      },
      {
        'productId': {
          '_id': '60d0fe4f5311236168a109cf',
          'name': 'Fresh Bananas',
          'price': 40,
          'originalPrice': 45,
          'imageUrl':
              'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=300&h=300&fit=crop',
          'category': 'fruits',
          'rating': 4.6,
          'reviews': 95,
          'isAvailable': true,
          'deliveryFee': 8,
          'description':
              'Sweet and nutritious fresh bananas, perfect for breakfast and snacks.',
          'images': [
            'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=300&h=300&fit=crop',
            'https://images.unsplash.com/photo-1603833665858-e61d17a86224?w=300&h=300&fit=crop'
          ],
          'vendorId': 'vendor123',
          'unit': 'dozen',
        },
        'isFeatured': false,
      },
    ];
  }
}
