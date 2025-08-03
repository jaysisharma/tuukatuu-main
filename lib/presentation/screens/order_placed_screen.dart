import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tuukatuu/main.dart';
import '../../providers/auth_provider.dart';
import '../../core/config/routes.dart';
import '../../utils/order_notifications.dart';

class OrderPlacedScreen extends StatefulWidget {
  final String orderId;
  const OrderPlacedScreen({super.key, required this.orderId});

  @override
  State<OrderPlacedScreen> createState() => _OrderPlacedScreenState();
}

class _OrderPlacedScreenState extends State<OrderPlacedScreen> {
  int _currentStep = 0;
  bool _loading = true;
  String? _error;
  Timer? _timer;
  String? _orderStatus;
  final List<String> _steps = [
    'pending',
    'accepted',
    'preparing',
    'on_the_way',
    'delivered',
  ];
  final List<String> _stepLabels = [
    'Order Received',
    'Accepted',
    'Preparing',
    'Out for Delivery',
    'Delivered',
  ];

  @override
  void initState() {
    super.initState();
    _fetchStatus();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _fetchStatus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final headers = <String, String>{};
      if (authProvider.jwtToken != null) {
        headers['Authorization'] = 'Bearer ${authProvider.jwtToken}';
      }
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/orders/${widget.orderId}'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final order = json.decode(response.body);
        _orderStatus = order['status'];
        final idx = _steps.indexOf(_orderStatus ?? 'pending');
        setState(() {
          _currentStep = idx >= 0 ? idx : 0;
          _loading = false;
        });
        // Show or update notification
        print('Order status: ${order['status']}');
        await showOrderStatusNotification(order);
      } else {
        setState(() {
          _error = 'Failed to fetch order status';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Order Placed'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.orange, size: 80),
                      const SizedBox(height: 16),
                      Text(
                        'Your order has been placed!',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Thank you for shopping with us. You can track your order status below.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      _buildStepper(theme),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        icon: const Icon(Icons.home_rounded),
                        label: const Text('Back to Home'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                          Future.delayed(const Duration(milliseconds: 100), () {
                            Navigator.of(context).pushNamed(AppRoutes.orders);
                          });
                        },
                        child: const Text('View My Orders'),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildStepper(ThemeData theme) {
    return Column(
      children: List.generate(_steps.length, (i) {
        final isActive = i <= _currentStep;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.orange : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isActive
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : Text('${i + 1}', style: TextStyle(color: Colors.grey[700])),
                  ),
                ),
                if (i < _steps.length - 1)
                  Container(
                    width: 4,
                    height: 36,
                    color: isActive ? Colors.orange : Colors.grey[300],
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Text(
              _stepLabels[i],
              style: theme.textTheme.titleMedium?.copyWith(
                color: isActive ? Colors.orange : Colors.grey[600],
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        );
      }),
    );
  }
} 