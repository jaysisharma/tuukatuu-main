import 'package:flutter/material.dart';
import '../services/error_service.dart';
import '../services/api_service.dart';

/// A mixin that provides consistent error handling across screens
mixin ErrorHandlerMixin<T extends StatefulWidget> on State<T> {
  
  /// Handle errors with automatic categorization and user-friendly messages
  void handleError(dynamic error, {String? customMessage, VoidCallback? onRetry}) {
    String errorType;
    String message;
    
    if (error is ApiException) {
      errorType = error.errorType;
      message = error.message;
    } else {
      errorType = ErrorService.handleApiError(error);
      message = customMessage ?? ErrorService.getErrorMessage(errorType);
    }
    
    // Log the error for debugging
    ErrorService.logError(errorType, message, {
      'screen': widget.runtimeType.toString(),
      'error': error.toString(),
    });
    
    // Show appropriate error UI
    if (mounted) {
      _showErrorUI(errorType, message, onRetry);
    }
  }
  
  /// Show error snackbar
  void showErrorSnackBar(String errorType, [String? customMessage]) {
    if (mounted) {
      ErrorService.showErrorSnackBar(context, errorType, customMessage);
    }
  }
  
  /// Show error dialog
  Future<void> showErrorDialog(String errorType, [String? customMessage, VoidCallback? onRetry]) async {
    if (mounted) {
      return ErrorService.showErrorDialog(context, errorType, customMessage, onRetry);
    }
  }
  
  /// Show success message
  void showSuccessMessage(String message) {
    if (mounted) {
      ErrorService.showSuccessSnackBar(context, message);
    }
  }
  
  /// Show info message
  void showInfoMessage(String message) {
    if (mounted) {
      ErrorService.showInfoSnackBar(context, message);
    }
  }
  
  /// Show loading dialog
  void showLoadingDialog([String? message]) {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(
                child: Text(message ?? 'Loading...'),
              ),
            ],
          ),
        ),
      );
    }
  }
  
  /// Hide loading dialog
  void hideLoadingDialog() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
  
  /// Show confirmation dialog
  Future<bool> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    if (!mounted) return false;
    
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDestructive 
              ? TextButton.styleFrom(foregroundColor: Colors.red)
              : null,
            child: Text(confirmText),
          ),
        ],
      ),
    ) ?? false;
  }
  
  /// Handle async operations with error handling
  Future<T?> handleAsyncOperation<T>(
    Future<T> Function() operation, {
    String? loadingMessage,
    String? errorMessage,
    VoidCallback? onRetry,
    bool showLoading = true,
    bool showError = true,
  }) async {
    try {
      if (showLoading && loadingMessage != null) {
        showLoadingDialog(loadingMessage);
      }
      
      final result = await operation();
      
      if (showLoading) {
        hideLoadingDialog();
      }
      
      return result;
    } catch (e) {
      if (showLoading) {
        hideLoadingDialog();
      }
      
      if (showError) {
        handleError(e, customMessage: errorMessage, onRetry: onRetry);
      }
      
      return null;
    }
  }
  
  /// Handle API operations with automatic error handling
  Future<T?> handleApiOperation<T>(
    Future<T> Function() apiCall, {
    String? loadingMessage,
    String? errorMessage,
    VoidCallback? onRetry,
    bool showLoading = true,
    bool showError = true,
  }) async {
    return handleAsyncOperation(
      apiCall,
      loadingMessage: loadingMessage,
      errorMessage: errorMessage,
      onRetry: onRetry,
      showLoading: showLoading,
      showError: showError,
    );
  }
  
  /// Show appropriate error UI based on error type
  void _showErrorUI(String errorType, String message, VoidCallback? onRetry) {
    switch (errorType) {
      case ErrorService.networkError:
        showErrorSnackBar(errorType, message);
        break;
      case ErrorService.authenticationError:
        showErrorDialog(errorType, message, onRetry);
        break;
      case ErrorService.serverError:
        showErrorDialog(errorType, message, onRetry);
        break;
      case ErrorService.validationError:
        showErrorSnackBar(errorType, message);
        break;
      case ErrorService.permissionError:
        showErrorDialog(errorType, message, onRetry);
        break;
      default:
        showErrorSnackBar(errorType, message);
        break;
    }
  }
  
  /// Check if user is authenticated and handle auth errors
  bool handleAuthError(dynamic error) {
    if (error is ApiException && error.errorType == ErrorService.authenticationError) {
      // Handle authentication error - could navigate to login
      showErrorDialog(
        ErrorService.authenticationError,
        'Your session has expired. Please log in again.',
        () {
          // Navigate to login screen
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        },
      );
      return true;
    }
    return false;
  }
  
  /// Handle network errors specifically
  void handleNetworkError(dynamic error, VoidCallback? onRetry) {
    if (error is ApiException && error.errorType == ErrorService.networkError) {
      showErrorDialog(
        ErrorService.networkError,
        'No internet connection. Please check your network and try again.',
        onRetry,
      );
    } else {
      handleError(error, onRetry: onRetry);
    }
  }
  
  /// Handle server errors specifically
  void handleServerError(dynamic error, VoidCallback? onRetry) {
    if (error is ApiException && error.errorType == ErrorService.serverError) {
      showErrorDialog(
        ErrorService.serverError,
        'Something went wrong on our end. Please try again in a few moments.',
        onRetry,
      );
    } else {
      handleError(error, onRetry: onRetry);
    }
  }
} 