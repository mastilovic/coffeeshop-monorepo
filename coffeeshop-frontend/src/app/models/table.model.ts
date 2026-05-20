import { ReservationResponseDto } from './reservation.model';

export interface TableResponseDto {
  id: string;
  number: number;
  capacity: number;
  shopId: string;
  reservations: ReservationResponseDto[];
}

export interface TableSummaryDto {
  id: string;
  number: number;
  capacity: number;
}

export interface TableCreateRequest {
  number: number;
  capacity: number;
  shopId: string;
}
