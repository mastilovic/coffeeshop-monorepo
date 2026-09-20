import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_notifier.dart';
import '../../core/auth/auth_service.dart';
import '../../core/auth/user_role.dart';
import '../../core/utils/extensions.dart';
import '../../data/services/reservation_api_service.dart';
import '../../data/services/review_api_service.dart';
import '../../data/services/user_api_service.dart';
import '../billing/billing_screen.dart';

final _userReservationsCountProvider = FutureProvider<int>((ref) async {
  final userId = ref.watch(authNotifierProvider).user?.id;
  if (userId == null) return 0;

  final api = ref.watch(reservationApiServiceProvider);
  final data = await api.getAll();
  return data.where((entry) {
    final user = entry['user'] as Map<String, dynamic>?;
    final id = user?['id'] as String? ?? entry['userId'] as String?;
    return id == userId;
  }).length;
});

final _userReviewsCountProvider = FutureProvider<int>((ref) async {
  final userId = ref.watch(authNotifierProvider).user?.id;
  if (userId == null) return 0;

  final api = ref.watch(reviewApiServiceProvider);
  final data = await api.getAll();
  return data.where((entry) {
    final json = entry as Map<String, dynamic>;
    final user = json['user'] as Map<String, dynamic>?;
    final id = user?['id'] as String? ?? json['userId'] as String?;
    return id == userId;
  }).length;
});

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _populateControllers() {
    final user = ref.read(authNotifierProvider).user;
    if (user != null) {
      _nameController.text = user.name;
      _usernameController.text = user.username;
      _emailController.text = user.email;
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final user = ref.read(authNotifierProvider).user;
      if (user == null) return;

      await ref.read(userApiServiceProvider).update(user.id, {
        'name': _nameController.text.trim(),
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
      });

      await ref.read(authNotifierProvider.notifier).refreshProfile();

      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (authState.user != null)
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                  if (_isEditing) _populateControllers();
                });
              },
            ),
        ],
      ),
      body: authState.user == null
          ? const Center(child: Text('Profile - Coming Soon'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      authState.user!.name.initials,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isEditing) ...[
                    _buildEditForm(context),
                  ] else ...[
                    _buildViewMode(context, authState),
                  ],
                  const SizedBox(height: 32),
                  if (showBillingForRole(authState.role)) ...[
                    OutlinedButton.icon(
                      onPressed: () => context.push('/profile/billing'),
                      icon: const Icon(Icons.credit_card_outlined),
                      label: const Text('Billing & Plans'),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (authState.role == UserRole.admin) ...[
                    OutlinedButton.icon(
                      onPressed: () => context.push('/users'),
                      icon: const Icon(Icons.people_outline),
                      label: const Text('Browse Users'),
                    ),
                    const SizedBox(height: 16),
                  ],
                  OutlinedButton.icon(
                    onPressed: () async {
                      await ref.read(authNotifierProvider.notifier).logout();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEditForm(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: 'Username',
            prefixIcon: Icon(Icons.alternate_email),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save Changes'),
          ),
        ),
      ],
    );
  }

  Widget _buildViewMode(BuildContext context, AuthState authState) {
    final user = authState.user!;
    final favourites = user.favouriteShops.length;
    final reservationsAsync = ref.watch(_userReservationsCountProvider);
    final reviewsAsync = ref.watch(_userReviewsCountProvider);

    return Column(
      children: [
        Text(
          user.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '@${user.username}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: UserRole.fromString(user.userType).displayColor(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            UserRole.fromString(user.userType).displayName,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          ),
        ),
        const SizedBox(height: 32),
        _StatsRow(
          favourites: favourites.toString(),
          reservationsAsync: reservationsAsync,
          reviewsAsync: reviewsAsync,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Details',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                _DetailRow(label: 'User ID', value: user.id),
                _DetailRow(label: 'Account Type', value: UserRole.fromString(user.userType).displayName),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.favourites,
    required this.reservationsAsync,
    required this.reviewsAsync,
  });

  final String favourites;
  final AsyncValue<int> reservationsAsync;
  final AsyncValue<int> reviewsAsync;

  @override
  Widget build(BuildContext context) {
    final reservations = reservationsAsync.valueOrNull?.toString() ?? '--';
    final reviews = reviewsAsync.valueOrNull?.toString() ?? '--';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(
          icon: Icons.favorite,
          label: 'Favourites',
          value: favourites,
          color: Colors.red,
          onTap: () => context.go('/shops'),
        ),
        _StatItem(
          icon: Icons.calendar_month,
          label: 'Reservations',
          value: reservations,
          color: Theme.of(context).colorScheme.primary,
          onTap: () => context.go('/reservations'),
        ),
        _StatItem(
          icon: Icons.star,
          label: 'Reviews',
          value: reviews,
          color: Colors.amber,
          onTap: () => context.go('/shops'),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
