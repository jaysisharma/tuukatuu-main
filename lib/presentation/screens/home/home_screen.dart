// ignore_for_file: curly_braces_in_flow_control_controls

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tuukatuu/presentation/screens/profile/profile_screen.dart';
import 'package:tuukatuu/presentation/screens/search_screen.dart';
import 'package:tuukatuu/presentation/screens/t_mart_clean_screen.dart';
import 'package:tuukatuu/presentation/widgets/cached_image.dart';
import 'package:tuukatuu/routes.dart';
import 'package:tuukatuu/screens/category_products_screen.dart';
import 'package:tuukatuu/services/location_service.dart';
import 'package:tuukatuu/services/api_service.dart';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tuukatuu/presentation/widgets/appbar_location.dart';
import 'dart:convert'; // Added for json.decode
import 'package:http/http.dart' as http; // Added for http requests
import 'package:provider/provider.dart';
import 'package:tuukatuu/providers/auth_provider.dart';
// import 'package:tuukatuu/providers/favorites_provider.dart';
import 'package:tuukatuu/widgets/appbar_location.dart';
import 'package:tuukatuu/presentation/widgets/home_skeleton_loader.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentBannerIndex = 0;
  final PageController _bannerController = PageController();
  String _currentAddress = 'Fetching location...';
  Position? _currentPosition;
  bool _isPermissionDeniedForever = false;

  List<dynamic> _banners = [];
  List<dynamic> _coupons = [];
  bool _loadingBanners = true;
  bool _loadingCoupons = true;

  List<dynamic> _featuredStores = [];
  List<dynamic> _allStores = [];
  List<dynamic> _popularNearYou = [];
  List<dynamic> _featuredRestaurants = []; // Add featured restaurants
  bool _loadingFeaturedStores = true;
  bool _loadingAllStores = true;
  bool _loadingPopularNearYou = true;
  bool _loadingFeaturedRestaurants = true; // Add loading state for restaurants
  String? _errorFeaturedStores;
  String? _errorAllStores;
  String? _errorPopularNearYou;
  String? _errorFeaturedRestaurants; // Add error state for restaurants
  
  // Filter state
  String _currentFilter = 'all'; // 'all', 'stores', 'restaurants'

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchBanners();
    _fetchCoupons();
    _fetchFeaturedStores();
    _fetchFeaturedRestaurants(); // Add featured restaurants fetch
    _fetchAllStores();
    _fetchPopularNearYou();
    
    // Force show content after 5 seconds even if some API calls are still loading
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isLoading()) {
        print('🔍 HomeScreen: Force showing content after timeout');
        setState(() {
          _loadingBanners = false;
          _loadingCoupons = false;
          _loadingFeaturedStores = false;
          _loadingAllStores = false;
          _loadingPopularNearYou = false;
          _loadingFeaturedRestaurants = false;
        });
      }
    });
  }

  bool _isLoading() {
    final isLoading = _loadingBanners || _loadingCoupons || _loadingFeaturedStores || 
           _loadingAllStores || _loadingPopularNearYou || _loadingFeaturedRestaurants;
    print('🔍 HomeScreen: Loading states - Banners: $_loadingBanners, Coupons: $_loadingCoupons, FeaturedStores: $_loadingFeaturedStores, AllStores: $_loadingAllStores, PopularNearYou: $_loadingPopularNearYou, FeaturedRestaurants: $_loadingFeaturedRestaurants');
    print('🔍 HomeScreen: Is loading: $isLoading');
    return isLoading;
  }

  Future<void> _refreshData() async {
    print('🔄 HomeScreen: Refreshing data...');
    
    try {
      // Reset all loading states
      setState(() {
        _loadingBanners = true;
        _loadingCoupons = true;
        _loadingFeaturedStores = true;
        _loadingAllStores = true;
        _loadingPopularNearYou = true;
        _loadingFeaturedRestaurants = true;
      });

      // Fetch all data concurrently with a small delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));
      await Future.wait([
        _fetchBanners(),
        _fetchCoupons(),
        _fetchFeaturedStores(),
        _fetchAllStores(),
        _fetchPopularNearYou(),
        _fetchFeaturedRestaurants(),
      ]);

      print('✅ HomeScreen: Data refresh completed');
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Home screen refreshed successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('❌ HomeScreen: Error refreshing data: $e');
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _currentAddress = 'Fetching location...';
      _isPermissionDeniedForever = false;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _currentAddress = 'Location services are disabled');
        return;
      }

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final newPermission = await Geolocator.requestPermission();
        if (newPermission == LocationPermission.denied) {
          setState(() => _currentAddress = 'Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentAddress = 'Location permissions are permanently denied';
          _isPermissionDeniedForever = true;
        });
        return;
      }

      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        setState(() => _currentPosition = position);
        final address = await LocationService.getAddressFromCoordinates(position);
        setState(() => _currentAddress = address);
      } else {
        setState(() => _currentAddress = 'Unable to get location');
      }
    } catch (e) {
      setState(() => _currentAddress = 'Error getting location');
    }
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search for items...',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 16,
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Sticky App Bar with Location and Search
          Container(
            color: Colors.amber.shade800,
            child: Column(
              children: [
                const AppbarLocation(),
                _buildSearchBar(context),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: _isLoading() 
                ? const HomeSkeletonLoader()
                : RefreshIndicator(
                    onRefresh: _refreshData,
                    color: Colors.amber.shade800,
                    backgroundColor: Colors.white,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          const Divider(height: 24, color: Colors.transparent,),
                          _buildTMartExpressInfo(),
                          _buildCategories(),
                          _buildPromotionBannerWithRetry(),
                          const SizedBox(height: 8),
                          _buildFeaturedStoresWithRetry(),
                          const Divider(height: 24),
                          // _buildPopularNearYouWithRetry(),
                          // const Divider(height: 24),
                          _buildQuickEssentials(),
                          const Divider(height: 24),
                          _buildAllStoresWithRetry(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTMartExpressInfo() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.tMart,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.delivery_dining, color: Colors.orange[700], size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'T-Mart Express Delivery',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Get your essentials delivered in 15-30 minutes',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.orange[700], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'icon': Icons.local_mall, 'label': 'T-Mart', 'color': Colors.blue, 'route': 't-mart'},
      {'icon': Icons.wine_bar, 'label': 'wine', 'color': Colors.purple, 'route': 'category'},
      {'icon': Icons.fastfood, 'label': 'Fast Food', 'color': Colors.orange, 'route': 'category'},
      {'icon': Icons.local_pharmacy, 'label': 'Pharmacy', 'color': Colors.green, 'route': 'category'},
      {'icon': Icons.cake, 'label': 'Bakery', 'color': Colors.pink, 'route': 'category'},
      {'icon': Icons.local_grocery_store, 'label': 'Grocery', 'color': Colors.teal, 'route': 'category'},
    ];

    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              if (category['route'] == 't-mart') {
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
                  arguments: {'category': category['label'] as String},
                );
              }
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: (category['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      category['icon'] as IconData,
                      color: category['color'] as Color,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category['label'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromotionBanner() {
    if (_loadingBanners) return const Center(child: CircularProgressIndicator());
    if (_banners.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _bannerController,
        itemCount: _banners.length,
        onPageChanged: (index) {
          setState(() {
            _currentBannerIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final banner = _banners[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedImage(
                    imageUrl: banner['imageUrl'],
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  left: 20,
                  bottom: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        banner['title'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (banner['subtitle'] != null)
                        Text(
                          banner['subtitle'],
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCoupons() {
    if (_loadingCoupons) return const Center(child: CircularProgressIndicator());
    if (_coupons.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _coupons.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final c = _coupons[i];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c['code'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${c['discount']}% OFF', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                if (c['description'] != null) Text(c['description'], style: const TextStyle(fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedStores() {
    if (_loadingFeaturedStores) return const Center(child: CircularProgressIndicator());
    if (_errorFeaturedStores != null) return Center(child: Text(_errorFeaturedStores!, style: const TextStyle(color: Colors.red)));
    if (_featuredStores.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Featured Stores',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _featuredStores.length,
            itemBuilder: (context, index) {
              final store = _featuredStores[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.storeDetails,
                      arguments: store,
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedImage(
                              imageUrl: store['storeImage'] ?? '',
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Store type badge
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                store['vendorType'] == 'restaurant' ? '🍽️' : '🛒',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store['storeName'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              store['vendorSubType'] ?? store['vendorType'] ?? 'Store',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            (store['storeRating'] ?? '0.0').toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${store['storeReviews'] ?? '0'})',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularNearYou() {
    if (_loadingPopularNearYou) return const Center(child: CircularProgressIndicator());
    if (_errorPopularNearYou != null) return Center(child: Text(_errorPopularNearYou!, style: const TextStyle(color: Colors.red)));
    if (_popularNearYou.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Popular Near You',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _popularNearYou.length,
            itemBuilder: (context, index) {
              final store = _popularNearYou[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.storeDetails,
                      arguments: store,
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedImage(
                              imageUrl: store['storeImage'] ?? '',
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Store type badge
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                store['vendorType'] == 'restaurant' ? '🍽️' : '🛒',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store['storeName'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              store['vendorSubType'] ?? store['vendorType'] ?? 'Store',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            (store['storeRating'] ?? '0.0').toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _getDistanceText(store),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getDistanceText(dynamic store) {
    return LocationService.calculateDistanceText(_currentPosition, store['storeCoordinates']);
  }

  Widget _buildQuickEssentials() {
    final essentials = [
      {
        'name': 'Fresh Fruits',
        'image': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf',
        'category': 'Fresh Fruits',
      },
      {
        'name': 'Vegetables',
        'image': 'https://images.unsplash.com/photo-1597362925123-77861d3fbac7',
        'category': 'Vegetables',
      },
      {
        'name': 'Dairy Products',
        'image': 'https://images.unsplash.com/photo-1628088062854-d1870b4553da',
        'category': 'Dairy',
      },
      {
        'name': 'Bread & Eggs',
        'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff',
        'category': 'Bakery',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Quick Essentials',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: essentials.length,
            itemBuilder: (context, index) {
              final item = essentials[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.categoryProducts,
                    arguments: {'category': item['category'] as String},
                  );
                },
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedImage(
                          imageUrl: item['image']!,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['name']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap to explore',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAllStores() {
    if (_loadingAllStores) return const Center(child: CircularProgressIndicator());
    if (_errorAllStores != null) return Center(child: Text(_errorAllStores!, style: const TextStyle(color: Colors.red)));
    if (_allStores.isEmpty) return const SizedBox.shrink();
    
    // Filter stores based on current filter
    List<dynamic> filteredStores = _allStores;
    if (_currentFilter == 'stores') {
      filteredStores = _allStores.where((store) => store['type'] == 'store').toList();
    } else if (_currentFilter == 'restaurants') {
      filteredStores = _allStores.where((store) => store['type'] == 'restaurant').toList();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Places',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
            ],
          ),
        ),
        
        // Filter Tabs
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _buildFilterTab('all', 'All Places'),
              _buildFilterTab('restaurants', 'Restaurants'),
              _buildFilterTab('stores', 'Stores'),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Stores List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredStores.length,
          itemBuilder: (context, index) {
            final store = filteredStores[index];
            return _buildEnhancedStoreCard(store);
          },
        ),
      ],
    );
  }

  Widget _buildFilterTab(String filter, String label) {
    final isSelected = _currentFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentFilter = filter;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedStoreCard(dynamic store) {
    final images = store['images'] as List<dynamic>? ?? [store['storeImage'] ?? ''];
    final rating = (store['storeRating'] ?? 0).toDouble();
    final distance = _getDistanceText(store);
    final deliveryTime = store['deliveryTime'] ?? '30-45 min';
    final itemType = store['type'] ?? 'store';
    final isFavorited = false; // TODO: Implement favorites functionality
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.storeDetails,
            arguments: store,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  child: PageView.builder(
                    itemCount: images.length,
                    itemBuilder: (context, imageIndex) {
                      return ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: CachedImage(
                          imageUrl: images[imageIndex],
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
                
                // Favorite Heart Icon
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () async {
                      // TODO: Implement favorites functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${isFavorited ? 'Removed from' : 'Added to'} favorites')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorited ? Icons.favorite : Icons.favorite_border,
                        color: isFavorited ? Colors.red : Colors.grey[600],
                        size: 20,
                      ),
                    ),
                  ),
                ),
                
                // Image Indicator
                if (images.length > 1)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${images.length} photos',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // Store Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          store['storeName'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          store['type'] == 'restaurant' ? 'Restaurant' : 'Store',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    store['storeDescription'] ?? '',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Rating, Distance, and Time
                  Row(
                    children: [
                      // Rating
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Distance
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            distance,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Delivery Time
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.grey[600], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            deliveryTime,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Tags
                  if (store['storeTags'] != null)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (store['storeTags'] as List<dynamic>).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag.toString(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchBanners() async {
    print('🔍 HomeScreen: Fetching banners...');
    setState(() => _loadingBanners = true);
    try {
      final data = await ApiService.get('/banners');
      print('🔍 HomeScreen: Banners fetched successfully: ${data.length} banners');
      setState(() {
        _banners = data;
        _loadingBanners = false;
      });
    } catch (e) {
      print('❌ HomeScreen: Error fetching banners: $e');
      // Use mock data if API fails
      setState(() {
        _banners = [
          {
            'imageUrl': 'https://via.placeholder.com/400x200/FF6B35/FFFFFF?text=T-Mart+Express',
            'title': 'T-Mart Express',
            'subtitle': 'Get groceries delivered in 15-30 minutes'
          },
          {
            'imageUrl': 'https://via.placeholder.com/400x200/4CAF50/FFFFFF?text=Fresh+Groceries',
            'title': 'Fresh Groceries',
            'subtitle': 'Quality products at best prices'
          }
        ];
        _loadingBanners = false;
      });
    }
  }

  Future<void> _fetchCoupons() async {
    setState(() => _loadingCoupons = true);
    try {
      final data = await ApiService.get('/coupons');
      setState(() {
        _coupons = data;
        _loadingCoupons = false;
      });
    } catch (e) {
      print('❌ HomeScreen: Error fetching coupons: $e');
      // Use mock data if API fails
      setState(() {
        _coupons = [
          {
            'code': 'WELCOME20',
            'discount': 20,
            'description': 'First order discount'
          },
          {
            'code': 'FRESH10',
            'discount': 10,
            'description': 'Fresh groceries discount'
          }
        ];
        _loadingCoupons = false;
      });
    }
  }

  Future<void> _fetchFeaturedStores() async {
    setState(() {
      _loadingFeaturedStores = true;
      _errorFeaturedStores = null;
    });
    try {
      final data = await ApiService.get('/auth/featured-vendors');
      setState(() {
        _featuredStores = data;
        _loadingFeaturedStores = false;
      });
    } catch (e) {
      print('❌ HomeScreen: Error fetching featured stores: $e');
      // Use mock data if API fails
      setState(() {
        _featuredStores = [
          {
            'name': 'Fresh Grocery Store',
            'image': 'https://via.placeholder.com/150x150/4CAF50/FFFFFF?text=Grocery',
            'rating': 4.5,
            'deliveryTime': '15-30 min',
            'deliveryFee': 'Free'
          },
          {
            'name': 'Quick Mart',
            'image': 'https://via.placeholder.com/150x150/FF9800/FFFFFF?text=Quick',
            'rating': 4.2,
            'deliveryTime': '20-35 min',
            'deliveryFee': '₹20'
          }
        ];
        _loadingFeaturedStores = false;
      });
    }
  }

  Future<void> _fetchFeaturedRestaurants() async {
    setState(() {
      _loadingFeaturedRestaurants = true;
      _errorFeaturedRestaurants = null;
    });
    try {
      final data = await ApiService.get('/auth/featured-restaurants');
      setState(() {
        _featuredRestaurants = data;
        _loadingFeaturedRestaurants = false;
      });
    } catch (e) {
      print('❌ HomeScreen: Error fetching featured restaurants: $e');
      // Use mock data if API fails
      setState(() {
        _featuredRestaurants = [
          {
            'name': 'Pizza Palace',
            'image': 'https://via.placeholder.com/150x150/FF5722/FFFFFF?text=Pizza',
            'rating': 4.6,
            'deliveryTime': '30-45 min',
            'deliveryFee': '₹40'
          },
          {
            'name': 'Burger House',
            'image': 'https://via.placeholder.com/150x150/FF9800/FFFFFF?text=Burger',
            'rating': 4.3,
            'deliveryTime': '25-35 min',
            'deliveryFee': '₹25'
          }
        ];
        _loadingFeaturedRestaurants = false;
      });
    }
  }

  Future<void> _fetchAllStores() async {
    setState(() {
      _loadingAllStores = true;
      _errorAllStores = null;
    });
    try {
      final data = await ApiService.get('/auth/vendors');
      setState(() {
        _allStores = data;
        _loadingAllStores = false;
      });
    } catch (e) {
      print('❌ HomeScreen: Error fetching all stores: $e');
      // Use mock data if API fails
      setState(() {
        _allStores = [
          {
            'name': 'Super Market',
            'image': 'https://via.placeholder.com/150x150/2196F3/FFFFFF?text=Super',
            'rating': 4.3,
            'deliveryTime': '25-40 min',
            'deliveryFee': '₹30'
          },
          {
            'name': 'Local Grocery',
            'image': 'https://via.placeholder.com/150x150/9C27B0/FFFFFF?text=Local',
            'rating': 4.1,
            'deliveryTime': '15-25 min',
            'deliveryFee': '₹15'
          },
          {
            'name': 'Express Mart',
            'image': 'https://via.placeholder.com/150x150/FF5722/FFFFFF?text=Express',
            'rating': 4.4,
            'deliveryTime': '10-20 min',
            'deliveryFee': 'Free'
          }
        ];
        _loadingAllStores = false;
      });
    }
  }

  Widget _buildPromotionBannerWithRetry() {
    if (_loadingBanners) return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
    if (_banners.isEmpty) return const SizedBox.shrink();
    return _buildPromotionBanner();
  }

  Widget _buildCouponsWithRetry() {
    if (_loadingCoupons) return const Center(child: CircularProgressIndicator());
    if (_coupons.isEmpty) return Center(
      child: Column(
        children: [
          const Text('No coupons available.'),
          TextButton(onPressed: _fetchCoupons, child: const Text('Retry')),
        ],
      ),
    );
    return _buildCoupons();
  }

  Widget _buildFeaturedStoresWithRetry() {
    if (_loadingFeaturedStores) return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
    if (_errorFeaturedStores != null) return const SizedBox.shrink();
    if (_featuredStores.isEmpty) return const SizedBox.shrink();
    return _buildFeaturedStores();
  }

  Widget _buildFeaturedRestaurantsWithRetry() {
    if (_loadingFeaturedRestaurants) return const Center(child: CircularProgressIndicator());
    if (_errorFeaturedRestaurants != null) return Center(
      child: Column(
        children: [
          Text(_errorFeaturedRestaurants!, style: const TextStyle(color: Colors.red)),
          TextButton(onPressed: _fetchFeaturedRestaurants, child: const Text('Retry')),
        ],
      ),
    );
    if (_featuredRestaurants.isEmpty) return Center(
      child: Column(
        children: [
          const Text('No featured restaurants.'),
          TextButton(onPressed: _fetchFeaturedRestaurants, child: const Text('Retry')),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Featured Restaurants',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _featuredRestaurants.length,
            itemBuilder: (context, index) {
              final restaurant = _featuredRestaurants[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.storeDetails,
                      arguments: restaurant,
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedImage(
                          imageUrl: restaurant['restaurantImage'] ?? '',
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        restaurant['restaurantName'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            (restaurant['restaurantRating'] ?? '').toString(),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularNearYouWithRetry() {
    return FutureBuilder<List<dynamic>>(
      future: _fetchPopularNearYou(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );
        }
        
        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }
        
        final stores = snapshot.data ?? [];
        
        if (stores.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return _buildPopularNearYou();
      },
    );
  }

  Future<List<dynamic>> _fetchPopularNearYou() async {
    try {
      // Try to get nearby vendors first
      if (_currentPosition != null) {
        try {
          print('🔍 Fetching nearby vendors with location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
          final nearbyStores = await ApiService.getNearbyVendors(
            latitude: _currentPosition!.latitude,
            longitude: _currentPosition!.longitude,
            radius: 10.0, // 10km radius
          );
          if (nearbyStores.isNotEmpty) {
            print('✅ Found ${nearbyStores.length} nearby stores');
            return nearbyStores;
          } else {
            print('⚠️ No nearby stores found, using featured');
          }
        } catch (e) {
          print('⚠️ Nearby vendors failed, using featured: $e');
        }
      } else {
        print('⚠️ No location available, using featured stores');
      }
      
      // Fallback to featured vendors
      print('🔍 Fetching featured vendors');
      final featuredStores = await ApiService.get('/auth/featured-vendors');
      final stores = featuredStores is List ? featuredStores : [];
      print('✅ Found ${stores.length} featured stores');
      return stores;
    } catch (e) {
      print('❌ Error fetching popular near you: $e');
      // Return mock data if API fails
      return [
        {
          'name': 'Nearby Grocery',
          'image': 'https://via.placeholder.com/150x150/4CAF50/FFFFFF?text=Nearby',
          'rating': 4.2,
          'deliveryTime': '10-15 min',
          'deliveryFee': '₹10'
        },
        {
          'name': 'Quick Stop',
          'image': 'https://via.placeholder.com/150x150/FF9800/FFFFFF?text=Quick',
          'rating': 4.0,
          'deliveryTime': '15-20 min',
          'deliveryFee': '₹15'
        }
      ];
    }
  }

  Widget _buildAllStoresWithRetry() {
    if (_loadingAllStores) return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
    if (_errorAllStores != null) return const SizedBox.shrink();
    if (_allStores.isEmpty) return const SizedBox.shrink();
    return _buildAllStores();
  }
}