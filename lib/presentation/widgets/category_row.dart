import 'package:flutter/material.dart';

class CategoryRow extends StatelessWidget {
  final List<Map<String, String>> categories;

  const CategoryRow({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: categories.map((category) => Column(
          children: [
            Image.asset(
              category['image']!,
              height: 40,
              width: 40,
            ),
            const SizedBox(height: 4),
            Text(
              category['name']!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )).toList(),
      ),
    );
  }
}
