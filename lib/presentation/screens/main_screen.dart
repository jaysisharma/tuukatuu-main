import 'package:flutter/material.dart';
import 'package:tuukatuu/presentation/screens/home/home_screen3.dart';
import 'package:tuukatuu/presentation/screens/mart/mart.dart';
import 'package:tuukatuu/presentation/screens/orders/order_history_screen.dart';
import 'package:tuukatuu/presentation/screens/t_mart_clean_screen.dart';
import '../../services/order_polling_service.dart';
import '../../utils/double_back_exit.dart';

import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  final int? initialTabIndex;
  
  const MainScreen({super.key, this.initialTabIndex});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    // const HomeScreen(),
    const HomeScreen3(),
    const Tmart(),
    // const HomeScreen3(),
    const TMartCleanScreen(),
    // const TmartScreen(),
    const OrderHistoryScreen(),
    // const TMartCleanScreen2(),
    // const HomeScreen(),
    // const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Set initial tab index if provided
    if (widget.initialTabIndex != null) {
      _currentIndex = widget.initialTabIndex!;
    }
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
    return WillPopScope(
      onWillPop: () => DoubleBackExit.onWillPop(context),
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: const Color(0xFFFC8019),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.store),
              label: 'T-Mart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
} 