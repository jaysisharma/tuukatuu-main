import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:baato_maps/baato_maps.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tuukatuu/providers/address_provider.dart';
import 'package:tuukatuu/providers/auth_provider.dart';
import 'package:tuukatuu/providers/location_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MapPage extends StatefulWidget {
  final BaatoSearchPlace place;
  const MapPage({super.key, required this.place});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const String _baatoAccessToken = 'bpk.c4NQriUA4yoDwdocKtxMB4dwZyoR7uA2jLAo43fTIa4z';

  BaatoMapController? _mapController;
  double? _latitude, _longitude;
  double? _originalLatitude, _originalLongitude; // Store original coordinates
  String? _error, _currentAddress;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isMarkerDraggable = true;
  BaatoCoordinate? _currentMarkerPosition;
  
  // TextEditingControllers for the save location modal
  late TextEditingController _labelController;
  late TextEditingController _addressController;
  late TextEditingController _instructionsController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _fetchPlaceCoordinates();
  }

  void _initializeControllers() {
    _labelController = TextEditingController();
    _addressController = TextEditingController();
    _instructionsController = TextEditingController();
  }

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _fetchPlaceCoordinates() async {
    final placeId = widget.place.placeId;
    if (placeId == null) {
      _setError('Place ID missing. Please try selecting a different location.');
      return;
    }

    final url = 'https://api.baato.io/api/v1/places?key=$_baatoAccessToken&placeId=$placeId';

    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode != 200) {
        _setError('Failed to fetch location details. Please try again.');
        return;
      }

      final data = json.decode(response.body);

      if (data['status'] == 200 && data['data'] != null && data['data'].isNotEmpty) {
        final centroid = data['data'][0]['centroid'];
        _latitude = centroid['lat']?.toDouble();
        _longitude = centroid['lon']?.toDouble();

        if (_latitude != null && _longitude != null) {
          // Store original coordinates for custom location detection
          _originalLatitude = _latitude;
          _originalLongitude = _longitude;
          
          _currentMarkerPosition = BaatoCoordinate(latitude: _latitude!, longitude: _longitude!);
          _addMarkerAndAddress(
            _currentMarkerPosition!,
            widget.place.name ?? 'Selected Location',
          );
          _clearLoading();
          return;
        }
        _setError("Location coordinates are missing. Please try a different place.");
      } else {
        _setError(data['message'] ?? 'Invalid response from location service.');
      }
    } catch (e) {
      print('❌ Error fetching place coordinates: $e');
      _setError('Network error. Please check your internet connection and try again.');
    }
  }

  void _onMapCreated(BaatoMapController controller) {
    _mapController = controller;
    if (_currentMarkerPosition != null) {
      _addMarkerAndAddress(
        _currentMarkerPosition!,
        widget.place.name ?? "Selected Location",
      );
    }
  }

  void _setError(String message) => setState(() {
        _error = message;
        _isLoading = false;
      });

  void _clearLoading() => setState(() {
        _error = null;
        _isLoading = false;
      });

  Future<void> _addMarkerAndAddress(BaatoCoordinate coord, String label) async {
    try {
      await _mapController?.markerManager.clearMarkers();
      await _mapController?.markerManager.addMarker(
        BaatoSymbolOption(
          geometry: coord,
          textField: label,
          iconImage: "baato_marker",
          iconSize: 1.5,
          draggable: _isMarkerDraggable,
        ),
      );
      await _fetchAddress(coord.latitude, coord.longitude);
    } catch (e) {
      print('❌ Error adding marker: $e');
      _setError('Failed to display location on map.');
    }
  }

  Future<void> _onMarkerDragEnd(BaatoCoordinate newPosition) async {
    setState(() {
      _latitude = newPosition.latitude;
      _longitude = newPosition.longitude;
      _currentMarkerPosition = newPosition;
    });
    
    await _fetchAddress(newPosition.latitude, newPosition.longitude);
    
    // Update address controller if modal is open
    _updateAddressControllerIfNeeded();
    
    // Show a subtle indicator instead of intrusive snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on, color: Colors.white, size: 14),
              const SizedBox(width: 6),
              const Text("Updated", style: TextStyle(fontSize: 12)),
            ],
          ),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          duration: const Duration(milliseconds: 1500),
          width: 120,
        ),
      );
    }
  }

  void _updateAddressControllerIfNeeded() {
    // Update the address controller if it's currently being used and the address has changed
    if (_addressController.text.isNotEmpty && 
        _currentAddress != null && 
        _addressController.text != _currentAddress) {
      _addressController.text = _currentAddress!;
    }
  }

  bool _isCustomLocation() {
    return _latitude != null && _longitude != null &&
           _originalLatitude != null && _originalLongitude != null &&
           (_latitude != _originalLatitude || _longitude != _originalLongitude);
  }

  Future<void> _fetchAddress(double lat, double lon) async {
    final url = 'https://api.baato.io/api/v1/reverse?key=$_baatoAccessToken&lat=$lat&lon=$lon';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode != 200) {
        setState(() {
          _currentAddress = widget.place.name ?? 'Selected Location';
        });
        return;
      }

      final data = json.decode(response.body);

      String? address;
      if (data['data'] is List && data['data'].isNotEmpty) {
        address = data['data'][0]['address'];
      } else if (data['data'] is Map) {
        address = data['data']['address'];
      }

      // Check if this is a custom location (marker has been moved from original position)
      final isCustomLocation = _isCustomLocation();

      setState(() {
        if (isCustomLocation) {
          // For custom locations, only use the fetched address without place name
          _currentAddress = address ?? 'Selected Location';
        } else {
          // For searched locations, combine place name and address
          _currentAddress = [widget.place.name, address]
              .whereType<String>()
              .where((s) => s.isNotEmpty)
              .join('\n');
        }
      });
      
      // Update the address controller if it's currently being used in a modal
      _updateAddressControllerIfNeeded();
    } catch (e) {
      print('❌ Error fetching address: $e');
      setState(() {
        _currentAddress = widget.place.name ?? 'Selected Location';
      });
      
      // Update the address controller if it's currently being used in a modal
      _updateAddressControllerIfNeeded();
    }
  }

  Future<void> _saveLocationToBackend({
    required String label,
    required String address,
    required double latitude,
    required double longitude,
    String instructions = '',
  }) async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      
      // Validate address provider
      if (!addressProvider.isAuthenticated) {
        _showSnackBar('Please login to save addresses.', isError: true);
        return;
      }

      final addressData = {
        "label": label.trim(),
        "address": address.trim(),
        "coordinates": {
          "latitude": latitude,
          "longitude": longitude,
        },
        "type": _getAddressType(label),
        "instructions": instructions.trim(),
        "isDefault": false,
      };

      final newAddress = await addressProvider.createAddress(addressData);

      if (!mounted) return;

      if (newAddress != null) {
        _showSnackBar("✅ Location saved successfully!");
        
        // Return the address to the previous screen
        Navigator.pop(context, {
          'address': address,
          'label': label,
          'saved': true,
        });
      } else {
        _showSnackBar("❌ Failed to save location. Please try again.", isError: true);
      }
    } catch (e) {
      print('❌ Error saving location: $e');
      if (mounted) {
        _showSnackBar("❌ Error saving location. Please try again.", isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _useThisAsDeliveryLocation() async {
    if (_latitude == null || _longitude == null || _currentAddress == null) {
      _showSnackBar("Location details unavailable. Please try again.", isError: true);
      return;
    }

    // Check if this is a custom location (not from search)
    final isCustomLocation = !widget.place.name.contains(_currentAddress!);
    
    String finalAddress = _currentAddress!;
    String instructions = '';

    // If it's a custom location, ask for address and instructions
    if (isCustomLocation) {
      // Initialize controllers with current values
      _addressController.text = _currentAddress ?? '';
      _instructionsController.clear();
      
      final result = await showModalBottomSheet<Map<String, String>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Set Delivery Location",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Selected Location",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentAddress!,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: "Address",
                        hintText: "Enter the actual address",
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      maxLines: 2,
                      enabled: true,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _instructionsController,
                      decoration: const InputDecoration(
                        labelText: "Delivery Instructions (Optional)",
                        hintText: "e.g., Near the main gate, 2nd floor, behind the shop",
                        prefixIcon: Icon(Icons.info_outline),
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.done,
                      maxLines: 2,
                      enabled: true,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Set Location"),
                          onPressed: () {
                            final address = _addressController.text.trim();
                            
                            if (address.isEmpty) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                  content: Text("Please enter an address"),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }
                            
                            Navigator.pop(ctx, {
                              'address': address,
                              'instructions': _instructionsController.text.trim(),
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

      if (result != null) {
        finalAddress = result['address']!;
        instructions = result['instructions'] ?? '';
      } else {
        return; // User cancelled
      }
    }

    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Save to location provider for immediate use
      await locationProvider.setDeliveryLocation(
        address: finalAddress,
        latitude: _latitude!,
        longitude: _longitude!,
        label: 'Selected Location',
      );

      // Also save to backend if user is authenticated
      if (authProvider.jwtToken != null) {
        final addressProvider = Provider.of<AddressProvider>(context, listen: false);
        
        final addressData = {
          "label": "Selected Location",
          "address": finalAddress.trim(),
          "coordinates": {
            "latitude": _latitude!,
            "longitude": _longitude!,
          },
          "type": "other",
          "instructions": instructions.trim(),
          "isDefault": false,
        };

        await addressProvider.createAddress(addressData);
      }

      _showSnackBar("✅ Delivery location set successfully!");
      
      Navigator.pop(context, {
        'address': finalAddress,
        'label': 'Selected Location',
        'saved': true,
        'deliveryLocation': true,
      });
    } catch (e) {
      print('❌ Error setting delivery location: $e');
      _showSnackBar("❌ Failed to set delivery location. Please try again.", isError: true);
    }
  }

  String _getAddressType(String label) {
    final lowerLabel = label.toLowerCase();
    if (lowerLabel.contains('home') || lowerLabel.contains('house')) {
      return 'home';
    } else if (lowerLabel.contains('work') || lowerLabel.contains('office')) {
      return 'work';
    } else {
      return 'other';
    }
  }

  Future<void> _showSaveBottomSheet() async {
    if (_latitude == null || _longitude == null || _currentAddress == null) {
      _showSnackBar("Location details unavailable. Please try again.", isError: true);
      return;
    }

    // Initialize controllers with current values
    _labelController.clear();
    _addressController.text = _currentAddress ?? '';
    _instructionsController.clear();
    
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Save Location",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Selected Location",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentAddress!,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _labelController,
                    decoration: const InputDecoration(
                      labelText: "Label (e.g., Home, Work, Gym)",
                      hintText: "Enter a label for this location",
                      prefixIcon: Icon(Icons.label),
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    enabled: true,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: "Address",
                      hintText: "Enter the actual address",
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    maxLines: 2,
                    enabled: true,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _instructionsController,
                    decoration: const InputDecoration(
                      labelText: "Delivery Instructions (Optional)",
                      hintText: "e.g., Near the main gate, 2nd floor, behind the shop",
                      prefixIcon: Icon(Icons.info_outline),
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.done,
                    maxLines: 2,
                    enabled: true,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Save"),
                        onPressed: () {
                          final label = _labelController.text.trim();
                          final address = _addressController.text.trim();
                          
                          if (label.isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter a label"),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }
                          
                          if (address.isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter an address"),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }
                          
                          Navigator.pop(ctx, {
                            'label': label,
                            'address': address,
                            'instructions': _instructionsController.text.trim(),
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (result != null) {
      await _saveLocationToBackend(
        label: result['label']!,
        address: result['address']!,
        latitude: _latitude!,
        longitude: _longitude!,
        instructions: result['instructions'] ?? '',
      );
    }
  }

  Widget _buildAttribution() => Align(
        alignment: Alignment.bottomRight,
        child: InkWell(
          onTap: () => launchUrlString("https://www.openstreetmap.org/copyright"),
          child: Container(
            padding: const EdgeInsets.all(4),
            color: Colors.white70,
            child: const Text.rich(
              TextSpan(
                text: "© ",
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: "OpenStreetMap contributors",
                    style: TextStyle(
                        color: Colors.purple,
                        decoration: TextDecoration.underline),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Map"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Loading map..."),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Map"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text(
                  "Error Loading Map",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _error = null;
                    });
                    _fetchPlaceCoordinates();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Retry"),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Go Back"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Map"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (_currentAddress != null)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isSaving ? null : _showSaveBottomSheet,
              tooltip: "Save Location",
            ),
        ],
      ),
      body: Stack(
        children: [
          BaatoMap(
            style: BaatoMapStyle.breeze,
            initialZoom: 16,
            initialPosition: _currentMarkerPosition ?? BaatoCoordinate(
              latitude: _latitude!, 
              longitude: _longitude!
            ),
            onMapCreated: _onMapCreated,
            onTap: (point, coord, feature) {
              _addMarkerAndAddress(coord, "Custom Location");
              _onMarkerDragEnd(coord);
            },
            logoViewMargins: const Point(-50, -50),
          ),
          // Only show attribution for non-custom locations
          if (!_isCustomLocation()) _buildAttribution(),
          Align(
            alignment: Alignment.bottomCenter,
            child: _currentAddress != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 6)
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentAddress!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _isSaving ? null : _showSaveBottomSheet,
                                icon: _isSaving 
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.save),
                                label: Text(_isSaving ? "Saving..." : "Save Location"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6B35),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: _isSaving ? null : _useThisAsDeliveryLocation,
                                icon: const Icon(Icons.delivery_dining),
                                label: const Text("Use This"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
