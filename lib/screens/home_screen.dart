import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tuukatuu/screens/cart_screen.dart';
import 'package:tuukatuu/screens/location_screen.dart';
import 'package:tuukatuu/screens/orders_screen.dart';
import 'package:tuukatuu/screens/profile_screen.dart';
import 'package:tuukatuu/services/location_service.dart';
import '../routes.dart';
import 't_mart_screen.dart';
import 'store_details_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'search_screen.dart';

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

  final List<Map<String, dynamic>> _promotionalBanners = [
    {
      'title': 'Get 20% OFF',
      'subtitle': 'On your first T-Mart order',
      'tag': 'Limited Time Offer',
      'gradient': [Colors.orange[400]!, Colors.deepOrange[600]!],
      'icon': Icons.shopping_bag,
      'route': AppRoutes.tMart,
    },
    {
      'title': 'Free Delivery',
      'subtitle': 'On orders above \$30',
      'tag': 'Today Only',
      'gradient': [Colors.purple[400]!, Colors.deepPurple[600]!],
      'icon': Icons.delivery_dining,
      'route': AppRoutes.tMart,
    },
    {
      'title': '15% Cashback',
      'subtitle': 'On all grocery items',
      'tag': 'Weekend Special',
      'gradient': [Colors.blue[400]!, Colors.indigo[600]!],
      'icon': Icons.local_grocery_store,
      'route': AppRoutes.tMart,
    },
  ];

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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

  void _openLocationSettings() async {
    if (await openAppSettings()) {
      setState(() => _currentAddress = 'Please enable location permission in settings');
    } else {
      setState(() => _currentAddress = 'Unable to open settings');
    }
  }

  Future<void> _openLocationScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationScreen()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _currentAddress = result['address'] as String;
        _currentPosition = result['position'] as Position;
      });
    }
  }

  void _openProfileScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _openLocationScreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery to',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey,
                  fontSize: 12,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _currentAddress,
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_isPermissionDeniedForever)
                    TextButton(
                      onPressed: _openLocationSettings,
                      child: Text(
                        'Open Settings',
                        style: TextStyle(
                          color: isDark ? Colors.orange[300] : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          GestureDetector(
            onTap: _openProfileScreen,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                child: Icon(
                  Icons.person,
                  color: isDark ? Colors.grey[400] : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(context),
              _buildTMartExpressInfo(),
              _buildCategories(),
              _buildPromotionBanner(),
              _buildFeaturedStores(),
              _buildPopularNearYou(),
              _buildQuickEssentials(),
              _buildAllStores(),
            ],
          ),
        ),
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
      {'icon': Icons.local_mall, 'label': 'T-Mart', 'color': Colors.blue},
      {'icon': Icons.wine_bar, 'label': 'Wine & Beer', 'color': Colors.purple},
      {'icon': Icons.fastfood, 'label': 'Fast Food', 'color': Colors.orange},
      {'icon': Icons.local_pharmacy, 'label': 'Pharmacy', 'color': Colors.green},
      {'icon': Icons.cake, 'label': 'Bakery', 'color': Colors.pink},
      {'icon': Icons.local_grocery_store, 'label': 'Grocery', 'color': Colors.teal},
    ];

    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Container(
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
          );
        },
      ),
    );
  }

  Widget _buildPromotionBanner() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _promotionalBanners.length,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final banner = _promotionalBanners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: banner['gradient'],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: banner['gradient'][0].withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Transform.rotate(
                        angle: -0.2,
                        child: Icon(
                          banner['icon'],
                          size: 150,
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(11.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              banner['tag'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            banner['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            banner['subtitle'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                banner['route'],
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                                    'Shop Now',
                                    style: TextStyle(
                                      color: banner['gradient'][1],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 16,
                                    color: banner['gradient'][1],
                                  ),
                                ],
                              ),
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
        ),
        const SizedBox(height: 12),
        Center(
          child: SmoothPageIndicator(
            controller: _bannerController,
            count: _promotionalBanners.length,
            effect: ExpandingDotsEffect(
              dotHeight: 8,
              dotWidth: 8,
              spacing: 8,
              expansionFactor: 3,
              activeDotColor: theme.colorScheme.primary,
              dotColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedStores() {
    final stores = [
      {
        'name': 'T-Mart Express',
        'image': 'https://images.unsplash.com/photo-1604719312566-8912e9227c6a',
        'rating': '4.8',
        'time': '15-20 min',
      },
      {
        'name': 'Wine Gallery',
        'image': 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
        'rating': '4.5',
        'time': '20-25 min',
      },
      {
        'name': 'Sweet Bakery',
        'image': 'https://images.unsplash.com/photo-1517433670267-08bbd4be890f',
        'rating': '4.7',
        'time': '25-30 min',
      },
    ];

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
            itemCount: stores.length,
            itemBuilder: (context, index) {
              final store = stores[index];
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
                        child: Image.network(
                          store['image']!,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        store['name']!,
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
                            store['rating']!,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.access_time, color: Colors.grey[600], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            store['time']!,
                            style: TextStyle(color: Colors.grey[600]),
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
    final stores = [
      {
        'name': 'Local Grocery',
        'image': 'https://images.unsplash.com/photo-1578916171728-46686eac8d58',
        'description': 'Groceries, Fresh Produce, Daily Essentials',
        'rating': '4.6',
        'time': '10-15 min',
      },
      {
        'name': 'City Pharmacy',
        'image': 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88',
        'description': 'Medicines, Healthcare Products',
        'rating': '4.9',
        'time': '15-20 min',
      },
      {
        'name': 'Sweet Tooth Bakery',
        'image': 'https://images.unsplash.com/photo-1517433670267-08bbd4be890f',
        'description': 'Fresh Baked Goods, Cakes, Pastries',
        'rating': '4.7',
        'time': '20-25 min',
      },
      {
        'name': 'Fresh Fruits Market',
        'image': 'https://images.unsplash.com/photo-1542838132-92c53300491e',
        'description': 'Fresh Fruits, Seasonal Produce',
        'rating': '4.5',
        'time': '15-20 min',
      },
      {
        'name': 'Organic Store',
        'image': 'https://images.unsplash.com/photo-1488459716781-31db52582fe9',
        'description': 'Organic Products, Health Foods',
        'rating': '4.8',
        'time': '25-30 min',
      },
      {
        'name': 'Quick Mart',
        'image': 'https://images.unsplash.com/photo-1604719312566-8912e9227c6a',
        'description': 'Convenience Store, Quick Essentials',
        'rating': '4.4',
        'time': '10-15 min',
      },
      {
        'name': 'Wine & Spirits',
        'image': 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
        'description': 'Premium Wines, Spirits, Beverages',
        'rating': '4.7',
        'time': '20-25 min',
      },
      {
        'name': 'Pet Store',
        'image': 'https://images.unsplash.com/photo-1601758228041-f3b2795255f1',
        'description': 'Pet Food, Supplies, Accessories',
        'rating': '4.6',
        'time': '25-30 min',
      },
    ];

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
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: stores.length,
          itemBuilder: (context, index) {
            final store = stores[index];
            return Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        store['image']!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store['name']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            store['description']!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.orange[700], size: 14),
                              const SizedBox(width: 4),
                              Text(
                                store['rating']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.access_time, color: Colors.grey[600], size: 14),
                              const SizedBox(width: 4),
                              Text(
                                store['time']!,
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
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickEssentials() {
    final essentials = [
      {
        'name': 'Fresh Fruits',
        'image': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf',
        'items': '50+ items',
      },
      {
        'name': 'Vegetables',
        'image': 'https://images.unsplash.com/photo-1597362925123-77861d3fbac7',
        'items': '30+ items',
      },
      {
        'name': 'Dairy Products',
        'image': 'https://images.unsplash.com/photo-1628088062854-d1870b4553da',
        'items': '25+ items',
      },
      {
        'name': 'Bread & Eggs',
        'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff',
        'items': '15+ items',
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
              return Container(
                width: 140,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item['image']!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
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
                      item['items']!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAllStores() {
    final List<Map<String, dynamic>> stores = [
      {
        'name': 'Fresh Mart Grocery',
        'image': 'https://images.unsplash.com/photo-1578916171728-46686eac8d58',
        'description': 'Groceries & Fresh Produce',
        'rating': '4.7',
        'time': '20-25 min',
        'tags': <String>['Grocery', 'Fresh Produce'],
      },
      {
        'name': 'City Pharmacy Plus',
        'image': 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88',
        'description': 'Medicines & Healthcare',
        'rating': '4.9',
        'time': '15-20 min',
        'tags': ['Pharmacy', 'Healthcare'],
      },
      {
        'name': 'Sweet Tooth Bakery',
        'image': 'https://images.unsplash.com/photo-1517433670267-08bbd4be890f',
        'description': 'Fresh Baked Goods',
        'rating': '4.6',
        'time': '25-30 min',
        'tags': ['Bakery', 'Desserts'],
      },
      {
        'name': 'Green Valley Fruits',
        'image': 'https://images.unsplash.com/photo-1542838132-92c53300491e',
        'description': 'Fresh Fruits & Vegetables',
        'rating': '4.5',
        'time': '20-25 min',
        'tags': ['Fruits', 'Vegetables'],
      },
      {
        'name': 'Daily Needs Store',
        'image': 'https://images.unsplash.com/photo-1604719312566-8912e9227c6a',
        'description': 'Everyday Essentials',
        'rating': '4.4',
        'time': '15-20 min',
        'tags': ['Grocery', 'Daily Needs'],
      },
      {
        'name': 'Organic World',
        'image': 'https://images.unsplash.com/photo-1488459716781-31db52582fe9',
        'description': 'Organic Products',
        'rating': '4.8',
        'time': '25-30 min',
        'tags': ['Organic', 'Health Foods'],
      },
      {
        'name': 'Quick Mart Express',
        'image': 'https://images.unsplash.com/photo-1578916171728-46686eac8d58',
        'description': 'Convenience Store',
        'rating': '4.3',
        'time': '10-15 min',
        'tags': ['Convenience', 'Quick Delivery'],
      },
      {
        'name': 'Health First Pharmacy',
        'image': 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88',
        'description': 'Healthcare & Wellness',
        'rating': '4.7',
        'time': '20-25 min',
        'tags': ['Pharmacy', 'Wellness'],
      },
      {
        'name': 'Fresh & Fast Foods',
        'image': 'https://images.unsplash.com/photo-1534723452862-4c874018d66d',
        'description': 'Ready to Eat Meals',
        'rating': '4.5',
        'time': '15-20 min',
        'tags': ['Food', 'Quick Meals'],
      },
      {
        'name': 'Pet Care Store',
        'image': 'https://images.unsplash.com/photo-1601758228041-f3b2795255f1',
        'description': 'Pet Food & Supplies',
        'rating': '4.6',
        'time': '25-30 min',
        'tags': ['Pet Care', 'Pet Food'],
      },
    ];

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
          itemCount: stores.length,
          itemBuilder: (context, index) {
            final Map<String, dynamic> store = stores[index];
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
                      child: Image.network(
                        store['image'] as String,
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120,
                            width: 120,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              store['description'] as String,
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
                                  store['rating'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(width: 12),
                                Icon(Icons.access_time, color: Colors.grey[600], size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  store['time'] as String,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: (store['tags'] as List<String>).map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    tag,
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
} 