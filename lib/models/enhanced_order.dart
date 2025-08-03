import 'package:flutter/material.dart';

enum OrderStatus {
  pending('Pending', Colors.orange),
  confirmed('Confirmed', Colors.blue),
  preparing('Preparing', Colors.purple),
  outForDelivery('Out for Delivery', Colors.indigo),
  delivered('Delivered', Colors.green),
  cancelled('Cancelled', Colors.red),
  failed('Failed', Colors.red);

  const OrderStatus(this.label, this.color);
  final String label;
  final Color color;
}

class OrderItem {
  final String id;
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final String? imageUrl;
  final String? notes;
  final Map<String, dynamic>? productDetails;

  OrderItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    this.imageUrl,
    this.notes,
    this.productDetails,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['_id'] ?? json['id'] ?? '',
      productId: json['product'] ?? json['productId'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'],
      notes: json['notes'],
      productDetails: json['productDetails'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
      'notes': notes,
      'productDetails': productDetails,
    };
  }

  double get totalPrice => price * quantity;
}

class EnhancedOrder {
  final String id;
  final String userId;
  final String vendorId;
  final String vendorName;
  final String? vendorImage;
  final List<OrderItem> items;
  final double itemTotal;
  final double tax;
  final double deliveryFee;
  final double tip;
  final double total;
  final OrderStatus status;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final String? deliveryAddress;
  final Map<String, dynamic>? customerLocation;
  final String? instructions;
  final String paymentMethod;
  final String? paymentStatus;
  final String? riderId;
  final String? riderName;
  final String? riderPhone;
  final Map<String, dynamic>? trackingInfo;
  final List<Map<String, dynamic>>? statusHistory;

  EnhancedOrder({
    required this.id,
    required this.userId,
    required this.vendorId,
    required this.vendorName,
    this.vendorImage,
    required this.items,
    required this.itemTotal,
    required this.tax,
    required this.deliveryFee,
    required this.tip,
    required this.total,
    required this.status,
    required this.orderDate,
    this.deliveryDate,
    this.deliveryAddress,
    this.customerLocation,
    this.instructions,
    required this.paymentMethod,
    this.paymentStatus,
    this.riderId,
    this.riderName,
    this.riderPhone,
    this.trackingInfo,
    this.statusHistory,
  });

  factory EnhancedOrder.fromJson(Map<String, dynamic> json) {
    return EnhancedOrder(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      vendorId: json['vendorId'] ?? '',
      vendorName: json['vendorName'] ?? '',
      vendorImage: json['vendorImage'],
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      itemTotal: (json['itemTotal'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      tip: (json['tip'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      status: _parseOrderStatus(json['status']),
      orderDate: DateTime.tryParse(json['orderDate'] ?? '') ?? DateTime.now(),
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.tryParse(json['deliveryDate'])
          : null,
      deliveryAddress: json['deliveryAddress'],
      customerLocation: json['customerLocation'],
      instructions: json['instructions'],
      paymentMethod: json['paymentMethod'] ?? 'cash',
      paymentStatus: json['paymentStatus'],
      riderId: json['riderId'],
      riderName: json['riderName'],
      riderPhone: json['riderPhone'],
      trackingInfo: json['trackingInfo'],
      statusHistory: json['statusHistory'] != null
          ? List<Map<String, dynamic>>.from(json['statusHistory'])
          : null,
    );
  }

  static OrderStatus _parseOrderStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'outfordelivery':
      case 'out for delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'failed':
        return OrderStatus.failed;
      default:
        return OrderStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'vendorImage': vendorImage,
      'items': items.map((item) => item.toJson()).toList(),
      'itemTotal': itemTotal,
      'tax': tax,
      'deliveryFee': deliveryFee,
      'tip': tip,
      'total': total,
      'status': status.name,
      'orderDate': orderDate.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'deliveryAddress': deliveryAddress,
      'customerLocation': customerLocation,
      'instructions': instructions,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'riderId': riderId,
      'riderName': riderName,
      'riderPhone': riderPhone,
      'trackingInfo': trackingInfo,
      'statusHistory': statusHistory,
    };
  }

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isDelivered => status == OrderStatus.delivered;
  bool get isCancelled => status == OrderStatus.cancelled;
  bool get isActive => !isDelivered && !isCancelled;

  @override
  String toString() {
    return 'EnhancedOrder(id: $id, vendorName: $vendorName, status: $status, total: $total)';
  }
} 