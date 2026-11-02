import { TestBed } from '@angular/core/testing';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { signal } from '@angular/core';
import { environment } from '../../environments/environment';
import { SubscriptionService } from './subscription.service';
import { ProfileService } from './profile.service';
import { UserProfileResponseDto } from '../models/user.model';
import {
  CatalogResponse,
  QuoteBreakdown,
  SubscriptionMeResponse,
  UpdatePlanRequest,
} from '../models/subscription.model';

describe('SubscriptionService', () => {
  let service: SubscriptionService;
  let httpMock: HttpTestingController;
  let currentUser: ReturnType<typeof signal<UserProfileResponseDto | null>>;

  const baseUrl = `${environment.apiUrl}/api/v2/subscription`;

  const profileWithSubscription: UserProfileResponseDto = {
    id: 'owner-1',
    name: 'Owner',
    username: 'owner',
    email: 'owner@example.com',
    userType: 'SHOP_OWNER',
    roles: [],
    favouriteShops: [],
    reviews: [],
    reservations: [],
    subscription: {
      planMode: 'PRESET',
      planTier: 'GROWTH',
      status: 'active',
      shopsIncluded: 1,
      shopsUsed: 1,
      monthlyAmountCents: 2900,
    },
    entitlements: {
      reservation_manage: true,
      event_create: true,
    },
    limits: {
      tables: { used: 5, max: 15 },
      events: { used: 2, max: 5 },
    },
  };

  beforeEach(() => {
    currentUser = signal<UserProfileResponseDto | null>(null);

    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [
        SubscriptionService,
        {
          provide: ProfileService,
          useValue: { currentUser },
        },
      ],
    });

    service = TestBed.inject(SubscriptionService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpMock.verify();
  });

  it('syncs entitlements and limits from profile signal', () => {
    currentUser.set(profileWithSubscription);
    TestBed.flushEffects();

    expect(service.canUseFeature('reservation_manage')).toBe(true);
    expect(service.canUseFeature('analytics')).toBe(false);
    expect(service.getLimit('tables')).toEqual({ used: 5, max: 15 });
    expect(service.subscription()?.planTier).toBe('GROWTH');
  });

  it('clears state when profile is null', () => {
    currentUser.set(profileWithSubscription);
    TestBed.flushEffects();
    currentUser.set(null);
    TestBed.flushEffects();

    expect(service.canUseFeature('reservation_manage')).toBe(false);
    expect(service.getLimit('tables')).toBeUndefined();
    expect(service.subscription()).toBeNull();
  });

  it('clear resets local state', () => {
    currentUser.set(profileWithSubscription);
    service.clear();

    expect(service.entitlements()).toEqual({});
    expect(service.limits()).toEqual({});
    expect(service.subscription()).toBeNull();
  });

  it('syncFromProfile updates state directly', () => {
    service.syncFromProfile(profileWithSubscription);

    expect(service.canUseFeature('event_create')).toBe(true);
    expect(service.getLimit('events')).toEqual({ used: 2, max: 5 });
  });

  it('getCatalog requests catalog endpoint', () => {
    const catalog: CatalogResponse = {
      tiers: [],
      features: [],
    };

    service.getCatalog().subscribe(response => {
      expect(response).toEqual(catalog);
    });

    const req = httpMock.expectOne(`${baseUrl}/catalog`);
    expect(req.request.method).toBe('GET');
    req.flush(catalog);
  });

  it('quote posts quote request', () => {
    const quote: QuoteBreakdown = {
      baseMonthlyCents: 2900,
      extraShopsCents: 0,
      featuresMonthlyCents: 0,
      monthlyTotalCents: 2900,
      annualTotalCents: 34800,
      annualMonthsCharged: 12,
      lineItems: [],
    };

    service
      .quote({
        planMode: 'PRESET',
        planTier: 'GROWTH',
        shopCount: 1,
        billingInterval: 'monthly',
      })
      .subscribe(response => {
        expect(response).toEqual(quote);
      });

    const req = httpMock.expectOne(`${baseUrl}/quote`);
    expect(req.request.method).toBe('POST');
    expect(req.request.body).toEqual({
      planMode: 'PRESET',
      planTier: 'GROWTH',
      shopCount: 1,
      billingInterval: 'monthly',
    });
    req.flush(quote);
  });

  it('getMe updates local subscription state', () => {
    const me: SubscriptionMeResponse = {
      planMode: 'PRESET',
      planTier: 'PRO',
      status: 'active',
      billingInterval: 'monthly',
      shopsIncluded: 1,
      shopsUsed: 2,
      lockedMonthlyAmountCents: 4900,
      entitlements: { analytics: true },
      limits: { shops: { used: 2, max: 5 } },
    };

    service.getMe().subscribe();

    const req = httpMock.expectOne(`${baseUrl}/me`);
    expect(req.request.method).toBe('GET');
    req.flush(me);

    expect(service.subscription()?.planTier).toBe('PRO');
    expect(service.canUseFeature('analytics')).toBe(true);
    expect(service.getLimit('shops')).toEqual({ used: 2, max: 5 });
  });

  it('changePlan updates local subscription state', () => {
    const request: UpdatePlanRequest = {
      planMode: 'PRESET',
      planTier: 'GROWTH',
      billingInterval: 'annual',
    };
    const response: SubscriptionMeResponse = {
      planMode: 'PRESET',
      planTier: 'GROWTH',
      status: 'active',
      billingInterval: 'annual',
      shopsIncluded: 1,
      shopsUsed: 1,
      lockedMonthlyAmountCents: 2900,
      entitlements: { reservation_manage: true },
      limits: {},
    };

    service.changePlan(request).subscribe();

    const req = httpMock.expectOne(`${baseUrl}/plan`);
    expect(req.request.method).toBe('PUT');
    expect(req.request.body).toEqual(request);
    req.flush(response);

    expect(service.subscription()?.planTier).toBe('GROWTH');
    expect(service.canUseFeature('reservation_manage')).toBe(true);
  });
});
