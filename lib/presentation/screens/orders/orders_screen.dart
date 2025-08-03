import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tuukatuu/core/config/routes.dart';
import 'package:tuukatuu/providers/auth_provider.dart';
import '../../../services/api_service.dart';
import '../../widgets/cached_image.dart';

// Remove the local RouteObserver instance
// Use a global singleton instead
RouteObserver<PageRoute> globalRouteObserver = RouteObserver<PageRoute>();

// Move this function to the top level so it can be used in both widgets
Color _getStatusColor(String status) {
  switch (status) {
    case 'pending':
      return Colors.orange;
    case 'accepted':
      return Colors.blue;
    case 'preparing':
      return Colors.amber;
    case 'on_the_way':
      return Colors.green;
    case 'delivered':
      return Colors.teal;
    case 'cancelled':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  OrdersScreenState createState() => OrdersScreenState();
}

class OrdersScreenState extends State<OrdersScreen> with RouteAware {
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;
  String? _error;

  // Expose a public method for refreshing orders
  void refreshOrders() {
    _fetchOrders();
  }

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    globalRouteObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    globalRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when coming back to this screen
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.jwtToken;
      final data = await ApiService.get('/orders', token: token);
      setState(() {
        _orders = List<Map<String, dynamic>>.from(data);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _orderAgain(Map<String, dynamic> order) {
    // Add all items from the order to cart
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Items added to cart'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pushNamed(context, AppRoutes.cart);
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final items = (order['items'] as List?) ?? [];
    final itemCount = items.length;
    final displayedItems = items.take(2).toList();
    final remainingItems = itemCount - 2;

    String getItemName(dynamic item) {
      if (item == null) return '';
      if (item['name'] != null && item['name'] is String) return item['name'] as String;
      if (item['product'] is Map && item['product']['name'] != null) return item['product']['name'].toString();
      if (item['product'] != null && item['product'] is String) return item['product'].toString();
      return '';
    }

    String getItemImage(dynamic item) {
      if (item == null) return '';
      if (item['image'] != null && item['image'] is String) return item['image'] as String;
      if (item['product'] is Map && item['product']['image'] != null) return item['product']['image'].toString();
      return '';
    }

    String getItemsText() {
      final List<String> names = displayedItems.map((item) => getItemName(item)).toList();
      if (remainingItems > 0) {
        return names.join(", ") + ' + $remainingItems more';
      }
      return names.join(", ");
    }

    String status = (order['status'] ?? '').toString();
    String date = order['createdAt'] != null ? order['createdAt'].toString().substring(0, 10) : '';
    double total = order['total'] is int ? (order['total'] as int).toDouble() : (order['total'] ?? 0.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showOrderDetails(context, order),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Images
              Column(
                children: [
                  ...displayedItems.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: getItemImage(item).isNotEmpty
                          ? CachedImage(
                              imageUrl: getItemImage(item),
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 48,
                              height: 48,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported, color: Colors.grey),
                            ),
                    ),
                  )),
                  if (remainingItems > 0)
                    Container(
                      width: 48,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '+$remainingItems',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getItemsText(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[100] : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rs $total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getStatusColor(status).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                status,
                                style: TextStyle(
                                  color: _getStatusColor(status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          date,
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        // Track Order button for active orders
                        if (!['delivered', 'cancelled', 'rejected'].contains(status))
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.orderTracking,
                                arguments: {
                                  'orderId': order['_id'],
                                  'initialOrder': order,
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.track_changes,
                                    size: 14,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Track',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailScreen(order: order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black12 : Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    'My Orders',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  // Refresh button removed
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!))
                      : _orders.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No orders yet',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Start shopping to create orders',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: _orders.length,
                              itemBuilder: (context, index) => GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OrderDetailScreen(order: _orders[index]),
                                    ),
                                  );
                                },
                                child: _buildOrderCard(_orders[index]),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
} 

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  const OrderDetailScreen({super.key, required this.order});

  Widget _buildSummaryRow(String label, double amount, {bool isBold = false, String? description}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: isBold ? 16 : 14,
                ),
              ),
              if (description != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          Text(
            'Rs ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: isBold ? 16 : 14,
              color: isBold ? Colors.orange : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final items = (order['items'] as List?) ?? [];
    String status = (order['status'] ?? '').toString();
    String date = order['createdAt'] != null ? order['createdAt'].toString().substring(0, 10) : '';
    String address = (order['deliveryAddress'] ?? '').toString();
    double itemTotal = order['itemTotal'] is int ? (order['itemTotal'] as int).toDouble() : (order['itemTotal'] ?? 0.0);
    double tax = order['tax'] is int ? (order['tax'] as int).toDouble() : (order['tax'] ?? 0.0);
    double deliveryFee = order['deliveryFee'] is int ? (order['deliveryFee'] as int).toDouble() : (order['deliveryFee'] ?? 0.0);
    double tip = order['tip'] is int ? (order['tip'] as int).toDouble() : (order['tip'] ?? 0.0);
    double total = order['total'] is int ? (order['total'] as int).toDouble() : (order['total'] ?? 0.0);

    String getItemName(dynamic item) {
      if (item == null) return '';
      if (item['name'] != null && item['name'] is String) return item['name'] as String;
      if (item['product'] is Map && item['product']['name'] != null) return item['product']['name'].toString();
      if (item['product'] != null && item['product'] is String) return item['product'].toString();
      return '';
    }
    String getItemImage(dynamic item) {
      if (item == null) return '';
      if (item['image'] != null && item['image'] is String) return item['image'] as String;
      if (item['product'] is Map && item['product']['image'] != null) return item['product']['image'].toString();
      return '';
    }
    int getItemQuantity(dynamic item) {
      if (item == null) return 1;
      if (item['quantity'] != null && item['quantity'] is int) return item['quantity'];
      return 1;
    }
    double getItemPrice(dynamic item) {
      if (item == null) return 0.0;
      if (item['price'] != null && item['price'] is num) return (item['price'] as num).toDouble();
      return 0.0;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        leading: BackButton(),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order status and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt_long, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Order Status:',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(date, style: theme.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Expanded(child: Text(address, style: theme.textTheme.bodyMedium)),
              ],
            ),
            const SizedBox(height: 20),
            // Items
            Text('Items', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...items.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black.withOpacity(0.04) : Colors.grey.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: getItemImage(item).isNotEmpty
                        ? CachedImage(
                            imageUrl: getItemImage(item),
                            width: 54,
                            height: 54,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 54,
                            height: 54,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported, color: Colors.grey),
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(getItemName(item), style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Quantity: ${getItemQuantity(item)}', style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  Text('Rs ${(getItemPrice(item) * getItemQuantity(item)).toStringAsFixed(2)}', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            )),
            const SizedBox(height: 24),
            // Order summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black.withOpacity(0.03) : Colors.grey.withOpacity(0.07),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order Summary', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildSummaryRow('Item Total', itemTotal),
                  _buildSummaryRow('Tax (5%)', tax),
                  _buildSummaryRow('Delivery Fee', deliveryFee, description: deliveryFee == 0 ? 'Free delivery for orders above Rs 400' : 'Flat delivery charge'),
                  if (tip > 0) _buildSummaryRow('Tip', tip),
                  const Divider(),
                  _buildSummaryRow('Total', total, isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Track Order Button (for active orders)
            if (!['delivered', 'cancelled', 'rejected'].contains(status))
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.orderTracking,
                      arguments: {
                        'orderId': order['_id'],
                        'initialOrder': order,
                      },
                    );
                  },
                  icon: const Icon(Icons.track_changes),
                  label: const Text('Track Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            
            // Thank you message
            Center(
              child: Column(
                children: [
                  Icon(Icons.celebration, color: theme.colorScheme.primary, size: 36),
                  const SizedBox(height: 8),
                  Text('Thank you for your order!', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('We appreciate your business.', style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 