import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuukatuu/models/product.dart';
import 'package:tuukatuu/presentation/widgets/home_widgets.dart';
import 'package:tuukatuu/widgets/appbar_location.dart';
import 'package:tuukatuu/routes.dart';
import 'package:tuukatuu/presentation/screens/t_mart_clean_screen.dart';
import 'package:tuukatuu/services/api_service.dart';
import 'package:tuukatuu/services/location_service.dart';
import 'package:tuukatuu/data/services/location_service.dart' as loc_service;
import 'package:tuukatuu/providers/favorites_provider.dart';
import 'package:tuukatuu/providers/auth_provider.dart';
import 'package:tuukatuu/presentation/screens/store_details_screen.dart';

class HomeScreen3 extends StatefulWidget {
  const HomeScreen3({super.key});

  @override
  State<HomeScreen3> createState() => _HomeScreen3State();
}

class _HomeScreen3State extends State<HomeScreen3> with SingleTickerProviderStateMixin {
  List<CategoryModel> _categories = [];
  List<CategoryModel> _categoriesFood = [];
  bool _isLoadingCategories = true;
  bool _isLoadingCategoriesFood = true;
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
  late TabController _tabController;
  late PageController _pageController;
  
  // Cache for API data to prevent refetching
  List<Map<String, dynamic>>? _cachedRestaurants;
  List<Map<String, dynamic>>? _cachedStores;
  bool _isLoadingRestaurants = false;
  bool _isLoadingStores = false;
  String? _lastLocationKey;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchCategoriesFood();
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController(initialPage: 0);
    _tabController.addListener(() {
      // Sync PageView with TabController
      if (_tabController.indexIsChanging && mounted) {
        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    // Using the same categories structure as the main home screen
    final categories = [
      {
        'id': '1',
        'name': 'T-Mart',
        'iconUrl': 'assets/images/logo/logo.png',
      },
      {
        'id': '2',
        'name': 'Grocery',
        'iconUrl': 'assets/images/products/bread.jpg',
      },
      {
        'id': '3',
        'name': 'Fast Food',
        'iconUrl': 'assets/images/products/chocolate.jpg',
      },
      {
        'id': '4',
        'name': 'Pharmacy',
        'iconUrl': 'assets/images/products/bread_2.jpg',
      },
      {
        'id': '5',
        'name': 'Bakery',
        'iconUrl': 'assets/images/products/chocolate_2.jpg',
      },
      {
        'id': '6',
        'name': 'Wine',
        'iconUrl': 'assets/images/products/chocolate_2.jpg',
      },
      // Additional food categories
     
    ];

    setState(() {
      _categories = categories
          .map((category) => CategoryModel.fromJson(category))
          .toList();
      _isLoadingCategories = false;
    });
  }

  Future<void> _fetchCategoriesFood() async {
    // Using the same categories structure as the main home screen
    final categoriesFood = [
     
      // Additional food categories
      {
        'id': '1',
        'name': 'Momos',
        'iconUrl': 'assets/images/products/bread.jpg',
      },
      {
        'id': '2',
        'name': 'Burgers',
        'iconUrl': 'assets/images/products/chocolate.jpg',
      },
      {
        'id': '3',
        'name': 'Pizza',
        'iconUrl': 'assets/images/products/bread_2.jpg',
      },
      {
        'id': '4',
        'name': 'Ice Cream',
        'iconUrl': 'assets/images/products/chocolate_2.jpg',
      },
      {
        'id': '5',
        'name': 'Coffee',
        'iconUrl': 'assets/images/products/bread.jpg',
      },
      {
        'id': '6',
        'name': 'Desserts',
        'iconUrl': 'assets/images/products/chocolate.jpg',
      },
    ];

    setState(() {
      _categoriesFood = categoriesFood
          .map((category) => CategoryModel.fromJson(category))
          .toList();
      _isLoadingCategoriesFood = false;
    });
  }
  Future<void> _refreshData() async {
    // Refresh both categories
    await _fetchCategories();
    await _fetchCategoriesFood();
    
    // Clear cache and refetch location-based data
    _cachedRestaurants = null;
    _cachedStores = null;
    _lastLocationKey = null;
    
    // Force rebuild of featured sections to refresh location-based data
    setState(() {
      // _refreshKeyString = DateTime.now().millisecondsSinceEpoch.toString(); // Removed
    });
  }

  // Check if we need to fetch data based on location change
  bool _shouldFetchLocationData() {
    final currentLat = context.currentLatitude;
    final currentLong = context.currentLongitude;
    
    if (currentLat == null || currentLong == null) return false;
    
    final currentLocationKey = '${currentLat.toStringAsFixed(4)}_${currentLong.toStringAsFixed(4)}';
    
    // Fetch if location changed or no cache exists
    if (_lastLocationKey != currentLocationKey || _cachedRestaurants == null || _cachedStores == null) {
      _lastLocationKey = currentLocationKey;
      return true;
    }
    
    return false;
  }

  // Method to refresh location data
  Future<void> _refreshLocationData() async {
    // Force rebuild of location-dependent sections
    setState(() {
      // _refreshKeyString = DateTime.now().millisecondsSinceEpoch.toString(); // Removed
    });
  }

 
  void _onCategoryTap(String categoryName) {
    // Handle category navigation like in the main home screen
    if (categoryName.toLowerCase() == 't-mart') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const TMartCleanScreen(),
        ),
      );
    } else {
      Navigator.pushNamed(
        context,
        AppRoutes.categoryProducts,
        arguments: {'category': categoryName},
      );
    }
  }

  Widget _buildFeaturedRestaurantsSection() {
    // Check if location is available
    final hasLocation = context.hasDeliveryLocation;
    final latitude = context.currentLatitude;
    final longitude = context.currentLongitude;

    if (!hasLocation || latitude == null || longitude == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_off, color: Colors.orange[600], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Set delivery location to see featured restaurants',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                // Request location permission and get current location
                final position = await loc_service.LocationService.getCurrentLocation();
                if (position != null) {
                  // Refresh the screen to show the new location
                  _refreshLocationData();
                }
              },
              icon: const Icon(Icons.my_location, size: 16),
              label: const Text('Set Current Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Use cached data if available and location hasn't changed
    if (_cachedRestaurants != null && !_shouldFetchLocationData()) {
      return _buildRestaurantsListView(_cachedRestaurants!);
    }

    // Fetch data if not cached or location changed
    if (!_isLoadingRestaurants) {
      _fetchRestaurantsData(latitude, longitude);
    }

    if (_isLoadingRestaurants) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show cached data while loading new data
    if (_cachedRestaurants != null) {
      return _buildRestaurantsListView(_cachedRestaurants!);
    }

    // Show sample data if no cache
    return _buildRestaurantsListView(_getSampleRestaurants());
  }

  Future<void> _fetchRestaurantsData(double lat, double long) async {
    if (_isLoadingRestaurants) return;
    
    setState(() {
      _isLoadingRestaurants = true;
    });

    try {
      final restaurants = await ApiService.getFeaturedStores(lat: lat, long: long);
      setState(() {
        _cachedRestaurants = restaurants;
        _isLoadingRestaurants = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingRestaurants = false;
      });
      // Keep existing cache on error
    }
  }

  List<Map<String, dynamic>> _getSampleRestaurants() {
    return [
      {
        'id': 'sample_restaurant_1',
        'name': 'Pizza Palace',
        'category': 'Restaurant',
        'rating': 4.6,
        'time': '25-35 mins',
        'distance': '3.2 Km',
        'imageUrl': 'assets/images/products/pizza.jpg',
        'description': 'Authentic Italian pizza with fresh ingredients and traditional recipes',
      },
      {
        'id': 'sample_restaurant_2',
        'name': 'Burger House',
        'category': 'Restaurant',
        'rating': 4.4,
        'time': '20-30 mins',
        'distance': '2.1 Km',
        'imageUrl': 'assets/images/products/bread.jpg',
        'description': 'Juicy burgers and crispy fries made with premium beef and fresh vegetables',
      },
      {
        'id': 'sample_restaurant_3',
        'name': 'Sushi Express',
        'category': 'Restaurant',
        'rating': 4.7,
        'time': '30-40 mins',
        'distance': '4.0 Km',
        'imageUrl': 'assets/images/products/chocolate.jpg',
        'description': 'Fresh sushi and Japanese cuisine prepared by expert chefs',
      },
    ];
  }

  Widget _buildRestaurantsListView(List<Map<String, dynamic>> restaurants) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = restaurants[index];
        return Container(
          width: 280,
          margin: EdgeInsets.only(
            right: index == restaurants.length - 1 ? 0 : 16,
          ),
          child: _buildRestaurantCardWithFavorite(restaurant),
        );
      },
    );
  }

  Widget _buildRestaurantCardWithFavorite(Map<String, dynamic> restaurant) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final isFavorited = favoritesProvider.isFavorited(restaurant['id'] ?? '');
        
        return Stack(
          children: [
            GestureDetector(
              onTap: () => _navigateToStoreDetails(restaurant),
              child: RestaurantCardWidget(restaurant),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: isFavorited ? Colors.red : Colors.grey[600],
                    size: 20,
                  ),
                  onPressed: () => _toggleRestaurantFavorite(restaurant),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleRestaurantFavorite(Map<String, dynamic> restaurant) async {
    final authProvider = context.read<AuthProvider>();
    final favoritesProvider = context.read<FavoritesProvider>();
    
    if (!authProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add favorites'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await favoritesProvider.toggleFavorite(
      token: authProvider.jwtToken!,
      itemId: restaurant['id'] ?? '',
      itemType: 'restaurant',
      itemName: restaurant['name'] ?? '',
      itemImage: restaurant['imageUrl'] ?? '',
      rating: restaurant['rating'],
      category: 'Restaurant',
    );

    if (success && mounted) {
      final isFavorited = favoritesProvider.isFavorited(restaurant['id'] ?? '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorited ? 'Added to favorites' : 'Removed from favorites',
          ),
          backgroundColor: isFavorited ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _navigateToStoreDetails(Map<String, dynamic> store) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoreDetailsScreen(store: store),
      ),
    );
  }

  Widget _buildFeaturedStoresSection() {
    final latitude = context.currentLatitude;
    final longitude = context.currentLongitude;

    if (latitude == null || longitude == null) {
      return const Center(child: Text('Location not available'));
    }

    // Use cached data if available and location hasn't changed
    if (_cachedStores != null && !_shouldFetchLocationData()) {
      return _buildStoresListView(_cachedStores!);
    }

    // Fetch data if not cached or location changed
    if (!_isLoadingStores) {
      _fetchStoresData(latitude, longitude);
    }

    if (_isLoadingStores) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show cached data while loading new data
    if (_cachedStores != null) {
      return _buildStoresListView(_cachedStores!);
    }

    // Show sample data if no cache
    return _buildStoresListView(_getSampleStores());
  }

  Future<void> _fetchStoresData(double lat, double long) async {
    if (_isLoadingStores) return;
    
    setState(() {
      _isLoadingStores = true;
    });

    try {
      final stores = await ApiService.getFeaturedStoresForStores(lat: lat, long: long);
      setState(() {
        _cachedStores = stores;
        _isLoadingStores = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStores = false;
      });
      // Keep existing cache on error
    }
  }

  List<Map<String, dynamic>> _getSampleStores() {
    return [
      {
        'id': 'sample_store_1',
        'name': 'Fresh Grocery',
        'category': 'Grocery Store',
        'rating': 4.5,
        'time': '15-25 mins',
        'distance': '1.8 Km',
        'imageUrl': 'assets/images/products/bread.jpg',
        'description': 'Fresh fruits, vegetables, and groceries delivered to your doorstep',
      },
      {
        'id': 'sample_store_2',
        'name': 'Pharmacy Plus',
        'category': 'Pharmacy',
        'rating': 4.3,
        'time': '10-20 mins',
        'distance': '0.9 Km',
        'imageUrl': 'assets/images/products/bread_2.jpg',
        'description': 'Complete pharmacy with medicines, health products, and wellness items',
      },
      {
        'id': 'sample_store_3',
        'name': 'Bakery Corner',
        'category': 'Bakery',
        'rating': 4.6,
        'time': '20-30 mins',
        'distance': '2.5 Km',
        'imageUrl': 'assets/images/products/chocolate_2.jpg',
        'description': 'Freshly baked bread, pastries, and cakes made with quality ingredients',
      },
    ];
  }

  Widget _buildStoresListView(List<Map<String, dynamic>> stores) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final store = stores[index];
        return Container(
          width: 280,
          margin: EdgeInsets.only(
            right: index == stores.length - 1 ? 0 : 16,
          ),
          child: _buildStoreCardWithFavorite(store),
        );
      },
    );
  }

  Widget _buildStoreCardWithFavorite(Map<String, dynamic> store) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final isFavorited = favoritesProvider.isFavorited(store['id'] ?? '');
        
        return GestureDetector(
          onTap: () => _navigateToStoreDetails(store),
          child: Stack(
            children: [
              StoreCardWidget({
                'name': store['name'],
                'category': store['category'] ?? 'Store',
                'rating': store['rating'],
                'time': store['time'],
                'distance': store['distance'],
                'imageUrl': store['imageUrl'],
                'description': store['description'],
                'storeImage': store['storeImage'],
                'storeBanner': store['storeBanner'],
              }),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: isFavorited ? Colors.red : Colors.grey[600],
                      size: 20,
                    ),
                    onPressed: () => _toggleStoreFavorite(store),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleStoreFavorite(Map<String, dynamic> store) async {
    final authProvider = context.read<AuthProvider>();
    final favoritesProvider = context.read<FavoritesProvider>();
    
    if (!authProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add favorites'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await favoritesProvider.toggleFavorite(
      token: authProvider.jwtToken!,
      itemId: store['id'] ?? '',
      itemType: 'store',
      itemName: store['name'] ?? '',
      itemImage: store['imageUrl'] ?? '',
      rating: store['rating'],
      category: store['category'] ?? 'Store',
    );

    if (success && mounted) {
      final isFavorited = favoritesProvider.isFavorited(store['id'] ?? '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorited ? 'Added to favorites' : 'Removed from favorites',
          ),
          backgroundColor: isFavorited ? Colors.green : Colors.red,
        ),
      );
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: RefreshIndicator(
          key: _refreshKey,
          onRefresh: _refreshData,
          color: Colors.orange.shade600,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // AppBar with Location
                const SliverToBoxAdapter(
                  child: AppbarLocation(),
                ),
                
                // Sticky Search Bar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickySectionDelegate(
                    minHeight: 70,
                    maxHeight: 70,
                    child: Container(
                      height: 70,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      color: Colors.white,
                      child: const SearchBarWidget(),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: TMartBannerWidget(),
                ),

                // Categories Section
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Categories",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87),
                        ),
                        const SizedBox(height: 10),
                        _isLoadingCategories
                            ? const Center(child: CircularProgressIndicator())
                            : CategoriesWidget(
                                categories: _categories,
                                onCategoryTap: _onCategoryTap,
                              ),
                        
                        const SizedBox(height: 20),
                        
                        
                        _isLoadingCategoriesFood
                            ? const Center(child: CircularProgressIndicator())
                            : CategoriesWidget(
                                categories: _categoriesFood,
                                onCategoryTap: _onCategoryTap,
                              ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1,vertical: 12),
                    child: PromotionalBannerWidget(),
                  ),
                ),

                // Featured Restaurants Section
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Featured Restaurants",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 260,
                          child: _buildFeaturedRestaurantsSection(),
                        ),
                      ],
                    ),
                  ),
                ),
               // Featured Stores Section
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Featured Stores",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 280,
                          child: _buildFeaturedStoresSection(),
                        ),
                      ],
                    ),
                  ),
                ),

                // // Sticky TabBar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    minHeight: 60,
                    maxHeight: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.grey[700],
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          tabs: const [
                            Tab(text: 'Restaurants'),
                            Tab(text: 'Stores'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Tab content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      height: 600, // Fixed height for tab content
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          if (_tabController.index != index) {
                            _tabController.animateTo(index);
                          }
                        },
                        children: [
                          _buildAllRestaurantsList(),
                          _buildAllStoresList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAllStoresList() {
    return _StoresListWidget();
  }

  Widget _buildAllRestaurantsList() {
    return _RestaurantsListWidget();
  }
}

// Sticky Section Delegate
class _StickySectionDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _StickySectionDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_StickySectionDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

// Widget to preserve restaurants list state
class _RestaurantsListWidget extends StatefulWidget {
  @override
  State<_RestaurantsListWidget> createState() => _RestaurantsListWidgetState();
}

class _RestaurantsListWidgetState extends State<_RestaurantsListWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    // Use cached data from parent widget if available
    final parentState = context.findAncestorStateOfType<_HomeScreen3State>();
    if (parentState != null && parentState._cachedRestaurants != null) {
      return _buildRestaurantsColumn(parentState._cachedRestaurants!);
    }

    // Fallback to API call if no cache
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ApiService.getFeaturedStores(
        lat: context.currentLatitude ?? 0.0,
        long: context.currentLongitude ?? 0.0,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red[400], size: 32),
                const SizedBox(height: 8),
                Text(
                  'Error loading restaurants',
                  style: TextStyle(color: Colors.red[600], fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  'Please try again later',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          );
        }
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return _buildRestaurantsColumn(snapshot.data!);
        }
        return const Center(
          child: Text('No restaurants available'),
        );
      },
    );
  }

  Widget _buildRestaurantsColumn(List<Map<String, dynamic>> restaurants) {
    return ListView.builder(
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = restaurants[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildRestaurantCardWithFavorite(restaurant),
        );
      },
    );
  }

  Widget _buildRestaurantCardWithFavorite(Map<String, dynamic> restaurant) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final isFavorited = favoritesProvider.isFavorited(restaurant['id'] ?? '');
        
        return Stack(
          children: [
            GestureDetector(
              onTap: () => _navigateToStoreDetails(restaurant),
              child: RestaurantCardWidget({
                'name': restaurant['name'],
                'rating': restaurant['rating'],
                'time': restaurant['time'],
                'distance': restaurant['distance'],
                'imageUrl': restaurant['imageUrl'],
                'description': restaurant['description'],
              }),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: isFavorited ? Colors.red : Colors.grey[600],
                    size: 20,
                  ),
                  onPressed: () => _toggleRestaurantFavorite(restaurant),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleRestaurantFavorite(Map<String, dynamic> restaurant) async {
    final authProvider = context.read<AuthProvider>();
    final favoritesProvider = context.read<FavoritesProvider>();
    
    if (!authProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add favorites'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await favoritesProvider.toggleFavorite(
      token: authProvider.jwtToken!,
      itemId: restaurant['id'] ?? '',
      itemType: 'restaurant',
      itemName: restaurant['name'] ?? '',
      itemImage: restaurant['imageUrl'] ?? '',
      rating: restaurant['rating'],
      category: 'Restaurant',
    );

    if (success && mounted) {
      final isFavorited = favoritesProvider.isFavorited(restaurant['id'] ?? '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorited ? 'Added to favorites' : 'Removed from favorites',
          ),
          backgroundColor: isFavorited ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _navigateToStoreDetails(Map<String, dynamic> store) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoreDetailsScreen(store: store),
      ),
    );
  }
}

// Widget to preserve stores list state
class _StoresListWidget extends StatefulWidget {
  @override
  State<_StoresListWidget> createState() => _StoresListWidgetState();
}

class _StoresListWidgetState extends State<_StoresListWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    // Use cached data from parent widget if available
    final parentState = context.findAncestorStateOfType<_HomeScreen3State>();
    if (parentState != null && parentState._cachedStores != null) {
      return _buildStoresColumn(parentState._cachedStores!);
    }

    // Fallback to API call if no cache
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ApiService.getFeaturedStoresForStores(
        lat: context.currentLatitude ?? 0.0,
        long: context.currentLongitude ?? 0.0,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red[400], size: 32),
                const SizedBox(height: 8),
                Text(
                  'Error loading stores',
                  style: TextStyle(color: Colors.red[600], fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  'Please try again later',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          );
        }
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return _buildStoresColumn(snapshot.data!);
        }
        return const Center(
          child: Text('No stores available'),
        );
      },
    );
  }

  Widget _buildStoresColumn(List<Map<String, dynamic>> stores) {
    return ListView.builder(
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final store = stores[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildStoreCardWithFavorite(store),
        );
      },
    );
  }

  Widget _buildStoreCardWithFavorite(Map<String, dynamic> store) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final isFavorited = favoritesProvider.isFavorited(store['id'] ?? '');
        
        return GestureDetector(
          onTap: () => _navigateToStoreDetails(store),
          child: Stack(
            children: [
              StoreCardWidget({
                'name': store['name'],
                'category': store['category'] ?? 'Store',
                'rating': store['rating'],
                'time': store['time'],
                'distance': store['distance'],
                'imageUrl': store['imageUrl'],
                'description': store['description'],
                'storeImage': store['storeImage'],
                'storeBanner': store['storeBanner'],
              }),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: isFavorited ? Colors.red : Colors.grey[600],
                      size: 20,
                    ),
                    onPressed: () => _toggleStoreFavorite(store),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleStoreFavorite(Map<String, dynamic> store) async {
    final authProvider = context.read<AuthProvider>();
    final favoritesProvider = context.read<FavoritesProvider>();
    
    if (!authProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add favorites'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await favoritesProvider.toggleFavorite(
      token: authProvider.jwtToken!,
      itemId: store['id'] ?? '',
      itemType: 'store',
      itemName: store['name'] ?? '',
      itemImage: store['imageUrl'] ?? '',
      rating: store['rating'],
      category: store['category'] ?? 'Store',
    );

    if (success && mounted) {
      final isFavorited = favoritesProvider.isFavorited(store['id'] ?? '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorited ? 'Added to favorites' : 'Removed from favorites',
          ),
          backgroundColor: isFavorited ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _navigateToStoreDetails(Map<String, dynamic> store) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoreDetailsScreen(store: store),
      ),
    );
  }
}
