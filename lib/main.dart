import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuukatuu/theme/app_theme.dart';
import 'package:tuukatuu/presentation/screens/splash_screen.dart';
import 'package:tuukatuu/providers/address_provider.dart';
import 'package:tuukatuu/providers/auth_provider.dart';
import 'package:tuukatuu/providers/cart_provider.dart';
import 'package:tuukatuu/providers/location_provider.dart';
import 'package:tuukatuu/providers/mart_cart_provider.dart';
import 'package:tuukatuu/providers/order_provider.dart';
import 'package:tuukatuu/providers/recently_viewed_provider.dart';
import 'package:tuukatuu/providers/search_provider.dart';
import 'package:tuukatuu/providers/theme_provider.dart';
import 'package:tuukatuu/providers/unified_cart_provider.dart';
import 'package:tuukatuu/providers/user_provider.dart';
import 'package:tuukatuu/routes.dart';
import 'package:tuukatuu/services/notification_service.dart';
import 'package:baato_maps/baato_maps.dart';

const String baatoApiKey = 'bpk.c4NQriUA4yoDwdocKtxMB4dwZyoR7uA2jLAo43fTIa4z';

// Global route observer
final RouteObserver<ModalRoute<void>> globalRouteObserver = RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Baato.configure(
    apiKey: baatoApiKey,
    enableLogging: true,
  );
  final prefs = await SharedPreferences.getInstance();

  // Initialize notification service
  await NotificationService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(create: (_) => AuthProvider(prefs)),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => MartCartProvider()),
        ChangeNotifierProvider(create: (_) => UnifiedCartProvider()),
        ChangeNotifierProvider(create: (_) => RecentlyViewedProvider()),
        // ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MyApp(prefs: prefs),
    ),
  );
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return Consumer3<ThemeProvider, AuthProvider, LocationProvider>(
        builder: (context, themeProvider, authProvider, locationProvider, _) {
          // Initialize location provider
          WidgetsBinding.instance.addPostFrameCallback((_) {
            locationProvider.initialize();
          });
          
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(context),
            darkTheme: AppTheme.darkTheme(context),
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
            onGenerateRoute: AppRoutes.generateRoute,
            navigatorObservers: [globalRouteObserver],
          );
        },
    );
  }
}
