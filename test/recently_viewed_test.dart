import 'package:flutter_test/flutter_test.dart';
import 'package:tuukatuu/providers/recently_viewed_provider.dart';

void main() {
  group('Recently Viewed Provider Tests', () {
    late RecentlyViewedProvider provider;

    setUp(() {
      provider = RecentlyViewedProvider();
    });

    test('should add product to recently viewed', () async {
      // Arrange
      final product = {
        '_id': 'test_product_1',
        'name': 'Test Product',
        'price': 100.0,
        'imageUrl': 'test_url',
        'category': 'Test Category',
      };

      // Act
      await provider.addToRecentlyViewed(product);

      // Assert
      expect(provider.itemCount, 1);
      expect(provider.recentlyViewed.first['name'], 'Test Product');
      expect(provider.isRecentlyViewed('test_product_1'), true);
    });

    test('should move product to top when added again', () async {
      // Arrange
      final product1 = {
        '_id': 'test_product_1',
        'name': 'Test Product 1',
        'price': 100.0,
        'imageUrl': 'test_url_1',
        'category': 'Test Category',
      };
      final product2 = {
        '_id': 'test_product_2',
        'name': 'Test Product 2',
        'price': 200.0,
        'imageUrl': 'test_url_2',
        'category': 'Test Category',
      };

      // Act
      await provider.addToRecentlyViewed(product1);
      await provider.addToRecentlyViewed(product2);
      await provider.addToRecentlyViewed(product1); // Add again

      // Assert
      expect(provider.itemCount, 2);
      expect(provider.recentlyViewed.first['name'], 'Test Product 1');
      expect(provider.recentlyViewed.last['name'], 'Test Product 2');
    });

    test('should limit recently viewed items', () async {
      // Arrange
      final products = List.generate(25, (index) => {
        '_id': 'test_product_$index',
        'name': 'Test Product $index',
        'price': 100.0 + index,
        'imageUrl': 'test_url_$index',
        'category': 'Test Category',
      });

      // Act
      for (final product in products) {
        await provider.addToRecentlyViewed(product);
      }

      // Assert
      expect(provider.itemCount, 20); // Max items limit
      expect(provider.recentlyViewed.first['name'], 'Test Product 24');
      expect(provider.recentlyViewed.last['name'], 'Test Product 5');
    });

    test('should remove product from recently viewed', () async {
      // Arrange
      final product = {
        '_id': 'test_product_1',
        'name': 'Test Product',
        'price': 100.0,
        'imageUrl': 'test_url',
        'category': 'Test Category',
      };
      await provider.addToRecentlyViewed(product);

      // Act
      await provider.removeFromRecentlyViewed('test_product_1');

      // Assert
      expect(provider.itemCount, 0);
      expect(provider.isRecentlyViewed('test_product_1'), false);
    });

    test('should clear all recently viewed products', () async {
      // Arrange
      final products = List.generate(5, (index) => {
        '_id': 'test_product_$index',
        'name': 'Test Product $index',
        'price': 100.0 + index,
        'imageUrl': 'test_url_$index',
        'category': 'Test Category',
      });

      for (final product in products) {
        await provider.addToRecentlyViewed(product);
      }

      // Act
      await provider.clearRecentlyViewed();

      // Assert
      expect(provider.itemCount, 0);
    });

    test('should filter by category', () async {
      // Arrange
      final product1 = {
        '_id': 'test_product_1',
        'name': 'Test Product 1',
        'price': 100.0,
        'imageUrl': 'test_url_1',
        'category': 'Category A',
      };
      final product2 = {
        '_id': 'test_product_2',
        'name': 'Test Product 2',
        'price': 200.0,
        'imageUrl': 'test_url_2',
        'category': 'Category B',
      };

      await provider.addToRecentlyViewed(product1);
      await provider.addToRecentlyViewed(product2);

      // Act
      final categoryAProducts = provider.getRecentlyViewedByCategory('Category A');
      final categoryBProducts = provider.getRecentlyViewedByCategory('Category B');

      // Assert
      expect(categoryAProducts.length, 1);
      expect(categoryAProducts.first['name'], 'Test Product 1');
      expect(categoryBProducts.length, 1);
      expect(categoryBProducts.first['name'], 'Test Product 2');
    });

    test('should filter by rating', () async {
      // Arrange
      final product1 = {
        '_id': 'test_product_1',
        'name': 'Test Product 1',
        'price': 100.0,
        'imageUrl': 'test_url_1',
        'category': 'Test Category',
        'rating': 3.5,
      };
      final product2 = {
        '_id': 'test_product_2',
        'name': 'Test Product 2',
        'price': 200.0,
        'imageUrl': 'test_url_2',
        'category': 'Test Category',
        'rating': 4.5,
      };

      await provider.addToRecentlyViewed(product1);
      await provider.addToRecentlyViewed(product2);

      // Act
      final highRatedProducts = provider.getRecentlyViewedByRating(4.0);

      // Assert
      expect(highRatedProducts.length, 1);
      expect(highRatedProducts.first['name'], 'Test Product 2');
    });

    test('should get recently viewed with limit', () async {
      // Arrange
      final products = List.generate(10, (index) => {
        '_id': 'test_product_$index',
        'name': 'Test Product $index',
        'price': 100.0 + index,
        'imageUrl': 'test_url_$index',
        'category': 'Test Category',
      });

      for (final product in products) {
        await provider.addToRecentlyViewed(product);
      }

      // Act
      final limitedProducts = provider.getRecentlyViewed(limit: 5);

      // Assert
      expect(limitedProducts.length, 5);
      expect(limitedProducts.first['name'], 'Test Product 9');
      expect(limitedProducts.last['name'], 'Test Product 5');
    });
  });
} 