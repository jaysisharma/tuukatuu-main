import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/unified_cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../services/order_polling_service.dart';
import 'home/home_screen.dart';
import 't_mart_screen.dart';
import 'orders/orders_screen.dart';
import 'profile/profile_screen.dart';
import 'unified_cart_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const TMartScreen(),
    const UnifiedCartScreen(),
    const OrdersScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeOrderPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    OrderPollingService.stopPolling();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground, check for updates
        OrderPollingService.checkForUpdates();
        break;
      case AppLifecycleState.paused:
        // App went to background
        break;
      default:
        break;
    }
  }

  void _initializeOrderPolling() {
    // Start polling for order updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OrderPollingService.startPolling();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Consumer<UnifiedCartProvider>(
        builder: (context, cartProvider, child) {
          final cartSummary = cartProvider.getCartSummary();
          final totalItems = cartSummary['totalItems'] as int;
          final hasMixedItems = cartSummary['hasMixedItems'] as bool;
          
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            selectedItemColor: const Color(0xFF2E7D32),
            unselectedItemColor: Colors.grey,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.store),
                label: 'T-Mart',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.shopping_cart),
                    if (totalItems > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            totalItems.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                label: hasMixedItems ? 'Cart (Mixed)' : 'Cart',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long),
                label: 'Orders',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }
} 