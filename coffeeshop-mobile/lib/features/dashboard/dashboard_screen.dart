import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_notifier.dart';
import '../../core/auth/auth_service.dart';
import '../../core/auth/user_permissions.dart';
import '../../core/network/api_exception.dart';
import '../../core/utils/reservation_event_utils.dart';
import '../../data/models/dashboard_activity_response.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'dashboard_provider.dart';
import 'widgets/activity_feed.dart';
import 'widgets/analytics_section.dart';
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
        forbiddenException: (message) => message,
        validationException: (message, _) => message,
        unknownException: (message) => message,
      );
    }

    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final isShopOwner =
        ref.watch(userPermissionsProvider).valueOrNull?.isShopOwner ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(isShopOwner ? 'Dashboard' : 'Home'),
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
              if (isShopOwner)
                StatsBar(
                  shopCount: data.aggregate.shopCount,
                  reviewCount: data.aggregate.reviewCount,
                  averageRating: data.aggregate.averageRating,
                  eventCount: data.aggregate.eventCount,
                  memberCount: data.aggregate.memberCount,
                )
              else
                const _CustomerQuickActions(),
              const AnalyticsSection(),
              if (data.notifications.isNotEmpty) ...[
                const SizedBox(height: 8),
                _NotificationsBanner(
                  notifications: isShopOwner
                      ? data.notifications
                      : data.notifications.where((n) {
                          final type = n.type;
                          return type != 'pending_requests' &&
                              type != 'new_reviews';
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

class _CustomerQuickActions extends StatelessWidget {
  const _CustomerQuickActions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionChip(
              icon: Icons.store_outlined,
              label: 'Browse shops',
              onTap: () => context.go('/shops'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _QuickActionChip(
              icon: Icons.event_outlined,
              label: 'Events',
              onTap: () => context.go('/events'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _QuickActionChip(
              icon: Icons.event_seat_outlined,
              label: 'Reserve',
              onTap: () => openReservationRequest(context, openForm: true),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationsBanner extends StatelessWidget {
  const _NotificationsBanner({required this.notifications});

  final List<DashboardNotification> notifications;

  void _onNotificationTap(
    BuildContext context,
    DashboardNotification notification,
  ) {
    final link = notification.link;
    if (link != null && link.isNotEmpty) {
      context.go(link);
      return;
    }

    switch (notification.type) {
      case 'pending_requests':
        context.go('/reservations');
      case 'new_reviews':
        context.go('/shops');
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) return const SizedBox.shrink();

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
            ...notifications.map(
              (n) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _onNotificationTap(context, n),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          _iconForType(n.type),
                          size: 16,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            n.message,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
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
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'pending_requests':
        return Icons.event_seat;
      case 'new_reviews':
        return Icons.rate_review;
      default:
        return Icons.notifications;
    }
  }
}
