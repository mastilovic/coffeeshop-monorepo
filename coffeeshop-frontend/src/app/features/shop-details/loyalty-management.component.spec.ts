import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { of } from 'rxjs';
import { LoyaltyManagementComponent } from './loyalty-management.component';
import { LoyaltyPlanService } from '../../services/loyalty-plan.service';
import { ShopService } from '../../services/shop.service';
import { SubscriptionService } from '../../services/subscription.service';
import { LoyaltyPlanResponseDto } from '../../models/loyalty-plan.model';
import { ShopResponseDto } from '../../models/shop.model';

describe('LoyaltyManagementComponent', () => {
  let fixture: ComponentFixture<LoyaltyManagementComponent>;
  let canUseFeatureMock: ReturnType<typeof vi.fn>;
  let createPlanMock: ReturnType<typeof vi.fn>;
  let updatePlanMock: ReturnType<typeof vi.fn>;
  let updateShopMock: ReturnType<typeof vi.fn>;

  const shopFields = {
    name: 'Test Cafe',
    address: '1 Main St',
    city: 'Berlin',
    phoneNumber: '123',
    email: 'cafe@example.com',
  };

  const existingPlan: LoyaltyPlanResponseDto = {
    id: 'loyalty-1',
    name: 'Basic Rewards',
    description: 'Earn points on every visit',
    type: 'BASIC',
  };

  const updatedShop = {
    id: 'shop-1',
    ...shopFields,
    loyaltyPlan: existingPlan,
  } as ShopResponseDto;

  async function setup(
    entitlements: Record<string, boolean>,
    loyaltyPlan: LoyaltyPlanResponseDto | null = null,
  ): Promise<void> {
    canUseFeatureMock = vi.fn((featureKey: string) => entitlements[featureKey] ?? false);
    createPlanMock = vi.fn(() => of({
      id: 'loyalty-new',
      name: 'New Rewards',
      description: 'Points on every purchase',
      type: 'BASIC',
    }));
    updatePlanMock = vi.fn(() => of({
      ...existingPlan,
      name: 'Updated Rewards',
    }));
    updateShopMock = vi.fn(() => of(updatedShop));

    await TestBed.configureTestingModule({
      imports: [LoyaltyManagementComponent],
      providers: [
        provideRouter([]),
        {
          provide: SubscriptionService,
          useValue: { canUseFeature: canUseFeatureMock },
        },
        {
          provide: LoyaltyPlanService,
          useValue: {
            create: createPlanMock,
            update: updatePlanMock,
          },
        },
        {
          provide: ShopService,
          useValue: { update: updateShopMock },
        },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(LoyaltyManagementComponent);
    fixture.componentRef.setInput('shopId', 'shop-1');
    fixture.componentRef.setInput('shopFields', shopFields);
    fixture.componentRef.setInput('loyaltyPlan', loyaltyPlan);
    fixture.detectChanges();
  }

  it('shows enable form with BASIC tier when loyalty_basic is entitled', async () => {
    await setup({ loyalty_basic: true });

    const element = fixture.nativeElement as HTMLElement;
    expect(element.textContent).toContain('Enable loyalty program');
    expect(fixture.componentInstance.typeSelectOptions().map(option => option.value)).toEqual(['BASIC']);
    expect(element.textContent).toContain('Upgrade to Pro');
  });

  it('shows PREMIUM and VIP tiers when loyalty_premium is entitled', async () => {
    await setup({ loyalty_basic: true, loyalty_premium: true });

    expect(fixture.componentInstance.typeSelectOptions().map(option => option.value)).toEqual([
      'BASIC',
      'PREMIUM',
      'VIP',
    ]);
    expect(fixture.nativeElement.querySelector('a[routerlink="/profile/billing"]')).toBeNull();
  });

  it('creates a BASIC plan and links it to the shop', async () => {
    await setup({ loyalty_basic: true });

    fixture.componentInstance.form.patchValue({
      name: 'New Rewards',
      description: 'Points on every purchase',
      type: 'BASIC',
    });
    fixture.componentInstance.onSubmit();
    await fixture.whenStable();
    fixture.detectChanges();

    expect(createPlanMock).toHaveBeenCalledWith({
      name: 'New Rewards',
      description: 'Points on every purchase',
      type: 'BASIC',
    });
    expect(updateShopMock).toHaveBeenCalledWith('shop-1', {
      ...shopFields,
      loyaltyPlanId: 'loyalty-new',
    });
  });

  it('shows configured plan and updates it when editing', async () => {
    await setup({ loyalty_basic: true }, existingPlan);

    const element = fixture.nativeElement as HTMLElement;
    expect(element.textContent).toContain('Basic Rewards');
    expect(element.textContent).not.toContain('Enable loyalty program');

    fixture.componentInstance.startEditing();
    fixture.detectChanges();

    fixture.componentInstance.form.patchValue({ name: 'Updated Rewards' });
    fixture.componentInstance.onSubmit();
    await fixture.whenStable();
    fixture.detectChanges();

    expect(updatePlanMock).toHaveBeenCalledWith('loyalty-1', {
      name: 'Updated Rewards',
      description: 'Earn points on every visit',
      type: 'BASIC',
    });
    expect(updateShopMock).toHaveBeenCalled();
  });

  it('blocks PREMIUM selection without loyalty_premium entitlement', async () => {
    await setup({ loyalty_basic: true });

    fixture.componentInstance.form.patchValue({
      name: 'VIP Club',
      description: 'Exclusive perks',
      type: 'PREMIUM',
    });
    fixture.componentInstance.onSubmit();
    fixture.detectChanges();

    expect(createPlanMock).not.toHaveBeenCalled();
    expect(fixture.nativeElement.textContent).toContain('not included in your subscription');
  });
});
