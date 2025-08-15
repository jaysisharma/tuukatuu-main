import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuukatuu/presentation/widgets/home_widgets.dart';
import 'dart:convert';
import 'package:tuukatuu/routes.dart';
import 'package:tuukatuu/presentation/screens/location/location_screen.dart';
import 'package:tuukatuu/services/notification_service.dart';
import 'cart_icon_with_badge.dart';

class AppbarLocation extends StatefulWidget {
  final bool showTmartDelivery;
  
  const AppbarLocation({
    super.key,
    this.showTmartDelivery = false,
  });

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
        final Map<String, dynamic> locationData =
            json.decode(savedLocationData);
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
          return Icons.school_outlined;
        case "university":
          return Icons.school_outlined;
        case "college":
          return Icons.school_outlined;
        case "hospital":
          return Icons.local_hospital_outlined;
        case "clinic":
          return Icons.local_hospital_outlined;
        case "current location":
          return Icons.location_on_outlined;
        default:
          return Icons.location_on_outlined;
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

  return Container(
    height: widget.showTmartDelivery ? 70 : 50, // Increase height when showing Tmart delivery
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    
    child: Column(
      children: [
        // Tmart Quick Delivery Indicator
       
        // Main Location Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: _navigateToLocationScreen,
              child: Row(
                children: [
                  Icon(
                    _getIconForLocation(),
                    size: 24,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 6.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Deliver to",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            locationForDisplay,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
           
            if (widget.showTmartDelivery) ...[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "T-Mart",
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.w700, 
                        color: Colors.grey[600]
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "Quick Delivery under 30 mins", 
                      style: TextStyle(
                        fontSize: 12, 
                        fontWeight: FontWeight.w500, 
                        color: Colors.grey[600]
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
         Row(
          children: [
               GestureDetector(
              onTap: () async {
                await Navigator.pushNamed(context, AppRoutes.notifications);
                _loadNotificationCount();
              },
              child: Stack(
                children: [
                  const IconButtonWidget(Icons.notifications_outlined),
                  if (_notificationCount > 0)
                    Positioned(
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
                          _notificationCount.toString(),
                          style: const TextStyle(
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
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(6),
              child: const CartIconWithBadge(
                iconSize: 20,
                badgeColor: Colors.orange,
                badgeSize: 18,
                iconColor: Colors.black87,
                badgeOffset: EdgeInsets.only(top: -10, right: -10),
              ),
            ),
         
          ],
         ) ],
        ),
      ],
    ),
  );
}
}