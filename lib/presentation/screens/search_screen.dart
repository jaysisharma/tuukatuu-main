import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuukatuu/models/product.dart';
import '../../../state/providers/search_provider.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/cached_image.dart';
import 'search_results_screen.dart';
import '../../services/api_service.dart';
import 'dart:async';

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
  List<String> _recentSearches = [
    'Chocolate',
    'Coca Cola',
    'Chips',
    'Ice Cream',
    'Milk',
  ];

  // List of all available product names for suggestions
  final List<String> _allProductNames = [
    'Coca Cola 1L',
    'Lays Classic 100g',
    'Amul Milk 1L',
    'Fresh Bread',
    'Chocolate Bar',
  ];

  List<Product> _similarItems = [];
  List<Product> _recommendations = [];
  bool _loading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
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
    _debounce = Timer(const Duration(milliseconds: 350), () async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _searchSuggestions = [];
        _similarItems = [];
        _recommendations = [];
          _loading = false;
      });
      return;
    }
      setState(() { _loading = true; });
      try {
        final data = await ApiService.get('/products?search=$query');
        final products = (data['products'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
        setState(() {
          _searchResults = products;
          _searchSuggestions = products.map((p) => p.name).toList();
          _loading = false;
        });
      } catch (e) {
    setState(() {
          _searchResults = [];
          _searchSuggestions = [];
          _loading = false;
        });
      }
    });
  }

  void _navigateToResults(String query) {
    if (query.isEmpty) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsScreen(
            query: query,
          initialResults: _searchResults,
          ),
        ),
      );
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
            icon: const Icon(Icons.arrow_back),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: _performSearch,
                onSubmitted: _navigateToResults,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Search for items...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
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
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.tune_rounded,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
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
                onPressed: () {
                  setState(() => _recentSearches = []);
                },
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
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
                _performSearch(_recentSearches[index]);
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
      ],
    );
  }

  Widget _buildSearchSuggestions() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_searchSuggestions.isNotEmpty) ...[
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
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_loading) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      ));
    }
    if (_searchResults.isEmpty && _similarItems.isEmpty && _recommendations.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32),
        child: Text('No results found'),
      ));
    }
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_searchResults.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Products',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
        if (_similarItems.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Similar Items',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _similarItems.length,
            itemBuilder: (context, index) {
              final product = _similarItems[index];
              return _buildProductTile(product);
            },
          ),
        ],
        if (_recommendations.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'People Also Like',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recommendations.length,
            itemBuilder: (context, index) {
              final product = _recommendations[index];
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
            'Rs ${product.price}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
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
        ],
      ),
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
                    if (_searchController.text.isEmpty)
                      _buildRecentSearches()
                    else ...[
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