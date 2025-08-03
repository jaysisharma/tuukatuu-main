// models.dart

import 'package:flutter/material.dart';

enum OrderStatus {
  inProgress('In Progress', Colors.blue),
  delivered('Delivered', Colors.green),
  cancelled('Cancelled', Colors.red);

  const OrderStatus(this.label, this.color);
  final String label;
  final Color color;
}

class OrderItem {
  final String name;
  final int quantity;
  final double price;
  final IconData icon;

  OrderItem({ required this.name, required this.quantity, required this.price, required this.icon });
  double get totalPrice => price * quantity;
}

class Order {
  final String id;
  final String storeName;
  final String storeCategory;
  final IconData storeIcon;
  final DateTime orderDate;
  final OrderStatus status;
  final List<OrderItem> items;
  final double deliveryFee;
  final double taxes;
  // --- NEW PROPERTIES ---
  final String deliveryPartnerName;
  final String deliveryPartnerPhone;

  Order({
    required this.id,
    required this.storeName,
    required this.storeCategory,
    required this.storeIcon,
    required this.orderDate,
    required this.status,
    required this.items,
    this.deliveryFee = 30.0,
    this.taxes = 18.5,
    // --- NEW PROPERTIES ---
    required this.deliveryPartnerName,
    required this.deliveryPartnerPhone,
  });

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  double get itemTotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get grandTotal => itemTotal + deliveryFee + taxes;
}