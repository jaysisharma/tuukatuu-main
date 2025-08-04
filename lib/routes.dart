import 'package:flutter/material.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/t_mart_screen.dart';
import 'presentation/screens/tmart_cart_screen.dart';
import 'presentation/screens/tmart_search_screen.dart';
import 'presentation/screens/tmart_category_products_screen.dart';
import 'presentation/screens/tmart_categories_screen.dart';
import 'presentation/screens/tmart_popular_products_screen.dart';
import 'presentation/screens/tmart_recommended_products_screen.dart';
import 'presentation/screens/tmart_product_detail_screen.dart';
import 'presentation/screens/favorites_screen.dart';
import 'presentation/screens/orders/orders_screen.dart';
import 'presentation/screens/orders/order_tracking.dart';
import 'presentation/screens/store_details_screen.dart';
import 'presentation/screens/cart/cart_screen.dart';
import 'presentation/screens/unified_cart_screen.dart';
import 'presentation/screens/multi_store_cart_screen.dart';
import 'presentation/screens/tmart_dedicated_cart_screen.dart';
import 'presentation/screens/t_mart_clean_screen.dart';
import 'presentation/screens/checkout_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/signup_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/screens/location/location_screen.dart';
import 'presentation/screens/notifications/notification_screen.dart';
import 'presentation/screens/notifications/notification_screen.dart';
import 'screens/category_products_screen.dart';
import 'presentation/screens/daily_essentials_page.dart';
import 'presentation/screens/recently_viewed_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String tMart = '/t-mart';
  static const String tmartCart = '/tmart-cart';
  static const String tmartProductDetail = '/tmart-product-detail';
  static const String tmartSearch = '/tmart-search';
  static const String tmartCategoryProducts = '/tmart-category-products';
  static const String tmartCategories = '/tmart-categories';
  static const String tmartPopularProducts = '/tmart-popular-products';
  static const String tmartRecommendedProducts = '/tmart-recommended-products';
  static const String favorites = '/favorites';
  static const String orders = '/orders';
  static const String orderTracking = '/order-tracking';
  static const String storeDetails = '/store-details';
  static const String location = '/location';
  static const String cart = '/cart';
  static const String unifiedCart = '/unified-cart';
  static const String checkout = '/checkout';
  static const String categoryProducts = '/category-products';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String dailyEssentialsPage = '/daily-essentials-page';
  static const String recentlyViewedPage = '/recently-viewed-page';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case tMart:
        return MaterialPageRoute(builder: (_) => const TMartCleanScreen());
      case tmartCart:
        return MaterialPageRoute(builder: (_) => const TMartCartScreen());
      case tmartProductDetail:
        if (settings.arguments != null) {
          final args = settings.arguments as Map<String, dynamic>;
          final product = args['product'] as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => TMartProductDetailScreen(product: product),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Product details not found')),
          ),
        );
      case tmartCategories:
        return MaterialPageRoute(builder: (_) => const TMartCategoriesScreen());
      case tmartPopularProducts:
        return MaterialPageRoute(builder: (_) => const TMartPopularProductsScreen());
      case tmartRecommendedProducts:
        return MaterialPageRoute(builder: (_) => const TMartRecommendedProductsScreen());
      case tmartSearch:
        if (settings.arguments != null) {
          final searchQuery = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => TMartSearchScreen(searchQuery: searchQuery),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const TMartSearchScreen(searchQuery: ''),
        );
      case tmartCategoryProducts:
        if (settings.arguments != null) {
          final args = settings.arguments as Map<String, dynamic>;
          final categoryName = args['categoryName'] as String;
          final categoryDisplayName = args['categoryDisplayName'] as String;
          return MaterialPageRoute(
            builder: (_) => TMartCategoryProductsScreen(
              categoryName: categoryName,
              categoryDisplayName: categoryDisplayName,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Category not specified')),
          ),
        );
      case favorites:
        return MaterialPageRoute(builder: (_) => const FavoritesScreen());
      case orders:
        return MaterialPageRoute(builder: (_) => const OrdersScreen());
      case orderTracking:
        if (settings.arguments != null) {
          final args = settings.arguments as Map<String, dynamic>;
          final orderId = args['orderId'] as String;
          final initialOrder = args['initialOrder'] as Map<String, dynamic>?;
          return MaterialPageRoute(
            // builder: (_) => OrderTrackingScreen(
            //   orderId: orderId,
            //   initialOrder: initialOrder,
            // ),
            builder: (_) => OrderTracking(order: initialOrder!),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Order ID not provided')),
          ),
        );
      case dailyEssentialsPage:
        return MaterialPageRoute(builder: (_) => const DailyEssentialsPage());
      case recentlyViewedPage:
        return MaterialPageRoute(builder: (_) => const RecentlyViewedPage());
      case categoryProducts:
        if (settings.arguments != null) {
          final args = settings.arguments as Map<String, dynamic>;
          final category = args['category'] as String;
          return MaterialPageRoute(
            builder: (_) => CategoryProductsScreen(category: category),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Category not specified')),
          ),
        );
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case location:
        return MaterialPageRoute(builder: (_) => const LocationScreen());
      case cart:
        return MaterialPageRoute(builder: (_) => const TMartDedicatedCartScreen());
      case checkout:
        if (settings.arguments != null) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => CheckoutScreen(
              totalAmount: args['totalAmount'] as double,
              cartItems: args['cartItems'] as List<Map<String, dynamic>>,
              isTmartOrder: args['isTmartOrder'] as bool? ?? false,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Checkout data not provided')),
          ),
        );
      case storeDetails:
        if (settings.arguments != null) {
          final store = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => StoreDetailsScreen(store: store),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Store data not provided')),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
