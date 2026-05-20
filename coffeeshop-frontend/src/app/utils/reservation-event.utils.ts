import { EventResponseDto } from '../models/event.model';
import {
  ReservationRequestResponseDto,
  ReservationResponseDto,
} from '../models/reservation.model';

export const BLOCKING_REQUEST_STATUSES = new Set(['PENDING', 'ACCEPTED']);

export function isEventFull(event: EventResponseDto): boolean {
  return event.isFull === true || (event.freeTables ?? 1) <= 0;
}

export function canReserveForEvent(event: EventResponseDto): boolean {
  if (isEventFull(event)) return false;
  const parsed = new Date(event.eventDate);
  if (Number.isNaN(parsed.getTime())) return true;
  return parsed > new Date();
}

export function eventAvailabilityLabel(event: EventResponseDto): string {
  if (isEventFull(event)) return 'Full';
  if (typeof event.freeTables === 'number') return `${event.freeTables} left`;
  return '—';
}

export function eventIdsBlockedForUser(
  requests: ReservationRequestResponseDto[],
  reservations: ReservationResponseDto[],
  userId: string,
): Set<string> {
  const blocked = new Set<string>();
  for (const req of requests) {
    if (
      req.user?.id === userId
      && req.eventId
      && BLOCKING_REQUEST_STATUSES.has(req.status)
    ) {
      blocked.add(req.eventId);
    }
  }
  for (const res of reservations) {
    if (res.user?.id === userId && res.eventId) {
      blocked.add(res.eventId);
    }
  }
  return blocked;
}
