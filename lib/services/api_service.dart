import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/address.dart';
import '../config/api_config.dart';

class ApiService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<dynamic> get(String endpoint, {String? token, Map<String, String>? headers, Map<String, String>? params}) async {
    Uri uri = Uri.parse('$baseUrl$endpoint');
    
    // Add query parameters if provided
    if (params != null && params.isNotEmpty) {
      uri = uri.replace(queryParameters: params);
    }
    
    print('🌐 API GET Request: $uri'); // Debug log
    
    final response = await http.get(
      uri,
      headers: _buildHeaders(token, headers),
    );
    
    print('🌐 API Response Status: ${response.statusCode}'); // Debug log
    return _handleResponse(response);
  }

  static Future<dynamic> post(String endpoint, {String? token, Map<String, dynamic>? body, Map<String, String>? headers}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildHeaders(token, headers, isJson: true),
      body: body != null ? json.encode(body) : null,
    );
    return _handleResponse(response);
  }

  static Future<dynamic> put(String endpoint, Map<String, String> map, {String? token, Map<String, dynamic>? body, Map<String, String>? headers}) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildHeaders(token, headers, isJson: true),
      body: body != null ? json.encode(body) : null,
    );
    return _handleResponse(response);
  }

  static Future<dynamic> delete(String endpoint, {String? token, Map<String, String>? headers}) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildHeaders(token, headers),
    );
    return _handleResponse(response);
  }

  static Future<List<BannerModel>> getBanners() async {
    final res = await get('/tmart/banners');
    if (res is List) {
      return res.map((e) => BannerModel.fromJson(e)).toList();
    }
    return [];
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

  static Future<List<Product>> getProductsByCategory(String category) async {
    try {
      print('🔍 Getting products by category: $category');
      final params = <String, String>{'category': category};
      final res = await get('/tmart/products', params: params);
      if (res is List) {
        final products = res.map((e) => Product.fromJson(e)).toList();
        print('🔍 Found ${products.length} products for category "$category"');
        products.forEach((product) {
          print('   - ${product.name}: ${product.category}');
        });
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
        products.forEach((product) {
          print('     - ${product.name}');
        });
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

  static Future<List<Product>> getRecommendations() async {
    final res = await get('/tmart/recommendations');
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
    final res = await get('/addresses', token: token);
    if (res is List) {
      return res.map((e) => Address.fromJson(e)).toList();
    }
    return [];
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
    if (radius != null) params['radius'] = radius.toString();
    
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
      filteredVendors.forEach((vendor) {
        print('   - ${vendor['storeName']}: ${vendor['storeTags']?.join(', ')}');
      });
      
      return filteredVendors;
    } catch (e) {
      print('❌ Error in getVendorsByCategoryFallback: $e');
      return [];
    }
  }

  // Test connection to verify API is reachable
  static Future<bool> testConnection() async {
    try {
      print('🔍 Testing connection to: $baseUrl');
      final response = await http.get(
        Uri.parse('$baseUrl/auth/vendors'),
        headers: _buildHeaders(null, null),
      );
      
      print('🔍 Test connection status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('✅ Connection successful!');
        return true;
      } else {
        print('❌ Connection failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Connection error: $e');
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
        final message = data['message'] ?? 'Unknown error occurred';
        throw Exception('${response.statusCode}: $message');
      }
    } catch (e) {
      if (e is FormatException) {
        print('❌ FormatException: ${response.body}');
        throw Exception('Invalid response format from server (${response.statusCode})');
      }
      rethrow;
    }
  }

  static Future<dynamic> _retryRequest(Future<dynamic> Function() request, {int maxRetries = 3}) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await request();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          rethrow;
        }
        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(milliseconds: 1000 * attempts));
      }
    }
  }
} 