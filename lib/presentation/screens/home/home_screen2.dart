// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'package:geolocator/geolocator.dart';
// import '../../widgets/home_widgets.dart';
// import '../../../services/api_service.dart';
// import '../../../services/store_service.dart';
// import '../../../services/location_service.dart';
// import '../../../models/store.dart';
// import '../../../models/product.dart';
// import '../../../routes.dart';

// class HomeScreen2 extends StatefulWidget {
//   const HomeScreen2({super.key});

//   @override
//   State<HomeScreen2> createState() => _HomeScreen2State();
// }

// class _HomeScreen2State extends State<HomeScreen2>
//     with SingleTickerProviderStateMixin {
//   int _currentIndex = 0;
//   late TabController _tabController;

//   // Data states
//   List<BannerModel> _banners = [];
//   List<CategoryModel> _categories = [];
//   List<Store> _featuredStores = [];
//   List<Store> _allStores = [];
//   List<Store> _allRestaurants = [];
//   List<Store> _nearbyRestaurants = [];
  
//   // Loading states
//   bool _isLoadingBanners = true;
//   bool _isLoadingCategories = true;
//   bool _isLoadingFeaturedStores = true;
//   bool _isLoadingAllStores = true;
//   bool _isLoadingAllRestaurants = true;
//   bool _isLoadingNearbyRestaurants = true;
  
//   // Error states
//   String? _errorBanners;
//   String? _errorCategories;
//   String? _errorFeaturedStores;
//   String? _errorAllStores;
//   String? _errorAllRestaurants;
//   String? _errorNearbyRestaurants;
  
//   // Location state
//   Position? _currentPosition;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _tabController.addListener(() {
//       if (_tabController.indexIsChanging) {
//         setState(() {});
//       }
//     });
    
//     // Initialize data
//     _initializeData();
//   }

//   Future<void> _initializeData() async {
//     await _getCurrentLocation();
//     await Future.wait([
//       _fetchBanners(),
//       _fetchCategories(),
//       _fetchFeaturedStores(),
//       _fetchAllStores(),
//       _fetchAllRestaurants(),
//       _fetchNearbyRestaurants(),
//     ]);
//   }

//   Future<void> _getCurrentLocation() async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         print('Location services are disabled.');
//         return;
//       }

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           print('Location permissions are denied');
//           return;
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         print('Location permissions are permanently denied');
//         return;
//       }

//       _currentPosition = await Geolocator.getCurrentPosition();
//       setState(() {});
//     } catch (e) {
//       print('Error getting location: $e');
//     }
//   }

//   Future<void> _fetchBanners() async {
//     try {
//       setState(() {
//         _isLoadingBanners = true;
//         _errorBanners = null;
//       });

//       final banners = await ApiService.getBanners();
//       setState(() {
//         _banners = banners;
//         _isLoadingBanners = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorBanners = e.toString();
//         _isLoadingBanners = false;
//       });
//     }
//   }

//   final List<Map<String, dynamic>> categories = [
//     {
//       'id': '1',
//       'name': 'T-Mart',
//       'iconUrl': 'assets/images/logo/logo.png',
//     },
//     {
//       'id': '2',
//       'name': 'Grocery',
//       'iconUrl': 'assets/images/products/bread.jpg',
//     },
//     {
//       'id': '3',
//       'name': 'Pharmacy',
//       'iconUrl': 'assets/images/products/chocolate.jpg',
//     },
//     {
//       'id': '4',
//       'name': 'Bakery',
//       'iconUrl': 'assets/images/products/bread_2.jpg',
//     },
//     {
//       'id': '5',
//       'name': 'Wine',
//       'iconUrl': 'assets/images/products/chocolate_2.jpg',
//     },
//   ];

//   Future<void> _fetchCategories() async {
//     setState(() {
//       _categories = categories.map((category) => CategoryModel.fromJson(category)).toList();
//       _isLoadingCategories = false;
//     });
//   }

//   Future<void> _fetchFeaturedStores() async {
//     try {
//       setState(() {
//         _isLoadingFeaturedStores = true;
//         _errorFeaturedStores = null;
//       });

//       final stores = await StoreService.getFeaturedStores(_currentPosition!.latitude, _currentPosition!.longitude);
      
//       // Sort by distance if location is available
//       if (_currentPosition != null) {
//         final sortedStores = LocationService.sortStoresByDistance(
//           stores.map((store) => store.toJson()).toList(),
//           _currentPosition,
//         );
//         final sortedStoreObjects = sortedStores.map((json) => Store.fromJson(json)).toList();
//         setState(() {
//           _featuredStores = sortedStoreObjects;
//           _isLoadingFeaturedStores = false;
//         });
//       } else {
//         setState(() {
//           _featuredStores = stores;
//           _isLoadingFeaturedStores = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorFeaturedStores = e.toString();
//         _isLoadingFeaturedStores = false;
//       });
//     }
//   }

//   Future<void> _fetchAllStores() async {
//     try {
//       setState(() {
//         _isLoadingAllStores = true;
//         _errorAllStores = null;
//       });

//       final stores = await StoreService.getStores();
      
//       // Sort by distance if location is available
//       if (_currentPosition != null) {
//         final sortedStores = LocationService.sortStoresByDistance(
//           stores.map((store) => store.toJson()).toList(),
//           _currentPosition,
//         );
//         final sortedStoreObjects = sortedStores.map((json) => Store.fromJson(json)).toList();
//         setState(() {
//           _allStores = sortedStoreObjects;
//           _isLoadingAllStores = false;
//         });
//       } else {
//         setState(() {
//           _allStores = stores;
//           _isLoadingAllStores = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorAllStores = e.toString();
//         _isLoadingAllStores = false;
//       });
//     }
//   }

//   Future<void> _fetchAllRestaurants() async {
//     try {
//       setState(() {
//         _isLoadingAllRestaurants = true;
//         _errorAllRestaurants = null;
//       });

//       // Use the customer API endpoint for restaurants
//       final response = await ApiService.get('/customer/all-restaurants');
//       if (response is List) {
//         final restaurants = response.map((json) => Store.fromJson(json)).toList();
        
//         // Sort by distance if location is available
//         if (_currentPosition != null) {
//           final sortedRestaurants = LocationService.sortStoresByDistance(
//             restaurants.map((restaurant) => restaurant.toJson()).toList(),
//             _currentPosition,
//           );
//           final sortedRestaurantObjects = sortedRestaurants.map((json) => Store.fromJson(json)).toList();
//           setState(() {
//             _allRestaurants = sortedRestaurantObjects;
//             _isLoadingAllRestaurants = false;
//           });
//         } else {
//           setState(() {
//             _allRestaurants = restaurants;
//             _isLoadingAllRestaurants = false;
//           });
//         }
//       } else {
//         setState(() {
//           _allRestaurants = [];
//           _isLoadingAllRestaurants = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorAllRestaurants = e.toString();
//         _isLoadingAllRestaurants = false;
//       });
//     }
//   }

//   Future<void> _fetchNearbyRestaurants() async {
//     try {
//       setState(() {
//         _isLoadingNearbyRestaurants = true;
//         _errorNearbyRestaurants = null;
//       });

//       // Use the customer API endpoint for restaurants
//       final response = await ApiService.get('/customer/all-restaurants');
//       if (response is List) {
//         final restaurants = response.map((json) => Store.fromJson(json)).toList();
        
//         // Sort by distance if location is available
//         if (_currentPosition != null) {
//           final sortedRestaurants = LocationService.sortStoresByDistance(
//             restaurants.map((restaurant) => restaurant.toJson()).toList(),
//             _currentPosition,
//           );
//           final sortedRestaurantObjects = sortedRestaurants.map((json) => Store.fromJson(json)).toList();
          
//           // Take only the first 4 for the nearby section
//           final nearbyRestaurants = sortedRestaurantObjects.take(4).toList();
//           setState(() {
//             _nearbyRestaurants = nearbyRestaurants;
//             _isLoadingNearbyRestaurants = false;
//           });
//         } else {
//           setState(() {
//             _nearbyRestaurants = restaurants.take(4).toList();
//             _isLoadingNearbyRestaurants = false;
//           });
//         }
//       } else {
//         setState(() {
//           _nearbyRestaurants = [];
//           _isLoadingNearbyRestaurants = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorNearbyRestaurants = e.toString();
//         _isLoadingNearbyRestaurants = false;
//       });
//     }
//   }

//   Future<void> _refreshData() async {
//     await _getCurrentLocation();
//     await Future.wait([
//       _fetchBanners(),
//       _fetchCategories(),
//       _fetchFeaturedStores(),
//       _fetchAllStores(),
//       _fetchAllRestaurants(),
//       _fetchNearbyRestaurants(),
//     ]);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: RefreshIndicator(
//           onRefresh: _refreshData,
//           child: CustomScrollView(
//             slivers: [
//               // Main content
//               const SliverToBoxAdapter(
//                 child: Padding(
//                   padding:
//                       EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       TopBarWidget(),
//                     ],
//                   ),
//                 ),
//               ),
//               // Sticky TabBar
//               SliverPersistentHeader(
//                   pinned: true,
//                   delegate: _SliverAppBarDelegate(
//                       minHeight: 70,
//                       maxHeight: 70,
//                       child: Container(
//                           width: double.infinity,
//                           decoration: const BoxDecoration(
//                             color: Colors.white,
//                           ),
//                           child: const Padding(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 20, vertical: 12),
//                             child: SearchBarWidget(),
//                           )))),

//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Categories Section
//                       if (_isLoadingCategories)
//                         const Center(child: CircularProgressIndicator())
//                       else if (_errorCategories != null)
//                         Center(
//                           child: Column(
//                             children: [
//                               Text('Error loading categories: $_errorCategories'),
//                               ElevatedButton(
//                                 onPressed: _fetchCategories,
//                                 child: const Text('Retry'),
//                               ),
//                             ],
//                           ),
//                         )
//                       else ...[
//                         const Text('Categories',
//                             style: TextStyle(
//                                 fontSize: 16, fontWeight: FontWeight.w600)),
//                         const SizedBox(height: 12),
//                         CategoriesWidget(
//                           categories: _categories,
//                           onCategoryTap: _handleCategoryTap,
//                         ),
//                         const SizedBox(height: 30),
//                       ],

//                       // Banner Section
//                       if (_isLoadingBanners)
//                         const Center(child: CircularProgressIndicator())
//                       else if (_errorBanners != null)
//                         Center(
//                           child: Column(
//                             children: [
//                               Text('Error loading banners: $_errorBanners'),
//                               ElevatedButton(
//                                 onPressed: _fetchBanners,
//                                 child: const Text('Retry'),
//                               ),
//                             ],
//                           ),
//                         )
//                       else if (_banners.isNotEmpty) ...[
//                         Column(
//                           children: [
//                             CarouselSlider(
//                               items: _banners.map((banner) {
//                                 return Container(
//                                   margin: const EdgeInsets.symmetric(horizontal: 5),
//                                   child: Stack(
//                                     children: [
//                                       ClipRRect(
//                                         borderRadius: BorderRadius.circular(12),
//                                         child: Image.network(
//                                           banner.imageUrl,
//                                           fit: BoxFit.cover,
//                                           width: double.infinity,
//                                           height: 150,
//                                           errorBuilder: (context, error, stackTrace) {
//                                             return Container(
//                                               width: double.infinity,
//                                               height: 150,
//                                               decoration: BoxDecoration(
//                                                 gradient: LinearGradient(
//                                                   colors: [Colors.blue.shade300, Colors.purple.shade300],
//                                                   begin: Alignment.topLeft,
//                                                   end: Alignment.bottomRight,
//                                                 ),
//                                                 borderRadius: BorderRadius.circular(12),
//                                               ),
//                                               child: Center(
//                                                 child: Text(
//                                                   banner.title ?? 'Banner',
//                                                   style: const TextStyle(
//                                                     color: Colors.white,
//                                                     fontSize: 18,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 ),
//                                               ),
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                       // Gradient overlay for better text visibility
//                                       Positioned.fill(
//                                         child: Container(
//                                           decoration: BoxDecoration(
//                                             borderRadius: BorderRadius.circular(12),
//                                             gradient: LinearGradient(
//                                               begin: Alignment.topCenter,
//                                               end: Alignment.bottomCenter,
//                                               colors: [
//                                                 Colors.transparent,
//                                                 Colors.black.withOpacity(0.4),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       // Text overlay
//                                       if (banner.title != null || banner.subtitle != null)
//                                         Positioned(
//                                           left: 16,
//                                           bottom: 16,
//                                           right: 16,
//                                           child: Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             mainAxisSize: MainAxisSize.min,
//                                             children: [
//                                               if (banner.title != null)
//                                                 Text(
//                                                   banner.title!,
//                                                   style: const TextStyle(
//                                                     color: Colors.white,
//                                                     fontSize: 18,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 ),
//                                               if (banner.subtitle != null) ...[
//                                                 const SizedBox(height: 4),
//                                                 Text(
//                                                   banner.subtitle!,
//                                                   style: const TextStyle(
//                                                     color: Colors.white70,
//                                                     fontSize: 12,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ],
//                                           ),
//                                         ),
//                                     ],
//                                   ),
//                                 );
//                               }).toList(),
//                               options: CarouselOptions(
//                                 height: 150,
//                                 autoPlay: true,
//                                 autoPlayInterval: const Duration(seconds: 4),
//                                 enlargeCenterPage: true,
//                                 viewportFraction: 1.0,
//                                 enableInfiniteScroll: true,
//                                 onPageChanged: (index, reason) {
//                                   setState(() {
//                                     _currentIndex = index;
//                                   });
//                                 },
//                               ),
//                             ),
//                             const SizedBox(height: 12),
//                             // Page Indicators
//                             AnimatedSmoothIndicator(
//                               activeIndex: _currentIndex,
//                               count: _banners.length,
//                               effect: ExpandingDotsEffect(
//                                 activeDotColor: Colors.blue,
//                                 dotColor: Colors.grey.shade300,
//                                 dotHeight: 8,
//                                 dotWidth: 8,
//                                 spacing: 6,
//                                 expansionFactor: 2,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 30),
//                       ],

//                       // Nearby Restaurants Section
//                       if (_isLoadingNearbyRestaurants)
//                         const Center(child: CircularProgressIndicator())
//                       else if (_errorNearbyRestaurants != null)
//                         Center(
//                           child: Column(
//                             children: [
//                               Text('Error loading restaurants: $_errorNearbyRestaurants'),
//                               ElevatedButton(
//                                 onPressed: _fetchNearbyRestaurants,
//                                 child: const Text('Retry'),
//                               ),
//                             ],
//                           ),
//                         )
//                       else if (_nearbyRestaurants.isNotEmpty) ...[
//                         const Text('Restaurant Near You',
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.w600)),
//                         const SizedBox(height: 16),
//                         _buildRestaurantSection(),
//                       ],

//                       // Featured Stores Section
//                       if (_isLoadingFeaturedStores)
//                         const Center(child: CircularProgressIndicator())
//                       else if (_errorFeaturedStores != null)
//                         Center(
//                           child: Column(
//                             children: [
//                               Text('Error loading featured stores: $_errorFeaturedStores'),
//                               ElevatedButton(
//                                 onPressed: _fetchFeaturedStores,
//                                 child: const Text('Retry'),
//                               ),
//                             ],
//                           ),
//                         )
//                       else if (_featuredStores.isNotEmpty) ...[
//                         const Text('Featured Stores',
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.w600)),
//                         const SizedBox(height: 16),
//                         _buildFeaturedStoresSection(),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),

//               SliverPersistentHeader(
//                 pinned: true,
//                 delegate: _SliverAppBarDelegate(
//                   minHeight: 60,
//                   maxHeight: 60,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 4,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Container(
//                       margin: const EdgeInsets.symmetric(
//                           horizontal: 20, vertical: 12),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[100],
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                       child: TabBar(
//                         controller: _tabController,
//                         indicator: BoxDecoration(
//                           color: Colors.orange,
//                           borderRadius: BorderRadius.circular(25),
//                         ),
//                         indicatorSize: TabBarIndicatorSize.tab,
//                         dividerColor: Colors.transparent,
//                         labelColor: Colors.white,
//                         unselectedLabelColor: Colors.grey[700],
//                         labelStyle: const TextStyle(
//                           fontWeight: FontWeight.w600,
//                           fontSize: 14,
//                         ),
//                         unselectedLabelStyle: const TextStyle(
//                           fontWeight: FontWeight.w500,
//                           fontSize: 14,
//                         ),
//                         tabs: const [
//                           Tab(text: 'All Stores'),
//                           Tab(text: 'Restaurants'),
//                           Tab(text: 'Shops'),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               // Tab content
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: IndexedStack(
//                     index: _tabController.index,
//                     children: [
//                       _buildAllStoresList(),
//                       _buildAllRestaurantsList(),
//                       _buildAllRestaurantsList(),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAllStoresList() {
//     if (_isLoadingAllStores) {
//       return const Center(child: CircularProgressIndicator());
//     }
    
//     if (_errorAllStores != null) {
//       return Center(
//         child: Column(
//           children: [
//             Text('Error loading stores: $_errorAllStores'),
//             ElevatedButton(
//               onPressed: _fetchAllStores,
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }
    
//     if (_allStores.isEmpty) {
//       return const Center(
//         child: Text('No stores available'),
//       );
//     }

//     return Column(
//       children: _allStores
//           .map((store) => Padding(
//                 padding: const EdgeInsets.only(bottom: 16),
//                 child: StoreCard2Widget({
//                   'name': store.name,
//                   'category': store.categories.isNotEmpty ? store.categories.first : 'Store',
//                   'rating': store.rating,
//                   'time': store.deliveryTime,
//                   'distance': _currentPosition != null ? 
//                     '${_calculateDistance(store.coordinates).toStringAsFixed(1)} Km' : 'N/A',
//                   'imageUrl': store.image,
//                 }),
//               ))
//           .toList(),
//     );
//   }

//   Widget _buildAllRestaurantsList() {
//     if (_isLoadingAllRestaurants) {
//       return const Center(child: CircularProgressIndicator());
//     }
    
//     if (_errorAllRestaurants != null) {
//       return Center(
//         child: Column(
//           children: [
//             Text('Error loading restaurants: $_errorAllRestaurants'),
//             ElevatedButton(
//               onPressed: _fetchAllRestaurants,
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }
    
//     if (_allRestaurants.isEmpty) {
//       return const Center(
//         child: Text('No restaurants available'),
//       );
//     }

//     return Column(
//       children: _allRestaurants
//           .map((restaurant) => Padding(
//                 padding: const EdgeInsets.only(bottom: 16),
//                 child: ListCardWidget({
//                   'name': restaurant.name,
//                   'category': restaurant.categories.isNotEmpty ? restaurant.categories.first : 'Restaurant',
//                   'rating': restaurant.rating,
//                   'time': restaurant.deliveryTime,
//                   'distance': _currentPosition != null ? 
//                     '${_calculateDistance(restaurant.coordinates).toStringAsFixed(1)} Km' : 'N/A',
//                   'imageUrl': restaurant.image,
//                 }),
//               ))
//           .toList(),
//     );
//   }

//   Widget _buildRestaurantSection() {
//     if (_nearbyRestaurants.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return SizedBox(
//       height: 240, // Fixed height for the horizontal section
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: _nearbyRestaurants.length,
//         itemBuilder: (context, index) {
//           final restaurant = _nearbyRestaurants[index];
//           return Container(
//             width: 280, // Fixed width for each restaurant card
//             margin: EdgeInsets.only(
//               right: index == _nearbyRestaurants.length - 1 ? 0 : 16,
//             ),
//             child: RestaurantCardWidget({
//               'name': restaurant.name,
//               'rating': restaurant.rating,
//               'time': restaurant.deliveryTime,
//               'distance': _currentPosition != null ? 
//                 '${_calculateDistance(restaurant.coordinates).toStringAsFixed(1)} Km' : 'N/A',
//               'imageUrl': restaurant.image,
//             }),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildFeaturedStoresSection() {
//     if (_featuredStores.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return SizedBox(
//       height: 250, // Fixed height for the horizontal section
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: _featuredStores.length,
//         itemBuilder: (context, index) {
//           final store = _featuredStores[index];
//           return Container(
//             width: 280, // Fixed width for each store card
//             margin: EdgeInsets.only(
//               right: index == _featuredStores.length - 1 ? 0 : 16,
//             ),
//             child: StoreCardWidget({
//               'name': store.name,
//               'category': store.categories.isNotEmpty ? store.categories.first : 'Store',
//               'rating': store.rating,
//               'time': store.deliveryTime,
//               'distance': _currentPosition != null ? 
//                 '${_calculateDistance(store.coordinates).toStringAsFixed(1)} Km' : 'N/A',
//               'imageUrl': store.image,
//             }),
//           );
//         },
//       ),
//     );
//   }

//   void _handleCategoryTap(String categoryName) {
//     // Special handling for T-Mart
//     if (categoryName.toLowerCase() == 't-mart' || categoryName.toLowerCase() == 'tmart') {
//       Navigator.pushNamed(context, AppRoutes.tMart);
//     } else {
//       // Navigate to category products screen
//       Navigator.pushNamed(
//         context,
//         AppRoutes.categoryProducts,
//         arguments: {'category': categoryName},
//       );
//     }
//   }

//   double _calculateDistance(Map<String, dynamic>? coordinates) {
//     if (_currentPosition == null || coordinates == null) {
//       return 0.0;
//     }
    
//     try {
//       final List<dynamic> coords = coordinates['coordinates'] ?? [];
//       if (coords.length >= 2) {
//         final double vendorLon = coords[0].toDouble();
//         final double vendorLat = coords[1].toDouble();
        
//         return Geolocator.distanceBetween(
//           _currentPosition!.latitude,
//           _currentPosition!.longitude,
//           vendorLat,
//           vendorLon,
//         ) / 1000; // Convert to kilometers
//       }
//     } catch (e) {
//       print('Error calculating distance: $e');
//     }
    
//     return 0.0;
//   }
// }

// class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
//   final double minHeight;
//   final double maxHeight;
//   final Widget child;

//   _SliverAppBarDelegate({
//     required this.minHeight,
//     required this.maxHeight,
//     required this.child,
//   });

//   @override
//   double get minExtent => minHeight;

//   @override
//   double get maxExtent => maxHeight;

//   @override
//   Widget build(
//       BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return SizedBox.expand(child: child);
//   }

//   @override
//   bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
//     return maxHeight != oldDelegate.maxHeight ||
//         minHeight != oldDelegate.minHeight ||
//         child != oldDelegate.child;
//   }
// }
