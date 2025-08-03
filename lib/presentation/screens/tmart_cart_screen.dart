import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tuukatuu/providers/mart_cart_provider.dart';
import 'package:tuukatuu/services/api_service.dart';
import 'package:tuukatuu/presentation/screens/checkout_screen.dart';

class TMartCartScreen extends StatefulWidget {
  const TMartCartScreen({super.key});

  @override
  State<TMartCartScreen> createState() => _TMartCartScreenState();
}

class _TMartCartScreenState extends State<TMartCartScreen> {
  bool _isCheckingOut = false;

  // Swiggy color scheme
  static const Color swiggyOrange = Color(0xFFFC8019);
  static const Color swiggyRed = Color(0xFFE23744);
  static const Color swiggyDark = Color(0xFF1C1C1C);
  static const Color swiggyLight = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    final martCartProvider = Provider.of<MartCartProvider>(context);
    final items = martCartProvider.items;
    final total = martCartProvider.totalAmount;
    print("Items $items");
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
          'T-Mart Cart',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () {
                _showClearCartDialog(context, martCartProvider);
              },
              child: Text(
                'Clear',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: items.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: _buildCartItems(martCartProvider),
                ),
                _buildCheckoutSection(martCartProvider, total),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your T-Mart cart is empty',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some groceries to get started',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: swiggyOrange,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Start Shopping',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(MartCartProvider martCartProvider) {
    final items = martCartProvider.items;
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildCartItemCard(item, martCartProvider);
      },
    );
  }

  Widget _buildCartItemCard(Map<String, dynamic> item, MartCartProvider martCartProvider) {
    final String productId = item['id'];
    final int quantity = item['quantity'] ?? 0;
    final double price = (item['price'] ?? 0).toDouble();
    final double totalPrice = price * quantity;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item['image'] ?? item['imageUrl'] ?? '',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, size: 30),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${price.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: swiggyOrange,
                    ),
                  ),
                  if (item['unit'] != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item['unit'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  
                  // Quantity Controls
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: swiggyOrange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  if (quantity > 1) {
                                    martCartProvider.updateQuantity(productId, quantity - 1);
                                  } else {
                                    martCartProvider.removeItem(productId);
                                  }
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: const SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: Center(
                                    child: Icon(
                                      Icons.remove,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              child: Center(
                                child: Text(
                                  quantity.toString(),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  martCartProvider.updateQuantity(productId, quantity + 1);
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: const SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: Center(
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '₹${totalPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Remove Button
            IconButton(
              onPressed: () {
                martCartProvider.removeItem(productId);
              },
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(MartCartProvider martCartProvider, double total) {
    final deliveryFee = total >= 500 ? 0.0 : 40.0;
    final finalTotal = total + deliveryFee;
    
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          // Price Breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '₹${total.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery Fee',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                deliveryFee == 0 ? 'FREE' : '₹${deliveryFee.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: deliveryFee == 0 ? Colors.green : Colors.black87,
                ),
              ),
            ],
          ),
          if (deliveryFee > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Free delivery on orders above ₹500',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '₹${finalTotal.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: swiggyOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Checkout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isCheckingOut ? null : () => _proceedToCheckout(martCartProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: swiggyOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isCheckingOut
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Proceed to Checkout',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          
          // Continue Shopping Button
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: swiggyOrange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Continue Shopping',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: swiggyOrange,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, MartCartProvider martCartProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Cart', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to remove all items from your cart?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              martCartProvider.clearCart();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: swiggyRed,
            ),
            child: Text('Clear', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _proceedToCheckout(MartCartProvider martCartProvider) async {
    setState(() {
      _isCheckingOut = true;
    });

    try {
      // Calculate totals
      final total = martCartProvider.totalAmount;
      final deliveryFee = total >= 500 ? 0.0 : 40.0;
      final finalTotal = total + deliveryFee;

      // Navigate to checkout screen
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutScreen(
            totalAmount: finalTotal,
            cartItems: martCartProvider.items,
            isTmartOrder: true,
          ),
        ),
      );

      // If order was successful, clear cart
      if (result == true) {
        martCartProvider.clearCart();
        Navigator.pop(context); // Go back to T-Mart screen
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Order placed successfully!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('❌ Error during checkout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error during checkout. Please try again.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: swiggyRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isCheckingOut = false;
      });
    }
  }
} 