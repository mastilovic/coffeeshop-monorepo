import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { signal } from '@angular/core';
import { of } from 'rxjs';
import { ReservationsComponent } from './reservations.component';
import { ReservationService } from '../../services/reservation.service';
import { ReservationRequestService } from '../../services/reservation-request.service';
import { ShopService } from '../../services/shop.service';
import { TableService } from '../../services/table.service';
import { EventService } from '../../services/event.service';
import { UserService } from '../../services/user.service';
import { ProfileService } from '../../services/profile.service';
import { AuthService } from '../../services/auth.service';
import { DialogService } from '../../services/dialog.service';
import { SubscriptionService } from '../../services/subscription.service';
import { ReservationRequestResponseDto } from '../../models/reservation.model';
import { ShopResponseDto } from '../../models/shop.model';
import { UserProfileResponseDto } from '../../models/user.model';

describe('ReservationsComponent', () => {
  let fixture: ComponentFixture<ReservationsComponent>;
  let canUseFeatureMock: ReturnType<typeof vi.fn>;

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

  const ownedShop: ShopResponseDto = {
    id: 'shop-1',
    name: 'Bean There',
    address: '1 Main St',
    city: 'Town',
    phoneNumber: '555',
    email: 'shop@example.com',
    createdBy: { id: 'owner-1', name: 'Owner', username: 'owner' },
    users: [],
    currentMenu: null,
    menuHistory: [],
    loyaltyPlan: {} as ShopResponseDto['loyaltyPlan'],
    events: [],
    tables: [],
    reviews: [],
    reviewCount: 0,
    averageRating: null,
    contacts: [],
  };

  const pendingRequest: ReservationRequestResponseDto = {
    id: 'req-1',
    user: { id: 'cust-1', name: 'Customer', username: 'cust' },
    shop: { id: 'shop-1', name: 'Bean There', address: '1 Main St', city: 'Town', phoneNumber: '555', email: 'shop@example.com' },
    partySize: 2,
    status: 'PENDING',
    reservationId: '',
    eventId: 'event-1',
    eventName: 'Open Mic',
  };

  beforeEach(async () => {
    canUseFeatureMock = vi.fn((featureKey: string) => featureKey === 'reservation_manage');

    await TestBed.configureTestingModule({
      imports: [ReservationsComponent],
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
          useValue: { getAll: vi.fn(() => of([ownedShop])) },
        },
        {
          provide: UserService,
          useValue: { getAll: vi.fn(() => of([])) },
        },
        {
          provide: TableService,
          useValue: { getAll: vi.fn(() => of([])) },
        },
        {
          provide: EventService,
          useValue: { getByShopId: vi.fn(() => of([])) },
        },
        {
          provide: ReservationService,
          useValue: { getAll: vi.fn(() => of([])) },
        },
        {
          provide: ReservationRequestService,
          useValue: { getAll: vi.fn(() => of([pendingRequest])) },
        },
        {
          provide: DialogService,
          useValue: { alert: vi.fn(), confirm: vi.fn(() => Promise.resolve(false)) },
        },
        {
          provide: SubscriptionService,
          useValue: {
            canUseFeature: canUseFeatureMock,
            getLimit: vi.fn(),
          },
        },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(ReservationsComponent);
    fixture.detectChanges();
  });

  function openManagePendingTab(): void {
    const buttons = fixture.nativeElement.querySelectorAll('button') as NodeListOf<HTMLButtonElement>;
    const manageTab = Array.from(buttons).find(button =>
      button.textContent?.includes('Manage my Shops'),
    );
    manageTab?.click();
    fixture.detectChanges();
  }

  function findActionButton(label: string): HTMLButtonElement | undefined {
    const buttons = fixture.nativeElement.querySelectorAll('button') as NodeListOf<HTMLButtonElement>;
    return Array.from(buttons).find(button => button.textContent?.trim() === label);
  }

  it('enables accept/deny when reservation_manage is entitled', () => {
    openManagePendingTab();

    const acceptButton = findActionButton('Accept');
    const denyButton = findActionButton('Deny');

    expect(acceptButton?.disabled).toBe(false);
    expect(denyButton?.disabled).toBe(false);
    expect(fixture.nativeElement.querySelector('a[routerlink="/profile/billing"]')).toBeNull();
  });

  it('disables accept/deny and shows upgrade link on Starter', () => {
    canUseFeatureMock.mockImplementation(() => false);
    fixture = TestBed.createComponent(ReservationsComponent);
    fixture.detectChanges();
    openManagePendingTab();

    const acceptButton = findActionButton('Accept');
    const denyButton = findActionButton('Deny');
    const upgradeLink = fixture.nativeElement.querySelector(
      'a[routerlink="/profile/billing"]',
    ) as HTMLAnchorElement | null;

    expect(acceptButton?.disabled).toBe(true);
    expect(denyButton?.disabled).toBe(true);
    expect(upgradeLink?.textContent).toContain('Upgrade to Growth');
  });

  describe('requestSecondaryLabel', () => {
    it('includes party size without date when eventDate is missing', () => {
      const component = fixture.componentInstance;
      expect(component.requestSecondaryLabel(pendingRequest)).toBe('Open Mic · Party 2');
    });

    it('appends event date and days-from-today when eventDate is present', () => {
      const component = fixture.componentInstance;
      const future = new Date();
      future.setHours(12, 0, 0, 0);
      future.setDate(future.getDate() + 3);
      const withDate = {
        ...pendingRequest,
        eventDate: future.toISOString(),
      };

      const label = component.requestSecondaryLabel(withDate);
      expect(label).toContain('Open Mic · Party 2 ·');
      expect(label).toContain('In 3 days');
      expect(label).not.toMatch(/· [^·]+ · [^·]+ · [^·]+ ·/);
      const parts = label.split(' · ');
      expect(parts.length).toBe(4);
      expect(parts[3]).toBe('In 3 days');
    });
  });

  describe('reservationSecondaryLabel', () => {
    it('appends event date and days-from-today', () => {
      const component = fixture.componentInstance;
      const past = new Date();
      past.setHours(12, 0, 0, 0);
      past.setDate(past.getDate() - 5);
      const label = component.reservationSecondaryLabel({
        eventName: 'Jazz Night',
        eventDate: past.toISOString(),
        partySize: 4,
        table: { number: 7 },
      });
      expect(label).toContain('Jazz Night · Table 7 · Party 4 ·');
      expect(label).toContain('5 days ago');
    });
  });

  describe('relativeEventTime', () => {
    it('returns Today for events on the same calendar day', () => {
      const component = fixture.componentInstance;
      const laterToday = new Date();
      laterToday.setHours(23, 59, 0, 0);
      expect(component.relativeEventTime(laterToday.toISOString())).toBe('Today');
    });

    it('returns Yesterday for events one day ago', () => {
      const component = fixture.componentInstance;
      const yesterday = new Date();
      yesterday.setHours(12, 0, 0, 0);
      yesterday.setDate(yesterday.getDate() - 1);
      expect(component.relativeEventTime(yesterday.toISOString())).toBe('Yesterday');
    });

    it('returns N days ago for far past without a second date', () => {
      const component = fixture.componentInstance;
      const farPast = new Date();
      farPast.setHours(12, 0, 0, 0);
      farPast.setDate(farPast.getDate() - 45);
      expect(component.relativeEventTime(farPast.toISOString())).toBe('45 days ago');
    });
  });
});
