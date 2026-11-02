import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  input,
  OnInit,
  output,
  signal,
} from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { FormSelectComponent } from '../../shared/form-select/form-select.component';
import { FormSelectOption } from '../../shared/form-select/form-select-option.model';
import {
  LoyaltyPlanCreateRequest,
  LoyaltyPlanResponseDto,
  LoyaltyPlanType,
  LOYALTY_PLAN_TYPES,
} from '../../models/loyalty-plan.model';
import { ShopUpdateRequest } from '../../models/shop.model';
import { LoyaltyPlanService } from '../../services/loyalty-plan.service';
import { ShopService } from '../../services/shop.service';
import { SubscriptionService } from '../../services/subscription.service';

export interface LoyaltyShopFields {
  name: string;
  address: string;
  city: string;
  phoneNumber: string;
  email: string;
}

@Component({
  selector: 'app-loyalty-management',
  standalone: true,
  imports: [ReactiveFormsModule, RouterLink, FormSelectComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="loyalty-management">
      <h3 class="mb-2">Loyalty program</h3>
      <p class="text-muted section-hint">
        Reward regular customers with a shop loyalty plan. Growth includes Basic; Pro unlocks Premium and VIP tiers.
      </p>

      @if (hasConfiguredPlan() && !editing()) {
        <div class="form-card mb-3">
          <p class="plan-name">{{ loyaltyPlan()!.name }}</p>
          @if (loyaltyPlan()!.description) {
            <p class="text-muted plan-description">{{ loyaltyPlan()!.description }}</p>
          }
          <span class="badge badge-joined">{{ formatPlanType(loyaltyPlan()!.type) }}</span>
          <div class="form-actions mt-3">
            <button type="button" class="btn btn-secondary" (click)="startEditing()">Edit plan</button>
          </div>
        </div>
      } @else {
        <div class="form-card">
          <form [formGroup]="form" (ngSubmit)="onSubmit()">
            <div class="form-group">
              <label for="loyalty-name">Plan name</label>
              <input id="loyalty-name" class="form-input" formControlName="name" placeholder="e.g. Regulars Rewards" />
            </div>
            <div class="form-group">
              <label for="loyalty-description">Description</label>
              <textarea
                id="loyalty-description"
                class="form-input"
                rows="3"
                formControlName="description"
                placeholder="Describe how customers earn and redeem rewards"
              ></textarea>
            </div>
            <div class="form-group">
              <label>Plan tier</label>
              <app-form-select
                formControlName="type"
                placeholder="Select tier"
                [options]="typeSelectOptions()"
              />
              @if (showPremiumUpgrade()) {
                <p class="upgrade-hint">
                  Premium and VIP tiers require Pro.
                  <a routerLink="/profile/billing" class="upgrade-link">Upgrade to Pro</a>
                </p>
              }
            </div>
            <div class="form-actions">
              <button type="submit" class="btn btn-primary" [disabled]="form.invalid || saving()">
                {{ saving() ? 'Saving...' : (hasConfiguredPlan() ? 'Update plan' : 'Enable loyalty program') }}
              </button>
              @if (hasConfiguredPlan()) {
                <button type="button" class="btn btn-secondary" (click)="cancelEditing()">Cancel</button>
              }
            </div>
            @if (saveError()) {
              <p class="form-error">{{ saveError() }}</p>
            }
          </form>
        </div>
      }
    </div>
  `,
  styles: [`
    .loyalty-management {
      max-width: 36rem;
    }

    .section-hint {
      font-size: 0.875rem;
      margin: 0 0 1rem;
    }

    .plan-name {
      font-weight: 600;
      margin: 0 0 0.5rem;
    }

    .plan-description {
      margin: 0 0 0.75rem;
    }

    .upgrade-hint {
      margin: 0.5rem 0 0;
      font-size: 0.8125rem;
      color: #9ca3af;
    }

    .upgrade-link {
      font-weight: 600;
      color: #d4a574;
      text-decoration: none;
      margin-left: 0.25rem;
    }

    .upgrade-link:hover {
      text-decoration: underline;
    }

    .form-error {
      margin: 0.75rem 0 0;
      color: #f87171;
      font-size: 0.8125rem;
    }

    .mt-3 {
      margin-top: 0.75rem;
    }
  `],
})
export class LoyaltyManagementComponent implements OnInit {
  private readonly fb = inject(FormBuilder);
  private readonly loyaltyPlanService = inject(LoyaltyPlanService);
  private readonly shopService = inject(ShopService);
  private readonly subscriptionService = inject(SubscriptionService);

  readonly shopId = input.required<string>();
  readonly shopFields = input.required<LoyaltyShopFields>();
  readonly loyaltyPlan = input<LoyaltyPlanResponseDto | null>(null);

  readonly loyaltyPlanChange = output<LoyaltyPlanResponseDto>();

  readonly editing = signal(false);
  readonly saving = signal(false);
  readonly saveError = signal<string | null>(null);

  readonly form = this.fb.nonNullable.group({
    name: ['', Validators.required],
    description: [''],
    type: ['' as LoyaltyPlanType, Validators.required],
  });

  readonly hasConfiguredPlan = computed(() => {
    const plan = this.loyaltyPlan();
    return !!plan?.id && !!plan?.name;
  });

  readonly canUseBasic = computed(() =>
    this.subscriptionService.canUseFeature('loyalty_basic'),
  );

  readonly canUsePremium = computed(() =>
    this.subscriptionService.canUseFeature('loyalty_premium'),
  );

  readonly availableTypes = computed((): LoyaltyPlanType[] => {
    const types: LoyaltyPlanType[] = [];
    if (this.canUseBasic()) types.push('BASIC');
    if (this.canUsePremium()) {
      types.push('PREMIUM', 'VIP');
    }
    return types;
  });

  readonly typeSelectOptions = computed((): FormSelectOption[] =>
    LOYALTY_PLAN_TYPES
      .filter(option => this.availableTypes().includes(option.value))
      .map(option => ({ value: option.value, label: option.label })),
  );

  readonly showPremiumUpgrade = computed(() =>
    this.canUseBasic() && !this.canUsePremium(),
  );

  ngOnInit(): void {
    this.resetFormFromPlan();
  }

  formatPlanType(type: string): string {
    return LOYALTY_PLAN_TYPES.find(option => option.value === type)?.label ?? type;
  }

  startEditing(): void {
    this.editing.set(true);
    this.resetFormFromPlan();
    this.saveError.set(null);
  }

  cancelEditing(): void {
    this.editing.set(false);
    this.resetFormFromPlan();
    this.saveError.set(null);
  }

  onSubmit(): void {
    if (this.form.invalid || !this.canUseSelectedType()) {
      this.saveError.set('Selected plan tier is not included in your subscription.');
      return;
    }

    const payload = this.form.getRawValue() as LoyaltyPlanCreateRequest;
    const existing = this.loyaltyPlan();
    this.saving.set(true);
    this.saveError.set(null);

    const planOp = existing?.id
      ? this.loyaltyPlanService.update(existing.id, payload)
      : this.loyaltyPlanService.create(payload);

    planOp.subscribe({
      next: plan => this.linkPlanToShop(plan),
      error: () => {
        this.saving.set(false);
        this.saveError.set('Unable to save loyalty plan. Check your plan entitlements and try again.');
      },
    });
  }

  private canUseSelectedType(): boolean {
    const type = this.form.controls.type.value;
    if (type === 'BASIC') return this.canUseBasic();
    if (type === 'PREMIUM' || type === 'VIP') return this.canUsePremium();
    return false;
  }

  private linkPlanToShop(plan: LoyaltyPlanResponseDto): void {
    const updateRequest: ShopUpdateRequest = {
      ...this.shopFields(),
      loyaltyPlanId: plan.id,
    };

    this.shopService.update(this.shopId(), updateRequest).subscribe({
      next: () => {
        this.saving.set(false);
        this.editing.set(false);
        this.loyaltyPlanChange.emit(plan);
      },
      error: () => {
        this.saving.set(false);
        this.saveError.set('Loyalty plan saved but could not be linked to this shop.');
      },
    });
  }

  private resetFormFromPlan(): void {
    const plan = this.loyaltyPlan();
    const defaultType = this.availableTypes()[0] ?? ('' as LoyaltyPlanType);

    if (plan?.id) {
      this.form.reset({
        name: plan.name,
        description: plan.description ?? '',
        type: this.availableTypes().includes(plan.type as LoyaltyPlanType)
          ? (plan.type as LoyaltyPlanType)
          : defaultType,
      });
      return;
    }

    this.form.reset({
      name: '',
      description: '',
      type: defaultType,
    });
  }
}
