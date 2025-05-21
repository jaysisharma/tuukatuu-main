import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/product.dart';
import '../../../state/providers/search_provider.dart';
import '../../../state/providers/cart_provider.dart';
import '../widgets/cached_image.dart';
import '../widgets/filter_bottom_sheet.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;
  final List<Product> initialResults;

  const SearchResultsScreen({
    super.key,
    required this.query,
    required this.initialResults,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> with SingleTickerProviderStateMixin {
  late List<Product> _filteredProducts;
  late List<Product> _similarProducts;
  late List<Product> _recommendations;
  final TextEditingController _searchController = TextEditingController();
  final Map<String, int> _quantities = {}; // Track quantities for each product
  late AnimationController _cartAnimationController;
  late Animation<double> _cartAnimation;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.query;
    _filteredProducts = widget.initialResults;
    _loadSimilarAndRecommendedProducts();
    // Initialize quantities to 0 for all products
    for (var product in widget.initialResults) {
      _quantities[product.id] = 0;
    }

    // Initialize animation controller
    _cartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _cartAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _cartAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _loadSimilarAndRecommendedProducts() {
    // Get the category of the first result (if any)
    final mainCategory = _filteredProducts.isNotEmpty ? _filteredProducts.first.category : null;
    
    // Find similar products (same category, excluding current results)
    _similarProducts = mainCategory != null
        ? Product.dummyProducts
            .where((p) => 
                p.category == mainCategory && 
                !_filteredProducts.contains(p))
            .take(4)
            .toList()
        : [];

    // Get recommendations (different category, sorted by rating)
    _recommendations = Product.dummyProducts
        .where((p) => 
            !_filteredProducts.contains(p) && 
            !_similarProducts.contains(p))
        .toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    _recommendations = _recommendations.take(4).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cartAnimationController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => const FilterBottomSheet(),
      ),
    ).then((value) {
      if (value == true) {
        _applyFilters();
      }
    });
  }

  void _applyFilters() {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    setState(() {
      _filteredProducts = Product.dummyProducts.where((product) {
        if (searchProvider.onlyAvailable && !product.isAvailable) return false;
        if (searchProvider.freeDelivery && product.deliveryFee > 0) return false;
        if (searchProvider.selectedCategories.isNotEmpty &&
            !searchProvider.selectedCategories.contains(product.category)) {
          return false;
        }
        if (product.price < searchProvider.minPrice ||
            product.price > searchProvider.maxPrice) {
          return false;
        }
        return true;
      }).toList();

      // Apply sorting
      switch (searchProvider.sortBy) {
        case 'Rating':
          _filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'Delivery Time':
          _filteredProducts.sort((a, b) =>
              (a.deliveryTime ?? '').compareTo(b.deliveryTime ?? ''));
          break;
        case 'Popular':
        default:
          _filteredProducts.sort((a, b) => b.reviews.compareTo(a.reviews));
          break;
      }
    });
  }

  void _updateQuantity(String productId, bool increment, Product product) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    setState(() {
      if (increment) {
        _quantities[productId] = (_quantities[productId] ?? 0) + 1;
        cartProvider.addItem(product);
        _cartAnimationController.forward().then((_) {
          _cartAnimationController.reverse();
        });
      } else {
        if ((_quantities[productId] ?? 0) > 0) {
          _quantities[productId] = _quantities[productId]! - 1;
          cartProvider.updateQuantity(product.name, _quantities[productId]!);
        }
      }
    });
  }

  Widget _buildProductCard(Product product, ThemeData theme, bool isDark) {
    final quantity = _quantities[product.id] ?? 0;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black12 : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to product details
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Add Button Overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Stack(
                    children: [
                      Image.asset(
                        product.imageUrl,
                        width: double.infinity,
                        height: 140,
                        fit: BoxFit.cover,
                      ),
                      if (product.deliveryFee == 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[500],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Free Delivery',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Add Button Overlay
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: quantity == 0
                      ? Material(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: () => _updateQuantity(product.id, true, product),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              child: const Text(
                                'ADD',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () => _updateQuantity(product.id, false, product),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                              Container(
                                constraints: const BoxConstraints(minWidth: 30),
                                alignment: Alignment.center,
                                child: Text(
                                  quantity.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => _updateQuantity(product.id, true, product),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
            // Product Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        ' (${product.reviews})',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rs ${product.price}',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final searchProvider = Provider.of<SearchProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
      floatingActionButton: ScaleTransition(
        scale: _cartAnimation,
        child: FloatingActionButton(
          onPressed: () {
            // TODO: Navigate to cart screen
          },
          backgroundColor: theme.colorScheme.primary,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_cart, color: Colors.white),
              if (cartProvider.itemCount > 0)
                Positioned(
                  right: -8,
                  top: -8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '${cartProvider.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black12
                        : Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (value) {
                          searchProvider.setQuery(value);
                          _applyFilters();
                        },
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          suffixIcon: Stack(
                            alignment: Alignment.center,
                            children: [
                              IconButton(
                                onPressed: _showFilterBottomSheet,
                                icon: const Icon(Icons.tune),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              if (searchProvider.hasActiveFilters)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No results found',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try different keywords or filters',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Search Results',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GridView.builder(
                            padding: const EdgeInsets.all(16),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.7,
                            ),
                            itemCount: _filteredProducts.length,
                            itemBuilder: (context, index) {
                              return _buildProductCard(
                                _filteredProducts[index],
                                theme,
                                isDark,
                              );
                            },
                          ),
                          if (_similarProducts.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                              child: Text(
                                'Similar Products',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 280,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                scrollDirection: Axis.horizontal,
                                itemCount: _similarProducts.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 180,
                                    margin: const EdgeInsets.only(right: 16),
                                    child: _buildProductCard(
                                      _similarProducts[index],
                                      theme,
                                      isDark,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                          if (_recommendations.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                              child: Text(
                                'You May Also Like',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 280,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                scrollDirection: Axis.horizontal,
                                itemCount: _recommendations.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 180,
                                    margin: const EdgeInsets.only(right: 16),
                                    child: _buildProductCard(
                                      _recommendations[index],
                                      theme,
                                      isDark,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
} 