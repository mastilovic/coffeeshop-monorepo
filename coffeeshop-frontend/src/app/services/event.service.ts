import { inject, Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import {
  EventResponseDto,
  EventCreateRequest,
  EventUpdateRequest,
  PageResponseDto,
  EventSearchParams,
} from '../models/event.model';

@Injectable({ providedIn: 'root' })
export class EventService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiUrl}/api/v1/event`;

  getAll(): Observable<EventResponseDto[]> {
    return this.http.get<EventResponseDto[]>(this.base);
  }

  search(params: EventSearchParams = {}): Observable<PageResponseDto<EventResponseDto>> {
    const httpParams: Record<string, string> = {
      page: String(params.page ?? 0),
      size: String(params.size ?? 10),
    };
    if (params.q?.trim()) {
      httpParams['q'] = params.q.trim();
    }
    if (params.dateFrom?.trim()) {
      httpParams['dateFrom'] = params.dateFrom.trim();
    }
    if (params.dateTo?.trim()) {
      httpParams['dateTo'] = params.dateTo.trim();
    }
    return this.http.get<PageResponseDto<EventResponseDto>>(this.base, { params: httpParams });
  }

  getByShopId(shopId: string): Observable<EventResponseDto[]> {
    return this.http.get<EventResponseDto[]>(this.base, { params: { shopId } });
  }

  getById(eventId: string): Observable<EventResponseDto> {
    return this.http.get<EventResponseDto>(`${this.base}/${eventId}`);
  }

  create(req: EventCreateRequest): Observable<EventResponseDto> {
    return this.http.post<EventResponseDto>(this.base, req);
  }

  update(eventId: string, req: EventUpdateRequest): Observable<EventResponseDto> {
    return this.http.put<EventResponseDto>(`${this.base}/${eventId}`, req);
  }

  delete(eventId: string): Observable<void> {
    return this.http.delete<void>(`${this.base}/${eventId}`);
  }
}
