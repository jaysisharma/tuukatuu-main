// ignore_for_file: curly_braces_in_flow_control_controls

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tuukatuu/presentation/screens/profile/profile_screen.dart';
import 'package:tuukatuu/presentation/screens/search_screen.dart';
import 'package:tuukatuu/presentation/screens/t_mart_screen.dart';
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
import 'package:tuukatuu/widgets/appbar_location.dart';

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
  bool _loadingFeaturedStores = true;
  bool _loadingAllStores = true;
  bool _loadingPopularNearYou = true;
  String? _errorFeaturedStores;
  String? _errorAllStores;
  String? _errorPopularNearYou;

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
    _fetchAllStores();
    _fetchPopularNearYou();
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
            Text(
              'Search for items...',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.amber.shade800, // Sets the background for the top part
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 170.0, // Adjust height as needed
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.amber.shade800,
                  // Remove bottom border here if you want the white container to touch the orange
                  // If you want a clear separation, you can keep a subtle border or shadow on the white container
                ),
                child: Column(
                  children: [
                    AppbarLocation(),
                    _buildSearchBar(context),
                  ],
                ),
              ),
            ),
            pinned: true, // Keeps the app bar visible at the top
            // You might want to set a system overlay style if you have status bar issues
            // systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      // The Divider here adds a gap, consider if you want it or prefer a smooth transition
                      const Divider(height: 24, color: Colors.transparent,), // Made transparent to remove the line
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
              ],
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
                    builder: (_) => TMartScreen(),
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
    if (_errorFeaturedStores != null) return Center(child: Text(_errorFeaturedStores!, style: TextStyle(color: Colors.red)));
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedImage(
                          imageUrl: store['storeImage'] ?? '',
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            store['storeName'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            (store['storeRating'] ?? '').toString(),
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

  Widget _buildPopularNearYou() {
    if (_loadingPopularNearYou) return const Center(child: CircularProgressIndicator());
    if (_errorPopularNearYou != null) return Center(child: Text(_errorPopularNearYou!, style: TextStyle(color: Colors.red)));
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedImage(
                          imageUrl: store['storeImage'] ?? '',
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        store['storeName'] ?? '',
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
                            (store['storeRating'] ?? '').toString(),
                            style: const TextStyle(fontWeight: FontWeight.w500),
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
    if (_errorAllStores != null) return Center(child: Text(_errorAllStores!, style: TextStyle(color: Colors.red)));
    if (_allStores.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'All Stores',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _allStores.length,
          itemBuilder: (context, index) {
            final store = _allStores[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
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
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.storeDetails,
                    arguments: store,
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                      child: CachedImage(
                        imageUrl: store['storeImage'] ?? '',
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store['storeName'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              store['storeDescription'] ?? '',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.orange[700], size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  (store['storeRating'] ?? '').toString(),
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: (store['storeTags'] as List<dynamic>? ?? []).map((tag) {
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
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _fetchBanners() async {
    setState(() => _loadingBanners = true);
    try {
      final data = await ApiService.get('/banners');
      setState(() {
        _banners = data;
        _loadingBanners = false;
      });
    } catch (e) {
      setState(() => _loadingBanners = false);
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
      setState(() => _loadingCoupons = false);
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
      setState(() {
        _loadingFeaturedStores = false;
        _errorFeaturedStores = e.toString();
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
      setState(() {
        _loadingAllStores = false;
        _errorAllStores = e.toString();
      });
    }
  }

  Widget _buildPromotionBannerWithRetry() {
    if (_loadingBanners) return const Center(child: CircularProgressIndicator());
    if (_banners.isEmpty) return Center(
      child: Column(
        children: [
          const Text('No banners available.'),
          TextButton(onPressed: _fetchBanners, child: const Text('Retry')),
        ],
      ),
    );
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
    if (_loadingFeaturedStores) return const Center(child: CircularProgressIndicator());
    if (_errorFeaturedStores != null) return Center(
      child: Column(
        children: [
          Text(_errorFeaturedStores!, style: const TextStyle(color: Colors.red)),
          TextButton(onPressed: _fetchFeaturedStores, child: const Text('Retry')),
        ],
      ),
    );
    if (_featuredStores.isEmpty) return Center(
      child: Column(
        children: [
          const Text('No featured stores.'),
          TextButton(onPressed: _fetchFeaturedStores, child: const Text('Retry')),
        ],
      ),
    );
    return _buildFeaturedStores();
  }

  Widget _buildPopularNearYouWithRetry() {
    return FutureBuilder<List<dynamic>>(
      future: _fetchPopularNearYou(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              children: [
                Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                TextButton(
                  onPressed: () => setState(() {}), 
                  child: const Text('Retry')
                ),
              ],
            ),
          );
        }
        
        final stores = snapshot.data ?? [];
        
        if (stores.isEmpty) {
          return const Center(
            child: Text('No stores found near you'),
          );
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
      return [];
    }
  }

  Widget _buildAllStoresWithRetry() {
    if (_loadingAllStores) return const Center(child: CircularProgressIndicator());
    if (_errorAllStores != null) return Center(
      child: Column(
        children: [
          Text(_errorAllStores!, style: const TextStyle(color: Colors.red)),
          TextButton(onPressed: _fetchAllStores, child: const Text('Retry')),
        ],
      ),
    );
    if (_allStores.isEmpty) return Center(
      child: Column(
        children: [
          const Text('No stores found.'),
          TextButton(onPressed: _fetchAllStores, child: const Text('Retry')),
        ],
      ),
    );
    return _buildAllStores();
  }
}