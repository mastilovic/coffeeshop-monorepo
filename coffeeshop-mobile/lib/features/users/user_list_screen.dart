import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_notifier.dart';
import '../../core/auth/user_permissions.dart';
import '../../core/auth/user_role.dart';
import '../../core/utils/api_error.dart';
import '../../data/models/user_list_item_dto.dart';
import '../../data/services/user_api_service.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/empty_state_view.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/form_select.dart';
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
    final currentUserId = ref.watch(authNotifierProvider).user?.id;
    final canEdit = isAdmin || user.id == currentUserId;

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
            if (canEdit || isAdmin)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditDialog(context, ref, isAdmin);
                  } else if (value == 'delete') {
                    _confirmDelete(context, ref);
                  }
                },
                itemBuilder: (context) => [
                  if (canEdit)
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  if (isAdmin)
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref, bool isAdmin) async {
    Map<String, dynamic> userData;
    try {
      userData = await ref.read(userApiServiceProvider).getById(user.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user: ${formatApiError(e)}')),
        );
      }
      return;
    }

    final nameController = TextEditingController(text: user.name);
    final usernameController = TextEditingController(text: user.username);
    final emailController = TextEditingController(text: userData['email'] as String? ?? '');
    var selectedUserType = user.userType;

    if (!context.mounted) {
      nameController.dispose();
      usernameController.dispose();
      emailController.dispose();
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Edit ${user.name}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    if (isAdmin) ...[
                      const SizedBox(height: 12),
                      FormSelect<String>(
                        label: 'Account type',
                        value: selectedUserType,
                        items: UserRole.values.map((role) => role.name).toList(),
                        itemLabel: (value) => UserRole.fromString(value).displayName,
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => selectedUserType = value);
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    try {
                      final payload = <String, dynamic>{
                        'name': nameController.text.trim(),
                        'username': usernameController.text.trim(),
                        'email': emailController.text.trim(),
                      };
                      if (isAdmin) {
                        payload['userType'] = selectedUserType;
                      }
                      await ref.read(userApiServiceProvider).update(user.id, payload);
                      ref.invalidate(userListProvider);
                      if (user.id == ref.read(authNotifierProvider).user?.id) {
                        await ref.read(authNotifierProvider.notifier).refreshProfile();
                      }
                      if (dialogContext.mounted) Navigator.pop(dialogContext);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User updated')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to update user: ${formatApiError(e)}')),
                        );
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
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
      try {
        await ref.read(userApiServiceProvider).delete(user.id);
        ref.invalidate(userListProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User deleted')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete user: ${formatApiError(e)}')),
          );
        }
      }
    }
  }
}
