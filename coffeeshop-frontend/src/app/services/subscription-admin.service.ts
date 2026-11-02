import { inject, Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import {
  AdminFeatureUpdate,
  AdminOwnerOverrideRequest,
  AdminTierUpdate,
  FeatureCatalogItem,
  OwnerSubscriptionPage,
  OwnerSubscriptionResponse,
  PlanTierCatalogItem,
} from '../models/subscription-admin.model';

export interface OwnerListParams {
  q?: string;
  page: number;
  size: number;
}

@Injectable({ providedIn: 'root' })
export class SubscriptionAdminService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiUrl}/api/v2/admin/subscription`;

  getTiers(): Observable<PlanTierCatalogItem[]> {
    return this.http.get<PlanTierCatalogItem[]>(`${this.base}/tiers`);
  }

  updateTiers(tiers: AdminTierUpdate[]): Observable<PlanTierCatalogItem[]> {
    return this.http.put<PlanTierCatalogItem[]>(`${this.base}/tiers`, { tiers });
  }

  getFeatures(): Observable<FeatureCatalogItem[]> {
    return this.http.get<FeatureCatalogItem[]>(`${this.base}/features`);
  }

  updateFeatures(features: AdminFeatureUpdate[]): Observable<FeatureCatalogItem[]> {
    return this.http.put<FeatureCatalogItem[]>(`${this.base}/features`, { features });
  }

  listOwners(params: OwnerListParams): Observable<OwnerSubscriptionPage> {
    let httpParams = new HttpParams()
      .set('page', String(params.page))
      .set('size', String(params.size));
    if (params.q) {
      httpParams = httpParams.set('q', params.q);
    }
    return this.http.get<OwnerSubscriptionPage>(`${this.base}/owners`, { params: httpParams });
  }

  overrideOwnerPlan(
    userId: string,
    request: AdminOwnerOverrideRequest,
  ): Observable<OwnerSubscriptionResponse> {
    return this.http.put<OwnerSubscriptionResponse>(`${this.base}/owners/${userId}`, request);
  }
}
