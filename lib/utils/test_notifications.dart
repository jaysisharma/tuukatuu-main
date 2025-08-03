import '../services/notification_service.dart';

class TestNotifications {
  // Test all notification types
  static Future<void> testAllNotifications() async {
    print('🧪 Testing all notification types...');
    
    // Test order status notifications
    await NotificationService.showOrderStatusNotification(
      orderId: 'test_order_123',
      status: 'accepted',
      message: 'Your order has been accepted and is being prepared!',
    );
    
    await Future.delayed(const Duration(seconds: 2));
    
    await NotificationService.showOrderStatusNotification(
      orderId: 'test_order_123',
      status: 'preparing',
      message: 'Your order is being prepared by the restaurant.',
    );
    
    await Future.delayed(const Duration(seconds: 2));
    
    await NotificationService.showOrderStatusNotification(
      orderId: 'test_order_123',
      status: 'ready_for_pickup',
      message: 'Your order is ready and waiting for pickup!',
    );
    
    await Future.delayed(const Duration(seconds: 2));
    
    await NotificationService.showOrderStatusNotification(
      orderId: 'test_order_123',
      status: 'picked_up',
      message: 'Your order has been picked up and is on its way!',
    );
    
    await Future.delayed(const Duration(seconds: 2));
    
    await NotificationService.showDeliveryETA(
      'test_order_123',
      '15 minutes',
    );
    
    await Future.delayed(const Duration(seconds: 2));
    
    await NotificationService.showOrderCompleted('test_order_123');
    
    print('✅ All test notifications sent!');
  }
  
  // Test specific notification type
  static Future<void> testNotificationType(String type) async {
    print('🧪 Testing $type notification...');
    
    switch (type.toLowerCase()) {
      case 'accepted':
        await NotificationService.showOrderStatusNotification(
          orderId: 'test_order_123',
          status: 'accepted',
        );
        break;
      case 'preparing':
        await NotificationService.showOrderStatusNotification(
          orderId: 'test_order_123',
          status: 'preparing',
        );
        break;
      case 'ready':
        await NotificationService.showOrderStatusNotification(
          orderId: 'test_order_123',
          status: 'ready_for_pickup',
        );
        break;
      case 'picked':
        await NotificationService.showOrderStatusNotification(
          orderId: 'test_order_123',
          status: 'picked_up',
        );
        break;
      case 'delivery':
        await NotificationService.showDeliveryETA(
          'test_order_123',
          '10 minutes',
        );
        break;
      case 'delivered':
        await NotificationService.showOrderCompleted('test_order_123');
        break;
      case 'cancelled':
        await NotificationService.showOrderCancelled(
          'test_order_123',
          'Restaurant was too busy',
        );
        break;
      case 'rejected':
        await NotificationService.showOrderRejected(
          'test_order_123',
          'Item out of stock',
        );
        break;
      case 'general':
        await NotificationService.showGeneralNotification(
          title: 'Test General Notification',
          body: 'This is a test general notification.',
        );
        break;
      default:
        print('❌ Unknown notification type: $type');
        return;
    }
    
    print('✅ $type notification sent!');
  }
  
  // Cancel all test notifications
  static Future<void> cancelAllTestNotifications() async {
    print('🧹 Cancelling all test notifications...');
    await NotificationService.cancelAllNotifications();
    print('✅ All notifications cancelled!');
  }
} 