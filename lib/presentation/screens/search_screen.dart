import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuukatuu/models/product.dart';
import '../../../state/providers/search_provider.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/cached_image.dart';
import 'search_results_screen.dart';
import 'product_details_screen.dart';
import '../../services/api_service.dart';
import '../../providers/unified_cart_provider.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuukatuu/models/store.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<Product> _searchResults = [];
  List<String> _searchSuggestions = [];
  List<String> _recentSearches = [];
  List<Product> _popularProducts = [];
  bool _loading = false;
  bool _hasSearched = false;
  Timer? _debounce;
  final String _recentSearchesKey = 'recent_searches';

  // T-Mart color scheme
  static const Color tmartGreen = Color(0xFF2E7D32);
  static const Color tmartLightGreen = Color(0xFF4CAF50);
  
  // Swiggy color scheme
  static const Color swiggyOrange = Color(0xFFFC8019);
  static const Color swiggyLight = Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _loadPopularProducts();
    _testApiConnection();
    
    // Auto focus the search field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = prefs.getStringList(_recentSearchesKey) ?? [];
      setState(() {
        _recentSearches = searches.take(10).toList();
      });
    } catch (e) {
      print('Error loading recent searches: $e');
    }
  }

  Future<void> _saveRecentSearch(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = prefs.getStringList(_recentSearchesKey) ?? [];
      
      // Remove if already exists and add to beginning
      searches.remove(query);
      searches.insert(0, query);
      
      // Keep only last 10 searches
      final updatedSearches = searches.take(10).toList();
      await prefs.setStringList(_recentSearchesKey, updatedSearches);
      
      setState(() {
        _recentSearches = updatedSearches;
      });
    } catch (e) {
      print('Error saving recent search: $e');
    }
  }

  Future<void> _loadPopularProducts() async {
    try {
      print('🔍 Search Screen: Loading popular products...');
      final products = await ApiService.getPopularProducts(limit: 6);
      
      if (products.isNotEmpty) {
        setState(() {
          _popularProducts = products;
        });
        print('✅ Search Screen: Loaded ${products.length} popular products');
      } else {
        print('❌ Search Screen: No popular products found, using fallback');
        setState(() {
          _popularProducts = Product.dummyProducts.take(6).toList();
        });
      }
    } catch (e) {
      print('❌ Search Screen: Error loading popular products: $e');
      // Fallback to dummy products
      setState(() {
        _popularProducts = Product.dummyProducts.take(6).toList();
      });
    }
  }

  Future<void> _testApiConnection() async {
    try {
      print('🔍 Testing API connection...');
      final isConnected = await ApiService.testConnection();
      if (isConnected) {
        print('✅ API connection successful');
      } else {
        print('❌ API connection failed');
      }
    } catch (e) {
      print('❌ API connection test error: $e');
    }
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
    );
  }

  void _performSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.trim().isEmpty) {
        setState(() {
          _searchResults = [];
          _searchSuggestions = [];
          _hasSearched = false;
          _loading = false;
        });
        return;
      }

      setState(() { 
        _loading = true;
        _hasSearched = true;
      });

      try {
        print('🔍 Search Screen: Searching for "$query"');
        final products = await ApiService.searchProducts(query.trim(), limit: 10);
        
        if (products.isNotEmpty) {
          setState(() {
            _searchResults = products;
            _searchSuggestions = products.map((p) => p.name).toList();
            _loading = false;
          });
          print('✅ Search Screen: Found ${products.length} products for "$query"');
        } else {
          // Fallback to dummy products if API returns empty
          print('🔍 Search Screen: API returned empty, trying fallback search');
          final fallbackProducts = _performFallbackSearch(query.trim());
          setState(() {
            _searchResults = fallbackProducts;
            _searchSuggestions = fallbackProducts.map((p) => p.name).toList();
            _loading = false;
          });
          print('✅ Search Screen: Found ${fallbackProducts.length} fallback products for "$query"');
        }
      } catch (e) {
        print('❌ Search Screen: Search error for "$query": $e');
        // Use fallback search on error
        final fallbackProducts = _performFallbackSearch(query.trim());
        setState(() {
          _searchResults = fallbackProducts;
          _searchSuggestions = fallbackProducts.map((p) => p.name).toList();
          _loading = false;
        });
        print('✅ Search Screen: Found ${fallbackProducts.length} fallback products for "$query"');
      }
    });
  }

  List<Product> _performFallbackSearch(String query) {
    // Fallback search using dummy products
    final lowercaseQuery = query.toLowerCase();
    return Product.dummyProducts
        .where((product) => 
            product.name.toLowerCase().contains(lowercaseQuery) ||
            product.category.toLowerCase().contains(lowercaseQuery) ||
            product.description.toLowerCase().contains(lowercaseQuery))
        .take(10)
        .toList();
  }

  void _navigateToProductDetails(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
      ),
    );
  }

  void _addToCart(Product product) {
    final cartProvider = Provider.of<UnifiedCartProvider>(context, listen: false);
    
    // Create a store object for the product using proper vendor information
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
    
    // Add to unified cart as store item with proper store information
    cartProvider.addStoreItem(
      id: product.id,
      name: product.name,
      price: product.price,
      quantity: 1,
      image: product.imageUrl,
      vendorId: product.vendorId,
      vendorName: product.vendorName,
      store: store,
    );
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        backgroundColor: swiggyOrange,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, '/multi-store-cart');
          },
        ),
      ),
    );
  }

  void _navigateToResults(String query) async {
    if (query.trim().isEmpty) return;
    
    // Save to recent searches
    await _saveRecentSearch(query.trim());
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(
          query: query.trim(),
          initialResults: _searchResults,
        ),
      ),
    );
  }

  void _clearRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentSearchesKey);
      setState(() {
        _recentSearches = [];
      });
    } catch (e) {
      print('Error clearing recent searches: $e');
    }
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black12 : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: swiggyOrange),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: swiggyOrange.withOpacity(0.3)),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: _performSearch,
                onSubmitted: _navigateToResults,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Search for groceries, snacks, beverages...',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: swiggyOrange,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey[600],
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _showFilterBottomSheet,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: swiggyOrange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_recentSearches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _clearRecentSearches,
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    color: swiggyOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentSearches.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                _searchController.text = _recentSearches[index];
                _navigateToResults(_recentSearches[index]);
              },
              leading: Icon(
                Icons.history,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              title: Text(_recentSearches[index]),
              trailing: Icon(
                Icons.north_west,
                size: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            );
          },
        ),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildPopularProducts() {
    final theme = Theme.of(context);
    
    if (_popularProducts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Text(
            'Popular Products',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _popularProducts.length,
            itemBuilder: (context, index) {
              final product = _popularProducts[index];
              return GestureDetector(
                onTap: () {
                  _navigateToProductDetails(product);
                },
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedImage(
                          imageUrl: product.imageUrl,
                          width: 80,
                          height: 80,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rs ${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: swiggyOrange,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildSearchSuggestions() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_searchSuggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Suggestions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _searchSuggestions.length,
          itemBuilder: (context, index) {
            final suggestion = _searchSuggestions[index];
            return ListTile(
              onTap: () {
                _searchController.text = suggestion;
                _navigateToResults(suggestion);
              },
              leading: Icon(
                Icons.search,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              title: Text(suggestion),
              trailing: Icon(
                Icons.north_west,
                size: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            );
          },
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Searching...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchResults.isEmpty && _hasSearched) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No products found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try searching with different keywords',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  _performSearch('');
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Clear Search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: tmartGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_searchResults.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Search Results (${_searchResults.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _navigateToResults(_searchController.text),
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: swiggyOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final product = _searchResults[index];
              return _buildProductTile(product);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildProductTile(Product product) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedImage(
          imageUrl: product.imageUrl,
          width: 56,
          height: 56,
        ),
      ),
      title: Text(
        product.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            'Rs ${product.price.toStringAsFixed(2)}',
            style: TextStyle(
              color: swiggyOrange,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                Icons.star,
                size: 16,
                color: Colors.amber[600],
              ),
              const SizedBox(width: 4),
              Text(
                '${product.rating} (${product.reviews})',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              if (product.deliveryFee == 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Free Delivery',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _addToCart(product),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: swiggyOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Add to Cart',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: () {
        // Navigate to product detail or add to cart
        _navigateToProductDetails(product);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (_searchController.text.isEmpty) ...[
                      _buildRecentSearches(),
                      _buildPopularProducts(),
                    ] else ...[
                      _buildSearchSuggestions(),
                      _buildSearchResults(),
                    ],
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