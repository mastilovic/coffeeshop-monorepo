import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { signal } from '@angular/core';
import { of } from 'rxjs';
import { DashboardComponent } from './dashboard.component';
import { DashboardService } from '../../services/dashboard.service';
import { AuthService } from '../../services/auth.service';
import { ProfileService } from '../../services/profile.service';
import { SubscriptionService } from '../../services/subscription.service';
import { UserProfileResponseDto } from '../../models/user.model';
import { DashboardActivityResponse, DashboardAnalyticsResponse } from '../../models/dashboard.model';

describe('DashboardComponent', () => {
  let fixture: ComponentFixture<DashboardComponent>;
  let canUseFeatureMock: ReturnType<typeof vi.fn>;
  let getAnalyticsMock: ReturnType<typeof vi.fn>;

  const ownerProfile: UserProfileResponseDto = {
    id: 'owner-1',
    name: 'Owner',
    username: 'owner',
    email: 'owner@example.com',
    userType: 'SHOP_OWNER',
    roles: [],
    favouriteShops: [],
    reviews: [],
    reservations: [],
  };

  const activityResponse: DashboardActivityResponse = {
    aggregate: {
      shopCount: 1,
      reviewCount: 2,
      averageRating: 4.5,
      eventCount: 1,
      memberCount: 3,
    },
    activities: [],
    topShops: [],
    upcomingEvents: [],
    personalSummary: {
      favouriteShops: 0,
      reservations: 0,
      reviewsWritten: 0,
    },
    notifications: [],
  };

  const analyticsResponse: DashboardAnalyticsResponse = {
    aggregate: {
      shopCount: 1,
      reservationCount: 4,
      pendingReservationRequestCount: 1,
      eventCount: 2,
      reviewCount: 5,
      averageRating: 4.2,
      communityPostCount: 3,
      memberCount: 10,
      employeeCount: 2,
      tableCount: 6,
      menuCount: 2,
    },
    shops: [
      {
        shopId: 'shop-1',
        shopName: 'Bean There',
        city: 'Zagreb',
        reservationCount: 4,
        pendingReservationRequestCount: 1,
        eventCount: 2,
        reviewCount: 5,
        averageRating: 4.2,
        communityPostCount: 3,
        memberCount: 10,
        employeeCount: 2,
        tableCount: 6,
        menuCount: 2,
      },
    ],
  };

  beforeEach(async () => {
    canUseFeatureMock = vi.fn((featureKey: string) => featureKey === 'analytics');
    getAnalyticsMock = vi.fn(() => of(analyticsResponse));

    await TestBed.configureTestingModule({
      imports: [DashboardComponent],
      providers: [
        provideRouter([]),
        {
          provide: ProfileService,
          useValue: { currentUser: signal(ownerProfile) },
        },
        {
          provide: AuthService,
          useValue: {
            realmRoles: signal(['shop_owner']),
            isAdmin: vi.fn(() => false),
          },
        },
        {
          provide: DashboardService,
          useValue: {
            getActivity: vi.fn(() => of(activityResponse)),
            getAnalytics: getAnalyticsMock,
          },
        },
        {
          provide: SubscriptionService,
          useValue: {
            canUseFeature: canUseFeatureMock,
          },
        },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(DashboardComponent);
    fixture.detectChanges();
  });

  it('loads analytics for entitled shop owners', () => {
    expect(getAnalyticsMock).toHaveBeenCalled();
    expect(fixture.nativeElement.querySelector('[data-testid="analytics-aggregate"]')).toBeTruthy();
    expect(fixture.nativeElement.textContent).toContain('4');
    expect(fixture.nativeElement.textContent).toContain('Bean There');
    expect(fixture.nativeElement.querySelector('[data-testid="analytics-upgrade"]')).toBeNull();
  });

  it('shows upgrade CTA for Starter/Growth owners without analytics', () => {
    canUseFeatureMock.mockImplementation(() => false);
    getAnalyticsMock.mockClear();

    fixture = TestBed.createComponent(DashboardComponent);
    fixture.detectChanges();

    expect(getAnalyticsMock).not.toHaveBeenCalled();
    const upgrade = fixture.nativeElement.querySelector('[data-testid="analytics-upgrade"]');
    expect(upgrade).toBeTruthy();
    const upgradeLink = fixture.nativeElement.querySelector(
      'a[routerlink="/profile/billing"]',
    ) as HTMLAnchorElement | null;
    expect(upgradeLink?.textContent).toContain('Upgrade to Pro');
  });

  it('hides analytics section for customers', () => {
    const customerAnalyticsMock = vi.fn(() => of(analyticsResponse));

    TestBed.resetTestingModule();
    TestBed.configureTestingModule({
      imports: [DashboardComponent],
      providers: [
        provideRouter([]),
        {
          provide: ProfileService,
          useValue: {
            currentUser: signal({
              ...ownerProfile,
              userType: 'CUSTOMER',
            } satisfies UserProfileResponseDto),
          },
        },
        {
          provide: AuthService,
          useValue: {
            realmRoles: signal(['customer']),
            isAdmin: vi.fn(() => false),
          },
        },
        {
          provide: DashboardService,
          useValue: {
            getActivity: vi.fn(() => of(activityResponse)),
            getAnalytics: customerAnalyticsMock,
          },
        },
        {
          provide: SubscriptionService,
          useValue: {
            canUseFeature: canUseFeatureMock,
          },
        },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(DashboardComponent);
    fixture.detectChanges();

    expect(fixture.nativeElement.textContent).not.toContain('Pro Analytics');
    expect(customerAnalyticsMock).not.toHaveBeenCalled();
  });
});
