// order_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final orderId = order['_id'].toString().substring(0, 8).toUpperCase();
    final status = order['status'] as String;
    final statusLabel = _getStatusLabel(status);
    final statusColor = _getStatusColor(status);
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            const Text('Order Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Order #$orderId', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStoreInfoCard(),
            const SizedBox(height: 16),
            _buildOrderStatusCard(statusLabel, statusColor),
            const SizedBox(height: 16),
            _buildItemsOrderedCard(),
            const SizedBox(height: 16),
            _buildBillDetailsCard(),
            const SizedBox(height: 16),
            _buildDeliveryPartnerCard(),
            const SizedBox(height: 16),
            _buildDeliveryAddressCard(),
          ],
        ),
      ),
    );
  }
  
  // Helper methods for status
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

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat("MMMM d, yyyy • h:mm a").format(date);
  }

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }
  
  // --- WIDGET BUILDERS ---

  Widget _buildCard({required Widget child, EdgeInsets padding = const EdgeInsets.all(16.0)}) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStoreInfoCard() {
    final vendorName = order['vendorId']?['storeName'] ?? 'Unknown Store';
    final orderDate = _formatDate(order['createdAt']);
    
    return _buildCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.store, color: Colors.black54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vendorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  orderDate,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusCard(String statusLabel, Color statusColor) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: statusColor, size: 20),
              const SizedBox(width: 8),
              const Text('Order Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsOrderedCard() {
    final items = order['items'] as List;
    
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_bag_outlined, color: Colors.black54, size: 20),
              const SizedBox(width: 8),
              const Text('Items Ordered', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: item['image'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item['image'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: Colors.grey),
                          ),
                        )
                      : const Icon(Icons.image, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'] ?? 'Unknown Item',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Qty: ${item['quantity']}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatCurrency((item['price'] ?? 0).toDouble()),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildBillDetailsCard() {
    final itemTotal = (order['itemTotal'] ?? 0).toDouble();
    final tax = (order['tax'] ?? 0).toDouble();
    final deliveryFee = (order['deliveryFee'] ?? 0).toDouble();
    final tip = (order['tip'] ?? 0).toDouble();
    final total = (order['total'] ?? 0).toDouble();
    
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_outlined, color: Colors.black54, size: 20),
              const SizedBox(width: 8),
              const Text('Bill Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          _buildBillRow('Item Total', _formatCurrency(itemTotal)),
          _buildBillRow('Tax', _formatCurrency(tax)),
          _buildBillRow('Delivery Fee', _formatCurrency(deliveryFee)),
          if (tip > 0) _buildBillRow('Tip', _formatCurrency(tip)),
          const Divider(),
          _buildBillRow('Total', _formatCurrency(total), isTotal: true),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryPartnerCard() {
    final rider = order['riderId'];
    
    if (rider == null) {
      return const SizedBox.shrink();
    }
    
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.delivery_dining_outlined, color: Colors.black54, size: 20),
              const SizedBox(width: 8),
              const Text('Delivery Partner', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(Icons.person, color: Colors.grey, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rider['profile']?['fullName'] ?? 'Unknown Rider',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rider['profile']?['phone'] ?? 'No phone',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Implement call functionality
                },
                icon: const Icon(Icons.phone, color: Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressCard() {
    final customerLocation = order['customerLocation'];
    
    if (customerLocation == null) {
      return const SizedBox.shrink();
    }
    
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.black54, size: 20),
              const SizedBox(width: 8),
              const Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            customerLocation['address'] ?? 'No address provided',
            style: const TextStyle(fontSize: 14),
          ),
          if (customerLocation['landmark'] != null) ...[
            const SizedBox(height: 4),
            Text(
              'Near: ${customerLocation['landmark']}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}