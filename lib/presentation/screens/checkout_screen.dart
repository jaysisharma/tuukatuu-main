import 'package:flutter/material.dart';
import '../../models/address.dart';
import 'package:provider/provider.dart';
import '../../providers/address_provider.dart';
import '../../providers/unified_cart_provider.dart';
import '../../providers/mart_cart_provider.dart';
import 'order_placed_screen.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/cached_image.dart';
import '../../services/api_service.dart';
import '../screens/location/location_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> cartItems;
  final bool isTmartOrder;
  final VoidCallback? onOrderSuccess;
  final String? vendorId; // Add vendorId parameter

  const CheckoutScreen({
    super.key,
    required this.totalAmount,
    required this.cartItems,
    this.isTmartOrder = false,
    this.onOrderSuccess,
    this.vendorId,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedAddressIndex = 0;
  int _selectedPaymentMethodIndex = 0;
  int _selectedTipIndex = 0; // Default to 20
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _customTipController = TextEditingController();
  bool _isCustomTip = false;
  bool _showAllAddresses = false;
  final ScrollController _scrollController = ScrollController();
  int _currentStep = 0; // 0: Address, 1: Payment, 2: Summary

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      print('🔍 Checkout: Fetching addresses...');
      // Always fetch addresses to ensure they're loaded
      addressProvider.fetchAddresses().then((_) {
        print('🔍 Checkout: Addresses loaded: ${addressProvider.addresses.length}');
      });
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _instructionsController.dispose();
    _customTipController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Find which section is visible and update _currentStep
    // Use context.findRenderObject for each section key
    final paymentBox = _paymentSectionKey.currentContext?.findRenderObject() as RenderBox?;
    final summaryBox = _summarySectionKey.currentContext?.findRenderObject() as RenderBox?;
    int newStep = 0;
    if (summaryBox != null && summaryBox.localToGlobal(Offset.zero).dy < 120) {
      newStep = 2;
    } else if (paymentBox != null && paymentBox.localToGlobal(Offset.zero).dy < 120) {
      newStep = 1;
    } else {
      newStep = 0;
    }
    if (newStep != _currentStep) {
      setState(() {
        _currentStep = newStep;
      });
    }
  }

  final GlobalKey _addressSectionKey = GlobalKey();
  final GlobalKey _paymentSectionKey = GlobalKey();
  final GlobalKey _summarySectionKey = GlobalKey();

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'type': 'Cash on Delivery',
      'details': 'Pay when you receive',
      'icon': Icons.money,
      'logo': null,
      'color': null,
    },
    {
      'type': 'eSewa',
      'details': 'Pay with eSewa',
      'icon': null,
      'logo': 'https://esewa.com.np/common/images/esewa_logo.png',
      'color': const Color(0xFF60BB46),
    },
    {
      'type': 'Khalti',
      'details': 'Pay with Khalti',
      'icon': null,
      'logo': 'https://khalti.com/static/images/khalti-logo.png',
      'color': const Color(0xFF5C2D91),
    },
    {
      'type': 'FonePay',
      'details': 'Pay with FonePay',
      'icon': null,
      'logo': 'https://fonepay.com/images/logo.png',
      'color': const Color(0xFF003C7E),
    },
    {
      'type': 'ConnectIPS',
      'details': 'Pay with ConnectIPS',
      'icon': null,
      'logo': 'https://connectips.com/images/logo.png',
      'color': const Color(0xFF00529B),
    },
    {
      'type': 'IME Pay',
      'details': 'Pay with IME Pay',
      'icon': null,
      'logo': 'https://imepay.com.np/images/logo.png',
      'color': const Color(0xFFE31837),
    },
  ];


  final List<int> _tipOptions = [20, 50, 100];

  double _getSelectedTip() {
    if (_isCustomTip) {
      final customAmount = double.tryParse(_customTipController.text) ?? 0.0;
      // Limit custom tip to 1000 rupees
      return customAmount > 1000 ? 1000.0 : customAmount;
    }
    return _tipOptions[_selectedTipIndex].toDouble();
  }

  double _getAddOnsTotal() {
    return 0.0; // _lastMinuteAddOns is not defined
  }


  Color _stepColor(bool isActive) {
    return isActive ? Colors.orange : Colors.grey[400]!;
  }

  Widget _buildProgressStep(int step, String label, bool isActive, bool isCompleted) {
    // Orange for active, grey for inactive, no green
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _stepColor(isActive),
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: _stepColor(isActive),
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool isActive, bool isCompleted) {
    // Orange for active, grey for inactive, no green
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: _stepColor(isActive),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final addressProvider = Provider.of<AddressProvider>(context);
    Provider.of<UnifiedCartProvider>(context);
    final addresses = addressProvider.addresses;
    
    // Debug logging
    print('🔍 Checkout Build: Addresses count: ${addresses.length}, Loading: ${addressProvider.isLoading}');
    
    final showMoreButton = !_showAllAddresses && addresses.length > 2;
    final visibleAddresses = showMoreButton ? addresses.take(2).toList() : addresses;

    final itemTotal = widget.cartItems.fold<double>(0, (sum, item) => sum + (item['price'] * item['quantity']));
    final deliveryFee = itemTotal < 400 ? 40.0 : 0.0;
    final tax = itemTotal * 0.05;
    final tip = _getSelectedTip();
    final total = itemTotal + tax + deliveryFee + tip;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          widget.isTmartOrder ? 'T-Mart Checkout' : 'Checkout',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [

          
          // Dynamic Progress Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: theme.cardColor,
            child: Row(
              children: [
                _buildProgressStep(1, 'Address', _currentStep == 0 || _currentStep > 0, false),
                _buildProgressLine(_currentStep >= 0, false),
                _buildProgressStep(2, 'Payment', _currentStep == 1 || _currentStep > 1, false),
                _buildProgressLine(_currentStep >= 1, false),
                _buildProgressStep(3, 'Summary', _currentStep == 2, false),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Address Section
                    Container(
                      key: _addressSectionKey,
                      child: _buildSectionWithHeader(
                        'Delivery Address',
                        Icons.location_on_outlined,
                        Column(
                          children: [
                            if (addressProvider.isLoading)
                              const Center(child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ))
                            else if (addresses.isEmpty)
                              const Center(child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text('No addresses found. Please add an address.'),
                              ))
                            else ...[
                              ...visibleAddresses.asMap().entries.map((entry) {
                                final index = entry.key;
                                final address = entry.value;
                                final isSelected = index == _selectedAddressIndex;
                                return _buildSelectionTile(
                                  isSelected: isSelected,
                                  onTap: () => setState(() => _selectedAddressIndex = index),
                                  leading: Icon(
                                    _getAddressIcon(address.label),
                                    color: isSelected ? Colors.white : null,
                                  ),
                                  title: address.label,
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(address.address),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          '${address.latitude.toStringAsFixed(4)}, ${address.longitude.toStringAsFixed(4)}',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              if (showMoreButton)
                                TextButton(
                                  onPressed: () => setState(() => _showAllAddresses = true),
                                  child: const Text('More Addresses'),
                                ),
                            ],
                            const SizedBox(height: 16),
                            // Select Different Location Button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  try {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LocationScreen(),
                                      ),
                                    );
                                    if (result != null && result is Map<String, dynamic>) {
                                      // Add the new location to the list temporarily
                                      setState(() {
                                        // Convert the result to Address model format
                                        final newAddress = Address(
                                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                                          label: result['addressData']['label'] ?? 'New Location',
                                          address: result['addressData']['address'] ?? '',
                                          latitude: result['addressData']['coordinates']?['latitude']?.toDouble() ?? 0.0,
                                          longitude: result['addressData']['coordinates']?['longitude']?.toDouble() ?? 0.0,
                                          type: 'other',
                                          instructions: '',
                                          isDefault: false,
                                          isVerified: false,
                                          createdAt: DateTime.now(),
                                          updatedAt: DateTime.now(),
                                        );
                                        addresses.add(newAddress);
                                        _selectedAddressIndex = addresses.length - 1;
                                      });
                                    }
                                  } catch (e) {
                                    // Silent error handling
                                  }
                                },
                                icon: const Icon(Icons.add_location),
                                label: const Text('Select Different Location'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.orange,
                                  side: const BorderSide(color: Colors.orange),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Payment Section
                    Container(
                      key: _paymentSectionKey,
                      child: _buildSectionWithHeader(
                        'Payment Method',
                        Icons.payment_outlined,
                        _buildPaymentMethodSection(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Tip Section (move here, before order summary)
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(Icons.volunteer_activism, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        const Text('Add Tip for Rider', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._tipOptions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final amount = entry.value;
                          final isSelected = !_isCustomTip && index == _selectedTipIndex;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _isCustomTip = false;
                                _selectedTipIndex = index;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[300]!),
                                ),
                              ),
                              child: Text(
                                'Rs $amount',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isCustomTip = true;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _isCustomTip ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _isCustomTip
                                    ? Theme.of(context).colorScheme.primary
                                    : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[300]!),
                              ),
                            ),
                            child: _isCustomTip
                                ? SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: _customTipController,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: 'Custom',
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(
                                          color: Colors.white70,
                                        ),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      onChanged: (value) {
                                        // Validate custom tip amount
                                        final amount = double.tryParse(value);
                                        if (amount != null && amount > 1000) {
                                          _customTipController.text = '1000';
                                          _customTipController.selection = TextSelection.fromPosition(
                                            TextPosition(offset: _customTipController.text.length),
                                          );
                                        }
                                        setState(() {});
                                      },
                                    ),
                                  )
                                : const Text(
                                    'Custom',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                                          if (_isCustomTip)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 4),
                          child: Text(
                            'Enter your own tip amount (max Rs 1000)',
                            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                    // Summary Section
                    Container(
                      key: _summarySectionKey,
                      child: _buildSectionWithHeader(
                        'Order Summary',
                        Icons.receipt_long_outlined,
                        _buildOrderSummary(itemTotal, tax, deliveryFee, tip, total),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionWithHeader(
                      'Special Instructions',
                      Icons.note_outlined,
                      TextField(
                        controller: _instructionsController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Add any special instructions...',
                          filled: true,
                          fillColor: theme.cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          // Bottom Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Amount',
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rs ${total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () async {
                            final addressProvider = Provider.of<AddressProvider>(context, listen: false);
                            final authProvider = Provider.of<AuthProvider>(context, listen: false);
                            final addresses = addressProvider.addresses;
                            if (addresses.isEmpty) {
                              return;
                            }
                            final selectedAddress = addresses[_selectedAddressIndex];
                            
                            // Use the unified cart provider
                            final cartProvider = Provider.of<UnifiedCartProvider>(context, listen: false);
                            
                            // Determine if this is a T-Mart order
                            final isTmartOrder = widget.isTmartOrder || 
                                (widget.cartItems.isNotEmpty && widget.cartItems.first['orderType'] == 'tmart');
                            
                            // Get vendorId from cart items instead of cart provider
                            String? vendorId;
                            if (widget.cartItems.isNotEmpty) {
                              final firstItem = widget.cartItems.first;
                              vendorId = firstItem['vendorId']?.toString();
                            }
                            
                            // Fallback to hardcoded vendorId if not found in cart items
                            if (vendorId == null || vendorId.isEmpty) {
                              vendorId = isTmartOrder ? 'tmart' : 'vendor_id';
                            }
                            final items = widget.cartItems.map((item) => {
                              'product': item['id'],
                              'quantity': item['quantity'],
                            }).toList();
                            final tip = _getSelectedTip();
                            final addOnsTotal = _getAddOnsTotal();
                            final itemTotal = widget.totalAmount;
                            final tax = itemTotal * 0.05; // Changed from 0.13 to 0.05 to match the summary display
                            
                            final total = itemTotal + tax + deliveryFee + tip + addOnsTotal;
                            
                            // Check if address has valid coordinates
                            if (selectedAddress.latitude == 0 && selectedAddress.longitude == 0) {
                              return;
                            }

                            // Validate coordinates are within reasonable bounds
                            if (selectedAddress.latitude < -90 || selectedAddress.latitude > 90 ||
                                selectedAddress.longitude < -180 || selectedAddress.longitude > 180) {
                              return;
                            }

                            print("Final Vendor ID: $vendorId");
                            print("Cart items: ${widget.cartItems.length}");
                            if (widget.cartItems.isNotEmpty) {
                              print("First cart item: ${widget.cartItems.first}");
                              print("First cart item vendorId: ${widget.cartItems.first['vendorId']}");
                            }
                            
                            // Validate vendorId is not null or empty
                            if (vendorId.isEmpty) {
                              return;
                            }
                            final orderPayload = {
                              'vendorId': vendorId,
                              'items': items,
                              'itemTotal': itemTotal,
                              'tax': tax,
                              'deliveryFee': deliveryFee,
                              'tip': tip,
                              'total': total,
                              'deliveryAddress': selectedAddress.address,
                              'instructions': _instructionsController.text,
                              'paymentMethod': _selectedPaymentMethodIndex == 0 ? 'cash' : 'card',
                              'orderType': isTmartOrder ? 'tmart' : 'regular',
                              'priority': isTmartOrder ? 'high' : 'low',
                              // Only include coordinates if they're valid
                              if (selectedAddress.latitude != 0 && selectedAddress.longitude != 0)
                                'customerLocation': {
                                  'latitude': selectedAddress.latitude,
                                  'longitude': selectedAddress.longitude,
                                  'address': selectedAddress.address,
                                  'label': selectedAddress.label,
                                },
                            };
print("Place Order Pressed");
                            try {
                              final endpoint = isTmartOrder ? '/orders' : '/orders';
                              final order = await ApiService.post(
                                endpoint,
                                token: authProvider.jwtToken,
                                body: orderPayload,
                              );
                              // Clear only the specific vendor's items instead of entire cart
                              if (widget.vendorId != null) {
                                print('🛒 Checkout - Clearing items for vendor: ${widget.vendorId}');
                                cartProvider.clearItemsByVendor(widget.vendorId!);
                              } else {
                                print('🛒 Checkout - No vendorId provided, clearing entire cart');
                                cartProvider.clearCart();
                              }
                              
                              // For T-Mart orders, also clear the MartCartProvider
                              if (widget.isTmartOrder) {
                                print('🛒 Checkout - Clearing MartCartProvider for T-Mart order');
                                final martCartProvider = Provider.of<MartCartProvider>(context, listen: false);
                                print('🛒 Checkout - MartCartProvider items before clearing: ${martCartProvider.items.length}');
                                martCartProvider.forceClearCart();
                                print('🛒 Checkout - MartCartProvider items after clearing: ${martCartProvider.items.length}');
                              }
                              
                              // Call the success callback if provided
                              if (widget.onOrderSuccess != null) {
                                widget.onOrderSuccess!();
                              }
                              
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrderPlacedScreen(orderId: order['_id'].toString()),
                                ),
                              );
                            } catch (e) {
                              // Silent error handling
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                          ),
                          child: const Text(
                            'Place Order',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionWithHeader(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildPaymentMethodSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: _paymentMethods.asMap().entries.map((entry) {
          final index = entry.key;
          final method = entry.value;
          final isSelected = index == _selectedPaymentMethodIndex;

          return Column(
            children: [
              if (index > 0)
                Divider(
                  height: 1,
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _selectedPaymentMethodIndex = index),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (method['color'] as Color? ?? theme.colorScheme.primary).withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        if (method['logo'] != null)
                          Container(
                            width: 40,
                            height: 40,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CachedImage(
                              imageUrl: method['logo'] as String,
                              height: 40,
                              width: 40,
                              fit: BoxFit.contain,
                            ),
                          )
                        else
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: (method['color'] as Color? ?? theme.colorScheme.primary).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              method['icon'] as IconData? ?? Icons.payment,
                              color: method['color'] as Color? ?? theme.colorScheme.primary,
                            ),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method['type'] as String,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? method['color'] as Color? ?? theme.colorScheme.primary
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                method['details'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Radio(
                          value: index,
                          groupValue: _selectedPaymentMethodIndex,
                          onChanged: (value) => setState(() => _selectedPaymentMethodIndex = value as int),
                          activeColor: method['color'] as Color? ?? theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }



  Widget _buildOrderSummary(double itemTotal, double tax, double deliveryFee, double tip, double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]!
              : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...widget.cartItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text(
                      '${item['quantity']}x',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item['name'] as String),
                    ),
                    Text(
                      'Rs ${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )),
          const Divider(),
          _buildSummaryRow('Item Total', itemTotal, description: 'Sum of all items in your cart'),
          const SizedBox(height: 4),
          _buildSummaryRow('Tax (5%)', tax, description: 'Government tax applied'),
          const SizedBox(height: 4),
          _buildSummaryRow('Delivery Fee', deliveryFee, description: deliveryFee == 0 ? 'Free delivery for orders above Rs 400' : 'Flat delivery charge'),
          if (tip > 0) _buildSummaryRow('Tip', tip, description: 'Thank your rider!'),
          const Divider(),
          _buildSummaryRow('Total', total, isBold: true, description: 'Final amount to pay'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isBold = false, String? description}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: isBold ? 16 : 14,
              ),
            ),
            Text(
              'Rs ${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                fontSize: isBold ? 16 : 14,
              ),
            ),
          ],
        ),
        if (description != null)
          Padding(
            padding: const EdgeInsets.only(left: 2, top: 2, bottom: 6),
            child: Text(
              description,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSelectionTile({
    required bool isSelected,
    required VoidCallback onTap,
    required Widget leading,
    required String title,
    required Widget subtitle,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary : theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withOpacity(0.2)
                        : (isDark ? Colors.grey[800] : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: leading,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected
                              ? Colors.white.withOpacity(0.8)
                              : theme.textTheme.bodyMedium?.color,
                        ),
                        child: subtitle,
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getAddressIcon(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home_rounded;
      case 'work':
        return Icons.work_rounded;
      default:
        return Icons.place_rounded;
    }
  }
} 