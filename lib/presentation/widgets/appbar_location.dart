import 'package:flutter/material.dart';

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
    return AppBar(
      title: GestureDetector(
        onTap: onLocationTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery to',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey,
                fontSize: 12,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    currentAddress,
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
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 