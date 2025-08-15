import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_cart_provider.dart';
import '../providers/unified_cart_provider.dart';
import '../providers/mart_cart_provider.dart';
import '../routes.dart';

class CartIconWithBadge extends StatelessWidget {
  final Color? iconColor;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final double iconSize;
  final double badgeSize;
  final EdgeInsets? badgeOffset;
  final VoidCallback? onTap;
  final bool showZeroBadge;

  const CartIconWithBadge({
    Key? key,
    this.iconColor,
    this.badgeColor,
    this.badgeTextColor,
    this.iconSize = 24.0,
    this.badgeSize = 18.0,
    this.badgeOffset,
    this.onTap,
    this.showZeroBadge = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<EnhancedCartProvider, MartCartProvider>(
      builder: (context, enhancedCartProvider, martCartProvider, child) {
        final enhancedItemCount = enhancedCartProvider.itemCount;
        int martItemCount = 0;
        for (final item in martCartProvider.items) {
          martItemCount += (item['quantity'] as int? ?? 1);
        }
        final totalItemCount = enhancedItemCount + martItemCount;
        
        return GestureDetector(
          onTap: onTap ?? () => Navigator.pushNamed(context, AppRoutes.cart),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.shopping_cart,
                color: iconColor ?? Colors.white,
                size: iconSize,
              ),
              if (totalItemCount > 0 || showZeroBadge)
                Positioned(
                  right: badgeOffset?.right ?? -8,
                  top: badgeOffset?.top ?? -8,
                  child: Container(
                    padding: EdgeInsets.all(badgeSize < 16 ? 2 : 4),
                    decoration: BoxDecoration(
                      color: badgeColor ?? Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                    ),
                    constraints: BoxConstraints(
                      minWidth: badgeSize,
                      minHeight: badgeSize,
                    ),
                    child: Text(
                      '$totalItemCount',
                      style: TextStyle(
                        color: badgeTextColor ?? Colors.white,
                        fontSize: badgeSize < 16 ? 10 : 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Floating Action Button variant for cart
class CartFloatingActionButton extends StatelessWidget {
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final double elevation;
  final VoidCallback? onPressed;

  const CartFloatingActionButton({
    Key? key,
    this.backgroundColor,
    this.iconColor,
    this.badgeColor,
    this.badgeTextColor,
    this.elevation = 8.0,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer2<EnhancedCartProvider, MartCartProvider>(
      builder: (context, enhancedCartProvider, martCartProvider, child) {
        final enhancedItemCount = enhancedCartProvider.itemCount;
        int martItemCount = 0;
        for (final item in martCartProvider.items) {
          martItemCount += (item['quantity'] as int? ?? 1);
        }
        final totalItemCount = enhancedItemCount + martItemCount;
        
        // Only show FAB if there are items in cart
        if (totalItemCount == 0) {
          return const SizedBox.shrink();
        }
        
        return FloatingActionButton(
          onPressed: onPressed ?? () => Navigator.pushNamed(context, AppRoutes.cart),
          backgroundColor: backgroundColor ?? theme.colorScheme.primary,
          elevation: elevation,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.shopping_cart,
                color: iconColor ?? Colors.white,
              ),
              Positioned(
                right: -8,
                top: -8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: badgeColor ?? Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    '$totalItemCount',
                    style: TextStyle(
                      color: badgeTextColor ?? Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// App Bar cart icon button
class CartAppBarButton extends StatelessWidget {
  final Color? iconColor;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final VoidCallback? onPressed;

  const CartAppBarButton({
    Key? key,
    this.iconColor,
    this.badgeColor,
    this.badgeTextColor,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<EnhancedCartProvider, MartCartProvider>(
      builder: (context, enhancedCartProvider, martCartProvider, child) {
        final enhancedItemCount = enhancedCartProvider.itemCount;
        int martItemCount = 0;
        for (final item in martCartProvider.items) {
          martItemCount += (item['quantity'] as int? ?? 1);
        }
        final totalItemCount = enhancedItemCount + martItemCount;
        
        return IconButton(
          onPressed: onPressed ?? () => Navigator.pushNamed(context, AppRoutes.cart),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.shopping_cart,
                color: iconColor ?? Colors.black87,
              ),
              if (totalItemCount > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: badgeColor ?? Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$totalItemCount',
                      style: TextStyle(
                        color: badgeTextColor ?? Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Legacy cart floating action button for UnifiedCartProvider
class LegacyCartFloatingActionButton extends StatelessWidget {
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final double elevation;
  final VoidCallback? onPressed;

  const LegacyCartFloatingActionButton({
    Key? key,
    this.backgroundColor,
    this.iconColor,
    this.badgeColor,
    this.badgeTextColor,
    this.elevation = 8.0,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<UnifiedCartProvider>(
      builder: (context, cartProvider, child) {
        final itemCount = cartProvider.itemCount;
        
        // Only show FAB if there are items in cart
        if (itemCount == 0) {
          return const SizedBox.shrink();
        }
        
        return FloatingActionButton(
          onPressed: onPressed ?? () => Navigator.pushNamed(context, AppRoutes.cart),
          backgroundColor: backgroundColor ?? theme.colorScheme.primary,
          elevation: elevation,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.shopping_cart,
                color: iconColor ?? Colors.white,
              ),
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: badgeColor ?? Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    '$itemCount',
                    style: TextStyle(
                      color: badgeTextColor ?? Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
