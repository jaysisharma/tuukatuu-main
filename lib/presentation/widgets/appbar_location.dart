import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuukatuu/providers/location_provider.dart';
import 'package:tuukatuu/presentation/screens/location/location_screen.dart';

class AppBarLocation extends StatelessWidget implements PreferredSizeWidget {
  final String currentAddress;
  final bool isPermissionDeniedForever;
  final VoidCallback onLocationTap;
  final VoidCallback onProfileTap;
  final VoidCallback onOpenLocationSettings;

  const AppBarLocation({
    super.key,
    required this.currentAddress,
    required this.isPermissionDeniedForever,
    required this.onLocationTap,
    required this.onProfileTap,
    required this.onOpenLocationSettings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        // Use delivery location if available, otherwise use current address
        final displayAddress = locationProvider.hasDeliveryLocation 
            ? locationProvider.deliveryAddress!
            : currentAddress;
        
        final isDeliveryLocation = locationProvider.hasDeliveryLocation;
        
        return AppBar(
          title: GestureDetector(
            onTap: () async {
              // Navigate to location screen for delivery location selection
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LocationScreen(),
                ),
              );
              
              // Handle result if needed
              if (result != null && result is Map<String, dynamic>) {
                // Location was selected or saved
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Delivery location updated'),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Delivery to',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    if (isDeliveryLocation) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'SET',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayAddress,
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isPermissionDeniedForever)
                      TextButton(
                        onPressed: onOpenLocationSettings,
                        child: Text(
                          'Open Settings',
                          style: TextStyle(
                            color: isDark ? Colors.orange[300] : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            GestureDetector(
              onTap: onProfileTap,
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  child: Icon(
                    Icons.person,
                    color: isDark ? Colors.grey[400] : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 