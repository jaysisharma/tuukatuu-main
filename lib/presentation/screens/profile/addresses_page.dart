import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuukatuu/providers/address_provider.dart';
import 'package:tuukatuu/models/address.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    final addresses = addressProvider.addresses
        .where((a) => _search.isEmpty || 
            a.label.toLowerCase().contains(_search.toLowerCase()) || 
            a.address.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('My Addresses'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search addresses',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: theme.colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: addressProvider.fetchAddresses,
              child: addressProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : addresses.isEmpty
                      ? _buildEmptyState(context)
                      : FadeTransition(
                          opacity: _fadeAnimation,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
                            itemCount: addresses.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, i) {
                              final address = addresses[i];
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
                                            child: Icon(icon, color: color, size: 22),
                                            radius: 18,
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
                                                              await addressProvider.setDefaultAddress(address.id);
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
                                                            final result = await showDialog(
                                                              context: context,
                                                              builder: (_) => AddressDialog(address: address),
                                                            );
                                                            if (result == true) addressProvider.fetchAddresses();
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
                                                            final confirm = await showDialog<bool>(
                                                              context: context,
                                                              builder: (context) => AlertDialog(
                                                                title: const Text('Delete Address'),
                                                                content: Text('Are you sure you want to delete "${address.label}"?'),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () => Navigator.pop(context, false),
                                                                    child: const Text('Cancel'),
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed: () => Navigator.pop(context, true),
                                                                    style: ElevatedButton.styleFrom(
                                                                      backgroundColor: theme.colorScheme.error
                                                                    ),
                                                                    child: const Text('Delete'),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                            if (confirm == true) {
                                                              await addressProvider.deleteAddress(address.id);
                                                            }
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
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SizedBox(
            width: 200,
            child: FloatingActionButton.extended(
              onPressed: () async {
                final result = await showDialog(
                  context: context,
                  builder: (_) => const AddressDialog(),
                );
                if (result == true) addressProvider.fetchAddresses();
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Address'),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 6,
            ),
          ),
        ),
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
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final addressProvider = Provider.of<AddressProvider>(context, listen: false);
                final result = await showDialog(
                  context: context,
                  builder: (_) => const AddressDialog(),
                );
                if (result == true) addressProvider.fetchAddresses();
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Address'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddressDialog extends StatefulWidget {
  final Address? address;
  const AddressDialog({super.key, this.address});

  @override
  State<AddressDialog> createState() => _AddressDialogState();
}

class _AddressDialogState extends State<AddressDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  late TextEditingController _addressController;
  late TextEditingController _instructionsController;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.address?.label ?? '');
    _addressController = TextEditingController(text: widget.address?.address ?? '');
    _instructionsController = TextEditingController(text: widget.address?.instructions ?? '');
  }

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final provider = Provider.of<AddressProvider>(context, listen: false);
      
      final addressData = {
        'label': _labelController.text.trim(),
        'address': _addressController.text.trim(),
        'coordinates': {
          'latitude': widget.address?.latitude ?? 27.7172, // Default to Kathmandu
          'longitude': widget.address?.longitude ?? 85.3240,
        },
        'type': _getAddressType(_labelController.text.trim()),
        'instructions': _instructionsController.text.trim(),
        'isDefault': false,
      };

      if (widget.address == null) {
        await provider.createAddress(addressData);
      } else {
        await provider.updateAddress(widget.address!.id, addressData);
      }
      
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _getAddressType(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return 'home';
      case 'work':
        return 'work';
      default:
        return 'other';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.address == null ? 'Add Address' : 'Edit Address',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _labelController,
                  decoration: const InputDecoration(
                    labelText: 'Label',
                    hintText: 'e.g. Home, Work, Gym',
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Label is required' : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    hintText: 'Enter your full address',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Address is required' : null,
                  textInputAction: TextInputAction.next,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _instructionsController,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Instructions (Optional)',
                    hintText: 'e.g. Near the main gate, 2nd floor',
                    prefixIcon: Icon(Icons.info_outline),
                  ),
                  textInputAction: TextInputAction.done,
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _loading ? null : () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _loading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(100, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _loading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, 
                                color: theme.colorScheme.onPrimary
                              ),
                            )
                          : Text(widget.address == null ? 'Add' : 'Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
