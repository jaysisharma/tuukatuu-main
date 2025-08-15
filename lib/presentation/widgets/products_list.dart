import 'package:flutter/material.dart';
import 'package:tuukatuu/presentation/widgets/product_card.dart';

class ProductsList extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final Map<String, int> quantities;
  final Function(String, bool, {bool isTrending}) onQuantityChanged;
  final bool isTrending;
  final Function(Map<String, dynamic>)? onProductTap; // Callback for product navigation

  const ProductsList({
    super.key,
    required this.products,
    required this.quantities,
    required this.onQuantityChanged,
    this.isTrending = false,
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250, // Increased from 200 to 280 for taller cards
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final productKey = product['name'];
          final quantity = quantities[productKey] ?? 0;

          return ProductCard(
            name: product['name'],
            price: product['price'],
            category: product['category'],
            image: product['image'],
            rating: product['rating'],
            reviews: product['reviews'],
            quantity: quantity,
            onAddToCart: () => onQuantityChanged(productKey, true, isTrending: isTrending),
            onRemoveFromCart: () => onQuantityChanged(productKey, false, isTrending: isTrending),
            isTrending: isTrending,
            trendingLabel: isTrending ? product['trending'] : null,
            discount: isTrending ? product['discount'] : null,
            isFeatured: product['isFeaturedDailyEssential'] == true || product['isFeatured'] == true,
            product: product, // Pass the full product data for navigation
            onProductTap: onProductTap, // Pass the navigation callback
          );
        },
      ),
    );
  }
}
