
import 'package:baato_maps/baato_maps.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:tuukatuu/presentation/screens/location/Map_Page.dart';
import 'package:tuukatuu/models/address.dart';
import 'package:tuukatuu/providers/address_provider.dart';
import 'package:tuukatuu/providers/auth_provider.dart';
import 'package:tuukatuu/providers/location_provider.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _currentLocationDisplay = "Detecting location...";
  String _locationDetails = "";
  bool _isLoadingLocation = false;
  double _currentLatitude = 0.0;
  double _currentLongitude = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAddressProvider();
    _determinePositionAndFetchAddress();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeAddressProvider() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);
    
    if (authProvider.jwtToken != null) {
      addressProvider.initialize(authProvider.jwtToken!);
    }
  }

  // Core location methods
  Future<void> _determinePositionAndFetchAddress() async {
    if (_isLoadingLocation) return;

    setState(() {
      _isLoadingLocation = true;
      _currentLocationDisplay = "Getting location...";
      _locationDetails = "";
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setLocationError("Location services disabled", "Enable GPS in settings");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setLocationError("Permission denied", "Grant location access");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setLocationError("Permission permanently denied", "Enable in app settings");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String street = place.street ?? place.name ?? "";
        String locality = "${place.locality ?? ''}, ${place.administrativeArea ?? ''}";

        setState(() {
          _currentLocationDisplay = street.isEmpty ? "Current Location" : street;
          _locationDetails = locality;
          _isLoadingLocation = false;
        });
        
        // Store the actual coordinates for later use
        _currentLatitude = position.latitude;
        _currentLongitude = position.longitude;
      }
    } catch (e) {
      _setLocationError("Location unavailable", "Try again");
    }
  }

  void _setLocationError(String message, String details) {
    setState(() {
      _currentLocationDisplay = message;
      _locationDetails = details;
      _isLoadingLocation = false;
    });
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  // UI Interaction methods
  Future<void> _useCurrentLocation() async {
    if (_isLoadingLocation) return;

    if (_currentLocationDisplay.contains("disabled") ||
        _currentLocationDisplay.contains("denied") ||
        _currentLocationDisplay.contains("unavailable")) {
      await _determinePositionAndFetchAddress();
      return;
    }

    final fullAddress = _buildFullAddress();
    
    // Set as delivery location
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.setDeliveryLocation(
      address: fullAddress,
      latitude: _currentLatitude, // Use actual coordinates
      longitude: _currentLongitude,
      label: 'Current Location',
    );
    
    if (mounted) {
      _showSnackBar("Delivery location set to current location");
      Navigator.pop(context, {
        'label': 'Current Location',
        'address': fullAddress,
        'deliveryLocation': true,
      });
    }
  }

  String _buildFullAddress() {
    return _locationDetails.isNotEmpty
        ? "$_currentLocationDisplay, $_locationDetails"
        : _currentLocationDisplay;
  }

  Future<void> _updateAddressLabel(Address address) async {
    final controller = TextEditingController(text: address.label);

    final newLabel = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Edit Address Label",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              address.address,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "e.g., Home, Work, Gym",
                labelText: "Label",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, controller.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Update"),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (newLabel != null && newLabel.isNotEmpty && newLabel != address.label) {
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      final success = await addressProvider.updateAddress(address.id, {'label': newLabel});
      
      if (mounted) {
        if (success) {
          _showSnackBar("Address updated to '$newLabel'");
        } else {
          _showSnackBar("Failed to update address");
        }
      }
    }
  }

  Future<void> _deleteAddress(Address address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Delete Address"),
          content: Text("Are you sure you want to delete '${address.label}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirmed) {
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      final success = await addressProvider.deleteAddress(address.id);
      
      if (mounted) {
        if (success) {
          _showSnackBar("Address '${address.label}' deleted");
        } else {
          _showSnackBar("Failed to delete address");
        }
      }
    }
  }

  Future<void> _setDefaultAddress(Address address) async {
    if (address.isDefault) return;
    
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);
    final success = await addressProvider.setDefaultAddress(address.id);
    
    if (mounted) {
      if (success) {
        _showSnackBar("'${address.label}' set as default address");
      } else {
        _showSnackBar("Failed to set default address");
      }
    }
  }

  Widget _buildCurrentLocationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B35),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: _useCurrentLocation,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _isLoadingLocation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.my_location, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Use Current Location",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _buildFullAddress(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedLocationsList() {
    return Consumer<AddressProvider>(
      builder: (context, addressProvider, child) {
        // Handle loading state
        if (addressProvider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Handle error state
        if (addressProvider.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    "Error loading addresses",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    addressProvider.error!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => addressProvider.retryFetchAddresses(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Retry"),
                      ),
                      if (!addressProvider.isAuthenticated) ...[
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to login screen or refresh auth
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Login"),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        // Handle empty state (no addresses)
        if (addressProvider.addresses.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    "No saved locations yet",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Search for a place or use current location to save your first address",
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Show addresses list
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: addressProvider.addresses.length,
          itemBuilder: (context, index) {
            final address = addressProvider.addresses[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: address.isDefault ? const Color(0xFFFF6B35) : Colors.grey[200]!,
                  width: address.isDefault ? 2 : 1,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIconForLabel(address.label),
                    color: const Color(0xFFFF6B35),
                    size: 20,
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        address.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (address.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Default",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (address.instructions.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          "📝 ${address.instructions}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!address.isDefault)
                      IconButton(
                        icon: Icon(Icons.star_outline, color: Colors.amber[600], size: 20),
                        onPressed: () => _setDefaultAddress(address),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        tooltip: "Set as default",
                      ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue[600], size: 20),
                      onPressed: () => _updateAddressLabel(address),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      tooltip: "Edit label",
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red[600], size: 20),
                      onPressed: () => _deleteAddress(address),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      tooltip: "Delete address",
                    ),
                  ],
                ),
                onTap: () async {
                  // Set as delivery location
                  final locationProvider = Provider.of<LocationProvider>(context, listen: false);
                  await locationProvider.setDeliveryLocation(
                    address: address.address,
                    latitude: address.latitude,
                    longitude: address.longitude,
                    label: address.label,
                  );
                  
                  if (mounted) {
                    _showSnackBar("✅ Delivery location set to '${address.label}'");
                    Navigator.pop(context, {
                      'label': address.label,
                      'address': address.address,
                      'deliveryLocation': true,
                    });
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case "home":
        return Icons.home;
      case "work":
        return Icons.work;
      case "other":
        return Icons.location_on;
      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Select Location",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      body: Column(
        children: [
          // Search section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                BaatoPlaceAutoSuggestion(
                  hintText: 'Search places...',
                  
                  onPlaceSelected: (suggestion) async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapPage(place: suggestion),
                      ),
                    );

                    if (result != null && result is Map<String, String>) {
                      final address = result['address']!;
                      final label = result['label']!;
                      _showSnackBar("Location selected: $label");
                      Navigator.pop(context, {
                        'label': label,
                        'address': address,
                      });
                    }
                  },
                  inputDecoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),
                _buildCurrentLocationCard(),
              ],
            ),
          ),

          // Content section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saved locations header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Saved Locations",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Consumer<AddressProvider>(
                        builder: (context, addressProvider, child) {
                          if (addressProvider.isLoading) {
                            return const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }
                          return IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () => addressProvider.fetchAddresses(),
                            tooltip: "Refresh addresses",
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Saved locations list
                  _buildSavedLocationsList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
