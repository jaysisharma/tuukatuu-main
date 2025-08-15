import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/recently_viewed_provider.dart';
import '../../providers/mart_cart_provider.dart';

class RecentlyViewedPage extends StatefulWidget {
  const RecentlyViewedPage({Key? key}) : super(key: key);

  @override
  State<RecentlyViewedPage> createState() => _RecentlyViewedPageState();
}

class _RecentlyViewedPageState extends State<RecentlyViewedPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  double _minRating = 0.0;
  List<String> _categories = ['All'];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    final recentlyViewedProvider = context.read<RecentlyViewedProvider>();
    final categories = recentlyViewedProvider.recentlyViewed
        .map((item) => item['category']?.toString() ?? 'Unknown')
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();
    
    setState(() {
      _categories = ['All', ...categories];
    });
  }

  List<Map<String, dynamic>> get _filteredProducts {
    final recentlyViewedProvider = context.read<RecentlyViewedProvider>();
    List<Map<String, dynamic>> products = recentlyViewedProvider.recentlyViewed;

    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      products = products.where((product) {
        final name = product['name']?.toString().toLowerCase() ?? '';
        final category = product['category']?.toString().toLowerCase() ?? '';
        final brand = product['brand']?.toString().toLowerCase() ?? '';
        return name.contains(query) || category.contains(query) || brand.contains(query);
      }).toList();
    }

    // Filter by category
    if (_selectedCategory != 'All') {
      products = products.where((product) => 
        product['category']?.toString() == _selectedCategory
      ).toList();
    }

    // Filter by rating
    if (_minRating > 0.0) {
      products = products.where((product) => 
        (product['rating'] ?? 0.0) >= _minRating
      ).toList();
    }

    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recently Viewed'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              _showClearConfirmation();
            },
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search recently viewed products...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),
                
                // Filters Row
                Row(
                  children: [
                    // Category Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Rating Filter
                    Expanded(
                      child: DropdownButtonFormField<double>(
                        value: _minRating,
                        decoration: InputDecoration(
                          labelText: 'Min Rating',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: const [
                          DropdownMenuItem(value: 0.0, child: Text('Any Rating')),
                          DropdownMenuItem(value: 3.0, child: Text('3+ Stars')),
                          DropdownMenuItem(value: 4.0, child: Text('4+ Stars')),
                          DropdownMenuItem(value: 4.5, child: Text('4.5+ Stars')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _minRating = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Products List
          Expanded(
            child: Consumer<RecentlyViewedProvider>(
              builder: (context, recentlyViewedProvider, child) {
                if (recentlyViewedProvider.itemCount == 0) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No recently viewed products',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Products you view will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (_filteredProducts.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No products match your filters',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    final productId = product['_id']?.toString() ?? product['id']?.toString() ?? '';
                    
                    return Consumer<MartCartProvider>(
                      builder: (context, cartProvider, child) {
                        final quantity = cartProvider.getItemQuantity(productId);
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                // Product Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product['imageUrl'] ?? '',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.broken_image),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                
                                // Product Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        product['category'] ?? '',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            '₹${product['price']?.toString() ?? '0'}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange,
                                            ),
                                          ),
                                          if (product['rating'] != null) ...[
                                            const SizedBox(width: 8),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  size: 16,
                                                  color: Colors.amber,
                                                ),
                                                const SizedBox(width: 2),
                                                Text(
                                                  product['rating'].toString(),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Cart Controls
                                Column(
                                  children: [
                                    // Remove from recently viewed
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.grey),
                                      onPressed: () {
                                        recentlyViewedProvider.removeFromRecentlyViewed(productId);
                                      },
                                      tooltip: 'Remove from recently viewed',
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Add to cart
                                    if (quantity == 0)
                                      IconButton(
                                        icon: const Icon(Icons.add_shopping_cart, color: Colors.orange),
                                        onPressed: () {
                                          cartProvider.addItem(product);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${product['name']} added to cart'),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                        },
                                        tooltip: 'Add to cart',
                                      )
                                    else
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove, color: Colors.orange),
                                            onPressed: () {
                                              if (quantity > 1) {
                                                cartProvider.updateQuantity(productId, quantity - 1);
                                              } else {
                                                cartProvider.removeItem(productId);
                                              }
                                            },
                                          ),
                                          Text(
                                            quantity.toString(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add, color: Colors.orange),
                                            onPressed: () {
                                              cartProvider.updateQuantity(productId, quantity + 1);
                                            },
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Recently Viewed'),
        content: const Text('Are you sure you want to clear all recently viewed products? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<RecentlyViewedProvider>().clearRecentlyViewed();
              Navigator.of(context).pop();
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 