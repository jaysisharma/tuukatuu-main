// order_history_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tuukatuu/presentation/screens/rough_location.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/api_service.dart';
import 'order_tracking.dart';
import 'order_detail_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  int _selectedTabIndex = 0;
  String _searchQuery = '';
  String _selectedDateFilter = 'all';
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _filteredOrders = [];

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Filter options
  final List<String> _statusFilters = ['All', 'Pending', 'Accepted', 'Preparing', 'Ready for Pickup', 'Picked Up', 'On the Way', 'Delivered', 'Cancelled'];
  final List<String> _dateFilters = ['all', 'today', 'week', 'month', 'year'];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    if (!_isRefreshing) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await ApiService.get('/orders/customer/my', token: authProvider.jwtToken);
      
      setState(() {
        _orders = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
        _isRefreshing = false;
      });
      
      _applyFilters();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  Future<void> _refreshOrders() async {
    setState(() => _isRefreshing = true);
    await _fetchOrders();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
    _applyFilters();
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = _orders;

    // Apply status filter
    if (_selectedTabIndex > 0) {
      final status = _statusFilters[_selectedTabIndex].toLowerCase().replaceAll(' ', '_');
      filtered = filtered.where((order) => order['status'] == status).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((order) {
        final orderId = order['_id'].toString().toLowerCase();
        final vendorName = (order['vendorId']?['storeName'] ?? '').toLowerCase();
        final items = (order['items'] as List).map((item) => item['name'].toString().toLowerCase()).join(' ');
        
        return orderId.contains(_searchQuery.toLowerCase()) ||
               vendorName.contains(_searchQuery.toLowerCase()) ||
               items.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply date filter
    if (_selectedDateFilter != 'all') {
      final now = DateTime.now();
      DateTime startDate;
      
      switch (_selectedDateFilter) {
        case 'today':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'week':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          break;
        case 'month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'year':
          startDate = DateTime(now.year, 1, 1);
          break;
        default:
          startDate = DateTime(1900);
      }
      
      filtered = filtered.where((order) {
        final orderDate = DateTime.parse(order['createdAt']);
        return orderDate.isAfter(startDate);
      }).toList();
    }

    setState(() {
      _filteredOrders = filtered;
    });
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending': return 'Pending';
      case 'accepted': return 'Accepted';
      case 'preparing': return 'Preparing';
      case 'ready_for_pickup': return 'Ready for Pickup';
      case 'picked_up': return 'Picked Up';
      case 'on_the_way': return 'On the Way';
      case 'delivered': return 'Delivered';
      case 'cancelled': return 'Cancelled';
      case 'rejected': return 'Rejected';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'accepted': return Colors.blue;
      case 'preparing': return Colors.amber;
      case 'ready_for_pickup': return Colors.purple;
      case 'picked_up': return Colors.indigo;
      case 'on_the_way': return Colors.green;
      case 'delivered': return Colors.teal;
      case 'cancelled': return Colors.red;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.schedule;
      case 'accepted': return Icons.check_circle_outline;
      case 'preparing': return Icons.restaurant;
      case 'ready_for_pickup': return Icons.store;
      case 'picked_up': return Icons.local_shipping;
      case 'on_the_way': return Icons.directions_bike;
      case 'delivered': return Icons.done_all;
      case 'cancelled': return Icons.cancel;
      case 'rejected': return Icons.block;
      default: return Icons.info;
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today at ${DateFormat('h:mm a').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${DateFormat('h:mm a').format(date)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE at h:mm a').format(date);
    } else {
      return DateFormat('MMM d, yyyy at h:mm a').format(date);
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '₹0';
    final numValue = amount is int ? amount.toDouble() : (amount is double ? amount : 0.0);
    return '₹${numValue.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Order History"),
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search orders, stores, items...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Date Filter
                Row(
                  children: [
                    const Text('Filter by:', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _dateFilters.map((filter) {
                            final isSelected = _selectedDateFilter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(filter.capitalize()),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedDateFilter = filter;
                                  });
                                  _applyFilters();
                                },
                                backgroundColor: Colors.grey[100],
                                selectedColor: Colors.orange[100],
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.orange[900] : Colors.grey[700],
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Status Tabs
                _buildStatusTabs(),
              ],
            ),
          ),
          
          // Orders List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorWidget()
                    : _filteredOrders.isEmpty
                        ? _buildEmptyWidget()
                        : RefreshIndicator(
                            onRefresh: _refreshOrders,
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredOrders.length,
                              itemBuilder: (context, index) {
                                final order = _filteredOrders[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildOrderCard(order),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _statusFilters.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTabIndex == index;
          final status = _statusFilters[index];
          final count = index == 0 
              ? _orders.length 
              : _orders.where((order) => order['status'] == status.toLowerCase().replaceAll(' ', '_')).length;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTabIndex = index;
              });
              _applyFilters();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ] : null,
              ),
              child: Text(
                '$status ($count)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.black : Colors.grey[700],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] as String;
    final statusLabel = _getStatusLabel(status);
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final orderDate = _formatDate(order['createdAt']);
    final total = _formatCurrency(order['total'].toDouble());
    final itemCount = (order['items'] as List).length;
    final vendorName = order['vendorId']?['storeName'] ?? 'Unknown Store';
    final orderId = order['_id'].toString().substring(0, 8).toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailScreen(order: order),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(statusIcon, color: statusColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vendorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            orderDate,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          constraints: const BoxConstraints(maxWidth: 120),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          total,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Items Preview
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...(order['items'] as List).take(3).map((item) => Container(
                          constraints: const BoxConstraints(maxWidth: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${item['name'] ?? 'Unknown Item'} x${item['quantity'] ?? 1}',
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        )),
                        if ((order['items'] as List).length > 3)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '+${(order['items'] as List).length - 3} more',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$itemCount items',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        if (order['orderType'] == 'tmart')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.orange.withOpacity(0.3)),
                            ),
                            child: Text(
                              'T-Mart',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Order ID
                Text(
                  'Order #$orderId',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Action Buttons
                _buildActionButtons(order),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> order) {
    final status = order['status'] as String;
    
    switch (status) {
      case 'delivered':
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _reorder(order),
                    icon: const Icon(Icons.replay, size: 16),
                    label: const Text('Reorder'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rateOrder(order),
                    icon: const Icon(Icons.star_border, size: 16),
                    label: const Text('Rate'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _contactSupport(order),
                    icon: const Icon(Icons.headphones_outlined, size: 16),
                    label: const Text('Contact Support'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
        
      case 'on_the_way':
      case 'picked_up':
      case 'ready_for_pickup':
      case 'preparing':
      case 'accepted':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _trackOrder(order),
                icon: const Icon(Icons.location_on_outlined, size: 16),
                label: const Text('Track Order'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => _contactSupport(order),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Icon(Icons.headphones_outlined, size: 20),
            ),
          ],
        );
        
      case 'cancelled':
      case 'rejected':
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _reorder(order),
                icon: const Icon(Icons.replay, size: 16),
                label: const Text('Reorder'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => _contactSupport(order),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Icon(Icons.headphones_outlined, size: 20),
            ),
          ],
        );
        
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unable to load orders',
            style: TextStyle(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchOrders,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No orders found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search terms',
            style: TextStyle(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Action Methods
  void _trackOrder(Map<String, dynamic> order) {
  debugPrint('Navigating to OrderTracking with order details:');
  debugPrint(order.toString()); // Safely prints the entire order map

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => OrderTracking(
        order: order, // pass the whole order to OrderTracking
      ),
    ),
  );
}


  void _reorder(Map<String, dynamic> order) {
    // TODO: Implement reorder functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reorder functionality coming soon!')),
    );
  }

  void _rateOrder(Map<String, dynamic> order) {
    // TODO: Implement rating functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rating functionality coming soon!')),
    );
  }

  void _contactSupport(Map<String, dynamic> order) {
    // TODO: Implement support contact
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Support contact coming soon!')),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}