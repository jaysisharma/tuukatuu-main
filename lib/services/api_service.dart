import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/address.dart';
import '../core/config/app_config.dart';
import 'error_service.dart';

class ApiService {
  static String get baseUrl => AppConfig.baseUrl;

  static Future<dynamic> get(String endpoint, {String? token, Map<String, String>? headers, Map<String, String>? params}) async {
    Uri uri = Uri.parse('$baseUrl$endpoint');
    
    // Add query parameters if provided
    if (params != null && params.isNotEmpty) {
      uri = uri.replace(queryParameters: params);
    }
    
    print('🌐 API GET Request: $uri'); // Debug log
    
    try {
      final response = await http.get(
        uri,
        headers: _buildHeaders(token, headers),
      );
      
      print('🌐 API Response Status: ${response.statusCode}'); // Debug log
      return _handleResponse(response);
    } catch (e) {
      print('❌ API GET Error: $e');
      final errorType = ErrorService.handleApiError(e);
      // Don't expose the raw error message to users
      final userMessage = ErrorService.getErrorMessage(errorType);
      throw ApiException(errorType, userMessage, e.toString());
    }
  }

  static Future<dynamic> post(String endpoint, {String? token, Map<String, dynamic>? body, Map<String, String>? headers}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _buildHeaders(token, headers, isJson: true),
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      print('❌ API POST Error: $e');
      final errorType = ErrorService.handleApiError(e);
      // Don't expose the raw error message to users
      final userMessage = ErrorService.getErrorMessage(errorType);
      throw ApiException(errorType, userMessage, e.toString());
    }
  }

  static Future<dynamic> put(String endpoint, Map<String, String> map, {String? token, Map<String, dynamic>? body, Map<String, String>? headers}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _buildHeaders(token, headers, isJson: true),
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      print('❌ API PUT Error: $e');
      final errorType = ErrorService.handleApiError(e);
      // Don't expose the raw error message to users
      final userMessage = ErrorService.getErrorMessage(errorType);
      throw ApiException(errorType, userMessage, e.toString());
    }
  }

  static Future<dynamic> delete(String endpoint, {String? token, Map<String, String>? headers}) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _buildHeaders(token, headers),
      );
      return _handleResponse(response);
    } catch (e) {
      print('❌ API DELETE Error: $e');
      final errorType = ErrorService.handleApiError(e);
      // Don't expose the raw error message to users
      final userMessage = ErrorService.getErrorMessage(errorType);
      throw ApiException(errorType, userMessage, e.toString());
    }
  }

  static Future<List<BannerModel>> getBanners() async {
    final res = await get('/tmart/banners');
    if (res is List) {
      return res.map((e) => BannerModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getGeneralBanners() async {
    try {
      final res = await get('/banners');
      if (res is List) {
        return res.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('❌ API Error: Failed to fetch general banners: $e');
      return [];
    }
  }

  static Future<List<CategoryModel>> getCategories() async {
    final res = await get('/tmart/categories');
    if (res is List) {
      return res.map((e) => CategoryModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<List<Product>> getProducts({String? category, String? search}) async {
    final params = <String, String>{};
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (search != null && search.isNotEmpty) params['search'] = search;
    final res = await get('/tmart/products', params: params);
    if (res is List) {
      return res.map((e) => Product.fromJson(e)).toList();
    }
    return [];
  }

  static Future<List<Product>> searchProducts(String query, {int limit = 10, int page = 1}) async {
    try {
      print('🔍 API Service: Searching for "$query"');
      
      final params = <String, String>{
        'search': query.trim(),
        'limit': limit.toString(),
        'page': page.toString(),
      };
      
      final response = await get('/products', params: params);
      
      if (response != null && response['data'] != null) {
        final products = (response['data'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
        
        print('✅ API Service: Found ${products.length} products for "$query"');
        return products;
      } else {
        print('❌ API Service: No products found for "$query"');
        return [];
      }
    } catch (e) {
      print('❌ API Service: Search error for "$query": $e');
      return [];
    }
  }

  static Future<List<Product>> getPopularProducts({int limit = 6}) async {
    try {
      print('🔍 API Service: Loading popular products');
      
      final params = <String, String>{
        'limit': limit.toString(),
        'isPopular': 'true',
      };
      
      final response = await get('/products', params: params);
      
      if (response != null && response['data'] != null) {
        final products = (response['data'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
        
        print('✅ API Service: Loaded ${products.length} popular products');
        return products;
      } else {
        print('❌ API Service: No popular products found');
        return [];
      }
    } catch (e) {
      print('❌ API Service: Error loading popular products: $e');
      return [];
    }
  }

  static Future<List<Product>> getSimilarProducts(String productId, {int limit = 6}) async {
    try {
      print('🔍 API Service: Loading similar products for product $productId');
      
      final params = <String, String>{
        'productId': productId,
        'limit': limit.toString(),
      };
      
      final response = await get('/products/similar', params: params);
      
      if (response != null && response['data'] != null) {
        final products = (response['data'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
        
        print('✅ API Service: Loaded ${products.length} similar products');
        return products;
      } else {
        print('❌ API Service: No similar products found');
        return [];
      }
    } catch (e) {
      print('❌ API Service: Error loading similar products: $e');
      return [];
    }
  }

  static Future<List<Product>> getRecommendations({int limit = 6}) async {
    try {
      print('🔍 API Service: Loading recommendations');
      
      final params = <String, String>{
        'limit': limit.toString(),
        'isFeatured': 'true',
      };
      
      final response = await get('/products', params: params);
      
      if (response != null && response['data'] != null) {
        final products = (response['data'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
        
        print('✅ API Service: Loaded ${products.length} recommendations');
        return products;
      } else {
        print('❌ API Service: No recommendations found');
        return [];
      }
    } catch (e) {
      print('❌ API Service: Error loading recommendations: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getProductsByVendor(String vendorId) async {
    try {
      print('🔍 Fetching products for vendor: $vendorId');
      
      if (vendorId.isEmpty) {
        print('❌ Vendor ID is empty');
        return [];
      }
      
      final params = <String, String>{'vendorId': vendorId};
      final response = await get('/products', params: params);
      
      if (response is Map<String, dynamic> && response['data'] is List) {
        // Backend returns products in the 'data' field
        final products = response['data'] as List;
        print('🔍 Found ${products.length} products for vendor $vendorId');
        return products;
      } else if (response is List) {
        // Direct list response (fallback)
        print('🔍 Found ${response.length} products for vendor $vendorId (direct response)');
        return response;
      } else {
        print('🔍 No products found for vendor $vendorId. Response: $response');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching products by vendor: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getProductsByVendorName(String vendorName) async {
    try {
      print('🔍 Fetching products for vendor name: $vendorName');
      
      if (vendorName.isEmpty) {
        print('❌ Vendor name is empty');
        return [];
      }
      
      final params = <String, String>{'vendorName': vendorName};
      final response = await get('/products', params: params);
      
      if (response is Map<String, dynamic> && response['data'] is List) {
        // Backend returns products in the 'data' field
        final products = response['data'] as List;
        print('🔍 Found ${products.length} products for vendor name $vendorName');
        return products;
      } else if (response is List) {
        // Direct list response (fallback)
        print('🔍 Found ${response.length} products for vendor name $vendorName (direct response)');
        return response;
      } else {
        print('🔍 No products found for vendor name $vendorName. Response: $response');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching products by vendor name: $e');
      return [];
    }
  }

  static Future<List<Product>> getProductsByCategory(String category) async {
    try {
      print('🔍 Getting products by category: $category');
      final params = <String, String>{'category': category};
      final res = await get('/tmart/products', params: params);
      if (res is List) {
        final products = res.map((e) => Product.fromJson(e)).toList();
        print('🔍 Found ${products.length} products for category "$category"');
        for (var product in products) {
          print('   - ${product.name}: ${product.category}');
        }
        return products;
      }
      return [];
    } catch (e) {
      print('❌ Error getting products by category: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getProductsByCategoryGrouped(String category, {int page = 1, int limit = 20}) async {
    try {
      print('🔍 Getting products by category grouped by vendor: $category');
      final params = <String, String>{
        'category': category,
        'page': page.toString(),
        'limit': limit.toString(),
      };
      final res = await get('/products/by-category', params: params);
      print('🔍 Response for category "$category": $res');
      return res;
    } catch (e) {
      print('❌ Error getting products by category grouped: $e');
      return {
        'vendors': [],
        'total': 0,
        'page': page,
        'limit': limit,
        'totalPages': 0
      };
    }
  }

  static Future<void> debugAllProducts() async {
    try {
      print('🔍 Debugging all products...');
      final products = await getProducts();
      print('🔍 Total products in database: ${products.length}');
      
      // Group by category
      final categoryMap = <String, List<Product>>{};
      for (final product in products) {
        categoryMap.putIfAbsent(product.category, () => []).add(product);
      }
      
      print('🔍 Products grouped by category:');
      categoryMap.forEach((category, products) {
        print('   Category: "$category" (${products.length} products)');
        for (var product in products) {
          print('     - ${product.name}');
        }
      });
    } catch (e) {
      print('❌ Error debugging products: $e');
    }
  }

  static Future<List<Product>> getBestSellers() async {
    final res = await get('/tmart/best-sellers');
    if (res is List) {
      return res.map((e) => Product.fromJson(e)).toList();
    }
    return [];
  }

  static Future<List<Product>> getPopularItems() async {
    final res = await get('/tmart/popular');
    if (res is List) {
      return res.map((e) => Product.fromJson(e)).toList();
    }
    return [];
  }

  static Future<List<Product>> getDeals() async {
    final res = await get('/tmart/deals');
    if (res is List) {
      return res.map((e) => Product.fromJson(e)).toList();
    }
    return [];
  }

  static Future<List<Combo>> getCombos() async {
    final res = await get('/tmart/combos');
    if (res is List) {
      return res.map((e) => Combo.fromJson(e)).toList();
    }
    return [];
  }

  static Future<List<Product>> getRecentlyOrdered({String? token}) async {
    final res = await get('/tmart/recently-ordered', token: token);
    if (res is List) {
      return res.map((e) => Product.fromJson(e)).toList();
    }
    return [];
  }

  static Future<Map<String, dynamic>?> getStoreInfo() async {
    final res = await get('/tmart/store-info');
    if (res is Map<String, dynamic>) return res;
    return null;
  }

  // Address API methods
  static Future<List<Address>> getAddresses(String token) async {
    print('🔍 ApiService: Calling getAddresses with token: ${token.substring(0, 10)}...');
    try {
      final res = await get('/addresses', token: token);
      print('🔍 ApiService: getAddresses response type: ${res.runtimeType}');
      print('🔍 ApiService: getAddresses response: $res');
      
      if (res is List) {
        final addresses = res.map((e) => Address.fromJson(e)).toList();
        print('🔍 ApiService: Successfully parsed ${addresses.length} addresses');
        return addresses;
      } else {
        print('❌ ApiService: Unexpected response type: ${res.runtimeType}');
        return [];
      }
    } catch (e) {
      print('❌ ApiService: Error in getAddresses: $e');
      rethrow;
    }
  }

  static Future<Address> createAddress(String token, Map<String, dynamic> body, {Map<String, String>? headers}) async {
    final res = await post('/addresses', token: token, body: body, headers: headers);

    if (res == null) {
      throw Exception("Received null response from backend.");
    }

    if (res is Map<String, dynamic>) {
      return Address.fromJson(res);
    } else {
      throw Exception("Unexpected response format: $res");
    }
  }

  static Future<Address> updateAddress(String token, String id, Map<String, dynamic> body) async {
    final res = await put('/addresses/$id', {}, token: token, body: body);
    
    if (res == null) {
      throw Exception("Received null response from backend.");
    }

    if (res is Map<String, dynamic>) {
      return Address.fromJson(res);
    } else {
      throw Exception("Unexpected response format: $res");
    }
  }

  static Future<void> deleteAddress(String token, String id) async {
    await delete('/addresses/$id', token: token);
  }

  static Future<Address> setDefaultAddress(String token, String id) async {
    final res = await put('/addresses/$id/default', {}, token: token);
    return Address.fromJson(res);
  }

  // Vendor API methods
  static Future<List<dynamic>> getVendorsByCategory(String category, {double? latitude, double? longitude, double radius = 10}) async {
    final params = <String, String>{};
    if (latitude != null) params['latitude'] = latitude.toString();
    if (longitude != null) params['longitude'] = longitude.toString();
    params['radius'] = radius.toString();
    
    final res = await get('/auth/vendors/category/$category', params: params);
    if (res is List) return res;
    return [];
  }

  static Future<List<dynamic>> getNearbyVendors({required double latitude, required double longitude, double radius = 10}) async {
    final params = <String, String>{
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'radius': radius.toString(),
    };
    
    final res = await get('/auth/vendors/nearby', params: params);
    if (res is List) return res;
    return [];
  }

  // Get vendors by category (simplified approach)
  static Future<List<dynamic>> getVendorsByCategorySimple(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/vendors/category/$category'),
        headers: _buildHeaders(null, null),
      );

      final data = _handleResponse(response);
      return List<dynamic>.from(data);
    } catch (e) {
      print('Error fetching vendors by category: $e');
      return [];
    }
  }

  // Get all vendors and filter by category on frontend (fallback approach)
  static Future<List<dynamic>> getVendorsByCategoryFallback(String category) async {
    try {
      print('🔍 getVendorsByCategoryFallback called with category: $category');
      
      final response = await http.get(
        Uri.parse('$baseUrl/auth/vendors'),
        headers: _buildHeaders(null, null),
      );

      print('🔍 API response status: ${response.statusCode}');
      print('🔍 API response body length: ${response.body.length}');

      final data = _handleResponse(response);
      print('🔍 Parsed data type: ${data.runtimeType}');
      
      final allVendors = List<dynamic>.from(data);
      print('🔍 Total vendors from API: ${allVendors.length}');
      
      // Log first few vendors for debugging
      allVendors.take(3).forEach((vendor) {
        print('   - ${vendor['storeName']}: ${vendor['storeTags']}');
      });
      
      // Filter vendors by category on frontend with improved logic
      final filteredVendors = allVendors.where((vendor) {
        final tags = List<String>.from(vendor['storeTags'] ?? []);
        
        // Handle compound categories like "Wine & Beer"
        if (category.toLowerCase().contains('&')) {
          // Split by '&' and check if any part matches
          final categoryParts = category.toLowerCase().split('&').map((e) => e.trim());
          return categoryParts.any((part) => 
            tags.any((tag) => tag.toLowerCase().contains(part))
          );
        } else {
          // Simple category matching
          return tags.any((tag) => tag.toLowerCase().contains(category.toLowerCase()));
        }
      }).toList();
      
      print('🔍 Filtered vendors for "$category": ${filteredVendors.length}');
      for (var vendor in filteredVendors) {
        print('   - ${vendor['storeName']}: ${vendor['storeTags']?.join(', ')}');
      }
      
      return filteredVendors;
    } catch (e) {
      print('❌ Error in getVendorsByCategoryFallback: $e');
      return [];
    }
  }

  // Test connection to verify API is reachable
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/vendors'),
        headers: _buildHeaders(null, null),
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Map<String, String> _buildHeaders(String? token, Map<String, String>? headers, {bool isJson = false}) {
    final base = <String, String>{};
    if (isJson) base['Content-Type'] = 'application/json';
    if (token != null) base['Authorization'] = 'Bearer $token';
    if (headers != null) base.addAll(headers);
    return base;
  }

  static dynamic _handleResponse(http.Response response) {
    try {
      final data = json.decode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        // Handle different error responses
        String errorMessage = 'Unknown error occurred';
        String errorType = ErrorService.handleHttpStatus(response.statusCode);
        
        if (data is Map<String, dynamic>) {
          errorMessage = data['message'] ?? data['error'] ?? errorMessage;
          
          // Check for specific error types in the response
          if (data['errorType'] != null) {
            errorType = data['errorType'];
          }
        }
        
        // Log the error for debugging
        ErrorService.logError(errorType, errorMessage, {
          'statusCode': response.statusCode,
          'endpoint': response.request?.url.toString(),
          'responseBody': response.body,
        });
        
        throw ApiException(errorType, errorMessage);
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      
      if (e is FormatException) {
        print('❌ FormatException: ${response.body}');
        throw ApiException(ErrorService.serverError, 'Invalid response format from server');
      }
      
      // Handle other parsing errors
      throw ApiException(ErrorService.unknownError, 'Failed to process server response');
    }
  }


  static Future<List<Map<String, dynamic>>> getFeaturedStores({double? lat, double? long}) async {
    print('📍 API Service: Calling getFeaturedStores with coordinates - Lat: $lat, Long: $long');
    
    final res = await get('/customer/featured-restaurants', params: {
      'lat': lat.toString(),
      'lon': long.toString(),
    });
    
    print('📍 API Service: Response received: ${res.runtimeType} - Length: ${res is List ? res.length : 'N/A'}');
    
    if (res is List) {
      return res.map((e) {
        // Debug logging for first item
        if (res.indexOf(e) == 0) {
          print('🔍 API Service: Sample restaurant data keys: ${e.keys.toList()}');
          print('🔍 API Service: Sample restaurant storeDescription: ${e['storeDescription']}');
          print('🔍 API Service: Sample restaurant storeImage: ${e['storeImage']}');
          print('🔍 API Service: Sample restaurant storeBanner: ${e['storeBanner']}');
        }
        
        // Calculate delivery time based on distance
        double distanceKm = 0.0;
        if (e['distance'] != null) {
          distanceKm = (e['distance'] / 1000).toDouble(); // Convert meters to km
        }
        
        String deliveryTime = _calculateDeliveryTime(distanceKm);
        
        final processed = {
          'id': e['_id'],
          'name': e['storeName'] ?? e['name'] ?? 'Restaurant',
          'category': 'Restaurant',
          'rating': e['storeRating']?.toDouble() ?? 4.0,
          'time': deliveryTime,
          'distance': _formatDistance(distanceKm),
          'distanceKm': distanceKm,
          'imageUrl': e['storeImage'] ?? e['storeBanner'] ?? 'assets/images/products/bread.jpg',
          'description': e['storeDescription'] ?? e['description'] ?? '',
          'coordinates': e['storeCoordinates'],
          'address': e['storeAddress'] ?? 'Address not available',
        };
        
        if (res.indexOf(e) == 0) {
          print('🔍 API Service: Processed restaurant description: ${processed['description']}');
          print('🔍 API Service: Processed restaurant imageUrl: ${processed['imageUrl']}');
        }
        
        return processed;
      }).toList();
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getFeaturedStoresForStores({double? lat, double? long}) async {
   
    try {
      final res = await get('/customer/featured-stores', params: {
        'lat': lat.toString(),
        'lon': long.toString(),
      });
      
     print(res);
      
      if (res is List) {
        print('📍 API Service: Processing ${res.length} stores');
        final processedStores = res.map((e) {
          // Debug logging for first item
          if (res.indexOf(e) == 0) {
            print('🔍 API Service: Sample store data keys: ${e.keys.toList()}');
            print('🔍 API Service: Sample store storeDescription: ${e['storeDescription']}');
            print('🔍 API Service: Sample store storeImage: ${e['storeImage']}');
            print('🔍 API Service: Sample store storeBanner: ${e['storeBanner']}');
          }
          
          // Calculate delivery time based on distance
          double distanceKm = 0.0;
          if (e['distance'] != null) {
            distanceKm = (e['distance'] / 1000).toDouble(); // Convert meters to km
          }
          
          String deliveryTime = _calculateDeliveryTime(distanceKm);
          
          final store = {
            'id': e['_id'],
            'name': e['storeName'] ?? e['name'] ?? 'Store',
            'category': e['vendorType'] == 'restaurant' ? 'Restaurant' : 'Store',
            'rating': e['storeRating']?.toDouble() ?? 4.0,
            'time': deliveryTime,
            'distance': _formatDistance(distanceKm),
            'distanceKm': distanceKm,
            'imageUrl': e['storeImage'] ?? e['storeBanner'] ?? 'assets/images/products/chocolate.jpg',
            'description': e['storeDescription'] ?? e['description'] ?? '',
            'coordinates': e['storeCoordinates'],
            'address': e['storeAddress'] ?? 'Address not available',
          };
          
          if (res.indexOf(e) == 0) {
            print('🔍 API Service: Processed store description: ${store['description']}');
            print('🔍 API Service: Processed store imageUrl: ${store['imageUrl']}');
          }
          
          print('📍 API Service: Processed store: ${store['name']} - Category: ${store['category']} - Distance: ${store['distance']}');
          return store;
        }).toList();
        
        print('📍 API Service: Returning ${processedStores.length} processed stores');
        return processedStores;
      } else {
        print('❌ API Service: Response is not a list. Type: ${res.runtimeType}');
        return [];
      }
    } catch (e) {
      print('❌ API Service: Error in getFeaturedStoresForStores: $e');
      return [];
    }
  }

  // Helper method to calculate delivery time based on distance
  static String _calculateDeliveryTime(double distanceKm) {
    // Base delivery time (preparation + pickup time)
    int baseTimeMinutes = 15;
    
    // Travel time calculation (assuming average speed of 20 km/h in city traffic)
    int travelTimeMinutes = (distanceKm * 3).round(); // 3 minutes per km
    
    // Total delivery time
    int totalTimeMinutes = baseTimeMinutes + travelTimeMinutes;
    
    // Add some buffer time for traffic and other delays
    int bufferTimeMinutes = (totalTimeMinutes * 0.2).round(); // 20% buffer
    totalTimeMinutes += bufferTimeMinutes;
    
    // Format the time range
    int minTime = totalTimeMinutes - 5;
    int maxTime = totalTimeMinutes + 10;
    
    return '$minTime-$maxTime mins';
  }

  static String _formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toInt()} m';
    } else {
      return '${distanceKm.toStringAsFixed(1)} Km';
    }
  }

  // Favorites API methods
  static Future<List<Map<String, dynamic>>> getUserFavorites({required String token}) async {
    try {
      final res = await get('/favorites', token: token);
      if (res is List) {
        return res.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('❌ Error fetching user favorites: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> addToFavorites({
    required String token,
    required String itemId,
    required String itemType,
    required String itemName,
    required String itemImage,
    double? rating,
    String? category,
  }) async {
    // Debug: Print the request body
    final body = {
      'itemId': itemId,
      'itemType': itemType,
      'itemName': itemName,
      'itemImage': itemImage,
      if (rating != null) 'rating': rating,
      if (category != null) 'category': category,
    };
    print('🔍 API Service: Sending to /favorites: $body');
    
    try {
      final res = await post('/favorites', token: token, body: body);
      return res;
    } catch (e) {
      print('❌ Error adding to favorites: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> removeFromFavorites({
    required String token,
    required String itemId,
  }) async {
    try {
      final res = await delete('/favorites/$itemId', token: token);
      return res;
    } catch (e) {
      print('❌ Error removing from favorites: $e');
      rethrow;
    }
  }

  static Future<bool> checkIfFavorited({
    required String token,
    required String itemId,
  }) async {
    try {
      final res = await get('/favorites/check/$itemId', token: token);
      return res['isFavorited'] ?? false;
    } catch (e) {
      print('❌ Error checking favorite status: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getDailyEssentials({int? limit}) async {
    print('📍 API Service: Calling getDailyEssentials with limit: $limit');
    
    try {
      final res = await get('/daily-essentials${limit != null ? '?limit=$limit' : ''}');
      print('📍 API Service: Daily essentials response received: ${res.runtimeType}');
      
      if (res['success'] && res['data'] != null) {
        final essentials = List<Map<String, dynamic>>.from(res['data']);
        print('📍 API Service: Processing ${essentials.length} daily essentials');
        
        final processedEssentials = essentials.map((essential) {
          final product = essential['productId'] ?? essential;
          
          // Debug logging for first item
          if (essentials.indexOf(essential) == 0) {
            print('🔍 API Service: Sample daily essential keys: ${essential.keys.toList()}');
            print('🔍 API Service: Sample product keys: ${product.keys.toList()}');
            print('🔍 API Service: Sample product imageUrl: ${product['imageUrl']}');
            print('🔍 API Service: Sample product image: ${product['image']}');
            print('🔍 API Service: Sample product images: ${product['images']}');
          }
          
          return {
            'id': essential['_id'],
            'productId': {
              'id': product['_id'] ?? product['id'],
              'name': product['name'] ?? 'Product',
              'price': product['price'] ?? 0,
              'originalPrice': product['originalPrice'],
              'imageUrl': product['imageUrl'] ?? product['image'] ?? '',
              'images': product['images'] ?? [],
              'category': product['category'] ?? 'Product',
              'description': product['description'] ?? '',
              'unit': product['unit'] ?? '1 piece',
              'isAvailable': product['isAvailable'] ?? true,
              'rating': product['rating'] ?? 0.0,
              'reviews': product['reviews'] ?? 0,
            },
            'isFeatured': essential['isFeatured'] ?? false,
            'isActive': essential['isActive'] ?? true,
            'sortOrder': essential['sortOrder'] ?? 0,
            'image': essential['image'], // Daily essential specific image
          };
        }).toList();
        
        print('📍 API Service: Returning ${processedEssentials.length} processed daily essentials');
        return processedEssentials;
      } else {
        print('❌ API Service: Daily essentials failed: ${res['message']}');
        return [];
      }
    } catch (e) {
      print('❌ API Service: Error in getDailyEssentials: $e');
      return [];
    }
  }
}

// Custom exception class for API errors
class ApiException implements Exception {
  final String errorType;
  final String message;
  final String? originalError;

  ApiException(this.errorType, this.message, [this.originalError]);

  @override
  String toString() {
    return 'ApiException: $errorType - $message';
  }
} 