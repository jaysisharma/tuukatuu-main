import 'dart:convert';
import 'dart:math';
import 'dart:async';
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
    
    // Set up periodic check for marker addition
    _setupMarkerCheck();
  }
  
  void _setupMarkerCheck() {
    // Check every 500ms for 5 seconds to see if map controller becomes available
    int attempts = 0;
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      attempts++;
      if (_mapController != null && _currentMarkerPosition != null && mounted) {
        print('✅ Map controller and position available, adding marker');
        _addMarkerAndAddress(
          _currentMarkerPosition!,
          widget.place.name ?? "Selected Location",
        );
        timer.cancel();
      } else if (!mounted || attempts >= 10) { // Stop after 5 seconds (10 * 500ms)
        print('⏰ Marker check timeout or widget disposed');
        timer.cancel();
      }
    });
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
          
          print('📍 Coordinates fetched: ${_latitude}, ${_longitude}');
          
          // Only add marker if map controller is ready
          if (_mapController != null) {
            print('🗺️ Map controller ready, adding marker');
            _addMarkerAndAddress(
              _currentMarkerPosition!,
              widget.place.name ?? 'Selected Location',
            );
          } else {
            print('⏳ Map controller not ready yet, will add marker when map is created');
          }
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
    print('🗺️ Map controller created');
    
    // Only add marker if we have coordinates
    if (_currentMarkerPosition != null) {
      print('📍 Adding marker for existing position');
      _addMarkerAndAddress(
        _currentMarkerPosition!,
        widget.place.name ?? "Selected Location",
      );
    } else {
      print('⚠️ No marker position available when map was created');
    }
    
    // Set up marker drag listener if available
    _setupMarkerDragListener();
  }
  
  // Method to check if we need to add a marker after map becomes ready
  void _checkAndAddMarkerIfNeeded() {
    if (_mapController != null && _currentMarkerPosition != null && mounted) {
      print('🔍 Checking if marker needs to be added...');
      _addMarkerAndAddress(
        _currentMarkerPosition!,
        widget.place.name ?? "Selected Location",
      );
    }
  }
  
  void _setupMarkerDragListener() {
    // Note: Baato maps may not have direct marker drag listeners
    // The drag functionality is handled through the draggable property
    // and we'll need to handle position updates through other means
    // For now, we'll rely on the onTap functionality for position updates
  }
  
  // Method to update marker position when user taps on map
  void _updateMarkerPosition(BaatoCoordinate newPosition) {
    if (!mounted) return;
    
    print('📍 Updating marker position to: ${newPosition.latitude}, ${newPosition.longitude}');
    
    setState(() {
      _latitude = newPosition.latitude;
      _longitude = newPosition.longitude;
      _currentMarkerPosition = newPosition;
    });
    
    // Update address for new position
    _fetchAddress(newPosition.latitude, newPosition.longitude);
    
    // Show feedback that this is now a custom location
    if (_isCustomLocation()) {
      _showSnackBar("📍 Custom location selected", isError: false);
    } else {
      _showSnackBar("📍 Location updated", isError: false);
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
    print('🎯 Attempting to add marker: $label at ${coord.latitude}, ${coord.longitude}');
    
    if (_mapController == null) {
      print('❌ Map controller is null, cannot add marker');
      return;
    }
    
    if (!mounted) {
      print('❌ Widget not mounted, cannot add marker');
      return;
    }
    
    // Retry mechanism for marker addition
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        print('🔄 Attempt $attempt: Adding marker...');
        
        // Add a small delay to ensure map controller is fully ready
        await Future.delayed(Duration(milliseconds: 100 * attempt));
        
        print('🗑️ Clearing existing markers...');
        await _mapController!.markerManager.clearMarkers();
        
        print('📍 Adding new marker...');
        final markerOption = BaatoSymbolOption(
          geometry: coord,
          textField: label,
          iconSize: 2.0, // Make it larger for better visibility
          draggable: true, // Make marker draggable
          textColor: "#FF0000", // Red text for better visibility
          textHaloColor: "#FFFFFF", // White halo around text
          textHaloWidth: 1.0, // Halo width
        );
        print('🎯 Marker option created: ${markerOption.textField} at ${markerOption.geometry?.latitude}, ${markerOption.geometry?.longitude}');
        
        await _mapController!.markerManager.addMarker(markerOption);
        
        print('✅ Marker added successfully on attempt $attempt');
        
        // Schedule map centering after a short delay
        Timer(const Duration(milliseconds: 500), () {
          if (mounted && _mapController != null) {
            print('🎯 Scheduling map centering on marker');
            // The map should already be centered since we set initialPosition
          }
        });
        
        await _fetchAddress(coord.latitude, coord.longitude);
        return; // Success, exit the retry loop
      } catch (e) {
        print('❌ Error adding marker on attempt $attempt: $e');
        if (attempt == 3) {
          // Final attempt failed
          if (mounted) {
            _setError('Failed to display location on map after 3 attempts.');
          }
        } else {
          // Wait before retry
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }
  }

  // Method to handle marker drag events
  void _onMarkerDragged(BaatoCoordinate newPosition) {
    print('🎯 Marker dragged to: ${newPosition.latitude}, ${newPosition.longitude}');
    
    if (!mounted) return;
    
    setState(() {
      _latitude = newPosition.latitude;
      _longitude = newPosition.longitude;
      _currentMarkerPosition = newPosition;
    });
    
    // Fetch address for the new position
    _fetchAddress(newPosition.latitude, newPosition.longitude);
  }
  
  // Method to handle marker drag end
  void _onMarkerDragEnd(BaatoCoordinate newPosition) {
    print('🎯 Marker drag ended at: ${newPosition.latitude}, ${newPosition.longitude}');
    
    if (!mounted) return;
    
    setState(() {
      _latitude = newPosition.latitude;
      _longitude = newPosition.longitude;
      _currentMarkerPosition = newPosition;
    });
    
    try {
      _fetchAddress(newPosition.latitude, newPosition.longitude);
      
      // Update address controller if modal is open
      _updateAddressControllerIfNeeded();
      
      // Show feedback
      if (_isCustomLocation()) {
        _showSnackBar("📍 Custom location selected", isError: false);
      } else {
        _showSnackBar("📍 Location updated", isError: false);
      }
    } catch (e) {
      print('❌ Error updating marker position: $e');
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
  
  // Helper method to check if map is ready
  bool get _isMapReady => _mapController != null && mounted;

  bool _isCustomLocation() {
    // A location is considered custom if:
    // 1. We have current coordinates
    // 2. We have original coordinates (from search)
    // 3. Current coordinates are different from original coordinates
    // 4. OR if the user tapped on the map to create a new marker
    
    if (_latitude == null || _longitude == null) {
      return false;
    }
    
    // If we have original coordinates, check if current position is different
    if (_originalLatitude != null && _originalLongitude != null) {
      final latDiff = (_latitude! - _originalLatitude!).abs();
      final lonDiff = (_longitude! - _originalLongitude!).abs();
      
      // Consider it custom if coordinates differ by more than 0.0001 degrees (roughly 10 meters)
      return latDiff > 0.0001 || lonDiff > 0.0001;
    }
    
    // If no original coordinates, it might be a custom location created by tapping
    // Check if the current address doesn't match the original place name
    if (_currentAddress != null && widget.place.name != null) {
      return !_currentAddress!.contains(widget.place.name!) && 
             !widget.place.name!.contains(_currentAddress!);
    }
    
    return false;
  }

  Future<void> _fetchAddress(double lat, double lon) async {
    if (!mounted) return;
    
    final url = 'https://api.baato.io/api/v1/reverse?key=$_baatoAccessToken&lat=$lat&lon=$lon';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode != 200) {
        if (mounted) {
          setState(() {
            _currentAddress = widget.place.name ?? 'Selected Location';
          });
        }
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

      if (mounted) {
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
      }
      
      // Update the address controller if it's currently being used in a modal
      _updateAddressControllerIfNeeded();
    } catch (e) {
      print('❌ Error fetching address: $e');
      if (mounted) {
        setState(() {
          _currentAddress = widget.place.name ?? 'Selected Location';
        });
      }
      
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

    // Check if this is a custom location (marker has been moved from original position)
    final isCustomLocation = _isCustomLocation();
    
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

    // Check if this is a custom location
    final isCustomLocation = _isCustomLocation();
    print('📍 Save location - Is custom location: $isCustomLocation');

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
                  Row(
                    children: [
                      Icon(
                        isCustomLocation ? Icons.edit_location : Icons.save,
                        color: isCustomLocation ? Colors.orange : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isCustomLocation ? "Save Custom Location" : "Save Location",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
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
                          isCustomLocation ? "Custom Location" : "Selected Location",
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
                        if (isCustomLocation) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "Custom Location",
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
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

  // Method to reset to original location
  void _resetToOriginalLocation() {
    if (_originalLatitude != null && _originalLongitude != null) {
      print('🔄 Resetting to original location: $_originalLatitude, $_originalLongitude');
      
      setState(() {
        _latitude = _originalLatitude;
        _longitude = _originalLongitude;
        _currentMarkerPosition = BaatoCoordinate(
          latitude: _originalLatitude!,
          longitude: _originalLongitude!,
        );
      });
      
      // Update marker and address
      if (_isMapReady) {
        _addMarkerAndAddress(
          _currentMarkerPosition!,
          widget.place.name ?? "Selected Location",
        );
      }
      
      _showSnackBar("📍 Reset to original location", isError: false);
    }
  }

  // Method to move marker to a new location
  void _moveMarkerToLocation(BaatoCoordinate newLocation) {
    print('📍 Moving marker to: ${newLocation.latitude}, ${newLocation.longitude}');
    
    if (!mounted) return;
    
    // Update the current position
    setState(() {
      _latitude = newLocation.latitude;
      _longitude = newLocation.longitude;
      _currentMarkerPosition = newLocation;
    });
    
    // Add marker at new location
    _addMarkerAndAddress(newLocation, "Custom Location");
    
    // Fetch address for the new location
    _fetchAddress(newLocation.latitude, newLocation.longitude);
    
    // Show feedback
    if (_isCustomLocation()) {
      _showSnackBar("📍 Custom location selected", isError: false);
    } else {
      _showSnackBar("📍 Location updated", isError: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug information
    if (_currentMarkerPosition != null) {
      print('🗺️ Map Debug - Current: ${_currentMarkerPosition!.latitude}, ${_currentMarkerPosition!.longitude}');
      print('🗺️ Map Debug - Original: $_originalLatitude, $_originalLongitude');
      print('🗺️ Map Debug - Is Custom: ${_isCustomLocation()}');
      print('🗺️ Map Debug - Address: $_currentAddress');
    }
    
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
              latitude: _latitude ?? 27.7172, 
              longitude: _longitude ?? 85.324
            ),
            onMapCreated: _onMapCreated,
            onTap: (point, coord, feature) {
              print('🎯 Map tapped at: ${coord.latitude}, ${coord.longitude}');
              if (_isMapReady) {
                // Move marker to the tapped location
                _moveMarkerToLocation(coord);
              } else {
                print('⚠️ Map not ready for marker movement');
              }
            },
            logoViewMargins: const Point(-50, -50),
          ),
          // Only show attribution for non-custom locations
          if (!_isCustomLocation()) _buildAttribution(),
          // Add a simple overlay to show marker position
          if (_currentMarkerPosition != null)
            Positioned(
              top: MediaQuery.of(context).size.height / 2 - 50,
              left: MediaQuery.of(context).size.width / 2 - 25,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          // Add tap hint overlay
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    "Tap anywhere to move marker",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                          // Show custom location indicator
                          if (_isCustomLocation())
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit_location, color: Colors.orange[700], size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Custom Location",
                                    style: TextStyle(
                                      color: Colors.orange[700],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                                    : Icon(_isCustomLocation() ? Icons.edit_location : Icons.save),
                                label: Text(_isSaving ? "Saving..." : (_isCustomLocation() ? "Save Custom" : "Save Location")),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isCustomLocation() ? Colors.orange : const Color(0xFFFF6B35),
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
                              // Add reset button for custom locations
                              if (_isCustomLocation() && _originalLatitude != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: IconButton(
                                    onPressed: _resetToOriginalLocation,
                                    icon: const Icon(Icons.refresh, color: Colors.blue),
                                    tooltip: "Reset to original location",
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
