import {
  ChangeDetectionStrategy,
  Component,
  inject,
  OnDestroy,
  OnInit,
  signal,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { forkJoin, Subscription } from 'rxjs';
import {
  BillingInterval,
  FeatureCatalogItem,
  QuoteBreakdown,
} from '../../models/subscription.model';
import { ProfileService } from '../../services/profile.service';
import { SubscriptionService } from '../../services/subscription.service';

@Component({
  selector: 'app-custom-plan-builder',
  standalone: true,
  imports: [RouterLink, FormsModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="page">
      <div class="page-header">
        <div>
          <a routerLink="/profile/billing" class="back-link">← Billing</a>
          <h1 class="page-title">Build Custom Plan</h1>
          <p class="page-subtitle">Pick the features you need and see a live price quote.</p>
        </div>
      </div>

      @if (loadError()) {
        <div class="error-message">Unable to load plan catalog. Please try again later.</div>
      } @else if (!catalogLoaded()) {
        <div class="loading">Loading catalog...</div>
      } @else {
        <div class="builder-grid">
          <section class="card builder-panel">
            <h2 class="section-title">Features</h2>
            <p class="text-muted section-hint">Select à-la-carte features for your plan.</p>

            <ul class="feature-list">
              @for (feature of selectableFeatures(); track feature.featureKey) {
                <li class="feature-item">
                  <label class="feature-label">
                    <input
                      type="checkbox"
                      class="feature-checkbox"
                      [attr.data-testid]="'feature-' + feature.featureKey"
                      [checked]="isFeatureSelected(feature.featureKey)"
                      (change)="toggleFeature(feature.featureKey)"
                    />
                    <span class="feature-content">
                      <span class="feature-name">{{ feature.displayName }}</span>
                      @if (feature.description) {
                        <span class="feature-description text-muted">{{ feature.description }}</span>
                      }
                    </span>
                    <span class="feature-price">{{ formatCents(feature.monthlyPriceCents) }}/mo</span>
                  </label>
                </li>
              }
            </ul>
          </section>

          <section class="card builder-panel quote-panel">
            <h2 class="section-title">Quote</h2>

            <div class="form-group">
              <label for="shop-count">Shop count</label>
              <input
                id="shop-count"
                type="number"
                class="form-input shop-count-input"
                data-testid="shop-count"
                min="1"
                [ngModel]="shopCount()"
                (ngModelChange)="onShopCountChange($event)"
              />
              <p class="text-muted field-hint">First shop included; extra shops add to monthly cost.</p>
            </div>

            <label class="annual-toggle">
              <input
                type="checkbox"
                data-testid="annual-toggle"
                [checked]="billingInterval() === 'annual'"
                (change)="onAnnualToggle($event)"
              />
              <span>Bill annually</span>
            </label>

            @if (quoting()) {
              <div class="loading quote-loading" data-testid="quote-loading">Updating quote...</div>
            } @else if (quoteError()) {
              <div class="error-message">{{ quoteError() }}</div>
            } @else if (quote(); as currentQuote) {
              <div class="quote-summary" data-testid="quote-summary">
                <div class="quote-total">
                  <span class="quote-total-label">
                    {{ billingInterval() === 'annual' ? 'Annual total' : 'Monthly total' }}
                  </span>
                  <span class="quote-total-amount" data-testid="quote-total">
                    {{
                      formatCents(
                        billingInterval() === 'annual'
                          ? currentQuote.annualTotalCents
                          : currentQuote.monthlyTotalCents
                      )
                    }}
                  </span>
                </div>

                @if (billingInterval() === 'annual') {
                  <p class="text-muted quote-equiv">
                    {{ formatCents(currentQuote.monthlyTotalCents) }}/mo equivalent
                  </p>
                }

                @if (currentQuote.lineItems.length > 0) {
                  <ul class="line-items">
                    @for (item of currentQuote.lineItems; track item.key) {
                      <li class="line-item">
                        <span>{{ item.label }}</span>
                        <span>{{ formatCents(item.amountCents) }}</span>
                      </li>
                    }
                  </ul>
                }
              </div>
            }

            @if (applySuccess()) {
              <div class="success-message" data-testid="apply-success">Custom plan applied.</div>
            }
            @if (errorMessage()) {
              <div class="error-message">{{ errorMessage() }}</div>
            }

            <button
              type="button"
              class="btn btn-primary apply-btn"
              data-testid="apply-plan"
              [disabled]="applying() || quoting() || !!quoteError()"
              (click)="applyPlan()"
            >
              {{ applying() ? 'Applying...' : 'Apply plan' }}
            </button>
          </section>
        </div>
      }
    </div>
  `,
  styles: [
    `
      .back-link {
        display: inline-block;
        margin-bottom: 0.5rem;
        font-size: 0.875rem;
      }

      .page-subtitle {
        color: #888;
        margin-top: 0.25rem;
      }

      .builder-grid {
        display: grid;
        gap: 1.5rem;
        grid-template-columns: 1fr;
      }

      @media (min-width: 900px) {
        .builder-grid {
          grid-template-columns: 1.2fr 0.8fr;
          align-items: start;
        }
      }

      .builder-panel {
        padding: 1.25rem;
      }

      .section-title {
        font-size: 1.125rem;
        margin-bottom: 0.25rem;
      }

      .section-hint,
      .field-hint {
        font-size: 0.8125rem;
        margin-bottom: 1rem;
      }

      .feature-list {
        list-style: none;
        display: flex;
        flex-direction: column;
        gap: 0.75rem;
      }

      .feature-item {
        border: 1px solid #2a2a3e;
        border-radius: 8px;
        transition: border-color 0.15s;
      }

      .feature-item:has(.feature-checkbox:checked) {
        border-color: rgba(212, 165, 116, 0.5);
        background: rgba(212, 165, 116, 0.05);
      }

      .feature-label {
        display: flex;
        align-items: flex-start;
        gap: 0.75rem;
        padding: 0.875rem 1rem;
        cursor: pointer;
      }

      .feature-checkbox {
        margin-top: 0.2rem;
        flex-shrink: 0;
      }

      .feature-content {
        flex: 1;
        display: flex;
        flex-direction: column;
        gap: 0.2rem;
        min-width: 0;
      }

      .feature-name {
        font-weight: 500;
      }

      .feature-description {
        font-size: 0.8125rem;
        line-height: 1.4;
      }

      .feature-price {
        flex-shrink: 0;
        font-size: 0.875rem;
        color: #d4a574;
      }

      .shop-count-input {
        max-width: 8rem;
      }

      .annual-toggle {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        margin: 1rem 0;
        cursor: pointer;
        font-size: 0.9375rem;
      }

      .quote-loading {
        padding: 1rem 0;
      }

      .quote-summary {
        margin: 1rem 0;
        padding: 1rem;
        background: #16213e;
        border-radius: 8px;
      }

      .quote-total {
        display: flex;
        justify-content: space-between;
        align-items: baseline;
        gap: 1rem;
      }

      .quote-total-label {
        font-size: 0.875rem;
        color: #aaa;
      }

      .quote-total-amount {
        font-size: 1.5rem;
        font-weight: 700;
        color: #d4a574;
      }

      .quote-equiv {
        font-size: 0.8125rem;
        margin-top: 0.25rem;
      }

      .line-items {
        list-style: none;
        margin-top: 1rem;
        padding-top: 0.75rem;
        border-top: 1px solid #2a2a3e;
        display: flex;
        flex-direction: column;
        gap: 0.5rem;
      }

      .line-item {
        display: flex;
        justify-content: space-between;
        gap: 1rem;
        font-size: 0.875rem;
        color: #bbb;
      }

      .apply-btn {
        width: 100%;
        margin-top: 1rem;
      }

      .success-message {
        margin-top: 0.75rem;
        padding: 0.75rem;
        background: rgba(76, 175, 80, 0.15);
        border: 1px solid rgba(76, 175, 80, 0.4);
        border-radius: 6px;
        color: #a5d6a7;
        font-size: 0.875rem;
      }
    `,
  ],
})
export class CustomPlanBuilderComponent implements OnInit, OnDestroy {
  private readonly subscriptionService = inject(SubscriptionService);
  private readonly profileService = inject(ProfileService);

  private quoteRequestSub?: Subscription;

  readonly catalogLoaded = signal(false);
  readonly loadError = signal(false);
  readonly selectableFeatures = signal<FeatureCatalogItem[]>([]);
  readonly selectedFeatures = signal<Set<string>>(new Set());
  readonly shopCount = signal(1);
  readonly billingInterval = signal<BillingInterval>('monthly');
  readonly quote = signal<QuoteBreakdown | null>(null);
  readonly quoting = signal(false);
  readonly quoteError = signal('');
  readonly applying = signal(false);
  readonly applySuccess = signal(false);
  readonly errorMessage = signal('');

  ngOnInit(): void {
    const sub = this.subscriptionService.subscription();
    this.shopCount.set(Math.max(sub?.shopsUsed ?? 1, sub?.shopsIncluded ?? 1, 1));

    forkJoin({
      catalog: this.subscriptionService.getCatalog(),
      me: this.subscriptionService.getMe(),
    }).subscribe({
      next: ({ catalog, me }) => {
        this.selectableFeatures.set(
          catalog.features
            .filter(feature => feature.isSelectableCustom && feature.isActive)
            .sort((a, b) => a.sortOrder - b.sortOrder),
        );

        if (me.planMode === 'CUSTOM' && me.features?.length) {
          this.selectedFeatures.set(new Set(me.features));
        }
        if (me.billingInterval) {
          this.billingInterval.set(me.billingInterval);
        }

        this.catalogLoaded.set(true);
        this.refreshQuote();
      },
      error: () => this.loadError.set(true),
    });
  }

  ngOnDestroy(): void {
    this.quoteRequestSub?.unsubscribe();
  }

  isFeatureSelected(featureKey: string): boolean {
    return this.selectedFeatures().has(featureKey);
  }

  toggleFeature(featureKey: string): void {
    this.selectedFeatures.update(current => {
      const next = new Set(current);
      if (next.has(featureKey)) {
        next.delete(featureKey);
      } else {
        next.add(featureKey);
      }
      return next;
    });
    this.applySuccess.set(false);
    this.refreshQuote();
  }

  onShopCountChange(value: number | string): void {
    const parsed = typeof value === 'string' ? Number.parseInt(value, 10) : value;
    this.shopCount.set(Number.isFinite(parsed) && parsed >= 1 ? parsed : 1);
    this.applySuccess.set(false);
    this.refreshQuote();
  }

  onAnnualToggle(event: Event): void {
    const checked = (event.target as HTMLInputElement).checked;
    this.billingInterval.set(checked ? 'annual' : 'monthly');
    this.applySuccess.set(false);
    this.refreshQuote();
  }

  applyPlan(): void {
    if (this.applying()) {
      return;
    }

    this.applying.set(true);
    this.applySuccess.set(false);
    this.errorMessage.set('');

    this.subscriptionService
      .changePlan({
        planMode: 'CUSTOM',
        features: [...this.selectedFeatures()],
        billingInterval: this.billingInterval(),
      })
      .subscribe({
        next: () => {
          this.applying.set(false);
          this.applySuccess.set(true);
          this.profileService.getProfile().subscribe();
        },
        error: err => {
          this.applying.set(false);
          this.errorMessage.set(err.error?.message ?? 'Failed to apply plan.');
        },
      });
  }

  formatCents(cents: number): string {
    return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(
      cents / 100,
    );
  }

  private refreshQuote(): void {
    if (!this.catalogLoaded()) {
      return;
    }

    this.quoting.set(true);
    this.quoteError.set('');
    this.quoteRequestSub?.unsubscribe();

    this.quoteRequestSub = this.subscriptionService
      .quote({
        planMode: 'CUSTOM',
        features: [...this.selectedFeatures()],
        shopCount: this.shopCount(),
        billingInterval: this.billingInterval(),
      })
      .subscribe({
        next: breakdown => {
          this.quote.set(breakdown);
          this.quoting.set(false);
        },
        error: () => {
          this.quote.set(null);
          this.quoteError.set('Unable to load quote.');
          this.quoting.set(false);
        },
      });
  }
}
