import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  // Notification channels
  static const String orderStatusChannelId = 'order_status_channel';
  static const String orderStatusChannelName = 'Order Status Updates';
  static const String orderStatusChannelDescription = 'Notifications for order status changes';

  static const String generalChannelId = 'general_channel';
  static const String generalChannelName = 'General Notifications';
  static const String generalChannelDescription = 'General app notifications';

  // Initialize notification service
  static Future<void> initialize() async {
    print('🔧 Initializing notification service...');
    
    if (_isInitialized) {
      print('✅ Notifications already initialized');
      return;
    }

    try {
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      print('📱 Setting up notification initialization...');
      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      print('✅ Notification initialization completed');

      // Create notification channels for Android
      print('📱 Creating notification channels...');
      await _createNotificationChannels();
      print('✅ Notification channels created');

      // Request permissions for iOS
      print('📱 Requesting iOS permissions...');
      await _requestPermissions();
      print('✅ iOS permissions requested');

      _isInitialized = true;
      print('🎉 Notification service fully initialized');
    } catch (e) {
      print('❌ Error initializing notification service: $e');
      rethrow;
    }
  }

  static Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel orderStatusChannel = AndroidNotificationChannel(
      orderStatusChannelId,
      orderStatusChannelName,
      description: orderStatusChannelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    const AndroidNotificationChannel generalChannel = AndroidNotificationChannel(
      generalChannelId,
      generalChannelName,
      description: generalChannelDescription,
      importance: Importance.low,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(orderStatusChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(generalChannel);
  }

  static Future<void> _requestPermissions() async {
    print('📱 Requesting iOS notification permissions...');
    try {
      final iOSImplementation = _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      
      if (iOSImplementation != null) {
        final result = await iOSImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        print('📱 iOS permission result: $result');
      } else {
        print('⚠️ iOS implementation not available');
      }
    } catch (e) {
      print('❌ Error requesting iOS permissions: $e');
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
    // You can navigate to specific screens based on the notification type
  }

  // Show order status notification
  static Future<void> showOrderStatusNotification({
    required String orderId,
    required String status,
    String? message,
    String? eta,
    bool isPersistent = false,
  }) async {
    print('🔔 Attempting to show order status notification...');
    print('📋 Order ID: $orderId');
    print('📋 Status: $status');
    print('📋 Message: $message');
    print('📋 ETA: $eta');
    
    if (!_isInitialized) {
      print('⚠️ Notifications not initialized, initializing now...');
      await initialize();
    }

    final String title = _getOrderStatusTitle(status);
    final String body = message ?? _getOrderStatusMessage(status, eta);
    
    print('📋 Title: $title');
    print('📋 Body: $body');

    try {
      await _notifications.show(
        _generateOrderNotificationId(orderId),
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            orderStatusChannelId,
            orderStatusChannelName,
            channelDescription: orderStatusChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            ongoing: isPersistent,
            onlyAlertOnce: true,
            showWhen: true,
            enableVibration: true,
            playSound: true,
            icon: '@mipmap/ic_launcher',
            color: _getStatusColor(status),
            category: AndroidNotificationCategory.status,
            actions: [
              const AndroidNotificationAction('view_order', 'View Order'),
              const AndroidNotificationAction('dismiss', 'Dismiss'),
            ],
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            categoryIdentifier: 'order_status',
          ),
        ),
        payload: 'order_status:$orderId',
      );
      print('✅ Order status notification sent successfully');
    } catch (e) {
      print('❌ Error sending order status notification: $e');
      rethrow;
    }
  }

  // Show general notification
  static Future<void> showGeneralNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    print('🔔 Attempting to show general notification...');
    print('📋 Title: $title');
    print('📋 Body: $body');
    print('📋 Payload: $payload');
    
    if (!_isInitialized) {
      print('⚠️ Notifications not initialized, initializing now...');
      await initialize();
    }

    try {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            generalChannelId,
            generalChannelName,
            channelDescription: generalChannelDescription,
            importance: Importance.low,
            priority: Priority.low,
            showWhen: true,
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload,
      );
      print('✅ General notification sent successfully');
    } catch (e) {
      print('❌ Error sending general notification: $e');
      rethrow;
    }
  }

  // Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Cancel order status notifications
  static Future<void> cancelOrderNotifications(String orderId) async {
    // Cancel the specific order notification
    await _notifications.cancel(_generateOrderNotificationId(orderId));
  }

  // Generate unique notification ID for orders
  static int _generateOrderNotificationId(String orderId) {
    // Use a hash of the order ID to generate a consistent notification ID
    return orderId.hashCode;
  }

  // Get order status title
  static String _getOrderStatusTitle(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return 'Order Accepted! 🎉';
      case 'preparing':
        return 'Order Being Prepared 👨‍🍳';
      case 'ready_for_pickup':
        return 'Order Ready for Pickup 📦';
      case 'picked_up':
        return 'Order Picked Up 🚚';
      case 'on_the_way':
        return 'Order On The Way 🚀';
      case 'delivered':
        return 'Order Delivered! ✅';
      case 'cancelled':
        return 'Order Cancelled ❌';
      case 'rejected':
        return 'Order Rejected ❌';
      default:
        return 'Order Update 📱';
    }
  }

  // Get order status message
  static String _getOrderStatusMessage(String status, String? eta) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return 'Your order has been accepted and is being prepared.';
      case 'preparing':
        return 'Your order is being prepared by the restaurant.';
      case 'ready_for_pickup':
        return 'Your order is ready and waiting for pickup.';
      case 'picked_up':
        return 'Your order has been picked up and is on its way.';
      case 'on_the_way':
        if (eta != null && eta.isNotEmpty) {
          return 'Your order is on the way! Estimated arrival: $eta';
        }
        return 'Your order is on the way to you!';
      case 'delivered':
        return 'Your order has been delivered. Enjoy your meal!';
      case 'cancelled':
        return 'Your order has been cancelled.';
      case 'rejected':
        return 'Your order has been rejected by the restaurant.';
      default:
        return 'Your order status has been updated.';
    }
  }

  // Get status color for Android notifications
  static Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'preparing':
      case 'ready_for_pickup':
        return Colors.orange;
      case 'picked_up':
      case 'on_the_way':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
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

  // Enable/disable notifications
  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
  }

  // Show delivery ETA notification
  static Future<void> showDeliveryETA(String orderId, String eta) async {
    await showOrderStatusNotification(
      orderId: orderId,
      status: 'on_the_way',
      eta: eta,
      isPersistent: true,
    );
  }

  // Show order completion notification
  static Future<void> showOrderCompleted(String orderId) async {
    await showOrderStatusNotification(
      orderId: orderId,
      status: 'delivered',
      message: 'Your order has been delivered successfully! Enjoy your meal! 🍽️',
    );
  }

  // Show order cancellation notification
  static Future<void> showOrderCancelled(String orderId, String reason) async {
    await showOrderStatusNotification(
      orderId: orderId,
      status: 'cancelled',
      message: 'Your order has been cancelled. Reason: $reason',
    );
  }

  // Show order rejection notification
  static Future<void> showOrderRejected(String orderId, String reason) async {
    await showOrderStatusNotification(
      orderId: orderId,
      status: 'rejected',
      message: 'Your order has been rejected. Reason: $reason',
    );
  }
} 