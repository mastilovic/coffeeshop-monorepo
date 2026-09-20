import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/auth/auth_notifier.dart';
import '../../core/auth/user_role.dart';
import '../../data/models/subscription_dto.dart';
import '../../data/models/user_profile_response_dto.dart';
import '../../data/services/subscription_api_service.dart';
import 'billing_format.dart';

final billingCatalogProvider = FutureProvider<CatalogResponseDto>((ref) async {
  return ref.watch(subscriptionApiServiceProvider).getCatalog();
});

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  String? _changingTier;
  String? _errorMessage;
  String? _successMessage;

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(billingCatalogProvider);
    final subscription = ref.watch(authNotifierProvider).user?.subscription;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing & Plans'),
      ),
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load plan catalog.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (catalog) => _buildContent(context, catalog, subscription),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    CatalogResponseDto catalog,
    SubscriptionSummaryDto? subscription,
  ) {
    final tiers = [...catalog.tiers]
      ..retainWhere((tier) => tier.isActive)
      ..sort((a, b) => tierSortIndex(a.tier).compareTo(tierSortIndex(b.tier)));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_errorMessage != null) ...[
          _MessageBanner(
            message: _errorMessage!,
            isError: true,
          ),
          const SizedBox(height: 12),
        ],
        if (_successMessage != null) ...[
          _MessageBanner(
            message: _successMessage!,
            isError: false,
          ),
          const SizedBox(height: 12),
        ],
        Text(
          'Current Plan',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        if (subscription != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              planLabel(
                                planMode: subscription.planMode,
                                planTier: subscription.planTier,
                                tiers: tiers,
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            _StatusChip(status: subscription.status),
                          ],
                        ),
                      ),
                      Text(
                        '${formatCents(subscription.monthlyAmountCents)}/mo',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${subscription.shopsUsed} / ${_formatShopLimit(subscription)} shops',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (subscription.periodEnd != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Renews ${DateFormat.yMMMd().format(DateTime.parse(subscription.periodEnd!))}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          )
        else
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No subscription information available.'),
            ),
          ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                'Choose a Plan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            OutlinedButton(
              onPressed: () => context.push('/profile/billing/custom'),
              child: const Text('Build Custom'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Pricing preview only — no payment required.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 12),
        ...tiers.map(
          (tier) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TierCard(
              tier: tier,
              isCurrent: _isCurrentTier(subscription, tier.tier),
              isChanging: _changingTier == tier.tier,
              onSelect: () => _selectTier(tier.tier),
            ),
          ),
        ),
      ],
    );
  }

  bool _isCurrentTier(SubscriptionSummaryDto? subscription, String tier) {
    return subscription?.planMode == 'PRESET' && subscription?.planTier == tier;
  }

  String _formatShopLimit(SubscriptionSummaryDto subscription) {
    return subscription.shopsIncluded > 0
        ? subscription.shopsIncluded.toString()
        : 'Unlimited';
  }

  Future<void> _selectTier(String tier) async {
    final subscription = ref.read(authNotifierProvider).user?.subscription;
    if (_isCurrentTier(subscription, tier) || _changingTier != null) return;

    setState(() {
      _changingTier = tier;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await ref.read(subscriptionApiServiceProvider).changePlan(
            UpdatePlanRequestDto(
              planMode: 'PRESET',
              planTier: tier,
              billingInterval: 'monthly',
            ),
          );
      await ref.read(authNotifierProvider.notifier).refreshProfile();
      if (mounted) {
        setState(() {
          _changingTier = null;
          _successMessage = 'Plan updated successfully.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _changingTier = null;
          _errorMessage = 'Failed to change plan.';
        });
      }
    }
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.tier,
    required this.isCurrent,
    required this.isChanging,
    required this.onSelect,
  });

  final CatalogTierDto tier;
  final bool isCurrent;
  final bool isChanging;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrent
            ? BorderSide(color: Theme.of(context).colorScheme.primary)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tier.displayName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${formatCents(tier.basePriceMonthlyCents)}/month',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${tier.includedFeatures.length} features included',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: isCurrent || isChanging ? null : onSelect,
              child: Text(
                isChanging
                    ? 'Switching...'
                    : isCurrent
                        ? 'Current Plan'
                        : 'Select ${tier.displayName}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({
    required this.message,
    required this.isError,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError
            ? Theme.of(context).colorScheme.errorContainer
            : Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message),
    );
  }
}

bool showBillingForRole(UserRole? role) {
  return role == UserRole.shop_owner || role == UserRole.admin;
}
