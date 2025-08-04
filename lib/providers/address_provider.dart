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
  bool get isAuthenticated => _jwtToken != null && _jwtToken!.isNotEmpty;

  // Initialize with token
  void initialize(String token) {
    if (token.isEmpty) {
      _setError('Invalid authentication token.');
      return;
    }
    
    _jwtToken = token;
    _clearError(); // Clear any previous errors
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
    print('🔍 AddressProvider: Starting fetchAddresses...');
    print('🔍 AddressProvider: JWT Token available: ${_jwtToken != null}');
    
    if (_jwtToken == null) {
      print('❌ AddressProvider: No JWT token available');
      _setError('Not authenticated. Please login again.');
      return;
    }

    _setLoading(true);
    _clearError(); // Clear any previous errors
    
    try {
      print('🔍 AddressProvider: Calling ApiService.getAddresses...');
      final addresses = await ApiService.getAddresses(_jwtToken!);
      print('🔍 AddressProvider: Received ${addresses.length} addresses from API');
      
      _addresses = addresses;
      
      // Set default address if available
      if (addresses.isNotEmpty) {
        _defaultAddress = addresses.firstWhere((addr) => addr.isDefault, orElse: () => addresses.first);
        print('🔍 AddressProvider: Set default address: ${_defaultAddress?.label}');
      } else {
        _defaultAddress = null;
        print('🔍 AddressProvider: No addresses found, default address set to null');
      }
      
      _clearError();
      print('🔍 AddressProvider: Successfully loaded ${_addresses.length} addresses');
    } catch (e) {
      print('❌ AddressProvider: Error fetching addresses: $e');
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        _setError('Authentication failed. Please login again.');
      } else if (e.toString().contains('Network') || e.toString().contains('Connection')) {
        _setError('Network error. Please check your internet connection.');
      } else {
        _setError('Failed to fetch addresses. Please try again.');
      }
    } finally {
      _setLoading(false);
      print('🔍 AddressProvider: Fetch completed, loading: $_isLoading');
    }
  }

  // Create new address
  Future<Address?> createAddress(Map<String, dynamic> addressData) async {
    if (_jwtToken == null) {
      _setError('Not authenticated. Please login again.');
      return null;
    }

    _setLoading(true);
    _clearError();
    
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
      print('❌ Error creating address: $e');
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        _setError('Authentication failed. Please login again.');
      } else if (e.toString().contains('Network') || e.toString().contains('Connection')) {
        _setError('Network error. Please check your internet connection.');
      } else {
        _setError('Failed to create address. Please try again.');
      }
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Retry fetching addresses
  Future<void> retryFetchAddresses() async {
    if (!isAuthenticated) {
      _setError('Not authenticated. Please login again.');
      return;
    }
    
    await fetchAddresses();
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

