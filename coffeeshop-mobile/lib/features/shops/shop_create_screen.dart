import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/user_permissions.dart';
import '../../core/auth/auth_notifier.dart';
import '../../core/network/api_exception.dart';
import '../../core/utils/validators.dart';
import '../../data/models/shop_response_dto.dart';
import '../../data/services/shop_api_service.dart';
import '../../shared/widgets/empty_state_view.dart';
import '../../shared/widgets/form_select.dart';
import 'shop_providers.dart';

class ShopCreateScreen extends ConsumerStatefulWidget {
  const ShopCreateScreen({super.key});

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

  bool get _canCreateShop {
    final permissions = ref.watch(userPermissionsProvider).valueOrNull;
    return permissions?.canCreateShop ?? false;
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
        validationException: (message, _) => message,
        unknownException: (message) => message,
      );
    }

    return error.toString().replaceFirst('Exception: ', '');
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCity == null) {
      setState(() => _cityError = 'City is required');
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

    setState(() {
      _isLoading = true;
      _cityError = null;
    });

    try {
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

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Shop "${created['name']}" created')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create shop: ${_formatError(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_canCreateShop) {
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

    final citiesAsync = ref.watch(citiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Shop'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                citiesAsync.when(
                  loading: () => const InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'City',
                      prefixIcon: Icon(Icons.location_city_outlined),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Loading cities...'),
                      ],
                    ),
                  ),
                  error: (error, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Failed to load cities: $error',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => ref.invalidate(citiesProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                  data: (cities) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormSelect<String>(
                        label: 'City',
                        hint: 'Select a city',
                        value: _selectedCity,
                        items: cities,
                        itemLabel: (city) => city,
                        prefixIcon: Icons.location_city_outlined,
                        onChanged: (value) {
                          setState(() {
                            _selectedCity = value;
                            _cityError = null;
                          });
                        },
                      ),
                      if (_cityError != null) ...[
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            _cityError!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
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
                  onPressed: _isLoading ? null : _handleCreate,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create'),
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
