import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/user_permissions.dart';
import '../../../core/utils/api_error.dart';
import '../../../data/services/table_api_service.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/upgrade_prompt.dart';
import '../../shops/shop_providers.dart';

class TablesTab extends ConsumerStatefulWidget {
  const TablesTab({
    super.key,
    required this.shopId,
    required this.tables,
    required this.canManage,
  });

  final String shopId;
  final List<Map<String, dynamic>>? tables;
  final bool canManage;

  @override
  ConsumerState<TablesTab> createState() => _TablesTabState();
}

class _TablesTabState extends ConsumerState<TablesTab> {
  bool _showForm = false;
  bool _isSaving = false;
  String? _editingTableId;

  final _numberController = TextEditingController();
  final _capacityController = TextEditingController();

  @override
  void dispose() {
    _numberController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _numberController.clear();
    _capacityController.clear();
    _editingTableId = null;
    _showForm = false;
  }

  void _startEdit(Map<String, dynamic> table) {
    setState(() {
      _showForm = true;
      _editingTableId = table['id'] as String?;
      _numberController.text = '${table['number'] ?? ''}';
      _capacityController.text = '${table['capacity'] ?? ''}';
    });
  }

  Future<void> _saveTable() async {
    final number = int.tryParse(_numberController.text.trim());
    final capacity = int.tryParse(_capacityController.text.trim());
    if (number == null || capacity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid number and capacity')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final api = ref.read(tableApiServiceProvider);
      if (_editingTableId != null) {
        await api.update(_editingTableId!, {'number': number, 'capacity': capacity});
      } else {
        await api.create({'number': number, 'capacity': capacity, 'shopId': widget.shopId});
      }
      _resetForm();
      ref.invalidate(shopDetailProvider(widget.shopId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save table: ${formatApiError(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteTable(String tableId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete table?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(tableApiServiceProvider).delete(tableId);
      ref.invalidate(shopDetailProvider(widget.shopId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: ${formatApiError(e)}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tables = widget.tables ?? [];
    final permissions = ref.watch(userPermissionsProvider).valueOrNull;
    final canAdd = widget.canManage && (permissions?.canAddTable ?? true);
    final showUpgrade = widget.canManage && (permissions?.showTablesUpgrade ?? false);
    final quotaLabel = permissions?.tablesQuotaLabel;

    return Column(
      children: [
        if (widget.canManage)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (quotaLabel != null) UsageQuotaLabel(label: quotaLabel),
                if (showUpgrade) ...[
                  const UpgradePromptBanner(
                    message: 'Table limit reached. Upgrade for more tables.',
                  ),
                  const SizedBox(height: 8),
                ],
                FilledButton.tonalIcon(
                  onPressed: canAdd
                      ? () => setState(() {
                            _showForm = !_showForm;
                            if (!_showForm) _resetForm();
                          })
                      : null,
                  icon: Icon(_showForm ? Icons.close : Icons.add),
                  label: Text(_showForm ? 'Cancel' : 'Add Table'),
                ),
              ],
            ),
          ),
        if (_showForm && widget.canManage && canAdd)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _numberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Table number', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _capacityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Capacity', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _isSaving ? null : _saveTable,
                      child: Text(_editingTableId != null ? 'Update Table' : 'Save Table'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Expanded(
          child: tables.isEmpty
              ? EmptyStateView(
                  icon: Icons.table_bar,
                  message: 'No tables.',
                  actionLabel: canAdd && !_showForm ? 'Add Table' : null,
                  onAction: canAdd && !_showForm ? () => setState(() => _showForm = true) : null,
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: tables.length,
                  itemBuilder: (context, index) {
                    final table = tables[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.table_bar, size: 32, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(height: 8),
                            Text(
                              'Table ${table['number'] ?? '?'}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text('Capacity: ${table['capacity'] ?? '?'}', style: Theme.of(context).textTheme.bodySmall),
                            if (widget.canManage) ...[
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 18),
                                    onPressed: () => _startEdit(table),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18),
                                    onPressed: () => _deleteTable(table['id'] as String),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
