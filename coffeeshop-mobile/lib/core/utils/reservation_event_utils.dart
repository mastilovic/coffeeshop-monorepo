import '../../data/models/event_response_dto.dart';

bool canReserveForEvent(EventResponseDto event) {
  final parsed = DateTime.tryParse(event.eventDate);
  if (parsed == null) return true;
  return parsed.isAfter(DateTime.now());
}
