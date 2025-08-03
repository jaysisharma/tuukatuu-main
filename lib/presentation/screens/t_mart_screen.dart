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

class TMartScreen extends StatefulWidget {
  const TMartScreen({super.key});

  @override
  State<TMartScreen> createState() => _TMartScreenState();
}

class _TMartScreenState extends State<TMartScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  late Timer _timer;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _banners = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _popularProducts = [];
  List<Map<String, dynamic>> _dailyEssentials = [];
  List<Map<String, dynamic>> _deals = [];
  List<Map<String, dynamic>> _recommendations = [];

  // Swiggy color scheme
  static const Color swiggyOrange = Color(0xFFFC8019);
  static const Color swiggyRed = Color(0xFFE23744);
  static const Color swiggyDark = Color(0xFF1C1C1C);
  static const Color swiggyLight = Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
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
        // print(_categories);
      } else {
        _categories = _getMockCategories();
      }

      final popularResponse = await ApiService.get('/tmart/popular');
      if (popularResponse['success']) {
        _popularProducts = List<Map<String, dynamic>>.from(popularResponse['data']);
        print('✅ Loaded ${_popularProducts.length} popular products from API');
      } else {
        print('⚠️ Failed to load popular products from API, using mock data');
        _popularProducts = _getMockPopularProducts();
      }

      final dailyEssentialsResponse = await ApiService.get('/tmart/daily-essentials');
      if (dailyEssentialsResponse['success']) {
        _dailyEssentials = List<Map<String, dynamic>>.from(dailyEssentialsResponse['data']);
      } else {
        _dailyEssentials = _getMockDailyEssentials();
      }

      final dealsResponse = await ApiService.get('/tmart/deals');
      if (dealsResponse['success']) {
        _deals = List<Map<String, dynamic>>.from(dealsResponse['data']);
      } else {
        _deals = _getMockDeals();
      }

      // Load recommendations for "show more products" section
      final recommendationsResponse = await ApiService.get('/tmart/recommendations?limit=12');
      if (recommendationsResponse['success']) {
        _recommendations = List<Map<String, dynamic>>.from(recommendationsResponse['data']);
        print('✅ Loaded ${_recommendations.length} recommendations from API');
      } else {
        print('⚠️ Failed to load recommendations from API, using mock data');
        _recommendations = _getMockRecommendations();
      }
    } catch (e) {
      print('❌ Error loading T-Mart data: $e');
      // Fallback to mock data
      _banners = _getMockBanners();
      _categories = _getMockCategories();
      _popularProducts = _getMockPopularProducts();
      _dailyEssentials = _getMockDailyEssentials();
      _deals = _getMockDeals();
      _recommendations = _getMockRecommendations();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getMockBanners() {
    return [
      {
        'imageUrl': 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&h=400&fit=crop',
        'title': 'Fresh Groceries',
        'subtitle': 'Up to 50% off',
      },
      {
        'imageUrl': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&h=400&fit=crop',
        'title': 'Quick Delivery',
        'subtitle': '10 minutes or free',
      },
      {
        'imageUrl': 'https://images.unsplash.com/photo-1534723452862-4c874018d66d?w=800&h=400&fit=crop',
        'title': 'Premium Quality',
        'subtitle': 'Best products guaranteed',
      },
    ];
  }

  List<Map<String, dynamic>> _getMockCategories() {
    return [
      {'name': 'Fruits & Vegetables', 'iconUrl': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=200&h=200&fit=crop', 'color': Colors.green},
      {'name': 'Dairy & Eggs', 'iconUrl': 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=200&h=200&fit=crop', 'color': Colors.blue},
      {'name': 'Bakery', 'iconUrl': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200&h=200&fit=crop', 'color': Colors.orange},
      {'name': 'Meat & Fish', 'iconUrl': 'https://images.unsplash.com/photo-1516594798947-e65505dbb29d?w=200&h=200&fit=crop', 'color': Colors.red},
      {'name': 'Snacks', 'iconUrl': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=200&h=200&fit=crop', 'color': Colors.purple},
      {'name': 'Beverages', 'iconUrl': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=200&h=200&fit=crop', 'color': Colors.cyan},
      {'name': 'Household', 'iconUrl': 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=200&h=200&fit=crop', 'color': Colors.indigo},
      {'name': 'Personal Care', 'iconUrl': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=200&h=200&fit=crop', 'color': Colors.pink},
    ];
  }

  List<Map<String, dynamic>> _getMockDailyEssentials() {
    return [
      {'_id': 'milk1', 'name': 'Fresh Milk', 'price': 45.0, 'imageUrl': 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&h=400&fit=crop', 'unit': '1L', 'category': 'Dairy & Eggs'},
      {'_id': 'eggs1', 'name': 'Farm Eggs', 'price': 60.0, 'imageUrl': 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400&h=400&fit=crop', 'unit': '12 pcs', 'category': 'Dairy & Eggs'},
      {'_id': 'bread1', 'name': 'Whole Wheat Bread', 'price': 35.0, 'imageUrl': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=400&fit=crop', 'unit': '400g', 'category': 'Bakery'},
      {'_id': 'banana1', 'name': 'Fresh Bananas', 'price': 40.0, 'imageUrl': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=400&fit=crop', 'unit': '1kg', 'category': 'Fruits & Vegetables'},
      {'_id': 'tomato1', 'name': 'Fresh Tomatoes', 'price': 30.0, 'imageUrl': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=400&fit=crop', 'unit': '1kg', 'category': 'Fruits & Vegetables'},
      {'_id': 'onion1', 'name': 'Red Onions', 'price': 25.0, 'imageUrl': 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400&h=400&fit=crop', 'unit': '1kg', 'category': 'Fruits & Vegetables'},
    ];
  }

  List<Map<String, dynamic>> _getMockPopularProducts() {
    return [
      {'_id': 'banana1', 'name': 'Fresh Bananas', 'price': 40.0, 'originalPrice': 50.0, 'discount': 20, 'imageUrl': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=400&fit=crop', 'rating': 4.5, 'unit': '1kg'},
      {'_id': 'juice1', 'name': 'Orange Juice', 'price': 120.0, 'originalPrice': 150.0, 'discount': 20, 'imageUrl': 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400&h=400&fit=crop', 'rating': 4.3, 'unit': '1L'},
      {'_id': 'pasta1', 'name': 'Italian Pasta', 'price': 85.0, 'originalPrice': 100.0, 'discount': 15, 'imageUrl': 'https://images.unsplash.com/photo-1544384951-6db2a7bec5d6?w=400&h=400&fit=crop', 'rating': 4.7, 'unit': '500g'},
      {'_id': 'tomato1', 'name': 'Fresh Tomatoes', 'price': 30.0, 'originalPrice': 40.0, 'discount': 25, 'imageUrl': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=400&fit=crop', 'rating': 4.2, 'unit': '1kg'},
    ];
  }

  List<Map<String, dynamic>> _getMockDeals() {
    return [
      {'id': 'deal1', 'name': 'Buy 1 Get 1 Free', 'description': 'On selected fruits', 'imageUrl': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=400&h=400&fit=crop', 'validUntil': '2024-12-31'},
      {'id': 'deal2', 'name': '₹99 Store', 'description': 'Everything at ₹99', 'imageUrl': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&h=400&fit=crop', 'validUntil': '2024-12-31'},
      {'id': 'deal3', 'name': '50% Off', 'description': 'On dairy products', 'imageUrl': 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&h=400&fit=crop', 'validUntil': '2024-12-31'},
    ];
  }

  List<Map<String, dynamic>> _getMockRecommendations() {
    return [
      {'_id': 'cheese1', 'name': 'Cheddar Cheese', 'price': 200.0, 'imageUrl': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop', 'rating': 4.4, 'unit': '200g'},
      {'_id': 'yogurt1', 'name': 'Greek Yogurt', 'price': 60.0, 'imageUrl': 'https://images.unsplash.com/photo-1547514701-42782101795e?w=400&h=400&fit=crop', 'rating': 4.6, 'unit': '150g'},
      {'_id': 'avocado1', 'name': 'Fresh Avocado', 'price': 150.0, 'imageUrl': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&h=400&fit=crop', 'rating': 4.8, 'unit': '1 pc'},
      {'_id': 'salmon1', 'name': 'Atlantic Salmon', 'price': 800.0, 'imageUrl': 'https://images.unsplash.com/photo-1516594798947-e65505dbb29d?w=400&h=400&fit=crop', 'rating': 4.5, 'unit': '500g'},
      {'_id': 'bread1', 'name': 'Whole Wheat Bread', 'price': 45.0, 'imageUrl': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=400&fit=crop', 'rating': 4.3, 'unit': '400g'},
      {'_id': 'eggs1', 'name': 'Farm Fresh Eggs', 'price': 120.0, 'imageUrl': 'https://images.unsplash.com/photo-1569288063648-850c6c2a2d0e?w=400&h=400&fit=crop', 'rating': 4.7, 'unit': '12 pcs'},
      {'_id': 'milk1', 'name': 'Organic Milk', 'price': 80.0, 'imageUrl': 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&h=400&fit=crop', 'rating': 4.5, 'unit': '1L'},
      {'_id': 'honey1', 'name': 'Pure Honey', 'price': 180.0, 'imageUrl': 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=400&h=400&fit=crop', 'rating': 4.6, 'unit': '500g'},
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
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
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildSearchAndBannerSection(),
                  _buildCategoriesSection(),
                  _buildDailyEssentialsSection(martCartProvider),
                  _buildDealsSection(),
                  _buildPopularProductsSection(martCartProvider, recentlyViewedProvider),
                  _buildRecentlyViewedSection(martCartProvider, recentlyViewedProvider),
                  _buildRecommendedProductsSection(martCartProvider, recentlyViewedProvider),
                  _buildRecommendationsSection(martCartProvider, recentlyViewedProvider),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
      floatingActionButton: _buildFloatingActionButton(martCartProvider),
    );
  }

  PreferredSizeWidget _buildAppBar(MartCartProvider martCartProvider) {
    return AppBar(
      backgroundColor: swiggyOrange,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      title: Column(
        children: [
          Text(
            'T-Mart',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Quick Grocery Delivery',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            // TODO: Navigate to notifications
          },
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pushNamed('/mart-cart');
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
                    print('🔍 Search submitted from T-Mart screen: "$value"'); // Debug log
                    Navigator.pushNamed(context, '/tmart-search', arguments: value.trim());
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            
            if (_banners.isNotEmpty) ...[
              SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _banners.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final banner = _banners[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Image.network(
                              banner['imageUrl'],
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, size: 50),
                              ),
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
                                children: [
                                  Text(
                                    banner['title'] ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    banner['subtitle'] ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_banners.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    height: 8.0,
                    width: _currentPage == index ? 24.0 : 8.0,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    // Categories are already limited to 8 from the API
    final featuredCategories = _categories;
    print(featuredCategories);
    if (featuredCategories.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TMartSectionHeader(
            title: "Shop by Category",
            icon: Icons.category,
            onViewAll: () {
              Navigator.pushNamed(context, '/tmart-categories');
            },
          ),
          const SizedBox(height: 16),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: featuredCategories.length,
            itemBuilder: (context, index) {
              final category = featuredCategories[index];
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
          if (featuredCategories.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${featuredCategories.length} categories available',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDailyEssentialsSection(MartCartProvider martCartProvider) {
    return DailyEssentialsSection(martCartProvider: martCartProvider);
  }

  Widget _buildDealsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TMartSectionHeader(
            title: "Today's Deals",
            icon: Icons.local_offer,
            onViewAll: () {
              // TODO: Navigate to deals page
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _deals.length,
              itemBuilder: (context, index) {
                final deal = _deals[index];
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16),
                  child: TMartDealCard(deal: deal),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(MartCartProvider martCartProvider, RecentlyViewedProvider recentlyViewedProvider) {
    if (_recommendations.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TMartSectionHeader(
            title: "More Products You'll Love",
            icon: Icons.recommend,
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
            itemCount: _recommendations.length,
            itemBuilder: (context, index) {
              final item = _recommendations[index];
              final String productId = item['_id'] ?? item['id'] ?? '';
              final int quantity = martCartProvider.getItemQuantity(productId);
              
              return GestureDetector(
                onTap: () {
                  // Add to recently viewed when product is tapped
                  recentlyViewedProvider.addToRecentlyViewed(item);
                  
                  // Navigate to product detail
                  Navigator.pushNamed(
                    context,
                    '/product-detail',
                    arguments: {
                      'product': item,
                    },
                  );
                },
                child: TMartProductCard(
                  item: item,
                  quantity: quantity,
                  onAdd: () {
                    martCartProvider.addItem(item);
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

  Widget _buildPopularProductsSection(MartCartProvider martCartProvider, RecentlyViewedProvider recentlyViewedProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TMartSectionHeader(
            title: "Popular Products",
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
              final String productId = item['_id'] ?? item['id'];
              final int quantity = martCartProvider.getItemQuantity(productId);
              
              return GestureDetector(
                onTap: () {
                  // Add to recently viewed when product is tapped
                  recentlyViewedProvider.addToRecentlyViewed(item);
                  
                  // Navigate to product detail
                  Navigator.pushNamed(
                    context,
                    '/product-detail',
                    arguments: {
                      'product': item,
                    },
                  );
                },
                child: TMartProductCard(
                item: item,
                quantity: quantity,
                onAdd: () {
                  martCartProvider.addItem(item);
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TMartSectionHeader(
            title: "Recently Viewed",
            icon: Icons.history,
            onViewAll: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RecentlyViewedPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: recentlyViewedProvider.itemCount == 0
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'No recently viewed products',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recentlyViewedProvider.getRecentlyViewed(limit: 10).length,
                    itemBuilder: (context, index) {
                      final item = recentlyViewedProvider.getRecentlyViewed(limit: 10)[index];
                      final String productId = item['_id'] ?? item['id'];
                      final int quantity = martCartProvider.getItemQuantity(productId);
                
                return GestureDetector(
                  onTap: () {
                    // Add to recently viewed when product is tapped
                    recentlyViewedProvider.addToRecentlyViewed(item);
                    
                    // Navigate to product detail
                    Navigator.pushNamed(
                      context,
                      '/product-detail',
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
                        martCartProvider.addItem(item);
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
        ],
      ),
    );
  }

  Widget _buildRecommendedProductsSection(MartCartProvider martCartProvider, RecentlyViewedProvider recentlyViewedProvider) {
    // Get some products from popular products as recommendations
    final recommendedProducts = _popularProducts.take(6).toList();
    
    if (recommendedProducts.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TMartSectionHeader(
            title: "Recommended for You",
            icon: Icons.recommend,
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
            itemCount: recommendedProducts.length,
            itemBuilder: (context, index) {
              final item = recommendedProducts[index];
              final String productId = item['_id'] ?? item['id'] ?? '';
              final int quantity = martCartProvider.getItemQuantity(productId);
              
              return GestureDetector(
                onTap: () {
                  // Add to recently viewed when product is tapped
                  recentlyViewedProvider.addToRecentlyViewed(item);
                  
                  // Navigate to product detail
                  Navigator.pushNamed(
                    context,
                    '/product-detail',
                    arguments: {
                      'product': item,
                    },
                  );
                },
                child: TMartProductCard(
                  item: item,
                  quantity: quantity,
                  onAdd: () {
                    martCartProvider.addItem(item);
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

  Widget _buildFloatingActionButton(MartCartProvider martCartProvider) {
    if (martCartProvider.itemCount == 0) return const SizedBox.shrink();
    
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const TMartCartScreen(),
          ),
        );
      },
      backgroundColor: swiggyOrange,
      icon: const Icon(Icons.shopping_cart, color: Colors.white),
      label: Text(
        'View Cart (${martCartProvider.itemCount})',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}





