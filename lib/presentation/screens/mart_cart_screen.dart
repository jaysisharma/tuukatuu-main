import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuukatuu/providers/mart_cart_provider.dart';

class MartCartScreen extends StatelessWidget {
  const MartCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final martCartProvider = Provider.of<MartCartProvider>(context);
    final items = martCartProvider.items;
    final total = martCartProvider.totalAmount;
    return Scaffold(
      appBar: AppBar(
        title: const Text('T-Mart Cart'),
        backgroundColor: Colors.orange,
      ),
      body: items.isEmpty
          ? const Center(child: Text('Your T-Mart cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item['image'] ?? '',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text('Rs ${item['price']}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, color: Colors.orange),
                                onPressed: () {
                                  if (item['quantity'] > 1) {
                                    martCartProvider.updateQuantity(item['id'], item['quantity'] - 1);
                                  } else {
                                    martCartProvider.removeItem(item['id']);
                                  }
                                },
                              ),
                              Text('${item['quantity']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              IconButton(
                                icon: const Icon(Icons.add, color: Colors.orange),
                                onPressed: () {
                                  martCartProvider.updateQuantity(item['id'], item['quantity'] + 1);
                                },
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              martCartProvider.removeItem(item['id']);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          Text('Rs $total', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Implement checkout logic
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checkout not implemented')));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
} 