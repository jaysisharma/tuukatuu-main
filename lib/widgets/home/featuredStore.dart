import 'package:flutter/material.dart';
import 'package:tuukatuu/services/location_service.dart';
import 'package:tuukatuu/services/api_service.dart';

class FeaturedStore extends StatelessWidget {
  const FeaturedStore({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current location from the global service
    final hasLocation = context.hasDeliveryLocation;
    final latitude = context.currentLatitude;
    final longitude = context.currentLongitude;

    print('📍 FeaturedStore: Building with location - HasLocation: $hasLocation, Lat: $latitude, Lng: $longitude');

    // If no location is set, show a message to set location
    if (!hasLocation || latitude == null || longitude == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.location_off, color: Colors.blue[600], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Set delivery location to see featured stores',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    print('📍 FeaturedStore: Calling API with coordinates: $latitude, $longitude');

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ApiService.getFeaturedStoresForStores(
        lat: latitude,
        long: longitude,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print('❌ FeaturedStore: Error loading featured stores: ${snapshot.error}');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[400], size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Error loading featured stores',
                    style: TextStyle(color: Colors.red[600], fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Please try again later',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          print('📍 FeaturedStore: Successfully loaded ${snapshot.data!.length} stores');
          return SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final store = snapshot.data![index];
                return Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          color: Colors.blue.shade200,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.store,
                            size: 32,
                            color: Colors.blue[600],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              store['name'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }
        print('📍 FeaturedStore: No stores found in response');
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No featured stores found',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}
