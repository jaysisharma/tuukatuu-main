import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuukatuu/presentation/widgets/category_item.dart';
import 'package:tuukatuu/providers/global_cart_provider.dart';
import 'package:tuukatuu/services/api_service.dart';

class ProductBottomSheet extends StatefulWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;
  final List<Map<String, dynamic>> initialProducts;
  final ScrollController categoryScrollController;
  final Function(String, bool) onAddToCart;
  final Map<String, int> initialQuantities;

  const ProductBottomSheet({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.initialProducts,
    required this.categoryScrollController,
    required this.onAddToCart,
    required this.initialQuantities,
  });

  @override
  State<ProductBottomSheet> createState() => _ProductBottomSheetState();
}

class _ProductBottomSheetState extends State<ProductBottomSheet> {
  // Track quantities for each product in this bottom sheet
  late Map<String, int> _productQuantities;
  
  // Backend data
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _currentCategory = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Initialize quantities from the parent cart state
    _productQuantities = Map.from(widget.initialQuantities);
    _currentCategory = widget.selectedCategory;
    _products = []; // Start with empty products
    _categories = []; // Start with empty categories
    
    print('ProductBottomSheet initialized with selectedCategory: ${widget.selectedCategory}'); // Debug log
    
    // Fetch categories first, then fetch products for the first subcategory if available
    _fetchCategories().then((_) {
      // After categories are loaded, fetch products for the first subcategory if available
      if (_categories.isNotEmpty) {
        final firstCategory = _categories.first['name'] as String;
        print('First subcategory found: $firstCategory'); // Debug log
        _fetchProductsForCategory(firstCategory);
      } else {
        print('No subcategories found'); // Debug log
      }
    });
  }

  @override
  void dispose() {
    // Ensure scroll controller is properly handled
    super.dispose();
  }

  // Fetch categories from backend
  Future<void> _fetchCategories() async {
    try {
      print('Fetching categories for main category: ${widget.selectedCategory}'); // Debug log
      
      // Get products for the main category to find actual subcategories
      final productsResponse = await ApiService.get('/mart/products/category', params: {
        'category': widget.selectedCategory,
        'limit': '100', // Get more products to find all subcategories
        'page': '1'
      });
      
      print('Categories API response: ${productsResponse['success']} - ${productsResponse['data']?.length ?? 0} products'); // Debug log
      
      if (productsResponse['success'] && productsResponse['data'] != null) {
        final products = List<Map<String, dynamic>>.from(productsResponse['data']);
        
        // Extract unique subcategories from products
        final subcategories = <String>{};
        for (final product in products) {
          if (product['subcategory'] != null && product['subcategory'].toString().isNotEmpty) {
            subcategories.add(product['subcategory'].toString());
          }
          // Also check for brand names as subcategories if no subcategory
          if (product['subcategory'] == null || product['subcategory'].toString().isEmpty) {
            if (product['brand'] != null && product['brand'].toString().isNotEmpty) {
              subcategories.add(product['brand'].toString());
            }
          }
        }
        
        print('Found subcategories: $subcategories'); // Debug log
        print('Products data sample: ${products.take(2).map((p) => {'name': p['name'], 'subcategory': p['subcategory']}).toList()}'); // Debug log
        
        // Create category list with only real subcategories
        final dynamicCategories = <Map<String, dynamic>>[];
        
        // Add only actual subcategories found in products
        for (final subcategory in subcategories) {
          dynamicCategories.add({
            'name': subcategory,
            'id': subcategory,
            'type': 'subcategory'
          });
        }
        
        print('Created dynamic categories: ${dynamicCategories.map((c) => c['name']).toList()}'); // Debug log
        
        setState(() {
          _categories = dynamicCategories;
        });
      } else {
        // If products fetch fails, show empty categories
        print('Categories API failed or returned no data'); // Debug log
        setState(() {
          _categories = [];
        });
      }
    } catch (error) {
      print('Error fetching categories: $error');
      // Show empty categories if API fails
      setState(() {
        _categories = [];
      });
    }
  }

  // Handle category change
  void _onCategoryChanged(String category) {
    print('Category changed to: $category'); // Debug log
    print('Current main category: ${widget.selectedCategory}'); // Debug log
    
    // Ensure scroll controller is attached before using it
    if (widget.categoryScrollController.hasClients) {
      widget.onCategoryChanged(category);
    }
    _fetchProductsForCategory(category);
  }

  // Fetch products from backend for a specific category
  Future<void> _fetchProductsForCategory(String category) async {
    if (_currentCategory == category && _products.isNotEmpty && !_hasError) return;
    
    print('_fetchProductsForCategory called with category: $category'); // Debug log
    
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      _currentCategory = category;
    });

    try {
      // All categories are now subcategories, so use subcategory parameter
      final params = {
        'category': widget.selectedCategory,
        'subcategory': category,
        'limit': '50',
        'page': '1',
        'sort': 'rating'
      };
      
      print('Fetching products with params: $params'); // Debug log
      print('Main category: ${widget.selectedCategory}'); // Debug log
      print('Subcategory: $category'); // Debug log
      
      final response = await ApiService.get('/mart/products/category', params: params);

      print('API response: ${response['success']} - ${response['data']?.length ?? 0} products'); // Debug log
      print('Full API response: $response'); // Debug log

      if (response['success'] && response['data'] != null) {
        List<Map<String, dynamic>> products;
        
        if (response['data'] is List) {
          products = List<Map<String, dynamic>>.from(response['data']);
        } else {
          products = [];
        }
        
        print('Transformed ${products.length} products'); // Debug log
        print('Products data: ${products.map((p) => {'name': p['name'], 'subcategory': p['subcategory']}).toList()}'); // Debug log
        
        // Transform backend data to match frontend format
        final transformedProducts = products.map((product) {
          return {
            'name': product['name'] ?? 'Product',
            'price': 'Rs. ${product['price']?.toString() ?? '0'}',
            'rating': product['rating']?.toDouble() ?? 0.0,
            'reviews': product['reviews'] ?? 0,
            'category': product['category'] ?? 'General',
            'image': product['imageUrl'] ?? 'assets/images/products/snickers.jpg',
            'isNew': product['isNewArrival'] ?? false,
            'discount': product['discount'] ?? null,
          };
        }).toList();

        print('Final transformed products: ${transformedProducts.length}'); // Debug log

        setState(() {
          _products = transformedProducts;
          _isLoading = false;
          _hasError = false;
        });
      } else {
        // Show empty state if API returns no data
        print('API returned no data or failed'); // Debug log
        setState(() {
          _products = [];
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (error) {
      print('Error fetching products for category $category: $error');
      setState(() {
        _products = [];
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load products. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88, // Reduce from 0.9 to 0.88
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              _buildBottomSheetHandle(),
              const SizedBox(height: 20),
              _buildBottomSheetHeader(),
              const SizedBox(height: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align items to top
                    children: [
                      _buildCategorySidebar(),
                      const SizedBox(width: 20),
                      Expanded( // Ensure products section takes remaining space
                        child: _buildProductsSection(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Floating Cart Button in Bottom Sheet
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Consumer<GlobalCartProvider>(
                builder: (context, cartProvider, child) {
                  if (!cartProvider.hasItems) return const SizedBox.shrink();
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35), // Swiggy Orange
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B35).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () {
                          Navigator.pop(context); // Close bottom sheet
                          // Navigate to cart screen
                          Navigator.pushNamed(context, '/cart');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.shopping_cart_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Cart',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${cartProvider.totalItems}',
                                  style: const TextStyle(
                                    color: Color(0xFFFF6B35),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheetHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildBottomSheetHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySidebar() {
    return Container(
      width: 110, // Slightly reduce width
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16), // Reduce from 20 to 16
          Expanded(
            child: _categories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 32,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No subcategories',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'available',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[400],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : Container(
                    constraints: const BoxConstraints(maxHeight: double.infinity),
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          controller: widget.categoryScrollController,
                          padding: const EdgeInsets.only(left: 4, bottom: 16), // Reduce from 20 to 16
                          physics: const BouncingScrollPhysics(), // Better scroll physics
                          child: Column(
                            children: _buildCategoryItems(),
                          ),
                        ),
                        Positioned(
                          right: 4,
                          top: 0,
                          bottom: 0,
                          child: _buildDynamicScrollbar(),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 16), // Reduce from 20 to 16
        ],
      ),
    );
  }

  List<Widget> _buildCategoryItems() {
    return _categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final isActive = _currentCategory == category['name'];
      final categoryName = category['name'] as String;
      final isLast = index == _categories.length - 1;
      
      // Get appropriate image for each subcategory
      String getImageForSubcategory(String subcategory) {
        switch (subcategory.toLowerCase()) {
          case 'dairy milk':
            return 'assets/images/products/chocolate.jpg'; // Use available chocolate image
          case 'kitkat':
            return 'assets/images/products/chocolate_2.jpg'; // Use available chocolate image
          case '5 star':
            return 'assets/images/products/chocolate.jpg'; // Use available chocolate image
          case 'twix':
            return 'assets/images/products/chocolate_2.jpg'; // Use available chocolate image
          case 'snickers':
            return 'assets/images/products/snickers.jpg'; // Available
          case 'cola':
            return 'assets/images/products/coca_cola.jpg'; // Available
          case 'lemon lime':
            return 'assets/images/products/coca_cola_2.jpg'; // Use available cola image
          case 'orange':
            return 'assets/images/products/coca_cola.jpg'; // Use available cola image
          case 'citrus':
            return 'assets/images/products/coca_cola_2.jpg'; // Use available cola image
          case 'potato chips':
            return 'assets/images/products/lays.jpg'; // Available
          case 'tortilla chips':
            return 'assets/images/products/lays_2.jpg'; // Available
          case 'cheese snacks':
            return 'assets/images/products/lays.jpg'; // Use available chips image
          case 'potato crisps':
            return 'assets/images/products/lays_2.jpg'; // Use available chips image
          case 'crackers':
            return 'assets/images/products/lays.jpg'; // Use available chips image
          default:
            return 'assets/images/products/snickers.jpg'; // fallback
        }
      }
      
      return GestureDetector(
        onTap: () => _onCategoryChanged(categoryName),
        child: Container(
          width: 90, // Fixed width
          height: 105, // Reduced from 100 to 99 to fix overflow
          margin: EdgeInsets.only(
            top: 3, // Reduce from 4 to 3
            bottom: isLast ? 6 : 3, // Add extra bottom margin for last item
            left: 0, // Move items more to the left
            right: 20, // Add right padding
          ),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFF6B35) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? const Color(0xFFFF6B35) : Colors.grey[300]!,
              width: 1.5,
            ),
            boxShadow: isActive ? [
              BoxShadow(
                color: const Color(0xFFFF6B35).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Category image
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage(getImageForSubcategory(categoryName)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Category name
              Text(
                categoryName,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? Colors.white : Colors.grey[700],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildProductsSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.selectedCategory}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
             
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFFFF6B35),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading products...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Searching in ${widget.selectedCategory}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : _hasError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.red[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _fetchProductsForCategory(_currentCategory),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6B35),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Retry',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _products.isEmpty
                         ? Center(
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
                                   '0 products available',
                                   style: TextStyle(
                                     fontSize: 18,
                                     fontWeight: FontWeight.w600,
                                     color: Colors.grey[600],
                                   ),
                                 ),
                                 const SizedBox(height: 8),
                                 Text(
                                   'No products found in ${_currentCategory}',
                                   style: TextStyle(
                                     fontSize: 14,
                                     color: Colors.grey[500],
                                   ),
                                 ),
                                 const SizedBox(height: 16),
                                 Text(
                                   'Try selecting a different category',
                                   style: TextStyle(
                                     fontSize: 12,
                                     color: Colors.grey[400],
                                   ),
                                 ),
                                 const SizedBox(height: 20),
                                 ElevatedButton.icon(
                                   onPressed: () => _fetchProductsForCategory(_currentCategory),
                                   icon: const Icon(Icons.refresh, size: 18),
                                   label: const Text('Refresh'),
                                   style: ElevatedButton.styleFrom(
                                     backgroundColor: const Color(0xFFFF6B35),
                                     foregroundColor: Colors.white,
                                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                     shape: RoundedRectangleBorder(
                                       borderRadius: BorderRadius.circular(10),
                                     ),
                                   ),
                                 ),
                               ],
                             ),
                           )
                        : RefreshIndicator(
                            onRefresh: () => _fetchProductsForCategory(_currentCategory),
                            color: const Color(0xFFFF6B35),
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16, // Increased from 12 to 16
                                mainAxisSpacing: 16, // Increased from 12 to 16
                                childAspectRatio: 0.65, // Reduced from 0.8 to make products taller
                              ),
                              itemCount: _products.length,
                              itemBuilder: (context, index) {
                                return _buildProductItem(_products[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product) {
    final productName = product['name']!;
    final currentQuantity = _productQuantities[productName] ?? 0;
    final rating = product['rating']?.toDouble() ?? 0.0;
    final reviews = product['reviews'] ?? 0;
    final isNew = product['isNew'] ?? false;

    return GestureDetector(
      onTap: () => _navigateToProductDetail(product),
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.asset(
                    product['image'] ?? 'assets/images/products/snickers.jpg',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // NEW badge
                if (isNew)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                // Plus button positioned at bottom right of image
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35), // Swiggy Orange
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B35).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _updateQuantity(productName, true),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Quantity controls
                if (currentQuantity > 0)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Minus button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => _updateQuantity(productName, false),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.remove,
                                  color: Colors.black54,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          // Quantity display
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '$currentQuantity',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF6B35),
                              ),
                            ),
                          ),
                          // Plus button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => _updateQuantity(productName, true),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B35),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Rating and reviews
                Row(
                  children: [
                    // Star rating
                    Row(
                      children: List.generate(5, (starIndex) {
                        if (starIndex < rating.floor()) {
                          return Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.amber.shade600,
                          );
                        } else if (starIndex == rating.floor() && rating % 1 != 0) {
                          return Icon(
                            Icons.star_half,
                            size: 12,
                            color: Colors.amber.shade600,
                          );
                        } else {
                          return Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.grey.shade300,
                          );
                        }
                      }),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '($reviews)',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product['price']!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  void _updateQuantity(String productName, bool isAdd) {
    setState(() {
      if (isAdd) {
        _productQuantities[productName] = (_productQuantities[productName] ?? 0) + 1;
        // Call the add to cart callback
        widget.onAddToCart(productName, true);
      } else {
        final currentQty = _productQuantities[productName] ?? 0;
        if (currentQty > 0) {
          _productQuantities[productName] = currentQty - 1;
          if (_productQuantities[productName] == 0) {
            _productQuantities.remove(productName);
          }
          // Call the remove from cart callback
          widget.onAddToCart(productName, false);
        }
      }
    });
  }

  void _navigateToProductDetail(Map<String, dynamic> product) {
    Navigator.pushNamed(
      context,
      '/tmart-product-detail',
      arguments: {'product': product},
    );
  }

  Widget _buildDynamicScrollbar() {
    // Only show scrollbar if there are categories and scroll controller is attached
    if (_categories.isEmpty || !widget.categoryScrollController.hasClients) {
      return const SizedBox.shrink();
    }
    
    return Container(
      width: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        heightFactor: 0.3,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[600],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
