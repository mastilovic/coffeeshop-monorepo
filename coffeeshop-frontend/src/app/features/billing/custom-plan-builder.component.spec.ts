import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { signal } from '@angular/core';
import { of, throwError } from 'rxjs';
import { CustomPlanBuilderComponent } from './custom-plan-builder.component';
import { SubscriptionService } from '../../services/subscription.service';
import { ProfileService } from '../../services/profile.service';
import {
  CatalogResponse,
  QuoteBreakdown,
  SubscriptionMeResponse,
  SubscriptionSummary,
} from '../../models/subscription.model';

describe('CustomPlanBuilderComponent', () => {
  let fixture: ComponentFixture<CustomPlanBuilderComponent>;
  let quoteMock: ReturnType<typeof vi.fn>;
  let changePlanMock: ReturnType<typeof vi.fn>;

  const mockCatalog: CatalogResponse = {
    tiers: [
      {
        tier: 'GROWTH',
        displayName: 'Growth',
        basePriceMonthlyCents: 2900,
        extraShopPriceCents: 1500,
        annualMonthsCharged: 12,
        isActive: true,
        includedFeatures: [],
      },
    ],
    features: [
      {
        featureKey: 'reservation_manage',
        displayName: 'Reservation management',
        monthlyPriceCents: 800,
        isSelectableCustom: true,
        sortOrder: 10,
        isActive: true,
      },
      {
        featureKey: 'event_create',
        displayName: 'Events',
        monthlyPriceCents: 1000,
        isSelectableCustom: true,
        sortOrder: 20,
        isActive: true,
      },
      {
        featureKey: 'analytics',
        displayName: 'Analytics',
        monthlyPriceCents: 1500,
        isSelectableCustom: false,
        sortOrder: 90,
        isActive: true,
      },
    ],
  };

  const baseQuote: QuoteBreakdown = {
    baseMonthlyCents: 0,
    extraShopsCents: 0,
    featuresMonthlyCents: 0,
    monthlyTotalCents: 0,
    annualTotalCents: 0,
    annualMonthsCharged: 12,
    lineItems: [],
  };

  const meResponse: SubscriptionMeResponse = {
    planMode: 'PRESET',
    planTier: 'STARTER',
    status: 'active',
    billingInterval: 'monthly',
    shopsIncluded: 1,
    shopsUsed: 1,
    lockedMonthlyAmountCents: 0,
    entitlements: {},
    limits: {},
  };

  function quoteFor(featuresMonthlyCents: number): QuoteBreakdown {
    return {
      ...baseQuote,
      featuresMonthlyCents,
      monthlyTotalCents: featuresMonthlyCents,
      annualTotalCents: featuresMonthlyCents * 12,
      lineItems:
        featuresMonthlyCents > 0
          ? [{ key: 'feature', label: 'Feature', amountCents: featuresMonthlyCents }]
          : [],
    };
  }

  beforeEach(async () => {
    quoteMock = vi.fn(() => of(quoteFor(0)));
    changePlanMock = vi.fn(() =>
      of({
        ...meResponse,
        planMode: 'CUSTOM' as const,
        features: ['reservation_manage'],
      }),
    );

    const subscriptionSummary = signal<SubscriptionSummary | null>({
      planMode: 'PRESET',
      planTier: 'STARTER',
      status: 'active',
      shopsIncluded: 1,
      shopsUsed: 1,
      monthlyAmountCents: 0,
    });

    await TestBed.configureTestingModule({
      imports: [CustomPlanBuilderComponent],
      providers: [
        provideRouter([]),
        {
          provide: SubscriptionService,
          useValue: {
            subscription: subscriptionSummary,
            getCatalog: vi.fn(() => of(mockCatalog)),
            getMe: vi.fn(() => of(meResponse)),
            quote: quoteMock,
            changePlan: changePlanMock,
          },
        },
        {
          provide: ProfileService,
          useValue: {
            getProfile: vi.fn(() => of(null)),
          },
        },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(CustomPlanBuilderComponent);
    fixture.detectChanges();
  });

  async function waitForCatalog(): Promise<void> {
    await fixture.whenStable();
    fixture.detectChanges();
  }

  it('renders only selectable custom features', async () => {
    await waitForCatalog();

    const featureCheckboxes = fixture.nativeElement.querySelectorAll('.feature-checkbox');
    expect(featureCheckboxes.length).toBe(2);
    expect(fixture.nativeElement.textContent).toContain('Reservation management');
    expect(fixture.nativeElement.textContent).toContain('Events');
    expect(fixture.nativeElement.textContent).not.toContain('Analytics');
  });

  it('requests quote on load and when features change', async () => {
    await waitForCatalog();
    quoteMock.mockClear();

    const reservationCheckbox: HTMLInputElement = fixture.nativeElement.querySelector(
      '[data-testid="feature-reservation_manage"]',
    );
    reservationCheckbox.click();
    fixture.detectChanges();
    await fixture.whenStable();

    expect(quoteMock).toHaveBeenCalled();
    const lastCall = quoteMock.mock.calls.at(-1)?.[0];
    expect(lastCall).toEqual({
      planMode: 'CUSTOM',
      features: ['reservation_manage'],
      shopCount: 1,
      billingInterval: 'monthly',
    });
  });

  it('updates quote when shop count changes', async () => {
    await waitForCatalog();
    quoteMock.mockClear();

    const shopCountInput: HTMLInputElement =
      fixture.nativeElement.querySelector('[data-testid="shop-count"]');
    shopCountInput.value = '3';
    shopCountInput.dispatchEvent(new Event('input'));
    shopCountInput.dispatchEvent(new Event('change'));
    fixture.detectChanges();
    await fixture.whenStable();

    const lastCall = quoteMock.mock.calls.at(-1)?.[0];
    expect(lastCall?.shopCount).toBe(3);
  });

  it('updates quote when annual toggle changes', async () => {
    await waitForCatalog();
    quoteMock.mockClear();

    const annualToggle: HTMLInputElement =
      fixture.nativeElement.querySelector('[data-testid="annual-toggle"]');
    annualToggle.click();
    fixture.detectChanges();
    await fixture.whenStable();

    const lastCall = quoteMock.mock.calls.at(-1)?.[0];
    expect(lastCall?.billingInterval).toBe('annual');
    expect(fixture.nativeElement.querySelector('[data-testid="quote-total"]')?.textContent).toBeTruthy();
  });

  it('displays quote total from service response', async () => {
    quoteMock.mockImplementation(() => of(quoteFor(1800)));
    fixture = TestBed.createComponent(CustomPlanBuilderComponent);
    fixture.detectChanges();
    await waitForCatalog();

    const total = fixture.nativeElement.querySelector('[data-testid="quote-total"]');
    expect(total?.textContent).toContain('$18.00');
  });

  it('applies custom plan via subscription service', async () => {
    await waitForCatalog();

    const reservationCheckbox: HTMLInputElement = fixture.nativeElement.querySelector(
      '[data-testid="feature-reservation_manage"]',
    );
    reservationCheckbox.click();
    fixture.detectChanges();
    await fixture.whenStable();

    const applyButton: HTMLButtonElement =
      fixture.nativeElement.querySelector('[data-testid="apply-plan"]');
    applyButton.click();
    fixture.detectChanges();
    await fixture.whenStable();

    expect(changePlanMock).toHaveBeenCalledWith({
      planMode: 'CUSTOM',
      features: ['reservation_manage'],
      billingInterval: 'monthly',
    });
    expect(fixture.nativeElement.querySelector('[data-testid="apply-success"]')).toBeTruthy();
  });

  it('shows error when quote request fails', async () => {
    quoteMock.mockImplementation(() => throwError(() => new Error('quote failed')));
    fixture = TestBed.createComponent(CustomPlanBuilderComponent);
    fixture.detectChanges();
    await waitForCatalog();

    expect(fixture.nativeElement.textContent).toContain('Unable to load quote.');
  });
});
