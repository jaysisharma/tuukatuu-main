// import 'package:flutter_test/flutter_test.dart';
// import '../lib/providers/enhanced_cart_provider.dart';
// import '../lib/models/cart_item.dart';
// import '../lib/models/product.dart';
// import '../lib/models/store.dart';

// void main() {
//   group('Store Details Quantity Controls', () {
//     late EnhancedCartProvider cartProvider;
//     late Product testProduct;
//     late Store testStore;

//     setUp(() {
//       cartProvider = EnhancedCartProvider();
//       testProduct = Product(
//         id: 'test-product-1',
//         name: 'Test Product',
//         price: 10.0,
//         imageUrl: 'https://example.com/image.jpg',
//         vendorId: 'test-store-1',
//       );
//       testStore = Store(
//         id: 'test-store-1',
//         name: 'Test Store',
//         description: 'A test store',
//         image: 'https://example.com/store.jpg',
//         banner: 'https://example.com/banner.jpg',
//         address: '123 Test St',
//         phone: '+1234567890',
//         email: 'test@store.com',
//         rating: 4.5,
//         reviews: 100,
//         isFeatured: false,
//         isActive: true,
//         deliveryTime: '30-45 min',
//         minimumOrder: 0.0,
//         deliveryFee: 2.0,
//         categories: ['food'],
//       );
//     });

//     test('should show quantity 0 initially', () {
//       final quantity = cartProvider.getItemQuantity(
//         testProduct, 
//         CartItemSource.store, 
//         sourceId: testStore.id
//       );
//       expect(quantity, 0);
//     });

//     test('should show + button when quantity is 0', () {
//       final quantity = cartProvider.getItemQuantity(
//         testProduct, 
//         CartItemSource.store, 
//         sourceId: testStore.id
//       );
//       expect(quantity == 0, true);
//     });

//     test('should add item and show quantity controls when + is tapped', () {
//       // Add item to cart
//       cartProvider.addFromStore(testProduct, testStore);
      
//       final quantity = cartProvider.getItemQuantity(
//         testProduct, 
//         CartItemSource.store, 
//         sourceId: testStore.id
//       );
//       expect(quantity, 1);
//     });

//     test('should update quantity when + button in quantity controls is tapped', () {
//       // Add item first
//       cartProvider.addFromStore(testProduct, testStore);
      
//       // Increment quantity
//       cartProvider.updateQuantity(
//         testProduct, 
//         CartItemSource.store, 
//         2, 
//         sourceId: testStore.id
//       );
      
//       final quantity = cartProvider.getItemQuantity(
//         testProduct, 
//         CartItemSource.store, 
//         sourceId: testStore.id
//       );
//       expect(quantity, 2);
//     });

//     test('should decrease quantity when - button is tapped', () {
//       // Add item and set quantity to 2
//       cartProvider.addFromStore(testProduct, testStore);
//       cartProvider.updateQuantity(
//         testProduct, 
//         CartItemSource.store, 
//         2, 
//         sourceId: testStore.id
//       );
      
//       // Decrease quantity
//       cartProvider.updateQuantity(
//         testProduct, 
//         CartItemSource.store, 
//         1, 
//         sourceId: testStore.id
//       );
      
//       final quantity = cartProvider.getItemQuantity(
//         testProduct, 
//         CartItemSource.store, 
//         sourceId: testStore.id
//       );
//       expect(quantity, 1);
//     });

//     test('should remove item when quantity reaches 0 via - button', () {
//       // Add item first
//       cartProvider.addFromStore(testProduct, testStore);
      
//       // Remove item by setting quantity to 0
//       cartProvider.removeItem(
//         testProduct, 
//         CartItemSource.store, 
//         sourceId: testStore.id
//       );
      
//       final quantity = cartProvider.getItemQuantity(
//         testProduct, 
//         CartItemSource.store, 
//         sourceId: testStore.id
//       );
//       expect(quantity, 0);
//     });

//     test('should show + button again after item is removed', () {
//       // Add item, then remove it
//       cartProvider.addFromStore(testProduct, testStore);
//       cartProvider.removeItem(
//         testProduct, 
//         CartItemSource.store, 
//         sourceId: testStore.id
//       );
      
//       final quantity = cartProvider.getItemQuantity(
//         testProduct, 
//         CartItemSource.store, 
//         sourceId: testStore.id
//       );
//       expect(quantity == 0, true);
//     });
//   });
// }
