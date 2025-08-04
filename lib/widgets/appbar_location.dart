import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:tuukatuu/routes.dart';
import 'package:tuukatuu/presentation/screens/location/location_screen.dart';
import 'package:tuukatuu/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:tuukatuu/providers/cart_provider.dart';
import 'package:tuukatuu/providers/mart_cart_provider.dart';

class AppbarLocation extends StatefulWidget {
  const AppbarLocation({super.key});

  @override
  State<AppbarLocation> createState() => _AppbarLocationState();
}

class _AppbarLocationState extends State<AppbarLocation> {
  String _displayedLocation = "Fetching location...";
  String _currentLabel = "";
  int _notificationCount = 0;

  static const String _kSavedLocationKey = 'saved_location_data';

  @override
  void initState() {
    super.initState();
    _loadLocationFromPrefs();
    _loadNotificationCount();
  }

  Future<void> _loadLocationFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocationData = prefs.getString(_kSavedLocationKey);
    
    if (savedLocationData != null && savedLocationData.isNotEmpty) {
      try {
        // Try to parse as JSON first (new format with label and address)
        final Map<String, dynamic> locationData = json.decode(savedLocationData);
        final String label = locationData['label'] ?? '';
        final String address = locationData['address'] ?? '';
        
        if (mounted) {
          setState(() {
            _currentLabel = label;
            _displayedLocation = label.isNotEmpty ? label : address;
          });
        }
      } catch (e) {
        // Fallback for old format (just address string)
        if (mounted) {
          setState(() {
            _currentLabel = "";
            _displayedLocation = savedLocationData;
          });
        }
        print('Error parsing location data: $e');
      }
    } else {
      // If no saved location, show default message
      if (mounted) {
        setState(() {
          _currentLabel = "";
          _displayedLocation = "Select Delivery Address";
        });
      }
    }
  }

  void _navigateToLocationScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationScreen()),
    );

    // Handle the result from LocationScreen
    if (result != null) {
      if (result is String) {
        // Old format - just address string
        if (result.isNotEmpty) {
          if (mounted) {
            setState(() {
              _currentLabel = "";
              _displayedLocation = result;
            });
          }
          _saveLocationToPrefs("", result);
        }
      } else if (result is Map<String, dynamic>) {
        // New format - map with label and address
        final String label = result['label'] ?? '';
        final String address = result['address'] ?? '';
        
        if (address.isNotEmpty) {
          if (mounted) {
            setState(() {
              _currentLabel = label;
              _displayedLocation = label.isNotEmpty ? label : address;
            });
          }
          _saveLocationToPrefs(label, address);
        }
      }
    }
  }

  Future<void> _saveLocationToPrefs(String label, String address) async {
    if (address.isEmpty) {
      print('Warning: Attempting to save empty address');
      return;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final locationData = {
      'label': label,
      'address': address,
    };
    await prefs.setString(_kSavedLocationKey, json.encode(locationData));
  }

  // Helper method to get the display text (label if available, otherwise address)
  String _getDisplayText() {
    if (_currentLabel.isNotEmpty) {
      return _currentLabel;
    }
    return _displayedLocation;
  }

  // Helper method to get the appropriate icon based on the location label
  IconData _getIconForLocation() {
    if (_currentLabel.isNotEmpty) {
      switch (_currentLabel.toLowerCase()) {
        case "home":
          return Icons.home;
        case "work":
          return Icons.work;
        case "office":
          return Icons.work;
        case "gym":
          return Icons.fitness_center;
        case "school":
          return Icons.school;
        case "university":
          return Icons.school;
        case "college":
          return Icons.school;
        case "hospital":
          return Icons.local_hospital;
        case "clinic":
          return Icons.local_hospital;
        case "current location":
          return Icons.my_location;
        default:
          return Icons.location_on;
      }
    }
    return Icons.location_on;
  }

  // Helper method to truncate the location string to 4 words
  String _getTruncatedLocation(String fullLocation) {
    List<String> words = fullLocation.split(' ');
    if (words.length > 4) {
      return "${words.sublist(0, 4).join(' ')}...";
    }
    return fullLocation;
  }

  Future<void> _loadNotificationCount() async {
    try {
      final count = await NotificationService.getUnreadCount();
      if (mounted) {
        setState(() {
          _notificationCount = count;
        });
      }
    } catch (e) {
      print('Error loading notification count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String locationForDisplay = _getTruncatedLocation(_getDisplayText());

    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 1,
      titleSpacing: 0,
      title: Row(
        children: [
          const SizedBox(width: 16.0),
          InkWell(
            onTap: _navigateToLocationScreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      _getIconForLocation(),
                      size: 24,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Deliver to",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              locationForDisplay,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              size: 18,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          // Notification icon
          GestureDetector(
            onTap: () async {
              await Navigator.pushNamed(context, AppRoutes.notifications);
              _loadNotificationCount();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Stack(
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    size: 28,
                    color: Colors.white,
                  ),
                  // Notification badge
                  if (_notificationCount > 0)
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
                          _notificationCount.toString(),
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
            ),
          ),
          const SizedBox(width: 12),
          // Cart icon
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.cart);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Stack(
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 28,
                    color: Colors.white,
                  ),
                  // Cart badge
                  Consumer2<CartProvider, MartCartProvider>(
                    builder: (context, cartProvider, martCartProvider, child) {
                      final cartCount = cartProvider.itemCount + martCartProvider.itemCount;
                      if (cartCount == 0) return const SizedBox.shrink();
                      
                      return Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            cartCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16.0),
        ],
      ),
    );
  }
}