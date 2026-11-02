import { effect, inject, Injectable, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, tap } from 'rxjs';
import { environment } from '../../environments/environment';
import {
  CatalogResponse,
  LimitUsage,
  QuoteBreakdown,
  QuoteRequest,
  SubscriptionMeResponse,
  SubscriptionSummary,
  UpdatePlanRequest,
} from '../models/subscription.model';
import { UserProfileResponseDto } from '../models/user.model';
import { ProfileService } from './profile.service';

@Injectable({ providedIn: 'root' })
export class SubscriptionService {
  private readonly http = inject(HttpClient);
  private readonly profileService = inject(ProfileService);
  private readonly base = `${environment.apiUrl}/api/v2/subscription`;

  readonly subscription = signal<SubscriptionSummary | null>(null);
  readonly entitlements = signal<Record<string, boolean>>({});
  readonly limits = signal<Record<string, LimitUsage>>({});

  constructor() {
    effect(() => {
      const user = this.profileService.currentUser();
      if (user) {
        this.syncFromProfile(user);
      } else {
        this.clear();
      }
    });
  }

  canUseFeature(featureKey: string): boolean {
    return this.entitlements()[featureKey] ?? false;
  }

  getLimit(limitKey: string): LimitUsage | undefined {
    return this.limits()[limitKey];
  }

  syncFromProfile(profile: UserProfileResponseDto): void {
    this.subscription.set(profile.subscription ?? null);
    this.entitlements.set(profile.entitlements ?? {});
    this.limits.set(profile.limits ?? {});
  }

  clear(): void {
    this.subscription.set(null);
    this.entitlements.set({});
    this.limits.set({});
  }

  getCatalog(): Observable<CatalogResponse> {
    return this.http.get<CatalogResponse>(`${this.base}/catalog`);
  }

  quote(request: QuoteRequest): Observable<QuoteBreakdown> {
    return this.http.post<QuoteBreakdown>(`${this.base}/quote`, request);
  }

  getMe(): Observable<SubscriptionMeResponse> {
    return this.http.get<SubscriptionMeResponse>(`${this.base}/me`).pipe(
      tap(response => this.applyMeResponse(response)),
    );
  }

  changePlan(request: UpdatePlanRequest): Observable<SubscriptionMeResponse> {
    return this.http.put<SubscriptionMeResponse>(`${this.base}/plan`, request).pipe(
      tap(response => this.applyMeResponse(response)),
    );
  }

  private applyMeResponse(response: SubscriptionMeResponse): void {
    this.subscription.set({
      planMode: response.planMode,
      planTier: response.planTier,
      status: response.status,
      shopsIncluded: response.shopsIncluded,
      shopsUsed: response.shopsUsed,
      periodEnd: response.periodEnd,
      monthlyAmountCents: response.lockedMonthlyAmountCents,
    });
    this.entitlements.set(response.entitlements);
    this.limits.set(response.limits ?? {});
  }
}
