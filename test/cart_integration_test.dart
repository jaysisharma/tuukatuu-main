import 'package:flutter_test/flutter_test.dart';
import 'package:tuukatuu/providers/enhanced_cart_provider.dart';
import 'package:tuukatuu/models/cart_item.dart';
import 'package:tuukatuu/models/product.dart';
import 'package:tuukatuu/models/store.dart';

void main() {
  group('Enhanced Cart Integration Tests', () {
    late EnhancedCartProvider cartProvider;
    late Product testProduct1;
    late Product testProduct2;
    late Store testStore;

    setUp(() {
      cartProvider = EnhancedCartProvider();
      
      testProduct1 = const Product(
        id: 'product_1',
        name: 'Test Product 1',
        price: 10.0,
        imageUrl: 'test_image_1.jpg',
        category: 'Test Category',
        rating: 4.5,
        reviews: 10,
        isAvailable: true,
        deliveryFee: 0,
        description: 'Test product description 1',
        images: ['test_image_1.jpg'],
        vendorId: 'store_1',
      );
      
      testProduct2 = const Product(
        id: 'product_2',
        name: 'Test Product 2',
        price: 15.0,
        imageUrl: 'test_image_2.jpg',
        category: 'Test Category',
        rating: 4.0,
        reviews: 5,
        isAvailable: true,
        deliveryFee: 0,
        description: 'Test product description 2',
        images: ['test_image_2.jpg'],
        vendorId: 'restaurant_1',
      );
      
      testStore = Store(
        id: 'store_1',
        name: 'Test Store',
        description: 'Test store description',
        image: 'store_image.jpg',
        banner: 'store_banner.jpg',
        address: 'Test Address',
        phone: '1234567890',
        email: 'test@store.com',
        rating: 4.0,
        reviews: 50,
        isFeatured: true,
        isActive: true,
        deliveryTime: '30-45 min',
        minimumOrder: 0.0,
        deliveryFee: 5.0,
        categories: ['General'],
      );
    });

    test('should add store and restaurant products to same cart', () {
      // Add store product
      cartProvider.addFromStore(testProduct1, testStore);
      
      // Add restaurant product
      cartProvider.addFromRestaurant(
        testProduct2,
        restaurantId: 'restaurant_1',
        restaurantName: 'Test Restaurant',
      );
      
      // Verify both products are in cart
      expect(cartProvider.items.length, 2);
      expect(cartProvider.hasStoreItems, true);
      expect(cartProvider.hasRestaurantItems, true);
      expect(cartProvider.hasMixedSources, true);
      
      // Verify source-specific counts
      expect(cartProvider.storeItemCount, 1);
      expect(cartProvider.restaurantItemCount, 1);
      
      // Verify totals
      expect(cartProvider.storeTotalAmount, 10.0);
      expect(cartProvider.restaurantTotalAmount, 15.0);
      expect(cartProvider.totalAmount, 25.0);
    });

    test('should group items by source correctly', () {
      // Add products from different sources
      cartProvider.addFromStore(testProduct1, testStore);
      cartProvider.addFromRestaurant(
        testProduct2,
        restaurantId: 'restaurant_1',
        restaurantName: 'Test Restaurant',
      );
      
      final groupedItems = cartProvider.getItemsGroupedBySource();
      
      expect(groupedItems.length, 2);
      expect(groupedItems.containsKey('Test Store'), true);
      expect(groupedItems.containsKey('Test Restaurant'), true);
      expect(groupedItems['Test Store']!.length, 1);
      expect(groupedItems['Test Restaurant']!.length, 1);
    });

    test('should get checkout sources correctly', () {
      // Add products from different sources
      cartProvider.addFromStore(testProduct1, testStore);
      cartProvider.addFromRestaurant(
        testProduct2,
        restaurantId: 'restaurant_1',
        restaurantName: 'Test Restaurant',
      );
      
      final checkoutSources = cartProvider.checkoutSources;
      
      expect(checkoutSources.length, 2);
      expect(checkoutSources.contains('Test Store'), true);
      expect(checkoutSources.contains('Test Restaurant'), true);
    });

    test('should get items for specific checkout source', () {
      // Add products from different sources
      cartProvider.addFromStore(testProduct1, testStore);
      cartProvider.addFromRestaurant(
        testProduct2,
        restaurantId: 'restaurant_1',
        restaurantName: 'Test Restaurant',
      );
      
      final storeItems = cartProvider.getItemsForCheckoutSource('Test Store');
      final restaurantItems = cartProvider.getItemsForCheckoutSource('Test Restaurant');
      
      expect(storeItems.length, 1);
      expect(restaurantItems.length, 1);
      expect(storeItems.first.sourceName, 'Test Store');
      expect(restaurantItems.first.sourceName, 'Test Restaurant');
    });

    test('should get total for specific checkout source', () {
      // Add products from different sources
      cartProvider.addFromStore(testProduct1, testStore);
      cartProvider.addFromRestaurant(
        testProduct2,
        restaurantId: 'restaurant_1',
        restaurantName: 'Test Restaurant',
      );
      
      final storeTotal = cartProvider.getTotalForCheckoutSource('Test Store');
      final restaurantTotal = cartProvider.getTotalForCheckoutSource('Test Restaurant');
      
      expect(storeTotal, 10.0);
      expect(restaurantTotal, 15.0);
    });

    test('should clear specific source while keeping others', () {
      // Add products from different sources
      cartProvider.addFromStore(testProduct1, testStore);
      cartProvider.addFromRestaurant(
        testProduct2,
        restaurantId: 'restaurant_1',
        restaurantName: 'Test Restaurant',
      );
      
      // Clear store items
      cartProvider.clearSource(CartItemSource.store);
      
      expect(cartProvider.hasStoreItems, false);
      expect(cartProvider.hasRestaurantItems, true);
      expect(cartProvider.items.length, 1);
      expect(cartProvider.restaurantItemCount, 1);
    });

    test('should maintain separate quantities for different sources', () {
      // Add same product from different sources
      cartProvider.addFromStore(testProduct1, testStore);
      cartProvider.addFromRestaurant(
        testProduct1, // Same product, different source
        restaurantId: 'restaurant_1',
        restaurantName: 'Test Restaurant',
      );
      
      // Verify they are treated as separate items
      expect(cartProvider.items.length, 2);
      expect(cartProvider.storeItemCount, 1);
      expect(cartProvider.restaurantItemCount, 1);
      
      // Verify quantities are tracked separately
      final storeQuantity = cartProvider.getItemQuantity(testProduct1, CartItemSource.store);
      final restaurantQuantity = cartProvider.getItemQuantity(testProduct1, CartItemSource.restaurant);
      
      expect(storeQuantity, 1);
      expect(restaurantQuantity, 1);
    });
  });
} 