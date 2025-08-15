// // ignore_for_file: curly_braces_in_flow_control_controls

// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:tuukatuu/data/services/location_service.dart';
// import 'package:tuukatuu/presentation/screens/search_screen.dart';
// import 'package:tuukatuu/presentation/screens/t_mart_clean_screen.dart';
// import 'package:tuukatuu/presentation/widgets/cached_image.dart';
// import 'package:tuukatuu/routes.dart';
// import 'package:tuukatuu/services/location_service.dart';
// import 'package:tuukatuu/services/api_service.dart';
// import 'package:tuukatuu/widgets/appbar_location.dart';
// import 'package:tuukatuu/presentation/widgets/home_skeleton_loader.dart';
// import 'package:tuukatuu/widgets/global_cart_fab.dart';
// import 'package:shimmer/shimmer.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final PageController _bannerController = PageController();
//   Position? _currentPosition;

//   List<dynamic> _banners = [];
//   List<dynamic> _coupons = [];
//   bool _loadingBanners = true;
//   bool _loadingCoupons = true;

//   List<dynamic> _featuredStores = [];
//   List<dynamic> _allStores = [];
//   List<dynamic> _popularNearYou = [];
//   List<dynamic> _featuredRestaurants = []; // Add featured restaurants
//   bool _loadingFeaturedStores = true;
//   bool _loadingAllStores = true;
//   bool _loadingPopularNearYou = true;
//   bool _loadingFeaturedRestaurants = true; // Add loading state for restaurants
//   String? _errorFeaturedStores;
//   String? _errorAllStores;
//   String? _errorPopularNearYou;
//   String? _errorFeaturedRestaurants; // Add error state for restaurants

//   // Filter state
//   String _currentFilter = 'restaurants'; // 'all', 'stores', 'restaurants'

//   @override
//   void dispose() {
//     _bannerController.dispose();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//     _fetchBanners();
//     _fetchCoupons();
//     _fetchFeaturedStores();
//     _fetchFeaturedRestaurants(); // Add featured restaurants fetch
//     _fetchAllStores();
//     _fetchPopularNearYou();

//     // Force show content after 5 seconds even if some API calls are still loading
//     Future.delayed(const Duration(seconds: 5), () {
//       if (mounted && _isLoading()) {
//         print('🔍 HomeScreen: Force showing content after timeout');
//         setState(() {
//           _loadingBanners = false;
//           _loadingCoupons = false;
//           _loadingFeaturedStores = false;
//           _loadingAllStores = false;
//           _loadingPopularNearYou = false;
//           _loadingFeaturedRestaurants = false;
//         });
//       }
//     });
//   }

//   bool _isLoading() {
//     final isLoading = _loadingBanners ||
//         _loadingCoupons ||
//         _loadingFeaturedStores ||
//         _loadingAllStores ||
//         _loadingPopularNearYou ||
//         _loadingFeaturedRestaurants;
//     return isLoading;
//   }

//   Future<void> _refreshData() async {
//     try {
//       // Reset all loading states and errors
//       setState(() {
//         _loadingBanners = true;
//         _loadingCoupons = true;
//         _loadingFeaturedStores = true;
//         _loadingAllStores = true;
//         _loadingPopularNearYou = true;
//         _loadingFeaturedRestaurants = true;
//         _errorFeaturedStores = null;
//         _errorAllStores = null;
//         _errorPopularNearYou = null;
//         _errorFeaturedRestaurants = null;
//       });

//       // Fetch all data concurrently
//       await Future.wait([
//         _fetchBanners(),
//         _fetchCoupons(),
//         _fetchFeaturedStores(),
//         _fetchAllStores(),
//         _fetchPopularNearYou(),
//         _fetchFeaturedRestaurants(),
//       ]);

//       // Show success message
//       if (mounted) {
//         // Home screen refreshed successfully - handle silently
//       }
//     } catch (e) {
//       // Ensure loading states are set to false even if there's an error
//       setState(() {
//         _loadingBanners = false;
//         _loadingCoupons = false;
//         _loadingFeaturedStores = false;
//         _loadingAllStores = false;
//         _loadingPopularNearYou = false;
//         _loadingFeaturedRestaurants = false;
//       });

//       // Show error message
//       if (mounted) {
//         // Failed to refresh - handle silently
//       }
//     }
//   }

//   Future<void> _getCurrentLocation() async {
//     setState(() {});

//     try {
//       final serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         return;
//       }

//       final permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         final newPermission = await Geolocator.requestPermission();
//         if (newPermission == LocationPermission.denied) {
//           return;
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         setState(() {});
//         return;
//       }

//       final position = await LocationService.getCurrentLocation();
//       if (position != null) {
//         setState(() => _currentPosition = position);

//         // Refresh store distances when location changes
//         _refreshStoreDistances();
//       } else {}
//     } catch (e) {}
//   }

//   /// Refresh store distances when user location changes
//   void _refreshStoreDistances() {
//     if (_currentPosition != null) {
//       // Re-sort stores by distance
//       setState(() {
//         _featuredStores = LocationService.sortStoresByDistance(
//             _featuredStores, _currentPosition);
//         _featuredRestaurants = LocationService.sortStoresByDistance(
//             _featuredRestaurants, _currentPosition);
//         _allStores =
//             LocationService.sortStoresByDistance(_allStores, _currentPosition);
//         _popularNearYou = LocationService.sortStoresByDistance(
//             _popularNearYou, _currentPosition);
//       });
//     }
//   }

//   Widget _buildSearchBar(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const SearchScreen()),
//         );
//       },
//       child: Container(
//         margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: isDark ? Colors.grey[800] : Colors.grey[100],
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               Icons.search_rounded,
//               color: isDark ? Colors.grey[400] : Colors.grey[600],
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 'Search for items...',
//                 style: TextStyle(
//                   color: isDark ? Colors.grey[400] : Colors.grey[600],
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         floatingActionButton: const GlobalCartFAB(
//           heroTag: 'home_cart_fab',
//         ),
//         body: Column(
//           children: [
//             // Sticky App Bar with Location and Search
//             Container(
//               child: Column(
//                 children: [
//                   const AppbarLocation(),
//                   _buildSearchBar(context),
//                   // Distance Status Indicator
//                 ],
//               ),
//             ),
//             // Main Content
//             Expanded(
//               child: Container(
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(16),
//                     topRight: Radius.circular(16),
//                   ),
//                 ),
//                 child: _isLoading()
//                     ? const HomeSkeletonLoader()
//                     : RefreshIndicator(
//                         onRefresh: _refreshData,
//                         color: Colors.amber.shade800,
//                         // backgroundColor: Colors.white,
//                         child: SingleChildScrollView(
//                           physics: const AlwaysScrollableScrollPhysics(),
//                           child: Column(
//                             children: [
//                               const Divider(
//                                 height: 24,
//                                 color: Colors.transparent,
//                               ),
//                               _buildTMartExpressInfo(),
//                               _buildCategories(),
//                               _buildPromotionBannerWithRetry(),
//                               const SizedBox(height: 8),
//                               _buildFeaturedStoresWithRetry(),
//                               const Divider(height: 24),
//                               _buildFeaturedRestaurantsWithRetry(),
//                               const Divider(height: 24),
//                               // _buildPopularNearYouWithRetry(),
//                               // const Divider(height: 24),
//                               _buildAllStoresWithRetry(),
//                               const SizedBox(height: 24),
//                             ],
//                           ),
//                         ),
//                       ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTMartExpressInfo() {
//     return GestureDetector(
//       onTap: () {
//         Navigator.pushNamed(
//           context,
//           AppRoutes.tMart,
//         );
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: Colors.orange[50],
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.orange.withOpacity(0.3)),
//         ),
//         child: Row(
//           children: [
//             Icon(Icons.delivery_dining, color: Colors.orange[700], size: 32),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'T-Mart Express Delivery',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'Get your essentials delivered in 15-30 minutes',
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                       fontSize: 13,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(Icons.arrow_forward_ios, color: Colors.orange[700], size: 16),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCategories() {
//     final categories = [
//       {
//         'icon': Icons.local_mall,
//         'label': 'T-Mart',
//         'color': Colors.blue,
//         'route': 't-mart'
//       },
//       {
//         'icon': Icons.local_grocery_store,
//         'label': 'Grocery',
//         'color': Colors.teal,
//         'route': 'category'
//       },
//       {
//         'icon': Icons.fastfood,
//         'label': 'Fast Food',
//         'color': Colors.orange,
//         'route': 'category'
//       },
//       {
//         'icon': Icons.local_pharmacy,
//         'label': 'Pharmacy',
//         'color': Colors.green,
//         'route': 'category'
//       },
//       {
//         'icon': Icons.cake,
//         'label': 'Bakery',
//         'color': Colors.pink,
//         'route': 'category'
//       },
//       {
//         'icon': Icons.wine_bar,
//         'label': 'Wine',
//         'color': Colors.purple,
//         'route': 'category'
//       },
//     ];

//     return Container(
//       height: 120,
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 8),
//         itemCount: categories.length,
//         itemBuilder: (context, index) {
//           final category = categories[index];
//           return GestureDetector(
//             onTap: () {
//               if (category['route'] == 't-mart') {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const TMartCleanScreen(),
//                   ),
//                 );
//               } else {
//                 Navigator.pushNamed(
//                   context,
//                   AppRoutes.categoryProducts,
//                   arguments: {'category': category['label'] as String},
//                 );
//               }
//             },
//             child: Container(
//               width: 80,
//               margin: const EdgeInsets.symmetric(horizontal: 8),
//               child: Column(
//                 children: [
//                   Container(
//                     height: 60,
//                     width: 60,
//                     decoration: BoxDecoration(
//                       color: (category['color'] as Color).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Icon(
//                       category['icon'] as IconData,
//                       color: category['color'] as Color,
//                       size: 30,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     category['label'] as String,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildPromotionBanner() {
//     if (_loadingBanners)
//       return const Center(child: CircularProgressIndicator());
//     if (_banners.isEmpty) return const SizedBox.shrink();
//     return SizedBox(
//       height: 180,
//       child: PageView.builder(
//         controller: _bannerController,
//         itemCount: _banners.length,
//         onPageChanged: (index) {
//           setState(() {});
//         },
//         itemBuilder: (context, index) {
//           final banner = _banners[index];
//           return Container(
//             margin: const EdgeInsets.symmetric(horizontal: 16),
//             child: Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(16),
//                   child: CachedImage(
//                     imageUrl: banner['imageUrl'],
//                     height: 180,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 Positioned(
//                   left: 20,
//                   bottom: 30,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         banner['title'] ?? '',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       if (banner['subtitle'] != null)
//                         Text(
//                           banner['subtitle'],
//                           style: const TextStyle(
//                             color: Colors.white70,
//                             fontSize: 14,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildCoupons() {
//     if (_loadingCoupons)
//       return const Center(child: CircularProgressIndicator());
//     if (_coupons.isEmpty) return const SizedBox.shrink();
//     return SizedBox(
//       height: 80,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         itemCount: _coupons.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 12),
//         itemBuilder: (context, i) {
//           final c = _coupons[i];
//           return Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.orange[50],
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.orange[200]!),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(c['code'],
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold, fontSize: 16)),
//                 Text('${c['discount']}% OFF',
//                     style: const TextStyle(
//                         color: Colors.orange, fontWeight: FontWeight.bold)),
//                 if (c['description'] != null)
//                   Text(c['description'], style: const TextStyle(fontSize: 12)),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildFeaturedStores() {
//     if (_loadingFeaturedStores)
//       return const Center(child: CircularProgressIndicator());
//     if (_errorFeaturedStores != null)
//       return Center(
//           child: Text(_errorFeaturedStores!,
//               style: const TextStyle(color: Colors.red)));
//     if (_featuredStores.isEmpty) return const SizedBox.shrink();
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Text(
//             'Featured Stores',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         SizedBox(
//           height: 200,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             itemCount: _featuredStores.length,
//             itemBuilder: (context, index) {
//               final store = _featuredStores[index];
//               return Container(
//                 width: 200,
//                 margin: const EdgeInsets.symmetric(horizontal: 8),
//                 child: GestureDetector(
//                   onTap: () {
//                     Navigator.pushNamed(
//                       context,
//                       AppRoutes.storeDetails,
//                       arguments: store,
//                     );
//                   },
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Stack(
//                         children: [
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: CachedImage(
//                               imageUrl: store['storeImage'] ?? '',
//                               height: 120,
//                               width: double.infinity,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                           // Store type badge
//                           Positioned(
//                             top: 8,
//                             right: 8,
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 8, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: Colors.orange.withOpacity(0.9),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 store['vendorType'] == 'restaurant'
//                                     ? '🍽️'
//                                     : '🛒',
//                                 style: const TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               store['storeName'] ?? '',
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                               ),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             const SizedBox(height: 2),
//                             Text(
//                               store['vendorSubType'] ??
//                                   store['vendorType'] ??
//                                   'Store',
//                               style: TextStyle(
//                                 color: Colors.grey[600],
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           const Icon(Icons.star,
//                               color: Colors.orange, size: 14),
//                           const SizedBox(width: 4),
//                           Text(
//                             (store['storeRating'] ?? '0.0').toString(),
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w500,
//                               fontSize: 12,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             '(${store['storeReviews'] ?? '0'})',
//                             style: const TextStyle(
//                               color: Colors.grey,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       // Distance information
//                       Row(
//                         children: [
//                           Icon(Icons.location_on,
//                               color: Colors.grey[600], size: 14),
//                           const SizedBox(width: 4),
//                           Text(
//                             _getDistanceText(store),
//                             style: TextStyle(
//                               color: Colors.grey[600],
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPopularNearYou() {
//     if (_loadingPopularNearYou)
//       return const Center(child: CircularProgressIndicator());
//     if (_errorPopularNearYou != null)
//       return Center(
//           child: Text(_errorPopularNearYou!,
//               style: const TextStyle(color: Colors.red)));
//     if (_popularNearYou.isEmpty) return const SizedBox.shrink();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Text(
//             'Popular Near You',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         SizedBox(
//           height: 200,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             itemCount: _popularNearYou.length,
//             itemBuilder: (context, index) {
//               final store = _popularNearYou[index];
//               return Container(
//                 width: 200,
//                 margin: const EdgeInsets.symmetric(horizontal: 8),
//                 child: GestureDetector(
//                   onTap: () {
//                     Navigator.pushNamed(
//                       context,
//                       AppRoutes.storeDetails,
//                       arguments: store,
//                     );
//                   },
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Stack(
//                         children: [
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: CachedImage(
//                               imageUrl: store['storeImage'] ?? '',
//                               height: 120,
//                               width: double.infinity,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                           // Store type badge
//                           Positioned(
//                             top: 8,
//                             right: 8,
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 8, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: Colors.orange.withOpacity(0.9),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 store['vendorType'] == 'restaurant'
//                                     ? '🍽️'
//                                     : '🛒',
//                                 style: const TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               store['storeName'] ?? '',
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                               ),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             const SizedBox(height: 2),
//                             Text(
//                               store['vendorSubType'] ??
//                                   store['vendorType'] ??
//                                   'Store',
//                               style: TextStyle(
//                                 color: Colors.grey[600],
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           const Icon(Icons.star,
//                               color: Colors.orange, size: 14),
//                           const SizedBox(width: 4),
//                           Text(
//                             (store['storeRating'] ?? '0.0').toString(),
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w500,
//                               fontSize: 12,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             '(${store['storeReviews'] ?? '0'})',
//                             style: const TextStyle(
//                               color: Colors.grey,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       // Distance information
//                       Row(
//                         children: [
//                           Icon(Icons.location_on,
//                               color: Colors.grey[600], size: 14),
//                           const SizedBox(width: 4),
//                           Text(
//                             _getDistanceText(store),
//                             style: TextStyle(
//                               color: Colors.grey[600],
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   String _getDistanceText(dynamic store) {
//     return LocationService.calculateDistanceTextEnhanced(
//         _currentPosition, store['storeCoordinates']);
//   }

//   Widget _buildAllStores() {
//     if (_loadingAllStores)
//       return const Center(child: CircularProgressIndicator());
//     if (_errorAllStores != null)
//       return Center(
//           child: Text(_errorAllStores!,
//               style: const TextStyle(color: Colors.red)));
//     if (_allStores.isEmpty) return const SizedBox.shrink();

//     // Filter stores based on current filter
//     List<dynamic> filteredStores = _allStores;
//     if (_currentFilter == 'stores') {
//       filteredStores = _allStores
//           .where((store) =>
//               store['type'] == 'store' || store['vendorType'] == 'store')
//           .toList();
//     } else if (_currentFilter == 'restaurants') {
//       filteredStores = _allStores
//           .where((store) =>
//               store['type'] == 'restaurant' ||
//               store['vendorType'] == 'restaurant')
//           .toList();
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           height: 20,
//         ),

//         // Filter Tabs
//         Container(
//           margin: const EdgeInsets.symmetric(horizontal: 16),
//           decoration: BoxDecoration(
//             color: Colors.grey[100],
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Row(
//             children: [
//               _buildFilterTab('restaurants', 'Restaurants'),
//               _buildFilterTab('stores', 'Stores'),
//             ],
//           ),
//         ),

//         const SizedBox(height: 16),

//         // Distance Filter
//         if (_currentPosition != null)
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               children: [
//                 Icon(Icons.location_on, color: Colors.orange[700], size: 16),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Sorting by distance',
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const Spacer(),
//                 TextButton(
//                   onPressed: () {
//                     setState(() {
//                       // Re-sort stores by distance
//                       _allStores = LocationService.sortStoresByDistance(
//                           _allStores, _currentPosition);
//                     });
//                   },
//                   child: Text(
//                     'Refresh',
//                     style: TextStyle(
//                       color: Colors.orange[700],
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//         // Stores List
//         ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           itemCount: filteredStores.length,
//           itemBuilder: (context, index) {
//             final store = filteredStores[index];
//             return _buildEnhancedStoreCard(store);
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildFilterTab(String filter, String label) {
//     final isSelected = _currentFilter == filter;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             _currentFilter = filter;
//           });
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             color: isSelected ? Colors.orange : Colors.transparent,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Text(
//             label,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//               color: isSelected ? Colors.white : Colors.grey[600],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEnhancedStoreCard(dynamic store) {
//     final images =
//         store['images'] as List<dynamic>? ?? [store['storeImage'] ?? ''];
//     final rating = (store['storeRating'] ?? 0).toDouble();
//     final distance = _getDistanceText(store);
//     final deliveryTime = store['deliveryTime'] ?? '30-45 min';

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: InkWell(
//         onTap: () {
//           Navigator.pushNamed(
//             context,
//             AppRoutes.storeDetails,
//             arguments: store,
//           );
//         },
//         borderRadius: BorderRadius.circular(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Image Carousel
//             Stack(
//               children: [
//                 Container(
//                   height: 200,
//                   width: double.infinity,
//                   child: PageView.builder(
//                     itemCount: images.length,
//                     itemBuilder: (context, imageIndex) {
//                       return ClipRRect(
//                         borderRadius: const BorderRadius.vertical(
//                             top: Radius.circular(16)),
//                         child: CachedImage(
//                           imageUrl: images[imageIndex],
//                           height: 200,
//                           width: double.infinity,
//                           fit: BoxFit.cover,
//                         ),
//                       );
//                     },
//                   ),
//                 ),

//                 // Image Indicator
//                 if (images.length > 1)
//                   Positioned(
//                     bottom: 12,
//                     left: 12,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.7),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         '${images.length} photos',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),

//             // Store Info
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           store['storeName'] ?? '',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                           ),
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.orange.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(
//                           store['type'] == 'restaurant'
//                               ? 'Restaurant'
//                               : 'Store',
//                           style: TextStyle(
//                             color: Colors.orange[700],
//                             fontSize: 12,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 8),

//                   Text(
//                     store['storeDescription'] ?? '',
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                       fontSize: 14,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),

//                   const SizedBox(height: 12),

//                   // Rating, Distance, and Time
//                   Row(
//                     children: [
//                       // Rating
//                       Row(
//                         children: [
//                           const Icon(Icons.star,
//                               color: Colors.orange, size: 16),
//                           const SizedBox(width: 4),
//                           Text(
//                             rating.toString(),
//                             style: const TextStyle(fontWeight: FontWeight.w500),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(width: 16),

//                       // Distance
//                       Row(
//                         children: [
//                           Icon(Icons.location_on,
//                               color: Colors.grey[600], size: 16),
//                           const SizedBox(width: 4),
//                           Text(
//                             distance,
//                             style: TextStyle(
//                               color: Colors.grey[600],
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(width: 16),

//                       // Delivery Time
//                       Row(
//                         children: [
//                           Icon(Icons.access_time,
//                               color: Colors.grey[600], size: 16),
//                           const SizedBox(width: 4),
//                           Text(
//                             deliveryTime,
//                             style: TextStyle(
//                               color: Colors.grey[600],
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 12),

//                   // Tags
//                   if (store['storeTags'] != null)
//                     Wrap(
//                       spacing: 8,
//                       runSpacing: 8,
//                       children:
//                           (store['storeTags'] as List<dynamic>).map((tag) {
//                         return Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: Theme.of(context)
//                                 .colorScheme
//                                 .primary
//                                 .withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             tag.toString(),
//                             style: TextStyle(
//                               color: Theme.of(context).colorScheme.primary,
//                               fontSize: 12,
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _fetchBanners() async {
//     print('🔍 HomeScreen: Fetching banners...');
//     if (!mounted) return;

//     try {
//       final data = await ApiService.get('/banners');
//       print(
//           '🔍 HomeScreen: Banners fetched successfully: ${data.length} banners');
//       if (mounted) {
//         setState(() {
//           _banners = data;
//           _loadingBanners = false;
//         });
//       }
//     } catch (e) {
//       print('❌ HomeScreen: Error fetching banners: $e');
//       // Use mock data if API fails
//       if (mounted) {
//         setState(() {
//           _banners = [
//             {
//               'imageUrl':
//                   'https://via.placeholder.com/400x200/FF6B35/FFFFFF?text=T-Mart+Express',
//               'title': 'T-Mart Express',
//               'subtitle': 'Get groceries delivered in 15-30 minutes'
//             },
//             {
//               'imageUrl':
//                   'https://via.placeholder.com/400x200/4CAF50/FFFFFF?text=Fresh+Groceries',
//               'title': 'Fresh Groceries',
//               'subtitle': 'Quality products at best prices'
//             }
//           ];
//           _loadingBanners = false;
//         });
//       }
//     }
//   }

//   Future<void> _fetchCoupons() async {
//     if (!mounted) return;

//     try {
//       final data = await ApiService.get('/coupons');
//       if (mounted) {
//         setState(() {
//           _coupons = data;
//           _loadingCoupons = false;
//         });
//       }
//     } catch (e) {
//       print('❌ HomeScreen: Error fetching coupons: $e');
//       // Use mock data if API fails
//       if (mounted) {
//         setState(() {
//           _coupons = [
//             {
//               'code': 'WELCOME20',
//               'discount': 20,
//               'description': 'First order discount'
//             },
//             {
//               'code': 'FRESH10',
//               'discount': 10,
//               'description': 'Fresh groceries discount'
//             }
//           ];
//           _loadingCoupons = false;
//         });
//       }
//     }
//   }

//   Future<void> _fetchFeaturedStores() async {
//     if (!mounted) return;

//     try {
//       // Use the correct endpoint for featured vendors
//       final data = await ApiService.get('/auth/featured-vendors');
//       print('🔍 HomeScreen: Featured stores fetched: ${data.length} stores');

//       // Transform the data to match the expected structure
//       final transformedData = (data as List).map((store) {
//         return {
//           'storeName': store['storeName'] ?? store['name'] ?? 'Store',
//           'storeImage': store['storeImage'] ?? store['image'] ?? '',
//           'storeRating': store['storeRating'] ?? store['rating'] ?? 0.0,
//           'storeReviews': store['storeReviews'] ?? store['reviews'] ?? 0,
//           'vendorType': store['vendorType'] ?? 'store',
//           'vendorSubType':
//               store['vendorSubType'] ?? store['storeCategory'] ?? 'Store',
//           'storeDescription':
//               store['storeDescription'] ?? store['description'] ?? '',
//           'deliveryTime': store['deliveryTime'] ?? '30-45 min',
//           'deliveryFee': store['deliveryFee'] ?? '₹20',
//           'storeCoordinates': store['storeCoordinates'],
//           'storeTags': store['storeTags'] ?? [],
//           'type': store['vendorType'] ?? 'store',
//           'images': store['storeImages'] ?? [store['storeImage'] ?? ''],
//           'vendorId': store['_id'] ?? store['id'] ?? store['vendorId'] ?? '',
//           'id': store['_id'] ?? store['id'] ?? '',
//         };
//       }).toList();

//       // Sort stores by distance if user location is available
//       final sortedStores = LocationService.sortStoresByDistance(
//           transformedData, _currentPosition);

//       if (mounted) {
//         setState(() {
//           _featuredStores = sortedStores;
//           _loadingFeaturedStores = false;
//         });
//       }
//     } catch (e) {
//       print('❌ HomeScreen: Error fetching featured stores: $e');
//       if (mounted) {
//         setState(() {
//           _errorFeaturedStores = e.toString();
//           _loadingFeaturedStores = false;
//         });
//       }
//     }
//   }

//   Future<void> _fetchFeaturedRestaurants() async {
//     if (!mounted) return;

//     try {
//       // Get all vendors and filter for restaurants
//       final data = await ApiService.get('/auth/vendors');
//       print('🔍 HomeScreen: All vendors fetched: ${data.length} vendors');

//       // Filter for restaurants and transform data
//       final allRestaurants = (data as List).where((vendor) {
//         final vendorType = vendor['vendorType']?.toString().toLowerCase() ?? '';
//         final storeTags = (vendor['storeTags'] as List<dynamic>? ?? [])
//             .map((tag) => tag.toString().toLowerCase())
//             .toList();

//         return vendorType.contains('restaurant') ||
//             storeTags.any((tag) =>
//                 tag.contains('restaurant') ||
//                 tag.contains('food') ||
//                 tag.contains('dining'));
//       }).toList();

//       // Select featured restaurants (first 4 or all if less than 4)
//       final restaurants = allRestaurants.take(4).map((restaurant) {
//         return {
//           'storeName':
//               restaurant['storeName'] ?? restaurant['name'] ?? 'Restaurant',
//           'storeImage': restaurant['storeImage'] ?? restaurant['image'] ?? '',
//           'storeRating':
//               restaurant['storeRating'] ?? restaurant['rating'] ?? 0.0,
//           'storeReviews':
//               restaurant['storeReviews'] ?? restaurant['reviews'] ?? 0,
//           'vendorType': 'restaurant',
//           'vendorSubType': restaurant['vendorSubType'] ??
//               restaurant['storeCategory'] ??
//               'Restaurant',
//           'storeDescription':
//               restaurant['storeDescription'] ?? restaurant['description'] ?? '',
//           'deliveryTime': restaurant['deliveryTime'] ?? '30-45 min',
//           'deliveryFee': restaurant['deliveryFee'] ?? '₹30',
//           'storeCoordinates': restaurant['storeCoordinates'],
//           'storeTags': restaurant['storeTags'] ?? [],
//           'type': 'restaurant',
//           'images':
//               restaurant['storeImages'] ?? [restaurant['storeImage'] ?? ''],
//           'vendorId': restaurant['_id'] ??
//               restaurant['id'] ??
//               restaurant['vendorId'] ??
//               '',
//           'id': restaurant['_id'] ?? restaurant['id'] ?? '',
//         };
//       }).toList();

//       // Sort restaurants by distance if user location is available
//       final sortedRestaurants =
//           LocationService.sortStoresByDistance(restaurants, _currentPosition);

//       print(
//           '🔍 HomeScreen: Featured restaurants filtered: ${sortedRestaurants.length} restaurants');

//       if (mounted) {
//         setState(() {
//           _featuredRestaurants = sortedRestaurants;
//           _loadingFeaturedRestaurants = false;
//         });
//       }
//     } catch (e) {
//       print('❌ HomeScreen: Error fetching featured restaurants: $e');
//       if (mounted) {
//         setState(() {
//           _errorFeaturedRestaurants = e.toString();
//           _loadingFeaturedRestaurants = false;
//         });
//       }
//     }
//   }

//   Future<void> _fetchAllStores() async {
//     if (!mounted) return;

//     try {
//       // Get all vendors
//       final data = await ApiService.get('/auth/vendors');
//       print('🔍 HomeScreen: All stores fetched: ${data.length} stores');

//       // Transform the data to match the expected structure
//       final transformedData = (data as List).map((store) {
//         final vendorType =
//             store['vendorType']?.toString().toLowerCase() ?? 'store';
//         final isRestaurant = vendorType.contains('restaurant') ||
//             (store['storeTags'] as List<dynamic>? ?? []).any((tag) =>
//                 tag.toString().toLowerCase().contains('restaurant') ||
//                 tag.toString().toLowerCase().contains('food'));

//         return {
//           'storeName': store['storeName'] ?? store['name'] ?? 'Store',
//           'storeImage': store['storeImage'] ?? store['image'] ?? '',
//           'storeRating': store['storeRating'] ?? store['rating'] ?? 0.0,
//           'storeReviews': store['storeReviews'] ?? store['reviews'] ?? 0,
//           'vendorType': store['vendorType'] ?? 'store',
//           'vendorSubType':
//               store['vendorSubType'] ?? store['storeCategory'] ?? 'Store',
//           'storeDescription':
//               store['storeDescription'] ?? store['description'] ?? '',
//           'deliveryTime': store['deliveryTime'] ?? '30-45 min',
//           'deliveryFee': store['deliveryFee'] ?? '₹20',
//           'storeCoordinates': store['storeCoordinates'],
//           'storeTags': store['storeTags'] ?? [],
//           'type': isRestaurant ? 'restaurant' : 'store',
//           'images': store['storeImages'] ?? [store['storeImage'] ?? ''],
//           'vendorId': store['_id'] ?? store['id'] ?? store['vendorId'] ?? '',
//           'id': store['_id'] ?? store['id'] ?? '',
//         };
//       }).toList();

//       // Sort stores by distance if user location is available
//       final sortedStores = LocationService.sortStoresByDistance(
//           transformedData, _currentPosition);

//       if (mounted) {
//         setState(() {
//           _allStores = sortedStores;
//           _loadingAllStores = false;
//         });
//       }
//     } catch (e) {
//       print('❌ HomeScreen: Error fetching all stores: $e');
//       if (mounted) {
//         setState(() {
//           _errorAllStores = e.toString();
//           _loadingAllStores = false;
//         });
//       }
//     }
//   }

//   Widget _buildPromotionBannerWithRetry() {
//     if (_loadingBanners)
//       return Container(
//         height: 180,
//         margin: const EdgeInsets.symmetric(horizontal: 16),
//         child: Shimmer.fromColors(
//           baseColor: Colors.grey[300]!,
//           highlightColor: Colors.grey[100]!,
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(16),
//             ),
//           ),
//         ),
//       );
//     if (_banners.isEmpty) return const SizedBox.shrink();
//     return _buildPromotionBanner();
//   }

//   Widget _buildCouponsWithRetry() {
//     if (_loadingCoupons)
//       return const Center(child: CircularProgressIndicator());
//     if (_coupons.isEmpty)
//       return Center(
//         child: Column(
//           children: [
//             const Text('No coupons available.'),
//             TextButton(onPressed: _fetchCoupons, child: const Text('Retry')),
//           ],
//         ),
//       );
//     return _buildCoupons();
//   }

//   Widget _buildFeaturedStoresWithRetry() {
//     if (_loadingFeaturedStores)
//       return Container(
//         height: 200,
//         margin: const EdgeInsets.symmetric(horizontal: 16),
//         child: Shimmer.fromColors(
//           baseColor: Colors.grey[300]!,
//           highlightColor: Colors.grey[100]!,
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         ),
//       );
//     if (_errorFeaturedStores != null) {
//       return Container(
//         height: 100,
//         margin: const EdgeInsets.symmetric(horizontal: 16),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text('Failed to load featured stores',
//                   style: TextStyle(color: Colors.grey[600])),
//               TextButton(
//                 onPressed: _fetchFeaturedStores,
//                 child: const Text('Retry'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//     if (_featuredStores.isEmpty) return const SizedBox.shrink();
//     return _buildFeaturedStores();
//   }

//   Widget _buildFeaturedRestaurantsWithRetry() {
//     if (_loadingFeaturedRestaurants)
//       return Container(
//         height: 200,
//         margin: const EdgeInsets.symmetric(horizontal: 16),
//         child: Shimmer.fromColors(
//           baseColor: Colors.grey[300]!,
//           highlightColor: Colors.grey[100]!,
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         ),
//       );
//     if (_errorFeaturedRestaurants != null) {
//       return Container(
//         height: 100,
//         margin: const EdgeInsets.symmetric(horizontal: 16),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text('Failed to load featured restaurants',
//                   style: TextStyle(color: Colors.grey[600])),
//               TextButton(
//                 onPressed: _fetchFeaturedRestaurants,
//                 child: const Text('Retry'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//     if (_featuredRestaurants.isEmpty) return const SizedBox.shrink();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Text(
//             'Featured Restaurants',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         SizedBox(
//           height: 200,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             itemCount: _featuredRestaurants.length,
//             itemBuilder: (context, index) {
//               final restaurant = _featuredRestaurants[index];
//               return Container(
//                 width: 200,
//                 margin: const EdgeInsets.symmetric(horizontal: 8),
//                 child: GestureDetector(
//                   onTap: () {
//                     Navigator.pushNamed(
//                       context,
//                       AppRoutes.storeDetails,
//                       arguments: restaurant,
//                     );
//                   },
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Stack(
//                         children: [
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: CachedImage(
//                               imageUrl: restaurant['storeImage'] ?? '',
//                               height: 120,
//                               width: double.infinity,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                           // Restaurant type badge
//                           Positioned(
//                             top: 8,
//                             right: 8,
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 8, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: Colors.orange.withOpacity(0.9),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: const Text(
//                                 '🍽️',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               restaurant['storeName'] ?? '',
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                               ),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             const SizedBox(height: 2),
//                             Text(
//                               restaurant['vendorSubType'] ?? 'Restaurant',
//                               style: TextStyle(
//                                 color: Colors.grey[600],
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           const Icon(Icons.star,
//                               color: Colors.orange, size: 14),
//                           const SizedBox(width: 4),
//                           Text(
//                             (restaurant['storeRating'] ?? '0.0').toString(),
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w500,
//                               fontSize: 12,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             '(${restaurant['storeReviews'] ?? '0'})',
//                             style: const TextStyle(
//                               color: Colors.grey,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       // Distance information
//                       Row(
//                         children: [
//                           Icon(Icons.location_on,
//                               color: Colors.grey[600], size: 14),
//                           const SizedBox(width: 4),
//                           Text(
//                             _getDistanceText(restaurant),
//                             style: TextStyle(
//                               color: Colors.grey[600],
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPopularNearYouWithRetry() {
//     if (_loadingPopularNearYou)
//       return Container(
//         height: 200,
//         margin: const EdgeInsets.symmetric(horizontal: 16),
//         child: Shimmer.fromColors(
//           baseColor: Colors.grey[300]!,
//           highlightColor: Colors.grey[100]!,
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         ),
//       );
//     if (_errorPopularNearYou != null) {
//       return Container(
//         height: 100,
//         margin: const EdgeInsets.symmetric(horizontal: 16),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text('Failed to load popular stores',
//                   style: TextStyle(color: Colors.grey[600])),
//               TextButton(
//                 onPressed: _fetchPopularNearYou,
//                 child: const Text('Retry'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//     if (_popularNearYou.isEmpty) return const SizedBox.shrink();
//     return _buildPopularNearYou();
//   }

//   Future<void> _fetchPopularNearYou() async {
//     if (!mounted) return;

//     try {
//       // Try to get nearby vendors first
//       if (_currentPosition != null) {
//         try {
//           print(
//               '🔍 Fetching nearby vendors with location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
//           final nearbyStores = await ApiService.getNearbyVendors(
//             latitude: _currentPosition!.latitude,
//             longitude: _currentPosition!.longitude,
//             radius: 10.0, // 10km radius
//           );
//           if (nearbyStores.isNotEmpty) {
//             print('✅ Found ${nearbyStores.length} nearby stores');
//             // Transform the data to match expected structure
//             final transformedData = nearbyStores.map((store) {
//               return {
//                 'storeName': store['storeName'] ?? store['name'] ?? 'Store',
//                 'storeImage': store['storeImage'] ?? store['image'] ?? '',
//                 'storeRating': store['storeRating'] ?? store['rating'] ?? 0.0,
//                 'storeReviews': store['storeReviews'] ?? store['reviews'] ?? 0,
//                 'vendorType': store['vendorType'] ?? 'store',
//                 'vendorSubType':
//                     store['vendorSubType'] ?? store['storeCategory'] ?? 'Store',
//                 'storeDescription':
//                     store['storeDescription'] ?? store['description'] ?? '',
//                 'deliveryTime': store['deliveryTime'] ?? '30-45 min',
//                 'deliveryFee': store['deliveryFee'] ?? '₹20',
//                 'storeCoordinates': store['storeCoordinates'],
//                 'storeTags': store['storeTags'] ?? [],
//                 'type': store['vendorType'] ?? 'store',
//                 'images': store['storeImages'] ?? [store['storeImage'] ?? ''],
//                 'vendorId':
//                     store['_id'] ?? store['id'] ?? store['vendorId'] ?? '',
//                 'id': store['_id'] ?? store['id'] ?? '',
//               };
//             }).toList();

//             // Sort stores by distance if user location is available
//             final sortedStores = LocationService.sortStoresByDistance(
//                 transformedData, _currentPosition);

//             if (mounted) {
//               setState(() {
//                 _popularNearYou = sortedStores;
//                 _loadingPopularNearYou = false;
//               });
//             }
//             return;
//           } else {
//             print('⚠️ No nearby stores found, using featured');
//           }
//         } catch (e) {
//           print('⚠️ Nearby vendors failed, using featured: $e');
//         }
//       } else {
//         print('⚠️ No location available, using featured stores');
//       }

//       // Fallback to featured vendors
//       print('🔍 Fetching featured vendors');
//       final featuredStores = await ApiService.get('/auth/featured-vendors');
//       final stores = featuredStores is List ? featuredStores : [];
//       print('✅ Found ${stores.length} featured stores');

//       // Transform the data to match expected structure
//       final transformedData = stores.map((store) {
//         return {
//           'storeName': store['storeName'] ?? store['name'] ?? 'Store',
//           'storeImage': store['storeImage'] ?? store['image'] ?? '',
//           'storeRating': store['storeRating'] ?? store['rating'] ?? 0.0,
//           'storeReviews': store['storeReviews'] ?? store['reviews'] ?? 0,
//           'vendorType': store['vendorType'] ?? 'store',
//           'vendorSubType':
//               store['vendorSubType'] ?? store['storeCategory'] ?? 'Store',
//           'storeDescription':
//               store['storeDescription'] ?? store['description'] ?? '',
//           'deliveryTime': store['deliveryTime'] ?? '30-45 min',
//           'deliveryFee': store['deliveryFee'] ?? '₹20',
//           'storeCoordinates': store['storeCoordinates'],
//           'storeTags': store['storeTags'] ?? [],
//           'type': store['vendorType'] ?? 'store',
//           'images': store['storeImages'] ?? [store['storeImage'] ?? ''],
//           'vendorId': store['_id'] ?? store['id'] ?? store['vendorId'] ?? '',
//           'id': store['_id'] ?? store['id'] ?? '',
//         };
//       }).toList();

//       // Sort stores by distance if user location is available
//       final sortedStores = LocationService.sortStoresByDistance(
//           transformedData, _currentPosition);

//       if (mounted) {
//         setState(() {
//           _popularNearYou = sortedStores;
//           _loadingPopularNearYou = false;
//         });
//       }
//     } catch (e) {
//       print('❌ Error fetching popular near you: $e');
//       if (mounted) {
//         setState(() {
//           _errorPopularNearYou = e.toString();
//           _loadingPopularNearYou = false;
//         });
//       }
//     }
//   }

//   Widget _buildAllStoresWithRetry() {
//     if (_loadingAllStores)
//       return Container(
//         height: 200,
//         margin: const EdgeInsets.symmetric(horizontal: 16),
//         child: Shimmer.fromColors(
//           baseColor: Colors.grey[300]!,
//           highlightColor: Colors.grey[100]!,
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         ),
//       );
//     if (_errorAllStores != null) {
//       return Container(
//         height: 100,
//         margin: const EdgeInsets.symmetric(horizontal: 16),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text('Failed to load stores',
//                   style: TextStyle(color: Colors.grey[600])),
//               TextButton(
//                 onPressed: _fetchAllStores,
//                 child: const Text('Retry'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//     if (_allStores.isEmpty) return const SizedBox.shrink();
//     return _buildAllStores();
//   }
// }
