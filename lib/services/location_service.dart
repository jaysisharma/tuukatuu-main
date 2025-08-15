import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuukatuu/providers/location_provider.dart';

/// Global Location Service
/// Provides easy access to the selected delivery location throughout the app
class GlobalLocationService {
  static GlobalLocationService? _instance;
  static GlobalLocationService get instance => _instance ??= GlobalLocationService._();

  GlobalLocationService._();

  /// Get the current delivery location from the LocationProvider
  /// Returns null if no location is set
  static Map<String, dynamic>? getCurrentLocation(BuildContext context) {
    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      return locationProvider.getDeliveryLocationMap();
    } catch (e) {
      print('❌ Error getting current location: $e');
      return null;
    }
  }

  /// Get the current delivery address
  static String? getCurrentAddress(BuildContext context) {
    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      return locationProvider.deliveryAddress;
    } catch (e) {
      print('❌ Error getting current address: $e');
      return null;
    }
  }

  /// Get the current delivery latitude
  static double? getCurrentLatitude(BuildContext context) {
    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      final latitude = locationProvider.deliveryLatitude;
      print('📍 GlobalLocationService: Retrieved latitude: $latitude');
      return latitude;
    } catch (e) {
      print('❌ Error getting current latitude: $e');
      return null;
    }
  }

  /// Get the current delivery longitude
  static double? getCurrentLongitude(BuildContext context) {
    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      final longitude = locationProvider.deliveryLongitude;
      print('📍 GlobalLocationService: Retrieved longitude: $longitude');
      return longitude;
    } catch (e) {
      print('❌ Error getting current longitude: $e');
      return null;
    }
  }

  /// Get the current delivery location label
  static String? getCurrentLocationLabel(BuildContext context) {
    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      return locationProvider.deliveryLabel;
    } catch (e) {
      print('❌ Error getting current location label: $e');
      return null;
    }
  }

  /// Check if a delivery location is set
  static bool hasDeliveryLocation(BuildContext context) {
    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      return locationProvider.hasDeliveryLocation;
    } catch (e) {
      print('❌ Error checking delivery location: $e');
      return false;
    }
  }

  /// Get the current location as a formatted string
  static String getFormattedLocation(BuildContext context) {
    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      
      if (!locationProvider.hasDeliveryLocation) {
        return 'No delivery location set';
      }

      final label = locationProvider.deliveryLabel;
      final address = locationProvider.deliveryAddress;
      
      if (label != null && label.isNotEmpty) {
        return '$label: $address';
      }
      
      return address ?? 'Unknown location';
    } catch (e) {
      print('❌ Error getting formatted location: $e');
      return 'Location unavailable';
    }
  }

  /// Get location coordinates as a string
  static String getCoordinatesString(BuildContext context) {
    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      
      if (!locationProvider.hasDeliveryLocation) {
        return 'No coordinates available';
      }

      final lat = locationProvider.deliveryLatitude;
      final lng = locationProvider.deliveryLongitude;
      
      if (lat != null && lng != null) {
        return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
      }
      
      return 'Coordinates unavailable';
    } catch (e) {
      print('❌ Error getting coordinates string: $e');
      return 'Coordinates unavailable';
    }
  }

  /// Listen to location changes
  static void listenToLocationChanges(BuildContext context, VoidCallback callback) {
    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      locationProvider.addListener(callback);
    } catch (e) {
      print('❌ Error listening to location changes: $e');
    }
  }

  /// Remove location change listener
  static void removeLocationListener(BuildContext context, VoidCallback callback) {
    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      locationProvider.removeListener(callback);
    } catch (e) {
      print('❌ Error removing location listener: $e');
    }
  }
}

/// Extension methods for easy access to location data
extension LocationExtension on BuildContext {
  /// Get current delivery location
  Map<String, dynamic>? get currentLocation => GlobalLocationService.getCurrentLocation(this);
  
  /// Get current delivery address
  String? get currentAddress => GlobalLocationService.getCurrentAddress(this);
  
  /// Get current delivery latitude
  double? get currentLatitude => GlobalLocationService.getCurrentLatitude(this);
  
  /// Get current delivery longitude
  double? get currentLongitude => GlobalLocationService.getCurrentLongitude(this);
  
  /// Get current delivery location label
  String? get currentLocationLabel => GlobalLocationService.getCurrentLocationLabel(this);
  
  /// Check if delivery location is set
  bool get hasDeliveryLocation => GlobalLocationService.hasDeliveryLocation(this);
  
  /// Get formatted location string
  String get formattedLocation => GlobalLocationService.getFormattedLocation(this);
  
  /// Get coordinates string
  String get coordinatesString => GlobalLocationService.getCoordinatesString(this);
} 