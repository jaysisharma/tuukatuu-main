import '../core/config/app_config.dart';

class AppConstants {
  // App Info
  static const String appName = AppConfig.appName;
  static const String appVersion = AppConfig.appVersion;
  
  // Colors
  static const int primaryColorValue = 0xFF2E7D32;
  static const int secondaryColorValue = 0xFFFF6B35;
  static const int backgroundColorValue = 0xFFF8F9FA;
  
  // API Endpoints - Now using centralized config
  static String get baseUrl => AppConfig.baseUrl;
  static String get tmartBaseUrl => AppConfig.tmartBaseUrl;
  
  // Pagination
  static const int defaultPageSize = AppConfig.defaultPageSize;
  static const int maxPageSize = AppConfig.maxPageSize;
  
  // Timeouts
  static const int apiTimeoutSeconds = AppConfig.apiTimeoutSeconds;
  static const int connectionTimeoutSeconds = AppConfig.connectionTimeoutSeconds;
  
  // Cache
  static const int cacheExpiryHours = AppConfig.cacheExpiryHours;
  static const int imageCacheExpiryDays = AppConfig.imageCacheExpiryDays;
  
  // Validation
  static const int minPasswordLength = AppConfig.minPasswordLength;
  static const int maxPasswordLength = AppConfig.maxPasswordLength;
  static const int minNameLength = AppConfig.minNameLength;
  static const int maxNameLength = AppConfig.maxNameLength;
  
  // File Upload
  static const int maxImageSizeMB = AppConfig.maxImageSizeMB;
  static const int maxFileSizeMB = AppConfig.maxFileSizeMB;
  static const List<String> allowedImageTypes = AppConfig.allowedImageTypes;
  
  // Order Status
  static const List<String> orderStatuses = AppConfig.orderStatuses;
  
  // Payment Methods
  static const List<String> paymentMethods = AppConfig.paymentMethods;
  
  // Delivery Times
  static const List<String> deliveryTimes = AppConfig.deliveryTimes;
  
  // Tip Options
  static const List<int> tipOptions = AppConfig.tipOptions;
  
  // Error Messages
  static const String networkError = AppConfig.networkError;
  static const String serverError = AppConfig.serverError;
  static const String unknownError = AppConfig.unknownError;
  static const String invalidCredentials = AppConfig.invalidCredentials;
  static const String emailAlreadyExists = AppConfig.emailAlreadyExists;
  static const String weakPassword = AppConfig.weakPassword;
  
  // Success Messages
  static const String loginSuccess = AppConfig.loginSuccess;
  static const String signupSuccess = AppConfig.signupSuccess;
  static const String profileUpdated = AppConfig.profileUpdated;
  static const String passwordChanged = AppConfig.passwordChanged;
  static const String orderPlaced = AppConfig.orderPlaced;
  static const String orderCancelled = AppConfig.orderCancelled;
  
  // Loading Messages
  static const String loading = AppConfig.loading;
  static const String processing = AppConfig.processing;
  static const String uploading = AppConfig.uploading;
  static const String saving = AppConfig.saving;
  
  // Empty State Messages
  static const String noOrders = AppConfig.noOrders;
  static const String noProducts = AppConfig.noProducts;
  static const String noAddresses = AppConfig.noAddresses;
  static const String noFavorites = AppConfig.noFavorites;
  static const String noSearchResults = AppConfig.noSearchResults;
  
  // Map Constants
  static const double defaultLatitude = AppConfig.defaultLatitude;
  static const double defaultLongitude = AppConfig.defaultLongitude;
  static const double defaultZoom = AppConfig.defaultZoom;
  static const double maxZoom = AppConfig.maxZoom;
  static const double minZoom = AppConfig.minZoom;
  
  // Animation Durations
  static const Duration shortAnimation = AppConfig.shortAnimation;
  static const Duration mediumAnimation = AppConfig.mediumAnimation;
  static const Duration longAnimation = AppConfig.longAnimation;
  
  // Debounce Delay
  static const Duration searchDebounce = AppConfig.searchDebounce;
  static const Duration scrollDebounce = AppConfig.scrollDebounce;
  
  // Refresh Intervals
  static const Duration orderRefreshInterval = AppConfig.orderRefreshInterval;
  static const Duration locationRefreshInterval = AppConfig.locationRefreshInterval;
  
  // Storage Keys
  static const String tokenKey = AppConfig.tokenKey;
  static const String userKey = AppConfig.userKey;
  static const String themeKey = AppConfig.themeKey;
  static const String languageKey = AppConfig.languageKey;
  static const String locationKey = AppConfig.locationKey;
  static const String cartKey = AppConfig.cartKey;
  
  // Notification Channels
  static const String orderChannel = AppConfig.orderChannel;
  static const String generalChannel = AppConfig.generalChannel;
  static const String promotionChannel = AppConfig.promotionChannel;
  
  // Notification IDs
  static const int orderStatusNotificationId = AppConfig.orderStatusNotificationId;
  static const int newOrderNotificationId = AppConfig.newOrderNotificationId;
  static const int deliveryNotificationId = AppConfig.deliveryNotificationId;
  static const int promotionNotificationId = AppConfig.promotionNotificationId;
} 