import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/event_response_dto.dart';
import '../../data/models/reservation_request_response_dto.dart';

bool canReserveForDate(String? eventDate) {
  if (eventDate == null) return true;
  final parsed = DateTime.tryParse(eventDate);
  if (parsed == null) return true;
  return parsed.isAfter(DateTime.now());
}

bool canReserveForEvent(EventResponseDto event) =>
    canReserveForDate(event.eventDate);

/// True when the user already has a confirmed reservation or pending request
/// for [eventId]. Denied requests do not block a new reservation.
bool userHasReservationForEvent({
  required String eventId,
  List<Map<String, dynamic>> reservations = const [],
  List<ReservationRequestResponseDto> requests = const [],
}) {
  if (reservations.any((r) => r['eventId'] == eventId)) return true;
  return requests.any(
    (r) => r.eventId == eventId && r.status.toUpperCase() == 'PENDING',
  );
}

/// Whether a reservation can be created for this shop + event date.
bool isEventReservable({
  String? shopId,
  String? eventDate,
  bool alreadyReserved = false,
}) =>
    !alreadyReserved &&
    shopId != null &&
    shopId.isNotEmpty &&
    canReserveForDate(eventDate);

/// User-facing reason when [isEventReservable] is false.
String reservationUnavailableMessage({
  String? shopId,
  String? eventDate,
  bool alreadyReserved = false,
}) {
  if (alreadyReserved) {
    return 'You already have a reservation for this event.';
  }
  if (shopId == null || shopId.isEmpty) {
    return "This event isn't linked to a shop yet.";
  }
  return 'Reservations for this event are no longer available.';
}

/// Navigates to the Reservations tab and opens the request form when needed.
///
/// Prefills [shopId] / [eventId] when provided. Pass [openForm] to force the
/// form open without IDs (e.g. empty-state / quick-action CTAs).
void openReservationRequest(
  BuildContext context, {
  String? shopId,
  String? eventId,
  bool openForm = false,
}) {
  final params = <String, String>{};
  if (shopId != null && shopId.isNotEmpty) {
    params['shopId'] = shopId;
  }
  if (eventId != null && eventId.isNotEmpty) {
    params['eventId'] = eventId;
  }
  if (openForm || params.isNotEmpty) {
    params['request'] = '1';
  }

  final uri = Uri(
    path: '/reservations',
    queryParameters: params.isEmpty ? null : params,
  );
  context.go(uri.toString());
}
