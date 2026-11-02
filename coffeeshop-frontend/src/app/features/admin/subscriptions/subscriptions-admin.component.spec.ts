import { ComponentFixture, TestBed } from '@angular/core/testing';
import { of, throwError } from 'rxjs';
import { SubscriptionsAdminComponent } from './subscriptions-admin.component';
import { SubscriptionAdminService } from '../../../services/subscription-admin.service';
import {
  FeatureCatalogItem,
  OwnerSubscriptionListItem,
} from '../../../models/subscription-admin.model';

describe('SubscriptionsAdminComponent', () => {
  let fixture: ComponentFixture<SubscriptionsAdminComponent>;
  let adminService: {
    getFeatures: ReturnType<typeof vi.fn>;
    listOwners: ReturnType<typeof vi.fn>;
    overrideOwnerPlan: ReturnType<typeof vi.fn>;
  };

  const owners: OwnerSubscriptionListItem[] = [
    {
      id: 'owner-1',
      name: 'Alice Owner',
      username: 'alice',
      email: 'alice@example.com',
      planMode: 'PRESET',
      planTier: 'GROWTH',
      status: 'active',
      shopsUsed: 2,
      lockedMonthlyAmountCents: 2900,
    },
    {
      id: 'owner-2',
      name: 'Bob Owner',
      username: 'bob',
      email: 'bob@example.com',
      planMode: 'CUSTOM',
      status: 'trialing',
      shopsUsed: 1,
      lockedMonthlyAmountCents: 1500,
    },
  ];

  const features: FeatureCatalogItem[] = [
    {
      featureKey: 'reservation_manage',
      displayName: 'Reservation Management',
      monthlyPriceCents: 500,
      isSelectableCustom: true,
      sortOrder: 1,
      isActive: true,
    },
    {
      featureKey: 'analytics',
      displayName: 'Analytics',
      monthlyPriceCents: 1000,
      isSelectableCustom: true,
      sortOrder: 2,
      isActive: true,
    },
  ];

  beforeEach(async () => {
    adminService = {
      getFeatures: vi.fn(() => of(features)),
      listOwners: vi.fn(() =>
        of({
          content: owners,
          page: 0,
          size: 20,
          totalElements: 2,
          totalPages: 1,
        }),
      ),
      overrideOwnerPlan: vi.fn(() =>
        of({
          userId: 'owner-1',
          planMode: 'PRESET',
          planTier: 'PRO',
          status: 'active',
          lockedMonthlyAmountCents: 4900,
        }),
      ),
    };

    await TestBed.configureTestingModule({
      imports: [SubscriptionsAdminComponent],
      providers: [{ provide: SubscriptionAdminService, useValue: adminService }],
    }).compileComponents();

    fixture = TestBed.createComponent(SubscriptionsAdminComponent);
    fixture.detectChanges();
  });

  it('lists owners with plan details', () => {
    const element = fixture.nativeElement as HTMLElement;

    expect(adminService.listOwners).toHaveBeenCalled();
    expect(element.textContent).toContain('Alice Owner');
    expect(element.textContent).toContain('@alice');
    expect(element.textContent).not.toContain('alice@example.com');
    expect(element.textContent).toContain('GROWTH');
    expect(element.querySelector('[data-testid="owner-owner-1"]')).toBeTruthy();
  });

  it('opens override form and saves via admin service', () => {
    const overrideBtn = fixture.nativeElement.querySelector(
      '[data-testid="override-btn"]',
    ) as HTMLButtonElement;
    overrideBtn.click();
    fixture.detectChanges();

    expect(fixture.nativeElement.querySelector('[data-testid="override-form"]')).toBeTruthy();

    const saveBtn = fixture.nativeElement.querySelector(
      '[data-testid="save-override"]',
    ) as HTMLButtonElement;
    saveBtn.click();
    fixture.detectChanges();

    expect(adminService.overrideOwnerPlan).toHaveBeenCalledWith('owner-1', {
      planMode: 'PRESET',
      planTier: 'GROWTH',
      features: [],
      billingInterval: 'monthly',
      status: 'active',
    });
    expect(fixture.nativeElement.textContent).toContain('Subscription override saved.');
  });

  it('shows error when override fails', () => {
    adminService.overrideOwnerPlan.mockReturnValueOnce(
      throwError(() => ({ error: { message: 'Invalid plan' } })),
    );

    const overrideBtn = fixture.nativeElement.querySelector(
      '[data-testid="override-btn"]',
    ) as HTMLButtonElement;
    overrideBtn.click();
    fixture.detectChanges();

    const saveBtn = fixture.nativeElement.querySelector(
      '[data-testid="save-override"]',
    ) as HTMLButtonElement;
    saveBtn.click();
    fixture.detectChanges();

    expect(fixture.nativeElement.textContent).toContain('Invalid plan');
  });
});
