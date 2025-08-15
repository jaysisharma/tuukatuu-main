// import 'package:flutter_test/flutter_test.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:tuukatuu/services/location_service.dart';

// void main() {
//   group('Distance Calculation Tests', () {
//     test('calculateDistanceTextEnhanced should return correct distance text', () {
//       // Mock user position
//       final userPosition = Position(
//         latitude: 37.7749,
//         longitude: -122.4194,
//         timestamp: DateTime.now(),
//         accuracy: 10.0,
//         altitude: 0.0,
//         heading: 0.0,
//         speed: 0.0,
//         speedAccuracy: 0.0,
//         altitudeAccuracy: 0.0,
//         headingAccuracy: 0.0,
//       );

//       // Mock store coordinates
//       final storeCoordinates = {
//         'latitude': 37.7849,
//         'longitude': -122.4094,
//       };

//       final result = LocationService.calculateDistanceTextEnhanced(userPosition, storeCoordinates);
      
//       // Should return a distance in meters or kilometers
//       expect(result, isA<String>());
//       expect(result, isNot('Distance unavailable'));
//       expect(result.contains('away'), isTrue);
//     });

//     test('calculateDistanceTextEnhanced should handle null coordinates', () {
//       final userPosition = Position(
//         latitude: 37.7749,
//         longitude: -122.4194,
//         timestamp: DateTime.now(),
//         accuracy: 10.0,
//         altitude: 0.0,
//         heading: 0.0,
//         speed: 0.0,
//         speedAccuracy: 0.0,
//         altitudeAccuracy: 0.0,
//         headingAccuracy: 0.0,
//       );

//       final result = LocationService.calculateDistanceTextEnhanced(userPosition, null);
//       expect(result, equals('Distance unavailable'));
//     });

//     test('calculateDistanceTextEnhanced should handle missing latitude/longitude', () {
//       final userPosition = Position(
//         latitude: 37.7749,
//         longitude: -122.4194,
//         timestamp: DateTime.now(),
//         accuracy: 10.0,
//         altitude: 0.0,
//         heading: 0.0,
//         speed: 0.0,
//         speedAccuracy: 0.0,
//         altitudeAccuracy: 0.0,
//         headingAccuracy: 0.0,
//       );

//       final storeCoordinates = {
//         'latitude': null,
//         'longitude': -122.4094,
//       };

//       final result = LocationService.calculateDistanceTextEnhanced(userPosition, storeCoordinates);
//       expect(result, equals('Distance unavailable'));
//     });

//     test('sortStoresByDistance should sort stores correctly', () {
//       final userPosition = Position(
//         latitude: 37.7749,
//         longitude: -122.4194,
//         timestamp: DateTime.now(),
//         accuracy: 10.0,
//         altitude: 0.0,
//         heading: 0.0,
//         speed: 0.0,
//         speedAccuracy: 0.0,
//         altitudeAccuracy: 0.0,
//         headingAccuracy: 0.0,
//       );

//       final stores = [
//         {
//           'name': 'Store A',
//           'storeCoordinates': {'latitude': 37.7849, 'longitude': -122.4194}, // ~1.1km away (north)
//         },
//         {
//           'name': 'Store B',
//           'storeCoordinates': {'latitude': 37.7749, 'longitude': -122.4094}, // ~0.8km away (east)
//         },
//         {
//           'name': 'Store C',
//           'storeCoordinates': {'latitude': 37.7949, 'longitude': -122.4194}, // ~2.2km away (further north)
//         },
//       ];

//       final sortedStores = LocationService.sortStoresByDistance(stores, userPosition);
      
//       expect(sortedStores.length, equals(3));
//       expect(sortedStores[0]['name'], equals('Store B')); // Closest (east)
//       expect(sortedStores[1]['name'], equals('Store A')); // Medium (north)
//       expect(sortedStores[2]['name'], equals('Store C')); // Farthest (further north)
//     });

//     test('getStoresWithinRadius should filter stores correctly', () {
//       final userPosition = Position(
//         latitude: 37.7749,
//         longitude: -122.4194,
//         timestamp: DateTime.now(),
//         accuracy: 10.0,
//         altitude: 0.0,
//         heading: 0.0,
//         speed: 0.0,
//         speedAccuracy: 0.0,
//         altitudeAccuracy: 0.0,
//         headingAccuracy: 0.0,
//       );

//       final stores = [
//         {
//           'name': 'Store A',
//           'storeCoordinates': {'latitude': 37.7849, 'longitude': -122.4094}, // ~1.4km away
//         },
//         {
//           'name': 'Store B',
//           'storeCoordinates': {'latitude': 37.7649, 'longitude': -122.4294}, // ~0.8km away
//         },
//         {
//           'name': 'Store C',
//           'storeCoordinates': {'latitude': 37.7949, 'longitude': -122.3994}, // ~2.2km away
//         },
//       ];

//       // Get stores within 1.5km radius
//       final nearbyStores = LocationService.getStoresWithinRadius(stores, userPosition, 1.5);
      
//       expect(nearbyStores.length, equals(2));
//       expect(nearbyStores.any((store) => store['name'] == 'Store A'), isTrue);
//       expect(nearbyStores.any((store) => store['name'] == 'Store B'), isTrue);
//       expect(nearbyStores.any((store) => store['name'] == 'Store C'), isFalse);
//     });
//   });
// }
