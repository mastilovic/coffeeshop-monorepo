import { CurrencyPipe } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  inject,
  OnInit,
  signal,
} from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { forkJoin } from 'rxjs';
import { FeatureCatalogItem, PlanTierCatalogItem } from '../../../models/subscription-admin.model';
import { PlanTier } from '../../../models/subscription.model';
import { SubscriptionAdminService } from '../../../services/subscription-admin.service';

const TIER_ORDER: PlanTier[] = ['STARTER', 'GROWTH', 'PRO'];

@Component({
  selector: 'app-subscription-pricing',
  standalone: true,
  imports: [ReactiveFormsModule, CurrencyPipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="page">
      <div class="page-header">
        <h1 class="page-title">Subscription Pricing</h1>
        <p class="page-subtitle text-muted">Edit tier base prices and à-la-carte feature pricing.</p>
      </div>

      @if (loading()) {
        <div class="loading">Loading pricing catalog...</div>
      } @else {
        @if (errorMessage()) {
          <div class="error-message">{{ errorMessage() }}</div>
        }
        @if (successMessage()) {
          <div class="success-message">{{ successMessage() }}</div>
        }

        <section class="pricing-section" aria-labelledby="tiers-heading">
          <div class="pricing-section__header">
            <h2 id="tiers-heading" class="section-title">Plan Tiers</h2>
            <button
              type="button"
              class="btn btn-primary btn-sm"
              data-testid="save-tiers"
              [disabled]="savingTiers()"
              (click)="saveTiers()"
            >
              {{ savingTiers() ? 'Saving...' : 'Save Tiers' }}
            </button>
          </div>

          <div class="pricing-grid">
            @for (tier of tiers(); track tier.tier) {
              <article class="card pricing-card" [attr.data-testid]="'tier-' + tier.tier">
                <h3 class="pricing-card__name">{{ tier.displayName }}</h3>
                <span class="pricing-card__key text-muted">{{ tier.tier }}</span>

                <div class="form-group">
                  <label [for]="'tier-name-' + tier.tier">Display Name</label>
                  <input
                    class="form-input"
                    [id]="'tier-name-' + tier.tier"
                    [formControl]="tierControls[tier.tier].controls.displayName"
                  />
                </div>

                <div class="form-row">
                  <div class="form-group">
                    <label [for]="'tier-base-' + tier.tier">Base Price (cents)</label>
                    <input
                      class="form-input"
                      type="number"
                      min="0"
                      [id]="'tier-base-' + tier.tier"
                      [formControl]="tierControls[tier.tier].controls.basePriceMonthlyCents"
                    />
                    <span class="field-hint text-muted">
                      {{ tierControls[tier.tier].controls.basePriceMonthlyCents.value / 100 | currency: 'USD' : 'symbol' : '1.0-2' }}/mo
                    </span>
                  </div>
                  <div class="form-group">
                    <label [for]="'tier-extra-' + tier.tier">Extra Shop (cents)</label>
                    <input
                      class="form-input"
                      type="number"
                      min="0"
                      [id]="'tier-extra-' + tier.tier"
                      [formControl]="tierControls[tier.tier].controls.extraShopPriceCents"
                    />
                  </div>
                </div>

                <div class="form-row">
                  <div class="form-group">
                    <label [for]="'tier-annual-' + tier.tier">Annual Months Charged</label>
                    <input
                      class="form-input"
                      type="number"
                      min="1"
                      max="12"
                      [id]="'tier-annual-' + tier.tier"
                      [formControl]="tierControls[tier.tier].controls.annualMonthsCharged"
                    />
                  </div>
                  <div class="form-group form-group--checkbox">
                    <label class="checkbox-label">
                      <input
                        type="checkbox"
                        [formControl]="tierControls[tier.tier].controls.isActive"
                      />
                      Active
                    </label>
                  </div>
                </div>
              </article>
            }
          </div>
        </section>

        <section class="pricing-section" aria-labelledby="features-heading">
          <div class="pricing-section__header">
            <h2 id="features-heading" class="section-title">Features</h2>
            <button
              type="button"
              class="btn btn-primary btn-sm"
              data-testid="save-features"
              [disabled]="savingFeatures()"
              (click)="saveFeatures()"
            >
              {{ savingFeatures() ? 'Saving...' : 'Save Features' }}
            </button>
          </div>

          <div class="card feature-table">
            @for (feature of features(); track feature.featureKey) {
              <div class="feature-row" [attr.data-testid]="'feature-' + feature.featureKey">
                <div class="feature-row__info">
                  <span class="feature-row__name">{{ feature.displayName }}</span>
                  <span class="feature-row__key text-muted">{{ feature.featureKey }}</span>
                </div>

                <div class="form-group feature-row__price">
                  <label [for]="'feature-price-' + feature.featureKey">Price (cents)</label>
                  <input
                    class="form-input"
                    type="number"
                    min="0"
                    [id]="'feature-price-' + feature.featureKey"
                    [formControl]="featureControls[feature.featureKey].controls.monthlyPriceCents"
                  />
                </div>

                <div class="form-group feature-row__limit">
                  <label [for]="'feature-limit-' + feature.featureKey">Limit Value</label>
                  <input
                    class="form-input"
                    type="number"
                    [id]="'feature-limit-' + feature.featureKey"
                    [formControl]="featureControls[feature.featureKey].controls.limitValue"
                  />
                </div>

                <div class="feature-row__flags">
                  <label class="checkbox-label">
                    <input
                      type="checkbox"
                      [formControl]="featureControls[feature.featureKey].controls.isSelectableCustom"
                    />
                    Custom
                  </label>
                  <label class="checkbox-label">
                    <input
                      type="checkbox"
                      [formControl]="featureControls[feature.featureKey].controls.isActive"
                    />
                    Active
                  </label>
                </div>
              </div>
            }
          </div>
        </section>
      }
    </div>
  `,
  styles: [
    `
      .section-title {
        font-size: 1.125rem;
        font-weight: 600;
        color: #fff;
        margin: 0;
      }

      .pricing-section {
        margin-bottom: 2rem;
      }

      .pricing-section__header {
        display: flex;
        flex-wrap: wrap;
        align-items: center;
        justify-content: space-between;
        gap: 0.75rem;
        margin-bottom: 0.75rem;
      }

      .pricing-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
        gap: 0.75rem;
      }

      .pricing-card {
        display: flex;
        flex-direction: column;
        gap: 0.5rem;
      }

      .pricing-card__name {
        font-size: 1.125rem;
        font-weight: 600;
        color: #fff;
        margin: 0;
      }

      .pricing-card__key {
        font-size: 0.75rem;
        margin-bottom: 0.25rem;
      }

      .form-group--checkbox {
        display: flex;
        align-items: flex-end;
        padding-bottom: 0.25rem;
      }

      .checkbox-label {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        font-size: 0.875rem;
        color: #e0e0e0;
        cursor: pointer;
      }

      .field-hint {
        font-size: 0.75rem;
        margin-top: 0.25rem;
        display: block;
      }

      .feature-table {
        display: flex;
        flex-direction: column;
        gap: 0.75rem;
        padding: 1rem;
      }

      .feature-row {
        display: grid;
        grid-template-columns: 1fr auto auto auto;
        gap: 0.75rem;
        align-items: end;
        padding-bottom: 0.75rem;
        border-bottom: 1px solid #2a2a3e;
      }

      .feature-row:last-child {
        border-bottom: none;
        padding-bottom: 0;
      }

      .feature-row__info {
        display: flex;
        flex-direction: column;
        gap: 0.125rem;
      }

      .feature-row__name {
        font-size: 0.9375rem;
        color: #e0e0e0;
      }

      .feature-row__key {
        font-size: 0.75rem;
      }

      .feature-row__price,
      .feature-row__limit {
        min-width: 120px;
      }

      .feature-row__flags {
        display: flex;
        flex-direction: column;
        gap: 0.375rem;
        min-width: 90px;
      }

      @media (max-width: 768px) {
        .feature-row {
          grid-template-columns: 1fr;
        }
      }
    `,
  ],
})
export class SubscriptionPricingComponent implements OnInit {
  private readonly fb = inject(FormBuilder);
  private readonly adminService = inject(SubscriptionAdminService);

  readonly loading = signal(true);
  readonly savingTiers = signal(false);
  readonly savingFeatures = signal(false);
  readonly errorMessage = signal('');
  readonly successMessage = signal('');
  readonly tiers = signal<PlanTierCatalogItem[]>([]);
  readonly features = signal<FeatureCatalogItem[]>([]);

  tierControls: Record<
    PlanTier,
    ReturnType<SubscriptionPricingComponent['createTierForm']>
  > = {} as Record<PlanTier, ReturnType<SubscriptionPricingComponent['createTierForm']>>;

  featureControls: Record<
    string,
    ReturnType<SubscriptionPricingComponent['createFeatureForm']>
  > = {};

  ngOnInit(): void {
    this.loadCatalog();
  }

  saveTiers(): void {
    const tiers = this.tiers().map(tier => {
      const controls = this.tierControls[tier.tier];
      const extraRaw = controls.controls.extraShopPriceCents.value;
      return {
        tier: tier.tier,
        displayName: controls.controls.displayName.value,
        basePriceMonthlyCents: controls.controls.basePriceMonthlyCents.value,
        extraShopPriceCents: extraRaw === '' || extraRaw === null ? null : Number(extraRaw),
        annualMonthsCharged: controls.controls.annualMonthsCharged.value,
        isActive: controls.controls.isActive.value,
      };
    });

    this.errorMessage.set('');
    this.successMessage.set('');
    this.savingTiers.set(true);

    this.adminService.updateTiers(tiers).subscribe({
      next: updated => {
        this.applyTiers(updated);
        this.savingTiers.set(false);
        this.successMessage.set('Tier pricing saved.');
      },
      error: err => {
        this.savingTiers.set(false);
        this.errorMessage.set(err.error?.message ?? 'Failed to save tier pricing.');
      },
    });
  }

  saveFeatures(): void {
    const features = this.features().map(feature => {
      const controls = this.featureControls[feature.featureKey];
      const limitRaw = controls.controls.limitValue.value;
      return {
        featureKey: feature.featureKey,
        monthlyPriceCents: controls.controls.monthlyPriceCents.value,
        limitType: feature.limitType ?? null,
        limitValue: limitRaw === '' || limitRaw === null ? null : Number(limitRaw),
        isSelectableCustom: controls.controls.isSelectableCustom.value,
        isActive: controls.controls.isActive.value,
      };
    });

    this.errorMessage.set('');
    this.successMessage.set('');
    this.savingFeatures.set(true);

    this.adminService.updateFeatures(features).subscribe({
      next: updated => {
        this.applyFeatures(updated);
        this.savingFeatures.set(false);
        this.successMessage.set('Feature pricing saved.');
      },
      error: err => {
        this.savingFeatures.set(false);
        this.errorMessage.set(err.error?.message ?? 'Failed to save feature pricing.');
      },
    });
  }

  private loadCatalog(): void {
    this.loading.set(true);
    forkJoin({
      tiers: this.adminService.getTiers(),
      features: this.adminService.getFeatures(),
    }).subscribe({
      next: ({ tiers, features }) => {
        this.applyTiers(tiers);
        this.applyFeatures(features);
        this.loading.set(false);
      },
      error: err => {
        this.errorMessage.set(err.error?.message ?? 'Failed to load pricing catalog.');
        this.loading.set(false);
      },
    });
  }

  private applyTiers(tiers: PlanTierCatalogItem[]): void {
    const sorted = [...tiers].sort(
      (a, b) => TIER_ORDER.indexOf(a.tier) - TIER_ORDER.indexOf(b.tier),
    );
    this.tiers.set(sorted);
    for (const tier of sorted) {
      this.tierControls[tier.tier] = this.createTierForm(tier);
    }
  }

  private applyFeatures(features: FeatureCatalogItem[]): void {
    const sorted = [...features].sort((a, b) => a.sortOrder - b.sortOrder);
    this.features.set(sorted);
    for (const feature of sorted) {
      this.featureControls[feature.featureKey] = this.createFeatureForm(feature);
    }
  }

  private createTierForm(tier: PlanTierCatalogItem) {
    return this.fb.nonNullable.group({
      displayName: [tier.displayName, Validators.required],
      basePriceMonthlyCents: [tier.basePriceMonthlyCents, [Validators.required, Validators.min(0)]],
      extraShopPriceCents: [tier.extraShopPriceCents ?? ('' as number | string)],
      annualMonthsCharged: [tier.annualMonthsCharged, [Validators.required, Validators.min(1)]],
      isActive: [tier.isActive],
    });
  }

  private createFeatureForm(feature: FeatureCatalogItem) {
    return this.fb.nonNullable.group({
      monthlyPriceCents: [feature.monthlyPriceCents, [Validators.required, Validators.min(0)]],
      limitValue: [feature.limitValue ?? ('' as number | string)],
      isSelectableCustom: [feature.isSelectableCustom],
      isActive: [feature.isActive],
    });
  }
}
