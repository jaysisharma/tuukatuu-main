
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
// import '../../../providers/auth_provider.dart';
// import '../../../services/api_service.dart';
// import '../../widgets/cached_image.dart';

// class OrderTrackingScreen extends StatefulWidget {
//   final String orderId;
//   final Map<String, dynamic>? initialOrder;

//   const OrderTrackingScreen({
//     Key? key,
//     required this.orderId,
//     this.initialOrder,
//   }) : super(key: key);

//   @override
//   State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
// }

// class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
//   GoogleMapController? _mapController;
//   Set<Marker> _markers = {};
//   Set<Polyline> _polylines = {};
//   List<LatLng> _polylineCoordinates = [];

//   Map<String, dynamic>? _order;
//   bool _loading = true;
//   String? _error;
//   Timer? _locationTimer;
//   Timer? _orderTimer;
//   Position? _userLocation;

//   // Status tracking
//   final Map<String, String> _statusLabels = {
//     'pending': 'Order Placed',
//     'accepted': 'Order Accepted',
//     'preparing': 'Preparing Your Order',
//     'ready_for_pickup': 'Ready for Pickup',
//     'picked_up': 'Picked Up',
//     'on_the_way': 'On the Way',
//     'delivered': 'Delivered',
//     'cancelled': 'Cancelled',
//     'rejected': 'Rejected',
//   };

//   final Map<String, IconData> _statusIcons = {
//     'pending': Icons.schedule,
//     'accepted': Icons.check_circle_outline,
//     'preparing': Icons.restaurant,
//     'ready_for_pickup': Icons.store,
//     'picked_up': Icons.local_shipping,
//     'on_the_way': Icons.directions_bike,
//     'delivered': Icons.done_all,
//     'cancelled': Icons.cancel,
//     'rejected': Icons.block,
//   };

//   final Map<String, Color> _statusColors = {
//     'pending': Colors.orange,
//     'accepted': Colors.blue,
//     'preparing': Colors.amber,
//     'ready_for_pickup': Colors.purple,
//     'picked_up': Colors.indigo,
//     'on_the_way': Colors.green,
//     'delivered': Colors.teal,
//     'cancelled': Colors.red,
//     'rejected': Colors.red,
//   };

//   @override
//   void initState() {
//     super.initState();
//     if (widget.initialOrder != null) {
//       _order = widget.initialOrder;
//       _loading = false;
//     }
//     _initializeTracking();
//   }

//   @override
//   void dispose() {
//     _locationTimer?.cancel();
//     _orderTimer?.cancel();
//     super.dispose();
//   }

//   Future<void> _initializeTracking() async {
//     await _getUserLocation();
//     await _fetchOrderDetails();
//     _startLocationUpdates();
//     _startOrderUpdates();
//   }

//   Future<void> _getUserLocation() async {
//     try {
//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       setState(() {
//         _userLocation = position;
//       });
//     } catch (e) {
//       print('Error getting user location: $e');
//     }
//   }

//   Future<void> _fetchOrderDetails() async {
//     if (_loading) {
//       setState(() {
//         _loading = true;
//         _error = null;
//       });
//     }

//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final order = await ApiService.get('/orders/${widget.orderId}', token: authProvider.jwtToken);
      
//       setState(() {
//         _order = order;
//         _loading = false;
//       });

//       _updateMapMarkers();
//       _fetchRoute();
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//         _loading = false;
//       });
//     }
//   }

//   void _startLocationUpdates() {
//     _locationTimer = Timer.periodic(const Duration(seconds: 10), (_) {
//       _getUserLocation();
//     });
//   }

//   void _startOrderUpdates() {
//     _orderTimer = Timer.periodic(const Duration(seconds: 15), (_) {
//       _fetchOrderDetails();
//     });
//   }

//   void _updateMapMarkers() {
//     if (_order == null) return;

//     _markers.clear();

//     // Customer location marker
//     if (_order!['customerLocation'] != null) {
//       final customerLocation = _order!['customerLocation'];
//       _markers.add(Marker(
//         markerId: const MarkerId('customer'),
//         position: LatLng(customerLocation['latitude'], customerLocation['longitude']),
//         infoWindow: InfoWindow(
//           title: 'Delivery Location',
//           snippet: customerLocation['address'] ?? 'Your address',
//         ),
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//       ));
//     }

//     // Vendor location marker
//     if (_order!['vendorLocation'] != null) {
//       final vendorLocation = _order!['vendorLocation'];
//       _markers.add(Marker(
//         markerId: const MarkerId('vendor'),
//         position: LatLng(vendorLocation['latitude'], vendorLocation['longitude']),
//         infoWindow: InfoWindow(
//           title: 'Restaurant',
//           snippet: _order!['vendorId']?['storeName'] ?? 'Restaurant',
//         ),
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//       ));
//     }

//     // Rider location marker
//     if (_order!['riderLocation'] != null && _order!['riderId'] != null) {
//       final riderLocation = _order!['riderLocation'];
//       _markers.add(Marker(
//         markerId: const MarkerId('rider'),
//         position: LatLng(riderLocation['latitude'], riderLocation['longitude']),
//         infoWindow: InfoWindow(
//           title: 'Your Rider',
//           snippet: _order!['riderId']?['name'] ?? 'Delivery Partner',
//         ),
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//       ));
//     }

//     // User location marker
//     if (_userLocation != null) {
//       _markers.add(Marker(
//         markerId: const MarkerId('user'),
//         position: LatLng(_userLocation!.latitude, _userLocation!.longitude),
//         infoWindow: const InfoWindow(title: 'Your Location'),
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
//       ));
//     }
//   }

//   Future<void> _fetchRoute() async {
//     if (_order == null) return;

//     LatLng? start;
//     LatLng? end;

//     // Determine route based on order status
//     if (_order!['status'] == 'on_the_way' && _order!['riderLocation'] != null) {
//       // Rider to customer
//       start = LatLng(
//         _order!['riderLocation']['latitude'],
//         _order!['riderLocation']['longitude'],
//       );
//       end = LatLng(
//         _order!['customerLocation']['latitude'],
//         _order!['customerLocation']['longitude'],
//       );
//     } else if (_order!['vendorLocation'] != null && _order!['customerLocation'] != null) {
//       // Vendor to customer (estimated route)
//       start = LatLng(
//         _order!['vendorLocation']['latitude'],
//         _order!['vendorLocation']['longitude'],
//       );
//       end = LatLng(
//         _order!['customerLocation']['latitude'],
//         _order!['customerLocation']['longitude'],
//       );
//     }

//     if (start != null && end != null) {
//       await _getRoutePolyline(start, end);
//     }
//   }

//   Future<void> _getRoutePolyline(LatLng start, LatLng end) async {
//     try {
//       PolylinePoints polylinePoints = PolylinePoints();
      
//       PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//         'AIzaSyC4T-nrxWDY5Iblq11Sh3n8dn_s4DvBtU8', // Replace with actual API key
//         PointLatLng(start.latitude, start.longitude),
//         PointLatLng(end.latitude, end.longitude),
//       );

//       if (result.points.isNotEmpty) {
//         _polylineCoordinates = result.points
//             .map((point) => LatLng(point.latitude, point.longitude))
//             .toList();

//         _polylines.clear();
//         _polylines.add(Polyline(
//           polylineId: const PolylineId('route'),
//           points: _polylineCoordinates,
//           color: Colors.blue,
//           width: 5,
//         ));

//         setState(() {});

//         // Fit bounds to show entire route
//         if (_mapController != null && _polylineCoordinates.isNotEmpty) {
//           _mapController!.animateCamera(
//             CameraUpdate.newLatLngBounds(
//               _boundsFromLatLngList(_polylineCoordinates),
//               50,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       print('Error fetching route: $e');
//     }
//   }

//   LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
//     double x0 = list[0].latitude;
//     double x1 = list[0].latitude;
//     double y0 = list[0].longitude;
//     double y1 = list[0].longitude;

//     for (LatLng latLng in list) {
//       if (latLng.latitude > x1) x1 = latLng.latitude;
//       if (latLng.latitude < x0) x0 = latLng.latitude;
//       if (latLng.longitude > y1) y1 = latLng.longitude;
//       if (latLng.longitude < y0) y0 = latLng.longitude;
//     }
//     return LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
//   }

//   void _contactRider() {
//     if (_order?['riderId']?['phone'] != null) {
//       // Launch phone call
//       // You can use url_launcher package here
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Calling ${_order!['riderId']['name']}...')),
//       );
//     }
//   }

//   void _contactVendor() {
//     if (_order?['vendorId']?['phone'] != null) {
//       // Launch phone call
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Calling ${_order!['vendorId']['storeName']}...')),
//       );
//     }
//   }

//   String _formatETA() {
//     if (_order?['estimatedDeliveryTime'] == null) return 'Calculating...';
    
//     final eta = DateTime.parse(_order!['estimatedDeliveryTime']);
//     final now = DateTime.now();
//     final difference = eta.difference(now);
    
//     if (difference.isNegative) return 'Arriving soon';
    
//          final minutes = difference.inMinutes;
//      if (minutes < 60) {
//        return '$minutes min';
//      } else {
//        final hours = minutes ~/ 60;
//        final remainingMinutes = minutes % 60;
//        return '${hours}h ${remainingMinutes}m';
//      }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
    
//     if (_loading) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Order Tracking')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (_error != null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Order Tracking')),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.error_outline, size: 64, color: Colors.red),
//               const SizedBox(height: 16),
//               Text('Error: $_error'),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _fetchOrderDetails,
//                 child: const Text('Retry'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     if (_order == null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Order Tracking')),
//         body: const Center(child: Text('Order not found')),
//       );
//     }

//     final status = _order!['status'] as String;
//     final statusLabel = _statusLabels[status] ?? status;
//     final statusColor = _statusColors[status] ?? Colors.grey;
//     final statusIcon = _statusIcons[status] ?? Icons.info;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Order Tracking'),
//         backgroundColor: statusColor,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _fetchOrderDetails,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Status Header
//           Container(
//             padding: const EdgeInsets.all(16),
//             color: statusColor.withOpacity(0.1),
//             child: Row(
//               children: [
//                 Icon(statusIcon, color: statusColor, size: 32),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         statusLabel,
//                         style: theme.textTheme.titleLarge?.copyWith(
//                           color: statusColor,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       if (_order!['estimatedDeliveryTime'] != null)
//                         Text(
//                           'ETA: ${_formatETA()}',
//                           style: theme.textTheme.bodyMedium?.copyWith(
//                             color: statusColor.withOpacity(0.8),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Map
//           Expanded(
//             flex: 2,
//             child: Container(
//               margin: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.grey.shade300),
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: _userLocation != null
//                     ? GoogleMap(
//                         initialCameraPosition: CameraPosition(
//                           target: LatLng(_userLocation!.latitude, _userLocation!.longitude),
//                           zoom: 14,
//                         ),
//                         markers: _markers,
//                         polylines: _polylines,
//                         myLocationEnabled: true,
//                         myLocationButtonEnabled: true,
//                         zoomControlsEnabled: false,
//                         onMapCreated: (GoogleMapController controller) {
//                           _mapController = controller;
//                         },
//                       )
//                     : const Center(child: CircularProgressIndicator()),
//               ),
//             ),
//           ),

//           // Order Details
//           Expanded(
//             flex: 1,
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Order Details',
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
                  
//                   // Order ID and Items
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Order #${_order!['_id'].toString().substring(0, 8).toUpperCase()}',
//                               style: theme.textTheme.bodyMedium?.copyWith(
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               '${_order!['items'].length} items • ₹${_order!['total']}',
//                               style: theme.textTheme.bodySmall?.copyWith(
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       if (_order!['riderId'] != null)
//                         ElevatedButton.icon(
//                           onPressed: _contactRider,
//                           icon: const Icon(Icons.phone, size: 16),
//                           label: const Text('Call Rider'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                           ),
//                         ),
//                     ],
//                   ),
                  
//                   const SizedBox(height: 16),
                  
//                   // Contact buttons
//                   Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton.icon(
//                           onPressed: _contactVendor,
//                           icon: const Icon(Icons.store, size: 16),
//                           label: const Text('Contact Restaurant'),
//                           style: OutlinedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: OutlinedButton.icon(
//                           onPressed: () {
//                             // Navigate to order details
//                             Navigator.pop(context);
//                           },
//                           icon: const Icon(Icons.receipt, size: 16),
//                           label: const Text('Order Details'),
//                           style: OutlinedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
