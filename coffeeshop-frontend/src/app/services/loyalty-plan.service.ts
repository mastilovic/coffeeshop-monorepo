import { inject, Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import { LoyaltyPlanResponseDto, LoyaltyPlanCreateRequest } from '../models/loyalty-plan.model';

@Injectable({ providedIn: 'root' })
export class LoyaltyPlanService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiUrl}/api/v2/loyalty-plan`;

  getAll(): Observable<LoyaltyPlanResponseDto[]> {
    return this.http.get<LoyaltyPlanResponseDto[]>(this.base);
  }

  getById(id: string): Observable<LoyaltyPlanResponseDto> {
    return this.http.get<LoyaltyPlanResponseDto>(`${this.base}/${id}`);
  }

  create(req: LoyaltyPlanCreateRequest): Observable<LoyaltyPlanResponseDto> {
    return this.http.post<LoyaltyPlanResponseDto>(this.base, req);
  }

  update(id: string, req: LoyaltyPlanCreateRequest): Observable<LoyaltyPlanResponseDto> {
    return this.http.put<LoyaltyPlanResponseDto>(`${this.base}/${id}`, req);
  }

  delete(id: string): Observable<void> {
    return this.http.delete<void>(`${this.base}/${id}`);
  }
}
