import { HttpErrorResponse } from '@angular/common/http';

interface ApiErrorBody {
  message?: string;
}

export function getApiErrorMessage(error: unknown, fallback: string): string {
  if (error instanceof HttpErrorResponse) {
    const body = error.error as ApiErrorBody | null;
    if (body?.message && typeof body.message === 'string') {
      return body.message;
    }
  }
  if (error instanceof Error && error.message) {
    return error.message;
  }
  return fallback;
}

export interface AcceptReservationErrorContext {
  partySize: number;
  tableCapacity?: number;
}

const CAPACITY_MESSAGE = 'Table capacity is less than partySize';
const SHOP_MISMATCH_MESSAGE = 'Table must belong to the same shop as the reservation request';
const NOT_PENDING_MESSAGE = 'Only pending reservation requests can be accepted';
const NO_TABLES_MESSAGE = 'No tables left for this event';
const DUPLICATE_BOOKING_MESSAGE =
  'This user already has a reservation request or reservation for this event';

export function getAcceptReservationErrorMessage(
  error: unknown,
  context?: AcceptReservationErrorContext,
): string {
  const apiMessage = getApiErrorMessage(error, '');
  const status = error instanceof HttpErrorResponse ? error.status : undefined;

  if (apiMessage === CAPACITY_MESSAGE) {
    const partySize = context?.partySize;
    const capacity = context?.tableCapacity;
    if (capacity != null && partySize != null) {
      return `This table seats ${capacity} guests, but the request is for ${partySize}. Choose a larger table.`;
    }
    if (partySize != null) {
      return `The selected table is too small for a party of ${partySize}. Choose a larger table.`;
    }
    return 'The selected table is too small for this party size. Choose a larger table.';
  }

  if (apiMessage === SHOP_MISMATCH_MESSAGE) {
    return 'The selected table belongs to a different shop than this request.';
  }

  if (apiMessage === NOT_PENDING_MESSAGE) {
    return 'This request is no longer pending and cannot be accepted.';
  }

  if (apiMessage === DUPLICATE_BOOKING_MESSAGE) {
    return 'This guest already has a reservation request or reservation for this event.';
  }

  if (status === 409 || apiMessage === NO_TABLES_MESSAGE) {
    return 'There are no tables left for this event.';
  }

  if (apiMessage) {
    return apiMessage;
  }

  return 'Could not accept this reservation request.';
}
