import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tuukatuu/providers/mart_cart_provider.dart';
import 'package:tuukatuu/presentation/screens/tmart_cart_screen.dart';
import 'package:tuukatuu/services/api_service.dart';

class TMartProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const TMartProductDetailScreen({super.key, required this.product});

  @override
  State<TMartProductDetailScreen> createState() => _TMartProductDetailScreenState();
}

class _TMartProductDetailScreenState extends State<TMartProductDetailScreen> {
  int _quantity = 1;
  final bool _isLoading = false;
  List<Map<String, dynamic>> _similarProducts = [];
  bool _loadingSimilar = false;

  // Swiggy color scheme
  static const Color swiggyOrange = Color(0xFFFC8019);
  static const Color swiggyLight = Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    _updateCartQuantity();
    _loadSimilarProducts();
  }

  void _updateCartQuantity() {
    Provider.of<MartCartProvider>(context, listen: false);
    setState(() {
    });
  }

  Future<void> _loadSimilarProducts() async {
    setState(() {
      _loadingSimilar = true;
    });

    try {
      final response = await ApiService.get('/tmart/similar', params: {
        'productId': widget.product['_id'] ?? widget.product['id'],
        'limit': '6',
      });

      if (response['success'] && response['data'] != null) {
        setState(() {
          _similarProducts = List<Map<String, dynamic>>.from(response['data']);
          _loadingSimilar = false;
        });
      } else {
        setState(() {
          _similarProducts = [];
          _loadingSimilar = false;
        });
      }
    } catch (e) {
      setState(() {
        _loadingSimilar = false;
      });
    }
  }

  void _addToCart() {
    final martCartProvider = Provider.of<MartCartProvider>(context, listen: false);
    martCartProvider.addItem(widget.product, quantity: _quantity);
    _updateCartQuantity();
    
    // Item added to cart silently
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  // Helper method to extract numeric price from string
  double _extractNumericPrice(String? priceString) {
    if (priceString == null || priceString.isEmpty) return 0.0;
    
    print('Extracting price from: "$priceString"');
    
    // Handle different price formats
    String cleanPrice = priceString;
    
    // Remove currency symbols, text, and extra spaces
    cleanPrice = cleanPrice
        .replaceAll(RegExp(r'Rs\.?\s*'), '') // Remove "Rs." or "Rs" with optional space
        .replaceAll(RegExp(r'₹\s*'), '')      // Remove "₹" with optional space
        .replaceAll(RegExp(r'\$\s*'), '')     // Remove "$" with optional space
        .replaceAll(RegExp(r'[^\d.]'), '')    // Remove all non-digit, non-dot characters
        .trim();                               // Remove leading/trailing spaces
    
    print('Cleaned price string: "$cleanPrice"');
    
    // Handle cases where there might be multiple decimal points
    final parts = cleanPrice.split('.');
    if (parts.length > 2) {
      cleanPrice = '${parts[0]}.${parts.sublist(1).join('')}';
      print('Fixed multiple decimals: "$cleanPrice"');
    }
    
    // Ensure we have a valid number
    if (cleanPrice.isEmpty || cleanPrice == '.') {
      print('Invalid price string after cleaning');
      return 0.0;
    }
    
    try {
      final price = double.parse(cleanPrice);
      print('Successfully parsed price: $price');
      return price.isFinite ? price : 0.0;
    } catch (e) {
      print('Error parsing price: "$priceString" -> cleaned: "$cleanPrice" -> error: $e');
      return 0.0;
    }
  }

  // Alternative method to get price - try to get the original numeric value first
  double _getProductPrice() {
    // Try different possible price field names
    final possiblePriceFields = ['price', 'Price', 'PRICE', 'amount', 'Amount', 'AMOUNT'];
    
    for (final fieldName in possiblePriceFields) {
      final priceValue = widget.product[fieldName];
      if (priceValue != null) {
        print('Found price in field "$fieldName": $priceValue (${priceValue.runtimeType})');
        
        // If it's already a number, use it directly
        if (priceValue is num) {
          print('Price is already numeric: $priceValue');
          return priceValue.toDouble();
        }
        
        // If it's a string, try to extract the numeric value
        if (priceValue is String) {
          final extractedPrice = _extractNumericPrice(priceValue);
          if (extractedPrice > 0) {
            print('Successfully extracted price from string: $extractedPrice');
            return extractedPrice;
          }
        }
      }
    }
    
    // Fallback to 0
    print('No valid price found in any field');
    return 0.0;
  }

  // Method to get original price for discount calculations
  double _getOriginalPrice() {
    // Try different possible original price field names
    final possibleOriginalPriceFields = ['originalPrice', 'original_price', 'OriginalPrice', 'ORIGINAL_PRICE'];
    
    for (final fieldName in possibleOriginalPriceFields) {
      final originalPriceValue = widget.product[fieldName];
      if (originalPriceValue != null) {
        print('Found original price in field "$fieldName": $originalPriceValue (${originalPriceValue.runtimeType})');
        
        // If it's already a number, use it directly
        if (originalPriceValue is num) {
          print('Original price is already numeric: $originalPriceValue');
          return originalPriceValue.toDouble();
        }
        
        // If it's a string, try to extract the numeric value
        if (originalPriceValue is String) {
          final extractedPrice = _extractNumericPrice(originalPriceValue);
          if (extractedPrice > 0) {
            print('Successfully extracted original price from string: $extractedPrice');
            return extractedPrice;
          }
        }
      }
    }
    
    // If no original price found, return 0
    print('No original price found, using 0');
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<MartCartProvider>(context);
    
    // Debug logging
    print('Product data: ${widget.product}');
    print('Price: ${widget.product['price']} (type: ${widget.product['price']?.runtimeType})');
    print('Original Price: ${widget.product['originalPrice']} (type: ${widget.product['originalPrice']?.runtimeType})');
    print('All product keys: ${widget.product.keys.toList()}');
    
    // Extract numeric prices for comparison
    final currentPrice = _getProductPrice();
    final originalPrice = _getOriginalPrice();
    
    print('Extracted current price: $currentPrice');
    print('Extracted original price: $originalPrice');
    
    final hasDiscount = originalPrice > 0 && originalPrice > currentPrice;
    final discountPercentage = hasDiscount 
        ? (((originalPrice - currentPrice) / originalPrice) * 100).round()
        : 0;

    return Scaffold(
      backgroundColor: swiggyLight,
      appBar: AppBar(
        backgroundColor: swiggyOrange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Product Details',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TMartCartScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 300,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: Image.network(
                  widget.product['imageUrl'] ?? widget.product['image'] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 80),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    widget.product['name'] ?? 'Product Name',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price Section
                  Row(
                    children: [
                      Text(
                        '₹${currentPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: swiggyOrange,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 12),
                        Text(
                          '₹${originalPrice.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.grey[500],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$discountPercentage% OFF',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  if (widget.product['description'] != null) ...[
                    Text(
                      'Description',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.product['description'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Quantity Selector
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Quantity:',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _decrementQuantity,
                          icon: const Icon(Icons.remove_circle_outline),
                          color: swiggyOrange,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: swiggyLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$_quantity',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _incrementQuantity,
                          icon: const Icon(Icons.add_circle_outline),
                          color: swiggyOrange,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: swiggyOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Add to Cart - ₹${(currentPrice * _quantity).toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Similar Products
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Similar Products',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          if (_loadingSimilar)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(swiggyOrange),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_loadingSimilar)
                        SizedBox(
                          height: 220,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 160,
                                margin: const EdgeInsets.only(right: 12),
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 120,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 12,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              height: 10,
                                              width: 60,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      else if (_similarProducts.isNotEmpty)
                        SizedBox(
                          height: 220,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _similarProducts.length,
                            itemBuilder: (context, index) {
                              final product = _similarProducts[index];
                              final productId = product['_id'] ?? product['id'] ?? '';
                              final cartQuantity = Provider.of<MartCartProvider>(context, listen: false).getItemQuantity(productId);
                              
                              return Container(
                                width: 160,
                                margin: const EdgeInsets.only(right: 12),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TMartProductDetailScreen(product: product),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                              child: Image.network(
                                                product['imageUrl'] ?? product['image'] ?? '',
                                                height: 120,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => Container(
                                                  height: 120,
                                                  color: Colors.grey[200],
                                                  child: const Icon(Icons.broken_image, size: 30),
                                                ),
                                              ),
                                            ),
                                            // Add to cart button
                                            Positioned(
                                              bottom: 8,
                                              right: 8,
                                              child: GestureDetector(
                                                onTap: () {
                                                  final martCartProvider = Provider.of<MartCartProvider>(context, listen: false);
                                                  martCartProvider.addItem(product, quantity: 1);
                                                  // Item added to cart silently
                                                },
                                                child: Container(
                                                  width: 32,
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    color: swiggyOrange,
                                                    borderRadius: BorderRadius.circular(16),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withOpacity(0.2),
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
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product['name'] ?? '',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    '₹${product['price']?.toString() ?? '0'}',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                      color: swiggyOrange,
                                                    ),
                                                  ),
                                                  if (cartQuantity > 0)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: swiggyOrange.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Text(
                                                        '$cartQuantity in cart',
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 10,
                                                          color: swiggyOrange,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      else if (!_loadingSimilar)
                        Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  color: Colors.grey[400],
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No similar products found',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 