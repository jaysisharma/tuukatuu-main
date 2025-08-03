import 'package:flutter/foundation.dart';
import '../models/address.dart';
import '../services/api_service.dart';

class AddressProvider with ChangeNotifier {
  List<Address> _addresses = [];
  Address? _defaultAddress;
  bool _isLoading = false;
  String? _error;
  String? _jwtToken;

  // Getters
  List<Address> get addresses => List.unmodifiable(_addresses);
  Address? get defaultAddress => _defaultAddress;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasAddresses => _addresses.isNotEmpty;

  // Initialize with token
  void initialize(String token) {
    _jwtToken = token;
    fetchAddresses();
  }

  // Clear data on logout
  void clear() {
    _addresses.clear();
    _defaultAddress = null;
    _error = null;
    _jwtToken = null;
    notifyListeners();
  }

  // Fetch all addresses
  Future<void> fetchAddresses() async {
    if (_jwtToken == null) return;

    _setLoading(true);
    try {
      final addresses = await ApiService.getAddresses(_jwtToken!);
      _addresses = addresses;
      _defaultAddress = addresses.firstWhere((addr) => addr.isDefault, orElse: () => addresses.first);
      _clearError();
    } catch (e) {
      _setError('Failed to fetch addresses: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create new address
  Future<Address?> createAddress(Map<String, dynamic> addressData) async {
    if (_jwtToken == null) {
      _setError('Not authenticated');
      return null;
    }

    _setLoading(true);
    try {
      final newAddress = await ApiService.createAddress(_jwtToken!, addressData);
      _addresses.add(newAddress);
      
      // If this is the first address or marked as default, set as default
      if (_addresses.length == 1 || addressData['isDefault'] == true) {
        _defaultAddress = newAddress;
      }
      
      _clearError();
      notifyListeners();
      return newAddress;
    } catch (e) {
      _setError('Failed to create address: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update address
  Future<bool> updateAddress(String id, Map<String, dynamic> updateData) async {
    if (_jwtToken == null) {
      _setError('Not authenticated');
      return false;
    }

    _setLoading(true);
    try {
      final updatedAddress = await ApiService.updateAddress(_jwtToken!, id, updateData);
      
      // Update in local list
      final index = _addresses.indexWhere((addr) => addr.id == id);
      if (index != -1) {
        _addresses[index] = updatedAddress;
        
        // Update default address if needed
        if (updatedAddress.isDefault) {
          _defaultAddress = updatedAddress;
        } else if (_defaultAddress?.id == id) {
          _defaultAddress = _addresses.firstWhere((addr) => addr.isDefault, orElse: () => _addresses.first);
        }
      }
      
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update address: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete address
  Future<bool> deleteAddress(String id) async {
    if (_jwtToken == null) {
      _setError('Not authenticated');
      return false;
    }

    _setLoading(true);
    try {
      await ApiService.deleteAddress(_jwtToken!, id);
      
      // Remove from local list
      _addresses.removeWhere((addr) => addr.id == id);
      
      // Update default address if deleted
      if (_defaultAddress?.id == id) {
        _defaultAddress = _addresses.isNotEmpty ? _addresses.first : null;
      }
      
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete address: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Set default address
  Future<bool> setDefaultAddress(String id) async {
    if (_jwtToken == null) {
      _setError('Not authenticated');
      return false;
    }

    _setLoading(true);
    try {
      final updatedAddress = await ApiService.setDefaultAddress(_jwtToken!, id);
      
      // Update all addresses to remove default flag
      _addresses = _addresses.map((addr) {
        if (addr.id == id) {
          return updatedAddress;
        } else {
          // Create a new address object with isDefault = false
          return Address(
            id: addr.id,
            label: addr.label,
            address: addr.address,
            latitude: addr.latitude,
            longitude: addr.longitude,
            type: addr.type,
            instructions: addr.instructions,
            isDefault: false,
            isVerified: addr.isVerified,
            createdAt: addr.createdAt,
            updatedAt: addr.updatedAt,
          );
        }
      }).toList();
      
      _defaultAddress = updatedAddress;
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to set default address: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get address by ID
  Address? getAddressById(String id) {
    try {
      return _addresses.firstWhere((addr) => addr.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search addresses
  List<Address> searchAddresses(String query) {
    if (query.isEmpty) return _addresses;
    
    final lowercaseQuery = query.toLowerCase();
    return _addresses.where((addr) {
      return addr.label.toLowerCase().contains(lowercaseQuery) ||
             addr.address.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}

