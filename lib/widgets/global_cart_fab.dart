import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_cart_provider.dart';
import '../routes.dart';

/// Global floating action button for cart that can be used across all screens
/// This provides a consistent cart FAB experience throughout the app
class GlobalCartFAB extends StatelessWidget {
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final double elevation;
  final VoidCallback? onPressed;
  final String? heroTag;

  const GlobalCartFAB({
    Key? key,
    this.backgroundColor,
    this.iconColor,
    this.badgeColor,
    this.badgeTextColor,
    this.elevation = 8.0,
    this.onPressed,
    this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    
    return Consumer<EnhancedCartProvider>(
      builder: (context, cartProvider, child) {
        final storeCount = cartProvider.sourceCount;
        
        // Only show FAB if there are items in cart
        if (storeCount == 0) {
          return const SizedBox.shrink();
        }
        
        return FloatingActionButton(
          onPressed: onPressed ?? () => Navigator.pushNamed(context, AppRoutes.cart),
          backgroundColor: backgroundColor ?? Colors.orange[700],
          elevation: elevation,
          heroTag: heroTag ?? 'global_cart_fab',
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.shopping_cart,
                color: iconColor ?? Colors.white,
                size: 24,
              ),
              Positioned(
                right: -10,
                top: -10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: badgeColor ?? Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    '$storeCount',
                    style: TextStyle(
                      color: badgeTextColor ?? Colors.white,
                      fontSize: 11,
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

/// Extended FAB variant for specific screens
class GlobalCartExtendedFAB extends StatelessWidget {
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final Color? textColor;
  final double elevation;
  final VoidCallback? onPressed;
  final String? heroTag;
  final String? label;

  const GlobalCartExtendedFAB({
    Key? key,
    this.backgroundColor,
    this.iconColor,
    this.badgeColor,
    this.badgeTextColor,
    this.textColor,
    this.elevation = 8.0,
    this.onPressed,
    this.heroTag,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    
    return Consumer<EnhancedCartProvider>(
      builder: (context, cartProvider, child) {
        final storeCount = cartProvider.sourceCount;
        final itemCount = cartProvider.itemCount;
        
        // Only show FAB if there are items in cart
        if (storeCount == 0) {
          return const SizedBox.shrink();
        }
        
        return FloatingActionButton.extended(
          onPressed: onPressed ?? () => Navigator.pushNamed(context, AppRoutes.cart),
          backgroundColor: backgroundColor ?? Colors.orange[700],
          elevation: elevation,
          heroTag: heroTag ?? 'global_cart_extended_fab',
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.shopping_cart,
                color: iconColor ?? Colors.white,
                size: 20,
              ),
              Positioned(
                right: -8,
                top: -8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: badgeColor ?? Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$storeCount',
                    style: TextStyle(
                      color: badgeTextColor ?? Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          label: Text(
            label ?? '$itemCount items',
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
