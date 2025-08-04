// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:tuukatuu/presentation/screens/unified_cart_screen.dart';
// import 'package:tuukatuu/providers/mart_cart_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:tuukatuu/services/api_service.dart';
// import 'package:tuukatuu/presentation/widgets/tmart_section_header.dart';
// import 'package:tuukatuu/presentation/widgets/tmart_category_card.dart';
// import 'package:tuukatuu/presentation/widgets/tmart_product_card.dart';
// import 'package:tuukatuu/presentation/widgets/tmart_recently_viewed_card.dart';
// import 'package:tuukatuu/presentation/widgets/tmart_deal_card.dart';
// import 'package:tuukatuu/presentation/widgets/daily_essentials_section.dart';
// import 'package:tuukatuu/presentation/screens/tmart_cart_screen.dart';
// import 'package:tuukatuu/presentation/screens/recently_viewed_page.dart';
// import 'package:tuukatuu/providers/recently_viewed_provider.dart';
// import 'package:tuukatuu/presentation/screens/product_details_screen.dart';
// import 'package:tuukatuu/models/product.dart';
// import 'package:tuukatuu/presentation/widgets/tmart_skeleton_loader.dart';
// import 'package:tuukatuu/providers/mart_cart_provider.dart';
// import 'package:tuukatuu/presentation/widgets/tmart_today_deal_card.dart';
// import 'package:tuukatuu/presentation/widgets/cached_image.dart';
// import 'package:tuukatuu/routes.dart';
// import 'package:tuukatuu/presentation/screens/tmart_product_detail_screen.dart';
// import 'package:tuukatuu/presentation/screens/tmart_dedicated_cart_screen.dart';

// class TMartScreen extends StatefulWidget {
//   const TMartScreen({super.key});

//   @override
//   State<TMartScreen> createState() => _TMartScreenState();
// }

// class _TMartScreenState extends State<TMartScreen> with TickerProviderStateMixin {
//   late PageController _pageController;
//   int _currentPage = 0;
//   late Timer _timer;
//   final TextEditingController _searchController = TextEditingController();
//   bool _isLoading = false;
//   List<Map<String, dynamic>> _banners = [];
//   List<Map<String, dynamic>> _categories = [];
//   List<Map<String, dynamic>> _popularProducts = [];
//   List<Map<String, dynamic>> _dailyEssentials = [];
//   List<Map<String, dynamic>> _deals = [];
//   List<Map<String, dynamic>> _todayDeals = [];
//   List<Map<String, dynamic>> _recommendations = [];
  
//   // Cart state management
//   Map<String, int> _itemQuantities = {};
//   Map<String, AnimationController> _itemAnimationControllers = {};
//   AnimationController? _cartAnimationController;
//   bool _showCartIndicator = false;
//   int _cartItemCount = 0;

//   // Swiggy color scheme
//   static const Color swiggyOrange = Color(0xFFFC8019);
//   static const Color swiggyRed = Color(0xFFE23744);
//   static const Color swiggyDark = Color(0xFF1C1C1C);
//   static const Color swiggyLight = Color(0xFFF8F9FA);

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(initialPage: _currentPage);
//     _cartAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _startBannerTimer();
//     _loadData();
//   }

//   void _startBannerTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
//       if (_banners.isNotEmpty) {
//         if (_currentPage < _banners.length - 1) {
//           _currentPage++;
//         } else {
//           _currentPage = 0;
//         }
//         _pageController.animateToPage(
//           _currentPage,
//           duration: const Duration(milliseconds: 500),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
//   }

//   Future<void> _loadData() async {
//     setState(() => _isLoading = true);
//     try {
//       // Load data from API
//       final bannersResponse = await ApiService.get('/tmart/banners');
//       if (bannersResponse['success']) {
//         _banners = List<Map<String, dynamic>>.from(bannersResponse['data']);
//       } else {
//         _banners = _getMockBanners();
//       }

//       final categoriesResponse = await ApiService.get('/tmart/categories/featured?limit=8');
//       if (categoriesResponse['success']) {
//         _categories = List<Map<String, dynamic>>.from(categoriesResponse['data']);
//         // print(_categories);
//       } else {
//         _categories = _getMockCategories();
//       }

//       // Load vendor products for T-Mart (fast delivery)
//       final popularResponse = await ApiService.get('/products');
//       if (popularResponse is List) {
//         _popularProducts = List<Map<String, dynamic>>.from(popularResponse);
//         print('✅ Loaded ${_popularProducts.length} vendor products for T-Mart from API');
        
//         // Debug: Print first few products to see vendor info
//         if (_popularProducts.isNotEmpty) {
//           print('🔍 Sample products loaded:');
//           for (int i = 0; i < _popularProducts.length && i < 3; i++) {
//             final product = _popularProducts[i];
//             print('   ${i + 1}. ${product['name']} - Vendor ID: ${product['vendorId']}, Vendor Name: ${product['vendorName']}');
//           }
//         }
//       } else {
//         print('⚠️ Failed to load vendor products from API, using mock data');
//         _popularProducts = _getMockPopularProducts();
//       }

//       // Load vendor products for daily essentials (fast delivery)
//       final dailyEssentialsResponse = await ApiService.get('/products');
//       if (dailyEssentialsResponse is List) {
//         _dailyEssentials = List<Map<String, dynamic>>.from(dailyEssentialsResponse);
//         print('✅ Loaded ${_dailyEssentials.length} vendor products for daily essentials from API');
//       } else {
//         print('⚠️ Failed to load vendor products for daily essentials from API, using mock data');
//         _dailyEssentials = _getMockDailyEssentials();
//       }

//       // Load recommendations
//       await _loadRecommendations();

//       final dealsResponse = await ApiService.get('/tmart/deals');
//       if (dealsResponse['success']) {
//         _deals = List<Map<String, dynamic>>.from(dealsResponse['data']);
//       } else {
//         _deals = _getMockDeals();
//       }

//       // Load today's deals
//       final todayDealsResponse = await ApiService.get('/today-deals');
//       if (todayDealsResponse['success']) {
//         _todayDeals = List<Map<String, dynamic>>.from(todayDealsResponse['data']);
//         print('✅ Loaded ${_todayDeals.length} today\'s deals from API');
//       } else {
//         print('⚠️ Failed to load today\'s deals from API, using mock data');
//         _todayDeals = _getMockTodayDeals();
//       }

//       // Load vendor products for recommendations (fast delivery)
//       final recommendationsResponse = await ApiService.get('/products');
//       if (recommendationsResponse is List) {
//         _recommendations = List<Map<String, dynamic>>.from(recommendationsResponse);
//         print('✅ Loaded ${_recommendations.length} vendor products for recommendations from API');
        
//         // Debug: Print first few products to see vendor info
//         if (_recommendations.isNotEmpty) {
//           print('🔍 Sample recommendations loaded:');
//           for (int i = 0; i < _recommendations.length && i < 3; i++) {
//             final product = _recommendations[i];
//             print('   ${i + 1}. ${product['name']} - Vendor ID: ${product['vendorId']}, Vendor Name: ${product['vendorName']}');
//           }
//         }
//       } else {
//         print('⚠️ Failed to load vendor products for recommendations from API, using mock data');
//         _recommendations = _getMockRecommendations();
//       }
//     } catch (e) {
//       print('❌ Error loading T-Mart data: $e');
//       // Fallback to mock data
//       _banners = _getMockBanners();
//       _categories = _getMockCategories();
//       _popularProducts = _getMockPopularProducts();
//       _dailyEssentials = _getMockDailyEssentials();
//       _deals = _getMockDeals();
//       _todayDeals = _getMockTodayDeals();
//       _recommendations = _getMockRecommendations();
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   List<Map<String, dynamic>> _getMockTodayDeals() {
//     return [
//       {
//         '_id': 'deal1',
//         'name': 'Fresh Organic Bananas',
//         'imageUrl': 'https://via.placeholder.com/300x300/4CAF50/FFFFFF?text=Bananas',
//         'originalPrice': 120,
//         'price': 80,
//         'discount': 33,
//         'description': 'Sweet organic bananas at unbeatable price!',
//         'dealType': 'percentage',
//         'category': 'Fruits',
//         'featured': true,
//         'remainingQuantity': 25,
//         'soldQuantity': 25,
//         'maxQuantity': 50,
//         'endDate': DateTime.now().add(const Duration(hours: 6)),
//         'isExpired': false,
//         'isValid': true,
//         'tags': ['organic', 'fruits', 'healthy']
//       },
//       {
//         '_id': 'deal2',
//         'name': 'Premium Whole Milk',
//         'imageUrl': 'https://via.placeholder.com/300x300/2196F3/FFFFFF?text=Milk',
//         'originalPrice': 85,
//         'price': 65,
//         'discount': 24,
//         'description': 'Fresh whole milk with 3.5% fat content',
//         'dealType': 'percentage',
//         'category': 'Dairy',
//         'featured': true,
//         'remainingQuantity': 15,
//         'soldQuantity': 15,
//         'maxQuantity': 30,
//         'endDate': DateTime.now().add(const Duration(hours: 12)),
//         'isExpired': false,
//         'isValid': true,
//         'tags': ['dairy', 'fresh', 'protein']
//       },
//       {
//         '_id': 'deal3',
//         'name': 'Organic Brown Bread',
//         'imageUrl': 'https://via.placeholder.com/300x300/FF9800/FFFFFF?text=Bread',
//         'originalPrice': 95,
//         'price': 70,
//         'discount': 26,
//         'description': 'Healthy brown bread made with whole grains',
//         'dealType': 'percentage',
//         'category': 'Bakery',
//         'featured': false,
//         'remainingQuantity': 10,
//         'soldQuantity': 15,
//         'maxQuantity': 25,
//         'endDate': DateTime.now().add(const Duration(hours: 18)),
//         'isExpired': false,
//         'isValid': true,
//         'tags': ['organic', 'bakery', 'whole-grain']
//       }
//     ];
//   }

//   Future<void> _loadRecommendations({bool forceRefresh = false}) async {
//     try {
//       final recommendationsResponse = await ApiService.get('/tmart/recommendations', params: {
//         'limit': '12',
//         'forceRefresh': forceRefresh.toString(),
//       });
      
//       if (recommendationsResponse['success']) {
//         setState(() {
//           _recommendations = List<Map<String, dynamic>>.from(recommendationsResponse['data']);
//         });
//         print('🎯 Loaded ${_recommendations.length} recommendations (refreshed: $forceRefresh)');
//       } else {
//         print('⚠️ Failed to load recommendations from API, using mock data');
//         setState(() {
//           _recommendations = _getMockRecommendations();
//         });
//       }
//     } catch (e) {
//       print('❌ Error loading recommendations: $e');
//       setState(() {
//         _recommendations = _getMockRecommendations();
//       });
//     }
//   }

//   List<Map<String, dynamic>> _getMockBanners() {
//     return [
//       {
//         'imageUrl': 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&h=400&fit=crop',
//         'title': 'Fresh Groceries',
//         'subtitle': 'Up to 50% off',
//       },
//       {
//         'imageUrl': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&h=400&fit=crop',
//         'title': 'Quick Delivery',
//         'subtitle': '10 minutes or free',
//       },
//       {
//         'imageUrl': 'https://images.unsplash.com/photo-1534723452862-4c874018d66d?w=800&h=400&fit=crop',
//         'title': 'Premium Quality',
//         'subtitle': 'Best products guaranteed',
//       },
//     ];
//   }

//   List<Map<String, dynamic>> _getMockCategories() {
//     return [
//       {'name': 'Fruits & Vegetables', 'iconUrl': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=200&h=200&fit=crop', 'color': Colors.green},
//       {'name': 'Dairy & Eggs', 'iconUrl': 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=200&h=200&fit=crop', 'color': Colors.blue},
//       {'name': 'Bakery', 'iconUrl': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200&h=200&fit=crop', 'color': Colors.orange},
//       {'name': 'Meat & Fish', 'iconUrl': 'https://images.unsplash.com/photo-1516594798947-e65505dbb29d?w=200&h=200&fit=crop', 'color': Colors.red},
//       {'name': 'Snacks', 'iconUrl': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=200&h=200&fit=crop', 'color': Colors.purple},
//       {'name': 'Beverages', 'iconUrl': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=200&h=200&fit=crop', 'color': Colors.cyan},
//       {'name': 'Household', 'iconUrl': 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=200&h=200&fit=crop', 'color': Colors.indigo},
//       {'name': 'Personal Care', 'iconUrl': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=200&h=200&fit=crop', 'color': Colors.pink},
//     ];
//   }

//   List<Map<String, dynamic>> _getMockDailyEssentials() {
//     return [
//       {'_id': 'milk1', 'name': 'Fresh Milk', 'price': 45.0, 'imageUrl': 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&h=400&fit=crop', 'unit': '1L', 'category': 'Dairy & Eggs'},
//       {'_id': 'eggs1', 'name': 'Farm Eggs', 'price': 60.0, 'imageUrl': 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400&h=400&fit=crop', 'unit': '12 pcs', 'category': 'Dairy & Eggs'},
//       {'_id': 'bread1', 'name': 'Whole Wheat Bread', 'price': 35.0, 'imageUrl': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=400&fit=crop', 'unit': '400g', 'category': 'Bakery'},
//       {'_id': 'banana1', 'name': 'Fresh Bananas', 'price': 40.0, 'imageUrl': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=400&fit=crop', 'unit': '1kg', 'category': 'Fruits & Vegetables'},
//       {'_id': 'tomato1', 'name': 'Fresh Tomatoes', 'price': 30.0, 'imageUrl': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=400&fit=crop', 'unit': '1kg', 'category': 'Fruits & Vegetables'},
//       {'_id': 'onion1', 'name': 'Red Onions', 'price': 25.0, 'imageUrl': 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400&h=400&fit=crop', 'unit': '1kg', 'category': 'Fruits & Vegetables'},
//     ];
//   }

//   List<Map<String, dynamic>> _getMockPopularProducts() {
//     return [
//       {'_id': 'banana1', 'name': 'Fresh Bananas', 'price': 40.0, 'originalPrice': 50.0, 'discount': 20, 'imageUrl': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=400&fit=crop', 'rating': 4.5, 'unit': '1kg', 'vendorId': 'tmart_vendor_1', 'vendorName': 'T-Mart Express'},
//       {'_id': 'juice1', 'name': 'Orange Juice', 'price': 120.0, 'originalPrice': 150.0, 'discount': 20, 'imageUrl': 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400&h=400&fit=crop', 'rating': 4.3, 'unit': '1L', 'vendorId': 'tmart_vendor_2', 'vendorName': 'T-Mart Express'},
//       {'_id': 'pasta1', 'name': 'Italian Pasta', 'price': 85.0, 'originalPrice': 100.0, 'discount': 15, 'imageUrl': 'https://images.unsplash.com/photo-1544384951-6db2a7bec5d6?w=400&h=400&fit=crop', 'rating': 4.7, 'unit': '500g', 'vendorId': 'tmart_vendor_3', 'vendorName': 'T-Mart Express'},
//       {'_id': 'tomato1', 'name': 'Fresh Tomatoes', 'price': 30.0, 'originalPrice': 40.0, 'discount': 25, 'imageUrl': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=400&fit=crop', 'rating': 4.2, 'unit': '1kg', 'vendorId': 'tmart_vendor_4', 'vendorName': 'T-Mart Express'},
//     ];
//   }

//   List<Map<String, dynamic>> _getMockDeals() {
//     return [
//       {'id': 'deal1', 'name': 'Buy 1 Get 1 Free', 'description': 'On selected fruits', 'imageUrl': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=400&h=400&fit=crop', 'validUntil': '2024-12-31'},
//       {'id': 'deal2', 'name': '₹99 Store', 'description': 'Everything at ₹99', 'imageUrl': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&h=400&fit=crop', 'validUntil': '2024-12-31'},
//       {'id': 'deal3', 'name': '50% Off', 'description': 'On dairy products', 'imageUrl': 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&h=400&fit=crop', 'validUntil': '2024-12-31'},
//     ];
//   }

//   List<Map<String, dynamic>> _getMockRecommendations() {
//     return [
//       {'_id': 'cheese1', 'name': 'Cheddar Cheese', 'price': 200.0, 'imageUrl': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop', 'rating': 4.4, 'unit': '200g', 'vendorId': 'tmart_vendor_5', 'vendorName': 'T-Mart Express'},
//       {'_id': 'yogurt1', 'name': 'Greek Yogurt', 'price': 60.0, 'imageUrl': 'https://images.unsplash.com/photo-1547514701-42782101795e?w=400&h=400&fit=crop', 'rating': 4.6, 'unit': '150g', 'vendorId': 'tmart_vendor_6', 'vendorName': 'T-Mart Express'},
//       {'_id': 'avocado1', 'name': 'Fresh Avocado', 'price': 150.0, 'imageUrl': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&h=400&fit=crop', 'rating': 4.8, 'unit': '1 pc', 'vendorId': 'tmart_vendor_7', 'vendorName': 'T-Mart Express'},
//       {'_id': 'salmon1', 'name': 'Atlantic Salmon', 'price': 800.0, 'imageUrl': 'https://images.unsplash.com/photo-1516594798947-e65505dbb29d?w=400&h=400&fit=crop', 'rating': 4.5, 'unit': '500g', 'vendorId': 'tmart_vendor_8', 'vendorName': 'T-Mart Express'},
//       {'_id': 'bread1', 'name': 'Whole Wheat Bread', 'price': 45.0, 'imageUrl': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=400&fit=crop', 'rating': 4.3, 'unit': '400g', 'vendorId': 'tmart_vendor_9', 'vendorName': 'T-Mart Express'},
//       {'_id': 'eggs1', 'name': 'Farm Fresh Eggs', 'price': 120.0, 'imageUrl': 'https://images.unsplash.com/photo-1569288063648-850c6c2a2d0e?w=400&h=400&fit=crop', 'rating': 4.7, 'unit': '12 pcs', 'vendorId': 'tmart_vendor_10', 'vendorName': 'T-Mart Express'},
//       {'_id': 'milk1', 'name': 'Organic Milk', 'price': 80.0, 'imageUrl': 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&h=400&fit=crop', 'rating': 4.5, 'unit': '1L', 'vendorId': 'tmart_vendor_11', 'vendorName': 'T-Mart Express'},
//       {'_id': 'honey1', 'name': 'Pure Honey', 'price': 180.0, 'imageUrl': 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=400&h=400&fit=crop', 'rating': 4.6, 'unit': '500g', 'vendorId': 'tmart_vendor_12', 'vendorName': 'T-Mart Express'},
//     ];
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     _timer.cancel();
//     _searchController.dispose();
//     _cartAnimationController?.dispose();
//     // Dispose all item animation controllers
//     for (final controller in _itemAnimationControllers.values) {
//       controller.dispose();
//     }
//     _itemAnimationControllers.clear();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final martCartProvider = Provider.of<MartCartProvider>(context);
//     final recentlyViewedProvider = Provider.of<RecentlyViewedProvider>(context);
//     return Scaffold(
//       backgroundColor: swiggyLight,
//       appBar: _buildAppBar(martCartProvider),
//       body: Stack(
//         children: [
//           _isLoading 
//             ? _buildSkeletonLoader()
//             : RefreshIndicator(
//                 onRefresh: _loadData,
//                 child: SingleChildScrollView(
//                   physics: const AlwaysScrollableScrollPhysics(),
//                   padding: const EdgeInsets.only(bottom: 20),
//                   child: Column(
//                     children: [
//                       _buildSearchAndBannerSection(),
//                       _buildCategoriesSection(),
//                       _buildDailyEssentialsSection(martCartProvider),
//                       _buildTodayDealsSection(),
//                       _buildPopularProductsSection(martCartProvider, recentlyViewedProvider),
//                       _buildRecommendedProductsSection(martCartProvider, recentlyViewedProvider),
//                       _buildRecentlyViewedSection(martCartProvider, recentlyViewedProvider),
//                       const SizedBox(height: 140),
//                     ],
//                   ),
//                 ),
//               ),
//           if (_showCartIndicator)
//             Positioned(
//               bottom: 100,
//               left: 0,
//               right: 0,
//               child: Center(
//                 child: ScaleTransition(
//                   scale: CurvedAnimation(
//                     parent: _cartAnimationController!,
//                     curve: Curves.elasticOut,
//                   ),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                     decoration: BoxDecoration(
//                       color: Colors.black87,
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Icon(
//                           Icons.shopping_cart,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           'Added to cart ($_cartItemCount)',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           if (_cartItemCount > 0)
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 10,
//                       offset: const Offset(0, -5),
//                     ),
//                   ],
//                 ),
                
//               ),
//             ),
//         ],
//       ),
//       floatingActionButton: _buildFloatingActionButton(martCartProvider),
//     );
//   }

//   PreferredSizeWidget _buildAppBar(MartCartProvider martCartProvider) {
//     return AppBar(
//       backgroundColor: swiggyOrange,
//       elevation: 0,
//       leading: IconButton(
//         icon: const Icon(Icons.menu, color: Colors.white),
//         onPressed: () {
//           Scaffold.of(context).openDrawer();
//         },
//       ),
//       title: Column(
//         children: [
//           Text(
//             'T-Mart Express',
//             style: GoogleFonts.poppins(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           Text(
//             'Fast Delivery Service',
//             style: GoogleFonts.poppins(
//               fontSize: 12,
//               color: Colors.white70,
//             ),
//           ),
//         ],
//       ),
//       centerTitle: true,
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.notifications_outlined, color: Colors.white),
//           onPressed: () {
//             // TODO: Navigate to notifications
//           },
//         ),
//         Stack(
//           children: [
//             IconButton(
//               icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
//               onPressed: () {
//                 Navigator.push(context, MaterialPageRoute(builder: (context) => const TMartDedicatedCartScreen()));
//               },
//             ),
//             if (martCartProvider.itemCount > 0)
//               Positioned(
//                 right: 8,
//                 top: 8,
//                 child: Container(
//                   padding: const EdgeInsets.all(2),
//                   decoration: BoxDecoration(
//                     color: swiggyRed,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   constraints: const BoxConstraints(
//                     minWidth: 16,
//                     minHeight: 16,
//                   ),
//                   child: Text(
//                     martCartProvider.itemCount.toString(),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildSearchAndBannerSection() {
//     return Container(
//       decoration: const BoxDecoration(
//         color: swiggyOrange,
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(20),
//           bottomRight: Radius.circular(20),
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: TextField(
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                   hintText: "Search for groceries, fruits, vegetables...",
//                   hintStyle: TextStyle(color: Colors.grey[400]),
//                   prefixIcon: const Icon(Icons.search, color: Colors.grey),
//                   suffixIcon: IconButton(
//                     icon: const Icon(Icons.clear, color: Colors.grey),
//                     onPressed: () {
//                       _searchController.clear();
//                     },
//                   ),
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                 ),
//                 onSubmitted: (value) {
//                   if (value.trim().isNotEmpty) {
//                     print('🔍 Search submitted from T-Mart screen: "$value"'); // Debug log
//                     Navigator.pushNamed(context, '/tmart-search', arguments: value.trim());
//                   }
//                 },
//               ),
//             ),
//             const SizedBox(height: 20),
            
//             if (_banners.isNotEmpty) ...[
//               SizedBox(
//                 height: 180,
//                 child: PageView.builder(
//                   controller: _pageController,
//                   itemCount: _banners.length,
//                   onPageChanged: (index) {
//                     setState(() {
//                       _currentPage = index;
//                     });
//                   },
//                   itemBuilder: (context, index) {
//                     final banner = _banners[index];
//                     return Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 4.0),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             blurRadius: 8,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(16),
//                         child: Stack(
//                           children: [
//                             Image.network(
//                               banner['imageUrl'],
//                               width: double.infinity,
//                               height: double.infinity,
//                               fit: BoxFit.cover,
//                               errorBuilder: (_, __, ___) => Container(
//                                 color: Colors.grey[300],
//                                 child: const Icon(Icons.image, size: 50),
//                               ),
//                             ),
//                             Container(
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   begin: Alignment.topCenter,
//                                   end: Alignment.bottomCenter,
//                                   colors: [
//                                     Colors.transparent,
//                                     Colors.black.withOpacity(0.7),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             Positioned(
//                               bottom: 16,
//                               left: 16,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     banner['title'] ?? '',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   Text(
//                                     banner['subtitle'] ?? '',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 14,
//                                       color: Colors.white70,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 16),
              
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(_banners.length, (index) {
//                   return AnimatedContainer(
//                     duration: const Duration(milliseconds: 300),
//                     margin: const EdgeInsets.symmetric(horizontal: 4.0),
//                     height: 8.0,
//                     width: _currentPage == index ? 24.0 : 8.0,
//                     decoration: BoxDecoration(
//                       color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.5),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   );
//                 }),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoriesSection() {
//     // Categories are already limited to 8 from the API
//     final featuredCategories = _categories;
//     print(featuredCategories);
//     if (featuredCategories.isEmpty) {
//       return const SizedBox.shrink();
//     }
    
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           TMartSectionHeader(
//             title: "Shop by Category",
//             icon: Icons.category,
//             onViewAll: () {
//               Navigator.pushNamed(context, '/tmart-categories');
//             },
//           ),
//           const SizedBox(height: 16),
//           GridView.builder(
//             physics: const NeverScrollableScrollPhysics(),
//             shrinkWrap: true,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 4,
//               crossAxisSpacing: 16,
//               mainAxisSpacing: 16,
//               childAspectRatio: 0.8,
//             ),
//             itemCount: featuredCategories.length,
//             itemBuilder: (context, index) {
//               final category = featuredCategories[index];
//               return TMartCategoryCard(
//                 category: category,
//                 onTap: () {
//                   Navigator.pushNamed(
//                     context, 
//                     '/tmart-category-products',
//                     arguments: {
//                       'categoryName': category['name'],
//                       'categoryDisplayName': category['displayName'] ?? category['name'],
//                     },
//                   );
//                 },
//               );
//             },
//           ),
//           if (featuredCategories.isNotEmpty) ...[
//             const SizedBox(height: 8),
//             Text(
//               '${featuredCategories.length} categories available',
//               style: GoogleFonts.poppins(
//                 fontSize: 12,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildDailyEssentialsSection(MartCartProvider martCartProvider) {
//     // DailyEssentialsSection expects UnifiedCartProvider, so we'll pass null for now
//     return DailyEssentialsSection(martCartProvider: null);
//   }

//   Widget _buildTodayDealsSection() {
//     if (_todayDeals.isEmpty) return const SizedBox.shrink();
    
//     // Limit to 5 deals
//     final limitedDeals = _todayDeals.take(5).toList();
    
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: TMartSectionHeader(
//                   title: "Today's Deals",
//                   icon: Icons.local_offer,
//                   onViewAll: () {
//                     Navigator.pushNamed(context, '/today-deals');
//                   },
//                 ),
//               ),
              
//             ],
//           ),
//           const SizedBox(height: 16),
//           SizedBox(
//             height: 290, // Reduced height to prevent overflow
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 4),
//               itemCount: limitedDeals.length,
//               itemBuilder: (context, index) {
//                 final deal = limitedDeals[index];
//                 return Container(
//                   width: 280, // Slightly reduced width
//                   margin: const EdgeInsets.only(right: 16),
//                   child: _buildTodayDealCard(deal),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTodayDealCard(Map<String, dynamic> deal) {
//     final String dealId = deal['_id'] ?? '';
//     final String name = deal['name'] ?? deal['description'] ?? 'Deal';
//     final String imageUrl = deal['imageUrl'] ?? 'https://via.placeholder.com/300x200?text=Deal';
//     final double originalPrice = (deal['originalPrice'] ?? 0).toDouble();
//     final double dealPrice = (deal['price'] ?? originalPrice * 0.8).toDouble();
//     final int discount = deal['discount'] ?? 20;
//     final String description = deal['description'] ?? '';
//     final String category = deal['category'] ?? '';
//     final bool isFeatured = deal['featured'] ?? false;
//     final int remainingQuantity = deal['remainingQuantity'] ?? 0;
//     final int soldQuantity = deal['soldQuantity'] ?? 0;
//     final int maxQuantity = deal['maxQuantity'] ?? 10;
//     final bool isExpired = deal['isExpired'] ?? false;
//     final List<dynamic> tags = deal['tags'] ?? [];
//     final DateTime? endDate = deal['endDate'] != null 
//         ? DateTime.parse(deal['endDate'].toString())
//         : null;

//     // Calculate progress percentage
//     final double progressPercentage = maxQuantity > 0 ? (soldQuantity / maxQuantity) : 0.0;
    
//     // Calculate time remaining
//     String timeRemaining = '';
//     if (endDate != null) {
//       final now = DateTime.now();
//       final difference = endDate.difference(now);
//       if (difference.isNegative) {
//         timeRemaining = 'Expired';
//       } else {
//         final hours = difference.inHours;
//         final minutes = difference.inMinutes % 60;
//         if (hours > 24) {
//           final days = hours ~/ 24;
//           timeRemaining = '$days days left';
//         } else if (hours > 0) {
//           timeRemaining = '$hours hours left';
//         } else {
//           timeRemaining = '$minutes minutes left';
//         }
//       }
//     }

//     // Get local cart quantity
//     final itemCount = _itemQuantities[name] ?? 0;
//     final animationController = _getAnimationController(name);
    
//     if (itemCount > 0 && animationController.status == AnimationStatus.dismissed) {
//       animationController.forward();
//     } else if (itemCount == 0 && animationController.status == AnimationStatus.completed) {
//       animationController.reverse();
//     }

//     final buttonWidth = Tween<double>(
//       begin: 32.0,
//       end: 100.0,
//     ).animate(CurvedAnimation(
//       parent: animationController,
//       curve: Curves.easeInOut,
//     ));

//     final colorAnimation = ColorTween(
//       begin: Colors.white,
//       end: swiggyOrange,
//     ).animate(CurvedAnimation(
//       parent: animationController,
//       curve: Curves.easeInOut,
//     ));
        
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Image with quantity controls
//           Stack(
//             children: [
//               ClipRRect(
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(12),
//                   topRight: Radius.circular(12),
//                 ),
//                 child: Image.network(
//                   imageUrl,
//                   width: double.infinity,
//                   height: 120,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => Container(
//                     height: 120,
//                     color: Colors.grey[300],
//                     child: const Icon(Icons.image, size: 30),
//                   ),
//                 ),
//               ),
              
//               // Status badges
//               if (isFeatured)
//                 Positioned(
//                   top: 8,
//                   left: 8,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: Colors.amber,
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Icon(Icons.star, size: 10, color: Colors.white),
//                         const SizedBox(width: 2),
//                         Text(
//                           'Featured',
//                           style: GoogleFonts.poppins(
//                             fontSize: 8,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
              
//               if (isExpired)
//                 Positioned(
//                   top: 8,
//                   right: 8,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: Colors.red,
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Text(
//                       'Expired',
//                       style: GoogleFonts.poppins(
//                         fontSize: 8,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
              
//               // Quantity controls overlay
//               if (!isExpired)
//                 Positioned(
//                   bottom: 8,
//                   right: 8,
//                   child: AnimatedBuilder(
//                     animation: animationController,
//                     builder: (context, child) {
//                       return Container(
//                         height: 32,
//                         width: buttonWidth.value,
//                         decoration: BoxDecoration(
//                           color: colorAnimation.value,
//                           borderRadius: BorderRadius.circular(16),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.1),
//                               blurRadius: 4,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(16),
//                           child: itemCount > 0
//                             ? Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Material(
//                                     color: Colors.transparent,
//                                     child: InkWell(
//                                       onTap: () {
//                                         setState(() {
//                                           if (itemCount > 1) {
//                                             _itemQuantities[name] = itemCount - 1;
//                                             _cartItemCount--;
//                                           } else {
//                                             _itemQuantities.remove(name);
//                                             _cartItemCount--;
//                                           }
//                                         });
//                                       },
//                                       child: SizedBox(
//                                         width: 32,
//                                         height: 32,
//                                         child: Center(
//                                           child: Icon(
//                                             Icons.remove,
//                                             color: Colors.white,
//                                             size: 16,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: 32,
//                                     child: Center(
//                                       child: Text(
//                                         itemCount.toString(),
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Material(
//                                     color: Colors.transparent,
//                                     child: InkWell(
//                                       onTap: () {
//                                         setState(() {
//                                           _itemQuantities[name] = itemCount + 1;
//                                           _cartItemCount++;
//                                         });
//                                         _addToCart(deal, 1);
//                                       },
//                                       child: SizedBox(
//                                         width: 32,
//                                         height: 32,
//                                         child: Center(
//                                           child: Icon(
//                                             Icons.add,
//                                             color: Colors.white,
//                                             size: 16,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               )
//                             : Material(
//                                 color: Colors.transparent,
//                                 child: InkWell(
//                                   onTap: () {
//                                     setState(() {
//                                       _itemQuantities[name] = 1;
//                                       _cartItemCount++;
//                                     });
//                                     _addToCart(deal, 1);
//                                   },
//                                   child: SizedBox(
//                                     width: 32,
//                                     height: 32,
//                                     child: Center(
//                                       child: Icon(
//                                         Icons.add,
//                                         color: swiggyOrange,
//                                         size: 16,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//             ],
//           ),
          
//           // Content
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Category and time remaining
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: swiggyOrange.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(
//                         category,
//                         style: GoogleFonts.poppins(
//                           fontSize: 9,
//                           fontWeight: FontWeight.w500,
//                           color: swiggyOrange,
//                         ),
//                       ),
//                     ),
//                     Text(
//                       timeRemaining,
//                       style: GoogleFonts.poppins(
//                         fontSize: 9,
//                         fontWeight: FontWeight.w500,
//                         color: isExpired ? Colors.red : Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
                
//                 const SizedBox(height: 8),
                
//                 // Deal name
//                 Text(
//                   name,
//                   style: GoogleFonts.poppins(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
                
//                 const SizedBox(height: 8),
                
//                 // Price section
//                 Row(
//                   children: [
//                     Text(
//                       '₹${dealPrice.toInt()}',
//                       style: GoogleFonts.poppins(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: swiggyOrange,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       '₹${originalPrice.toInt()}',
//                       style: GoogleFonts.poppins(
//                         fontSize: 11,
//                         decoration: TextDecoration.lineThrough,
//                         color: Colors.grey[500],
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: Colors.green,
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(
//                         '$discount% OFF',
//                         style: GoogleFonts.poppins(
//                           fontSize: 9,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
                
//                 const SizedBox(height: 8),
                
//                 // Progress bar
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Sold: $soldQuantity/$maxQuantity',
//                           style: GoogleFonts.poppins(
//                             fontSize: 9,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                         Text(
//                           '$remainingQuantity left',
//                           style: GoogleFonts.poppins(
//                             fontSize: 9,
//                             color: remainingQuantity < 5 ? Colors.red : Colors.grey[600],
//                             fontWeight: remainingQuantity < 5 ? FontWeight.w600 : FontWeight.normal,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     Container(
//                       height: 4,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[200],
//                         borderRadius: BorderRadius.circular(2),
//                       ),
//                       child: FractionallySizedBox(
//                         alignment: Alignment.centerLeft,
//                         widthFactor: progressPercentage.clamp(0.0, 1.0),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: swiggyOrange,
//                             borderRadius: BorderRadius.circular(2),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
                
//                 const SizedBox(height: 8),
                
//                 // Tags
//                 if (tags.isNotEmpty)
//                   Wrap(
//                     spacing: 4,
//                     runSpacing: 4,
//                     children: tags.take(2).map((tag) => Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: Colors.blue.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(
//                         tag.toString(),
//                         style: GoogleFonts.poppins(
//                           fontSize: 8,
//                           color: Colors.blue[700],
//                         ),
//                       ),
//                     )).toList(),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDealsSection() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           TMartSectionHeader(
//             title: "Today's Deals",
//             icon: Icons.local_offer,
//             onViewAll: () {
//               // TODO: Navigate to deals page
//             },
//           ),
//           const SizedBox(height: 16),
//           SizedBox(
//             height: 140, // Increased height to prevent overflow
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 4),
//               itemCount: _deals.length,
//               itemBuilder: (context, index) {
//                 final deal = _deals[index];
//                 return Container(
//                   width: 260, // Reduced width to prevent overflow
//                   margin: const EdgeInsets.only(right: 12),
//                   child: TMartDealCard(deal: deal),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRecommendationsSection(MartCartProvider martCartProvider, RecentlyViewedProvider recentlyViewedProvider) {
//     if (_recommendations.isEmpty) return const SizedBox.shrink();
    
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: TMartSectionHeader(
//                   title: "Fast Delivery Recommendations",
//                   icon: Icons.recommend,
//                   onViewAll: () {
//                     Navigator.pushNamed(context, '/tmart-recommended-products');
//                   },
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.refresh, color: swiggyOrange),
//                 onPressed: () => _loadRecommendations(forceRefresh: true),
//                 tooltip: 'Refresh recommendations',
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           GridView.builder(
//             physics: const NeverScrollableScrollPhysics(),
//             shrinkWrap: true,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: 16,
//               mainAxisSpacing: 16,
//               childAspectRatio: 0.75,
//             ),
//             itemCount: _recommendations.length,
//             itemBuilder: (context, index) {
//               final item = _recommendations[index];
//               final String productId = item['_id'] ?? item['id'] ?? '';
//               final int quantity = martCartProvider.getItemQuantity(productId);
              
//               return GestureDetector(
//                 onTap: () {
//                   // Add to recently viewed when product is tapped
//                   recentlyViewedProvider.addToRecentlyViewed(item);
                  
//                   // Navigate to product detail screen
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ProductDetailsScreen(
//                         product: Product.fromJson(item),
//                       ),
//                     ),
//                   );
//                 },
//                 child: TMartProductCard(
//                   item: item,
//                   quantity: quantity,
//                   onAdd: () {
//                     // Get vendor information from the product
//                     final vendorId = item['vendorId']?.toString() ?? item['vendor']?['_id']?.toString();
//                     final vendorName = item['vendorName']?.toString() ?? item['vendor']?['name']?.toString() ?? 'T-Mart Express';
                    
//                     print('🛒 Adding to T-Mart cart (recommendations): ${item['name']}');
//                     print('   Vendor ID: $vendorId');
//                     print('   Vendor Name: $vendorName');
                    
//                     martCartProvider.addItem(item, quantity: 1);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('${item['name']} added to cart'),
//                         backgroundColor: swiggyOrange,
//                         behavior: SnackBarBehavior.floating,
//                       ),
//                     );
//                   },
//                   onIncrement: () {
//                     martCartProvider.updateQuantity(productId, quantity + 1);
//                   },
//                   onDecrement: () {
//                     if (quantity > 1) {
//                       martCartProvider.updateQuantity(productId, quantity - 1);
//                     } else {
//                       martCartProvider.removeItem(productId);
//                     }
//                   },
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPopularProductsSection(MartCartProvider martCartProvider, RecentlyViewedProvider recentlyViewedProvider) {
//     if (_popularProducts.isEmpty) return const SizedBox.shrink();

//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           TMartSectionHeader(
//             title: "Fast Delivery Products",
//             icon: Icons.trending_up,
//             onViewAll: () {
//               Navigator.pushNamed(context, '/tmart-popular-products');
//             },
//           ),
//           const SizedBox(height: 16),
//           GridView.builder(
//             physics: const NeverScrollableScrollPhysics(),
//             shrinkWrap: true,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: 16,
//               mainAxisSpacing: 16,
//               childAspectRatio: 0.75,
//             ),
//             itemCount: _popularProducts.length,
//             itemBuilder: (context, index) {
//               final item = _popularProducts[index];
//               final String productId = item['_id'] ?? item['id'] ?? '';
//               final String productName = item['name'] ?? '';
//               final String imageUrl = item['imageUrl'] ?? item['image'] ?? '';
//               final double price = (item['price'] ?? 0).toDouble();
              
//               // Get local cart quantity
//               final itemCount = _itemQuantities[productName] ?? 0;
//               final animationController = _getAnimationController(productName);
              
//               if (itemCount > 0 && animationController.status == AnimationStatus.dismissed) {
//                 animationController.forward();
//               } else if (itemCount == 0 && animationController.status == AnimationStatus.completed) {
//                 animationController.reverse();
//               }

//               final buttonWidth = Tween<double>(
//                 begin: 32.0,
//                 end: 100.0,
//               ).animate(CurvedAnimation(
//                 parent: animationController,
//                 curve: Curves.easeInOut,
//               ));

//               final colorAnimation = ColorTween(
//                 begin: Colors.white,
//                 end: swiggyOrange,
//               ).animate(CurvedAnimation(
//                 parent: animationController,
//                 curve: Curves.easeInOut,
//               ));
              
//               return GestureDetector(
//                 onTap: () {
//                   // Add to recently viewed when product is tapped
//                   recentlyViewedProvider.addToRecentlyViewed(item);
                  
//                   // Navigate to product detail
//                   Navigator.pushNamed(
//                     context,
//                     AppRoutes.tmartProductDetail,
//                     arguments: {
//                       'product': item,
//                     },
//                   );
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.08),
//                         blurRadius: 6,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Stack(
//                         children: [
//                           ClipRRect(
//                             borderRadius: const BorderRadius.only(
//                               topLeft: Radius.circular(12),
//                               topRight: Radius.circular(12),
//                             ),
//                             child: CachedImage(
//                               imageUrl: imageUrl,
//                               height: 120,
//                               width: double.infinity,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                           Positioned(
//                             bottom: 8,
//                             right: 8,
//                             child: AnimatedBuilder(
//                               animation: animationController,
//                               builder: (context, child) {
//                                 return Container(
//                                   height: 32,
//                                   width: buttonWidth.value,
//                                   decoration: BoxDecoration(
//                                     color: colorAnimation.value,
//                                     borderRadius: BorderRadius.circular(16),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.1),
//                                         blurRadius: 4,
//                                         offset: const Offset(0, 2),
//                                       ),
//                                     ],
//                                   ),
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(16),
//                                     child: itemCount > 0
//                                       ? Row(
//                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             Material(
//                                               color: Colors.transparent,
//                                               child: InkWell(
//                                                 onTap: () {
//                                                   setState(() {
//                                                     if (itemCount > 1) {
//                                                       _itemQuantities[productName] = itemCount - 1;
//                                                       _cartItemCount--;
//                                                     } else {
//                                                       _itemQuantities.remove(productName);
//                                                       _cartItemCount--;
//                                                     }
//                                                   });
//                                                 },
//                                                 child: SizedBox(
//                                                   width: 32,
//                                                   height: 32,
//                                                   child: Center(
//                                                     child: Icon(
//                                                       Icons.remove,
//                                                       color: Colors.white,
//                                                       size: 16,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               width: 32,
//                                               child: Center(
//                                                 child: Text(
//                                                   itemCount.toString(),
//                                                   style: const TextStyle(
//                                                     color: Colors.white,
//                                                     fontWeight: FontWeight.bold,
//                                                     fontSize: 14,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                             Material(
//                                               color: Colors.transparent,
//                                               child: InkWell(
//                                                 onTap: () {
//                                                   setState(() {
//                                                     _itemQuantities[productName] = itemCount + 1;
//                                                     _cartItemCount++;
//                                                   });
//                                                 },
//                                                 child: SizedBox(
//                                                   width: 32,
//                                                   height: 32,
//                                                   child: Center(
//                                                     child: Icon(
//                                                       Icons.add,
//                                                       color: Colors.white,
//                                                       size: 16,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         )
//                                       : Material(
//                                           color: Colors.transparent,
//                                           child: InkWell(
//                                             onTap: () {
//                                               setState(() {
//                                                 _itemQuantities[productName] = 1;
//                                                 _cartItemCount++;
//                                               });
//                                             },
//                                             child: SizedBox(
//                                               width: 32,
//                                               height: 32,
//                                               child: Center(
//                                                 child: Icon(
//                                                   Icons.add,
//                                                   color: swiggyOrange,
//                                                   size: 16,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.all(12),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 productName,
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.black87,
//                                 ),
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 '₹${price.toInt()}',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: swiggyOrange,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRecentlyViewedSection(MartCartProvider martCartProvider, RecentlyViewedProvider recentlyViewedProvider) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           TMartSectionHeader(
//             title: "Recently Viewed",
//             icon: Icons.history,
//             onViewAll: () {
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (context) => const RecentlyViewedPage(),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 16),
//           SizedBox(
//             height: 200,
//             child: recentlyViewedProvider.itemCount == 0
//                 ? const Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.history, size: 48, color: Colors.grey),
//                         SizedBox(height: 8),
//                         Text(
//                           'No recently viewed products',
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                       ],
//                     ),
//                   )
//                 : ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: recentlyViewedProvider.getRecentlyViewed(limit: 10).length,
//                     itemBuilder: (context, index) {
//                       final item = recentlyViewedProvider.getRecentlyViewed(limit: 10)[index];
//                       final String productId = item['_id'] ?? item['id'];
//                       final int quantity = martCartProvider.getItemQuantity(productId);
                
//                 return GestureDetector(
//                   onTap: () {
//                     // Add to recently viewed when product is tapped
//                     recentlyViewedProvider.addToRecentlyViewed(item);
                    
//                     // Navigate to product detail
//                     Navigator.pushNamed(
//                       context,
//                       AppRoutes.tmartProductDetail,
//                       arguments: {
//                         'product': item,
//                       },
//                     );
//                   },
//                   child: Container(
//                     margin: const EdgeInsets.only(right: 16),
//                     child: TMartRecentlyViewedCard(
//                       item: item,
//                       quantity: quantity,
//                       onAdd: () {
//                         // Get vendor information from the product
//                         final vendorId = item['vendorId']?.toString() ?? item['vendor']?['_id']?.toString();
//                         final vendorName = item['vendorName']?.toString() ?? item['vendor']?['name']?.toString() ?? 'T-Mart Express';
                        
//                         print('🛒 Adding to T-Mart cart (recently viewed): ${item['name']}');
//                         print('   Vendor ID: $vendorId');
//                         print('   Vendor Name: $vendorName');
                        
//                         martCartProvider.addItem(item, quantity: 1);
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text('${item['name']} added to cart'),
//                             backgroundColor: swiggyOrange,
//                             behavior: SnackBarBehavior.floating,
//                           ),
//                         );
//                       },
//                       onIncrement: () {
//                         martCartProvider.updateQuantity(productId, quantity + 1);
//                       },
//                       onDecrement: () {
//                         if (quantity > 1) {
//                           martCartProvider.updateQuantity(productId, quantity - 1);
//                         } else {
//                           martCartProvider.removeItem(productId);
//                         }
//                       },
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRecommendedProductsSection(MartCartProvider martCartProvider, RecentlyViewedProvider recentlyViewedProvider) {
//     // Use actual recommendations data
//     final recommendedProducts = _recommendations.take(6).toList();
    
//     print('🎯 Building recommended section with ${recommendedProducts.length} products');
    
//     if (recommendedProducts.isEmpty) {
//       print('⚠️ No recommended products available');
//       return const SizedBox.shrink();
//     }
    
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: TMartSectionHeader(
//                   title: "Recommended for You",
//                   icon: Icons.recommend,
//                   onViewAll: () {
//                     Navigator.pushNamed(context, '/tmart-recommended-products');
//                   },
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.refresh, color: swiggyOrange),
//                 onPressed: () => _loadRecommendations(forceRefresh: true),
//                 tooltip: 'Refresh recommendations',
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           GridView.builder(
//             physics: const NeverScrollableScrollPhysics(),
//             shrinkWrap: true,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: 16,
//               mainAxisSpacing: 16,
//               childAspectRatio: 0.75,
//             ),
//             itemCount: recommendedProducts.length,
//             itemBuilder: (context, index) {
//               final item = recommendedProducts[index];
//               final String productId = item['_id'] ?? item['id'] ?? '';
//               final int quantity = unifiedCartProvider.getItemQuantity(productId, CartItemType.tmart);
              
//               return GestureDetector(
//                 onTap: () {
//                   // Add to recently viewed when product is tapped
//                   recentlyViewedProvider.addToRecentlyViewed(item);
                  
//                   // Navigate to product detail
//                   Navigator.pushNamed(
//                     context,
//                     '/product-detail',
//                     arguments: {
//                       'product': item,
//                     },
//                   );
//                 },
//                 child: TMartProductCard(
//                   item: item,
//                   quantity: quantity,
//                   onAdd: () {
//                     unifiedCartProvider.addTmartItem(
//                       id: item['_id'] ?? item['id'] ?? '',
//                       name: item['name'] ?? '',
//                       price: (item['price'] ?? 0).toDouble(),
//                       quantity: 1,
//                       image: item['imageUrl'] ?? item['image'] ?? '',
//                       vendorId: item['vendorId'],
//                     );
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('${item['name']} added to cart'),
//                         backgroundColor: swiggyOrange,
//                         behavior: SnackBarBehavior.floating,
//                       ),
//                     );
//                   },
//                   onIncrement: () {
//                     unifiedCartProvider.updateQuantity(productId, CartItemType.tmart, quantity + 1);
//                   },
//                   onDecrement: () {
//                     if (quantity > 1) {
//                       unifiedCartProvider.updateQuantity(productId, CartItemType.tmart, quantity - 1);
//                     } else {
//                       unifiedCartProvider.removeItem(productId, CartItemType.tmart);
//                     }
//                   },
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSkeletonLoader() {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           // Search bar skeleton
//           Container(
//             padding: const EdgeInsets.all(16),
//             child: TMartSkeletonLoader(height: 50, borderRadius: 12),
//           ),
          
//           // Banner skeleton
//           Container(
//             height: 200,
//             margin: const EdgeInsets.symmetric(horizontal: 16),
//             child: TMartSkeletonLoader(height: 200, borderRadius: 16),
//           ),
          
//           const SizedBox(height: 24),
          
//           // Categories skeleton
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 TMartSkeletonLoader(height: 20, width: 150, borderRadius: 4),
//                 const SizedBox(height: 16),
//                 SizedBox(
//                   height: 100,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: 8,
//                     itemBuilder: (context, index) => Padding(
//                       padding: const EdgeInsets.only(right: 16),
//                       child: TMartCategoryCardSkeleton(),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
          
//           // Daily essentials skeleton
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 TMartSkeletonLoader(height: 20, width: 150, borderRadius: 4),
//                 const SizedBox(height: 16),
//                 GridView.builder(
//                   physics: const NeverScrollableScrollPhysics(),
//                   shrinkWrap: true,
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 16,
//                     mainAxisSpacing: 16,
//                     childAspectRatio: 0.75,
//                   ),
//                   itemCount: 4,
//                   itemBuilder: (context, index) => TMartProductCardSkeleton(),
//                 ),
//               ],
//             ),
//           ),
          
//           // Deals skeleton
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 TMartSkeletonLoader(height: 20, width: 150, borderRadius: 4),
//                 const SizedBox(height: 16),
//                 SizedBox(
//                   height: 140,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: 3,
//                     itemBuilder: (context, index) => Padding(
//                       padding: const EdgeInsets.only(right: 12),
//                       child: TMartDealCardSkeleton(),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   AnimationController _getAnimationController(String itemName) {
//     if (!_itemAnimationControllers.containsKey(itemName)) {
//       _itemAnimationControllers[itemName] = AnimationController(
//         duration: const Duration(milliseconds: 300),
//         vsync: this,
//       );
//     }
//     return _itemAnimationControllers[itemName]!;
//   }

//   void _addToCart(Map<String, dynamic> item, int quantity) {
//     setState(() {
//       _cartItemCount += quantity;
//       _showCartIndicator = true;
//       _itemQuantities[item['name']!] = (_itemQuantities[item['name']] ?? 0) + quantity;
//     });

//     // Animate the cart indicator
//     _cartAnimationController?.forward(from: 0).then((_) {
//       Future.delayed(const Duration(seconds: 2), () {
//         if (mounted) {
//           setState(() {
//             _showCartIndicator = false;
//           });
//         }
//       });
//     });
//   }

//   String? _extractVendorId(Map<String, dynamic> item) {
//     final vendorId = item['vendorId'];
//     if (vendorId is String) {
//       return vendorId;
//     } else if (vendorId is Map<String, dynamic>) {
//       return vendorId['_id']?.toString();
//     }
//     return null;
//   }

//   Widget _buildFloatingActionButton(MartCartProvider martCartProvider) {
//     if (_cartItemCount == 0) return const SizedBox.shrink();
    
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0), // Added padding to prevent overlap
//       child: FloatingActionButton.extended(
//         onPressed: () {
//           Navigator.push(context, MaterialPageRoute(builder: (context) => const TMartDedicatedCartScreen()));
//         },
//         backgroundColor: swiggyOrange,
//         icon: const Icon(Icons.shopping_cart, color: Colors.white),
//         label: Text(
//           '($_cartItemCount)',
//           style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }
// }





