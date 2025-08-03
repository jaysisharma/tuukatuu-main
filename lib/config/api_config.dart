class ApiConfig {
  // Development URLs - change these based on your network
  static const String localhost = 'http://10.0.2.2:3000/api';
  static const String localIP = 'http://10.0.2.2:3000/api';
  
  // Use localIP for device/emulator, localhost for web
  static const String baseUrl = localIP;
  
  // Alternative: You can uncomment the line below to use localhost for web testing
  // static const String baseUrl = localhost;
  
  // Helper method to get the correct URL based on platform
  static String getBaseUrl() {
    // You can add platform detection here if needed
    return baseUrl;
  }
} 