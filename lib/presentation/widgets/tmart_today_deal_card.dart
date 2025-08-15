import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

// Swiggy color scheme
const Color swiggyOrange = Color(0xFFFC8019);
const Color swiggyRed = Color(0xFFE23744);
const Color swiggyDark = Color(0xFF1C1C1C);
const Color swiggyLight = Color(0xFFF8F9FA);

class TMartTodayDealCard extends StatefulWidget {
  final Map<String, dynamic> deal;

  const TMartTodayDealCard({
    super.key,
    required this.deal,
  });

  @override
  State<TMartTodayDealCard> createState() => _TMartTodayDealCardState();
}

class _TMartTodayDealCardState extends State<TMartTodayDealCard> {
  Timer? _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _calculateTimeLeft() {
    final endDate = DateTime.parse(widget.deal['endDate']);
    final now = DateTime.now();
    _timeLeft = endDate.difference(now);
    
    if (_timeLeft.isNegative) {
      _timeLeft = Duration.zero;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _calculateTimeLeft();
        });
        
        if (_timeLeft.inSeconds <= 0) {
          timer.cancel();
        }
      }
    });
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount = widget.deal['originalPrice'] != null && 
                       widget.deal['originalPrice'] > widget.deal['price'];
    final discountPercentage = widget.deal['discount'] ?? 0;
    final isExpired = widget.deal['isExpired'] ?? false;
    final isValid = widget.deal['isValid'] ?? true;
    final remainingQuantity = widget.deal['remainingQuantity'] ?? 0;
    final maxQuantity = widget.deal['maxQuantity'] ?? 10;
    final soldQuantity = widget.deal['soldQuantity'] ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: widget.deal['featured'] == true ? Border.all(
          color: swiggyOrange.withOpacity(0.3),
          width: 1.5,
        ) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with Discount Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  widget.deal['imageUrl'] ?? '',
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 40),
                  ),
                ),
              ),
              // Discount Badge
              if (hasDiscount && !isExpired)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: swiggyRed,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$discountPercentage% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              // Featured Badge
              if (widget.deal['featured'] == true)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: swiggyOrange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'FEATURED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              // Expired Badge
              if (isExpired)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'EXPIRED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Product Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  widget.deal['name'] ?? '',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Description
                Text(
                  widget.deal['description'] ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Price Section
                Row(
                  children: [
                    // Deal Price
                    Text(
                      '₹${widget.deal['price']?.toString() ?? '0'}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: swiggyOrange,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Original Price (strikethrough)
                    if (hasDiscount)
                      Text(
                        '₹${widget.deal['originalPrice']?.toString() ?? '0'}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                // Countdown Timer
                if (!isExpired && isValid && _timeLeft.inSeconds > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: swiggyRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: swiggyRed.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 12,
                          color: swiggyRed,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Ends in ${_formatDuration(_timeLeft)}',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: swiggyRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                // Stock Progress
                if (!isExpired && isValid)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Stock: $remainingQuantity left',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: remainingQuantity < 5 ? swiggyRed : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '$soldQuantity/$maxQuantity sold',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Progress Bar
                      LinearProgressIndicator(
                        value: soldQuantity / maxQuantity,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          remainingQuantity < 5 ? swiggyRed : swiggyOrange,
                        ),
                        minHeight: 3,
                      ),
                    ],
                  ),
                // Expired Message
                if (isExpired)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Deal expired',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 