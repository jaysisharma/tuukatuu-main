import 'package:flutter/material.dart';
import '../models/store.dart';
import '../widgets/cached_image.dart';
import '../core/config/routes.dart';

class StoreCartBanner extends StatelessWidget {
  final Store store;
  final int itemCount;
  final double totalAmount;
  final VoidCallback? onTap;
  final VoidCallback? onClose;

  const StoreCartBanner({
    super.key,
    required this.store,
    required this.itemCount,
    required this.totalAmount,
    this.onTap,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {
            Navigator.pushNamed(context, AppRoutes.cart);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Store banner image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedImage(
                    imageUrl: store.banner.isNotEmpty ? store.banner : store.image,
                    width: 80,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                // Store info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${store.rating} (${store.reviews})',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            store.deliveryTime,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$itemCount item${itemCount > 1 ? 's' : ''} • Rs ${totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Close button
                if (onClose != null)
                  IconButton(
                    onPressed: onClose,
                    icon: Icon(
                      Icons.close,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 