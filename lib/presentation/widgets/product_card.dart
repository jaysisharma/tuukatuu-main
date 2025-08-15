import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String category;
  final String image;
  final double rating;
  final int reviews;
  final int quantity;
  final VoidCallback onAddToCart;
  final VoidCallback onRemoveFromCart;
  final bool isTrending;
  final String? trendingLabel;
  final String? discount;
  final bool isFeatured;
  final Map<String, dynamic>? product; // Full product data for navigation
  final Function(Map<String, dynamic>)? onProductTap; // Navigation callback

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.category,
    required this.image,
    required this.rating,
    required this.reviews,
    required this.quantity,
    required this.onAddToCart,
    required this.onRemoveFromCart,
    this.isTrending = false,
    this.trendingLabel,
    this.discount,
    this.isFeatured = false,
    this.product,
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: product != null ? () {
        if (onProductTap != null) {
          onProductTap!(product!);
        } else {
          _navigateToProductDetail(context, product!);
        }
      } : null,
      child: Container(
        width: 180, // Increased from 160 to 180 for better proportions
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
          
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image Section
          Expanded(
            flex: 4, // Increase image size even more
            child: Stack(
              children: [
                // Main Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    image,
                    height: double.infinity,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                
                // Trending Badge
                if (isTrending && trendingLabel != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35), // Swiggy Orange
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B35).withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            trendingLabel!.contains('🔥') ? Icons.local_fire_department : Icons.trending_up,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            trendingLabel!.replaceAll('🔥', '').replaceAll('⚡', ''),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                
              
                // Cart Controls Overlay
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: _buildCartControls(),
                ),
              ],
            ),
          ),
          
          // Product Details Section
          Container(
            padding: const EdgeInsets.all(8), // Reduced padding from 12 to 8
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                
                const SizedBox(height: 6), // Reduced from 8 to 6
                
                // Product Name
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 6), // Reduced from 8 to 6
                
                // Price
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B35), // Swiggy Orange
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
     ));
  }

  Widget _buildCartControls() {
    if (quantity == 0) {
      // Add to cart button
      return GestureDetector(
        onTap: onAddToCart,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B35), // Swiggy Orange
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B35).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 20,
          ),
        ),
      );
    } else {
      // Quantity controls
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFFF6B35),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Minus button
            GestureDetector(
              onTap: onRemoveFromCart,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.remove,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Quantity
            Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B35),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Plus button
            GestureDetector(
              onTap: onAddToCart,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _navigateToProductDetail(BuildContext context, Map<String, dynamic> product) {
    Navigator.pushNamed(
      context,
      '/tmart-product-detail',
      arguments: {'product': product},
    );
  }
}
