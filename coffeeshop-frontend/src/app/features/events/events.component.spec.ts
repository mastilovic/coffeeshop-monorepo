import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { signal } from '@angular/core';
import { of } from 'rxjs';
import { EventsComponent } from './events.component';
import { EventService } from '../../services/event.service';
import { ShopService } from '../../services/shop.service';
import { ReservationService } from '../../services/reservation.service';
import { ReservationRequestService } from '../../services/reservation-request.service';
import { AuthService } from '../../services/auth.service';
import { ProfileService } from '../../services/profile.service';
import { DialogService } from '../../services/dialog.service';
import { SubscriptionService } from '../../services/subscription.service';
import { UserProfileResponseDto } from '../../models/user.model';
import { LimitUsage } from '../../models/subscription.model';

describe('EventsComponent', () => {
  let fixture: ComponentFixture<EventsComponent>;
  let canUseFeatureMock: ReturnType<typeof vi.fn>;
  let getLimitMock: ReturnType<typeof vi.fn>;

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

  const emptyPage = {
    content: [],
    page: 0,
    size: 10,
    totalElements: 0,
    totalPages: 1,
  };

  beforeEach(async () => {
    canUseFeatureMock = vi.fn((featureKey: string) => featureKey === 'event_create');
    getLimitMock = vi.fn(() => ({ used: 2, max: 5 } satisfies LimitUsage));

    await TestBed.configureTestingModule({
      imports: [EventsComponent],
      providers: [
        provideRouter([]),
        {
          provide: ProfileService,
          useValue: { currentUser: signal(ownerProfile) },
        },
        {
          provide: AuthService,
          useValue: { isAdmin: vi.fn(() => false) },
        },
        {
          provide: ShopService,
          useValue: { getMine: vi.fn(() => of([])) },
        },
        {
          provide: ReservationService,
          useValue: { getAll: vi.fn(() => of([])) },
        },
        {
          provide: ReservationRequestService,
          useValue: { getAll: vi.fn(() => of([])) },
        },
        {
          provide: EventService,
          useValue: { search: vi.fn(() => of(emptyPage)) },
        },
        {
          provide: DialogService,
          useValue: { confirm: vi.fn(() => Promise.resolve(false)) },
        },
        {
          provide: SubscriptionService,
          useValue: {
            canUseFeature: canUseFeatureMock,
            getLimit: getLimitMock,
          },
        },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(EventsComponent);
    fixture.detectChanges();
  });

  it('shows monthly event quota for entitled owners', () => {
    expect(fixture.nativeElement.textContent).toContain('2 / 5 events this month');
    expect(fixture.nativeElement.textContent).toContain('+ Add Event');
    expect(fixture.nativeElement.querySelector('a[routerlink="/profile/billing"]')).toBeNull();
  });

  it('hides create button and shows upgrade link on Starter', () => {
    canUseFeatureMock.mockImplementation(() => false);
    fixture = TestBed.createComponent(EventsComponent);
    fixture.detectChanges();

    expect(fixture.nativeElement.textContent).not.toContain('+ Add Event');
    const upgradeLink = fixture.nativeElement.querySelector(
      'a[routerlink="/profile/billing"]',
    ) as HTMLAnchorElement | null;
    expect(upgradeLink?.textContent).toContain('Upgrade to Growth');
  });

  it('blocks create when monthly quota is reached', () => {
    getLimitMock.mockReturnValue({ used: 5, max: 5 });
    fixture = TestBed.createComponent(EventsComponent);
    fixture.detectChanges();

    expect(fixture.nativeElement.textContent).toContain('5 / 5 events this month');
    expect(fixture.nativeElement.textContent).not.toContain('+ Add Event');
  });
});
