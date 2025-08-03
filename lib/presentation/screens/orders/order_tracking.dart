import 'dart:math';
import 'dart:convert';
import 'package:baato_maps/baato_maps.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OrderTracking extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderTracking({super.key, required this.order});

  @override
  State<OrderTracking> createState() => _OrderTrackingState();
}

class _OrderTrackingState extends State<OrderTracking> {
  BaatoMapController? _mapController;
  BaatoCoordinate? startPoint;
  BaatoCoordinate? endPoint;

  @override
  void initState() {
    super.initState();

    final order = widget.order;

    debugPrint('Order Data:\n${const JsonEncoder.withIndent('  ').convert(order)}');

    try {
      final deliveryLocation = order['customerLocation'];
      final startLat = 27.7075;
      final startLng = 85.3123;

      final endLat = deliveryLocation?['latitude'];
      final endLng = deliveryLocation?['longitude'];

      if (endLat != null && endLng != null) {
        startPoint = BaatoCoordinate(latitude: startLat, longitude: startLng);
        endPoint = BaatoCoordinate(latitude: endLat, longitude: endLng);
      } else {
        startPoint = BaatoCoordinate(latitude: 27.7075, longitude: 85.3123);
        endPoint = BaatoCoordinate(latitude: 27.7129, longitude: 85.3282);
      }
    } catch (e) {
      debugPrint("Coordinate parsing error: $e");
      startPoint = BaatoCoordinate(latitude: 27.7075, longitude: 85.3123);
      endPoint = BaatoCoordinate(latitude: 27.7129, longitude: 85.3282);
    }
  }

  void _onMapCreated(BaatoMapController controller) {
    _mapController = controller;
    _drawRouteAndMarkers();
  }

  Future<void> _drawRouteAndMarkers() async {
    if (_mapController == null || startPoint == null || endPoint == null) return;

    try {
      final routeResponse = await Baato.api.direction.getRoutes(
        startCoordinate: startPoint!,
        endCoordinate: endPoint!,
        mode: BaatoDirectionMode.foot,
        decodePolyline: true,
      );

      _mapController!.routeManager.drawRouteFromResponse(routeResponse);

      // Start Marker (Vendor)
      _mapController!.markerManager.addMarker(
        BaatoSymbolOption(
          iconImage: 'baato_marker',
          iconSize: 1.2,
          textField: "Vendor",
          textOffset: const Offset(0, 1.2),
          textSize: 12.0,
          geometry: startPoint!,
        ),
      );

      // End Marker (Customer)
      _mapController!.markerManager.addMarker(
        BaatoSymbolOption(
          iconImage: 'baato_marker',
          iconSize: 1.2,
          textField: "Your Location",
          textOffset: const Offset(0, 1.2),
          textSize: 12.0,
          geometry: endPoint!,
        ),
      );
    } catch (e) {
      debugPrint('Route or marker error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (startPoint == null || endPoint == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          BaatoMap(
            initialPosition: startPoint!,
            initialZoom: 14.0,
            myLocationEnabled: false,
            style: BaatoMapStyle.breeze,
            compassEnabled: true,
            onMapCreated: _onMapCreated,
            logoViewMargins: const Point(-50, -50),
            attributionButtonMargins: const Point(0, 0),
            annotationOrder: const [
              AnnotationType.fill,
              AnnotationType.line,
              AnnotationType.circle,
              AnnotationType.symbol,
            ],
          ),

          // Baato Logo
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              height: 35,
              decoration: const BoxDecoration(color: Colors.white70),
              child: Image.network("https://i.postimg.cc/k5DpLQKQ/baato-Logo.png"),
            ),
          ),

          // OSM Credit
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              decoration: const BoxDecoration(color: Colors.white70),
              padding: const EdgeInsets.only(bottom: 2.0, right: 2.0),
              child: InkWell(
                onTap: () => launchUrlString("https://www.openstreetmap.org/copyright"),
                child: const Text.rich(
                  TextSpan(
                    text: "© ",
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: "OpenStreetMap contributors",
                        style: TextStyle(
                          color: Colors.purple,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 🟧 Floating Delivery Status Card
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.timer_outlined, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Order on the way",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Estimated delivery in 20 mins",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.black45),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
