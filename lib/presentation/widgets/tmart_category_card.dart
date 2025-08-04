import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TMartCategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;
  final VoidCallback onTap;

  const TMartCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  Color _getCategoryColor(dynamic colorValue) {
    if (colorValue is Color) {
      return colorValue;
    }
    
    if (colorValue is String) {
      switch (colorValue.toLowerCase()) {
        case 'green':
          return Colors.green;
        case 'blue':
          return Colors.blue;
        case 'red':
          return Colors.red;
        case 'orange':
          return Colors.orange;
        case 'purple':
          return Colors.purple;
        case 'pink':
          return Colors.pink;
        case 'cyan':
          return Colors.cyan;
        case 'indigo':
          return Colors.indigo;
        case 'teal':
          return Colors.teal;
        case 'amber':
          return Colors.amber;
        case 'deeppurple':
          return Colors.deepPurple;
        case 'lightblue':
          return Colors.lightBlue;
        case 'yellow':
          return Colors.yellow;
        case 'brown':
          return Colors.brown;
        default:
          return const Color(0xFFFC8019); // Swiggy Orange as default
      }
    }
    
    return const Color(0xFFFC8019); // Swiggy Orange as default
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: _getCategoryColor(category['color']).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getCategoryColor(category['color']).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.network(
                  category['imageUrl'] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.category,
                    color: _getCategoryColor(category['color']),
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                category['displayName'] ?? category['name'] ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (category['productCount'] != null && category['productCount'] > 0) ...[
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: _getCategoryColor(category['color']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${category['productCount']}',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: _getCategoryColor(category['color']),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
} 