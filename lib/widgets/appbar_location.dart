import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuukatuu/presentation/screens/location/location_screen.dart'; // Ensure this path is correct

class AppbarLocation extends StatefulWidget {
  const AppbarLocation({super.key});

  @override
  State<AppbarLocation> createState() => _AppbarLocationState();
}

class _AppbarLocationState extends State<AppbarLocation> {
  String _displayedLocation = "Fetching location..."; // Default initial location, indicating loading

  static const String _kSavedLocationKey = 'saved_location_address';

  @override
  void initState() {
    super.initState();
    _loadLocationFromPrefs();
  }

  Future<void> _loadLocationFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAddress = prefs.getString(_kSavedLocationKey);
    if (savedAddress != null && savedAddress.isNotEmpty) {
      if (mounted) {
        setState(() {
          _displayedLocation = savedAddress;
        });
      }
    } else {
      // If no saved location, try to fetch current location for initial display
      // This is a simplified call; real implementation would be more robust.
      // For now, we'll just keep "Kathmandu" as a fallback if nothing is saved.
      if (mounted) {
        setState(() {
          _displayedLocation = "Kathmandu"; // Fallback if no saved location
        });
      }
    }
  }

  void _navigateToLocationScreen() async {
    final newLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationScreen()),
    );

    // If a new location is returned from LocationScreen
    if (newLocation != null && newLocation is String && newLocation.isNotEmpty) {
      if (mounted) {
        setState(() {
          _displayedLocation = newLocation;
        });
      }
      // Save the newly selected location to SharedPreferences
      _saveLocationToPrefs(newLocation);
    }
  }

  Future<void> _saveLocationToPrefs(String location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSavedLocationKey, location);
  }

  // Helper method to truncate the location string to 4 words
  String _getTruncatedLocation(String fullLocation) {
    List<String> words = fullLocation.split(' ');
    if (words.length > 4) { // Changed condition to > 4 to include the 4th word
      return "${words.sublist(0, 4).join(' ')}..."; // Appending '...' for clarity
    }
    return fullLocation;
  }

  @override
  Widget build(BuildContext context) {
    String locationForDisplay = _getTruncatedLocation(_displayedLocation);

    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 1, // Consider 0 elevation if part of a CustomScrollView's FlexibleSpaceBar
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
                    const Icon(
                      Icons.location_on, // Location icon
                      size: 24, // Adjust size as needed
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4.0), // Spacing between icon and text

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
                            // Display the truncated dynamic location
                            Text(
                              locationForDisplay,
                              style: const TextStyle(
                                fontSize: 14,
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
          // Profile icon (unchanged)
          GestureDetector(
            onTap: () {
               // Navigate to profile screen
               // Assuming you have AppRoutes.profile defined
               // Navigator.pushNamed(context, AppRoutes.profile);
            },
            child: const Icon(
              Icons.account_circle,
              size: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16.0),
        ],
      ),
    );
  }
}