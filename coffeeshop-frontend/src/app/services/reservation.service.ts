import { inject, Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import { ReservationResponseDto, ReservationCreateRequest, ReservationUpdateRequest } from '../models/reservation.model';

@Injectable({ providedIn: 'root' })
export class ReservationService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiUrl}/api/v1/reservation`;

  getAll(): Observable<ReservationResponseDto[]> {
    return this.http.get<ReservationResponseDto[]>(this.base);
  }

  getById(id: string): Observable<ReservationResponseDto> {
    return this.http.get<ReservationResponseDto>(`${this.base}/${id}`);
  }

  create(req: ReservationCreateRequest): Observable<ReservationResponseDto> {
    return this.http.post<ReservationResponseDto>(this.base, req);
  }

  update(id: string, req: ReservationUpdateRequest): Observable<ReservationResponseDto> {
    return this.http.put<ReservationResponseDto>(`${this.base}/${id}`, req);
  }

  delete(id: string): Observable<void> {
    return this.http.delete<void>(`${this.base}/${id}`);
  }
}
