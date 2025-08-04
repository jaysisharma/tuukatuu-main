import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuukatuu/providers/mart_cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:tuukatuu/services/api_service.dart';
import 'package:tuukatuu/presentation/widgets/tmart_section_header.dart';
import 'package:tuukatuu/presentation/widgets/tmart_category_card.dart';
import 'package:tuukatuu/presentation/widgets/tmart_product_card.dart';
import 'package:tuukatuu/presentation/widgets/tmart_recently_viewed_card.dart';
import 'package:tuukatuu/presentation/widgets/tmart_deal_card.dart';
import 'package:tuukatuu/presentation/widgets/daily_essentials_section.dart';
import 'package:tuukatuu/presentation/screens/tmart_cart_screen.dart';
import 'package:tuukatuu/presentation/screens/recently_viewed_page.dart';
import 'package:tuukatuu/providers/recently_viewed_provider.dart';
import 'package:tuukatuu/presentation/screens/product_details_screen.dart';
import 'package:tuukatuu/models/product.dart';
import 'package:tuukatuu/presentation/widgets/tmart_skeleton_loader.dart';
import 'package:tuukatuu/presentation/widgets/tmart_today_deal_card.dart';
import 'package:tuukatuu/presentation/widgets/tmart_promotional_deal_card.dart';
import 'package:tuukatuu/presentation/widgets/cached_image.dart';
import 'package:tuukatuu/routes.dart';
import 'package:tuukatuu/presentation/screens/tmart_product_detail_screen.dart';
import 'package:tuukatuu/presentation/screens/tmart_dedicated_cart_screen.dart';

class TMartCleanScreen extends StatefulWidget {
  const TMartCleanScreen({super.key});

  @override
  State<TMartCleanScreen> createState() => _TMartCleanScreenState();
}

class _TMartCleanScreenState extends State<TMartCleanScreen> with TickerProviderStateMixin {
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
  List<Map<String, dynamic>> _deals = [];
  List<Map<String, dynamic>> _todayDeals = [];
  List<Map<String, dynamic>> _recommendations = [];
  
  // Cart state management
  Map<String, int> _itemQuantities = {};
  Map<String, AnimationController> _itemAnimationControllers = {};
  AnimationController? _cartAnimationController;
  bool _showCartIndicator = false;
  int _cartItemCount = 0;

  // Swiggy color scheme
  static const Color swiggyOrange = Color(0xFFFC8019);
  static const Color swiggyRed = Color(0xFFE23744);
  static const Color swiggyDark = Color(0xFF1C1C1C);
  static const Color swiggyLight = Color(0xFFF8F9FA);

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
    try {
      // Load data from API
      final bannersResponse = await ApiService.get('/tmart/banners');
      if (bannersResponse['success']) {
        _banners = List<Map<String, dynamic>>.from(bannersResponse['data']);
      } else {
        _banners = _getMockBanners();
      }

      final categoriesResponse = await ApiService.get('/tmart/categories/featured?limit=8');
      if (categoriesResponse['success']) {
        _categories = List<Map<String, dynamic>>.from(categoriesResponse['data']);
      } else {
        _categories = _getMockCategories();
      }

      final popularResponse = await ApiService.get('/tmart/popular?limit=8');
      if (popularResponse['success']) {
        _popularProducts = List<Map<String, dynamic>>.from(popularResponse['data']);
      } else {
        _popularProducts = _getMockPopularProducts();
      }

      final essentialsResponse = await ApiService.get('/tmart/daily-essentials?limit=6');
      if (essentialsResponse['success']) {
        _dailyEssentials = List<Map<String, dynamic>>.from(essentialsResponse['data']);
      } else {
        _dailyEssentials = _getMockDailyEssentials();
      }

      final dealsResponse = await ApiService.get('/tmart/deals?limit=4');
      if (dealsResponse['success']) {
        _deals = List<Map<String, dynamic>>.from(dealsResponse['data']);
      } else {
        _deals = _getMockDeals();
      }

      final todayDealsResponse = await ApiService.get('/tmart/deals/today?limit=4');
      if (todayDealsResponse['success']) {
        _todayDeals = List<Map<String, dynamic>>.from(todayDealsResponse['data']);
      } else {
        _todayDeals = _getMockTodayDeals();
      }

      final recommendationsResponse = await ApiService.get('/tmart/recommendations?limit=6');
      if (recommendationsResponse['success']) {
        _recommendations = List<Map<String, dynamic>>.from(recommendationsResponse['data']);
      } else {
        _recommendations = _getMockRecommendations();
      }

    } catch (e) {
      print('Error loading T-Mart data: $e');
      // Load mock data on error
      _banners = _getMockBanners();
      _categories = _getMockCategories();
      _popularProducts = _getMockPopularProducts();
      _dailyEssentials = _getMockDailyEssentials();
      _deals = _getMockDeals();
      _todayDeals = _getMockTodayDeals();
      _recommendations = _getMockRecommendations();
    } finally {
      setState(() => _isLoading = false);
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
      appBar: _buildAppBar(martCartProvider),
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
                      _buildPopularProductsSection(martCartProvider, recentlyViewedProvider),
                      _buildRecommendedProductsSection(martCartProvider, recentlyViewedProvider),
                      _buildRecentlyViewedSection(martCartProvider, recentlyViewedProvider),
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
              ),
            ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(martCartProvider),
    );
  }

  PreferredSizeWidget _buildAppBar(MartCartProvider martCartProvider) {
    return AppBar(
      backgroundColor: swiggyOrange,
      elevation: 0,
     
      title: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'T-Mart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text("Quick Delivery", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),)
       ,      SizedBox(height: 10)
              ],
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TMartDedicatedCartScreen()));
              },
            ),
            if (martCartProvider.itemCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: swiggyRed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    martCartProvider.itemCount.toString(),
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
      ],
    );
  }

  Widget _buildSearchAndBannerSection() {
    return Container(
      decoration: const BoxDecoration(
        color: swiggyOrange,
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    Navigator.pushNamed(context, '/tmart-search', arguments: value.trim());
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            
            if (_banners.isNotEmpty) ...[
           ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    if (_categories.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: TMartSectionHeader(
              title: "Shop by Category",
              icon: Icons.category,
              onViewAll: () {
                Navigator.pushNamed(context, '/tmart-categories');
              },
            ),
          ),
          const SizedBox(height: 12),
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
              itemCount: _categories.length > 8 ? 8 : _categories.length, // Show max 8 categories (4x2)
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
                        'categoryDisplayName': category['displayName'] ?? category['name'],
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
    // For now, we'll skip the daily essentials section since it expects UnifiedCartProvider
    return const SizedBox.shrink();
  }

  Widget _buildTodayDealsSection() {
    if (_todayDeals.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
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
            height: 220,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${deal['name']} deal applied!'),
            backgroundColor: swiggyOrange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              dealColor,
              dealColor.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: dealColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Pattern
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Left Content
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Deal Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
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
                        
                        const SizedBox(height: 16),
                        
                        // Deal Title
                        Text(
                          deal['name'] ?? '',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Deal Description
                        Text(
                          deal['shortDescription'] ?? deal['description'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Action Button
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
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
                                  color: dealColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                color: dealColor,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Right Image
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: NetworkImage(deal['imageUrl'] ?? ''),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            // Handle error
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Featured Badge
            if (deal['isFeatured'] == true)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
              ),
          ],
        ),
      ),
    );
  }

  Color _getDealColor(Map<String, dynamic> deal) {
    final backgroundColor = deal['backgroundColor'];
    if (backgroundColor != null) {
      try {
        return Color(int.parse(backgroundColor.replaceAll('#', '0xFF')));
      } catch (e) {
        // Fallback to default color
      }
    }
    return swiggyOrange;
  }

  String _getDealTypeText(Map<String, dynamic> deal) {
    switch (deal['dealType']) {
      case 'percentage':
        return '${deal['discountValue']}% OFF';
      case 'fixed':
        return '₹${deal['discountValue']} OFF';
      case 'buy_one_get_one':
        return 'BOGO';
      case 'free_delivery':
        return 'FREE DELIVERY';
      case 'combo':
        return 'COMBO DEAL';
      default:
        return 'DEAL';
    }
  }

  Widget _buildPopularProductsSection(MartCartProvider martCartProvider, RecentlyViewedProvider recentlyViewedProvider) {
    if (_popularProducts.isEmpty) return const SizedBox.shrink();

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
                    martCartProvider.addItem(item, quantity: 1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item['name']} added to cart'),
                        backgroundColor: swiggyOrange,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  onIncrement: () {
                    martCartProvider.updateQuantity(productId, quantity + 1);
                  },
                  onDecrement: () {
                    if (quantity > 1) {
                      martCartProvider.updateQuantity(productId, quantity - 1);
                    } else {
                      martCartProvider.removeItem(productId);
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedProductsSection(MartCartProvider martCartProvider, RecentlyViewedProvider recentlyViewedProvider) {
    if (_recommendations.isEmpty) return const SizedBox.shrink();

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
              final String productId = item['_id'] ?? item['id'] ?? '';
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
                    martCartProvider.addItem(item, quantity: 1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item['name']} added to cart'),
                        backgroundColor: swiggyOrange,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  onIncrement: () {
                    martCartProvider.updateQuantity(productId, quantity + 1);
                  },
                  onDecrement: () {
                    if (quantity > 1) {
                      martCartProvider.updateQuantity(productId, quantity - 1);
                    } else {
                      martCartProvider.removeItem(productId);
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyViewedSection(MartCartProvider martCartProvider, RecentlyViewedProvider recentlyViewedProvider) {
    final recentlyViewed = recentlyViewedProvider.getRecentlyViewed(limit: 10);
    if (recentlyViewed.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: TMartSectionHeader(
              title: "Recently Viewed",
              icon: Icons.history,
              onViewAll: () {
                Navigator.pushNamed(context, '/recently-viewed-page');
              },
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: recentlyViewed.length,
              itemBuilder: (context, index) {
                final item = recentlyViewed[index];
                final String productId = item['_id'] ?? item['id'];
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
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: TMartRecentlyViewedCard(
                      item: item,
                      quantity: quantity,
                      onAdd: () {
                        martCartProvider.addItem(item, quantity: 1);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item['name']} added to cart'),
                            backgroundColor: swiggyOrange,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      onIncrement: () {
                        martCartProvider.updateQuantity(productId, quantity + 1);
                      },
                      onDecrement: () {
                        if (quantity > 1) {
                          martCartProvider.updateQuantity(productId, quantity - 1);
                        } else {
                          martCartProvider.removeItem(productId);
                        }
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
              TMartSkeletonLoader(height: 20, width: 150, borderRadius: 4),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: TMartSkeletonLoader(height: 100, width: 80, borderRadius: 8),
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
              TMartSkeletonLoader(height: 20, width: 150, borderRadius: 4),
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
                itemBuilder: (context, index) => TMartProductCardSkeleton(),
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
              TMartSkeletonLoader(height: 20, width: 150, borderRadius: 4),
              const SizedBox(height: 16),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(right: 12),
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

  Widget _buildFloatingActionButton(MartCartProvider martCartProvider) {
    if (martCartProvider.itemCount == 0) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TMartDedicatedCartScreen()));
        },
        backgroundColor: swiggyOrange,
        icon: const Icon(Icons.shopping_cart, color: Colors.white),
        label: Text(
          '(${martCartProvider.itemCount})',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Mock data methods
  List<Map<String, dynamic>> _getMockBanners() {
    return [
      {
        'id': '1',
        'title': 'Fresh Groceries',
        'imageUrl': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400&h=200&fit=crop',
      },
      {
        'id': '2',
        'title': 'Fast Delivery',
        'imageUrl': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400&h=200&fit=crop',
      },
    ];
  }

  List<Map<String, dynamic>> _getMockCategories() {
    return [
      {'id': '1', 'name': 'Fruits', 'displayName': 'Fresh Fruits', 'imageUrl': 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=100&h=100&fit=crop'},
      {'id': '2', 'name': 'Vegetables', 'displayName': 'Fresh Vegetables', 'imageUrl': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=100&h=100&fit=crop'},
      {'id': '3', 'name': 'Dairy', 'displayName': 'Dairy Products', 'imageUrl': 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=100&h=100&fit=crop'},
      {'id': '4', 'name': 'Bakery', 'displayName': 'Fresh Bakery', 'imageUrl': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=100&h=100&fit=crop'},
    ];
  }

  List<Map<String, dynamic>> _getMockPopularProducts() {
    return [
      {
        'id': '1',
        'name': 'Fresh Bananas',
        'price': 49.0,
        'imageUrl': 'https://images.unsplash.com/photo-1528825871115-3581a5387919?w=200&h=200&fit=crop',
        'vendorId': 'tmart',
        'vendorName': 'T-Mart Express',
      },
      {
        'id': '2',
        'name': 'Organic Tomatoes',
        'price': 79.0,
        'imageUrl': 'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=200&h=200&fit=crop',
        'vendorId': 'tmart',
        'vendorName': 'T-Mart Express',
      },
    ];
  }

  List<Map<String, dynamic>> _getMockDailyEssentials() {
    return [
      {
        'id': '1',
        'name': 'Milk 1L',
        'price': 65.0,
        'imageUrl': 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=200&h=200&fit=crop',
        'vendorId': 'tmart',
        'vendorName': 'T-Mart Express',
      },
    ];
  }

  List<Map<String, dynamic>> _getMockDeals() {
    return [
      {
        'id': '1',
        'title': '50% Off on Fruits',
        'imageUrl': 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=300&h=150&fit=crop',
        'discount': 50,
      },
    ];
  }

  List<Map<String, dynamic>> _getMockTodayDeals() {
    return [
      {
        'id': '1',
        'title': 'Flash Sale',
        'imageUrl': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=300&h=150&fit=crop',
        'discount': 30,
      },
    ];
  }

  List<Map<String, dynamic>> _getMockRecommendations() {
    return [
      {
        'id': '1',
        'name': 'Fresh Apples',
        'price': 99.0,
        'imageUrl': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=200&h=200&fit=crop',
        'vendorId': 'tmart',
        'vendorName': 'T-Mart Express',
      },
    ];
  }
} 