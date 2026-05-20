import { inject, Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import { ReviewResponseDto, ReviewCreateRequest, ReviewUpdateRequest } from '../models/review.model';

@Injectable({ providedIn: 'root' })
export class ReviewService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiUrl}/api/v1/review`;

  getAll(): Observable<ReviewResponseDto[]> {
    return this.http.get<ReviewResponseDto[]>(this.base);
  }

  getById(id: string): Observable<ReviewResponseDto> {
    return this.http.get<ReviewResponseDto>(`${this.base}/${id}`);
  }

  create(req: ReviewCreateRequest): Observable<ReviewResponseDto> {
    return this.http.post<ReviewResponseDto>(this.base, req);
  }

  update(id: string, req: ReviewUpdateRequest): Observable<ReviewResponseDto> {
    return this.http.put<ReviewResponseDto>(`${this.base}/${id}`, req);
  }

  delete(id: string): Observable<void> {
    return this.http.delete<void>(`${this.base}/${id}`);
  }
}
