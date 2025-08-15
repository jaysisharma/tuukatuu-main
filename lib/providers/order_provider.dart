import 'package:flutter/material.dart';
import '../models/enhanced_order.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../services/error_service.dart';

class OrderProvider extends ChangeNotifier {
  List<EnhancedOrder> _orders = [];
  List<EnhancedOrder> _activeOrders = [];
  bool _isLoading = false;
  String? _error;
  String? _errorType;
  EnhancedOrder? _currentOrder;

  List<EnhancedOrder> get orders => _orders;
  List<EnhancedOrder> get activeOrders => _activeOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get errorType => _errorType;
  EnhancedOrder? get currentOrder => _currentOrder;

  int get totalOrders => _orders.length;
  int get activeOrdersCount => _activeOrders.length;

  // Fetch all orders for the user
  Future<void> fetchOrders({String? token}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.get('/orders', token: token);
      
      if (response['success']) {
        final ordersData = response['data'] as List<dynamic>;
        _orders = ordersData
            .map((orderData) => EnhancedOrder.fromJson(orderData))
            .toList();
        
        // Filter active orders
        _activeOrders = _orders.where((order) => order.isActive).toList();
        
        // Sort by order date (newest first)
        _orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
        _activeOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      } else {
        _setError(response['message'] ?? 'Failed to fetch orders', ErrorService.orderError);
      }
    } catch (e) {
      if (e is ApiException) {
        _setError(e.message, e.errorType);
      } else {
        _setError('Error fetching orders', ErrorService.unknownError);
      }
    } finally {
      _setLoading(false);
    }
  }

  // Fetch a specific order by ID
  Future<EnhancedOrder?> fetchOrderById(String orderId, {String? token}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.get('/orders/$orderId', token: token);
      
      if (response['success']) {
        _currentOrder = EnhancedOrder.fromJson(response['data']);
        return _currentOrder;
      } else {
        _setError(response['message'] ?? 'Failed to fetch order', ErrorService.orderError);
        return null;
      }
    } catch (e) {
      if (e is ApiException) {
        _setError(e.message, e.errorType);
      } else {
        _setError('Error fetching order', ErrorService.unknownError);
      }
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Create a new order
  Future<bool> createOrder(Map<String, dynamic> orderData, {String? token}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.post('/orders', token: token, body: orderData);
      
      if (response['success']) {
        final newOrder = EnhancedOrder.fromJson(response['data']);
        _orders.insert(0, newOrder);
        _activeOrders.insert(0, newOrder);
        _currentOrder = newOrder;
        notifyListeners();
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to create order', ErrorService.orderError);
        return false;
      }
    } catch (e) {
      if (e is ApiException) {
        _setError(e.message, e.errorType);
      } else {
        _setError('Error creating order', ErrorService.orderError);
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cancel an order
  Future<bool> cancelOrder(String orderId, {String? token, String? reason}) async {
    _setLoading(true);
    _clearError();

    try {
      final cancelData = <String, dynamic>{};
      if (reason != null && reason.isNotEmpty) {
        cancelData['reason'] = reason;
      }

      final response = await ApiService.put('/orders/$orderId/cancel', {}, token: token, body: cancelData);
      
      if (response['success']) {
        // Update the order in our lists
        final orderIndex = _orders.indexWhere((order) => order.id == orderId);
        if (orderIndex != -1) {
          _orders[orderIndex] = EnhancedOrder.fromJson(response['data']);
          _orders = List.from(_orders); // Trigger notifyListeners
        }
        
        // Update active orders
        _activeOrders = _orders.where((order) => order.isActive).toList();
        
        // Update current order if it's the one being cancelled
        if (_currentOrder?.id == orderId) {
          _currentOrder = EnhancedOrder.fromJson(response['data']);
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to cancel order', ErrorService.orderError);
        return false;
      }
    } catch (e) {
      if (e is ApiException) {
        _setError(e.message, e.errorType);
      } else {
        _setError('Error cancelling order', ErrorService.orderError);
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus status, {String? token, String? note}) async {
    try {
      final statusData = <String, dynamic>{
        'status': status.toString().split('.').last,
      };
      if (note != null && note.isNotEmpty) {
        statusData['note'] = note;
      }

      final response = await ApiService.put('/orders/$orderId/status', {}, token: token, body: statusData);
      
      if (response['success']) {
        // Update the order in our lists
        final orderIndex = _orders.indexWhere((order) => order.id == orderId);
        if (orderIndex != -1) {
          _orders[orderIndex] = EnhancedOrder.fromJson(response['data']);
          _orders = List.from(_orders); // Trigger notifyListeners
        }
        
        // Update active orders
        _activeOrders = _orders.where((order) => order.isActive).toList();
        
        // Update current order if it's the one being updated
        if (_currentOrder?.id == orderId) {
          _currentOrder = EnhancedOrder.fromJson(response['data']);
        }
        
        // Show notification for status change
        _showOrderStatusNotification(orderId, status);
        
        notifyListeners();
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to update order status', ErrorService.orderError);
        return false;
      }
    } catch (e) {
      if (e is ApiException) {
        _setError(e.message, e.errorType);
      } else {
        _setError('Error updating order status', ErrorService.orderError);
      }
      return false;
    }
  }

  // Track order
  Future<Map<String, dynamic>?> trackOrder(String orderId, {String? token}) async {
    try {
      final response = await ApiService.get('/orders/$orderId/track', token: token);
      
      if (response['success']) {
        return response['data'];
      } else {
        _setError(response['message'] ?? 'Failed to track order', ErrorService.orderError);
        return null;
      }
    } catch (e) {
      if (e is ApiException) {
        _setError(e.message, e.errorType);
      } else {
        _setError('Error tracking order', ErrorService.orderError);
      }
      return null;
    }
  }

  // Rate order
  Future<bool> rateOrder(String orderId, int rating, {String? comment, String? token}) async {
    try {
      final ratingData = <String, dynamic>{
        'rating': rating,
      };
      if (comment != null && comment.isNotEmpty) {
        ratingData['comment'] = comment;
      }

      final response = await ApiService.post('/orders/$orderId/rate', token: token, body: ratingData);
      
      if (response['success']) {
        // Update the order in our lists
        final orderIndex = _orders.indexWhere((order) => order.id == orderId);
        if (orderIndex != -1) {
          _orders[orderIndex] = EnhancedOrder.fromJson(response['data']);
          _orders = List.from(_orders); // Trigger notifyListeners
        }
        
        // Update current order if it's the one being rated
        if (_currentOrder?.id == orderId) {
          _currentOrder = EnhancedOrder.fromJson(response['data']);
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to rate order', ErrorService.orderError);
        return false;
      }
    } catch (e) {
      if (e is ApiException) {
        _setError(e.message, e.errorType);
      } else {
        _setError('Error rating order', ErrorService.orderError);
      }
      return false;
    }
  }

  // Refresh order status (for real-time updates)
  Future<void> refreshOrderStatus(String orderId, {String? token}) async {
    try {
      final response = await ApiService.get('/orders/$orderId', token: token);
      
      if (response['success']) {
        final updatedOrder = EnhancedOrder.fromJson(response['data']);
        
        // Update the order in our lists
        final orderIndex = _orders.indexWhere((order) => order.id == orderId);
        if (orderIndex != -1) {
          final oldStatus = _orders[orderIndex].status;
          _orders[orderIndex] = updatedOrder;
          
          // Check if status changed and show notification
          if (oldStatus != updatedOrder.status) {
            _showOrderStatusNotification(orderId, updatedOrder.status);
          }
        }
        
        // Update active orders
        _activeOrders = _orders.where((order) => order.isActive).toList();
        
        // Update current order if it's the one being refreshed
        if (_currentOrder?.id == orderId) {
          _currentOrder = updatedOrder;
        }
        
        notifyListeners();
      }
    } catch (e) {
      // Don't show error for refresh operations, just log it
      print('Error refreshing order status: $e');
    }
  }

  // Show notification for order status change
  void _showOrderStatusNotification(String orderId, OrderStatus status) async {
    // Check if order notifications are enabled
    final orderNotificationsEnabled = await NotificationService.areOrderNotificationsEnabled();
    if (!orderNotificationsEnabled) return;

    final statusString = status.toString().split('.').last;
    
    switch (status) {
      case OrderStatus.delivered:
        await NotificationService.showOrderCompleted(orderId);
        break;
      case OrderStatus.cancelled:
        // Get cancellation reason from order
        final order = getOrderById(orderId);
        final reason = order?.statusHistory?.last['note'] ?? 'No reason provided';
        await NotificationService.showOrderCancelled(orderId, reason);
        break;
      case OrderStatus.failed:
        // Get failure reason from order
        final order = getOrderById(orderId);
        final reason = order?.statusHistory?.last['note'] ?? 'No reason provided';
        await NotificationService.showOrderRejected(orderId, reason);
        break;
      default:
        await NotificationService.showOrderStatusNotification(
          orderId: orderId,
          status: statusString,
        );
    }
  }

  // Get order by ID from local cache
  EnhancedOrder? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  // Clear current order
  void clearCurrentOrder() {
    _currentOrder = null;
    notifyListeners();
  }

  // Clear all data
  void clearData() {
    _orders.clear();
    _activeOrders.clear();
    _currentOrder = null;
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error, String errorType) {
    _error = error;
    _errorType = errorType;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    _errorType = null;
  }
}