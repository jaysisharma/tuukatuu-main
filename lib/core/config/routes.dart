import 'package:flutter/material.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/t_mart_screen.dart';
import '../../presentation/screens/favorites_screen.dart';
import '../../presentation/screens/orders/orders_screen.dart';
import '../../presentation/screens/store_details_screen.dart';
import '../../presentation/screens/location_screen.dart';
import '../../presentation/screens/cart/cart_screen.dart';
import '../../presentation/screens/checkout_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String tMart = '/t-mart';
  static const String favorites = '/favorites';
  static const String orders = '/orders';
  static const String storeDetails = '/store-details';
  static const String location = '/location';
  static const String cart = '/cart';
  static const String checkout = '/checkout';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case tMart:
        return MaterialPageRoute(builder: (_) => const TMartScreen());
      case favorites:
        return MaterialPageRoute(builder: (_) => const FavoritesScreen());
      case orders:
        return MaterialPageRoute(builder: (_) => const OrdersScreen());
      case location:
        return MaterialPageRoute(builder: (_) => const LocationScreen());
      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case checkout:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CheckoutScreen(
            totalAmount: args['totalAmount'] as double,
            cartItems: args['cartItems'] as List<Map<String, dynamic>>,
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
            body: Center(
              child: Text('Store details not found'),
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