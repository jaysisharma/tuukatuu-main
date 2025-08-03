import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever
      return false;
    }

    // Permissions are granted
    return true;
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  static Future<String> getAddressFromCoordinates(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        final addressParts = <String>[
          if (place.subLocality?.isNotEmpty ?? false) place.subLocality!,
          if (place.locality?.isNotEmpty ?? false) place.locality!,
          if (place.administrativeArea?.isNotEmpty ?? false) place.administrativeArea!,
        ];
        
        return addressParts.isNotEmpty ? addressParts.join(', ') : 'Location found';
      }
      return 'Location found';
    } catch (e) {
      return 'Location found';
    }
  }

  static String calculateDistanceText(Position? userLocation, Map<String, dynamic>? storeCoordinates) {
    if (userLocation == null || storeCoordinates == null) {
      return 'Distance unavailable';
    }
    
    try {
      final storeLat = storeCoordinates['latitude'];
      final storeLng = storeCoordinates['longitude'];
      
      if (storeLat == null || storeLng == null) {
        return 'Distance unavailable';
      }
      
      final distance = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        storeLat.toDouble(),
        storeLng.toDouble(),
      );
      
      if (distance < 1000) {
        return '${distance.round()}m away';
      } else {
        return '${(distance / 1000).toStringAsFixed(1)}km away';
      }
    } catch (e) {
      print('Error calculating distance: $e');
      return 'Distance unavailable';
    }
  }

  static double? calculateDistance(Position? userLocation, Map<String, dynamic>? storeCoordinates) {
    if (userLocation == null || storeCoordinates == null) {
      return null;
    }
    
    try {
      final storeLat = storeCoordinates['latitude'];
      final storeLng = storeCoordinates['longitude'];
      
      if (storeLat == null || storeLng == null) {
        return null;
      }
      
      return Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        storeLat.toDouble(),
        storeLng.toDouble(),
      );
    } catch (e) {
      print('Error calculating distance: $e');
      return null;
    }
  }
} 