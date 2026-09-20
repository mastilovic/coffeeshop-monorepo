import { ComponentFixture, TestBed } from '@angular/core/testing';
import { of, throwError } from 'rxjs';
import { SubscriptionPricingComponent } from './subscription-pricing.component';
import { SubscriptionAdminService } from '../../../services/subscription-admin.service';
import {
  FeatureCatalogItem,
  PlanTierCatalogItem,
} from '../../../models/subscription-admin.model';

describe('SubscriptionPricingComponent', () => {
  let fixture: ComponentFixture<SubscriptionPricingComponent>;
  let adminService: {
    getTiers: ReturnType<typeof vi.fn>;
    getFeatures: ReturnType<typeof vi.fn>;
    updateTiers: ReturnType<typeof vi.fn>;
    updateFeatures: ReturnType<typeof vi.fn>;
  };

  const tiers: PlanTierCatalogItem[] = [
    {
      tier: 'STARTER',
      displayName: 'Starter',
      basePriceMonthlyCents: 0,
      annualMonthsCharged: 12,
      isActive: true,
    },
    {
      tier: 'GROWTH',
      displayName: 'Growth',
      basePriceMonthlyCents: 2900,
      extraShopPriceCents: 1500,
      annualMonthsCharged: 12,
      isActive: true,
    },
    {
      tier: 'PRO',
      displayName: 'Pro',
      basePriceMonthlyCents: 4900,
      annualMonthsCharged: 12,
      isActive: true,
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
      limitValue: null,
      isSelectableCustom: true,
      sortOrder: 2,
      isActive: true,
    },
  ];

  beforeEach(async () => {
    adminService = {
      getTiers: vi.fn(() => of(tiers)),
      getFeatures: vi.fn(() => of(features)),
      updateTiers: vi.fn(() => of(tiers)),
      updateFeatures: vi.fn(() => of(features)),
    };

    await TestBed.configureTestingModule({
      imports: [SubscriptionPricingComponent],
      providers: [{ provide: SubscriptionAdminService, useValue: adminService }],
    }).compileComponents();

    fixture = TestBed.createComponent(SubscriptionPricingComponent);
    fixture.detectChanges();
  });

  it('loads and displays tier and feature pricing', () => {
    const element = fixture.nativeElement as HTMLElement;

    expect(adminService.getTiers).toHaveBeenCalled();
    expect(adminService.getFeatures).toHaveBeenCalled();
    expect(element.textContent).toContain('Starter');
    expect(element.textContent).toContain('Growth');
    expect(element.textContent).toContain('Reservation Management');
    expect(element.querySelector('[data-testid="tier-GROWTH"]')).toBeTruthy();
    expect(element.querySelector('[data-testid="feature-analytics"]')).toBeTruthy();
  });

  it('saves tier pricing via admin service', () => {
    const growthBase = fixture.nativeElement.querySelector(
      '#tier-base-GROWTH',
    ) as HTMLInputElement;
    growthBase.value = '3500';
    growthBase.dispatchEvent(new Event('input'));
    fixture.detectChanges();

    const saveButton = fixture.nativeElement.querySelector(
      '[data-testid="save-tiers"]',
    ) as HTMLButtonElement;
    saveButton.click();
    fixture.detectChanges();

    expect(adminService.updateTiers).toHaveBeenCalledWith(
      expect.arrayContaining([
        expect.objectContaining({
          tier: 'GROWTH',
          basePriceMonthlyCents: 3500,
        }),
      ]),
    );
    expect(fixture.nativeElement.textContent).toContain('Tier pricing saved.');
  });

  it('saves feature pricing via admin service', () => {
    const priceInput = fixture.nativeElement.querySelector(
      '#feature-price-analytics',
    ) as HTMLInputElement;
    priceInput.value = '1200';
    priceInput.dispatchEvent(new Event('input'));
    fixture.detectChanges();

    const saveButton = fixture.nativeElement.querySelector(
      '[data-testid="save-features"]',
    ) as HTMLButtonElement;
    saveButton.click();
    fixture.detectChanges();

    expect(adminService.updateFeatures).toHaveBeenCalledWith(
      expect.arrayContaining([
        expect.objectContaining({
          featureKey: 'analytics',
          monthlyPriceCents: 1200,
        }),
      ]),
    );
    expect(fixture.nativeElement.textContent).toContain('Feature pricing saved.');
  });

  it('shows error when catalog load fails', () => {
    adminService.getTiers.mockReturnValueOnce(
      throwError(() => ({ error: { message: 'Forbidden' } })),
    );

    fixture = TestBed.createComponent(SubscriptionPricingComponent);
    fixture.detectChanges();

    expect(fixture.nativeElement.textContent).toContain('Forbidden');
  });
});
