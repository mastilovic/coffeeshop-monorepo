import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { ActivatedRoute } from '@angular/router';
import { signal } from '@angular/core';
import { of } from 'rxjs';
import { ShopDetailsComponent } from './shop-details.component';
import { ShopService } from '../../services/shop.service';
import { MenuItemService } from '../../services/menu-item.service';
import { MenuService } from '../../services/menu.service';
import { TableService } from '../../services/table.service';
import { ReservationService } from '../../services/reservation.service';
import { ReservationRequestService } from '../../services/reservation-request.service';
import { ReviewService } from '../../services/review.service';
import { ReviewCommentService } from '../../services/review-comment.service';
import { CommunityService } from '../../services/community.service';
import { EventService } from '../../services/event.service';
import { ProfileService } from '../../services/profile.service';
import { AuthService } from '../../services/auth.service';
import { ShopEmployeeService } from '../../services/shop-employee.service';
import { DialogService } from '../../services/dialog.service';
import { SubscriptionService } from '../../services/subscription.service';
import { UserProfileResponseDto } from '../../models/user.model';
import { ShopResponseDto } from '../../models/shop.model';
import { LimitUsage } from '../../models/subscription.model';

describe('ShopDetailsComponent', () => {
  let fixture: ComponentFixture<ShopDetailsComponent>;
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

  const mockShop: ShopResponseDto = {
    id: 'shop-1',
    name: 'Test Cafe',
    address: '1 Main St',
    city: 'Berlin',
    phoneNumber: '123',
    email: 'cafe@example.com',
    createdBy: { id: 'owner-1', name: 'Owner', username: 'owner' },
    users: [],
    currentMenu: {
      id: 'menu-1',
      label: 'Summer',
      items: [],
      createdAt: '2026-01-01',
    },
    menuHistory: [],
    loyaltyPlan: {
      id: 'loyalty-1',
      name: 'Basic Rewards',
      description: 'Earn points on every visit',
      type: 'BASIC',
    },
    events: [],
    tables: [{ id: 'table-1', number: 1, capacity: 4, shopId: 'shop-1', reservations: [] }],
    reviews: [{
      id: 'review-1',
      description: 'Great coffee',
      rating: 5,
      reviewDate: '2026-06-01',
      commentsEnabled: true,
      comments: [],
      user: { id: 'customer-1', name: 'Customer', username: 'customer' },
      shop: { id: 'shop-1', name: 'Test Cafe', address: '1 Main St', city: 'Berlin', phoneNumber: '123', email: 'cafe@example.com' },
    }],
    reviewCount: 1,
    averageRating: 5,
    contacts: [],
  };

  const emptyPage = {
    content: [],
    page: 0,
    size: 10,
    totalElements: 0,
    totalPages: 1,
  };

  async function setup(
    entitlements: Record<string, boolean>,
    limits: Record<string, LimitUsage> = {},
    profile: UserProfileResponseDto = ownerProfile,
  ): Promise<void> {
    canUseFeatureMock = vi.fn((featureKey: string) => entitlements[featureKey] ?? false);
    getLimitMock = vi.fn((limitKey: string) => limits[limitKey]);

    await TestBed.configureTestingModule({
      imports: [ShopDetailsComponent],
      providers: [
        provideRouter([]),
        {
          provide: ActivatedRoute,
          useValue: { snapshot: { paramMap: { get: () => 'shop-1' } } },
        },
        {
          provide: ProfileService,
          useValue: { currentUser: signal(profile) },
        },
        {
          provide: AuthService,
          useValue: { isAdmin: vi.fn(() => false) },
        },
        {
          provide: ShopService,
          useValue: { getById: vi.fn(() => of(mockShop)) },
        },
        { provide: MenuItemService, useValue: {} },
        { provide: MenuService, useValue: { createForShop: vi.fn(() => of(mockShop.currentMenu)) } },
        { provide: TableService, useValue: {} },
        { provide: ReservationService, useValue: { getAll: vi.fn(() => of([])) } },
        {
          provide: ReservationRequestService,
          useValue: { getAll: vi.fn(() => of([])) },
        },
        {
          provide: ReviewService,
          useValue: {
            delete: vi.fn(() => of(void 0)),
            create: vi.fn(),
            update: vi.fn(),
          },
        },
        { provide: ReviewCommentService, useValue: {} },
        {
          provide: CommunityService,
          useValue: {
            getMembers: vi.fn(() => of(emptyPage)),
            getPosts: vi.fn(() => of(emptyPage)),
          },
        },
        { provide: EventService, useValue: {} },
        {
          provide: ShopEmployeeService,
          useValue: {
            getMyEmployeeShops: vi.fn(() => of([])),
            getEmployees: vi.fn(() => of([])),
          },
        },
        {
          provide: DialogService,
          useValue: { confirm: vi.fn(() => Promise.resolve(false)), alert: vi.fn(() => Promise.resolve()) },
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

    fixture = TestBed.createComponent(ShopDetailsComponent);
    fixture.detectChanges();
  }

  it('defaults to Overview as the first tab', async () => {
    await setup({});

    const tabLabels = fixture.componentInstance.visibleTabs().map(tab => tab.label);
    expect(tabLabels[0]).toBe('Overview');
    expect(fixture.componentInstance.activeTab()).toBe('overview');

    const element = fixture.nativeElement as HTMLElement;
    expect(element.textContent).toContain('No menu yet.');
    expect(element.textContent).toContain('No upcoming events.');
    expect(element.textContent).toContain('Great coffee');
    expect(element.textContent).toContain('5.0 (1)');
  });

  it('shows table usage indicator', async () => {
    await setup(
      { unlimited_tables: false },
      { tables: { used: 12, max: 15 } },
    );

    fixture.componentInstance.onTabChange('tables');
    fixture.detectChanges();

    const element = fixture.nativeElement as HTMLElement;
    expect(element.textContent).toContain('12 / 15 tables');
    expect(element.textContent).toContain('+ Add Table');
  });

  it('shows upgrade link when table cap is reached', async () => {
    await setup(
      { unlimited_tables: false },
      { tables: { used: 15, max: 15 } },
    );

    fixture.componentInstance.onTabChange('tables');
    fixture.detectChanges();

    const upgradeLink = fixture.nativeElement.querySelector(
      'a[routerlink="/profile/billing"]',
    ) as HTMLAnchorElement | null;
    expect(upgradeLink?.textContent).toContain('Upgrade to Growth');
  });

  it('disables second menu on Starter and shows upgrade link', async () => {
    await setup(
      { unlimited_menus: false },
      { menus: { used: 1, max: 1 } },
    );

    fixture.componentInstance.onTabChange('menu');
    fixture.detectChanges();

    const element = fixture.nativeElement as HTMLElement;
    expect(element.textContent).toContain('1 / 1 menus');
    expect(element.textContent).not.toContain('+ New Menu');
    expect(element.querySelector('a[routerlink="/profile/billing"]')?.textContent).toContain('Upgrade to Growth');
  });

  it('gates community announcements on Starter', async () => {
    await setup({ community_post: false });

    fixture.componentInstance.onTabChange('users');
    fixture.detectChanges();

    const element = fixture.nativeElement as HTMLElement;
    expect(element.querySelector('textarea[placeholder="Share news with your community..."]')).toBeNull();
    expect(element.textContent).toContain('Upgrade to Growth');
  });

  it('shows review moderation upgrade when not entitled', async () => {
    await setup({ review_moderate: false });

    fixture.componentInstance.onTabChange('reviews');
    fixture.detectChanges();

    const element = fixture.nativeElement as HTMLElement;
    expect(element.textContent).not.toContain('Delete');
    expect(element.querySelector('a[routerlink="/profile/billing"]')?.textContent).toContain('Upgrade to Growth');
  });

  it('shows delete review when moderation is entitled', async () => {
    await setup({ review_moderate: true });

    fixture.componentInstance.onTabChange('reviews');
    fixture.detectChanges();

    expect(fixture.nativeElement.textContent).toContain('Delete');
  });

  it('hides leave review and shows edit when current user already reviewed', async () => {
    const customerProfile: UserProfileResponseDto = {
      ...ownerProfile,
      id: 'customer-1',
      name: 'Customer',
      username: 'customer',
      email: 'customer@example.com',
      userType: 'CUSTOMER',
    };

    await setup({}, {}, customerProfile);
    fixture.componentInstance.onTabChange('reviews');
    fixture.detectChanges();

    const element = fixture.nativeElement as HTMLElement;
    expect(element.textContent).not.toContain('Leave a review');
    expect(element.textContent).toContain('Edit your review');
    expect(fixture.componentInstance.canLeaveReview()).toBe(false);
    expect(fixture.componentInstance.canEditReview()).toBe(true);
    expect(element.textContent).toContain('By customer');
  });

  it('shows leave review when current user has not reviewed', async () => {
    const customerProfile: UserProfileResponseDto = {
      ...ownerProfile,
      id: 'customer-2',
      name: 'Other Customer',
      username: 'other',
      email: 'other@example.com',
      userType: 'CUSTOMER',
    };

    await setup({}, {}, customerProfile);
    fixture.componentInstance.onTabChange('reviews');
    fixture.detectChanges();

    const element = fixture.nativeElement as HTMLElement;
    expect(element.textContent).toContain('Leave a review');
    expect(element.textContent).not.toContain('Edit your review');
    expect(fixture.componentInstance.canLeaveReview()).toBe(true);
    expect(fixture.componentInstance.canEditReview()).toBe(false);
  });

  it('hides loyalty tab without loyalty entitlement', async () => {
    await setup({});

    const tabLabels = fixture.componentInstance.visibleTabs().map(tab => tab.label);
    expect(tabLabels).not.toContain('Loyalty');
  });

  it('shows loyalty tab when loyalty_basic is entitled', async () => {
    await setup({ loyalty_basic: true });

    const tabLabels = fixture.componentInstance.visibleTabs().map(tab => tab.label);
    expect(tabLabels).toContain('Loyalty');

    fixture.componentInstance.onTabChange('loyalty');
    fixture.detectChanges();

    expect(fixture.nativeElement.textContent).toContain('Basic Rewards');
  });
});
