import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:baato_maps/baato_maps.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tuukatuu/providers/address_provider.dart';
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
  String? _error, _currentAddress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlaceCoordinates();
  }

  Future<void> _fetchPlaceCoordinates() async {
    final placeId = widget.place.placeId;
    if (placeId == null) {
      _setError('Place ID missing');
      return;
    }

    final url =
        'https://api.baato.io/api/v1/places?key=$_baatoAccessToken&placeId=$placeId';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (response.statusCode == 200 &&
          data['status'] == 200 &&
          data['data'].isNotEmpty) {
        final centroid = data['data'][0]['centroid'];
        _latitude = centroid['lat']?.toDouble();
        _longitude = centroid['lon']?.toDouble();

        if (_latitude != null && _longitude != null) {
          _addMarkerAndAddress(
            BaatoCoordinate(latitude: _latitude!, longitude: _longitude!),
            widget.place.name ?? 'Selected',
          );
          _clearLoading();
          return;
        }
        _setError("Centroid missing.");
      } else {
        _setError(data['message'] ?? 'Invalid response');
      }
    } catch (e) {
      _setError('Error: $e');
    }
  }

  void _onMapCreated(BaatoMapController controller) {
    _mapController = controller;
    if (_latitude != null && _longitude != null) {
      _addMarkerAndAddress(
          BaatoCoordinate(latitude: _latitude!, longitude: _longitude!),
          widget.place.name ?? "Selected");
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
    await _mapController?.markerManager.clearMarkers();
    await _mapController?.markerManager.addMarker(
      BaatoSymbolOption(
        geometry: coord,
        textField: label,
        iconImage: "baato_marker",
        iconSize: 1.5,
      ),
    );
    _fetchAddress(coord.latitude, coord.longitude);
  }

  Future<void> _fetchAddress(double lat, double lon) async {
    final url =
        'https://api.baato.io/api/v1/reverse?key=$_baatoAccessToken&lat=$lat&lon=$lon';
    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      String? address;
      if (data['data'] is List && data['data'].isNotEmpty) {
        address = data['data'][0]['address'];
      } else if (data['data'] is Map) {
        address = data['data']['address'];
      }

      setState(() {
        _currentAddress =
            [widget.place.name, address].whereType<String>().join('\n');
      });
    } catch (e) {
      setState(() {
        _currentAddress = "Error fetching address: $e";
      });
    }
  }

  Future<void> _saveLocationToBackend({
    required String label,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      
      final addressData = {
        "label": label,
        "address": address,
        "coordinates": {
          "latitude": latitude,
          "longitude": longitude,
        },
        "type": "other",
        "instructions": "",
        "isDefault": false,
      };

      final newAddress = await addressProvider.createAddress(addressData);

      if (!mounted) return;

      if (newAddress != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Location saved successfully."),
            backgroundColor: Colors.green,
          ),
        );
        
        // Return the address to the previous screen
        Navigator.pop(context, {
          'address': address,
          'label': label,
          'saved': true,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Error saving location: ${addressProvider.error}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Error saving location: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showSaveBottomSheet() async {
    if (_latitude == null || _longitude == null || _currentAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Coordinates or address unavailable."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final label = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final controller = TextEditingController();
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Save Location",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  _currentAddress!,
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: "Label (e.g., Home, Work)",
                    prefixIcon: Icon(Icons.label),
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
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
                      ),
                      child: const Text("Save"),
                      onPressed: () {
                        final label = controller.text.trim();
                        if (label.isNotEmpty) {
                          Navigator.pop(ctx, label);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (label != null && label.isNotEmpty) {
      await _saveLocationToBackend(
        label: label,
        address: _currentAddress!,
        latitude: _latitude!,
        longitude: _longitude!,
      );
    }
  }

  Widget _buildAttribution() => Align(
        alignment: Alignment.bottomRight,
        child: InkWell(
          onTap: () =>
              launchUrlString("https://www.openstreetmap.org/copyright"),
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
      return const Scaffold(
        body: Center(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(
                "❌ $_error",
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _fetchPlaceCoordinates();
                },
                child: const Text("Retry"),
              ),
            ],
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
      ),
      body: Stack(
        children: [
          BaatoMap(
            style: BaatoMapStyle.breeze,
            initialZoom: 16,
            initialPosition:
                BaatoCoordinate(latitude: _latitude!, longitude: _longitude!),
            onMapCreated: _onMapCreated,
            onTap: (point, coord, feature) {
              _addMarkerAndAddress(coord, "Custom Location");
            },
            logoViewMargins: const Point(-50, -50),
          ),
          _buildAttribution(),
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
                                onPressed: _showSaveBottomSheet,
                                icon: const Icon(Icons.save),
                                label: const Text("Save Location"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6B35),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context, {
                                    'address': _currentAddress!,
                                    'label': 'Selected Location',
                                    'saved': false,
                                  });
                                },
                                icon: const Icon(Icons.check),
                                label: const Text("Use This"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
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
