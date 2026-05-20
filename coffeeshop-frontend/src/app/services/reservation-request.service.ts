import { inject, Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import {
  ReservationRequestResponseDto,
  ReservationRequestCreateRequest,
  ReservationAcceptRequest,
} from '../models/reservation.model';

@Injectable({ providedIn: 'root' })
export class ReservationRequestService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiUrl}/api/v1/reservation-request`;

  getAll(shopId?: string): Observable<ReservationRequestResponseDto[]> {
    const url = shopId ? `${this.base}?shopId=${shopId}` : this.base;
    return this.http.get<ReservationRequestResponseDto[]>(url);
  }

  create(req: ReservationRequestCreateRequest): Observable<ReservationRequestResponseDto> {
    return this.http.post<ReservationRequestResponseDto>(this.base, req);
  }

  accept(id: string, req: ReservationAcceptRequest): Observable<ReservationRequestResponseDto> {
    return this.http.post<ReservationRequestResponseDto>(`${this.base}/${id}/accept`, req);
  }

  deny(id: string): Observable<ReservationRequestResponseDto> {
    return this.http.post<ReservationRequestResponseDto>(`${this.base}/${id}/deny`, {});
  }
}
