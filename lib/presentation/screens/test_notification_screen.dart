import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/notification_service.dart';
import '../../utils/test_notifications.dart';

class TestNotificationScreen extends StatefulWidget {
  const TestNotificationScreen({super.key});

  @override
  State<TestNotificationScreen> createState() => _TestNotificationScreenState();
}

class _TestNotificationScreenState extends State<TestNotificationScreen> {
  bool _isLoading = false;
  String _lastResult = '';

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await NotificationService.initialize();
      setState(() {
        _lastResult = '✅ Notifications initialized successfully';
      });
    } catch (e) {
      setState(() {
        _lastResult = '❌ Error initializing notifications: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testSimpleNotification() async {
    setState(() {
      _isLoading = true;
      _lastResult = 'Sending simple notification...';
    });

    try {
      await NotificationService.showGeneralNotification(
        title: 'Test Notification',
        body: 'This is a simple test notification from TuukaTuu!',
      );
      setState(() {
        _lastResult = '✅ Simple notification sent successfully';
      });
    } catch (e) {
      setState(() {
        _lastResult = '❌ Error sending notification: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testOrderNotification() async {
    setState(() {
      _isLoading = true;
      _lastResult = 'Sending order notification...';
    });

    try {
      await NotificationService.showOrderStatusNotification(
        orderId: 'test_order_123',
        status: 'accepted',
        message: 'Your order has been accepted!',
      );
      setState(() {
        _lastResult = '✅ Order notification sent successfully';
      });
    } catch (e) {
      setState(() {
        _lastResult = '❌ Error sending order notification: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testAllNotifications() async {
    setState(() {
      _isLoading = true;
      _lastResult = 'Testing all notification types...';
    });

    try {
      await TestNotifications.testAllNotifications();
      setState(() {
        _lastResult = '✅ All test notifications sent successfully';
      });
    } catch (e) {
      setState(() {
        _lastResult = '❌ Error testing notifications: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkNotificationSettings() async {
    setState(() {
      _isLoading = true;
      _lastResult = 'Checking notification settings...';
    });

    try {
      final orderEnabled = await NotificationService.areOrderNotificationsEnabled();
      final generalEnabled = await NotificationService.areGeneralNotificationsEnabled();
      final allEnabled = await NotificationService.areNotificationsEnabled();
      
      setState(() {
        _lastResult = '📊 Notification Settings:\n'
            '• All Notifications: ${allEnabled ? "✅ Enabled" : "❌ Disabled"}\n'
            '• Order Notifications: ${orderEnabled ? "✅ Enabled" : "❌ Disabled"}\n'
            '• General Notifications: ${generalEnabled ? "✅ Enabled" : "❌ Disabled"}';
      });
    } catch (e) {
      setState(() {
        _lastResult = '❌ Error checking settings: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearAllNotifications() async {
    setState(() {
      _isLoading = true;
      _lastResult = 'Clearing all notifications...';
    });

    try {
      await NotificationService.cancelAllNotifications();
      setState(() {
        _lastResult = '✅ All notifications cleared successfully';
      });
    } catch (e) {
      setState(() {
        _lastResult = '❌ Error clearing notifications: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Test Notifications',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'iOS Simulator Notice',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'iOS Simulators have limited notification support. Notifications may not appear in the notification center, but the system should still work. Try testing on a physical device for full functionality.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Test Buttons
            _buildTestButton(
              title: 'Initialize Notifications',
              subtitle: 'Set up notification channels and permissions',
              icon: Icons.settings,
              onTap: _initializeNotifications,
              color: Colors.blue,
            ),
            
            const SizedBox(height: 12),
            
            _buildTestButton(
              title: 'Check Settings',
              subtitle: 'View current notification preferences',
              icon: Icons.settings_applications,
              onTap: _checkNotificationSettings,
              color: Colors.green,
            ),
            
            const SizedBox(height: 12),
            
            _buildTestButton(
              title: 'Test Simple Notification',
              subtitle: 'Send a basic notification',
              icon: Icons.notifications,
              onTap: _testSimpleNotification,
              color: Colors.orange,
            ),
            
            const SizedBox(height: 12),
            
            _buildTestButton(
              title: 'Test Order Notification',
              subtitle: 'Send an order status notification',
              icon: Icons.shopping_bag,
              onTap: _testOrderNotification,
              color: Colors.purple,
            ),
            
            const SizedBox(height: 12),
            
            _buildTestButton(
              title: 'Test All Notifications',
              subtitle: 'Send all notification types with delays',
              icon: Icons.playlist_play,
              onTap: _testAllNotifications,
              color: Colors.red,
            ),
            
            const SizedBox(height: 12),
            
            _buildTestButton(
              title: 'Clear All Notifications',
              subtitle: 'Remove all active notifications',
              icon: Icons.clear_all,
              onTap: _clearAllNotifications,
              color: Colors.grey,
            ),
            
            const SizedBox(height: 24),
            
            // Result Display
            if (_lastResult.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _lastResult.startsWith('✅') 
                              ? Icons.check_circle 
                              : _lastResult.startsWith('❌') 
                                  ? Icons.error 
                                  : Icons.info_outline,
                          color: _lastResult.startsWith('✅') 
                              ? Colors.green 
                              : _lastResult.startsWith('❌') 
                                  ? Colors.red 
                                  : Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Last Result',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lastResult,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Loading Indicator
            if (_isLoading)
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 8),
                    Text(
                      'Processing...',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 