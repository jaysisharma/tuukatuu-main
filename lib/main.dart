import 'package:baato_maps/baato_maps.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuukatuu/presentation/screens/main_screen.dart';
import 'package:tuukatuu/presentation/screens/orders/order_history_screen.dart';
import 'package:tuukatuu/providers/location_provider.dart';

import 'routes.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/t_mart_screen.dart';
import 'presentation/screens/orders/orders_screen.dart';
import 'presentation/screens/cart/cart_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/search_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/user_provider.dart';
import 'theme/app_theme.dart';
import 'providers/address_provider.dart';
import 'providers/mart_cart_provider.dart';
import 'providers/unified_cart_provider.dart';
import 'providers/recently_viewed_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'services/notification_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
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
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

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
    return Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(context),
            darkTheme: AppTheme.darkTheme(context),
            themeMode: themeProvider.themeMode,
            home: authProvider.isLoggedIn ? const MainScreen() : const SplashScreen(),
            onGenerateRoute: AppRoutes.generateRoute,
            navigatorObservers: [globalRouteObserver],
          );
        },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Add a GlobalKey for OrdersScreen
  final GlobalKey<OrdersScreenState> _ordersScreenKey = GlobalKey<OrdersScreenState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      // const HomeScreen(),
      const HomeScreen(),
       TMartScreen(),
      const CartScreen(),
      // OrdersScreen(key: _ordersScreenKey),
      OrderHistoryScreen(),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // If Orders tab is selected, refresh orders
    if (index == 3) {
      _ordersScreenKey.currentState?.refreshOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cartProvider = Provider.of<CartProvider>(context);
    // Calculate total quantity of items in cart
    final int totalCartQuantity = cartProvider.items.fold(0, (sum, item) => sum + (item['quantity'] as int));

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: isDark ? Colors.orange[300] : theme.primaryColor,
        unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store_outlined),
            activeIcon: Icon(Icons.store),
            label: 'T-Mart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: (_selectedIndex != 2 && totalCartQuantity > 0)
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.cart);
              },
              backgroundColor: theme.colorScheme.primary,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart, color: Colors.white),
                  if (totalCartQuantity > 0)
                    Positioned(
                      right: -8,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          '$totalCartQuantity',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            )
          : null,
    );
  }
}

Future<void> showOrderStatusNotification(Map<String, dynamic> order) async {
  final status = (order['status'] ?? '').toString();
  if (status == 'pending' || status == 'delivered' || status == 'cancelled') {
    await flutterLocalNotificationsPlugin.cancel(1001); // Remove notification
    return;
  }
  final eta = order['eta']?.toString() ?? '';
  await flutterLocalNotificationsPlugin.show(
    1001, // Notification ID
    'Order ${status[0].toUpperCase()}${status.substring(1)}',
    eta.isNotEmpty ? 'Arrives in $eta mins' : 'Track your order status',
    NotificationDetails(
      android: AndroidNotificationDetails(
        'order_status_channel',
        'Order Status',
        channelDescription: 'Live updates for your order status',
        importance: Importance.max,
        priority: Priority.high,
        ongoing: true, // Makes it persistent
        onlyAlertOnce: true,
        showWhen: true,
      ),
      iOS: DarwinNotificationDetails(),
    ),
  );
}
