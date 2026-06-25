import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/api_error.dart';
import '../../../data/services/menu_item_api_service.dart';
import '../../../data/services/shop_api_service.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/form_select.dart';
import '../../shops/shop_providers.dart';

const _menuItemTypes = ['FOOD', 'DRINK', 'DESSERT', 'OTHER'];
const _currencies = ['USD', 'EUR', 'GBP'];

String _menuItemTypeLabel(Map<String, dynamic> item) {
  return (item['itemType'] as String? ?? item['type'] as String? ?? 'OTHER');
}

IconData _iconForType(String type) {
  switch (type.toUpperCase()) {
    case 'FOOD':
      return Icons.restaurant;
    case 'DRINK':
      return Icons.local_drink;
    case 'DESSERT':
      return Icons.cake;
    default:
      return Icons.fastfood;
  }
}

class MenuTab extends ConsumerStatefulWidget {
  const MenuTab({
    super.key,
    required this.shopId,
    this.menu,
    required this.canManage,
  });

  final String shopId;
  final Map<String, dynamic>? menu;
  final bool canManage;

  @override
  ConsumerState<MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends ConsumerState<MenuTab> {
  String _typeFilter = 'ALL';
  bool _showItemForm = false;
  bool _isSaving = false;
  String? _editingItemId;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String? _selectedType;
  String? _selectedCurrency;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _resetItemForm() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _imageUrlController.clear();
    _selectedType = null;
    _selectedCurrency = 'USD';
    _editingItemId = null;
    _showItemForm = false;
  }

  void _startEditItem(Map<String, dynamic> item) {
    setState(() {
      _showItemForm = true;
      _editingItemId = item['id'] as String?;
      _nameController.text = item['name'] as String? ?? '';
      _descriptionController.text = item['description'] as String? ?? '';
      _priceController.text = '${item['price'] ?? ''}';
      _imageUrlController.text = item['imageUrl'] as String? ?? '';
      _selectedType = _menuItemTypeLabel(item);
      _selectedCurrency = item['priceCurrency'] as String? ?? 'USD';
    });
  }

  Future<void> _createMenu() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(shopApiServiceProvider).createMenu(widget.shopId, {'label': 'Menu'});
      ref.invalidate(shopDetailProvider(widget.shopId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create menu: ${formatApiError(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveItem() async {
    final menuId = widget.menu?['id'] as String?;
    if (menuId == null) return;

    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    if (name.isEmpty || price == null || _selectedType == null || _selectedCurrency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in name, price, type, and currency')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final api = ref.read(menuItemApiServiceProvider);
      final data = {
        'name': name,
        'description': _descriptionController.text.trim(),
        'price': price,
        'priceCurrency': _selectedCurrency,
        'itemType': _selectedType,
        'imageUrl': _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        'menuId': menuId,
      };

      if (_editingItemId != null) {
        await api.update(_editingItemId!, data);
      } else {
        await api.create(data);
      }

      _resetItemForm();
      ref.invalidate(shopDetailProvider(widget.shopId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save item: ${formatApiError(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteItem(String itemId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete menu item?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(menuItemApiServiceProvider).delete(itemId);
      ref.invalidate(shopDetailProvider(widget.shopId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: ${formatApiError(e)}')),
        );
      }
    }
  }

  List<Map<String, dynamic>> _filteredItems(List<dynamic> items) {
    final typed = items.cast<Map<String, dynamic>>();
    if (_typeFilter == 'ALL') return typed;
    return typed.where((item) => _menuItemTypeLabel(item).toUpperCase() == _typeFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.menu == null) {
      return EmptyStateView(
        icon: Icons.restaurant_menu,
        message: 'No menu yet.',
        actionLabel: widget.canManage ? 'Create Menu' : null,
        onAction: widget.canManage && !_isSaving ? _createMenu : null,
      );
    }

    final allItems = (widget.menu!['items'] as List<dynamic>?) ?? [];
    final items = _filteredItems(allItems);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (widget.canManage) ...[
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => setState(() {
                    _showItemForm = !_showItemForm;
                    if (!_showItemForm) {
                      _resetItemForm();
                    } else {
                      _selectedCurrency ??= 'USD';
                    }
                  }),
                  icon: Icon(_showItemForm ? Icons.close : Icons.add),
                  label: Text(_showItemForm ? 'Cancel' : 'Add Item'),
                ),
              ),
            ],
          ),
          if (_showItemForm) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 8),
                    FormSelect<String>(
                      label: 'Currency',
                      value: _selectedCurrency,
                      items: _currencies,
                      itemLabel: (v) => v,
                      onChanged: (v) => setState(() => _selectedCurrency = v),
                    ),
                    const SizedBox(height: 8),
                    FormSelect<String>(
                      label: 'Type',
                      value: _selectedType,
                      items: _menuItemTypes,
                      itemLabel: (v) => v,
                      onChanged: (v) => setState(() => _selectedType = v),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(labelText: 'Image URL (optional)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _isSaving ? null : _saveItem,
                      child: Text(_editingItemId != null ? 'Update Item' : 'Save Item'),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
        ],
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: ['ALL', ..._menuItemTypes].map((filter) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(filter == 'ALL' ? 'All' : filter[0] + filter.substring(1).toLowerCase()),
                  selected: _typeFilter == filter,
                  onSelected: (_) => setState(() => _typeFilter = filter),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          EmptyStateView(
            icon: Icons.fastfood_outlined,
            message: allItems.isEmpty ? 'No menu items.' : 'No items match this filter.',
          )
        else
          ...items.map((item) {
            final type = _menuItemTypeLabel(item);
            final currency = item['priceCurrency'] as String? ?? 'USD';
            final symbol = currency == 'EUR' ? '€' : currency == 'GBP' ? '£' : '\$';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_iconForType(type), color: Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['name'] as String? ?? '', style: Theme.of(context).textTheme.titleSmall),
                          if (item['description'] != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              item['description'] as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (item['price'] != null)
                          Text(
                            '$symbol${item['price']}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(type, style: Theme.of(context).textTheme.labelSmall),
                        ),
                        if (widget.canManage) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                onPressed: () => _startEditItem(item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18),
                                onPressed: () => _deleteItem(item['id'] as String),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
