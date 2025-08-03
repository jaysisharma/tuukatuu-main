import '../models/enhanced_order.dart';
import 'api_service.dart';

class OrderService {
  // Get all orders for user
  static Future<List<EnhancedOrder>> getUserOrders({String? token}) async {
    try {
      final response = await ApiService.get('/orders', token: token);
      if (response['success']) {
        final ordersData = response['data'] as List<dynamic>;
        return ordersData
            .map((orderData) => EnhancedOrder.fromJson(orderData))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  // Get order by ID
  static Future<EnhancedOrder?> getOrderById(String orderId, {String? token}) async {
    try {
      final response = await ApiService.get('/orders/$orderId', token: token);
      if (response['success']) {
        return EnhancedOrder.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Error fetching order: $e');
      return null;
    }
  }

  // Create new order
  static Future<EnhancedOrder?> createOrder(Map<String, dynamic> orderData, {String? token}) async {
    try {
      final response = await ApiService.post('/orders', token: token, body: orderData);
      if (response['success']) {
        return EnhancedOrder.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  // Cancel order
  static Future<EnhancedOrder?> cancelOrder(String orderId, {String? token}) async {
    try {
      final response = await ApiService.put('/orders/$orderId/cancel', {}, token: token);
      if (response['success']) {
        return EnhancedOrder.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Error cancelling order: $e');
      return null;
    }
  }

  // Rate order
  static Future<bool> rateOrder(String orderId, double rating, String? review, {String? token}) async {
    try {
      final response = await ApiService.post('/orders/$orderId/rate', token: token, body: {
        'rating': rating,
        'review': review,
      });
      return response['success'] ?? false;
    } catch (e) {
      print('Error rating order: $e');
      return false;
    }
  }

  // Get order tracking info
  static Future<Map<String, dynamic>?> getOrderTracking(String orderId, {String? token}) async {
    try {
      final response = await ApiService.get('/orders/$orderId/tracking', token: token);
      if (response['success']) {
        return response['data'];
      }
      return null;
    } catch (e) {
      print('Error fetching order tracking: $e');
      return null;
    }
  }

  // Get order history
  static Future<List<EnhancedOrder>> getOrderHistory({String? token, int? page, int? limit}) async {
    try {
      final params = <String, String>{};
      if (page != null) params['page'] = page.toString();
      if (limit != null) params['limit'] = limit.toString();
      
      final response = await ApiService.get('/orders/history', token: token, params: params);
      if (response['success']) {
        final ordersData = response['data'] as List<dynamic>;
        return ordersData
            .map((orderData) => EnhancedOrder.fromJson(orderData))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching order history: $e');
      return [];
    }
  }

  // Get active orders
  static Future<List<EnhancedOrder>> getActiveOrders({String? token}) async {
    try {
      final response = await ApiService.get('/orders/active', token: token);
      if (response['success']) {
        final ordersData = response['data'] as List<dynamic>;
        return ordersData
            .map((orderData) => EnhancedOrder.fromJson(orderData))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching active orders: $e');
      return [];
    }
  }

  // Reorder
  static Future<EnhancedOrder?> reorder(String orderId, {String? token}) async {
    try {
      final response = await ApiService.post('/orders/$orderId/reorder', token: token);
      if (response['success']) {
        return EnhancedOrder.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Error reordering: $e');
      return null;
    }
  }

  // Get order statistics
  static Future<Map<String, dynamic>?> getOrderStats({String? token}) async {
    try {
      final response = await ApiService.get('/orders/stats', token: token);
      if (response['success']) {
        return response['data'];
      }
      return null;
    } catch (e) {
      print('Error fetching order stats: $e');
      return null;
    }
  }
} 