import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../models/store.dart';
import '../../providers/search_provider.dart';
import '../../providers/enhanced_cart_provider.dart';
import '../../models/cart_item.dart';
import '../widgets/cached_image.dart';
import '../../widgets/global_cart_fab.dart';
import '../../services/api_service.dart';
import 'dart:async';
import 'product_details_screen.dart';

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
  bool _loading = false;
  bool _loadingSimilar = false;
  bool _loadingRecommendations = false;
  Timer? _debounce;

  // Swiggy color scheme
  static const Color swiggyOrange = Color(0xFFFC8019);

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.query;
    _filteredProducts = widget.initialResults;
    
    // Initialize quantities from unified cart
    _syncQuantitiesWithCart();

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
    _searchController.addListener(_onSearchChanged);
    
    // Load similar and recommended products after initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSimilarAndRecommendedProducts();
    });
  }

  void _syncQuantitiesWithCart() {
    final cartProvider = Provider.of<EnhancedCartProvider>(context, listen: false);
    
    for (var product in _filteredProducts) {
      final quantity = cartProvider.getItemQuantity(product, CartItemSource.store);
      _quantities[product.id] = quantity;
    }
  }


  void _navigateToProductDetails(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
      ),
    ).then((_) {
      // Refresh quantities when returning from product details
      _syncQuantitiesWithCart();
    });
  }

  Future<void> _loadSimilarAndRecommendedProducts() async {
    try {
      print('🔍 Search Results: Loading similar and recommended products');
      
      // Get similar products based on the first result's category
      if (_filteredProducts.isNotEmpty) {
        setState(() {
          _loadingSimilar = true;
        });
        
        final firstProduct = _filteredProducts.first;
        print('🔍 Search Results: Loading similar products for category: ${firstProduct.category}');
        
        try {
          final similarProducts = await ApiService.getSimilarProducts(firstProduct.id, limit: 4);
          if (similarProducts.isNotEmpty) {
            setState(() {
              _similarProducts = similarProducts;
              _loadingSimilar = false;
            });
            print('✅ Search Results: Loaded ${similarProducts.length} similar products from API');
          } else {
            // Fallback to dummy products
            _loadFallbackSimilarProducts(firstProduct.category);
            setState(() {
              _loadingSimilar = false;
            });
          }
        } catch (e) {
          print('❌ Search Results: Error loading similar products from API: $e');
          _loadFallbackSimilarProducts(firstProduct.category);
          setState(() {
            _loadingSimilar = false;
          });
        }
      } else {
        setState(() {
          _similarProducts = [];
          _loadingSimilar = false;
        });
      }

      // Get recommendations
      setState(() {
        _loadingRecommendations = true;
      });
      
      try {
        final recommendations = await ApiService.getRecommendations(limit: 4);
        if (recommendations.isNotEmpty) {
          setState(() {
            _recommendations = recommendations;
            _loadingRecommendations = false;
          });
          print('✅ Search Results: Loaded ${recommendations.length} recommendations from API');
        } else {
          // Fallback to dummy products
          _loadFallbackRecommendations();
          setState(() {
            _loadingRecommendations = false;
          });
        }
      } catch (e) {
        print('❌ Search Results: Error loading recommendations from API: $e');
        _loadFallbackRecommendations();
        setState(() {
          _loadingRecommendations = false;
        });
      }
    } catch (e) {
      print('❌ Search Results: Error in _loadSimilarAndRecommendedProducts: $e');
      _loadFallbackSimilarProducts(null);
      _loadFallbackRecommendations();
      setState(() {
        _loadingSimilar = false;
        _loadingRecommendations = false;
      });
    }
  }

  void _loadFallbackSimilarProducts(String? category) {
    if (category == null) {
      setState(() {
        _similarProducts = [];
      });
      return;
    }

    // Find similar products from dummy data (same category, excluding current results)
    final fallbackSimilar = Product.dummyProducts
            .where((p) => 
            p.category == category && 
                !_filteredProducts.contains(p))
            .take(4)
        .toList();

    setState(() {
      _similarProducts = fallbackSimilar;
    });
    print('✅ Search Results: Loaded ${fallbackSimilar.length} fallback similar products');
  }

  void _loadFallbackRecommendations() {
    // Get recommendations from dummy data (different category, sorted by rating)
    final fallbackRecommendations = Product.dummyProducts
        .where((p) => 
            !_filteredProducts.contains(p) && 
            !_similarProducts.contains(p))
        .toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    
    final recommendations = fallbackRecommendations.take(4).toList();

    setState(() {
      _recommendations = recommendations;
    });
    print('✅ Search Results: Loaded ${recommendations.length} fallback recommendations');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cartAnimationController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final query = _searchController.text.trim();
      if (query.isEmpty) {
        setState(() {
          _filteredProducts = [];
          _loading = false;
        });
        return;
      }
      setState(() { _loading = true; });
      try {
        print('🔍 Search Results: Searching for "$query"');
        final products = await ApiService.searchProducts(query, limit: 20);
        
        setState(() {
          _filteredProducts = products;
          _loading = false;
        });
        
        print('✅ Search Results: Found ${products.length} products for "$query"');
        
        // Reload similar and recommended products based on new results
        _loadSimilarAndRecommendedProducts();
      } catch (e) {
        print('❌ Search Results: Search error for "$query": $e');
        setState(() {
          _filteredProducts = [];
          _loading = false;
        });
      }
    });
  }



  void _updateQuantity(String productId, bool increment, Product product) {
    final cartProvider = Provider.of<EnhancedCartProvider>(context, listen: false);
    
    setState(() {
      if (increment) {
        _quantities[productId] = (_quantities[productId] ?? 0) + 1;
        
        // Add to enhanced cart as store item
        final store = Store(
          id: product.vendorId,
          name: product.vendorName, // Use proper vendor name instead of category
          description: product.vendorDescription,
          image: product.vendorImage,
          banner: product.vendorImage,
          address: product.vendor?['storeAddress'] ?? 'Store Address',
          phone: product.vendor?['phone'] ?? 'Store Phone',
          email: product.vendor?['email'] ?? 'store@example.com',
          rating: (product.vendor?['storeRating'] ?? product.rating).toDouble(),
          reviews: product.vendor?['storeReviews'] ?? product.reviews,
          isFeatured: product.vendor?['isFeatured'] ?? true,
          isActive: true,
          deliveryTime: '30-45 min',
          minimumOrder: 0.0,
          deliveryFee: product.deliveryFee,
          categories: product.vendor?['storeCategories']?.cast<String>() ?? [product.category],
        );
        cartProvider.addFromStore(product, store);
        
        _cartAnimationController.forward().then((_) {
          _cartAnimationController.reverse();
        });
        
        // Show success message
        // Item added to cart silently
      } else {
        if ((_quantities[productId] ?? 0) > 0) {
          _quantities[productId] = _quantities[productId]! - 1;
          
          // Update quantity in enhanced cart
          cartProvider.updateQuantity(product, CartItemSource.store, _quantities[productId]!);
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
          // Navigate to product details screen
          _navigateToProductDetails(product);
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
                      CachedImage(
                        imageUrl: product.imageUrl, 
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
                          color: swiggyOrange,
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
                            color: swiggyOrange,
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
                    style: const TextStyle(
                      color: swiggyOrange,
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
    Provider.of<SearchProvider>(context);
    Provider.of<EnhancedCartProvider>(context);

    // Sync quantities when cart changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncQuantitiesWithCart();
    });

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
      floatingActionButton: ScaleTransition(
        scale: _cartAnimation,
        child: const GlobalCartFAB(
          heroTag: 'search_results_fab',
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
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Searching for products...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _filteredProducts.isEmpty
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
                          if (_similarProducts.isNotEmpty || _loadingSimilar) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                'Similar Products',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                                  if (!_loadingSimilar)
                                    Text(
                                      '${_similarProducts.length} items',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (_loadingSimilar)
                              const Padding(
                                padding: EdgeInsets.all(32),
                                child: Center(
                                  child: Column(
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 8),
                                      Text('Loading similar products...'),
                                    ],
                                  ),
                                ),
                              )
                            else
                            SizedBox(
                                height: 300,
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
                          if (_recommendations.isNotEmpty || _loadingRecommendations) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                'You May Also Like',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                                  if (!_loadingRecommendations)
                                    Text(
                                      '${_recommendations.length} items',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (_loadingRecommendations)
                              const Padding(
                                padding: EdgeInsets.all(32),
                                child: Center(
                                  child: Column(
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 8),
                                      Text('Loading recommendations...'),
                                    ],
                                  ),
                                ),
                              )
                            else
                            SizedBox(
                                height: 300,
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