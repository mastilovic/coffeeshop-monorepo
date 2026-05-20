import { UserSummaryDto } from './user.model';
import { ShopSummaryDto } from './shop.model';
import { TableSummaryDto } from './table.model';

export interface ReservationResponseDto {
  id: string;
  user: UserSummaryDto;
  shop: ShopSummaryDto;
  partySize: number;
  reservationRequestId: string;
  table: TableSummaryDto;
  eventId?: string;
  eventName?: string;
  eventDate?: string;
}

export interface ReservationCreateRequest {
  userId: string;
  tableId: string;
  eventId: string;
  partySize: number;
}

export interface ReservationUpdateRequest {
  userId: string;
  tableId: string;
}

export interface ReservationRequestResponseDto {
  id: string;
  user: UserSummaryDto;
  shop: ShopSummaryDto;
  partySize: number;
  status: 'PENDING' | 'ACCEPTED' | 'DENIED';
  reservationId: string;
  eventId?: string;
  eventName?: string;
  eventDate?: string;
}

export interface ReservationRequestCreateRequest {
  userId: string;
  shopId: string;
  eventId: string;
  partySize: number;
}

export interface ReservationAcceptRequest {
  tableId: string;
}
