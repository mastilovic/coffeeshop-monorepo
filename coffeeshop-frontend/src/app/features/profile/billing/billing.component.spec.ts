import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { of, throwError } from 'rxjs';
import { signal } from '@angular/core';
import { BillingComponent } from './billing.component';
import { SubscriptionService } from '../../../services/subscription.service';
import { ProfileService } from '../../../services/profile.service';
import {
  CatalogResponse,
  CatalogTier,
  SubscriptionMeResponse,
  SubscriptionSummary,
} from '../../../models/subscription.model';

describe('BillingComponent', () => {
  let fixture: ComponentFixture<BillingComponent>;
  let subscriptionService: {
    subscription: ReturnType<typeof signal<SubscriptionSummary | null>>;
    limits: ReturnType<typeof signal<Record<string, { used: number; max: number }>>>;
    getCatalog: ReturnType<typeof vi.fn>;
    changePlan: ReturnType<typeof vi.fn>;
  };

  const catalogTiers: CatalogTier[] = [
    {
      tier: 'STARTER',
      displayName: 'Starter',
      basePriceMonthlyCents: 0,
      annualMonthsCharged: 12,
      isActive: true,
      includedFeatures: ['dashboard_notifications'],
    },
    {
      tier: 'GROWTH',
      displayName: 'Growth',
      basePriceMonthlyCents: 2900,
      annualMonthsCharged: 12,
      isActive: true,
      includedFeatures: ['reservation_manage', 'event_create'],
    },
    {
      tier: 'PRO',
      displayName: 'Pro',
      basePriceMonthlyCents: 4900,
      annualMonthsCharged: 12,
      isActive: true,
      includedFeatures: ['analytics', 'loyalty_premium'],
    },
  ];

  const catalog: CatalogResponse = {
    tiers: catalogTiers,
    features: [],
  };

  const growthSubscription: SubscriptionSummary = {
    planMode: 'PRESET',
    planTier: 'GROWTH',
    status: 'active',
    shopsIncluded: 1,
    shopsUsed: 1,
    monthlyAmountCents: 2900,
  };

  beforeEach(async () => {
    subscriptionService = {
      subscription: signal<SubscriptionSummary | null>(growthSubscription),
      limits: signal({
        tables: { used: 5, max: 15 },
        events: { used: 2, max: 5 },
      }),
      getCatalog: vi.fn(() => of(catalog)),
      changePlan: vi.fn(() =>
        of({
          planMode: 'PRESET',
          planTier: 'PRO',
          status: 'active',
          shopsIncluded: 1,
          shopsUsed: 1,
          lockedMonthlyAmountCents: 4900,
          entitlements: {},
        } satisfies SubscriptionMeResponse),
      ),
    };

    await TestBed.configureTestingModule({
      imports: [BillingComponent],
      providers: [
        provideRouter([]),
        { provide: SubscriptionService, useValue: subscriptionService },
        {
          provide: ProfileService,
          useValue: { getProfile: vi.fn(() => of({})) },
        },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(BillingComponent);
    fixture.detectChanges();
  });

  it('displays current plan and usage bars', () => {
    const element = fixture.nativeElement as HTMLElement;

    expect(element.textContent).toContain('Growth');
    expect(element.textContent).toContain('Tables');
    expect(element.textContent).toContain('5 / 15');
    expect(element.textContent).toContain('Events (monthly)');
    expect(element.textContent).toContain('2 / 5');

    const progressBars = element.querySelectorAll('[role="progressbar"]');
    expect(progressBars.length).toBe(2);
  });

  it('renders preset tier cards from catalog', () => {
    const element = fixture.nativeElement as HTMLElement;

    expect(subscriptionService.getCatalog).toHaveBeenCalled();
    expect(element.textContent).toContain('Starter');
    expect(element.textContent).toContain('Growth');
    expect(element.textContent).toContain('Pro');
    expect(element.textContent).toContain('$29');
    expect(element.textContent).toContain('$49');
  });

  it('marks current tier and links to custom plan builder', () => {
    const element = fixture.nativeElement as HTMLElement;
    const growthCard = Array.from(element.querySelectorAll('.billing-tier')).find(card =>
      card.textContent?.includes('Growth'),
    );

    expect(growthCard?.classList.contains('billing-tier--current')).toBe(true);
    expect(element.querySelector('a[routerlink="/profile/billing/custom"]')).toBeTruthy();
  });

  it('changes plan via subscription service', () => {
    const proButton = Array.from(
      fixture.nativeElement.querySelectorAll('button') as NodeListOf<HTMLButtonElement>,
    ).find(button => button.textContent?.includes('Select Pro'));

    proButton!.click();
    fixture.detectChanges();

    expect(subscriptionService.changePlan).toHaveBeenCalledWith({
      planMode: 'PRESET',
      planTier: 'PRO',
      billingInterval: 'monthly',
    });
    expect(fixture.nativeElement.textContent).toContain('Plan updated successfully.');
  });

  it('shows error when catalog load fails', () => {
    subscriptionService.getCatalog.mockReturnValueOnce(
      throwError(() => ({ error: { message: 'Catalog unavailable' } })),
    );

    fixture = TestBed.createComponent(BillingComponent);
    fixture.detectChanges();

    expect(fixture.nativeElement.textContent).toContain('Catalog unavailable');
  });
});
