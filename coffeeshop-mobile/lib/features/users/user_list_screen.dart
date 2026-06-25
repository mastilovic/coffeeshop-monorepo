import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/user_permissions.dart';
import '../../core/auth/user_role.dart';
import '../../core/auth/auth_notifier.dart';
import '../../data/models/user_list_item_dto.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/empty_state_view.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/search_bar.dart';
import 'user_providers.dart';

class UserListScreen extends ConsumerWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(userListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context, ref),
          ),
        ],
      ),
      body: usersAsync.when(
        loading: () => const LoadingIndicator(message: 'Loading users...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(userListProvider),
        ),
        data: (users) {
          if (users.isEmpty) {
            return const EmptyStateView(
              icon: Icons.people,
              message: 'No users found',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userListProvider);
              await ref.read(userListProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return _UserTile(user: user);
              },
            ),
          );
        },
      ),
    );
  }

  void _showSearch(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Users'),
        content: SearchBar(
          hintText: 'Search by name or username...',
          onChanged: (String value) {
            ref.read(userSearchProvider.notifier).state = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(userSearchProvider.notifier).state = '';
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _UserTile extends ConsumerWidget {
  const _UserTile({required this.user});

  final UserListItemDto user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(userPermissionsProvider).valueOrNull;
    final isAdmin = permissions?.isAdmin ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
        title: Text(user.name),
        subtitle: Text('@${user.username}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: UserRole.fromString(user.userType).displayColor(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                UserRole.fromString(user.userType).displayName,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            if (isAdmin)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _confirmDelete(context, ref);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _colorForType(String type, BuildContext context) {
    return UserRole.fromString(type).displayColor(context);
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete User',
      message: 'Are you sure you want to delete ${user.name}?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirmed) {
      ref.read(deleteUserProvider(user.id));
    }
  }
}
