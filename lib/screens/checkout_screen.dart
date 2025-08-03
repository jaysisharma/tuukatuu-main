import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/address.dart';
import 'package:provider/provider.dart';
import '../providers/address_provider.dart';
import '../providers/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/cached_image.dart';
import '../services/api_service.dart';

class CheckoutScreen extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> cartItems;
  final bool isTmartOrder;

  const CheckoutScreen({
    super.key,
    required this.totalAmount,
    required this.cartItems,
    this.isTmartOrder = false,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedAddressIndex = 0;
  int _selectedPaymentMethodIndex = 0;
  int _selectedDeliveryTimeIndex = 0;
  int _selectedTipIndex = 1;
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _customTipController = TextEditingController();
  bool _isCustomTip = false;
  bool _showAllAddresses = false;

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
      'color': Color(0xFF60BB46),
    },
    {
      'type': 'Khalti',
      'details': 'Pay with Khalti',
      'icon': null,
      'logo': 'https://khalti.com/static/images/khalti-logo.png',
      'color': Color(0xFF5C2D91),
    },
    {
      'type': 'FonePay',
      'details': 'Pay with FonePay',
      'icon': null,
      'logo': 'https://fonepay.com/images/logo.png',
      'color': Color(0xFF003C7E),
    },
    {
      'type': 'ConnectIPS',
      'details': 'Pay with ConnectIPS',
      'icon': null,
      'logo': 'https://connectips.com/images/logo.png',
      'color': Color(0xFF00529B),
    },
    {
      'type': 'IME Pay',
      'details': 'Pay with IME Pay',
      'icon': null,
      'logo': 'https://imepay.com.np/images/logo.png',
      'color': Color(0xFFE31837),
    },
  ];

  final List<String> _deliveryTimes = [
    'As soon as possible',
    'In 30 minutes',
    'In 1 hour',
    'In 2 hours',
  ];

  final List<int> _tipOptions = [20, 50, 100];

  // Last-minute add-ons
  final List<Map<String, dynamic>> _lastMinuteAddOns = [
    {
      'name': 'Disposable Cutlery',
      'price': 10.0,
      'isSelected': false,
    },
    {
      'name': 'Extra Napkins',
      'price': 5.0,
      'isSelected': false,
    },
    {
      'name': 'Carry Bag',
      'price': 15.0,
      'isSelected': false,
    },
  ];

  // Products you might have missed
  final List<Product> _missedProducts = Product.dummyProducts.take(3).toList();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      print('🔍 Checkout: Fetching addresses...');
      // Always fetch addresses to ensure they're loaded
      addressProvider.fetchAddresses().then((_) {
        print('🔍 Checkout: Addresses loaded: ${addressProvider.addresses.length}');
        if (mounted) {
          setState(() {
            // Reset selected address index if current selection is invalid
            if (_selectedAddressIndex >= addressProvider.addresses.length) {
              _selectedAddressIndex = addressProvider.addresses.isNotEmpty ? 0 : -1;
            }
          });
        }
      }).catchError((error) {
        print('❌ Error fetching addresses: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load addresses: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    _customTipController.dispose();
    super.dispose();
  }

  double _getSelectedTip() {
    if (_isCustomTip) {
      return double.tryParse(_customTipController.text) ?? 0.0;
    }
    return _tipOptions[_selectedTipIndex].toDouble();
  }

  double _getAddOnsTotal() {
    return _lastMinuteAddOns
        .where((item) => item['isSelected'])
        .fold(0.0, (sum, item) => sum + (item['price'] as double));
  }

  double _calculateFinalTotal() {
    return widget.totalAmount + _getSelectedTip() + _getAddOnsTotal();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final addressProvider = Provider.of<AddressProvider>(context);
    final addresses = addressProvider.addresses;
    final showMoreButton = !_showAllAddresses && addresses.length > 2;
    final visibleAddresses = showMoreButton ? addresses.take(2).toList() : addresses;

    return Scaffold(
      appBar: AppBar(
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
          // T-Mart Order Indicator
          if (widget.isTmartOrder)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFFC8019).withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.local_grocery_store,
                    color: const Color(0xFFFC8019),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'T-Mart Order - High Priority',
                    style: TextStyle(
                      color: const Color(0xFFFC8019),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFC8019),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '20 min',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: theme.cardColor,
                    child: Row(
                      children: [
                        _buildProgressStep(1, 'Address', true),
                        _buildProgressLine(true),
                        _buildProgressStep(2, 'Payment', false),
                        _buildProgressLine(false),
                        _buildProgressStep(3, 'Summary', false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Main Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionWithHeader(
                          'Delivery Address',
                          Icons.location_on_outlined,
                          _buildAddressSection(addressProvider, visibleAddresses, showMoreButton),
                        ),
                        const SizedBox(height: 24),
                        _buildSectionWithHeader(
                          'Delivery Time',
                          Icons.access_time,
                          _buildDeliveryTimeSection(),
                        ),
                        const SizedBox(height: 24),
                        _buildSectionWithHeader(
                          'Payment Method',
                          Icons.payment_outlined,
                          _buildPaymentMethodSection(),
                        ),
                        const SizedBox(height: 24),
                        _buildSectionWithHeader(
                          'Rider Tip',
                          Icons.volunteer_activism_outlined,
                          _buildTipSection(),
                        ),
                        const SizedBox(height: 24),
                        _buildSectionWithHeader(
                          'Order Summary',
                          Icons.receipt_long_outlined,
                          _buildOrderSummary(),
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
                ],
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
                            'Rs ${_calculateFinalTotal().toStringAsFixed(2)}',
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
                          onPressed: addresses.isEmpty ? null : () {
                            _placeOrder();
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

  void _placeOrder() async {
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (addressProvider.addresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a delivery address first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedAddressIndex < 0 || _selectedAddressIndex >= addressProvider.addresses.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a delivery address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final selectedAddress = addressProvider.addresses[_selectedAddressIndex];
    
    // Validate address coordinates
    if (selectedAddress.latitude == 0 && selectedAddress.longitude == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected address is missing coordinates. Please select a valid address.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Determine if this is a T-Mart order
    final isTmartOrder = widget.isTmartOrder || 
        (widget.cartItems.isNotEmpty && widget.cartItems.first['orderType'] == 'tmart');
    
    // Calculate totals
    final itemTotal = widget.cartItems.fold<double>(0, (sum, item) => sum + (item['price'] * item['quantity']));
    final deliveryFee = isTmartOrder ? (itemTotal >= 500 ? 0.0 : 40.0) : 40.0;
    final tax = itemTotal * 0.05;
    final tip = _getSelectedTip();
    final total = itemTotal + tax + deliveryFee + tip;

    final orderPayload = {
      'vendorId': isTmartOrder ? 'tmart' : 'vendor_id', // Replace with actual vendor ID
      'items': widget.cartItems.map((item) => ({
        'productId': item['id'],
        'name': item['name'],
        'price': item['price'],
        'quantity': item['quantity'],
        'image': item['image'] ?? item['imageUrl'],
        'unit': item['unit'],
      })),
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
      'customerLocation': {
        'latitude': selectedAddress.latitude,
        'longitude': selectedAddress.longitude,
        'address': selectedAddress.address,
        'label': selectedAddress.label,
      },
    };

    try {
      final endpoint = isTmartOrder ? '/orders/tmart' : '/orders';
      final order = await ApiService.post(
        endpoint,
        token: authProvider.jwtToken,
        body: orderPayload,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildProgressStep(int step, String label, bool isActive) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? theme.colorScheme.primary : (isDark ? Colors.grey[800] : Colors.grey[200]),
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
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
            color: isActive ? theme.colorScheme.primary : (isDark ? Colors.grey[400] : Colors.grey[600]),
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool isActive) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isActive ? theme.colorScheme.primary : (isDark ? Colors.grey[800] : Colors.grey[200]),
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

  Widget _buildAddressSection(AddressProvider addressProvider, List<Address> visibleAddresses, bool showMoreButton) {
    if (addressProvider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (visibleAddresses.isEmpty) {
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
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'No addresses found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please add a delivery address to continue',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to add address screen
                Navigator.pushNamed(context, '/add-address');
              },
              icon: const Icon(Icons.add_location),
              label: const Text('Add Address'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
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
                if (address.latitude != 0 && address.longitude != 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '${address.latitude.toStringAsFixed(4)}, ${address.longitude.toStringAsFixed(4)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
        if (showMoreButton)
          TextButton(
            onPressed: () => setState(() => _showAllAddresses = true),
            child: const Text('Show More Addresses'),
          ),
        const SizedBox(height: 16),
        // Add New Address Button
        Container(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Navigate to add address screen
              Navigator.pushNamed(context, '/add-address');
            },
            icon: const Icon(Icons.add_location),
            label: const Text('Add New Address'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
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

  Widget _buildDeliveryTimeSection() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).cardColor,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _deliveryTimes.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedDeliveryTimeIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(_deliveryTimes[index]),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedDeliveryTimeIndex = index);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTipSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Add Tip for Rider',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.volunteer_activism,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Show your appreciation for the rider\'s service',
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ..._tipOptions.asMap().entries.map((entry) {
              final index = entry.key;
              final amount = entry.value;
              final isSelected = !_isCustomTip && index == _selectedTipIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isCustomTip = false;
                      _selectedTipIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colorScheme.primary : theme.cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                      ),
                    ),
                    child: Text(
                      'Rs $amount',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isCustomTip = true;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _isCustomTip ? theme.colorScheme.primary : theme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isCustomTip
                          ? theme.colorScheme.primary
                          : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                    ),
                  ),
                  child: _isCustomTip
                      ? TextField(
                          controller: _customTipController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isCustomTip ? Colors.white : null,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Custom',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: _isCustomTip ? Colors.white70 : null,
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (value) {
                            setState(() {});
                          },
                        )
                      : const Text(
                          'Custom',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
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
          _buildSummaryRow('Subtotal', widget.totalAmount - 40 - (widget.totalAmount * 0.13)),
          const SizedBox(height: 4),
          _buildSummaryRow('Tax (13%)', widget.totalAmount * 0.13),
          const SizedBox(height: 4),
          _buildSummaryRow('Delivery Fee', 40.0),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        Text(
          'Rs ${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
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
                  Icon(
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
} 