import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http; // Import http package
import 'dart:convert'; // Import for JSON decoding

// Assuming these services and providers are correctly implemented
import '../../services/location_service.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/address_provider.dart';

// --- Main Location Screen (Consolidated for better UI/UX) ---
class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoadingCurrentLocation = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _savedAddresses = [];
  bool _isLoadingAddresses = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Attempt to get current location on start
    _loadSavedAddresses(); // Load saved addresses
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingCurrentLocation = true;
      _errorMessage = null;
    });

    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        final address = await LocationService.getAddressFromCoordinates(position);
        setState(() {
          _currentPosition = position;
          _currentAddress = address;
          _isLoadingCurrentLocation = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Unable to get location. Please enable location services.';
          _isLoadingCurrentLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location. Please check permissions.';
        _isLoadingCurrentLocation = false;
      });
    }
  }

  Future<void> _loadSavedAddresses() async {
    setState(() {
      _isLoadingAddresses = true;
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.jwtToken != null) {
        final response = await ApiService.get('/addresses', token: authProvider.jwtToken);
        setState(() {
          _savedAddresses = List<Map<String, dynamic>>.from(response);
          _isLoadingAddresses = false;
        });
      } else {
        setState(() {
          _isLoadingAddresses = false;
        });
        // Handle unauthenticated state, maybe show a message or redirect to login
      }
    } catch (e) {
      setState(() {
        _isLoadingAddresses = false;
      });
      print('Error loading saved addresses: $e'); // For debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load addresses: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteAddress(String addressId) async {
    // Show confirmation dialog before deleting
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Delete Address?'),
          content: const Text('Are you sure you want to delete this address? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await ApiService.delete('/addresses/$addressId', token: authProvider.jwtToken);

        setState(() {
          _savedAddresses.removeWhere((addr) => addr['_id'] == addressId);
        });

        // Update address provider
        final addressProvider = Provider.of<AddressProvider>(context, listen: false);
        await addressProvider.fetchAddresses();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting address: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareAddress(Map<String, dynamic> address) {
    final coordinates = address['coordinates'];
    final lat = coordinates?['latitude'] ?? 0;
    final lng = coordinates?['longitude'] ?? 0;
    final fullAddress = address['address'] ?? 'N/A';

    Share.share(
      'Check out this location!\n\nAddress: $fullAddress\nCoordinates: $lat, $lng',
      subject: 'Shared Location',
    );
  }

  // --- UI Builder for Saved Address Item ---
  Widget _buildSavedAddressItem(Map<String, dynamic> address) {
    final isDefault = address['isDefault'] ?? false;
    final type = address['type'] ?? 'other';
    final label = address['label'] ?? 'Unknown';
    final fullAddress = address['address'] ?? 'No address';
    final landmark = address['landmark'];
    final floor = address['floor'];
    final building = address['building'];
    final instructions = address['instructions'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDefault ? Colors.orange : Colors.grey[200]!,
          width: isDefault ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            final coordinates = address['coordinates'];
            if (coordinates != null) {
              Navigator.pop(context, {
                'address': address['address'],
                'position': Position(
                  latitude: coordinates['latitude'],
                  longitude: coordinates['longitude'],
                  timestamp: DateTime.now(),
                  accuracy: 0,
                  altitude: 0,
                  heading: 0,
                  speed: 0,
                  speedAccuracy: 0,
                  altitudeAccuracy: 0,
                  headingAccuracy: 0,
                ),
                'addressData': address,
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getTypeColor(type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getTypeIcon(type),
                        color: _getTypeColor(type),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (isDefault) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'DEFAULT',
                                    style: TextStyle(
                                      color: Colors.orange[700],
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fullAddress,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                          // TODO: Implement edit functionality (would open the Add/Select Location modal with pre-filled data)
                            break;
                          case 'delete':
                            _deleteAddress(address['_id']);
                            break;
                          case 'share':
                            _shareAddress(address);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'share',
                          child: Row(
                            children: [
                              Icon(Icons.share, size: 20),
                              SizedBox(width: 8),
                              Text('Share'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      child: const Icon(Icons.more_vert, color: Colors.grey),
                    ),
                  ],
                ),
                // Optional: Display more details if available
                if (landmark != null && landmark.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Landmark: $landmark',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ),
                if ((floor != null && floor.isNotEmpty) || (building != null && building.isNotEmpty))
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '${floor != null && floor.isNotEmpty ? 'Floor: $floor' : ''}${floor != null && floor.isNotEmpty && building != null && building.isNotEmpty ? ', ' : ''}${building != null && building.isNotEmpty ? 'Building: $building' : ''}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ),
                if (instructions != null && instructions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Instructions: $instructions',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'home':
        return Colors.blue;
      case 'work':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'home':
        return Icons.home_outlined;
      case 'work':
        return Icons.work_outline;
      default:
        return Icons.location_on_outlined;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No saved addresses',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first address to get started',
            style: TextStyle(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddLocationModal(),
            icon: const Icon(Icons.add_location),
            label: const Text('Add New Address'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Modal for Adding/Selecting Location (Refactored to be more interactive) ---
  Future<void> _showAddLocationModal({bool isForOrder = false}) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddLocationModal(
        initialPosition: _currentPosition, // Pass current position to the modal
        initialAddress: _currentAddress, // Pass current address to the modal
        isForOrder: isForOrder,
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      if (result.containsKey('addressData')) {
        // If it's for an order, pop back to the main screen with the selected address
        Navigator.pop(context, result);
      } else if (result.containsKey('addressSaved') && result['addressSaved'] == true) {
        // If an address was saved, reload the list
        _loadSavedAddresses();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choose Location',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Use Current Location Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: _isLoadingCurrentLocation ? null : () {
                  if (_currentPosition != null && _currentAddress != null) {
                    // Immediately use current location for order
                    Navigator.pop(context, {
                      'address': _currentAddress,
                      'position': _currentPosition,
                      'addressData': {
                        'address': _currentAddress,
                        'coordinates': {
                          'latitude': _currentPosition!.latitude,
                          'longitude': _currentPosition!.longitude,
                        },
                        'type': 'current',
                        'label': 'Current Location',
                      },
                    });
                  } else {
                    _getCurrentLocation(); // Retry if not available
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.my_location,
                            color: Colors.orange[700],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Use My Current Location',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_isLoadingCurrentLocation)
                        const LinearProgressIndicator(color: Colors.orange)
                      else if (_currentAddress != null)
                        Text(
                          _currentAddress!,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                        )
                      else if (_errorMessage != null)
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        )
                      else
                        Text(
                          'Tap to get your precise location for delivery.',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16), // Reduced space

          // Saved Addresses Section
          Expanded(
            child: _isLoadingAddresses
                ? const Center(child: CircularProgressIndicator())
                : _savedAddresses.isEmpty
                    ? _buildEmptyState()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'SAVED ADDRESSES',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${_savedAddresses.length} address${_savedAddresses.length != 1 ? 'es' : ''}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Add New Address Button directly in the header
                                IconButton(
                                  icon: const Icon(Icons.add_location, color: Colors.orange),
                                  onPressed: () => _showAddLocationModal(),
                                  tooltip: 'Add New Address',
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ..._savedAddresses.map((addr) => _buildSavedAddressItem(addr)),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// --- Add Location Modal (Refactored to use DraggableScrollableSheet for better interaction) ---
class _AddLocationModal extends StatefulWidget {
  final Position? initialPosition;
  final String? initialAddress;
  final bool isForOrder;

  const _AddLocationModal({
    this.initialPosition,
    this.initialAddress,
    this.isForOrder = false,
  });

  @override
  State<_AddLocationModal> createState() => _AddLocationModalState();
}

class _AddLocationModalState extends State<_AddLocationModal> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  Set<Marker> _markers = {};
  String? _currentAddressDisplay; // Address displayed in the form based on map selection

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isSaving = false;
  bool _isMapLoading = true;

  String? _selectedType = 'other'; // default to 'other'
  String? _selectedLabel = 'Other'; // default label

  // TODO: Replace with your actual Google Places API Key
  final String _googlePlacesApiKey = 'AIzaSyC4T-nrxWDY5Iblq11Sh3n8dn_s4DvBtU8';

  @override
  void initState() {
    super.initState();
    if (widget.initialPosition != null) {
      _selectedLocation = LatLng(widget.initialPosition!.latitude, widget.initialPosition!.longitude);
      _currentAddressDisplay = widget.initialAddress;
      _addressController.text = widget.initialAddress ?? '';
      _updateMapMarkers();
    } else {
      _getCurrentLocation(); // Get current location if no initial position
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _addressController.dispose();
    _labelController.dispose();
    _landmarkController.dispose();
    _floorController.dispose();
    _buildingController.dispose();
    _instructionsController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isMapLoading = true;
    });
    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        final address = await LocationService.getAddressFromCoordinates(position);
        setState(() {
          _selectedLocation = LatLng(position.latitude, position.longitude);
          _currentAddressDisplay = address;
          _addressController.text = address;
          _isMapLoading = false;
        });
        _updateMapMarkers();
        _animateToLocation();
      } else {
        setState(() {
          _isMapLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to get current location.')),
        );
      }
    } catch (e) {
      setState(() {
        _isMapLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: ${e.toString()}')),
      );
    }
  }

  void _updateMapMarkers() {
    if (_selectedLocation != null) {
      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId('selected_location'),
            position: _selectedLocation!,
            infoWindow: InfoWindow(
              title: 'Selected Location',
              snippet: _currentAddressDisplay ?? 'Location selected',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            draggable: true,
            onDragEnd: (newPosition) {
              setState(() {
                _selectedLocation = newPosition;
              });
              _reverseGeocode(newPosition);
            },
          ),
        };
      });
    }
  }

  void _animateToLocation() {
    if (_mapController != null && _selectedLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedLocation!, 16),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() => _isMapLoading = false);
    if (_selectedLocation != null) {
      _animateToLocation();
    }
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    _updateMapMarkers();
    _reverseGeocode(location);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Location selected!'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // --- REAL LOCATION SEARCH IMPLEMENTATION (Google Places Autocomplete) ---
  Future<void> _searchLocations(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_googlePlacesApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          List<Map<String, dynamic>> fetchedResults = [];
          for (var prediction in data['predictions']) {
            fetchedResults.add({
              'name': prediction['structured_formatting']['main_text'],
              'address': prediction['description'],
              'place_id': prediction['place_id'], // Store place_id for details lookup
            });
          }
          setState(() {
            _searchResults = fetchedResults;
          });
        } else {
          print('Places API Error: ${data['status']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Places API Error: ${data['status']}')),
          );
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error searching locations: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching locations: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  // --- Google Places Details API to get Lat/Lng from place_id ---
  Future<Map<String, dynamic>?> _getPlaceDetails(String placeId) async {
    final String url = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_googlePlacesApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final result = data['result'];
          final geometry = result['geometry'];
          final location = geometry['location'];
          return {
            'address': result['formatted_address'],
            'latitude': location['lat'],
            'longitude': location['lng'],
          };
        } else {
          print('Place Details API Error: ${data['status']}');
          return null;
        }
      } else {
        print('HTTP Error for Place Details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching place details: $e');
      return null;
    }
  }

  // --- Reverse Geocoding Method ---
  Future<void> _reverseGeocode(LatLng location) async {
    try {
      final position = Position(
        latitude: location.latitude,
        longitude: location.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      final address = await LocationService.getAddressFromCoordinates(position);
      setState(() {
        _currentAddressDisplay = address;
        _addressController.text = address;
      });
    } catch (e) {
      print('Error reverse geocoding: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not get address for selected location.')),
      );
    }
  }

  void _useForOrder() {
    if (_selectedLocation == null || _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location and enter an address')),
      );
      return;
    }

    // Return the selected location for order
    Navigator.pop(context, {
      'address': _addressController.text.trim(),
      'position': Position(
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      ),
      'addressData': {
        'address': _addressController.text.trim(),
        'landmark': _landmarkController.text.trim(),
        'coordinates': {
          'latitude': _selectedLocation!.latitude,
          'longitude': _selectedLocation!.longitude,
        },
        'type': _selectedType,
        'label': _selectedType == 'other' ? _labelController.text.trim() : _selectedLabel!,
        'floor': _floorController.text.trim(),
        'building': _buildingController.text.trim(),
        'instructions': _instructionsController.text.trim(),
      },
    });
  }

  Future<void> _saveAddress() async {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location on the map')),
      );
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an address')),
      );
      return;
    }

    if (_selectedType == 'other' && _labelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a label for this address')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.jwtToken == null) {
        throw Exception('User not authenticated');
      }

      // Parse address components (simplified for example)
      final addressParts = _addressController.text.split(',');
      final city = addressParts.length > 1 ? addressParts[addressParts.length - 2].trim() : '';
      final state = addressParts.length > 2 ? addressParts[addressParts.length - 3].trim() : '';
      final zip = '44600'; // Default zip code for Nepal or derive from location

      final addressData = {
        'label': _selectedType == 'other' ? _labelController.text.trim() : _selectedLabel!,
        'address': _addressController.text.trim(),
        'landmark': _landmarkController.text.trim(),
        'city': city,
        'state': state,
        'zip': zip,
        'country': 'Nepal',
        'coordinates': {
          'latitude': _selectedLocation!.latitude,
          'longitude': _selectedLocation!.longitude,
        },
        'type': _selectedType,
        'floor': _floorController.text.trim(),
        'building': _buildingController.text.trim(),
        'instructions': _instructionsController.text.trim(),
        // 'isDefault': _savedAddresses.isEmpty, // This logic should be handled by the backend or a separate default setting
      };

      final response = await ApiService.post(
        '/addresses',
        token: authProvider.jwtToken,
        body: addressData,
      );

      // Indicate success to the previous screen (LocationScreen)
      Navigator.pop(context, {'addressSaved': true});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Address saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving address: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // --- UI Builder for Address Type Chips ---
  Widget _buildTypeChip(String type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedType = type;
            _selectedLabel = label;
          });
        }
      },
      avatar: Icon(icon, color: isSelected ? Colors.white : Colors.grey[600]),
      selectedColor: Colors.orange,
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Colors.orange : Colors.grey[300]!,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Location',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Google Map (takes full available space)
          _selectedLocation != null
              ? GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation!,
                    zoom: 16,
                  ),
                  markers: _markers,
                  onTap: _onMapTap,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false, // Will use custom button
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: false,
                  compassEnabled: true,
                  rotateGesturesEnabled: true,
                  scrollGesturesEnabled: true, // Ensure map dragging is enabled
                  zoomGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                )
              : Center(child: _isMapLoading ? const CircularProgressIndicator() : const Text('Loading map...')),

          // Search Bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for area, street name, landmark...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: _getCurrentLocation,
                    tooltip: 'Use current location',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none, // No border for a cleaner look
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: _searchLocations,
              ),
            ),
          ),

          // Search Results Overlay
          if (_isSearching || _searchResults.isNotEmpty)
            Positioned(
              top: 80, // Below search bar
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: _isSearching
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text('Searching...'),
                            ],
                          ),
                        ),
                      )
                    : _searchResults.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: _searchResults.length,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              final result = _searchResults[index];
                              return ListTile(
                                leading: const Icon(Icons.location_on, color: Colors.blue),
                                title: Text(result['name']),
                                subtitle: Text(result['address']),
                                onTap: () async { // Made onTap async to fetch place details
                                  // Fetch place details to get precise lat/lng
                                  final placeDetails = await _getPlaceDetails(result['place_id']);
                                  if (placeDetails != null) {
                                    setState(() {
                                      _selectedLocation = LatLng(placeDetails['latitude'], placeDetails['longitude']);
                                      _currentAddressDisplay = placeDetails['address'];
                                      _addressController.text = placeDetails['address'];
                                      _searchResults = []; // Clear search results
                                    });
                                    _updateMapMarkers();
                                    _animateToLocation();
                                    FocusScope.of(context).unfocus(); // Dismiss keyboard
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Failed to get details for selected place.')),
                                    );
                                  }
                                },
                              );
                            },
                          )
                        : Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'No results found for "${_searchController.text}"',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
              ),
            ),

          // Draggable Scrollable Sheet for Address Details
          DraggableScrollableSheet(
            initialChildSize: 0.3, // Initial height of the sheet
            minChildSize: 0.1,    // Minimum height when dragged down
            maxChildSize: 0.8,    // Maximum height when dragged up
            expand: true,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Current Selected Address Display
                      if (_selectedLocation != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.blue, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _currentAddressDisplay ?? 'Location not selected',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            'Tap on the map or search to select a location.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),

                      // Address Type Selection
                      const Text(
                        'Address Type',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: [
                          _buildTypeChip('home', 'Home', Icons.home_outlined),
                          _buildTypeChip('work', 'Work', Icons.work_outline),
                          _buildTypeChip('other', 'Other', Icons.location_on_outlined),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Label Field
                      if (_selectedType == 'other')
                        TextField(
                          controller: _labelController,
                          decoration: InputDecoration(
                            labelText: 'Label',
                            hintText: 'e.g., Gym, School, Friend\'s House',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.label_outline),
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),

                      if (_selectedType == 'other') const SizedBox(height: 16),

                      // Address Field
                      TextField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Full Address',
                          hintText: 'Street name, locality, city...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.location_on_outlined),
                        ),
                        maxLines: 3,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                      ),

                      const SizedBox(height: 16),

                      // Landmark Field
                      TextField(
                        controller: _landmarkController,
                        decoration: InputDecoration(
                          labelText: 'Landmark (Optional)',
                          hintText: 'e.g., Near Big Bazaar, Opposite Park',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.place_outlined),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),

                      const SizedBox(height: 16),

                      // Floor and Building Fields
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _floorController,
                              decoration: InputDecoration(
                                labelText: 'Floor (Optional)',
                                hintText: 'e.g., 3rd Floor, Basement',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.layers_outlined),
                              ),
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _buildingController,
                              decoration: InputDecoration(
                                labelText: 'Building (Optional)',
                                hintText: 'e.g., Alpha Tower, Main Building',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.business_outlined),
                              ),
                              textCapitalization: TextCapitalization.words,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Delivery Instructions
                      TextField(
                        controller: _instructionsController,
                        decoration: InputDecoration(
                          labelText: 'Delivery Instructions (Optional)',
                          hintText: 'e.g., Ring bell twice, Leave at reception',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.note_outlined),
                        ),
                        maxLines: 2,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                      ),

                      const SizedBox(height: 24),

                      // Action Buttons
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedLocation == null || _isSaving ? null : _saveAddress,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  widget.isForOrder ? 'Confirm Location for Order' : 'Save Address',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:tuukatuu/providers/location_provider.dart';

// class LocationScreen extends StatefulWidget {
//   const LocationScreen({Key? key}) : super(key: key);

//   @override
//   State<LocationScreen> createState() => _LocationScreenState();
// }

// class _LocationScreenState extends State<LocationScreen> {
//   final TextEditingController _labelController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   int? editingIndex;

//   void _showAddAddressDialog(LocationProvider provider, {bool isEdit = false}) {
//     // Pre-fill controllers if editing
//     if (isEdit && editingIndex != null) {
//       final existing = provider.savedAddresses[editingIndex!];
//       _labelController.text = existing['label'];
//       _addressController.text = existing['address'];
//     }

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(isEdit ? "Edit Address" : "Add New Address"),
//           content: SingleChildScrollView(
//             child: Column(
//               children: [
//                 TextField(
//                   controller: _labelController,
//                   decoration: const InputDecoration(labelText: "Label (e.g., Home, Work)"),
//                   autofocus: true,
//                 ),
//                 TextField(
//                   controller: _addressController,
//                   decoration: const InputDecoration(labelText: "Full Address"),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 _labelController.clear();
//                 _addressController.clear();
//                 Navigator.pop(context);
//               },
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (_labelController.text.isNotEmpty &&
//                     _addressController.text.isNotEmpty &&
//                     provider.selectedPosition != null) {
//                   if (isEdit && editingIndex != null) {
//                     provider.editAddress(editingIndex!, _labelController.text,
//                         _addressController.text, provider.selectedPosition!);
//                   } else {
//                     provider.addAddress(_labelController.text,
//                         _addressController.text, provider.selectedPosition!);
//                   }
//                   _labelController.clear();
//                   _addressController.clear();
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text(isEdit ? "Address Updated" : "Address Saved")),
//                   );
//                   Navigator.pop(context);
//                 }
//               },
//               child: Text(isEdit ? "Update" : "Save"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final locationProvider = Provider.of<LocationProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Select Delivery Location"),
//         actions: [
//           IconButton(icon: const Icon(Icons.help_outline), onPressed: () {})
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Stack(
//               children: [
//                 GoogleMap(
//                   initialCameraPosition: locationProvider.initialPosition,
//                   myLocationEnabled: true,
//                   onMapCreated: locationProvider.onMapCreated,
//                   onCameraMove: locationProvider.updateMapPosition,
//                 ),
//                 const Center(
//                   child: Icon(Icons.location_pin, size: 40, color: Colors.red),
//                 ),
//                 Positioned(
//                   top: 16,
//                   left: 16,
//                   right: 16,
//                   child: Material(
//                     elevation: 8,
//                     borderRadius: BorderRadius.circular(12),
//                     child: TextField(
//                       decoration: InputDecoration(
//                         hintText: "Enter Area, Locality or Landmark",
//                         prefixIcon: const Icon(Icons.search),
//                         contentPadding:
//                             const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide.none,
//                         ),
//                         filled: true,
//                         fillColor: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 220,
//                   right: 16,
//                   child: FloatingActionButton.extended(
//                     onPressed: locationProvider.useCurrentLocation,
//                     icon: const Icon(Icons.my_location),
//                     label: const Text("Use Current Location"),
//                   ),
//                 )
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("Saved Addresses",
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                 TextButton(
//                   onPressed: () => _showAddAddressDialog(locationProvider),
//                   child: const Text("+ Add"),
//                 )
//               ],
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: locationProvider.savedAddresses.length,
//               itemBuilder: (context, index) {
//                 final address = locationProvider.savedAddresses[index];
//                 return Card(
//                   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                   child: ListTile(
//                     leading: Icon(address['label'] == "Home"
//                         ? Icons.home
//                         : Icons.work),
//                     title: Text(address['label']),
//                     subtitle: Text(
//                         '${address['address']}\nLat: ${address['latitude'].toStringAsFixed(4)}, Lng: ${address['longitude'].toStringAsFixed(4)}'),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.edit),
//                           onPressed: () {
//                             editingIndex = index;
//                             _showAddAddressDialog(locationProvider, isEdit: true);
//                           },
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.delete),
//                           onPressed: () {
//                             locationProvider.removeAddress(index);
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text("Address Deleted")),
//                             );
//                           },
//                         )
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: ElevatedButton(
//               onPressed: locationProvider.selectedPosition != null
//                   ? () {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text("Location confirmed!")),
//                       );
//                     }
//                   : null,
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size.fromHeight(50),
//                 backgroundColor: locationProvider.selectedPosition != null
//                     ? Colors.deepPurple
//                     : Colors.grey,
//               ),
//               child: Text(
//                 locationProvider.selectedPosition != null
//                     ? "Deliver to: ${locationProvider.selectedPosition!.latitude.toStringAsFixed(4)}, ${locationProvider.selectedPosition!.longitude.toStringAsFixed(4)}"
//                     : "Select a Location",
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }