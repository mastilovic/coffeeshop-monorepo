import { CurrencyPipe } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  OnInit,
  signal,
} from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { FormSelectComponent } from '../../../shared/form-select/form-select.component';
import { FormSelectOption } from '../../../shared/form-select/form-select-option.model';
import {
  FeatureCatalogItem,
  OwnerSubscriptionListItem,
} from '../../../models/subscription-admin.model';
import { PlanMode, PlanTier } from '../../../models/subscription.model';
import { SubscriptionAdminService } from '../../../services/subscription-admin.service';

const PLAN_MODE_OPTIONS: FormSelectOption[] = [
  { value: 'PRESET', label: 'Preset Tier' },
  { value: 'CUSTOM', label: 'Custom Plan' },
];

const PLAN_TIER_OPTIONS: FormSelectOption[] = [
  { value: 'STARTER', label: 'Starter' },
  { value: 'GROWTH', label: 'Growth' },
  { value: 'PRO', label: 'Pro' },
];

const BILLING_INTERVAL_OPTIONS: FormSelectOption[] = [
  { value: 'monthly', label: 'Monthly' },
  { value: 'annual', label: 'Annual' },
];

const STATUS_OPTIONS: FormSelectOption[] = [
  { value: 'active', label: 'Active' },
  { value: 'trialing', label: 'Trialing' },
  { value: 'past_due', label: 'Past Due' },
  { value: 'canceled', label: 'Canceled' },
];

@Component({
  selector: 'app-subscriptions-admin',
  standalone: true,
  imports: [ReactiveFormsModule, FormSelectComponent, CurrencyPipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="page page--with-footer">
      <div class="page__content">
        <div class="page-header">
          <h1 class="page-title">Owner Subscriptions</h1>
          <p class="page-subtitle text-muted">View shop owners and override their subscription plan.</p>
        </div>

        @if (showForm()) {
          <div class="form-card mb-3" data-testid="override-form">
            <h3 class="form-card__title">Override Plan — {{ selectedOwner()?.name }}</h3>
            <p class="text-muted form-card__subtitle">@{{ selectedOwner()?.username }}</p>

            <form [formGroup]="form" (ngSubmit)="onSubmit()">
              <div class="form-row">
                <div class="form-group">
                  <label>Plan Mode</label>
                  <app-form-select
                    formControlName="planMode"
                    placeholder="Plan mode"
                    [options]="planModeOptions"
                  />
                </div>
                @if (form.controls.planMode.value === 'PRESET') {
                  <div class="form-group">
                    <label>Plan Tier</label>
                    <app-form-select
                      formControlName="planTier"
                      placeholder="Plan tier"
                      [options]="planTierOptions"
                    />
                  </div>
                }
              </div>

              <div class="form-row">
                <div class="form-group">
                  <label>Billing Interval</label>
                  <app-form-select
                    formControlName="billingInterval"
                    placeholder="Billing interval"
                    [options]="billingIntervalOptions"
                  />
                </div>
                <div class="form-group">
                  <label>Status</label>
                  <app-form-select
                    formControlName="status"
                    placeholder="Status"
                    [options]="statusOptions"
                  />
                </div>
              </div>

              @if (form.controls.planMode.value === 'CUSTOM') {
                <div class="form-group">
                  <label>Custom Features</label>
                  <div class="feature-checkboxes">
                    @for (feature of selectableFeatures(); track feature.featureKey) {
                      <label class="checkbox-label">
                        <input
                          type="checkbox"
                          [checked]="isFeatureSelected(feature.featureKey)"
                          (change)="toggleFeature(feature.featureKey)"
                        />
                        {{ feature.displayName }}
                      </label>
                    }
                  </div>
                </div>
              }

              @if (errorMessage()) {
                <div class="error-message">{{ errorMessage() }}</div>
              }
              @if (successMessage()) {
                <div class="success-message">{{ successMessage() }}</div>
              }

              <div class="form-actions">
                <button
                  type="submit"
                  class="btn btn-primary"
                  data-testid="save-override"
                  [disabled]="form.invalid || saving()"
                >
                  {{ saving() ? 'Saving...' : 'Save Override' }}
                </button>
                <button type="button" class="btn btn-secondary" (click)="cancelOverride()">
                  Cancel
                </button>
              </div>
            </form>
          </div>
        }

        <div class="events-toolbar mb-3">
          <input
            class="form-input events-search"
            type="search"
            placeholder="Search by name or username..."
            aria-label="Search owners"
            [value]="searchInput()"
            (input)="onSearchInput($event)"
          />
        </div>

        @if (loading()) {
          <div class="loading">Loading owners...</div>
        } @else if (totalElements() === 0) {
          <div class="empty-state"><p>{{ emptyStateMessage() }}</p></div>
        } @else {
          <div class="compact-list">
            @for (owner of owners(); track owner.id) {
              <article class="compact-row" [attr.data-testid]="'owner-' + owner.id">
                <div class="compact-row__start">
                  <span class="compact-row__avatar">{{ owner.name.charAt(0).toUpperCase() }}</span>
                  <div class="compact-row__text">
                    <span class="compact-row__primary">{{ owner.name }}</span>
                    <span class="compact-row__secondary">@{{ owner.username }}</span>
                  </div>
                </div>
                <span class="compact-row__badge plan-badge">
                  {{ planLabel(owner) }}
                </span>
                <span class="compact-row__badge status-badge">
                  {{ owner.status ?? 'none' }}
                </span>
                <span class="compact-row__badge shops-badge">
                  {{ owner.shopsUsed }} shop{{ owner.shopsUsed === 1 ? '' : 's' }}
                </span>
                @if (owner.lockedMonthlyAmountCents != null) {
                  <span class="compact-row__badge price-badge">
                    {{ owner.lockedMonthlyAmountCents / 100 | currency: 'USD' : 'symbol' : '1.0-0' }}/mo
                  </span>
                }
                <div class="compact-row__end">
                  <button
                    class="btn btn--compact btn-secondary"
                    data-testid="override-btn"
                    (click)="onOverride(owner)"
                  >
                    Override
                  </button>
                </div>
              </article>
            }
          </div>
        }
      </div>

      @if (!loading()) {
        <div class="pagination-bar page__footer">
          <span class="pagination-summary">{{ rangeLabel() }}</span>
          <div class="pagination-controls">
            <button
              class="btn btn-secondary btn-sm"
              [disabled]="currentPage() === 0"
              (click)="goToPage(currentPage() - 1)"
            >
              Previous
            </button>
            <span class="pagination-page">Page {{ currentPage() + 1 }} of {{ totalPages() }}</span>
            <button
              class="btn btn-secondary btn-sm"
              [disabled]="currentPage() >= totalPages() - 1"
              (click)="goToPage(currentPage() + 1)"
            >
              Next
            </button>
          </div>
        </div>
      }
    </div>
  `,
  styles: [
    `
      :host {
        display: block;
        min-height: 100%;
      }

      .form-card__title {
        color: #fff;
        margin: 0 0 0.25rem;
        font-size: 1.125rem;
      }

      .form-card__subtitle {
        margin: 0 0 0.75rem;
        font-size: 0.875rem;
      }

      .feature-checkboxes {
        display: flex;
        flex-direction: column;
        gap: 0.5rem;
        max-height: 240px;
        overflow-y: auto;
        padding: 0.75rem;
        background: #16213e;
        border-radius: 8px;
      }

      .checkbox-label {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        font-size: 0.875rem;
        color: #e0e0e0;
        cursor: pointer;
      }

      .plan-badge {
        background: rgba(212, 165, 116, 0.1);
        color: #d4a574;
      }

      .status-badge {
        background: rgba(76, 175, 80, 0.1);
        color: #4caf50;
      }

      .shops-badge {
        background: rgba(33, 150, 243, 0.1);
        color: #64b5f6;
      }

      .price-badge {
        background: rgba(136, 136, 136, 0.1);
        color: #aaa;
      }
    `,
  ],
})
export class SubscriptionsAdminComponent implements OnInit {
  readonly planModeOptions = PLAN_MODE_OPTIONS;
  readonly planTierOptions = PLAN_TIER_OPTIONS;
  readonly billingIntervalOptions = BILLING_INTERVAL_OPTIONS;
  readonly statusOptions = STATUS_OPTIONS;

  private readonly fb = inject(FormBuilder);
  private readonly adminService = inject(SubscriptionAdminService);

  readonly owners = signal<OwnerSubscriptionListItem[]>([]);
  readonly loading = signal(true);
  readonly saving = signal(false);
  readonly showForm = signal(false);
  readonly selectedOwner = signal<OwnerSubscriptionListItem | null>(null);
  readonly selectedFeatures = signal<string[]>([]);
  readonly catalogFeatures = signal<FeatureCatalogItem[]>([]);
  readonly searchInput = signal('');
  readonly currentPage = signal(0);
  readonly pageSize = 20;
  readonly totalElements = signal(0);
  readonly totalPages = signal(1);
  readonly errorMessage = signal('');
  readonly successMessage = signal('');

  readonly selectableFeatures = computed(() =>
    this.catalogFeatures().filter(f => f.isSelectableCustom && f.isActive),
  );

  readonly form = this.fb.nonNullable.group({
    planMode: ['PRESET' as PlanMode, Validators.required],
    planTier: ['GROWTH' as PlanTier, Validators.required],
    billingInterval: ['monthly' as 'monthly' | 'annual', Validators.required],
    status: ['active' as 'active' | 'trialing' | 'past_due' | 'canceled', Validators.required],
  });

  ngOnInit(): void {
    this.adminService.getFeatures().subscribe({
      next: features => this.catalogFeatures.set(features),
      error: () => {},
    });
    this.loadOwners();
  }

  emptyStateMessage(): string {
    if (this.searchInput().trim()) return 'No owners match your search.';
    return 'No shop owners found.';
  }

  planLabel(owner: OwnerSubscriptionListItem): string {
    if (!owner.planMode) return 'No plan';
    if (owner.planMode === 'CUSTOM') return 'Custom';
    return owner.planTier ?? 'Preset';
  }

  onSearchInput(inputEvent: Event): void {
    const value = (inputEvent.target as HTMLInputElement).value;
    this.searchInput.set(value);
    this.currentPage.set(0);
    this.loadOwners();
  }

  loadOwners(): void {
    this.loading.set(true);
    const q = this.searchInput().trim();
    this.adminService
      .listOwners({
        q: q || undefined,
        page: this.currentPage(),
        size: this.pageSize,
      })
      .subscribe({
        next: page => {
          this.owners.set(page.content);
          this.totalElements.set(page.totalElements);
          this.totalPages.set(Math.max(1, page.totalPages));
          this.loading.set(false);
        },
        error: () => this.loading.set(false),
      });
  }

  goToPage(page: number): void {
    if (page < 0 || page >= this.totalPages()) return;
    this.currentPage.set(page);
    this.loadOwners();
  }

  rangeLabel(): string {
    const total = this.totalElements();
    if (total === 0) return '';
    const start = this.currentPage() * this.pageSize + 1;
    const end = Math.min((this.currentPage() + 1) * this.pageSize, total);
    return `Showing ${start}–${end} of ${total}`;
  }

  onOverride(owner: OwnerSubscriptionListItem): void {
    this.selectedOwner.set(owner);
    this.showForm.set(true);
    this.errorMessage.set('');
    this.successMessage.set('');
    this.selectedFeatures.set([]);

    this.form.patchValue({
      planMode: owner.planMode ?? 'PRESET',
      planTier: owner.planTier ?? 'GROWTH',
      billingInterval: 'monthly',
      status: owner.status ?? 'active',
    });
  }

  isFeatureSelected(featureKey: string): boolean {
    return this.selectedFeatures().includes(featureKey);
  }

  toggleFeature(featureKey: string): void {
    const current = this.selectedFeatures();
    if (current.includes(featureKey)) {
      this.selectedFeatures.set(current.filter(key => key !== featureKey));
    } else {
      this.selectedFeatures.set([...current, featureKey]);
    }
  }

  onSubmit(): void {
    if (this.form.invalid) return;
    const owner = this.selectedOwner();
    if (!owner) return;

    const val = this.form.getRawValue();
    this.errorMessage.set('');
    this.successMessage.set('');
    this.saving.set(true);

    this.adminService
      .overrideOwnerPlan(owner.id, {
        planMode: val.planMode,
        planTier: val.planMode === 'PRESET' ? val.planTier : undefined,
        features: val.planMode === 'CUSTOM' ? this.selectedFeatures() : [],
        billingInterval: val.billingInterval,
        status: val.status,
      })
      .subscribe({
        next: () => {
          this.saving.set(false);
          this.successMessage.set('Subscription override saved.');
          this.loadOwners();
        },
        error: err => {
          this.saving.set(false);
          this.errorMessage.set(err.error?.message ?? 'Failed to save override.');
        },
      });
  }

  cancelOverride(): void {
    this.selectedOwner.set(null);
    this.showForm.set(false);
    this.selectedFeatures.set([]);
    this.errorMessage.set('');
    this.successMessage.set('');
    this.form.reset({
      planMode: 'PRESET',
      planTier: 'GROWTH',
      billingInterval: 'monthly',
      status: 'active',
    });
  }
}
