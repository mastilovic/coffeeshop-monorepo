import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/reservation_event_utils.dart';
import '../../features/reservations/reservation_providers.dart';

/// Outlined Reserve control that opens the reservation request flow for an event.
///
/// When the event is not reservable the button stays tappable (visually muted)
/// and shows a SnackBar instead of navigating.
class EventReserveButton extends ConsumerWidget {
  const EventReserveButton({
    super.key,
    required this.eventId,
    this.shopId,
    this.eventDate,
  });

  final String eventId;
  final String? shopId;
  final String? eventDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservations =
        ref.watch(myReservationsProvider).valueOrNull ?? const [];
    final requests =
        ref.watch(myReservationRequestsProvider).valueOrNull ?? const [];
    final alreadyReserved = userHasReservationForEvent(
      eventId: eventId,
      reservations: reservations,
      requests: requests,
    );
    final reservable = isEventReservable(
      shopId: shopId,
      eventDate: eventDate,
      alreadyReserved: alreadyReserved,
    );
    final theme = Theme.of(context);
    final color = reservable
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.38);

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        minimumSize: const Size(88, 40),
        textStyle: theme.textTheme.labelLarge,
      ),
      onPressed: () {
        if (reservable) {
          openReservationRequest(
            context,
            shopId: shopId,
            eventId: eventId,
          );
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              reservationUnavailableMessage(
                shopId: shopId,
                eventDate: eventDate,
                alreadyReserved: alreadyReserved,
              ),
            ),
          ),
        );
      },
      child: const Text('Reserve'),
    );
  }
}
