// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:uuid/uuid.dart';
// import 'package:http/http.dart' as http;
// import '../../models/address.dart';
// import '../../providers/location_provider.dart';
// import '../../services/api_service.dart';
// import '../../providers/auth_provider.dart';

// class LocationScreen extends StatefulWidget {
//   const LocationScreen({super.key});

//   @override
//   State<LocationScreen> createState() => _LocationScreenState();
// }

// class _LocationScreenState extends State<LocationScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final PlacesService _placesService = PlacesService(
//     apiKey: 'AIzaSyC4T-nrxWDY5Iblq11Sh3n8dn_s4DvBtU8', // Replace with your actual Google API key
//   );
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final locationProvider = Provider.of<LocationProvider>(context, listen: false);
//       final token = Provider.of<AuthProvider>(context, listen: false).jwtToken;
//       if (token != null) {
//         await locationProvider.fetchAddresses(token);
//       }
//     });
//   }

//   Future<void> _useCurrentLocation() async {
//     setState(() => _isLoading = true);
//     try {
//       Position position = await Geolocator.getCurrentPosition();
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         position.latitude,
//         position.longitude,
//       );
//       String locationName = placemarks.first.name ?? "Current Location";
//       if (mounted) {
//         HapticFeedback.lightImpact();
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => MapPickerScreen(
//               initialLat: position.latitude,
//               initialLng: position.longitude,
//               locationName: locationName,
//               onSave: _onSaveAddress,
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error getting location: $e'),
//           backgroundColor: Theme.of(context).colorScheme.error,
//         ),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _onSaveAddress(Address address) async {
//     final locationProvider = Provider.of<LocationProvider>(context, listen: false);
//     final token = Provider.of<AuthProvider>(context, listen: false).jwtToken;
//     if (token != null) {
//       try {
//         // await locationProvider.addAddress(token, address);
//         if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to save address: $e'), backgroundColor: Theme.of(context).colorScheme.error),
//           );
//         }
//       }
//     }
//   }

//   Future<void> _onDeleteAddress(String id) async {
//     final locationProvider = Provider.of<LocationProvider>(context, listen: false);
//     final token = Provider.of<AuthProvider>(context, listen: false).jwtToken;
//     if (token != null) {
//       try {
//         await locationProvider.deleteAddress(token, id);
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to delete address: $e'), backgroundColor: Theme.of(context).colorScheme.error),
//           );
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text("Add New Address", style: theme.textTheme.headlineMedium),
//           centerTitle: true,
//           elevation: 2,
//           backgroundColor: theme.colorScheme.surface,
//         ),
//         body: Consumer<LocationProvider>(
//           builder: (context, locationProvider, _) {
//             return Stack(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       TypeAheadField<Map<String, dynamic>>(
//                         suggestionsCallback: (pattern) async {
//                           if (pattern.isEmpty) return [];
//                           setState(() => _isLoading = true);
//                           try {
//                             return await _placesService.getAutocomplete(pattern);
//                           } finally {
//                             setState(() => _isLoading = false);
//                           }
//                         },
//                         itemBuilder: (context, suggestion) {
//                           return ListTile(
//                             title: Text(suggestion['description'], style: theme.textTheme.bodyLarge),
//                             dense: true,
//                           );
//                         },
//                         onSelected: (suggestion) async {
//                           final placeId = suggestion['place_id'];
//                           setState(() => _isLoading = true);
//                           try {
//                             final location = await _placesService.getPlaceDetail(placeId);
//                             if (location != null && mounted) {
//                               HapticFeedback.selectionClick();
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => MapPickerScreen(
//                                     initialLat: location.latitude,
//                                     initialLng: location.longitude,
//                                     locationName: suggestion['description'],
//                                     onSave: _onSaveAddress,
//                                   ),
//                                 ),
//                               );
//                             }
//                           } catch (e) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text('Error fetching place details: $e'),
//                                 backgroundColor: theme.colorScheme.error,
//                               ),
//                             );
//                           } finally {
//                             setState(() => _isLoading = false);
//                           }
//                         },
//                         builder: (context, controller, focusNode) {
//                           return TextField(
//                             controller: controller,
//                             focusNode: focusNode,
//                             decoration: InputDecoration(
//                               hintText: "Search for a location",
//                               prefixIcon: const Icon(Icons.search),
//                               suffixIcon: controller.text.isNotEmpty
//                                   ? IconButton(
//                                       icon: const Icon(Icons.clear),
//                                       onPressed: () {
//                                         controller.clear();
//                                         setState(() {});
//                                       },
//                                     )
//                                   : null,
//                               border: const OutlineInputBorder(),
//                               filled: true,
//                               fillColor: theme.colorScheme.surface,
//                             ),
//                           );
//                         },
//                         loadingBuilder: (context) => const Padding(
//                           padding: EdgeInsets.all(16),
//                           child: Center(child: CircularProgressIndicator()),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton.icon(
//                         onPressed: _isLoading ? null : _useCurrentLocation,
//                         icon: _isLoading
//                             ? const SizedBox(
//                                 width: 24,
//                                 height: 24,
//                                 child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//                               )
//                             : const Icon(Icons.my_location),
//                         label: const Text("Use Current Location"),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: theme.colorScheme.secondary,
//                           foregroundColor: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       Text(
//                         "Saved Addresses",
//                         style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.primary),
//                       ),
//                       const SizedBox(height: 8),
//                       Expanded(
//                         child: locationProvider.isLoading
//                             ? const Center(child: CircularProgressIndicator())
//                             : locationProvider.addresses.isEmpty
//                                 ? Center(
//                                     child: Text(
//                                       "No saved addresses yet.\nSearch or use current location to add one.",
//                                       textAlign: TextAlign.center,
//                                       style: theme.textTheme.bodyLarge,
//                                     ),
//                                   )
//                                 : ListView.builder(
//                                     itemCount: locationProvider.addresses.length,
//                                     itemBuilder: (context, index) {
//                                       final address = locationProvider.addresses[index];
//                                       return AddressCard(
//                                         address: address,
//                                         isDefault: address.isDefault ?? false,
//                                         onEdit: () async {
//                                           final updated = await Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (_) => AddressDetailsScreen(
//                                                 coordinates: address.coordinates,
//                                                 address: address.address,
//                                                 onSave: (updatedAddress) async {
//                                                   final locationProvider = Provider.of<LocationProvider>(context, listen: false);
//                                                   final token = Provider.of<AuthProvider>(context, listen: false).jwtToken;
//                                                   if (token != null) {
//                                                     await locationProvider.updateAddress(token, updatedAddress.copyWith(id: address.id));
//                                                     if (context.mounted) Navigator.pop(context, updatedAddress);
//                                                   }
//                                                 },
//                                                 initialLabel: address.label,
//                                                 initialInstructions: address.instructions,
//                                                 initialLandmark: address.landmark,
//                                                 initialCity: address.city,
//                                               ),
//                                             ),
//                                           );
//                                           // Optionally show a snackbar or refresh
//                                         },
//                                         onDelete: () => _onDeleteAddress(address.id!),
//                                       );
//                                     },
//                                   ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (locationProvider.isLoading)
//                   Container(
//                     color: Colors.black.withOpacity(0.2),
//                     child: const Center(child: CircularProgressIndicator()),
//                   ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class PlacesService {
//   final String apiKey;
//   String sessionToken = const Uuid().v4();

//   PlacesService({required this.apiKey});

//   Future<List<Map<String, dynamic>>> getAutocomplete(String input) async {
//     final String baseUrl = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
//     final request = '$baseUrl?input=$input&key=$apiKey&sessiontoken=$sessionToken&components=country:np';
//     final response = await http.get(Uri.parse(request));
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final List predictions = data['predictions'];
//       return predictions.map((p) => {
//             'description': p['description'],
//             'place_id': p['place_id'],
//           }).toList();
//     } else {
//       throw Exception('Failed to fetch suggestions');
//     }
//   }

//   Future<LatLng?> getPlaceDetail(String placeId) async {
//     final String baseUrl = 'https://maps.googleapis.com/maps/api/place/details/json';
//     final request = '$baseUrl?place_id=$placeId&key=$apiKey';
//     final response = await http.get(Uri.parse(request));
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final location = data['result']['geometry']['location'];
//       return LatLng(location['lat'], location['lng']);
//     } else {
//       throw Exception('Failed to fetch place details');
//     }
//   }
// }

// class MapPickerScreen extends StatefulWidget {
//   final double initialLat;
//   final double initialLng;
//   final String locationName;
//   final Function(Address) onSave;

//   const MapPickerScreen({
//     super.key,
//     required this.initialLat,
//     required this.initialLng,
//     required this.locationName,
//     required this.onSave,
//   });

//   @override
//   State<MapPickerScreen> createState() => _MapPickerScreenState();
// }

// class _MapPickerScreenState extends State<MapPickerScreen> {
//   late LatLng _currentLatLng;
//   String? _pickedAddress;
//   final Set<Marker> _markers = {};

//   @override
//   void initState() {
//     super.initState();
//     _currentLatLng = LatLng(widget.initialLat, widget.initialLng);
//     _updateMarker();
//     _getAddress();
//   }

//   Future<void> _getAddress() async {
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         _currentLatLng.latitude,
//         _currentLatLng.longitude,
//       );
//       setState(() {
//         _pickedAddress = placemarks.first.name ?? widget.locationName;
//         _updateMarker();
//       });
//     } catch (e) {
//       setState(() {
//         _pickedAddress = widget.locationName;
//         _updateMarker();
//       });
//     }
//   }

//   void _updateMarker() {
//     setState(() {
//       _markers.clear();
//       _markers.add(
//         Marker(
//           markerId: const MarkerId('picked_location'),
//           position: _currentLatLng,
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
//         ),
//       );
//     });
//   }

//   void _onCameraMove(CameraPosition position) {
//     _currentLatLng = position.target;
//     _updateMarker();
//   }

//   void _onCameraIdle() {
//     _getAddress();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text("Pick Location", style: theme.textTheme.headlineMedium),
//           centerTitle: true,
//           elevation: 2,
//           backgroundColor: theme.colorScheme.surface,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//         ),
//         body: Stack(
//           children: [
//             GoogleMap(
//               initialCameraPosition: CameraPosition(
//                 target: _currentLatLng,
//                 zoom: 15,
//               ),
//               markers: _markers,
//               onCameraMove: _onCameraMove,
//               onCameraIdle: _onCameraIdle,
//               myLocationEnabled: true,
//               myLocationButtonEnabled: true,
//             ),
//             Positioned(
//               top: 16,
//               left: 16,
//               right: 16,
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.9),
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Text(
//                   'Drag the map to adjust the pin location.\nAddress: ${_pickedAddress ?? ''}',
//                   style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: 30,
//               left: 20,
//               right: 20,
//               child: ElevatedButton(
//                 onPressed: _pickedAddress != null
//                     ? () {
//                         HapticFeedback.lightImpact();
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => AddressDetailsScreen(
//                               coordinates: _currentLatLng,
//                               address: _pickedAddress!,
//                               onSave: widget.onSave,
//                             ),
//                           ),
//                         );
//                       }
//                     : null,
//                 child: const Text("Confirm & Continue"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class AddressCard extends StatelessWidget {
//   final Address address;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;
//   final bool isDefault;

//   const AddressCard({
//     super.key,
//     required this.address,
//     required this.onEdit,
//     required this.onDelete,
//     this.isDefault = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Icon(Icons.location_on, color: theme.colorScheme.primary, size: 32),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text(
//                         address.label,
//                         style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
//                       ),
//                       if (isDefault)
//                         Container(
//                           margin: const EdgeInsets.only(left: 8),
//                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: theme.colorScheme.primary.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Text('Default', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary)),
//                         ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     address.fullAddress ?? address.address,
//                     style: theme.textTheme.bodyMedium,
//                   ),
//                   if (address.landmark != null && address.landmark!.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 2),
//                       child: Row(
//                         children: [
//                           Icon(Icons.flag, size: 16, color: theme.colorScheme.secondary),
//                           const SizedBox(width: 4),
//                           Flexible(
//                             child: Text(
//                               address.landmark!,
//                               style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   if (address.city != null && address.city!.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 2),
//                       child: Row(
//                         children: [
//                           Icon(Icons.location_city, size: 16, color: theme.colorScheme.secondary),
//                           const SizedBox(width: 4),
//                           Flexible(
//                             child: Text(
//                               address.city!,
//                               style: theme.textTheme.bodySmall,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   if (address.instructions != null && address.instructions!.trim().isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 4),
//                       child: Row(
//                         children: [
//                           Icon(Icons.info_outline, size: 16, color: theme.colorScheme.tertiary),
//                           const SizedBox(width: 4),
//                           Flexible(
//                             child: Text(
//                               address.instructions!,
//                               style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             Column(
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.edit, color: theme.colorScheme.primary),
//                   tooltip: 'Edit',
//                   onPressed: onEdit,
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.delete, color: theme.colorScheme.error),
//                   tooltip: 'Delete',
//                   onPressed: onDelete,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class AddressDetailsScreen extends StatefulWidget {
//   final LatLng coordinates;
//   final String address;
//   final Function(Address) onSave;
//   final String? initialLabel;
//   final String? initialInstructions;
//   final String? initialLandmark;
//   final String? initialCity;
//   final String? initialState;
//   final String? initialCountry;

//   const AddressDetailsScreen({
//     super.key,
//     required this.coordinates,
//     required this.address,
//     required this.onSave,
//     this.initialLabel,
//     this.initialInstructions,
//     this.initialLandmark,
//     this.initialCity,
//     this.initialState,
//     this.initialCountry,
//   });

//   @override
//   State<AddressDetailsScreen> createState() => _AddressDetailsScreenState();
// }

// class _AddressDetailsScreenState extends State<AddressDetailsScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _labelController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _landmarkController = TextEditingController();
//   final _cityController = TextEditingController();
//   final _stateController = TextEditingController();
//   final _instructionsController = TextEditingController();
//   final List<String> _countries = ['Nepal', 'India', 'USA', 'UK', 'Australia', 'Other'];
//   String _selectedCountry = 'Nepal';

//   @override
//   void initState() {
//     super.initState();
//     _addressController.text = widget.address;
//     _labelController.text = widget.initialLabel ?? '';
//     _landmarkController.text = widget.initialLandmark ?? '';
//     _cityController.text = widget.initialCity ?? '';
//     _stateController.text = widget.initialState ?? '';
//     _instructionsController.text = widget.initialInstructions ?? '';
//     _selectedCountry = widget.initialCountry ?? 'Nepal';
//   }

//   void _save() async {
//     if (_formKey.currentState!.validate()) {
//       // Optionally, call a geocoding API to validate city/state/country
//       // If invalid, show error and return
//       final label = _labelController.text.trim();
//       final fullAddress = _addressController.text.trim();
//       final landmark = _landmarkController.text.trim();
//       final city = _cityController.text.trim();
//       final state = _stateController.text.trim();
//       final country = _selectedCountry;
//       final instructions = _instructionsController.text.trim();
//       final lat = widget.coordinates.latitude;
//       final lng = widget.coordinates.longitude;

//       final address = Address(
//         label: label,
//         address: fullAddress,
//         landmark: landmark,
//         city: city,
//         state: state,
//         country: country,
//         coordinates: LatLng(lat, lng),
//         instructions: instructions,
//       );
//       widget.onSave(address);
//       HapticFeedback.lightImpact();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text("Address Details", style: theme.textTheme.headlineMedium),
//           centerTitle: true,
//           elevation: 2,
//           backgroundColor: theme.colorScheme.surface,
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text('Cancel', style: TextStyle(color: theme.colorScheme.secondary)),
//             ),
//           ],
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Form(
//             key: _formKey,
//             child: ListView(
//               children: [
//                 TextFormField(
//                   controller: _labelController,
//                   decoration: InputDecoration(
//                     labelText: "Label",
//                     hintText: "E.g., Home, Office",
//                     helperText: "A short name for this address",
//                     border: const OutlineInputBorder(),
//                     filled: true,
//                     fillColor: theme.colorScheme.surface,
//                   ),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Label is required';
//                     }
//                     return null;
//                   },
//                   textInputAction: TextInputAction.next,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _addressController,
//                   maxLines: 3,
//                   decoration: InputDecoration(
//                     labelText: "Full Address",
//                     hintText: "Add apartment, floor, landmarks, etc.",
//                     helperText: "Include details for accurate delivery",
//                     border: const OutlineInputBorder(),
//                     filled: true,
//                     fillColor: theme.colorScheme.surface,
//                   ),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Full address is required';
//                     }
//                     return null;
//                   },
//                   textInputAction: TextInputAction.next,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _landmarkController,
//                   decoration: InputDecoration(
//                     labelText: "Landmark",
//                     hintText: "Nearby landmark for easier identification",
//                     border: const OutlineInputBorder(),
//                     filled: true,
//                     fillColor: theme.colorScheme.surface,
//                   ),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Landmark is required';
//                     }
//                     return null;
//                   },
//                   textInputAction: TextInputAction.next,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _cityController,
//                   decoration: InputDecoration(
//                     labelText: "City",
//                     hintText: "Enter city",
//                     border: const OutlineInputBorder(),
//                     filled: true,
//                     fillColor: theme.colorScheme.surface,
//                   ),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'City is required';
//                     }
//                     return null;
//                   },
//                   textInputAction: TextInputAction.next,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _stateController,
//                   decoration: InputDecoration(
//                     labelText: "State",
//                     hintText: "Enter state",
//                     border: const OutlineInputBorder(),
//                     filled: true,
//                     fillColor: theme.colorScheme.surface,
//                   ),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'State is required';
//                     }
//                     return null;
//                   },
//                   textInputAction: TextInputAction.next,
//                 ),
//                 const SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   value: _selectedCountry,
//                   decoration: InputDecoration(
//                     labelText: "Country",
//                     border: const OutlineInputBorder(),
//                     filled: true,
//                     fillColor: theme.colorScheme.surface,
//                   ),
//                   items: _countries.map((country) => DropdownMenuItem(
//                     value: country,
//                     child: Text(country),
//                   )).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedCountry = value!;
//                     });
//                   },
//                   validator: (value) => value == null || value.isEmpty ? 'Country is required' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _instructionsController,
//                   maxLines: 3,
//                   maxLength: 100,
//                   decoration: InputDecoration(
//                     labelText: "Special Instructions (Optional)",
//                     hintText: "E.g., Ring the bell twice",
//                     helperText: "Additional notes for delivery",
//                     border: const OutlineInputBorder(),
//                     filled: true,
//                     fillColor: theme.colorScheme.surface,
//                   ),
//                   textInputAction: TextInputAction.done,
//                 ),
//                 const SizedBox(height: 24),
//                 ElevatedButton.icon(
//                   onPressed: _save,
//                   icon: const Icon(Icons.save),
//                   label: const Text("Save Address"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
