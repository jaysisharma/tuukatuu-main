// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter/material.dart';
// import '../main.dart';

// Future<void> showOrderStatusNotification(Map<String, dynamic> order) async {
//   final status = (order['status'] ?? '').toString();
//   if (status == 'pending' || status == 'delivered' || status == 'cancelled') {
//     await flutterLocalNotificationsPlugin.cancel(1001); // Remove notification
//     return;
//   }
//   final eta = order['eta']?.toString() ?? '';
//   await flutterLocalNotificationsPlugin.show(
//     1001, // Notification ID
//     'Order ${status[0].toUpperCase()}${status.substring(1)}',
//     eta.isNotEmpty ? 'Arrives in $eta mins' : 'Track your order status',
//     NotificationDetails(
//       android: AndroidNotificationDetails(
//         'order_status_channel',
//         'Order Status',
//         channelDescription: 'Live updates for your order status',
//         importance: Importance.max,
//         priority: Priority.high,
//         ongoing: true, // Makes it persistent
//         onlyAlertOnce: true,
//         showWhen: true,
//       ),
//       iOS: DarwinNotificationDetails(),
//     ),
//   );
// } 