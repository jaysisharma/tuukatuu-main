import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'notification_service.dart';

class OrderPollingService {
  static Timer? _pollingTimer;
  static bool _isPolling = false;
  static const Duration _pollingInterval = Duration(seconds: 30); // Poll every 30 seconds
  
  // Start polling for order updates
  static void startPolling() {
    if (_isPolling) return;
    
    _isPolling = true;
    _pollingTimer = Timer.periodic(_pollingInterval, (_) => _checkOrderUpdates());
    
  }
  
  // Stop polling
  static void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
    
    print('🛑 Order polling stopped');
  }
  
  // Check if polling is active
  static bool get isPolling => _isPolling;
  
  // Check for order updates
  static Future<void> _checkOrderUpdates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        stopPolling();
        return;
      }
      
      // Get active orders
      final response = await ApiService.get('/orders?status=active', token: token);
      
      if (response['success']) {
        final orders = response['data'] as List<dynamic>;
        
        for (final orderData in orders) {
          final orderId = orderData['_id'] as String;
          final status = orderData['status'] as String;
          final lastUpdate = orderData['updatedAt'] as String;
          
          // Check if this is a new status update
          await _checkOrderStatusUpdate(orderId, status, lastUpdate);
        }
      }
    } catch (e) {
      print('❌ Error checking order updates: $e');
    }
  }
  
  // Check if order status has changed and show notification
  static Future<void> _checkOrderStatusUpdate(String orderId, String status, String lastUpdate) async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdateKey = 'last_order_update_$orderId';
    final lastKnownStatusKey = 'last_order_status_$orderId';
    
    final lastKnownUpdate = prefs.getString(lastUpdateKey);
    final lastKnownStatus = prefs.getString(lastKnownStatusKey);
    
    // If this is a new update or status has changed
    if (lastKnownUpdate != lastUpdate || lastKnownStatus != status) {
      // Save the new update info
      await prefs.setString(lastUpdateKey, lastUpdate);
      await prefs.setString(lastKnownStatusKey, status);
      
      // Show notification if status changed
      if (lastKnownStatus != null && lastKnownStatus != status) {
        await _showStatusChangeNotification(orderId, status);
      }
    }
  }
  
  // Show notification for status change
  static Future<void> _showStatusChangeNotification(String orderId, String status) async {
    // Check if order notifications are enabled
    final orderNotificationsEnabled = await NotificationService.areOrderNotificationsEnabled();
    if (!orderNotificationsEnabled) return;
    
    switch (status.toLowerCase()) {
      case 'delivered':
        await NotificationService.showOrderCompleted(orderId);
        break;
      case 'cancelled':
        await NotificationService.showOrderCancelled(orderId, 'Order was cancelled');
        break;
      case 'rejected':
        await NotificationService.showOrderRejected(orderId, 'Order was rejected');
        break;
      case 'on_the_way':
        // Get ETA if available
        try {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          if (token != null) {
            final orderResponse = await ApiService.get('/orders/$orderId', token: token);
            if (orderResponse['success']) {
              final orderData = orderResponse['data'];
              final eta = orderData['estimatedDeliveryTime'];
              if (eta != null) {
                await NotificationService.showDeliveryETA(orderId, eta.toString());
                return;
              }
            }
          }
        } catch (e) {
          print('❌ Error getting ETA: $e');
        }
        // Fallback to regular notification
        await NotificationService.showOrderStatusNotification(
          orderId: orderId,
          status: status,
        );
        break;
      default:
        await NotificationService.showOrderStatusNotification(
          orderId: orderId,
          status: status,
        );
    }
  }
  
  // Manually check for updates (useful when app comes to foreground)
  static Future<void> checkForUpdates() async {
    await _checkOrderUpdates();
  }
  
  // Clear stored order update data
  static Future<void> clearStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    for (final key in keys) {
      if (key.startsWith('last_order_update_') || key.startsWith('last_order_status_')) {
        await prefs.remove(key);
      }
    }
  }
} 