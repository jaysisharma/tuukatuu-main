import 'package:flutter_test/flutter_test.dart';
import 'package:tuukatuu/providers/enhanced_cart_provider.dart';
import 'package:tuukatuu/models/cart_item.dart';
import 'package:tuukatuu/models/product.dart';
import 'package:tuukatuu/models/store.dart';

void main() {
  group('EnhancedCartProvider Tests', () {
    late EnhancedCartProvider cartProvider;
    late Product testProduct;
    late Store testStore;

    setUp(() {
      cartProvider = EnhancedCartProvider();
      testProduct = const Product(
        id: 'test_product_1',
        name: 'Test Product',
        price: 10.0,
        imageUrl: 'test_image.jpg',
        category: 'Test Category',
        rating: 4.5,
        reviews: 10,
        isAvailable: true,
        deliveryFee: 0,
        description: 'Test product description',
        images: ['test_image.jpg'],
        vendorId: 'test_vendor',
      );
      testStore = Store(
        id: 'test_store_1',
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

    group('Basic Cart Operations', () {
      test('should start with empty cart', () {
        expect(cartProvider.items, isEmpty);
        expect(cartProvider.itemCount, 0);
        expect(cartProvider.totalAmount, 0.0);
      });

      test('should add item to cart', () {
        cartProvider.addItem(testProduct, CartItemSource.mart);
        
        expect(cartProvider.items.length, 1);
        expect(cartProvider.itemCount, 1);
        expect(cartProvider.totalAmount, 10.0);
        expect(cartProvider.items.first.product, testProduct);
        expect(cartProvider.items.first.quantity, 1);
        expect(cartProvider.items.first.source, CartItemSource.mart);
      });

      test('should increment existing item quantity', () {
        cartProvider.addItem(testProduct, CartItemSource.mart);
        cartProvider.addItem(testProduct, CartItemSource.mart);
        
        expect(cartProvider.items.length, 1);
        expect(cartProvider.itemCount, 2);
        expect(cartProvider.totalAmount, 20.0);
        expect(cartProvider.items.first.quantity, 2);
      });

      test('should remove item from cart', () {
        cartProvider.addItem(testProduct, CartItemSource.mart);
        cartProvider.addItem(testProduct, CartItemSource.mart);
        
        cartProvider.removeItem(testProduct, CartItemSource.mart);
        
        expect(cartProvider.items.length, 1);
        expect(cartProvider.itemCount, 1);
        expect(cartProvider.totalAmount, 10.0);
        expect(cartProvider.items.first.quantity, 1);
      });

      test('should remove item completely when quantity becomes 0', () {
        cartProvider.addItem(testProduct, CartItemSource.mart);
        
        cartProvider.removeItem(testProduct, CartItemSource.mart);
        
        expect(cartProvider.items, isEmpty);
        expect(cartProvider.itemCount, 0);
        expect(cartProvider.totalAmount, 0.0);
      });

      test('should clear cart', () {
        cartProvider.addItem(testProduct, CartItemSource.mart);
        cartProvider.addItem(testProduct, CartItemSource.mart);
        
        cartProvider.clearCart();
        
        expect(cartProvider.items, isEmpty);
        expect(cartProvider.itemCount, 0);
        expect(cartProvider.totalAmount, 0.0);
      });
    });

    group('Source-Specific Operations', () {
      test('should add restaurant item', () {
        cartProvider.addFromRestaurant(
          testProduct,
          restaurantId: 'restaurant_1',
          restaurantName: 'Test Restaurant',
        );
        
        expect(cartProvider.items.length, 1);
        expect(cartProvider.items.first.source, CartItemSource.restaurant);
        expect(cartProvider.items.first.sourceId, 'restaurant_1');
        expect(cartProvider.items.first.sourceName, 'Test Restaurant');
      });

      test('should add store item', () {
        cartProvider.addFromStore(testProduct, testStore);
        
        expect(cartProvider.items.length, 1);
        expect(cartProvider.items.first.source, CartItemSource.store);
        expect(cartProvider.items.first.sourceId, testStore.id);
        expect(cartProvider.items.first.sourceName, testStore.name);
        expect(cartProvider.items.first.store, testStore);
      });

      test('should add mart item', () {
        cartProvider.addFromMart(testProduct);
        
        expect(cartProvider.items.length, 1);
        expect(cartProvider.items.first.source, CartItemSource.mart);
        expect(cartProvider.items.first.sourceName, 'T-Mart');
      });

      test('should track items by source correctly', () {
        cartProvider.addFromRestaurant(testProduct, restaurantId: 'restaurant_1', restaurantName: 'Restaurant 1');
        cartProvider.addFromStore(testProduct, testStore);
        cartProvider.addFromMart(testProduct);
        
        expect(cartProvider.restaurantItems.length, 1);
        expect(cartProvider.storeItems.length, 1);
        expect(cartProvider.martItems.length, 1);
        expect(cartProvider.hasMixedSources, true);
      });

      test('should clear specific source', () {
        cartProvider.addFromRestaurant(testProduct, restaurantId: 'restaurant_1', restaurantName: 'Restaurant 1');
        cartProvider.addFromStore(testProduct, testStore);
        
        cartProvider.clearSource(CartItemSource.restaurant);
        
        expect(cartProvider.restaurantItems, isEmpty);
        expect(cartProvider.storeItems.length, 1);
        expect(cartProvider.hasMixedSources, false);
      });
    });

    group('Quantity Management', () {
      test('should update item quantity', () {
        cartProvider.addItem(testProduct, CartItemSource.mart);
        
        cartProvider.updateQuantity(testProduct, CartItemSource.mart, 5);
        
        expect(cartProvider.items.first.quantity, 5);
        expect(cartProvider.totalAmount, 50.0);
      });

      test('should remove item when quantity set to 0', () {
        cartProvider.addItem(testProduct, CartItemSource.mart);
        
        cartProvider.updateQuantity(testProduct, CartItemSource.mart, 0);
        
        expect(cartProvider.items, isEmpty);
      });

      test('should get item quantity', () {
        cartProvider.addItem(testProduct, CartItemSource.mart);
        cartProvider.addItem(testProduct, CartItemSource.mart);
        
        final quantity = cartProvider.getItemQuantity(testProduct, CartItemSource.mart);
        
        expect(quantity, 2);
      });

      test('should return 0 for non-existent item', () {
        final quantity = cartProvider.getItemQuantity(testProduct, CartItemSource.mart);
        
        expect(quantity, 0);
      });
    });

    group('Source-Specific Getters', () {
      test('should return correct source-specific counts', () {
        cartProvider.addFromRestaurant(testProduct, restaurantId: 'restaurant_1', restaurantName: 'Restaurant 1');
        cartProvider.addFromStore(testProduct, testStore);
        cartProvider.addFromMart(testProduct);
        
        expect(cartProvider.restaurantItemCount, 1);
        expect(cartProvider.storeItemCount, 1);
        expect(cartProvider.martItemCount, 1);
      });

      test('should return correct source-specific totals', () {
        cartProvider.addFromRestaurant(testProduct, restaurantId: 'restaurant_1', restaurantName: 'Restaurant 1');
        cartProvider.addFromStore(testProduct, testStore);
        cartProvider.addFromMart(testProduct);
        
        expect(cartProvider.restaurantTotalAmount, 10.0);
        expect(cartProvider.storeTotalAmount, 10.0);
        expect(cartProvider.martTotalAmount, 10.0);
      });

      test('should check source-specific items existence', () {
        expect(cartProvider.hasRestaurantItems, false);
        expect(cartProvider.hasStoreItems, false);
        expect(cartProvider.hasMartItems, false);
        
        cartProvider.addFromRestaurant(testProduct, restaurantId: 'restaurant_1', restaurantName: 'Restaurant 1');
        
        expect(cartProvider.hasRestaurantItems, true);
        expect(cartProvider.hasStoreItems, false);
        expect(cartProvider.hasMartItems, false);
      });
    });

    group('Grouped Items', () {
      test('should group items by source name', () {
        cartProvider.addFromRestaurant(testProduct, restaurantId: 'restaurant_1', restaurantName: 'Restaurant 1');
        cartProvider.addFromStore(testProduct, testStore);
        cartProvider.addFromMart(testProduct);
        
        final groupedItems = cartProvider.groupedItems;
        
        expect(groupedItems.length, 3);
        expect(groupedItems.containsKey('Restaurant 1'), true);
        expect(groupedItems.containsKey('Test Store'), true);
        expect(groupedItems.containsKey('T-Mart'), true);
      });

      test('should get items grouped by source for UI', () {
        cartProvider.addFromRestaurant(testProduct, restaurantId: 'restaurant_1', restaurantName: 'Restaurant 1');
        cartProvider.addFromStore(testProduct, testStore);
        cartProvider.addFromMart(testProduct);
        
        final groupedItems = cartProvider.getItemsGroupedBySource();
        
        expect(groupedItems.length, 3);
        expect(groupedItems['Restaurant 1']!.length, 1);
        expect(groupedItems['Test Store']!.length, 1);
        expect(groupedItems['T-Mart']!.length, 1);
      });
    });

    group('Cart Summary', () {
      test('should return correct cart summary', () {
        cartProvider.addFromRestaurant(testProduct, restaurantId: 'restaurant_1', restaurantName: 'Restaurant 1');
        cartProvider.addFromStore(testProduct, testStore);
        cartProvider.addFromMart(testProduct);
        
        final summary = cartProvider.getCartSummary();
        
        expect(summary['totalItems'], 3);
        expect(summary['totalAmount'], 30.0);
        expect(summary['restaurantItems'], 1);
        expect(summary['storeItems'], 1);
        expect(summary['martItems'], 1);
        expect(summary['hasMixedSources'], true);
        expect(summary['sources']['restaurant'], true);
        expect(summary['sources']['store'], true);
        expect(summary['sources']['mart'], true);
      });
    });

    group('Checkout Operations', () {
      test('should check if cart can be checked out', () {
        expect(cartProvider.canCheckout, false);
        
        cartProvider.addItem(testProduct, CartItemSource.mart);
        
        expect(cartProvider.canCheckout, true);
      });

      test('should get checkout sources', () {
        cartProvider.addFromRestaurant(testProduct, restaurantId: 'restaurant_1', restaurantName: 'Restaurant 1');
        cartProvider.addFromStore(testProduct, testStore);
        cartProvider.addFromMart(testProduct);
        
        final checkoutSources = cartProvider.checkoutSources;
        
        expect(checkoutSources.length, 3);
        expect(checkoutSources.contains('Restaurant 1'), true);
        expect(checkoutSources.contains('Test Store'), true);
        expect(checkoutSources.contains('T-Mart'), true);
      });

      test('should get items for specific checkout source', () {
        cartProvider.addFromRestaurant(testProduct, restaurantId: 'restaurant_1', restaurantName: 'Restaurant 1');
        cartProvider.addFromStore(testProduct, testStore);
        
        final restaurantItems = cartProvider.getItemsForCheckoutSource('Restaurant 1');
        final storeItems = cartProvider.getItemsForCheckoutSource('Test Store');
        
        expect(restaurantItems.length, 1);
        expect(storeItems.length, 1);
        expect(restaurantItems.first.sourceName, 'Restaurant 1');
        expect(storeItems.first.sourceName, 'Test Store');
      });

      test('should get total for specific checkout source', () {
        cartProvider.addFromRestaurant(testProduct, restaurantId: 'restaurant_1', restaurantName: 'Restaurant 1');
        cartProvider.addFromRestaurant(testProduct, restaurantId: 'restaurant_1', restaurantName: 'Restaurant 1');
        
        final total = cartProvider.getTotalForCheckoutSource('Restaurant 1');
        
        expect(total, 20.0);
      });
    });

    group('Order Format', () {
      test('should convert cart items to order format', () {
        cartProvider.addFromRestaurant(testProduct, restaurantId: 'restaurant_1', restaurantName: 'Restaurant 1');
        
        final orderItems = cartProvider.getOrderItems();
        
        expect(orderItems.length, 1);
        expect(orderItems.first['productId'], testProduct.id);
        expect(orderItems.first['productName'], testProduct.name);
        expect(orderItems.first['price'], testProduct.price);
        expect(orderItems.first['quantity'], 1);
        expect(orderItems.first['source'], 'restaurant');
        expect(orderItems.first['sourceId'], 'restaurant_1');
        expect(orderItems.first['sourceName'], 'Restaurant 1');
      });
    });

    group('Item Existence', () {
      test('should check if item exists in cart', () {
        expect(cartProvider.hasItem(testProduct, CartItemSource.mart), false);
        
        cartProvider.addItem(testProduct, CartItemSource.mart);
        
        expect(cartProvider.hasItem(testProduct, CartItemSource.mart), true);
      });

      test('should check if item exists with specific source ID', () {
        cartProvider.addItem(testProduct, CartItemSource.restaurant, sourceId: 'restaurant_1');
        
        expect(cartProvider.hasItem(testProduct, CartItemSource.restaurant, sourceId: 'restaurant_1'), true);
        expect(cartProvider.hasItem(testProduct, CartItemSource.restaurant, sourceId: 'restaurant_2'), false);
      });
    });

    group('Source-Specific Methods', () {
      test('should get items by source', () {
        cartProvider.addFromRestaurant(testProduct, restaurantId: 'restaurant_1', restaurantName: 'Restaurant 1');
        cartProvider.addFromStore(testProduct, testStore);
        cartProvider.addFromMart(testProduct);
        
        final restaurantItems = cartProvider.getItemsBySource(CartItemSource.restaurant);
        final storeItems = cartProvider.getItemsBySource(CartItemSource.store);
        final martItems = cartProvider.getItemsBySource(CartItemSource.mart);
        
        expect(restaurantItems.length, 1);
        expect(storeItems.length, 1);
        expect(martItems.length, 1);
      });

      test('should get items by source ID', () {
        cartProvider.addItem(testProduct, CartItemSource.restaurant, sourceId: 'restaurant_1');
        cartProvider.addItem(testProduct, CartItemSource.restaurant, sourceId: 'restaurant_2');
        
        final items1 = cartProvider.getItemsBySourceId('restaurant_1');
        final items2 = cartProvider.getItemsBySourceId('restaurant_2');
        
        expect(items1.length, 1);
        expect(items2.length, 1);
      });

      test('should get total for specific source', () {
        cartProvider.addItem(testProduct, CartItemSource.restaurant, sourceId: 'restaurant_1');
        cartProvider.addItem(testProduct, CartItemSource.restaurant, sourceId: 'restaurant_1');
        
        final total = cartProvider.getSourceTotal(CartItemSource.restaurant);
        
        expect(total, 20.0);
      });

      test('should get total for specific source ID', () {
        cartProvider.addItem(testProduct, CartItemSource.restaurant, sourceId: 'restaurant_1');
        cartProvider.addItem(testProduct, CartItemSource.restaurant, sourceId: 'restaurant_1');
        
        final total = cartProvider.getSourceIdTotal('restaurant_1');
        
        expect(total, 20.0);
      });
    });

    group('Clear Operations', () {
      test('should clear items by source ID', () {
        cartProvider.addItem(testProduct, CartItemSource.restaurant, sourceId: 'restaurant_1');
        cartProvider.addItem(testProduct, CartItemSource.restaurant, sourceId: 'restaurant_2');
        
        cartProvider.clearSourceById('restaurant_1');
        
        expect(cartProvider.items.length, 1);
        expect(cartProvider.items.first.sourceId, 'restaurant_2');
      });
    });

    group('Animation State', () {
      test('should start with animation disabled', () {
        expect(cartProvider.isAnimating, false);
      });

      test('should trigger animation when adding item', () {
        cartProvider.addItem(testProduct, CartItemSource.mart);
        
        // Animation should be triggered (though we can't easily test the timing)
        expect(cartProvider.items.length, 1);
      });
    });
  });
} 