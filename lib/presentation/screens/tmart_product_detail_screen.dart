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
  int _cartQuantity = 0;
  bool _isLoading = false;
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
    final martCartProvider = Provider.of<MartCartProvider>(context, listen: false);
    final productId = widget.product['_id'] ?? widget.product['id'] ?? '';
    setState(() {
      _cartQuantity = martCartProvider.getItemQuantity(productId);
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
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product['name']} added to cart'),
        backgroundColor: swiggyOrange,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TMartCartScreen()),
            );
          },
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final martCartProvider = Provider.of<MartCartProvider>(context);
    final hasDiscount = widget.product['originalPrice'] != null && 
                       widget.product['originalPrice'] > widget.product['price'];
    final discountPercentage = hasDiscount 
        ? (((widget.product['originalPrice'] - widget.product['price']) / widget.product['originalPrice']) * 100).round()
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
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
                        '₹${widget.product['price']?.toString() ?? '0'}',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: swiggyOrange,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 12),
                        Text(
                          '₹${widget.product['originalPrice']}',
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
                              'Add to Cart - ₹${(widget.product['price'] * _quantity).toString()}',
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
                            SizedBox(
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
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('${product['name']} added to cart'),
                                                      backgroundColor: swiggyOrange,
                                                      behavior: SnackBarBehavior.floating,
                                                    ),
                                                  );
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
                                                        '${cartQuantity} in cart',
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