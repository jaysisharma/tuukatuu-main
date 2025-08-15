import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  static bool _isInitialized = false;
  static const String _baseUrl = 'https://api.tuukatuu.com'; // Replace with your actual API base URL

  // Initialize local notifications
  static Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to appropriate screen
    print('Notification tapped: ${response.payload}');
  }

  // Check if order notifications are enabled
  static Future<bool> areOrderNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('order_notifications_enabled') ?? true;
  }

  // Check if general notifications are enabled
  static Future<bool> areGeneralNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('general_notifications_enabled') ?? true;
  }

  // Check if all notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  // Show order completed notification
  static Future<void> showOrderCompleted(String orderId) async {
    if (!await areOrderNotificationsEnabled()) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'order_notifications',
      'Order Notifications',
      channelDescription: 'Notifications for order status updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      orderId.hashCode,
      'Order Delivered! 🎉',
      'Your order #$orderId has been successfully delivered.',
      platformChannelSpecifics,
      payload: json.encode({
        'type': 'order_completed',
        'orderId': orderId,
      }),
    );
  }

  // Show order cancelled notification
  static Future<void> showOrderCancelled(String orderId, String reason) async {
    if (!await areOrderNotificationsEnabled()) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'order_notifications',
      'Order Notifications',
      channelDescription: 'Notifications for order status updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      orderId.hashCode,
      'Order Cancelled',
      'Your order #$orderId has been cancelled. Reason: $reason',
      platformChannelSpecifics,
      payload: json.encode({
        'type': 'order_cancelled',
        'orderId': orderId,
        'reason': reason,
      }),
    );
  }

  // Show order rejected notification
  static Future<void> showOrderRejected(String orderId, String reason) async {
    if (!await areOrderNotificationsEnabled()) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'order_notifications',
      'Order Notifications',
      channelDescription: 'Notifications for order status updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      orderId.hashCode,
      'Order Rejected',
      'Your order #$orderId has been rejected. Reason: $reason',
      platformChannelSpecifics,
      payload: json.encode({
        'type': 'order_rejected',
        'orderId': orderId,
        'reason': reason,
      }),
    );
  }

  // Show order status notification
  static Future<void> showOrderStatusNotification({
    required String orderId,
    required String status,
    String? message,
  }) async {
    if (!await areOrderNotificationsEnabled()) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'order_notifications',
      'Order Notifications',
      channelDescription: 'Notifications for order status updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      orderId.hashCode,
      'Order Update',
      message ?? 'Your order #$orderId status: $status',
      platformChannelSpecifics,
      payload: json.encode({
        'type': 'order_status',
        'orderId': orderId,
        'status': status,
      }),
    );
  }

  // Show delivery ETA notification
  static Future<void> showDeliveryETA(String orderId, String eta) async {
    if (!await areOrderNotificationsEnabled()) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'order_notifications',
      'Order Notifications',
      channelDescription: 'Notifications for order status updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      orderId.hashCode,
      'Delivery Update',
      'Your order #$orderId will be delivered in $eta',
      platformChannelSpecifics,
      payload: json.encode({
        'type': 'delivery_eta',
        'orderId': orderId,
        'eta': eta,
      }),
    );
  }

  // Show general notification
  static Future<void> showGeneralNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!await areGeneralNotificationsEnabled()) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'general_notifications',
      'General Notifications',
      channelDescription: 'General app notifications',
      importance: Importance.none,
      priority: Priority.low,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // Fetch notifications from API
  static Future<List<Map<String, dynamic>>> fetchNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      // Return mock data for development
      return _getMockNotifications();
    }
  }

  // Mark notification as read
  static Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/notifications/$notificationId/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Mark all notifications as read
  static Future<bool> markAllNotificationsAsRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/notifications/read-all'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }

  // Delete notification
  static Future<bool> deleteNotification(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/notifications/$notificationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  // Get unread notification count
  static Future<int> getUnreadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      
      if (token == null) {
        return 0;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/notifications/unread-count'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['count'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error getting unread count: $e');
      return 3; // Mock count for development
    }
  }

  // Mock notifications for development
  static List<Map<String, dynamic>> _getMockNotifications() {
    return [
      {
        'id': '1',
        'title': 'Order Delivered! 🎉',
        'message': 'Your order #ORD123 has been successfully delivered.',
        'type': 'order',
        'isRead': false,
        'createdAt': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
        'additionalData': {
          'orderId': 'ORD123',
          'status': 'delivered',
        },
      },
      {
        'id': '2',
        'title': 'Special Offer! 🏷️',
        'message': 'Get 20% off on all groceries. Use code SAVE20',
        'type': 'promotion',
        'isRead': false,
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'additionalData': {
          'promoCode': 'SAVE20',
          'discount': 20,
        },
      },
      {
        'id': '3',
        'title': 'Payment Successful 💳',
        'message': 'Your payment of \$45.99 has been processed successfully.',
        'type': 'payment',
        'isRead': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'additionalData': {
          'amount': 45.99,
          'orderId': 'ORD122',
        },
      },
      {
        'id': '4',
        'title': 'New Store Available 🏪',
        'message': 'Fresh Grocery Store is now available in your area!',
        'type': 'store',
        'isRead': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'additionalData': {
          'storeId': 'store_123',
          'storeName': 'Fresh Grocery Store',
        },
      },
      {
        'id': '5',
        'title': 'System Maintenance ⚙️',
        'message': 'We will be performing maintenance on Sunday from 2-4 AM.',
        'type': 'system',
        'isRead': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'additionalData': {
          'maintenanceTime': 'Sunday 2-4 AM',
        },
      },
    ];
  }
}