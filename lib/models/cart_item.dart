import 'package:flutter/material.dart';
import 'product.dart';
import 'store.dart';

enum CartItemSource { 
  restaurant,  // Food delivery items
  store,       // Retail store items  
  mart         // T-Mart grocery items
}

class CartItem {
  final Product product;        // Product details
  int quantity;                 // Current quantity
  final CartItemSource source;  // Source type (restaurant/store/mart)
  final String? sourceId;       // Restaurant/Store ID
  final String? sourceName;     // Display name
  final String? notes;          // Additional notes
  final Store? store;           // Store information if available

  CartItem({
    required this.product,
    required this.quantity,
    required this.source,
    this.sourceId,
    this.sourceName,
    this.notes,
    this.store,
  });

  // Get total price for this item
  double get totalPrice => product.price * quantity;

  // Get display name for source
  String get displaySourceName {
    if (sourceName != null && sourceName!.isNotEmpty) {
      return sourceName!;
    }
    
    switch (source) {
      case CartItemSource.restaurant:
        return 'Restaurant';
      case CartItemSource.store:
        return 'Store';
      case CartItemSource.mart:
        return 'T-Mart';
    }
  }

  // Get source color for UI
  Color get sourceColor {
    switch (source) {
      case CartItemSource.restaurant:
        return const Color(0xFF6366F1); // Purple
      case CartItemSource.store:
        return const Color(0xFF8B5CF6); // Violet
      case CartItemSource.mart:
        return const Color(0xFF10B981); // Green
    }
  }

  // Create copy with updated values
  CartItem copyWith({
    Product? product,
    int? quantity,
    CartItemSource? source,
    String? sourceId,
    String? sourceName,
    String? notes,
    Store? store,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      sourceName: sourceName ?? this.sourceName,
      notes: notes ?? this.notes,
      store: store ?? this.store,
    );
  }

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'productId': product.id,
      'productName': product.name,
      'price': product.price,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'imageUrl': product.imageUrl,
      'source': source.name,
      'sourceId': sourceId,
      'sourceName': sourceName,
      'notes': notes,
      'store': store?.toJson(),
    };
  }

  // Create from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product'] ?? {}),
      quantity: json['quantity'] ?? 1,
      source: CartItemSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => CartItemSource.mart,
      ),
      sourceId: json['sourceId'],
      sourceName: json['sourceName'],
      notes: json['notes'],
      store: json['store'] != null ? Store.fromJson(json['store']) : null,
    );
  }

  // Equality operator for proper comparison
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          product == other.product &&
          source == other.source &&
          sourceId == other.sourceId;

  @override
  int get hashCode => Object.hash(product, source, sourceId);

  @override
  String toString() {
    return 'CartItem(product: ${product.name}, quantity: $quantity, source: $source, sourceName: $sourceName)';
  }
} 