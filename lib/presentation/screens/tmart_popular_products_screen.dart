import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tuukatuu/providers/mart_cart_provider.dart';
import 'package:tuukatuu/presentation/widgets/tmart_product_card.dart';
import 'package:tuukatuu/services/api_service.dart';
import 'package:tuukatuu/presentation/screens/tmart_cart_screen.dart';
import 'package:tuukatuu/routes.dart';

class TMartPopularProductsScreen extends StatefulWidget {
  const TMartPopularProductsScreen({super.key});

  @override
  State<TMartPopularProductsScreen> createState() => _TMartPopularProductsScreenState();
}

class _TMartPopularProductsScreenState extends State<TMartPopularProductsScreen> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _sortBy = 'relevance';
  final TextEditingController _searchController = TextEditingController();

  // Swiggy color scheme
  static const Color swiggyOrange = Color(0xFFFC8019);
  static const Color swiggyLight = Color(0xFFF8F9FA);

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

  Future<void> _loadProducts({bool shuffle = false}) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await ApiService.get('/tmart/popular', params: {
        'limit': '50',
        'sort': _sortBy,
        'shuffle': shuffle.toString(),
      });

      if (response['success']) {
        setState(() {
          _products = List<Map<String, dynamic>>.from(response['data'] ?? []);
          _isLoading = false;
        });
        
        print('🏆 Loaded ${_products.length} popular products (shuffled: ${response['shuffled'] ?? false})');
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = response['message'] ?? 'Failed to load popular products';
          _isLoading = false;
        });
      }
    } catch (e) {
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
      final response = await ApiService.get('/tmart/search', params: {
        'q': _searchController.text.trim(),
        'sort': _sortBy,
        'limit': '50',
      });

      if (response['success']) {
        setState(() {
          _products = List<Map<String, dynamic>>.from(response['data'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = response['message'] ?? 'Failed to search products';
          _isLoading = false;
        });
      }
    } catch (e) {
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
            _buildSortOption('relevance', 'Relevance'),
            _buildSortOption('rating', 'Rating'),
            _buildSortOption('price_low', 'Price: Low to High'),
            _buildSortOption('price_high', 'Price: High to Low'),
            _buildSortOption('newest', 'Newest First'),
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MartCartProvider>(
      create: (_) => MartCartProvider(),
      child: Builder(
        builder: (context) {
          final martCartProvider = Provider.of<MartCartProvider>(context);
          
          return Scaffold(
            backgroundColor: swiggyLight,
            appBar: AppBar(
              backgroundColor: swiggyOrange,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Popular Products',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () => _loadProducts(shuffle: true),
                  tooltip: 'Refresh with shuffle',
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    _showSearchDialog();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.sort, color: Colors.white),
                  onPressed: _showSortDialog,
                ),
                IconButton(
                  icon: const Icon(Icons.shopping_cart, color: Colors.white),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.tmartCart);
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                // Search bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: swiggyOrange,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search popular products...",
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
            'Error loading popular products',
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
            Icons.trending_up,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No popular products found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or check back later',
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
          
          return TMartProductCard(
            item: item,
            quantity: quantity,
            onAdd: () {
              martCartProvider.addItem(item);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item['name']} added to cart'),
                  backgroundColor: swiggyOrange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
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

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search Popular Products', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Search popular products...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onSubmitted: (value) {
            Navigator.pop(context);
            _searchProducts();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _searchProducts();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: swiggyOrange,
            ),
            child: Text('Search', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }
} 