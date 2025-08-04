import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuukatuu/providers/mart_cart_provider.dart';
import 'package:tuukatuu/providers/recently_viewed_provider.dart';
import 'package:tuukatuu/services/api_service.dart';
import 'package:tuukatuu/presentation/widgets/tmart_product_card.dart';
import 'package:tuukatuu/presentation/widgets/cached_image.dart';
import 'package:tuukatuu/routes.dart';

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
  int _currentPage = 1;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMoreProducts();
      }
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await ApiService.get(
        '/tmart/category/query?category=${widget.categoryName}&page=1&limit=20',
      );

      if (response['success']) {
        setState(() {
          _products = List<Map<String, dynamic>>.from(response['data']);
          _hasMore = response['hasMore'] ?? false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = response['message'] ?? 'Failed to load products';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final response = await ApiService.get(
        '/tmart/category/query?category=${widget.categoryName}&page=$nextPage&limit=20',
      );

      if (response['success']) {
        final newProducts = List<Map<String, dynamic>>.from(response['data']);
        setState(() {
          _products.addAll(newProducts);
          _currentPage = nextPage;
          _hasMore = response['hasMore'] ?? false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasMore = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasMore = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _currentPage = 1;
      _hasMore = true;
    });
    await _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryDisplayName,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black87),
            onPressed: () {
              // TODO: Implement filter functionality
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return _buildErrorState();
    }

    if (_products.isEmpty && !_isLoading) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshProducts,
      child: Column(
        children: [
          _buildCategoryHeader(),
          Expanded(
            child: _buildProductsGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFC8019).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.category,
              color: Color(0xFFFC8019),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.categoryDisplayName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_products.length} products available',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid() {
    return Consumer2<MartCartProvider, RecentlyViewedProvider>(
      builder: (context, martCartProvider, recentlyViewedProvider, child) {
        return GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: _products.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _products.length) {
              return _buildLoadingIndicator();
            }

            final product = _products[index];
            final String productId = product['_id'] ?? product['id'] ?? '';
            final int quantity = martCartProvider.getItemQuantity(productId);

            return GestureDetector(
              onTap: () {
                recentlyViewedProvider.addToRecentlyViewed(product);
                Navigator.pushNamed(
                  context,
                  AppRoutes.tmartProductDetail,
                  arguments: {
                    'product': product,
                  },
                );
              },
              child: TMartProductCard(
                item: product,
                quantity: quantity,
                onAdd: () {
                  martCartProvider.addItem(product, quantity: 1);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product['name']} added to cart'),
                      backgroundColor: const Color(0xFFFC8019),
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
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFC8019)),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
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
            'Oops! Something went wrong',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
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
            onPressed: _loadProducts,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFC8019),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Try Again',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We couldn\'t find any products in this category',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadProducts,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFC8019),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Refresh',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 