import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../models/store.dart';
import '../../core/config/routes.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/store_cart_banner.dart';
import 'package:provider/provider.dart';
import '../../providers/unified_cart_provider.dart';
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
  int _cartQuantity = 0;
  
  // Similar products (excluding current product)
  List<Product> _similarProducts = [];
  bool _loadingSimilar = false;
  String? _errorSimilar;
  
  // Frequently bought together items
  final List<Map<String, dynamic>> _frequentlyBoughtTogether = [
    {
      'product': Product.dummyProducts[2], // Coca-Cola
      'isSelected': true,
    },
    {
      'product': Product.dummyProducts[3], // Lays
      'isSelected': true,
    },
  ];

  // Store information
  Store? _store;
  bool _loadingStore = false;

  @override
  void initState() {
    super.initState();
    _fetchSimilarProducts();
    _fetchStoreInfo();
    _updateCartQuantity();
  }

  void _updateCartQuantity() {
    final cartProvider = Provider.of<UnifiedCartProvider>(context, listen: false);
    final item = cartProvider.items.firstWhere(
      (e) => e.id == widget.product.id && e.type == CartItemType.store,
      orElse: () => CartItem(
        id: '',
        name: '',
        price: 0,
        quantity: 0,
        image: '',
        type: CartItemType.store,
      ),
    );
    setState(() {
      _cartQuantity = item.quantity;
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
    if (widget.product.vendorId == null) return;
    
    setState(() {
      _loadingStore = true;
    });
    try {
      final store = await StoreService.getStoreById(widget.product.vendorId!);
      setState(() {
        _store = store ?? Store.demoStore;
        _loadingStore = false;
      });
    } catch (e) {
      setState(() {
        _store = Store.demoStore;
        _loadingStore = false;
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
    final isDark = theme.brightness == Brightness.dark;
    final cartProvider = Provider.of<UnifiedCartProvider>(context, listen: false);

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
                          print('🛒 Product Details - Adding item to cart:');
                          print('  - Item: ${product.name}');
                          print('  - Price: ${product.price}');
                          print('  - Cart items before: ${cartProvider.items.length}');
                          
                          cartProvider.addStoreItem(
                            id: product.id,
                            name: product.name,
                            price: product.price,
                            quantity: 1,
                            image: product.imageUrl,
                            vendorId: product.vendorId,
                            store: _store,
                          );
                          
                          print('  - Cart items after: ${cartProvider.items.length}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added to cart'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: theme.colorScheme.primary,
                              action: SnackBarAction(
                                label: 'View Cart',
                                textColor: Colors.white,
                                onPressed: () {
                                  Navigator.pushNamed(context, '/multi-store-cart');
                                },
                              ),
                            ),
                          );
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

  Widget _buildFrequentlyBoughtTogether() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final totalPrice = widget.product.price +
        _frequentlyBoughtTogether
            .where((item) => item['isSelected'])
            .fold(0.0, (sum, item) => sum + (item['product'] as Product).price);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Frequently Bought Together',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _frequentlyBoughtTogether.length,
            itemBuilder: (context, index) {
              final item = _frequentlyBoughtTogether[index];
              final product = item['product'] as Product;
              return CheckboxListTile(
                value: item['isSelected'],
                onChanged: (value) {
                  setState(() {
                    item['isSelected'] = value;
                  });
                },
                title: Text(product.name),
                subtitle: Text('Rs ${product.price}'),
                secondary: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedImage(
                    imageUrl: product.imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Total: Rs ${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  // Add all selected items to cart
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All items added to cart'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pushNamed(context, AppRoutes.cart);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Add All to Cart'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<UnifiedCartProvider>(context);
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    print('🛒 Product Details - Build method:');
    print('  - Cart items count: ${cartProvider.items.length}');
    print('  - Should show FAB: ${cartProvider.items.isNotEmpty}');
    
    // Check if this product is in cart
    final cartItem = cartProvider.items.firstWhere(
      (item) => item.id == widget.product.id && item.type == CartItemType.store,
      orElse: () => CartItem(
        id: '',
        name: '',
        price: 0,
        quantity: 0,
        image: '',
        type: CartItemType.store,
      ),
    );
    final isInCart = cartItem.id.isNotEmpty;
    
    // Update cart quantity when cart changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateCartQuantity();
      }
    });
    
    return Scaffold(
      floatingActionButton: cartProvider.items.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.multiStoreCart);
              },
              backgroundColor: Colors.orange,
              child: Stack(
                children: [
                  const Icon(Icons.shopping_cart, color: Colors.white),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        '${cartProvider.items.length}',
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
                        print('🛒 Product Details - Main Add to Cart button:');
                        print('  - Item: ${widget.product.name}');
                        print('  - Price: ${widget.product.price}');
                        print('  - Quantity: $_quantity');
                        print('  - Cart items before: ${cartProvider.items.length}');
                        
                        cartProvider.addStoreItem(
                          id: widget.product.id,
                          name: widget.product.name,
                          price: widget.product.price,
                          quantity: _quantity,
                          image: widget.product.imageUrl,
                          vendorId: widget.product.vendorId,
                          store: _store,
                        );
                        
                        print('  - Cart items after: ${cartProvider.items.length}');
                        setState(() {
                          _cartQuantity = _quantity;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${widget.product.name} (x$_quantity) added to cart'),
                            behavior: SnackBarBehavior.floating,
                            action: SnackBarAction(
                              label: 'View Cart',
                              onPressed: () {
                                Navigator.pushNamed(context, '/multi-store-cart');
                              },
                            ),
                          ),
                        );
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