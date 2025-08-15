import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuukatuu/providers/address_provider.dart';
import 'package:tuukatuu/providers/auth_provider.dart';
import 'package:tuukatuu/models/address.dart';
import 'package:tuukatuu/presentation/screens/location/location_screen.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.forward());
    _initializeAddressProvider();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initializeAddressProvider() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);
    
    if (authProvider.jwtToken != null) {
      addressProvider.initialize(authProvider.jwtToken!);
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _updateAddressLabel(Address address) async {
    final controller = TextEditingController(text: address.label);

    final newLabel = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Edit Address Label",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              address.address,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "e.g., Home, Work, Gym",
                labelText: "Label",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, controller.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Update"),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (newLabel != null && newLabel.isNotEmpty && newLabel != address.label) {
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      final success = await addressProvider.updateAddress(address.id, {'label': newLabel});
      
      if (mounted) {
        if (success) {
          _showSnackBar("Address updated to '$newLabel'");
        } else {
          _showSnackBar("Failed to update address");
        }
      }
    }
  }

  Future<void> _deleteAddress(Address address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Delete Address"),
          content: Text("Are you sure you want to delete '${address.label}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirmed) {
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      final success = await addressProvider.deleteAddress(address.id);
      
      if (mounted) {
        if (success) {
          _showSnackBar("Address '${address.label}' deleted");
        } else {
          _showSnackBar("Failed to delete address");
        }
      }
    }
  }

  Future<void> _setDefaultAddress(Address address) async {
    if (address.isDefault) return;
    
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);
    final success = await addressProvider.setDefaultAddress(address.id);
    
    if (mounted) {
      if (success) {
        _showSnackBar("'${address.label}' set as default address");
      } else {
        _showSnackBar("Failed to set default address");
      }
    }
  }

  Future<void> _navigateToLocationPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationScreen(),
      ),
    );

    if (result != null && result is Map<String, String>) {
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      await addressProvider.fetchAddresses();
      _showSnackBar("Address added successfully!");
    }
  }

  IconData _getLabelIcon(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home_rounded;
      case 'work':
        return Icons.work_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  Color _getLabelColor(BuildContext context, String label) {
    final theme = Theme.of(context);
    switch (label.toLowerCase()) {
      case 'home':
        return theme.colorScheme.primary;
      case 'work':
        return theme.colorScheme.secondary;
      default:
        return theme.colorScheme.tertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = Provider.of<AddressProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('My Addresses'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
       
      ),
      body: RefreshIndicator(
        onRefresh: addressProvider.fetchAddresses,
        child: addressProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : addressProvider.addresses.isEmpty
                ? _buildEmptyState(context)
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
                      itemCount: addressProvider.addresses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final address = addressProvider.addresses[i];
                        final label = address.label;
                        final icon = _getLabelIcon(label);
                        final color = _getLabelColor(context, label);
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: null,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: theme.colorScheme.surface,
                                border: address.isDefault 
                                    ? Border.all(color: theme.colorScheme.primary, width: 2)
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.shadowColor.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: color.withOpacity(0.12),
                                      radius: 18,
                                      child: Icon(icon, color: color, size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      label,
                                                      style: theme.textTheme.titleSmall?.copyWith(
                                                        fontWeight: FontWeight.bold, 
                                                        color: color
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    if (address.isDefault) ...[
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 6, 
                                                          vertical: 2
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: theme.colorScheme.primary,
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Text(
                                                          'Default',
                                                          style: TextStyle(
                                                            color: theme.colorScheme.onPrimary,
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  if (!address.isDefault)
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.star_outline_rounded, 
                                                        color: theme.colorScheme.primary, 
                                                        size: 20
                                                      ),
                                                      tooltip: 'Set as default',
                                                      onPressed: () async {
                                                        await _setDefaultAddress(address);
                                                      },
                                                    ),
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.edit_rounded, 
                                                      color: theme.colorScheme.primary, 
                                                      size: 20
                                                    ),
                                                    tooltip: 'Edit',
                                                    onPressed: () async {
                                                      await _updateAddressLabel(address);
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.delete_outline_rounded, 
                                                      color: theme.colorScheme.error, 
                                                      size: 20
                                                    ),
                                                    tooltip: 'Delete',
                                                    onPressed: () async {
                                                      await _deleteAddress(address);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on_outlined, 
                                                size: 16, 
                                                color: theme.colorScheme.primary
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  address.address,
                                                  style: theme.textTheme.bodyMedium,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (address.instructions.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.info_outline_rounded, 
                                                    size: 14, 
                                                    color: theme.colorScheme.onSurface.withOpacity(0.6)
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      address.instructions,
                                                      style: theme.textTheme.bodySmall?.copyWith(
                                                        color: theme.colorScheme.onSurface.withOpacity(0.6)
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToLocationPage,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Address'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.maps_home_work_rounded, 
              size: 80, 
              color: theme.colorScheme.primary.withOpacity(0.18)
            ),
            const SizedBox(height: 24),
            Text(
              'No addresses found',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold, 
                color: theme.colorScheme.onSurface.withOpacity(0.7)
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Add your home, work, or other addresses to make ordering easier and faster.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5)
              ),
              textAlign: TextAlign.center,
            ),
         
          ],
        ),
      ),
    );
  }
}
