import 'package:flutter/material.dart';
import 'package:tuukatuu/services/location_service.dart';
import 'package:tuukatuu/services/api_service.dart';

class FeaturedRestaurant extends StatelessWidget {
  const FeaturedRestaurant({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current location from the global service
    final hasLocation = context.hasDeliveryLocation;
    final latitude = context.currentLatitude;
    final longitude = context.currentLongitude;

    print('📍 FeaturedRestaurant: Building with location - HasLocation: $hasLocation, Lat: $latitude, Lng: $longitude');

    // If no location is set, show a message to set location
    if (!hasLocation || latitude == null || longitude == null) {
      print('📍 FeaturedRestaurant: No location available, showing location prompt');
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.location_off, color: Colors.orange[600], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Set delivery location to see featured restaurants',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    print('📍 FeaturedRestaurant: Calling API with coordinates: $latitude, $longitude');

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ApiService.getFeaturedStores(
        lat: latitude,
        long: longitude,
      ), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print('❌ FeaturedRestaurant: Error loading featured restaurants: ${snapshot.error}');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[400], size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Error loading featured restaurants',
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
          print('📍 FeaturedRestaurant: Successfully loaded ${snapshot.data!.length} restaurants');
          return SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final restaurant = snapshot.data![index];
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
                          color: Colors.orange.shade200,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.restaurant,
                            size: 32,
                            color: Colors.orange[600],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              restaurant['name'],
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
        print('📍 FeaturedRestaurant: No restaurants found in response');
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No featured restaurants found',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}