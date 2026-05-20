export interface EventResponseDto {
  eventId: string;
  eventName: string;
  eventDate: string;
  description: string;
  shopId: string;
  shopName?: string;
  shopCity?: string;
  totalTables?: number;
  reservedTables?: number;
  freeTables?: number;
  isFull?: boolean;
}

export interface PageResponseDto<T> {
  content: T[];
  page: number;
  size: number;
  totalElements: number;
  totalPages: number;
}

export interface EventSearchParams {
  q?: string;
  dateFrom?: string;
  dateTo?: string;
  page?: number;
  size?: number;
}

export interface EventCreateRequest {
  eventName: string;
  eventDate: string;
  description: string;
  shopId: string;
}

export interface EventUpdateRequest {
  eventName: string;
  eventDate: string;
  description: string;
  shopId: string;
}
