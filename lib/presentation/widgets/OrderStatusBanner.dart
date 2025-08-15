import 'package:flutter/material.dart';

class OrderStatusBanner extends StatelessWidget {
  final Map<String, dynamic> order;
  const OrderStatusBanner({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final status = (order['status'] ?? '').toString();
    if (status == 'pending' || status == 'delivered' || status == 'cancelled') {
      return const SizedBox.shrink();
    }
    final eta = order['eta']?.toString();
    return MaterialBanner(
      backgroundColor: Colors.orange[50],
      content: Row(
        children: [
          const Icon(Icons.delivery_dining, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order ${_capitalize(status)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                if (eta != null && eta.isNotEmpty)
                  Text('Arrives in $eta mins', style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/order-details', arguments: order['id'] ?? order['_id']);
            },
            child: const Text('View'),
          ),
        ],
      ),
      actions: const [],
    );
  }

  String _capitalize(String s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;
}