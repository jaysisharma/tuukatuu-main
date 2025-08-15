import 'package:flutter/material.dart';
import 'package:tuukatuu/presentation/widgets/product_grid_item.dart';

class ProductsGrid extends StatelessWidget {
  final List<String> productNames;
  final Function(String) onProductTap;

  const ProductsGrid({
    super.key,
    required this.productNames,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: productNames.map((name) => ProductGridItem(
        name: name,
        onTap: () => onProductTap(name),
      )).toList(),
    );
  }
}
