import { inject, Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import { DashboardActivityResponse, DashboardAnalyticsResponse } from '../models/dashboard.model';

@Injectable({ providedIn: 'root' })
export class DashboardService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiUrl}/api/v2/dashboard`;

  getActivity(): Observable<DashboardActivityResponse> {
    return this.http.get<DashboardActivityResponse>(`${this.base}/activity`);
  }

  getAnalytics(): Observable<DashboardAnalyticsResponse> {
    return this.http.get<DashboardAnalyticsResponse>(`${this.base}/analytics`);
  }
}
