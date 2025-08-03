class AppConstants {
  // App Info
  static const String appName = 'Tuukatuu';
  static const String appVersion = '1.0.0';
  
  // Colors
  static const int primaryColorValue = 0xFF2E7D32;
  static const int secondaryColorValue = 0xFFFF6B35;
  static const int backgroundColorValue = 0xFFF8F9FA;
  
  // API Endpoints
  static const String baseUrl = 'http://localhost:3000/api';
  static const String tmartBaseUrl = 'http://localhost:3000/api/tmart';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Timeouts
  static const int apiTimeoutSeconds = 30;
  static const int connectionTimeoutSeconds = 10;
  
  // Cache
  static const int cacheExpiryHours = 24;
  static const int imageCacheExpiryDays = 7;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  
  // File Upload
  static const int maxImageSizeMB = 5;
  static const int maxFileSizeMB = 10;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Order Status
  static const List<String> orderStatuses = [
    'pending',
    'confirmed',
    'preparing',
    'outfordelivery',
    'delivered',
    'cancelled',
    'failed'
  ];
  
  // Payment Methods
  static const List<String> paymentMethods = [
    'cash',
    'esewa',
    'khalti',
    'fonepay',
    'connectips',
    'imepay'
  ];
  
  // Delivery Times
  static const List<String> deliveryTimes = [
    'As soon as possible',
    'In 30 minutes',
    'In 1 hour',
    'In 2 hours'
  ];
  
  // Tip Options
  static const List<int> tipOptions = [20, 50, 100];
  
  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError = 'An unknown error occurred.';
  static const String invalidCredentials = 'Invalid email or password.';
  static const String emailAlreadyExists = 'Email already exists.';
  static const String weakPassword = 'Password is too weak.';
  
  // Success Messages
  static const String loginSuccess = 'Login successful!';
  static const String signupSuccess = 'Account created successfully!';
  static const String profileUpdated = 'Profile updated successfully!';
  static const String passwordChanged = 'Password changed successfully!';
  static const String orderPlaced = 'Order placed successfully!';
  static const String orderCancelled = 'Order cancelled successfully!';
  
  // Loading Messages
  static const String loading = 'Loading...';
  static const String processing = 'Processing...';
  static const String uploading = 'Uploading...';
  static const String saving = 'Saving...';
  
  // Empty State Messages
  static const String noOrders = 'No orders found.';
  static const String noProducts = 'No products found.';
  static const String noAddresses = 'No addresses found.';
  static const String noFavorites = 'No favorites found.';
  static const String noSearchResults = 'No search results found.';
  
  // Map Constants
  static const double defaultLatitude = 27.7172;
  static const double defaultLongitude = 85.3240;
  static const double defaultZoom = 15.0;
  static const double maxZoom = 20.0;
  static const double minZoom = 10.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Debounce Delay
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration scrollDebounce = Duration(milliseconds: 100);
  
  // Refresh Intervals
  static const Duration orderRefreshInterval = Duration(seconds: 30);
  static const Duration locationRefreshInterval = Duration(seconds: 10);
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String locationKey = 'last_location';
  static const String cartKey = 'cart_data';
  
  // Notification Channels
  static const String orderChannel = 'order_notifications';
  static const String generalChannel = 'general_notifications';
  static const String promotionChannel = 'promotion_notifications';
  
  // Notification IDs
  static const int orderStatusNotificationId = 1001;
  static const int newOrderNotificationId = 1002;
  static const int deliveryNotificationId = 1003;
  static const int promotionNotificationId = 1004;
} 