import 'package:flutter_test/flutter_test.dart';
import 'package:tuukatuu/providers/mart_cart_provider.dart';

void main() {
  group('Daily Essentials Cart Integration Tests', () {
    late MartCartProvider cartProvider;

    setUp(() {
      cartProvider = MartCartProvider();
    });

    test('should add product to cart from daily essentials', () {
      // Arrange
      final product = {
        '_id': 'test_product_1',
        'name': 'Test Product',
        'price': 100.0,
        'imageUrl': 'test_url',
        'category': 'Test Category',
        'isFeaturedDailyEssential': true,
      };

      // Act
      cartProvider.addItem(product);

      // Assert
      expect(cartProvider.itemCount, 1);
      expect(cartProvider.getItemQuantity('test_product_1'), 1);
      expect(cartProvider.totalAmount, 100.0);
    });

    test('should update quantity when incrementing from daily essentials', () {
      // Arrange
      final product = {
        '_id': 'test_product_1',
        'name': 'Test Product',
        'price': 100.0,
        'imageUrl': 'test_url',
        'category': 'Test Category',
        'isFeaturedDailyEssential': true,
      };
      cartProvider.addItem(product);

      // Act
      cartProvider.updateQuantity('test_product_1', 3);

      // Assert
      expect(cartProvider.getItemQuantity('test_product_1'), 3);
      expect(cartProvider.totalAmount, 300.0);
    });

    test('should remove product when quantity reaches zero', () {
      // Arrange
      final product = {
        '_id': 'test_product_1',
        'name': 'Test Product',
        'price': 100.0,
        'imageUrl': 'test_url',
        'category': 'Test Category',
        'isFeaturedDailyEssential': true,
      };
      cartProvider.addItem(product);

      // Act
      cartProvider.updateQuantity('test_product_1', 0);

      // Assert
      expect(cartProvider.itemCount, 0);
      expect(cartProvider.getItemQuantity('test_product_1'), 0);
      expect(cartProvider.totalAmount, 0.0);
    });

    test('should show floating cart when items are added', () {
      // Arrange
      final product = {
        '_id': 'test_product_1',
        'name': 'Test Product',
        'price': 100.0,
        'imageUrl': 'test_url',
        'category': 'Test Category',
        'isFeaturedDailyEssential': true,
      };

      // Act
      cartProvider.addItem(product);

      // Assert
      expect(cartProvider.itemCount, 1);
      // The floating cart should be visible when itemCount > 0
      expect(cartProvider.itemCount > 0, true);
    });
  });
} 