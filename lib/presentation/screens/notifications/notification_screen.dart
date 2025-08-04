import 'package:flutter/material.dart';
import 'package:tuukatuu/services/notification_service.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (!_isRefreshing) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final notifications = await NotificationService.fetchNotifications();
      
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load notifications: $e';
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      _isRefreshing = true;
    });
    await _loadNotifications();
  }

  Future<void> _markAsRead(Map<String, dynamic> notification) async {
    if (notification['isRead'] == true) return;

    try {
      final success = await NotificationService.markNotificationAsRead(notification['id']);
      if (success && mounted) {
        setState(() {
          final index = _notifications.indexWhere((n) => n['id'] == notification['id']);
          if (index != -1) {
            _notifications[index]['isRead'] = true;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark as read: $e')),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final success = await NotificationService.markAllNotificationsAsRead();
      if (success && mounted) {
        setState(() {
          for (var notification in _notifications) {
            notification['isRead'] = true;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications marked as read')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark all as read: $e')),
        );
      }
    }
  }

  Future<void> _deleteNotification(Map<String, dynamic> notification) async {
    try {
      final success = await NotificationService.deleteNotification(notification['id']);
      if (success && mounted) {
        setState(() {
          _notifications.removeWhere((n) => n['id'] == notification['id']);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete notification: $e')),
        );
      }
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification) async {
    // Mark as read first
    await _markAsRead(notification);

    // Navigate based on notification type
    final type = notification['type'];
    final additionalData = notification['additionalData'] ?? {};

    switch (type) {
      case 'order':
        // Navigate to order details
        if (additionalData['orderId'] != null) {
          // Navigator.pushNamed(context, AppRoutes.orderDetails, arguments: additionalData['orderId']);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navigate to order: ${additionalData['orderId']}')),
          );
        }
        break;
      case 'promotion':
        // Navigate to promotions with promo code
        if (additionalData['promoCode'] != null) {
          // Navigator.pushNamed(context, AppRoutes.promotions, arguments: additionalData['promoCode']);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navigate to promotion with code: ${additionalData['promoCode']}')),
          );
        }
        break;
      case 'store':
        // Navigate to store details
        if (additionalData['storeId'] != null) {
          // Navigator.pushNamed(context, AppRoutes.storeDetails, arguments: additionalData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navigate to store: ${additionalData['storeName'] ?? additionalData['storeId']}')),
          );
        }
        break;
      case 'payment':
        // Navigate to payment history or order details
        if (additionalData['orderId'] != null) {
          // Navigator.pushNamed(context, AppRoutes.orderDetails, arguments: additionalData['orderId']);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navigate to payment for order: ${additionalData['orderId']}')),
          );
        }
        break;
      case 'system':
        // Show system notification details
        _showSystemNotificationDetails(notification);
        break;
      default:
        // Show notification details
        _showNotificationDetails(notification);
        break;
    }
  }

  void _showSystemNotificationDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification['message']),
            const SizedBox(height: 16),
            Text(
              'Time: ${_formatDateTime(notification['createdAt'])}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showNotificationDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification['message']),
            const SizedBox(height: 16),
            Text(
              'Time: ${_formatDateTime(notification['createdAt'])}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return 'Unknown time';
    
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'order':
        return Icons.delivery_dining;
      case 'promotion':
        return Icons.local_offer;
      case 'payment':
        return Icons.payment;
      case 'store':
        return Icons.store;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'order':
        return Colors.green;
      case 'promotion':
        return Colors.orange;
      case 'payment':
        return Colors.blue;
      case 'store':
        return Colors.purple;
      case 'system':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          if (_notifications.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'mark_all_read':
                    _markAllAsRead();
                    break;
                  case 'clear_all':
                    _clearAllNotifications();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      Icon(Icons.mark_email_read),
                      SizedBox(width: 8),
                      Text('Mark all as read'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all),
                      SizedBox(width: 8),
                      Text('Clear all'),
                    ],
                  ),
                ),
              ],
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Icon(Icons.more_vert),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNotifications,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ll see notifications about your orders, promotions, and updates here.',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] == true;
    final type = notification['type'] ?? 'general';
    final title = notification['title'] ?? 'Notification';
    final message = notification['message'] ?? '';
    final createdAt = notification['createdAt'];

    return Dismissible(
      key: Key(notification['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleNotificationTap(notification),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getColorForType(type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconForType(type),
                      color: _getColorForType(type),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                                  color: isRead ? Colors.grey[600] : Colors.black,
                                ),
                              ),
                            ),
                            if (!isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatDateTime(createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to clear all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _notifications.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications cleared')),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
} 