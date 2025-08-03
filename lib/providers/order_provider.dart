import 'package:flutter/material.dart';
import '../models/enhanced_order.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class OrderProvider extends ChangeNotifier {
  List<EnhancedOrder> _orders = [];
  List<EnhancedOrder> _activeOrders = [];
  bool _isLoading = false;
  String? _error;
  EnhancedOrder? _currentOrder;

  List<EnhancedOrder> get orders => _orders;
  List<EnhancedOrder> get activeOrders => _activeOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;
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
        _setError(response['message'] ?? 'Failed to fetch orders');
      }
    } catch (e) {
      _setError('Error fetching orders: $e');
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
        _setError(response['message'] ?? 'Failed to fetch order');
        return null;
      }
    } catch (e) {
      _setError('Error fetching order: $e');
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
        _setError(response['message'] ?? 'Failed to create order');
        return false;
      }
    } catch (e) {
      _setError('Error creating order: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cancel an order
  Future<bool> cancelOrder(String orderId, {String? token}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.put('/orders/$orderId/cancel', {}, token: token);
      
      if (response['success']) {
        final updatedOrder = EnhancedOrder.fromJson(response['data']);
        
        // Update the order in the lists
        final orderIndex = _orders.indexWhere((order) => order.id == orderId);
        if (orderIndex != -1) {
          _orders[orderIndex] = updatedOrder;
        }
        
        // Remove from active orders if cancelled
        _activeOrders.removeWhere((order) => order.id == orderId);
        
        // Update current order if it's the one being cancelled
        if (_currentOrder?.id == orderId) {
          _currentOrder = updatedOrder;
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to cancel order');
        return false;
      }
    } catch (e) {
      _setError('Error cancelling order: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update order status (for real-time updates)
  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      final order = _orders[orderIndex];
      final oldStatus = order.status;
      
      // Create a new order with updated status
      final updatedOrder = EnhancedOrder(
        id: order.id,
        userId: order.userId,
        vendorId: order.vendorId,
        vendorName: order.vendorName,
        vendorImage: order.vendorImage,
        items: order.items,
        itemTotal: order.itemTotal,
        tax: order.tax,
        deliveryFee: order.deliveryFee,
        tip: order.tip,
        total: order.total,
        status: newStatus,
        orderDate: order.orderDate,
        deliveryDate: order.deliveryDate,
        deliveryAddress: order.deliveryAddress,
        customerLocation: order.customerLocation,
        instructions: order.instructions,
        paymentMethod: order.paymentMethod,
        paymentStatus: order.paymentStatus,
        riderId: order.riderId,
        riderName: order.riderName,
        riderPhone: order.riderPhone,
        trackingInfo: order.trackingInfo,
        statusHistory: order.statusHistory,
      );
      
      _orders[orderIndex] = updatedOrder;
      
      // Update active orders list
      if (updatedOrder.isActive) {
        final activeIndex = _activeOrders.indexWhere((order) => order.id == orderId);
        if (activeIndex != -1) {
          _activeOrders[activeIndex] = updatedOrder;
        } else {
          _activeOrders.insert(0, updatedOrder);
        }
      } else {
        _activeOrders.removeWhere((order) => order.id == orderId);
      }
      
      // Update current order if it's the one being updated
      if (_currentOrder?.id == orderId) {
        _currentOrder = updatedOrder;
      }
      
      // Show notification if status changed
      if (oldStatus != newStatus) {
        _showOrderStatusNotification(orderId, newStatus);
      }
      
      notifyListeners();
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
        final reason = order?.statusHistory?.last?['note'] ?? 'No reason provided';
        await NotificationService.showOrderCancelled(orderId, reason);
        break;
      case OrderStatus.failed:
        // Get failure reason from order
        final order = getOrderById(orderId);
        final reason = order?.statusHistory?.last?['note'] ?? 'No reason provided';
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

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
} 