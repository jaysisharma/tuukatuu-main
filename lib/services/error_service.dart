import 'package:flutter/material.dart';

class ErrorService {
  // Error types
  static const String networkError = 'network_error';
  static const String locationError = 'location_error';
  static const String validationError = 'validation_error';
  static const String authenticationError = 'authentication_error';
  static const String serverError = 'server_error';
  static const String unknownError = 'unknown_error';

  // Error messages
  static const Map<String, String> errorMessages = {
    networkError: 'Network connection error. Please check your internet connection and try again.',
    locationError: 'Unable to get your location. Please enable location services and try again.',
    validationError: 'Please check your input and try again.',
    authenticationError: 'Authentication failed. Please log in again.',
    serverError: 'Server error. Please try again later.',
    unknownError: 'An unexpected error occurred. Please try again.',
  };

  // Error icons
  static const Map<String, IconData> errorIcons = {
    networkError: Icons.wifi_off,
    locationError: Icons.location_off,
    validationError: Icons.error_outline,
    authenticationError: Icons.lock_outline,
    serverError: Icons.cloud_off,
    unknownError: Icons.error_outline,
  };

  // Get error message
  static String getErrorMessage(String errorType, [String? customMessage]) {
    if (customMessage != null && customMessage.isNotEmpty) {
      return customMessage;
    }
    return errorMessages[errorType] ?? errorMessages[unknownError]!;
  }

  // Get error icon
  static IconData getErrorIcon(String errorType) {
    return errorIcons[errorType] ?? errorIcons[unknownError]!;
  }

  // Show error snackbar
  static void showErrorSnackBar(BuildContext context, String errorType, [String? customMessage]) {
    final message = getErrorMessage(errorType, customMessage);
    final icon = getErrorIcon(errorType);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context, 
    String errorType, 
    [String? customMessage, 
    VoidCallback? onRetry]
  ) async {
    final message = getErrorMessage(errorType, customMessage);
    final icon = getErrorIcon(errorType);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(icon, color: Colors.red[600], size: 24),
              const SizedBox(width: 12),
              const Text('Error'),
            ],
          ),
          content: Text(message),
          actions: [
            if (onRetry != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: const Text('Retry'),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show error widget
  static Widget buildErrorWidget(
    String errorType, 
    [String? customMessage, 
    VoidCallback? onRetry]
  ) {
    final message = getErrorMessage(errorType, customMessage);
    final icon = getErrorIcon(errorType);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Handle API errors
  static String handleApiError(dynamic error) {
    if (error is Exception) {
      final errorString = error.toString().toLowerCase();
      
      if (errorString.contains('network') || errorString.contains('connection')) {
        return networkError;
      } else if (errorString.contains('unauthorized') || errorString.contains('401')) {
        return authenticationError;
      } else if (errorString.contains('server') || errorString.contains('500')) {
        return serverError;
      } else if (errorString.contains('validation') || errorString.contains('400')) {
        return validationError;
      }
    }
    
    return unknownError;
  }

  // Handle location errors
  static String handleLocationError(dynamic error) {
    if (error is Exception) {
      final errorString = error.toString().toLowerCase();
      
      if (errorString.contains('permission') || errorString.contains('denied')) {
        return locationError;
      } else if (errorString.contains('service') || errorString.contains('disabled')) {
        return locationError;
      }
    }
    
    return locationError;
  }

  // Log error for analytics
  static void logError(String errorType, String message, [Map<String, dynamic>? additionalData]) {
    // In a real app, you would send this to your analytics service
    print('Error logged: $errorType - $message');
    if (additionalData != null) {
      print('Additional data: $additionalData');
    }
  }

  // Show loading widget
  static Widget buildLoadingWidget([String? message]) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Show empty state widget
  static Widget buildEmptyStateWidget(
    String title, 
    String message, 
    IconData icon, 
    [VoidCallback? onAction, 
    String? actionText]
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 