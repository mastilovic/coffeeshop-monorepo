import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_notifier.dart';
import '../../core/auth/user_permissions.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/dashboard_activity_response.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'dashboard_provider.dart';
import 'widgets/activity_feed.dart';
import 'widgets/personal_summary_card.dart';
import 'widgets/stats_bar.dart';
import 'widgets/top_shops_carousel.dart';
import 'widgets/upcoming_events_list.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _formatError(Object error) {
    if (error is ApiException) {
      return error.when(
        networkException: (message, _) => message,
        serverException: (message, _) => message,
        unauthorizedException: (message) => message,
        validationException: (message, _) => message,
        unknownException: (message) => message,
      );
    }

    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: switch (auth.status) {
        AuthStatus.unknown ||
        AuthStatus.unauthenticated =>
          const LoadingIndicator(message: 'Loading dashboard...'),
        AuthStatus.authenticated => _DashboardBody(formatError: _formatError),
      },
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.formatError});

  final String Function(Object error) formatError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return dashboardAsync.when(
      loading: () => const LoadingIndicator(message: 'Loading dashboard...'),
      error: (error, stackTrace) => ErrorView(
        message: formatError(error),
        onRetry: () => ref.invalidate(dashboardProvider),
      ),
      data: (data) {
        final permissions = ref.watch(userPermissionsProvider).valueOrNull;
        final isShopOwner = permissions?.isShopOwner ?? false;

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardProvider);
            await ref.read(dashboardProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              StatsBar(
                shopCount: data.aggregate.shopCount,
                reviewCount: data.aggregate.reviewCount,
                averageRating: data.aggregate.averageRating,
                eventCount: data.aggregate.eventCount,
                memberCount: data.aggregate.memberCount,
              ),
              if (data.notifications.isNotEmpty) ...[
                const SizedBox(height: 8),
                _NotificationsBanner(
                  notifications: isShopOwner
                      ? data.notifications
                      : data.notifications.where((n) {
                          final type = n.type;
                          return type != 'reservation_request' && type != 'review';
                        }).toList(),
                ),
              ],
              const SizedBox(height: 12),
              TopShopsCarousel(shops: data.topShops),
              const SizedBox(height: 12),
              UpcomingEventsList(events: data.upcomingEvents),
              if (data.personalSummary != null) ...[
                const SizedBox(height: 12),
                PersonalSummaryCard(summary: data.personalSummary!),
              ],
              if (data.activities.isNotEmpty) ...[
                const SizedBox(height: 12),
                ActivityFeed(activities: data.activities),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _NotificationsBanner extends StatelessWidget {
  const _NotificationsBanner({required this.notifications});

  final List<DashboardNotification> notifications;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications,
                  size: 18,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...notifications.map((n) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        _iconForType(n.type),
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          n.message,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                        ),
                      ),
                      if (n.count > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            n.count.toString(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                          ),
                        ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'reservation_request':
        return Icons.event_seat;
      case 'review':
        return Icons.rate_review;
      default:
        return Icons.notifications;
    }
  }
}
