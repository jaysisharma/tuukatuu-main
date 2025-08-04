import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProvider with ChangeNotifier {
  String? _deliveryAddress;
  double? _deliveryLatitude;
  double? _deliveryLongitude;
  String? _deliveryLabel;
  bool _isLoading = false;

  // Getters
  String? get deliveryAddress => _deliveryAddress;
  double? get deliveryLatitude => _deliveryLatitude;
  double? get deliveryLongitude => _deliveryLongitude;
  String? get deliveryLabel => _deliveryLabel;
  bool get isLoading => _isLoading;
  bool get hasDeliveryLocation => _deliveryAddress != null && _deliveryLatitude != null && _deliveryLongitude != null;

  // Initialize from shared preferences
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _deliveryAddress = prefs.getString('delivery_address');
      _deliveryLatitude = prefs.getDouble('delivery_latitude');
      _deliveryLongitude = prefs.getDouble('delivery_longitude');
      _deliveryLabel = prefs.getString('delivery_label');
      notifyListeners();
    } catch (e) {
      print('❌ Error initializing location provider: $e');
    }
  }

  // Set delivery location
  Future<void> setDeliveryLocation({
    required String address,
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    _setLoading(true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('delivery_address', address);
      await prefs.setDouble('delivery_latitude', latitude);
      await prefs.setDouble('delivery_longitude', longitude);
      if (label != null) {
        await prefs.setString('delivery_label', label);
      }

      _deliveryAddress = address;
      _deliveryLatitude = latitude;
      _deliveryLongitude = longitude;
      _deliveryLabel = label;
      
      _clearLoading();
      notifyListeners();
    } catch (e) {
      print('❌ Error setting delivery location: $e');
      _clearLoading();
    }
  }

  // Clear delivery location
  Future<void> clearDeliveryLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('delivery_address');
      await prefs.remove('delivery_latitude');
      await prefs.remove('delivery_longitude');
      await prefs.remove('delivery_label');

      _deliveryAddress = null;
      _deliveryLatitude = null;
      _deliveryLongitude = null;
      _deliveryLabel = null;
      
      notifyListeners();
    } catch (e) {
      print('❌ Error clearing delivery location: $e');
    }
  }

  // Get delivery location as map
  Map<String, dynamic>? getDeliveryLocationMap() {
    if (!hasDeliveryLocation) return null;
    
    return {
      'address': _deliveryAddress,
      'latitude': _deliveryLatitude,
      'longitude': _deliveryLongitude,
      'label': _deliveryLabel ?? 'Delivery Location',
    };
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearLoading() {
    _isLoading = false;
  }
}
