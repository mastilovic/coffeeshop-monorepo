import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_notifier.dart';
import '../../core/auth/user_permissions.dart';
import '../../core/utils/reservation_event_utils.dart';
import '../../data/models/event_response_dto.dart';
import '../../shared/widgets/empty_state_view.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/search_bar.dart';
import '../reservations/reservation_providers.dart';
import 'event_providers.dart';

class EventListScreen extends ConsumerWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventListProvider);
    final permissions = ref.watch(userPermissionsProvider).valueOrNull;
    final canCreate = permissions?.canCreateEvent ?? false;
    final userId = ref.watch(authNotifierProvider).user?.id;
    final requests = ref.watch(myReservationRequestsProvider).valueOrNull ?? [];
    final reservations = ref.watch(myReservationsProvider).valueOrNull ?? [];
    final blocked = userId == null
        ? <String>{}
        : eventIdsBlockedForUser(
            requests: requests,
            reservations: reservations,
            userId: userId,
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          if (canCreate)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push('/events/new'),
            ),
        ],
      ),
      body: Column(
        children: [
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
              data: (events) {
                if (events.isEmpty) {
                  return const EmptyStateView(
                    icon: Icons.event,
                    message: 'No events found',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(eventListProvider);
                    await ref.read(eventListProvider.future);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: _EventListTile(
                          event: event,
                          blockedEventIds: blocked,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EventListTile extends ConsumerWidget {
  const _EventListTile({
    required this.event,
    required this.blockedEventIds,
  });

  final EventResponseDto event;
  final Set<String> blockedEventIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopId = event.shopId;
    final permissions = ref.watch(userPermissionsProvider).valueOrNull;
    final canManageShopContent = shopId != null
        ? permissions?.canManageContent(shopId) ?? false
        : false;
    final showReserve = shopId != null &&
        canShowReserveButton(
          event: event,
          canManageShopContent: canManageShopContent,
          blockedEventIds: blockedEventIds,
        );

    return ListTile(
      onTap: () => context.push('/events/${event.eventId}'),
      leading: const Icon(Icons.event, color: Colors.orange, size: 32),
      title: Text(event.eventName, style: Theme.of(context).textTheme.titleSmall),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(event.eventDate, style: Theme.of(context).textTheme.bodySmall),
          if (event.shopName?.isNotEmpty == true)
            Text(
              event.shopName!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
        ],
      ),
      trailing: showReserve
          ? TextButton(
              onPressed: () {
                context.push('/reservations?shopId=$shopId&eventId=${event.eventId}');
              },
              child: const Text('Reserve'),
            )
          : const Icon(Icons.chevron_right),
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
