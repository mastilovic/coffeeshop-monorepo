import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/user_permissions.dart';
import '../../shared/widgets/empty_state_view.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/event_list_card.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/pagination_controls.dart';
import '../../shared/widgets/search_bar.dart';
import '../../shared/widgets/upgrade_prompt.dart';
import 'event_providers.dart';

class EventListScreen extends ConsumerWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventListProvider);
    final filter = ref.watch(eventFilterProvider);
    final permissions = ref.watch(userPermissionsProvider).valueOrNull;
    final canCreate = permissions?.canCreateEventWithSubscription ?? false;
    final showUpgrade = permissions?.showEventCreateUpgrade ?? false;
    final eventsQuota = permissions?.eventsQuotaLabel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          if (permissions?.canCreateEvent ?? false)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: canCreate ? () => context.push('/events/new') : null,
            ),
        ],
      ),
      body: Column(
        children: [
          if (showUpgrade)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: UpgradePromptBanner(
                message: 'Create events with a Growth plan or higher.',
              ),
            ),
          if (eventsQuota != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: UsageQuotaLabel(label: eventsQuota),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SearchBar(
              hintText: 'Search events...',
              onChanged: (String value) {
                final current = ref.read(eventFilterProvider);
                ref.read(eventFilterProvider.notifier).state =
                    current.copyWith(query: value, page: 0);
              },
            ),
          ),
          _FilterPills(),
          Expanded(
            child: eventsAsync.when(
              loading: () => const LoadingIndicator(message: 'Loading events...'),
              error: (error, _) => ErrorView(
                message: error.toString(),
                onRetry: () => ref.invalidate(eventListProvider),
              ),
              data: (result) {
                if (result.events.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.event,
                    message: 'No events found',
                    actionLabel: 'Browse shops',
                    onAction: () => context.go('/shops'),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(eventListProvider);
                          await ref.read(eventListProvider.future);
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: result.events.length,
                          itemBuilder: (context, index) {
                            final event = result.events[index];
                            return EventListCard(
                              eventId: event.eventId,
                              eventName: event.eventName,
                              eventDate: event.eventDate,
                              shopId: event.shopId,
                              shopName: event.shopName,
                              shopCity: event.shopCity,
                            );
                          },
                        ),
                      ),
                    ),
                    PaginationControls(
                      currentPage: filter.page,
                      totalPages: result.totalPages,
                      onPageChanged: (page) {
                        final current = ref.read(eventFilterProvider);
                        ref.read(eventFilterProvider.notifier).state =
                            current.copyWith(page: page);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPills extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(eventFilterProvider);

    const filters = [
      (EventTimeFilter.all, 'All'),
      (EventTimeFilter.today, 'Today'),
      (EventTimeFilter.thisWeek, 'This Week'),
      (EventTimeFilter.thisMonth, 'This Month'),
    ];

    final currentIndex = filters.indexWhere((f) => f.$1 == filter.filter);

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == currentIndex;
          return ChoiceChip(
            label: Text(filters[index].$2),
            selected: isSelected,
            onSelected: (_) {
              final current = ref.read(eventFilterProvider);
              ref.read(eventFilterProvider.notifier).state =
                  current.copyWith(filter: filters[index].$1, page: 0);
            },
          );
        },
      ),
    );
  }
}
