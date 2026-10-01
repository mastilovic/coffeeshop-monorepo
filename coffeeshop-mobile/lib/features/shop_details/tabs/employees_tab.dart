import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/user_permissions.dart';
import '../../../core/utils/api_error.dart';
import '../../../data/models/user_list_item_dto.dart';
import '../../../data/services/shop_employee_api_service.dart';
import '../../../data/services/user_api_service.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/form_select.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/upgrade_prompt.dart';

final shopEmployeesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      shopId,
    ) async {
      final api = ref.watch(shopEmployeeApiServiceProvider);
      final data = await api.getEmployees(shopId);
      return data.cast<Map<String, dynamic>>();
    });

final assignableUsersProvider = FutureProvider<List<UserListItemDto>>((
  ref,
) async {
  final data = await ref.watch(userApiServiceProvider).getAll(size: 100);
  if (data is Map<String, dynamic>) {
    return (data['content'] as List<dynamic>?)
            ?.map((e) => UserListItemDto.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }
  return [];
});

class EmployeesTab extends ConsumerStatefulWidget {
  const EmployeesTab({super.key, required this.shopId});

  final String shopId;

  @override
  ConsumerState<EmployeesTab> createState() => _EmployeesTabState();
}

class _EmployeesTabState extends ConsumerState<EmployeesTab> {
  bool _showAddForm = false;
  String? _selectedUserId;
  bool _isAssigning = false;

  String? _employeeUserId(Map<String, dynamic> employee) {
    return employee['userId'] as String? ??
        employee['user_id'] as String? ??
        (employee['user'] as Map<String, dynamic>?)?['id'] as String?;
  }

  bool _isOwnerRow(Map<String, dynamic> employee) {
    return employee['isOwner'] as bool? ??
        employee['is_owner'] as bool? ??
        false;
  }

  Future<void> _assignEmployee() async {
    if (_selectedUserId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a user')));
      return;
    }

    setState(() => _isAssigning = true);
    try {
      await ref.read(shopEmployeeApiServiceProvider).assign({
        'shopId': widget.shopId,
        'userId': _selectedUserId,
      });
      ref.invalidate(shopEmployeesProvider(widget.shopId));
      if (mounted) {
        setState(() {
          _showAddForm = false;
          _selectedUserId = null;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Employee assigned')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to assign employee: ${formatApiError(e)}'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAssigning = false);
    }
  }

  Future<void> _removeEmployee(Map<String, dynamic> employee) async {
    final userId = _employeeUserId(employee);
    if (userId == null) return;

    final name = employee['name'] as String? ?? 'this employee';
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Remove employee',
      message: 'Remove $name from this shop?',
      confirmLabel: 'Remove',
      isDestructive: true,
    );
    if (!confirmed) return;

    try {
      await ref.read(shopEmployeeApiServiceProvider).remove({
        'shopId': widget.shopId,
        'userId': userId,
      });
      ref.invalidate(shopEmployeesProvider(widget.shopId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove employee: ${formatApiError(e)}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(shopEmployeesProvider(widget.shopId));
    final usersAsync = ref.watch(assignableUsersProvider);
    final permissions = ref.watch(userPermissionsProvider).valueOrNull;
    final canAssign = permissions?.canAssignEmployees ?? false;
    final showUpgrade = permissions?.showEmployeeAssignUpgrade ?? false;

    return asyncData.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(shopEmployeesProvider(widget.shopId)),
      ),
      data: (employees) {
        final assignedIds = employees
            .map(_employeeUserId)
            .whereType<String>()
            .toSet();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (showUpgrade) ...[
              const UpgradePromptBanner(
                message: 'Employee seats require Growth or higher.',
              ),
              const SizedBox(height: 12),
            ],
            FilledButton.tonalIcon(
              onPressed: canAssign
                  ? () => setState(() => _showAddForm = !_showAddForm)
                  : null,
              icon: Icon(_showAddForm ? Icons.close : Icons.person_add),
              label: Text(_showAddForm ? 'Cancel' : 'Add Employee'),
            ),
            if (_showAddForm && canAssign) ...[
              const SizedBox(height: 12),
              usersAsync.when(
                loading: () => const LoadingIndicator(),
                error: (e, _) => ErrorView(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(assignableUsersProvider),
                ),
                data: (users) {
                  final available = users
                      .where((u) => !assignedIds.contains(u.id))
                      .toList();
                  if (available.isEmpty) {
                    return const Text('No users available to assign.');
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FormSelect<String>(
                        label: 'User',
                        value: _selectedUserId,
                        items: available.map((u) => u.id).toList(),
                        itemLabel: (id) {
                          final user = available.firstWhere((u) => u.id == id);
                          return '${user.name} (@${user.username})';
                        },
                        onChanged: (value) =>
                            setState(() => _selectedUserId = value),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _isAssigning ? null : _assignEmployee,
                        child: _isAssigning
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Assign'),
                      ),
                    ],
                  );
                },
              ),
            ],
            const SizedBox(height: 12),
            if (employees.isEmpty)
              const Center(child: Text('No employees assigned'))
            else
              ...employees.map((emp) {
                final name = emp['name'] as String? ?? 'Unknown';
                final username = emp['username'] as String? ?? '';
                final roleName =
                    emp['role_name'] as String? ??
                    emp['roleName'] as String? ??
                    'Employee';
                final isOwner = _isOwnerRow(emp);

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                      ),
                    ),
                    title: Text(name),
                    subtitle: username.isEmpty ? null : Text('@$username'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isOwner ? 'Owner' : roleName,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                        if (!isOwner)
                          IconButton(
                            icon: const Icon(Icons.person_remove_outlined),
                            tooltip: 'Remove employee',
                            onPressed: () => _removeEmployee(emp),
                          ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}
