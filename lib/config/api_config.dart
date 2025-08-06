// DEPRECATED: Use lib/core/config/app_config.dart instead
// This file is kept for backward compatibility
import '../core/config/app_config.dart';

class ApiConfig {
  // Development URLs - change these based on your network
  @deprecated
  static const String localhost = 'http://13.203.210.247:3000/api';
  
  @deprecated
  static const String localIP = 'http://13.203.210.247:3000/api';
  
  // Use centralized config instead
  @deprecated
  static String get baseUrl => AppConfig.baseUrl;
  
  // Helper method to get the correct URL based on platform
  @deprecated
  static String getBaseUrl() {
    return AppConfig.baseUrl;
  }
} 