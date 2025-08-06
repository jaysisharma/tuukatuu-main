import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tuukatuu/providers/unified_cart_provider.dart';
import 'package:tuukatuu/services/api_service.dart';
import 'package:tuukatuu/presentation/widgets/tmart_product_card.dart';

class TMartSearchScreen extends StatefulWidget {
  final String searchQuery;
  
  const TMartSearchScreen({
    super.key,
    required this.searchQuery,
  });

  @override
  State<TMartSearchScreen> createState() => _TMartSearchScreenState();
}

class _TMartSearchScreenState extends State<TMartSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _hasMoreData = true;
  int _currentPage = 1;
  
  // Filter states
  String _selectedSort = 'relevance';
  bool _isVegetarian = false;
  bool _isOrganic = false;
  bool _isVegan = false;
  bool _isGlutenFree = false;
  bool _hasDiscount = false;
  RangeValues _priceRange = const RangeValues(0, 2000);
  double _minRating = 0;
  
  @override
  void initState() {
    super.initState();
    print('🚀 TMartSearchScreen initialized with query: "${widget.searchQuery}"'); // Debug log
    _searchController.text = widget.searchQuery;
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts({bool refresh = false}) async {
    if (_isLoading || (!refresh && !_hasMoreData)) return;

    setState(() {
      _isLoading = true;
      if (refresh) {
        _currentPage = 1;
        _hasMoreData = true;
      }
    });

    try {
      final query = _searchController.text.trim();
      print('🔍 Search Query: "$query"'); // Debug log
      
      if (query.isEmpty) {
        print('❌ Empty search query, clearing results'); // Debug log
        setState(() {
          _products = [];
          _isLoading = false;
          _hasError = false;
        });
        return;
      }

      final params = {
        'q': query,
        'page': _currentPage.toString(),
        'limit': '20',
        'sort': _selectedSort,
        if (_isVegetarian) 'isVegetarian': 'true',
        if (_isOrganic) 'isOrganic': 'true',
        if (_isVegan) 'isVegan': 'true',
        if (_isGlutenFree) 'isGlutenFree': 'true',
        if (_hasDiscount) 'hasDiscount': 'true',
        'minPrice': _priceRange.start.round().toString(),
        'maxPrice': _priceRange.end.round().toString(),
        if (_minRating > 0) 'rating': _minRating.toString(),
      };

      print('📡 API Params: $params'); // Debug log
      final response = await ApiService.get('/tmart/search', params: params);
      print('📡 API Response: ${response['success']} - ${response['data']?.length ?? 0} results'); // Debug log
      
      if (response['success']) {
        final newProducts = List<Map<String, dynamic>>.from(response['data']);
        
        setState(() {
          if (refresh) {
            _products = newProducts;
          } else {
            _products.addAll(newProducts);
          }
          _isLoading = false;
          _hasError = false;
          _hasMoreData = newProducts.length == 20;
          if (_hasMoreData) _currentPage++;
        });
        
        print('✅ Search completed: ${_products.length} total products'); // Debug log
      } else {
        throw Exception(response['message'] ?? 'Failed to load products');
      }
    } catch (e) {
      print('❌ Search error: $e'); // Debug log
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sort By', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSortOption('relevance', 'Relevance'),
            _buildSortOption('price_low', 'Price: Low to High'),
            _buildSortOption('price_high', 'Price: High to Low'),
            _buildSortOption('rating', 'Rating'),
            _buildSortOption('popular', 'Popularity'),
            _buildSortOption('newest', 'Newest'),
            _buildSortOption('discount', 'Discount'),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String value, String label) {
    return RadioListTile<String>(
      title: Text(label, style: GoogleFonts.poppins()),
      value: value,
      groupValue: _selectedSort,
      onChanged: (newValue) {
        setState(() {
          _selectedSort = newValue!;
        });
        Navigator.pop(context);
        _loadProducts(refresh: true);
      },
    );
  }

  Widget _buildFilterBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isVegetarian = false;
                      _isOrganic = false;
                      _isVegan = false;
                      _isGlutenFree = false;
                      _hasDiscount = false;
                      _priceRange = const RangeValues(0, 2000);
                      _minRating = 0;
                    });
                  },
                  child: Text(
                    'Clear All',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFFC8019),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dietary Preferences
                  Text(
                    'Dietary Preferences',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFilterOption('Vegetarian', _isVegetarian, (value) {
                    setState(() => _isVegetarian = value ?? false);
                  }),
                  _buildFilterOption('Organic', _isOrganic, (value) {
                    setState(() => _isOrganic = value ?? false);
                  }),
                  _buildFilterOption('Vegan', _isVegan, (value) {
                    setState(() => _isVegan = value ?? false);
                  }),
                  _buildFilterOption('Gluten Free', _isGlutenFree, (value) {
                    setState(() => _isGlutenFree = value ?? false);
                  }),
                  _buildFilterOption('Has Discount', _hasDiscount, (value) {
                    setState(() => _hasDiscount = value ?? false);
                  }),
                  
                  const SizedBox(height: 24),
                  
                  // Price Range
                  Text(
                    'Price Range',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 2000,
                    divisions: 40,
                    labels: RangeLabels(
                      '₹${_priceRange.start.round()}',
                      '₹${_priceRange.end.round()}',
                    ),
                    onChanged: (values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Rating
                  Text(
                    'Minimum Rating',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: _minRating,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    label: _minRating > 0 ? '${_minRating.toStringAsFixed(1)}+' : 'Any',
                    onChanged: (value) {
                      setState(() {
                        _minRating = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Apply Button
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _loadProducts(refresh: true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFC8019),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Apply Filters',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String label, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      title: Text(label, style: GoogleFonts.poppins()),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFFFC8019),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFC8019),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search for groceries...",
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                  _loadProducts(refresh: true);
                },
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onSubmitted: (value) {
              _loadProducts(refresh: true);
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.white),
            onPressed: _showSortDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Results Header
          if (_products.isNotEmpty || _isLoading)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  Text(
                    '${_products.length} results found',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Sort: ${_selectedSort.replaceAll('_', ' ').toUpperCase()}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          
          // Products Grid
          Expanded(
            child: _hasError
                ? _buildErrorWidget()
                : _products.isEmpty && !_isLoading
                    ? _buildEmptyWidget()
                    : _buildProductsGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _loadProducts();
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _products.length + (_isLoading ? 4 : 0),
        itemBuilder: (context, index) {
          if (index >= _products.length) {
            return _buildLoadingCard();
          }
          
          final product = _products[index];
          return Consumer<UnifiedCartProvider>(
            builder: (context, cartProvider, child) {
              final productId = product['_id'] ?? '';
              final quantity = cartProvider.getItemQuantity(productId, CartItemType.tmart);
              
              return TMartProductCard(
                item: product,
                quantity: quantity,
                onAdd: () {
                  // Create CartItem for T-Mart product
                  final cartItem = CartItem(
                    id: productId,
                    name: product['name'] ?? '',
                    price: (product['price'] ?? 0).toDouble(),
                    quantity: 1,
                    image: product['image'] ?? '',
                    type: CartItemType.tmart,
                    vendorId: 'tmart',
                    vendorName: 'T-Mart',
                    notes: '',
                  );
                  
                  cartProvider.addItem(cartItem);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product['name']} added to cart'),
                      backgroundColor: const Color(0xFFFC8019),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                onIncrement: () {
                  cartProvider.updateQuantity(productId, CartItemType.tmart, quantity + 1);
                },
                onDecrement: () {
                  if (quantity > 1) {
                    cartProvider.updateQuantity(productId, CartItemType.tmart, quantity - 1);
                  } else {
                    cartProvider.removeItem(productId, CartItemType.tmart);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _loadProducts(refresh: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFC8019),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Try Again',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
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
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 