import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/user_permissions.dart';
import '../../../core/utils/api_error.dart';
import '../../../data/services/loyalty_plan_api_service.dart';
import '../../../data/services/shop_api_service.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/form_select.dart';
import '../../../shared/widgets/loyalty_badge.dart';
import '../../../shared/widgets/upgrade_prompt.dart';
import '../../shops/shop_providers.dart';

class LoyaltyTab extends ConsumerStatefulWidget {
  const LoyaltyTab({
    super.key,
    required this.shopId,
    this.loyaltyPlan,
  });

  final String shopId;
  final Map<String, dynamic>? loyaltyPlan;

  @override
  ConsumerState<LoyaltyTab> createState() => _LoyaltyTabState();
}

class _LoyaltyTabState extends ConsumerState<LoyaltyTab> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedType;
  bool _showForm = false;
  bool _isSaving = false;
  String? _editingPlanId;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _hasPlan => shopHasLoyaltyProgram(widget.loyaltyPlan);

  void _resetForm() {
    _nameController.clear();
    _descriptionController.clear();
    _selectedType = null;
    _editingPlanId = null;
    _showForm = false;
  }

  void _startCreate(List<String> availableTypes) {
    setState(() {
      _showForm = true;
      _editingPlanId = null;
      _nameController.clear();
      _descriptionController.clear();
      _selectedType = availableTypes.isNotEmpty ? availableTypes.first : null;
    });
  }

  void _startEdit(Map<String, dynamic> plan) {
    setState(() {
      _showForm = true;
      _editingPlanId = plan['id'] as String?;
      _nameController.text = plan['name'] as String? ?? '';
      _descriptionController.text = plan['description'] as String? ?? '';
      _selectedType = plan['type'] as String? ?? 'BASIC';
    });
  }

  Future<void> _savePlan(UserPermissions permissions) async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final type = _selectedType;

    if (name.isEmpty || type == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a plan name and type')),
      );
      return;
    }

    if (!permissions.canCreateLoyaltyType(type)) {
      showUpgradeSnackBar(
        context,
        message: type == 'BASIC'
            ? 'Loyalty programs require Growth or higher.'
            : 'Premium and VIP loyalty require Pro or higher.',
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final loyaltyApi = ref.read(loyaltyPlanApiServiceProvider);
      final shopApi = ref.read(shopApiServiceProvider);
      final payload = {
        'name': name,
        'description': description.isEmpty ? null : description,
        'type': type,
      };

      if (_editingPlanId != null) {
        await loyaltyApi.update(_editingPlanId!, payload);
      } else {
        final created = await loyaltyApi.create(payload);
        final planId = created['id'] as String?;
        if (planId != null) {
          await shopApi.update(widget.shopId, {'loyaltyPlanId': planId});
        }
      }

      ref.invalidate(shopDetailProvider(widget.shopId));
      _resetForm();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _editingPlanId != null ? 'Loyalty plan updated' : 'Loyalty plan enabled',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save loyalty plan: ${formatApiError(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _removePlan() async {
    final planId = widget.loyaltyPlan?['id'] as String?;
    if (planId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove loyalty program?'),
        content: const Text(
          'Customers will no longer see a loyalty badge for this shop.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(loyaltyPlanApiServiceProvider).delete(planId);
      await ref.read(shopApiServiceProvider).update(
            widget.shopId,
            {'loyaltyPlanId': null},
          );
      ref.invalidate(shopDetailProvider(widget.shopId));
      _resetForm();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loyalty program removed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove loyalty plan: ${formatApiError(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildPlanCard(BuildContext context, Map<String, dynamic> plan) {
    final type = plan['type'] as String? ?? 'BASIC';
    final name = plan['name'] as String? ?? 'Loyalty plan';
    final description = plan['description'] as String?;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(name, style: Theme.of(context).textTheme.titleMedium),
                ),
                LoyaltyBadge(planType: type),
              ],
            ),
            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _isSaving ? null : () => _startEdit(plan),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: _isSaving ? null : _removePlan,
                  icon: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  label: Text(
                    'Remove',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    UserPermissions permissions,
    List<String> availableTypes,
  ) {
    final isEditing = _editingPlanId != null;
    final typeItems = isEditing && _selectedType != null
        ? [_selectedType!]
        : availableTypes;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEditing ? 'Edit loyalty plan' : 'Enable loyalty program',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Plan name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            FormSelect<String>(
              label: 'Plan type',
              value: _selectedType,
              items: typeItems,
              itemLabel: (type) => type,
              onChanged: isEditing
                  ? (_) {}
                  : (value) => setState(() => _selectedType = value),
            ),
            if (permissions.showLoyaltyPremiumUpgrade) ...[
              const SizedBox(height: 12),
              const UpgradePromptBanner(
                message: 'Upgrade to Pro for Premium and VIP loyalty tiers.',
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: _isSaving ? null : _resetForm,
                  child: const Text('Cancel'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _isSaving || typeItems.isEmpty
                      ? null
                      : () => _savePlan(permissions),
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEditing ? 'Save changes' : 'Enable loyalty'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(userPermissionsProvider).valueOrNull;
    if (permissions == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final availableTypes = permissions.availableLoyaltyTypes;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_hasPlan && !_showForm && widget.loyaltyPlan != null)
          _buildPlanCard(context, widget.loyaltyPlan!)
        else if (!_showForm) ...[
          const EmptyStateView(
            icon: Icons.card_giftcard,
            message: 'No loyalty program configured yet.',
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: availableTypes.isEmpty || _isSaving
                ? null
                : () => _startCreate(availableTypes),
            icon: const Icon(Icons.add),
            label: const Text('Enable loyalty program'),
          ),
          if (availableTypes.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: UpgradePromptBanner(
                message: 'Loyalty programs require Growth or higher.',
              ),
            )
          else if (permissions.showLoyaltyPremiumUpgrade)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: UpgradePromptBanner(
                message: 'Upgrade to Pro for Premium and VIP loyalty tiers.',
              ),
            ),
        ],
        if (_showForm) _buildForm(context, permissions, availableTypes),
      ],
    );
  }
}
