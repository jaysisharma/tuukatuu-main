import 'package:flutter/material.dart';

class DoubleBackExit {
  static DateTime? _lastBackPressTime;

  /// Shows a snackbar with exit message and handles double back press logic
  static Future<bool> onWillPop(BuildContext context) async {
    final now = DateTime.now();
    
    if (_lastBackPressTime == null || 
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      // First back press or more than 2 seconds have passed
      _lastBackPressTime = now;
      
      // Show snackbar to inform user about double tap to exit
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Press back again to exit'),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.orange[700],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      
      return false; // Don't exit yet
    } else {
      // Second back press within 2 seconds
      return true; // Exit the app
    }
  }

  /// Resets the back press timer (useful when navigating to other screens)
  static void resetTimer() {
    _lastBackPressTime = null;
  }

  /// Creates a WillPopScope widget with double back exit functionality
  static Widget wrapWithDoubleBackExit({
    required Widget child,
    required BuildContext context,
  }) {
    return WillPopScope(
      onWillPop: () => onWillPop(context),
      child: child,
    );
  }
} 