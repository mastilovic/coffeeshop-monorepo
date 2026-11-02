import { CurrencyPipe, DatePipe } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  OnInit,
  signal,
} from '@angular/core';
import { RouterLink } from '@angular/router';
import {
  CatalogTier,
  LimitKey,
  PlanTier,
  SubscriptionSummary,
} from '../../../models/subscription.model';
import { ProfileService } from '../../../services/profile.service';
import { SubscriptionService } from '../../../services/subscription.service';

const LIMIT_LABELS: Record<LimitKey, string> = {
  tables: 'Tables',
  menus: 'Menus',
  events: 'Events (monthly)',
  employees: 'Employees',
  shops: 'Shops',
};

const TIER_ORDER: PlanTier[] = ['STARTER', 'GROWTH', 'PRO'];

@Component({
  selector: 'app-billing',
  standalone: true,
  imports: [RouterLink, CurrencyPipe, DatePipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="page">
      <div class="page-header">
        <h1 class="page-title">Billing &amp; Plans</h1>
        <a routerLink="/profile" class="btn btn-secondary">Back to Profile</a>
      </div>

      @if (loading()) {
        <div class="loading">Loading billing information...</div>
      } @else {
        @if (errorMessage()) {
          <div class="error-message">{{ errorMessage() }}</div>
        }
        @if (successMessage()) {
          <div class="success-message">{{ successMessage() }}</div>
        }

        <section class="billing-section" aria-labelledby="current-plan-heading">
          <h2 id="current-plan-heading" class="section-title">Current Plan</h2>
          @if (subscription(); as sub) {
            <div class="card billing-current">
              <div class="billing-current__header">
                <div>
                  <span class="billing-current__plan">{{ currentPlanLabel() }}</span>
                  <span class="badge" [class]="statusBadgeClass(sub.status)">{{ sub.status }}</span>
                </div>
                <span class="billing-current__price">
                  {{ sub.monthlyAmountCents / 100 | currency: 'USD' : 'symbol' : '1.0-0' }}/mo
                </span>
              </div>
              <div class="billing-current__meta">
                <span>{{ sub.shopsUsed }} / {{ formatShopLimit(sub) }} shops</span>
                @if (sub.periodEnd) {
                  <span>Renews {{ sub.periodEnd | date: 'mediumDate' }}</span>
                }
              </div>
            </div>
          } @else {
            <div class="empty-state"><p>No subscription information available.</p></div>
          }
        </section>

        @if (usageItems().length > 0) {
          <section class="billing-section" aria-labelledby="usage-heading">
            <h2 id="usage-heading" class="section-title">Usage</h2>
            <div class="card billing-usage">
              @for (item of usageItems(); track item.key) {
                <div class="usage-row">
                  <div class="usage-row__header">
                    <span class="usage-row__label">{{ item.label }}</span>
                    <span class="usage-row__value">{{ item.display }}</span>
                  </div>
                  @if (!item.unlimited) {
                    <div
                      class="usage-bar"
                      role="progressbar"
                      [attr.aria-valuenow]="item.used"
                      [attr.aria-valuemin]="0"
                      [attr.aria-valuemax]="item.max"
                      [attr.aria-label]="item.label + ' usage'"
                    >
                      <div
                        class="usage-bar__fill"
                        [class.usage-bar__fill--warning]="item.percent >= 80"
                        [class.usage-bar__fill--danger]="item.percent >= 100"
                        [style.width.%]="item.percent"
                      ></div>
                    </div>
                  }
                </div>
              }
            </div>
          </section>
        }

        <section class="billing-section" aria-labelledby="plans-heading">
          <div class="billing-section__header">
            <h2 id="plans-heading" class="section-title">Choose a Plan</h2>
            <a routerLink="/profile/billing/custom" class="btn btn-secondary btn-sm">
              Build Custom Plan
            </a>
          </div>

          <div class="billing-tiers">
            @for (tier of catalogTiers(); track tier.tier) {
              <article
                class="card billing-tier"
                [class.billing-tier--current]="isCurrentTier(tier.tier)"
              >
                <h3 class="billing-tier__name">{{ tier.displayName }}</h3>
                <p class="billing-tier__price">
                  {{ tier.basePriceMonthlyCents / 100 | currency: 'USD' : 'symbol' : '1.0-0' }}
                  <span class="billing-tier__interval">/ month</span>
                </p>
                <p class="billing-tier__features text-muted">
                  {{ tier.includedFeatures.length }} features included
                </p>
                <button
                  type="button"
                  class="btn btn-block"
                  [class.btn-primary]="!isCurrentTier(tier.tier)"
                  [class.btn-secondary]="isCurrentTier(tier.tier)"
                  [disabled]="isCurrentTier(tier.tier) || changingTier() !== null"
                  (click)="selectTier(tier.tier)"
                >
                  @if (changingTier() === tier.tier) {
                    Switching...
                  } @else if (isCurrentTier(tier.tier)) {
                    Current Plan
                  } @else {
                    Select {{ tier.displayName }}
                  }
                </button>
              </article>
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
        margin: 0 0 0.75rem;
      }

      .billing-section {
        margin-bottom: 1.5rem;
      }

      .billing-section__header {
        display: flex;
        flex-wrap: wrap;
        align-items: center;
        justify-content: space-between;
        gap: 0.75rem;
        margin-bottom: 0.75rem;
      }

      .billing-section__header .section-title {
        margin-bottom: 0;
      }

      .billing-current__header {
        display: flex;
        flex-wrap: wrap;
        align-items: flex-start;
        justify-content: space-between;
        gap: 0.75rem;
        margin-bottom: 0.75rem;
      }

      .billing-current__plan {
        display: block;
        font-size: 1.25rem;
        font-weight: 600;
        color: #fff;
        margin-bottom: 0.375rem;
      }

      .billing-current__price {
        font-size: 1.125rem;
        font-weight: 600;
        color: #d4a574;
      }

      .billing-current__meta {
        display: flex;
        flex-wrap: wrap;
        gap: 1rem;
        font-size: 0.875rem;
        color: #aaa;
      }

      .badge-active {
        background: rgba(76, 175, 80, 0.15);
        color: #4caf50;
      }

      .badge-trialing {
        background: rgba(33, 150, 243, 0.15);
        color: #64b5f6;
      }

      .badge-past_due {
        background: rgba(192, 57, 43, 0.15);
        color: #c0392b;
      }

      .badge-canceled {
        background: rgba(136, 136, 136, 0.15);
        color: #888;
      }

      .billing-usage {
        display: flex;
        flex-direction: column;
        gap: 1rem;
      }

      .usage-row__header {
        display: flex;
        justify-content: space-between;
        align-items: baseline;
        gap: 0.75rem;
        margin-bottom: 0.375rem;
      }

      .usage-row__label {
        font-size: 0.875rem;
        color: #e0e0e0;
      }

      .usage-row__value {
        font-size: 0.8125rem;
        color: #aaa;
      }

      .usage-bar {
        height: 8px;
        background: #16213e;
        border-radius: 999px;
        overflow: hidden;
      }

      .usage-bar__fill {
        height: 100%;
        background: #d4a574;
        border-radius: 999px;
        transition: width 0.2s;
      }

      .usage-bar__fill--warning {
        background: #f0ad4e;
      }

      .usage-bar__fill--danger {
        background: #c0392b;
      }

      .billing-tiers {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
        gap: 0.75rem;
      }

      .billing-tier {
        display: flex;
        flex-direction: column;
        gap: 0.5rem;
      }

      .billing-tier--current {
        border-color: #d4a574;
        box-shadow: 0 0 0 1px rgba(212, 165, 116, 0.35);
      }

      .billing-tier__name {
        font-size: 1.125rem;
        font-weight: 600;
        color: #fff;
        margin: 0;
      }

      .billing-tier__price {
        font-size: 1.5rem;
        font-weight: 700;
        color: #d4a574;
        margin: 0;
      }

      .billing-tier__interval {
        font-size: 0.875rem;
        font-weight: 400;
        color: #888;
      }

      .billing-tier__features {
        font-size: 0.8125rem;
        margin: 0 0 0.5rem;
        flex: 1;
      }

      .billing-tier .btn {
        margin-top: auto;
      }
    `,
  ],
})
export class BillingComponent implements OnInit {
  private readonly subscriptionService = inject(SubscriptionService);
  private readonly profileService = inject(ProfileService);

  readonly loading = signal(true);
  readonly errorMessage = signal('');
  readonly successMessage = signal('');
  readonly changingTier = signal<PlanTier | null>(null);
  readonly catalogTiers = signal<CatalogTier[]>([]);

  readonly subscription = this.subscriptionService.subscription;
  readonly limits = this.subscriptionService.limits;

  readonly usageItems = computed(() => {
    const limits = this.limits();
    return (Object.keys(limits) as LimitKey[])
      .filter(key => LIMIT_LABELS[key])
      .map(key => {
        const usage = limits[key];
        const unlimited = usage.max < 0;
        const percent = unlimited ? 0 : usage.max > 0 ? Math.min(100, (usage.used / usage.max) * 100) : 0;
        return {
          key,
          label: LIMIT_LABELS[key],
          used: usage.used,
          max: usage.max,
          unlimited,
          percent,
          display: unlimited ? `${usage.used} / Unlimited` : `${usage.used} / ${usage.max}`,
        };
      });
  });

  readonly currentPlanLabel = computed(() => {
    const sub = this.subscription();
    if (!sub) return 'Unknown';
    if (sub.planMode === 'CUSTOM') return 'Custom Plan';
    const tier = this.catalogTiers().find(t => t.tier === sub.planTier);
    return tier?.displayName ?? sub.planTier ?? 'Preset Plan';
  });

  ngOnInit(): void {
    this.subscriptionService.getCatalog().subscribe({
      next: catalog => {
        const sorted = [...catalog.tiers]
          .filter(t => t.isActive)
          .sort((a, b) => TIER_ORDER.indexOf(a.tier) - TIER_ORDER.indexOf(b.tier));
        this.catalogTiers.set(sorted);
        this.loading.set(false);
      },
      error: err => {
        this.errorMessage.set(err.error?.message ?? 'Failed to load plan catalog.');
        this.loading.set(false);
      },
    });
  }

  isCurrentTier(tier: PlanTier): boolean {
    const sub = this.subscription();
    return sub?.planMode === 'PRESET' && sub.planTier === tier;
  }

  selectTier(tier: PlanTier): void {
    if (this.isCurrentTier(tier) || this.changingTier()) return;

    this.errorMessage.set('');
    this.successMessage.set('');
    this.changingTier.set(tier);

    this.subscriptionService
      .changePlan({
        planMode: 'PRESET',
        planTier: tier,
        billingInterval: 'monthly',
      })
      .subscribe({
        next: () => {
          this.changingTier.set(null);
          this.successMessage.set('Plan updated successfully.');
          this.profileService.getProfile().subscribe();
        },
        error: err => {
          this.changingTier.set(null);
          this.errorMessage.set(err.error?.message ?? 'Failed to change plan.');
        },
      });
  }

  formatShopLimit(sub: SubscriptionSummary): string {
    return sub.shopsIncluded > 0 ? String(sub.shopsIncluded) : 'Unlimited';
  }

  statusBadgeClass(status: string): string {
    const classes: Record<string, string> = {
      active: 'badge-active',
      trialing: 'badge-trialing',
      past_due: 'badge-past_due',
      canceled: 'badge-canceled',
    };
    return classes[status] ?? 'badge-role';
  }
}
