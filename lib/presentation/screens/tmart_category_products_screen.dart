import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tuukatuu/providers/mart_cart_provider.dart';
import 'package:tuukatuu/presentation/widgets/tmart_product_card.dart';
import 'package:tuukatuu/services/api_service.dart';

// Swiggy color scheme
const Color swiggyOrange = Color(0xFFFC8019);
const Color swiggyRed = Color(0xFFE23744);
const Color swiggyDark = Color(0xFF1C1C1C);
const Color swiggyLight = Color(0xFFF8F9FA);

class TMartCategoryProductsScreen extends StatefulWidget {
  final String categoryName;
  final String categoryDisplayName;

  const TMartCategoryProductsScreen({
    super.key,
    required this.categoryName,
    required this.categoryDisplayName,
  });

  @override
  State<TMartCategoryProductsScreen> createState() => _TMartCategoryProductsScreenState();
}

class _TMartCategoryProductsScreenState extends State<TMartCategoryProductsScreen> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _sortBy = 'relevance';
  String _filterBy = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
  
      // Build query parameters
      final params = <String, String>{
        'category': widget.categoryDisplayName,
        'sort': _sortBy,
        'limit': '50',
      };
      
      // Add filter parameters
      if (_filterBy != 'all') {
        switch (_filterBy) {
          case 'best_seller':
            params['isBestSeller'] = 'true';
            break;
          case 'featured':
            params['isFeatured'] = 'true';
            break;
          case 'daily_essential':
            params['dailyEssential'] = 'true';
            break;
        }
      }
      
      // Use the correct T-Mart API endpoint
      final response = await ApiService.get('/tmart/products', params: params);

      print('🔍 API Response: $response');

      if (response != null && response['success'] == true) {
        final products = List<Map<String, dynamic>>.from(response['data'] ?? []);
      
        setState(() {
          _products = products;
          _isLoading = false;
        });
      } else {
        print('❌ API returned error: ${response?['message']}');
        setState(() {
          _hasError = true;
          _errorMessage = response?['message'] ?? 'Failed to load products';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading products for category ${widget.categoryDisplayName}: $e');
      setState(() {
        _hasError = true;
        _errorMessage = 'Network error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _searchProducts() async {
    if (_searchController.text.trim().isEmpty) {
      _loadProducts();
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      print('🔍 Searching products: ${_searchController.text.trim()}');
      
      // Build query parameters for search
      final params = <String, String>{
        'search': _searchController.text.trim(),
        'category': widget.categoryDisplayName,
        'sort': _sortBy,
        'limit': '50',
      };
      
      // Add filter parameters if not showing all
      if (_filterBy != 'all') {
        switch (_filterBy) {
          case 'best_seller':
            params['isBestSeller'] = 'true';
            break;
          case 'featured':
            params['isFeatured'] = 'true';
            break;
          case 'daily_essential':
            params['dailyEssential'] = 'true';
            break;
        }
      }
      
      final response = await ApiService.get('/tmart/products', params: params);

      print('🔍 Search Response: $response');

      if (response != null && response['success'] == true) {
        final products = List<Map<String, dynamic>>.from(response['data'] ?? []);
        print('🔍 Found ${products.length} products in search');
        
        setState(() {
          _products = products;
          _isLoading = false;
        });
      } else {
        print('❌ Search API returned error: ${response?['message']}');
        setState(() {
          _hasError = true;
          _errorMessage = response?['message'] ?? 'Failed to search products';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error searching products: $e');
      setState(() {
        _hasError = true;
        _errorMessage = 'Network error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sort By', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSortOption('createdAt', 'Newest First'),
            _buildSortOption('rating', 'Rating'),
            _buildSortOption('price', 'Price: Low to High'),
            _buildSortOption('name', 'Name A-Z'),
            _buildSortOption('reviews', 'Most Reviewed'),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String value, String label) {
    return RadioListTile<String>(
      title: Text(label, style: GoogleFonts.poppins()),
      value: value,
      groupValue: _sortBy,
      onChanged: (newValue) {
        setState(() {
          _sortBy = newValue!;
        });
        Navigator.pop(context);
        _loadProducts();
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter By', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('all', 'All Products'),
            _buildFilterOption('best_seller', 'Best Sellers'),
            _buildFilterOption('featured', 'Featured'),
            _buildFilterOption('daily_essential', 'Daily Essentials'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String value, String label) {
    return RadioListTile<String>(
      title: Text(label, style: GoogleFonts.poppins()),
      value: value,
      groupValue: _filterBy,
      onChanged: (newValue) {
        setState(() {
          _filterBy = newValue!;
        });
        Navigator.pop(context);
        _loadProducts();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MartCartProvider>(
      create: (_) => MartCartProvider(),
      child: Builder(
        builder: (context) {
          final martCartProvider = Provider.of<MartCartProvider>(context);
          
          return Scaffold(
            backgroundColor: swiggyLight,
            floatingActionButton: martCartProvider.items.isNotEmpty
                ? FloatingActionButton(
                    onPressed: () {
                      try {
                        Navigator.pushNamed(context, '/tmart-cart');
                      } catch (e) {
                        // Fallback if route doesn't exist
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Cart: ${martCartProvider.items.length} items'),
                            backgroundColor: swiggyOrange,
                          ),
                        );
                      }
                    },
                    backgroundColor: swiggyOrange,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.shopping_cart, color: Colors.white),
                        if (martCartProvider.items.isNotEmpty)
                          Positioned(
                            right: -8,
                            top: -8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: swiggyRed,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Text(
                                '${martCartProvider.items.length}',
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
                  )
                : null,
            appBar: AppBar(
              backgroundColor: swiggyOrange,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                widget.categoryDisplayName,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
                // Search bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: swiggyOrange,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search in ${widget.categoryDisplayName}...",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _loadProducts();
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onSubmitted: (_) => _searchProducts(),
                  ),
                ),
                
                // Products grid
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _hasError
                          ? _buildErrorWidget()
                          : _products.isEmpty
                              ? _buildEmptyWidget()
                              : _buildProductsGrid(martCartProvider),
                ),
              ],
            ),
          );
        },
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
            'Error loading products',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadProducts,
            style: ElevatedButton.styleFrom(
              backgroundColor: swiggyOrange,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Retry',
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
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(MartCartProvider martCartProvider) {
    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final item = _products[index];
          final String productId = item['_id'] ?? item['id'] ?? '';
          final int quantity = martCartProvider.getItemQuantity(productId);
          
          // Debug: Print item structure if there are issues
          if (item['name'] == null || item['price'] == null) {
            print('⚠️ Product item missing required fields: $item');
          }
          
          return TMartProductCard(
            item: item,
            quantity: quantity,
            onAdd: () {
              martCartProvider.addItem(item);
            },
            onIncrement: () {
              martCartProvider.updateQuantity(productId, quantity + 1);
            },
            onDecrement: () {
              if (quantity > 1) {
                martCartProvider.updateQuantity(productId, quantity - 1);
              } else {
                martCartProvider.removeItem(productId);
              }
            },
          );
        },
      ),
    );
  }

} 