import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../providers/unified_cart_provider.dart';

class DailyEssentialsSection extends StatefulWidget {
  final UnifiedCartProvider? martCartProvider;
  
  const DailyEssentialsSection({
    Key? key, 
    this.martCartProvider,
  }) : super(key: key);

  @override
  State<DailyEssentialsSection> createState() => _DailyEssentialsSectionState();
}

class _DailyEssentialsSectionState extends State<DailyEssentialsSection> {
  List<Map<String, dynamic>> _dailyEssentials = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadDailyEssentials();
  }

  Future<void> _loadDailyEssentials() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Load vendor products for fast delivery daily essentials
      final response = await ApiService.get('/products');
      
      if (response is List) {
        final allEssentials = List<Map<String, dynamic>>.from(response);
        // Take first 8 products for daily essentials
        final featuredEssentials = allEssentials.take(8).toList();
        
        setState(() {
          _dailyEssentials = featuredEssentials;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      print('Error loading daily essentials: $e');
    }
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final hasDiscount = product['originalPrice'] != null && 
                       product['originalPrice'] > product['price'];
    final discountPercentage = hasDiscount 
        ? ((product['originalPrice'] - product['price']) / product['originalPrice'] * 100).round()
        : 0;
    final isFeatured = product['isFeaturedDailyEssential'] == true;
    
    // Get quantity for this product from cart provider
    final productId = product['_id']?.toString() ?? '';
    final quantity = widget.martCartProvider?.getItemQuantity(productId, CartItemType.tmart) ?? 0;

    return Container(
      width: 140,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: isFeatured ? Border.all(
          color: Colors.orange.withOpacity(0.5),
          width: 2,
        ) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  product['imageUrl'] ?? '',
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 100,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 30),
                  ),
                ),
              ),
              // Featured Badge
              if (isFeatured)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'FEATURED',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Discount Badge
              if (hasDiscount)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$discountPercentage% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // Quantity Controls
              Positioned(
                right: 6,
                bottom: 6,
                child: quantity == 0
                    ? Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // Add to cart using cart provider
                            widget.martCartProvider?.addTmartItem(
                              id: product['_id'] ?? product['id'] ?? '',
                              name: product['name'] ?? '',
                              price: (product['price'] ?? 0).toDouble(),
                              quantity: 1,
                              image: product['imageUrl'] ?? product['image'] ?? '',
                              vendorId: product['vendorId'] is String ? product['vendorId'] : product['vendorId']?['_id']?.toString(),
                            );
                            
                           
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  if (quantity > 1) {
                                    widget.martCartProvider?.updateQuantity(productId, CartItemType.tmart, quantity - 1);
                                  } else {
                                    widget.martCartProvider?.removeItem(productId, CartItemType.tmart);
                                  }
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: const SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              child: Text(
                                quantity.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  widget.martCartProvider?.updateQuantity(productId, CartItemType.tmart, quantity + 1);
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: const SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
          // Product Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Category
                  Text(
                    product['category'] ?? '',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Unit
                  const Spacer(),
                  // Price and Rating
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              '₹${product['price']?.toString() ?? '0'}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            if (hasDiscount) ...[
                              const SizedBox(width: 4),
                              Text(
                                '₹${product['originalPrice']?.toString() ?? '0'}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (product['rating'] != null) ...[
                        const SizedBox(width: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              product['rating'].toString(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_hasError || _dailyEssentials.isEmpty) {
      return SizedBox.shrink(); // Hide section if no data
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fast Delivery Essentials',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/daily-essentials-page',
                    arguments: {
                      'products': _dailyEssentials,
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'View All',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _dailyEssentials.length,
            itemBuilder: (context, index) {
              final product = _dailyEssentials[index];
              
              return GestureDetector(
                onTap: () {
                  // Navigate to product detail
                  Navigator.pushNamed(
                    context,
                    '/product-detail',
                    arguments: {
                      'product': product,
                    },
                  );
                },
                child: _buildProductCard(product),
              );
            },
          ),
        ),
      ],
    );
  }
} 