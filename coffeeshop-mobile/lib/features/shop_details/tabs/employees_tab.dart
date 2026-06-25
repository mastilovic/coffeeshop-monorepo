import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/services/shop_employee_api_service.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_indicator.dart';

final shopEmployeesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, shopId) async {
  final api = ref.watch(shopEmployeeApiServiceProvider);
  final data = await api.getEmployees(shopId);
  return data.cast<Map<String, dynamic>>();
});

class EmployeesTab extends ConsumerWidget {
  const EmployeesTab({super.key, required this.shopId});

  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(shopEmployeesProvider(shopId));

    return asyncData.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(shopEmployeesProvider(shopId)),
      ),
      data: (employees) {
        if (employees.isEmpty) {
          return const Center(child: Text('No employees assigned'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: employees.length,
          itemBuilder: (context, index) {
            final emp = employees[index];
            final name = emp['name'] as String? ?? 'Unknown';
            final email = emp['email'] as String? ?? '';
            final roleName = emp['role_name'] as String? ?? emp['roleName'] as String? ?? 'Employee';

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?')),
                title: Text(name),
                subtitle: Text(email),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(roleName, style: Theme.of(context).textTheme.labelSmall),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
