import 'package:flutter_test/flutter_test.dart';
import 'package:tuukatuu/models/product.dart';

void main() {
  group('Product Equality Tests', () {
    test('Products with same ID should be equal', () {
      const product1 = Product(
        id: 'test-id',
        name: 'Test Product',
        price: 10.0,
        imageUrl: 'test.jpg',
        category: 'test',
        rating: 4.5,
        reviews: 100,
        isAvailable: true,
        deliveryFee: 0.0,
        description: 'Test description',
        images: ['test.jpg'],
        vendorId: 'vendor-1',
      );

      const product2 = Product(
        id: 'test-id', // Same ID
        name: 'Different Name', // Different name but same ID
        price: 20.0, // Different price but same ID
        imageUrl: 'different.jpg',
        category: 'different',
        rating: 3.5,
        reviews: 50,
        isAvailable: false,
        deliveryFee: 5.0,
        description: 'Different description',
        images: ['different.jpg'],
        vendorId: 'vendor-2',
      );

      expect(product1, equals(product2));
      expect(product1.hashCode, equals(product2.hashCode));
    });

    test('Products with different IDs should not be equal', () {
      const product1 = Product(
        id: 'test-id-1',
        name: 'Test Product',
        price: 10.0,
        imageUrl: 'test.jpg',
        category: 'test',
        rating: 4.5,
        reviews: 100,
        isAvailable: true,
        deliveryFee: 0.0,
        description: 'Test description',
        images: ['test.jpg'],
        vendorId: 'vendor-1',
      );

      const product2 = Product(
        id: 'test-id-2', // Different ID
        name: 'Test Product', // Same name but different ID
        price: 10.0,
        imageUrl: 'test.jpg',
        category: 'test',
        rating: 4.5,
        reviews: 100,
        isAvailable: true,
        deliveryFee: 0.0,
        description: 'Test description',
        images: ['test.jpg'],
        vendorId: 'vendor-1',
      );

      expect(product1, isNot(equals(product2)));
      expect(product1.hashCode, isNot(equals(product2.hashCode)));
    });
  });
}
