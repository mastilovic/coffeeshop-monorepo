import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/user_permissions.dart';
import '../../../data/models/dashboard_analytics_response.dart';
import '../../../data/services/dashboard_api_service.dart';
import '../../../shared/widgets/loading_indicator.dart';

const upgradeToProLabel = 'Upgrade to Pro';

final dashboardAnalyticsProvider =
    FutureProvider<DashboardAnalyticsResponse>((ref) async {
  final apiService = ref.watch(dashboardApiServiceProvider);
  final data = await apiService.getAnalytics();
  return DashboardAnalyticsResponse.fromJson(data);
});

class AnalyticsSection extends ConsumerWidget {
  const AnalyticsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(userPermissionsProvider).valueOrNull;
    if (permissions == null || !permissions.isShopOwner) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pro Analytics',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          if (!permissions.canUseFeature(SubscriptionFeature.analytics))
            const _AnalyticsUpgradeCard()
          else
            const _AnalyticsContent(),
        ],
      ),
    );
  }
}

class _AnalyticsUpgradeCard extends StatelessWidget {
  const _AnalyticsUpgradeCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('analytics-upgrade'),
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Unlock full shop analytics with reservations, reviews, community, and operations metrics.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/profile/billing'),
              child: const Text(upgradeToProLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsContent extends ConsumerWidget {
  const _AnalyticsContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(dashboardAnalyticsProvider);

    return analyticsAsync.when(
      loading: () => const LoadingIndicator(message: 'Loading analytics...'),
      error: (_, __) => Text(
        'Unable to load analytics right now.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
      ),
      data: (data) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AggregateMetrics(aggregate: data.aggregate),
          if (data.shops.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ShopBreakdown(shops: data.shops),
          ],
        ],
      ),
    );
  }
}

class _AggregateMetrics extends StatelessWidget {
  const _AggregateMetrics({required this.aggregate});

  final DashboardAnalyticsAggregate aggregate;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _MetricTile(label: 'Reservations', value: aggregate.reservationCount),
      _MetricTile(
        label: 'Pending requests',
        value: aggregate.pendingReservationRequestCount,
      ),
      _MetricTile(label: 'Events', value: aggregate.eventCount),
      _MetricTile(
        label: 'Reviews',
        value: aggregate.reviewCount,
        subtitle: aggregate.averageRating?.toStringAsFixed(1),
      ),
      _MetricTile(label: 'Posts', value: aggregate.communityPostCount),
      _MetricTile(label: 'Members', value: aggregate.memberCount),
      _MetricTile(label: 'Employees', value: aggregate.employeeCount),
      _MetricTile(label: 'Tables', value: aggregate.tableCount),
      _MetricTile(label: 'Menus', value: aggregate.menuCount),
    ];

    return Wrap(
      key: const Key('analytics-aggregate'),
      spacing: 8,
      runSpacing: 8,
      children: metrics,
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    this.subtitle,
  });

  final String label;
  final int value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            subtitle != null ? '$label ($subtitle)' : label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _ShopBreakdown extends StatelessWidget {
  const _ShopBreakdown({required this.shops});

  final List<DashboardShopAnalytics> shops;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('analytics-shops'),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Shop')),
            DataColumn(label: Text('Res.')),
            DataColumn(label: Text('Pending')),
            DataColumn(label: Text('Events')),
            DataColumn(label: Text('Reviews')),
            DataColumn(label: Text('Posts')),
            DataColumn(label: Text('Members')),
          ],
          rows: shops
              .map(
                (shop) => DataRow(
                  cells: [
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(shop.shopName),
                          if (shop.city != null && shop.city!.isNotEmpty)
                            Text(
                              shop.city!,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                        ],
                      ),
                    ),
                    DataCell(Text('${shop.reservationCount}')),
                    DataCell(Text('${shop.pendingReservationRequestCount}')),
                    DataCell(Text('${shop.eventCount}')),
                    DataCell(
                      Text(
                        shop.averageRating != null
                            ? '${shop.reviewCount} (${shop.averageRating!.toStringAsFixed(1)})'
                            : '${shop.reviewCount}',
                      ),
                    ),
                    DataCell(Text('${shop.communityPostCount}')),
                    DataCell(Text('${shop.memberCount}')),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
