import 'package:flutter/material.dart';

class ErrorService {
  // Error types
  static const String networkError = 'network_error';
  static const String locationError = 'location_error';
  static const String validationError = 'validation_error';
  static const String authenticationError = 'authentication_error';
  static const String serverError = 'server_error';
  static const String unknownError = 'unknown_error';
  static const String timeoutError = 'timeout_error';
  static const String permissionError = 'permission_error';
  static const String notFoundError = 'not_found_error';
  static const String rateLimitError = 'rate_limit_error';
  static const String paymentError = 'payment_error';
  static const String orderError = 'order_error';
  static const String productError = 'product_error';
  static const String addressError = 'address_error';

  // Error messages
  static const Map<String, String> errorMessages = {
    networkError: 'No internet connection. Please check your network and try again.',
    locationError: 'Unable to access location. Please enable location services in your device settings.',
    validationError: 'Please check your input and try again.',
    authenticationError: 'Your session has expired. Please log in again.',
    serverError: 'Something went wrong on our end. Please try again in a few moments.',
    unknownError: 'An unexpected error occurred. Please try again.',
    timeoutError: 'Request timed out. Please check your connection and try again.',
    permissionError: 'Permission denied. Please grant the required permissions to continue.',
    notFoundError: 'The requested information was not found.',
    rateLimitError: 'Too many requests. Please wait a moment and try again.',
    paymentError: 'Payment processing failed. Please check your payment details and try again.',
    orderError: 'Unable to process your order. Please try again or contact support.',
    productError: 'Product information is currently unavailable. Please try again later.',
    addressError: 'Unable to save address. Please check your details and try again.',
  };

  // Error icons
  static const Map<String, IconData> errorIcons = {
    networkError: Icons.wifi_off,
    locationError: Icons.location_off,
    validationError: Icons.error_outline,
    authenticationError: Icons.lock_outline,
    serverError: Icons.cloud_off,
    unknownError: Icons.error_outline,
    timeoutError: Icons.timer_off,
    permissionError: Icons.block,
    notFoundError: Icons.search_off,
    rateLimitError: Icons.speed,
    paymentError: Icons.payment,
    orderError: Icons.shopping_cart_outlined,
    productError: Icons.inventory_2_outlined,
    addressError: Icons.location_on_outlined,
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
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
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
              const Text('Oops!'),
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

  // Handle API errors with improved categorization
  static String handleApiError(dynamic error) {
    if (error is Exception) {
      final errorString = error.toString().toLowerCase();
      
      // Network and connection errors - including the specific connection refused error
      if (errorString.contains('network') || 
          errorString.contains('connection') ||
          errorString.contains('socket') ||
          errorString.contains('host') ||
          errorString.contains('connection refused') ||
          errorString.contains('clientexception') ||
          errorString.contains('socketexception') ||
          errorString.contains('errno = 61')) {
        return networkError;
      }
      
      // Authentication errors
      if (errorString.contains('unauthorized') || 
          errorString.contains('401') ||
          errorString.contains('forbidden') ||
          errorString.contains('403') ||
          errorString.contains('token') ||
          errorString.contains('jwt')) {
        return authenticationError;
      }
      
      // Server errors
      if (errorString.contains('server') || 
          errorString.contains('500') ||
          errorString.contains('502') ||
          errorString.contains('503') ||
          errorString.contains('504')) {
        return serverError;
      }
      
      // Validation errors
      if (errorString.contains('validation') || 
          errorString.contains('400') ||
          errorString.contains('bad request') ||
          errorString.contains('invalid')) {
        return validationError;
      }
      
      // Not found errors
      if (errorString.contains('not found') || 
          errorString.contains('404')) {
        return notFoundError;
      }
      
      // Timeout errors
      if (errorString.contains('timeout') || 
          errorString.contains('timed out')) {
        return timeoutError;
      }
      
      // Rate limit errors
      if (errorString.contains('rate limit') || 
          errorString.contains('too many requests') ||
          errorString.contains('429')) {
        return rateLimitError;
      }
      
      // Payment errors
      if (errorString.contains('payment') || 
          errorString.contains('card') ||
          errorString.contains('billing')) {
        return paymentError;
      }
      
      // Order errors
      if (errorString.contains('order') || 
          errorString.contains('cart')) {
        return orderError;
      }
      
      // Product errors
      if (errorString.contains('product') || 
          errorString.contains('item')) {
        return productError;
      }
      
      // Address errors
      if (errorString.contains('address') || 
          errorString.contains('location')) {
        return addressError;
      }
    }
    
    return unknownError;
  }

  // Handle location errors
  static String handleLocationError(dynamic error) {
    if (error is Exception) {
      final errorString = error.toString().toLowerCase();
      
      if (errorString.contains('permission') || 
          errorString.contains('denied') ||
          errorString.contains('access')) {
        return permissionError;
      } else if (errorString.contains('service') || 
                 errorString.contains('disabled') ||
                 errorString.contains('unavailable')) {
        return locationError;
      }
    }
    
    return locationError;
  }

  // Handle connection refused errors specifically
  static String handleConnectionRefusedError(dynamic error) {
    if (error is Exception) {
      final errorString = error.toString().toLowerCase();
      
      if (errorString.contains('connection refused') ||
          errorString.contains('errno = 61') ||
          errorString.contains('socketexception') ||
          errorString.contains('clientexception')) {
        return networkError;
      }
    }
    
    return networkError;
  }

  // Handle HTTP status codes
  static String handleHttpStatus(int statusCode) {
    switch (statusCode) {
      case 400:
        return validationError;
      case 401:
      case 403:
        return authenticationError;
      case 404:
        return notFoundError;
      case 408:
      case 504:
        return timeoutError;
      case 429:
        return rateLimitError;
      case 500:
      case 502:
      case 503:
        return serverError;
      default:
        return unknownError;
    }
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
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
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

  // Show success message
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show info message
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
} 