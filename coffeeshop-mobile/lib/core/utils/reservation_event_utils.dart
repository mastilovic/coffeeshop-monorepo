import '../../data/models/event_response_dto.dart';
import '../../data/models/reservation_request_response_dto.dart';

const blockingRequestStatuses = {'PENDING', 'ACCEPTED'};

bool canReserveForEvent(EventResponseDto event) {
  final parsed = DateTime.tryParse(event.eventDate);
  if (parsed == null) return true;
  return parsed.isAfter(DateTime.now());
}

Set<String> eventIdsBlockedForUser({
  required List<ReservationRequestResponseDto> requests,
  required List<Map<String, dynamic>> reservations,
  required String userId,
}) {
  final blocked = <String>{};

  for (final req in requests) {
    final reqUserId = req.user?['id'] as String? ?? req.userId;
    if (reqUserId == userId &&
        req.eventId != null &&
        blockingRequestStatuses.contains(req.status)) {
      blocked.add(req.eventId!);
    }
  }

  for (final res in reservations) {
    final resUser = res['user'] as Map<String, dynamic>?;
    final resUserId = resUser?['id'] as String? ?? res['userId'] as String?;
    final eventId = res['eventId'] as String?;
    if (resUserId == userId && eventId != null) {
      blocked.add(eventId);
    }
  }

  return blocked;
}

bool canShowReserveButton({
  required EventResponseDto event,
  required bool canManageShopContent,
  required Set<String> blockedEventIds,
}) {
  if (canManageShopContent) return false;
  if (!canReserveForEvent(event)) return false;
  return !blockedEventIds.contains(event.eventId);
}

String reserveTooltip({
  required EventResponseDto event,
  required bool canManageShopContent,
  required Set<String> blockedEventIds,
}) {
  if (canManageShopContent) {
    return 'Use Reservations to request for a guest at your shop';
  }
  if (!canReserveForEvent(event)) {
    return 'This event has already passed';
  }
  if (blockedEventIds.contains(event.eventId)) {
    return 'You already have a reservation request or reservation for this event';
  }
  return 'Reserve for ${event.eventName}';
}
