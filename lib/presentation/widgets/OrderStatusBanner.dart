import 'package:flutter/material.dart';

class OrderStatusBanner extends StatelessWidget {
  final Map<String, dynamic> order;
  const OrderStatusBanner({required this.order});

  @override
  Widget build(BuildContext context) {
    final status = (order['status'] ?? '').toString();
    if (status == 'pending' || status == 'delivered' || status == 'cancelled') {
      return SizedBox.shrink();
    }
    final eta = order['eta']?.toString();
    return MaterialBanner(
      backgroundColor: Colors.orange[50],
      content: Row(
        children: [
          Icon(Icons.delivery_dining, color: Colors.orange),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order ${_capitalize(status)}', style: TextStyle(fontWeight: FontWeight.bold)),
                if (eta != null && eta.isNotEmpty)
                  Text('Arrives in $eta mins', style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/order-details', arguments: order['id'] ?? order['_id']);
            },
            child: Text('View'),
          ),
        ],
      ),
      actions: [],
    );
  }

  String _capitalize(String s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;
}