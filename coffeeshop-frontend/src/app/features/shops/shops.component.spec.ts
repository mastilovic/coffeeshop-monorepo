import { TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { RouterTestingHarness } from '@angular/router/testing';
import { signal } from '@angular/core';
import { of } from 'rxjs';
import { ShopsComponent } from './shops.component';
import { ShopService } from '../../services/shop.service';
import { AuthService } from '../../services/auth.service';
import { ProfileService } from '../../services/profile.service';
import { DialogService } from '../../services/dialog.service';
import { ShopResponseDto, ShopSearchParams } from '../../models/shop.model';
import { UserProfileResponseDto } from '../../models/user.model';

describe('ShopsComponent recent reviews', () => {
  const profile: UserProfileResponseDto = {
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

  function shop(overrides: Partial<ShopResponseDto>): ShopResponseDto {
    return {
      id: 'shop',
      name: 'Shop',
      address: '1 Main',
      city: 'Town',
      phoneNumber: '555',
      email: 'shop@example.com',
      createdBy: { id: 'other', name: 'Other', username: 'other' },
      users: [],
      currentMenu: null,
      menuHistory: [],
      loyaltyPlan: {} as ShopResponseDto['loyaltyPlan'],
      events: [],
      tables: [],
      reviews: [],
      reviewCount: 0,
      recentReviewCount: 0,
      averageRating: null,
      contacts: [],
      ...overrides,
    };
  }

  const plain = shop({ id: 'plain', name: 'Plain Shop' });
  const rated = shop({
    id: 'rated',
    name: 'Rated Shop',
    reviewCount: 2,
    recentReviewCount: 2,
    averageRating: 4.5,
  });

  let search: ReturnType<typeof vi.fn>;

  beforeEach(async () => {
    search = vi.fn((params: ShopSearchParams) => of({
      content: params.recentReviews === 30 ? [plain, rated] : [plain, rated],
      page: 0,
      size: 10,
      totalElements: 2,
      totalPages: 1,
    }));

    await TestBed.configureTestingModule({
      providers: [
        provideRouter([{ path: 'shops', component: ShopsComponent }]),
        { provide: ShopService, useValue: { search } },
        { provide: AuthService, useValue: { isAdmin: vi.fn(() => false) } },
        { provide: ProfileService, useValue: { currentUser: signal(profile) } },
        { provide: DialogService, useValue: { alert: vi.fn(), confirm: vi.fn() } },
      ],
    }).compileComponents();
  });

  it('badges and sorts recent reviews, then clears the query', async () => {
    const harness = await RouterTestingHarness.create();
    await harness.navigateByUrl('/shops?recentReviews=30', ShopsComponent);

    expect(search).toHaveBeenCalledWith(expect.objectContaining({ recentReviews: 30 }));

    const titles = [...harness.routeNativeElement!.querySelectorAll('.shop-card__title')]
      .map(node => node.textContent ?? '');
    expect(titles[0]).toContain('Rated Shop');
    expect(titles[1]).toContain('Plain Shop');
    expect(harness.routeNativeElement!.textContent).toContain('4.5 (2)');
    expect(harness.routeNativeElement!.textContent).toContain('2 new');
    expect(harness.routeNativeElement!.textContent).toContain('No rating yet');
    expect(harness.routeNativeElement!.textContent).not.toContain('0 new');

    harness.routeNativeElement!.querySelector<HTMLButtonElement>('.recent-reviews-chip')!.click();
    await harness.fixture.whenStable();
    harness.detectChanges();

    const lastCall = search.mock.calls.at(-1)?.[0] as ShopSearchParams;
    expect(lastCall.recentReviews).toBeUndefined();
    expect(harness.routeNativeElement!.querySelector('.recent-reviews-chip')).toBeNull();
    expect(harness.routeNativeElement!.textContent).not.toContain('2 new');
    expect(harness.routeNativeElement!.textContent).toContain('No rating yet');
  });
});
