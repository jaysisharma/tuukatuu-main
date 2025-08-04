# Error Handling Guide

## Overview
This guide explains how to implement proper error handling in the Tuukatuu Flutter app to prevent exposing technical backend errors to users and provide a better user experience.

## The Problem
❌ **What we DON'T want to show users:**
```
ClientException with SocketException: Connection refused (OS Error: Connection refused, errno = 61), address = 13.234.29.215, port = 63091, uri=http://13.234.29.215:3000/api/auth/login
```

✅ **What we SHOULD show users:**
```
"No internet connection. Please check your network and try again."
```

## Components

### 1. ErrorService (`lib/services/error_service.dart`)
Central service that categorizes errors and provides user-friendly messages.

**Key Features:**
- Categorizes errors by type (network, authentication, server, etc.)
- Provides user-friendly error messages
- Includes appropriate icons for each error type
- Handles HTTP status codes
- Logs errors for debugging (without exposing to users)

**Error Types:**
```dart
static const String networkError = 'network_error';
static const String authenticationError = 'authentication_error';
static const String serverError = 'server_error';
static const String validationError = 'validation_error';
static const String timeoutError = 'timeout_error';
static const String permissionError = 'permission_error';
static const String notFoundError = 'not_found_error';
static const String rateLimitError = 'rate_limit_error';
static const String paymentError = 'payment_error';
static const String orderError = 'order_error';
static const String productError = 'product_error';
static const String addressError = 'address_error';
```

### 2. ApiException (`lib/services/api_service.dart`)
Custom exception class that wraps backend errors with proper categorization.

```dart
class ApiException implements Exception {
  final String errorType;
  final String message;
  final String? originalError;

  ApiException(this.errorType, this.message, [this.originalError]);
}
```

### 3. ErrorHandlerMixin (`lib/utils/error_handler_mixin.dart`)
Mixin that provides consistent error handling across screens.

**Key Methods:**
- `handleError()` - Automatically categorizes and displays errors
- `handleAsyncOperation()` - Wraps async operations with error handling
- `handleApiOperation()` - Specifically for API calls
- `showErrorSnackBar()` - Shows user-friendly error messages
- `showErrorDialog()` - Shows error dialogs with retry options

### 4. Error Widgets (`lib/widgets/error_widget.dart`)
Reusable widgets for displaying errors consistently.

- `CustomErrorWidget` - Generic error display
- `NetworkErrorWidget` - Network-specific errors
- `ServerErrorWidget` - Server-specific errors
- `AuthenticationErrorWidget` - Auth-specific errors
- `LoadingWidget` - Loading states
- `EmptyStateWidget` - Empty states

## Implementation Examples

### 1. In API Service
```dart
static Future<dynamic> get(String endpoint, {String? token, Map<String, String>? headers, Map<String, String>? params}) async {
  try {
    final response = await http.get(uri, headers: _buildHeaders(token, headers));
    return _handleResponse(response);
  } catch (e) {
    // Convert raw error to user-friendly error
    final errorType = ErrorService.handleApiError(e);
    throw ApiException(errorType, ErrorService.getErrorMessage(errorType));
  }
}
```

### 2. In Providers
```dart
Future<void> login({required String email, required String password}) async {
  try {
    final data = await ApiService.post('/auth/login', body: {
      'email': email,
      'password': password,
    });
    // Handle success
  } catch (e) {
    if (e is ApiException) {
      throw ApiException(e.errorType, e.message);
    }
    throw ApiException(ErrorService.authenticationError, 'Login failed. Please check your credentials.');
  }
}
```

### 3. In Screens (Using Mixin)
```dart
class _LoginScreenState extends State<LoginScreen> with ErrorHandlerMixin {
  
  Future<void> _login() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // Navigate on success
    } catch (e) {
      // Automatically handles error categorization and display
      handleError(e);
    }
  }
}
```

### 4. In Screens (Manual)
```dart
Future<void> _login() async {
  try {
    // API call
  } catch (e) {
    if (e is ApiException) {
      ErrorService.showErrorSnackBar(context, e.errorType, e.message);
    } else {
      ErrorService.showErrorSnackBar(context, ErrorService.authenticationError, 'Login failed. Please try again.');
    }
  }
}
```

## Error Categorization Logic

### Network Errors
- Connection refused
- Socket exceptions
- Host unreachable
- Network unavailable

### Authentication Errors
- 401 Unauthorized
- 403 Forbidden
- Token expired
- Invalid credentials

### Server Errors
- 500 Internal Server Error
- 502 Bad Gateway
- 503 Service Unavailable
- 504 Gateway Timeout

### Validation Errors
- 400 Bad Request
- Invalid input data
- Missing required fields

### Timeout Errors
- Request timeout
- Connection timeout
- 408 Request Timeout
- 504 Gateway Timeout

## Best Practices

### 1. Never Expose Technical Details
❌ Don't show:
- IP addresses
- Port numbers
- Internal error codes
- Stack traces
- Database errors

✅ Do show:
- User-friendly messages
- Actionable instructions
- Retry options when appropriate

### 2. Log Errors for Debugging
```dart
ErrorService.logError(errorType, message, {
  'screen': widget.runtimeType.toString(),
  'error': error.toString(), // Only in logs, not UI
  'timestamp': DateTime.now().toIso8601String(),
});
```

### 3. Provide Retry Options
```dart
ErrorService.showErrorDialog(
  context,
  ErrorService.networkError,
  'No internet connection. Please check your network and try again.',
  () => _retryOperation(), // Retry callback
);
```

### 4. Handle Different Error Types Appropriately
- **Network errors**: Show retry option
- **Authentication errors**: Navigate to login
- **Server errors**: Show retry with delay
- **Validation errors**: Show specific field errors
- **Permission errors**: Guide user to settings

### 5. Use Appropriate UI Components
- **Snackbars**: For temporary, non-critical errors
- **Dialogs**: For important errors requiring user action
- **Error widgets**: For full-screen error states
- **Loading states**: For operations in progress

## Migration Guide

### Step 1: Update API Service
Replace raw error throwing with `ApiException`:
```dart
// Before
throw Exception('${response.statusCode}: $message');

// After
throw ApiException(ErrorService.handleHttpStatus(response.statusCode), message);
```

### Step 2: Update Providers
Wrap API calls with proper error handling:
```dart
// Before
final data = await ApiService.get('/endpoint');

// After
try {
  final data = await ApiService.get('/endpoint');
} catch (e) {
  if (e is ApiException) {
    throw e;
  }
  throw ApiException(ErrorService.unknownError, 'Operation failed');
}
```

### Step 3: Update Screens
Use ErrorHandlerMixin or manual error handling:
```dart
// Before
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Error: $e')),
);

// After
if (e is ApiException) {
  ErrorService.showErrorSnackBar(context, e.errorType, e.message);
} else {
  ErrorService.showErrorSnackBar(context, ErrorService.unknownError);
}
```

### Step 4: Replace Error Widgets
Use the new error widgets:
```dart
// Before
Center(child: Text('Error: $error'));

// After
CustomErrorWidget(
  errorType: errorType,
  message: message,
  onRetry: () => _retry(),
);
```

## Testing Error Handling

### 1. Network Errors
- Turn off internet connection
- Use invalid API endpoints
- Test timeout scenarios

### 2. Authentication Errors
- Use expired tokens
- Test invalid credentials
- Test unauthorized endpoints

### 3. Server Errors
- Mock 500 errors
- Test rate limiting
- Test service unavailability

### 4. Validation Errors
- Submit invalid data
- Test missing required fields
- Test format validation

## Security Considerations

1. **Never log sensitive data** (passwords, tokens, personal info)
2. **Sanitize error messages** before logging
3. **Use different log levels** for development vs production
4. **Implement rate limiting** for error reporting
5. **Monitor error patterns** for potential security issues

## Monitoring and Analytics

Track error patterns to improve the app:
```dart
ErrorService.logError(errorType, message, {
  'screen': screenName,
  'action': actionName,
  'user_id': userId, // If available
  'timestamp': DateTime.now().toIso8601String(),
});
```

This helps identify:
- Most common error types
- Problematic screens/features
- Network connectivity issues
- Server performance problems 