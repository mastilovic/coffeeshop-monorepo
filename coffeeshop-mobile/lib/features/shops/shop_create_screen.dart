import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_notifier.dart';
import '../../core/auth/user_permissions.dart';
import '../../core/network/api_exception.dart';
import '../../core/utils/validators.dart';
import '../../data/models/shop_response_dto.dart';
import '../../data/services/shop_api_service.dart';
import '../../shared/widgets/city_search_select.dart';
import '../../shared/widgets/empty_state_view.dart';
import '../shop_details/shop_manage_permission.dart';
import 'shop_providers.dart';

class ShopCreateScreen extends ConsumerStatefulWidget {
  const ShopCreateScreen({super.key, this.shopId});

  final String? shopId;

  bool get isEditing => shopId != null;

  @override
  ConsumerState<ShopCreateScreen> createState() => _ShopCreateScreenState();
}

class _ShopCreateScreenState extends ConsumerState<ShopCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedCity;
  String? _cityError;
  bool _isLoading = false;
  bool _isLoadingShop = false;

  bool get _canCreateShop {
    final permissions = ref.watch(userPermissionsProvider).valueOrNull;
    return permissions?.canCreateShop ?? false;
  }

  bool _canEditShop(String shopId) {
    final permissions = ref.watch(userPermissionsProvider).valueOrNull;
    return permissions?.canManageShop(shopId) ?? false;
  }

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadShopForEdit();
    }
  }

  Future<void> _loadShopForEdit() async {
    setState(() => _isLoadingShop = true);
    try {
      final data = await ref.read(shopApiServiceProvider).getById(widget.shopId!);
      final shop = ShopResponseDto.fromJson(data);
      _nameController.text = shop.name;
      _addressController.text = shop.address;
      _phoneController.text = shop.phoneNumber ?? '';
      _selectedCity = shop.city;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load shop details')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingShop = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _formatError(Object error) {
    if (error is ApiException) {
      return error.when(
        networkException: (message, _) => message,
        serverException: (message, _) => message,
        unauthorizedException: (message) => message,
        forbiddenException: (message) => message,
        validationException: (message, _) => message,
        unknownException: (message) => message,
      );
    }

    return error.toString().replaceFirst('Exception: ', '');
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCity == null) {
      setState(() => _cityError = 'City is required');
      return;
    }

    setState(() {
      _isLoading = true;
      _cityError = null;
    });

    try {
      if (widget.isEditing) {
        await ref.read(shopApiServiceProvider).update(widget.shopId!, {
          'name': _nameController.text.trim(),
          'address': _addressController.text.trim(),
          'city': _selectedCity!,
          'phoneNumber': _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
        });
        ref.invalidate(shopDetailProvider(widget.shopId!));
        ref.invalidate(shopListProvider);
        ref.invalidate(ownedShopsProvider);

        if (mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Shop updated')),
          );
        }
        return;
      }

      final userId = ref.read(authNotifierProvider).user?.id;
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You must be logged in to create a shop')),
          );
        }
        return;
      }

      final request = ShopCreateRequest(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        city: _selectedCity!,
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        ownerUserId: userId,
      );

      final created = await ref
          .read(shopApiServiceProvider)
          .create(request.toJson());

      ref.invalidate(shopListProvider);
      ref.invalidate(ownedShopsProvider);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Shop "${created['name']}" created')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Failed to update shop: ${_formatError(e)}'
                  : 'Failed to create shop: ${_formatError(e)}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing) {
      if (!_canEditShop(widget.shopId!)) {
        return Scaffold(
          appBar: AppBar(title: const Text('Edit Shop')),
          body: EmptyStateView(
            icon: Icons.lock_outline,
            message: 'You do not have permission to edit this shop.',
            actionLabel: 'Go back',
            onAction: () => context.pop(),
          ),
        );
      }
    } else if (!_canCreateShop) {
      return Scaffold(
        appBar: AppBar(title: const Text('Create Shop')),
        body: EmptyStateView(
          icon: Icons.lock_outline,
          message: 'Only shop owners and admins can create shops.',
          actionLabel: 'Go back',
          onAction: () => context.pop(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Shop' : 'Create Shop'),
      ),
      body: SafeArea(
        child: _isLoadingShop
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.store),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) => Validators.required(value, 'Name'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) => Validators.required(value, 'Address'),
                      ),
                      const SizedBox(height: 16),
                      CitySearchSelect(
                        value: _selectedCity,
                        hint: 'Select a city',
                        errorText: _cityError,
                        onChanged: (value) {
                          setState(() {
                            _selectedCity = value;
                            _cityError = null;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone (optional)',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 32),
                      FilledButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(widget.isEditing ? 'Save Changes' : 'Create'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _isLoading ? null : () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
