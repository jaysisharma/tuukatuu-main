// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../models/store.dart';
import '../../widgets/cached_image.dart';
import 'package:provider/provider.dart';
import '../../widgets/global_cart_fab.dart';
import '../../providers/enhanced_cart_provider.dart';
import '../../models/cart_item.dart';
import '../../services/api_service.dart';
import '../../services/store_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _currentImageIndex = 0;
  int _quantity = 1;
  
  // Similar products (excluding current product)
  List<Product> _similarProducts = [];
  bool _loadingSimilar = false;
  String? _errorSimilar;
  
  // Frequently bought together items

  // Store information
  Store? _store;

  @override
  void initState() {
    super.initState();
    _fetchSimilarProducts();
    _fetchStoreInfo();
    _updateCartQuantity();
  }

  void _updateCartQuantity() {
    final cartProvider = Provider.of<EnhancedCartProvider>(context, listen: false);
    cartProvider.getItemQuantity(widget.product, CartItemSource.store);
    setState(() {
    });
  }

  Future<void> _fetchSimilarProducts() async {
    setState(() {
      _loadingSimilar = true;
      _errorSimilar = null;
    });
    try {
      final response = await ApiService.get('/tmart/similar-general', params: {
        'productId': widget.product.id,
        'limit': '8',
      });

      if (response['success'] && response['data'] != null) {
        final products = (response['data'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
        setState(() {
          _similarProducts = products;
          _loadingSimilar = false;
        });
      } else {
        setState(() {
          _similarProducts = [];
          _loadingSimilar = false;
        });
      }
    } catch (e) {
      setState(() {
        _loadingSimilar = false;
        _errorSimilar = e.toString();
      });
    }
  }

  Future<void> _fetchStoreInfo() async {
    setState(() {
    });
    try {
      final store = await StoreService.getStoreById(widget.product.vendorId);
      setState(() {
        _store = store ?? Store.demoStore;
      });
    } catch (e) {
      setState(() {
        _store = Store.demoStore;
      });
      // Store info is optional, so we don't show error
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final theme = Theme.of(context);
    final cartProvider = Provider.of<EnhancedCartProvider>(context, listen: false);

    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedImage(
                    imageUrl: product.imageUrl,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (product.rating >= 4.5)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            product.rating.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Rs ${product.price}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Add to cart logic
                
                
                
                
                          
                          if (_store != null) {
                            cartProvider.addFromStore(product, _store!);
                          } else {
                            cartProvider.addItem(product, CartItemSource.store);
                          }
                          
                
                          // Item added to cart silently
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
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
    final cartProvider = Provider.of<EnhancedCartProvider>(context);
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    
    // Check if this product is in cart
    cartProvider.hasItem(widget.product, CartItemSource.store);
    
    // Update cart quantity when cart changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateCartQuantity();
      }
    });
    
    return Scaffold(
      floatingActionButton: const GlobalCartFAB(
        heroTag: 'product_details_fab',
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 300,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark ? theme.cardColor : Colors.grey[100],
                          ),
                          child: PageView.builder(
                            itemCount: widget.product.images.isNotEmpty ? widget.product.images.length : 1,
                            onPageChanged: (index) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              // If no images array or empty, use the main imageUrl
                              String imageUrl = widget.product.imageUrl;
                              if (widget.product.images.isNotEmpty && index < widget.product.images.length) {
                                imageUrl = widget.product.images[index];
                              }
                              
                              return CachedImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.contain,
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 16,
                          left: 16,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.arrow_back,
                              color: isDark ? Colors.grey[100] : Colors.grey[900],
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: theme.cardColor,
                              elevation: 2,
                            ),
                          ),
                        ),
                        
                        if (widget.product.images.isNotEmpty && widget.product.images.length > 1)
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: widget.product.images
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) => Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _currentImageIndex == entry.key
                                            ? theme.colorScheme.primary
                                            : (isDark ? Colors.grey[700] : Colors.grey[300]),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.blue[900] : Colors.blue[50],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  widget.product.category,
                                  style: TextStyle(
                                    color: isDark ? Colors.blue[100] : theme.primaryColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.product.rating.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              Text(
                                ' (${widget.product.reviews})',
                                style: TextStyle(
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.product.name,
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Rs ${widget.product.price}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Description',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.product.description,
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text(
                                'Quantity',
                                style: theme.textTheme.titleLarge,
                              ),
                              const Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        if (_quantity > 1) {
                                          setState(() {
                                            _quantity--;
                                          });
                                        }
                                      },
                                      icon: Icon(
                                        Icons.remove,
                                        color: theme.iconTheme.color,
                                      ),
                                    ),
                                    Text(
                                      _quantity.toString(),
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _quantity++;
                                        });
                                      },
                                      icon: Icon(
                                        Icons.add,
                                        color: theme.iconTheme.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // _buildFrequentlyBoughtTogether(),
                    // Similar Products Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSectionTitle('Similar Products'),
                            if (_loadingSimilar)
                              Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (_loadingSimilar)
                          SizedBox(
                            height: 240,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              scrollDirection: Axis.horizontal,
                              itemCount: 3,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 180,
                                  margin: const EdgeInsets.only(right: 16),
                                  child: Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                height: 12,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                height: 10,
                                                width: 60,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius: BorderRadius.circular(5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        else if (_errorSimilar != null)
                          Container(
                            height: 100,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red[400], size: 24),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Failed to load similar products',
                                    style: TextStyle(
                                      color: Colors.red[600],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (_similarProducts.isEmpty)
                          Container(
                            height: 100,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    color: Colors.grey[400],
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No similar products found',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            height: 240,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              scrollDirection: Axis.horizontal,
                              itemCount: _similarProducts.length,
                              itemBuilder: (context, index) => _buildProductCard(_similarProducts[index]),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Total: Rs ${widget.product.price * _quantity}',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
              
              
              
              
              
                        
                        if (_store != null) {
                          cartProvider.addFromStore(widget.product, _store!);
                        } else {
                          cartProvider.addItem(widget.product, CartItemSource.store);
                        }
                        
              
                        setState(() {
                        });
                        // Item added to cart silently
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Add to Cart'),
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
} 