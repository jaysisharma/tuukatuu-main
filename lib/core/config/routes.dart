import 'package:flutter/material.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/t_mart_clean_screen.dart';
import '../../presentation/screens/favorites_screen.dart';
import '../../presentation/screens/orders/orders_screen.dart';
import '../../presentation/screens/orders/order_tracking.dart';
import '../../presentation/screens/store_details_screen.dart';
import '../../presentation/screens/product_details_screen.dart';
import '../../presentation/screens/cart/cart_screen.dart';
import '../../presentation/screens/checkout_screen.dart';
import '../../presentation/screens/multi_store_cart_screen.dart';
import 'package:tuukatuu/presentation/screens/mart_cart_screen.dart';
import '../../presentation/screens/tmart_cart_screen.dart';
import '../../presentation/screens/tmart_product_detail_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String tMart = '/t-mart';
  static const String favorites = '/favorites';
  static const String orders = '/orders';
  static const String orderTracking = '/order-tracking';
  static const String storeDetails = '/store-details';
  static const String productDetails = '/product-details';
  static const String location = '/location';
  static const String cart = '/cart';
  static const String multiStoreCart = '/multi-store-cart';
  static const String checkout = '/checkout';
  static const String tmartCart = '/tmart-cart';
  static const String tmartProductDetail = '/tmart-product-detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case tMart:
        return MaterialPageRoute(builder: (_) =>  TMartCleanScreen());
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
      // case location:
        // return MaterialPageRoute(builder: (_) => const LocationScreen());
      case cart:
        return MaterialPageRoute(builder: (_) => const MultiStoreCartScreen());
      case multiStoreCart:
        return MaterialPageRoute(builder: (_) => const MultiStoreCartScreen());
      case '/multi-store-cart':
        return MaterialPageRoute(builder: (_) => const MultiStoreCartScreen());
      // case checkout:
      //   final args = settings.arguments as Map<String, dynamic>;
      //   return MaterialPageRoute(
      //     builder: (_) => CheckoutScreen(
      //       totalAmount: args['totalAmount'] as double,
      //       cartItems: args['cartItems'] as List<Map<String, dynamic>>,
      //     ),
      //   );
      case storeDetails:
        if (settings.arguments != null) {
          final store = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => StoreDetailsScreen(store: store),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Store details not found'),
            ),
          ),
        );
      case productDetails:
        if (settings.arguments != null) {
          final product = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product['product']),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Product details not found'),
            ),
          ),
        );
      case '/mart-cart':
        return MaterialPageRoute(builder: (_) => const MartCartScreen());
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
            body: Center(
              child: Text('Product details not found'),
            ),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
} 