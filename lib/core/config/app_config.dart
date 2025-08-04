class AppConfig {
  // API Configuration
  static const String serverIP = 'localhost';
  static const int serverPort = 3000;
  static const String apiPath = '/api';
  
  // Base URLs
  static String get baseUrl => 'http://$serverIP:$serverPort$apiPath';
  static String get tmartBaseUrl => '$baseUrl/tmart';
  
  // Auth Endpoints
  static String get loginUrl => '$baseUrl/auth/login';
  static String get registerUrl => '$baseUrl/auth/register';
  static String get profileUrl => '$baseUrl/auth/me';
  
  // Order Endpoints
  static String get ordersUrl => '$baseUrl/orders';
  static String orderUrl(String orderId) => '$baseUrl/orders/$orderId';
  
  // Product Endpoints
  static String get productsUrl => '$baseUrl/products';
  static String get categoriesUrl => '$baseUrl/categories';
  static String get featuredProductsUrl => '$baseUrl/products/featured';
  
  // Vendor Endpoints
  static String get vendorsUrl => '$baseUrl/vendors';
  static String vendorUrl(String vendorId) => '$baseUrl/vendors/$vendorId';
  
  // Address Endpoints
  static String get addressesUrl => '$baseUrl/addresses';
  static String addressUrl(String addressId) => '$baseUrl/addresses/$addressId';
  
  // Cart Endpoints
  static String get cartUrl => '$baseUrl/cart';
  static String get cartItemsUrl => '$baseUrl/cart/items';
  
  // Search Endpoints
  static String get searchUrl => '$baseUrl/search';
  
  // Banner Endpoints
  static String get bannersUrl => '$baseUrl/banners';
  
  // App Configuration
  static const String appName = 'TuukaTuu';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Your One-Stop Shopping Destination';
  
  // Timeouts
  static const int apiTimeoutSeconds = 30;
  static const int connectionTimeoutSeconds = 10;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache Settings
  static const int cacheExpiryHours = 24;
  static const int imageCacheExpiryDays = 7;
  
  // Validation Rules
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  
  // File Upload Limits
  static const int maxImageSizeMB = 5;
  static const int maxFileSizeMB = 10;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Order Configuration
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
  
  // Map Configuration
  static const double defaultLatitude = 27.7172;
  static const double defaultLongitude = 85.3240;
  static const double defaultZoom = 15.0;
  static const double maxZoom = 20.0;
  static const double minZoom = 10.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Debounce Delays
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
  
  // Notification Configuration
  static const String orderChannel = 'order_notifications';
  static const String generalChannel = 'general_notifications';
  static const String promotionChannel = 'promotion_notifications';
  
  static const int orderStatusNotificationId = 1001;
  static const int newOrderNotificationId = 1002;
  static const int deliveryNotificationId = 1003;
  static const int promotionNotificationId = 1004;
  
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
} 