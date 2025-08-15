# Reusable Widgets Documentation

This directory contains reusable widgets that have been extracted from the `mart.dart` file to improve code organization and reusability.

## Available Widgets

### 1. ProductCard
A reusable product card widget that displays product information with add/remove cart functionality.

**Usage:**
```dart
ProductCard(
  name: 'Product Name',
  price: 'Rs. 100',
  category: 'Chocolate',
  image: 'assets/images/products/product.jpg',
  rating: 4.5,
  reviews: 100,
  quantity: 2,
  onAddToCart: () => addToCart(),
  onRemoveFromCart: () => removeFromCart(),
  isTrending: true,
  trendingLabel: '🔥 Hot',
  discount: '20% OFF',
)
```

**Features:**
- Product image with trending/discount badges
- Product information (name, category, price, rating)
- Cart quantity controls
- Responsive design for different screen sizes

### 2. CategoryItem
A reusable category item widget for sidebar navigation.

**Usage:**
```dart
CategoryItem(
  name: 'Category Name',
  imagePath: 'assets/images/category/category.png',
  isSelected: true,
  onTap: () => selectCategory(),
)
```

**Features:**
- Category icon and name
- Selection state styling
- Tap handling

### 3. ProductGridItem
A reusable product grid item widget for the main product grid.

**Usage:**
```dart
ProductGridItem(
  name: 'Product Name',
  onTap: () => showProductDetails(),
)
```

**Features:**
- Grid layout with product images
- Product name display
- Tap handling

### 4. BannerCarousel
A reusable banner carousel widget with auto-scroll functionality.

**Usage:**
```dart
BannerCarousel(
  images: ['image1.jpg', 'image2.jpg', 'image3.jpg'],
  autoScrollDuration: Duration(seconds: 3),
  animationDuration: Duration(milliseconds: 500),
)
```

**Features:**
- Auto-scrolling banner images
- Page indicators
- Customizable scroll timing
- Manual navigation support

### 5. CategoryRow
A reusable category row widget for displaying main categories.

**Usage:**
```dart
CategoryRow(
  categories: [
    {'name': 'Alcohol', 'image': 'assets/images/category/alcohol.png'},
    {'name': 'Snacks', 'image': 'assets/images/category/snacks.png'},
  ],
)
```

**Features:**
- Horizontal category layout
- Category icons and names
- Responsive spacing

### 6. SectionHeader
A reusable section header widget with optional action button.

**Usage:**
```dart
SectionHeader(
  title: 'Section Title',
  actionText: 'View All',
  onActionTap: () => navigateToSection(),
  actionColor: Colors.orange,
)
```

**Features:**
- Section title display
- Optional action button
- Customizable colors

### 7. ProductBottomSheet
A reusable bottom sheet widget for displaying product details.

**Usage:**
```dart
ProductBottomSheet(
  selectedCategory: 'Chocolate',
  onCategoryChanged: (category) => updateCategory(category),
  products: productList,
  categoryScrollController: scrollController,
)
```

**Features:**
- Category sidebar navigation
- Product grid display
- Dynamic scrollbar
- Responsive layout

### 8. ProductsList
A reusable horizontal scrolling products list widget.

**Usage:**
```dart
ProductsList(
  products: productList,
  quantities: cartQuantities,
  onQuantityChanged: (productKey, isAdd, isTrending: false) => updateCart(),
  isTrending: true,
)
```

**Features:**
- Horizontal scrolling layout
- Cart quantity management
- Support for trending products
- Reusable across different sections

### 9. ProductsGrid
A reusable products grid widget for the main product display.

**Usage:**
```dart
ProductsGrid(
  productNames: ['Product1', 'Product2', 'Product3'],
  onProductTap: () => showProductDetails(),
)
```

**Features:**
- Grid layout
- Product name display
- Tap handling

### 10. ExploreProductsGrid
A reusable 2-column grid widget for displaying explore products with detailed information.

**Usage:**
```dart
ExploreProductsGrid(
  products: exploreProductsList,
  onProductTap: () => showProductDetails(),
)
```

**Features:**
- 2-column grid layout
- Product images with discount and NEW badges
- Product information (name, category, price, rating, reviews)
- Original price display with strikethrough
- Responsive design
- Shadow effects and rounded corners

**Product Data Structure:**
```dart
{
  'name': 'Product Name',
  'price': 'Rs. 100',
  'originalPrice': 'Rs. 120', // Optional
  'rating': 4.5,
  'reviews': 100,
  'category': 'Chocolate',
  'image': 'assets/images/products/product.jpg',
  'discount': '20% OFF', // Optional
  'isNew': true, // Optional
}
```

## Benefits of This Organization

1. **Reusability**: All widgets can be used across different screens
2. **Maintainability**: Changes to widget logic only need to be made in one place
3. **Testability**: Individual widgets can be tested in isolation
4. **Readability**: Main screen files are cleaner and easier to understand
5. **Consistency**: Widgets maintain consistent styling and behavior across the app

## How to Use

1. Import the required widget:
```dart
import 'package:tuukatuu/presentation/widgets/product_card.dart';
```

2. Use the widget in your build method:
```dart
@override
Widget build(BuildContext context) {
  return ProductCard(
    // ... required parameters
  );
}
```

3. Customize the widget using the available parameters and callbacks.

## Adding New Widgets

When creating new reusable widgets:

1. Create a new file in the `widgets` directory
2. Follow the naming convention: `widget_name.dart`
3. Make the widget as configurable as possible using parameters
4. Add proper documentation and usage examples
5. Update this README with the new widget information
