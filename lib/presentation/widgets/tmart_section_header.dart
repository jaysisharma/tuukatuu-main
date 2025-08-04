import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TMartSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  final IconData? icon;

  const TMartSectionHeader({
    super.key,
    required this.title,
    this.onViewAll,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: const Color(0xFFFC8019), // Swiggy Orange
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16, // Reduced from 20 to 16
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child:             Text(
              'View All',
              style: GoogleFonts.poppins(
                fontSize: 12, // Reduced font size
                color: const Color(0xFFFC8019), // Swiggy Orange
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
} 