import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_notifier.dart';
import '../../core/auth/user_permissions.dart';
import '../../core/utils/api_error.dart';
import '../../core/utils/reservation_event_utils.dart';
import '../../data/models/event_response_dto.dart';
import '../../data/services/event_api_service.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../reservations/reservation_providers.dart';
import '../reservations/widgets/event_reservation_form.dart';
import '../shop_details/tabs/events_tab.dart';
import 'event_providers.dart';

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventDetailProvider(eventId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event'),
        actions: [
          eventAsync.maybeWhen(
            data: (event) {
              final shopId = event.shopId;
              if (shopId == null) return const SizedBox.shrink();
              return _EventDeleteAction(
                shopId: shopId,
                onDelete: () => _deleteEvent(context, ref),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: eventAsync.when(
        loading: () => const LoadingIndicator(message: 'Loading event...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(eventDetailProvider(eventId)),
        ),
        data: (event) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(eventLabel(event), style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 8),
                Text(event.eventDate),
              ],
            ),
            if (event.shopName != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.store, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(event.shopName!)),
                ],
              ),
            ],
            if (event.description != null && event.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Description', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(event.description!),
            ],
            if (event.shopId != null) ...[
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: () => context.push('/shops/${event.shopId}'),
                child: const Text('View Shop'),
              ),
            ],
            if (event.shopId != null) ...[
              const SizedBox(height: 16),
              _EventReservationSection(event: event),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _deleteEvent(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete event?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(eventApiServiceProvider).delete(eventId);
      ref.invalidate(eventListProvider);
      if (context.mounted) context.pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: ${formatApiError(e)}')),
        );
      }
    }
  }
}

class _EventDeleteAction extends ConsumerWidget {
  const _EventDeleteAction({
    required this.shopId,
    required this.onDelete,
  });

  final String shopId;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(userPermissionsProvider).valueOrNull;

    if (permissions == null) return const SizedBox.shrink();
    if (!permissions.canManageShop(shopId)) return const SizedBox.shrink();

    return IconButton(
      icon: const Icon(Icons.delete_outline),
      onPressed: onDelete,
    );
  }
}

class _EventReservationSection extends ConsumerWidget {
  const _EventReservationSection({required this.event});

  final EventResponseDto event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopId = event.shopId;
    if (shopId == null) return const SizedBox.shrink();

    final userId = ref.watch(authNotifierProvider).user?.id;
    if (userId == null) return const SizedBox.shrink();

    final permissions = ref.watch(userPermissionsProvider).valueOrNull;
    final requestsAsync = ref.watch(myReservationRequestsProvider);
    final reservationsAsync = ref.watch(myReservationsProvider);

    if (permissions == null) return const SizedBox.shrink();

    if (permissions.canManageContent(shopId)) return const SizedBox.shrink();

    return requestsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 8),
        child: LinearProgressIndicator(),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (requests) => reservationsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.only(top: 8),
          child: LinearProgressIndicator(),
        ),
        error: (_, __) => const SizedBox.shrink(),
        data: (reservations) {
          final blocked = eventIdsBlockedForUser(
            requests: requests,
            reservations: reservations,
            userId: userId,
          );

          if (!canReserveForEvent(event)) {
            return Text(
              'This event has already passed.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            );
          }

          if (blocked.contains(event.eventId)) {
            return Text(
              'You already have a reservation request or reservation for this event.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            );
          }

          return EventReservationForm(
            eventId: event.eventId,
            shopId: shopId,
            eventName: event.eventName,
            eventDate: event.eventDate,
          );
        },
      ),
    );
  }
}
