import { NgTemplateOutlet } from '@angular/common';
import { Component, computed, inject, Injector, OnInit, signal, ChangeDetectionStrategy } from '@angular/core';
import { takeUntilDestroyed, toObservable } from '@angular/core/rxjs-interop';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { debounceTime, distinctUntilChanged, skip } from 'rxjs';
import { ShopService } from '../../services/shop.service';
import { AuthService } from '../../services/auth.service';
import { ProfileService } from '../../services/profile.service';
import { ShopResponseDto } from '../../models/shop.model';
import { StarRatingComponent } from '../../shared/star-rating/star-rating.component';
import { CitySearchSelectComponent } from '../../shared/city-search-select/city-search-select.component';
import { DialogService } from '../../services/dialog.service';

@Component({
  selector: 'app-shops',
  standalone: true,
  imports: [ReactiveFormsModule, StarRatingComponent, CitySearchSelectComponent, NgTemplateOutlet],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="page page--with-footer shops-page">
      @if (showForm() && canShowForm()) {
        <div class="page__content shops-page__content">
          <div class="page-header">
            <h1 class="page-title">{{ editingId() ? 'Edit Shop' : 'Create Shop' }}</h1>
            <button type="button" class="btn btn-secondary" (click)="cancelEdit()">Cancel</button>
          </div>

          <div class="shops-form-wrapper">
            <div class="form-card">
              <form [formGroup]="form" (ngSubmit)="onSubmit()">
                <div class="form-group shop-form-group--name">
                  <label>Name</label>
                  <input class="form-input" formControlName="name" placeholder="Shop name" />
                </div>
                @if (editingId()) {
                  <div class="form-group shop-form-group--email">
                    <label>Email</label>
                    <input class="form-input" type="email" formControlName="email" placeholder="shop@example.com" />
                  </div>
                }
                <div class="form-row shop-form-row--address-city">
                  <div class="form-group">
                    <label>Address</label>
                    <input class="form-input" formControlName="address" placeholder="Street address" />
                  </div>
                  <div class="form-group">
                    <label>City</label>
                    <app-city-search-select formControlName="city" />
                  </div>
                </div>
                <div class="form-group shop-form-group--phone">
                  <label>Phone</label>
                  <input class="form-input" formControlName="phoneNumber" placeholder="+1 234 567 890" />
                </div>
                <div class="form-actions shops-form-actions">
                  <button type="submit" class="btn btn-primary" [disabled]="form.invalid">
                    {{ editingId() ? 'Update' : 'Create' }}
                  </button>
                  <button type="button" class="btn btn-secondary" (click)="cancelEdit()">Cancel</button>
                </div>
              </form>
            </div>
          </div>
        </div>
      } @else {
        <div class="page__content shops-page__content">
          <div class="page-header">
            <h1 class="page-title">Shops</h1>
            @if (canCreateShop()) {
              <button type="button" class="btn btn-primary" (click)="showForm.set(true)">+ New Shop</button>
            }
          </div>

          <div class="events-toolbar mb-3">
            <input
              class="form-input events-search"
              type="search"
              placeholder="Search by name, city, or address..."
              aria-label="Search shops"
              [value]="searchInput()"
              (input)="onSearchInput($event)"
            />
          </div>

          @if (loading()) {
            <div class="loading">Loading shops...</div>
          } @else if (totalElements() === 0) {
            <div class="empty-state"><p>{{ emptyStateMessage() }}</p></div>
          } @else {
            @if (favouriteShopsList().length > 0) {
              <h2 class="shops-section-title">Your communities</h2>
              <div class="shop-card-grid">
                @for (shop of favouriteShopsList(); track shop.id) {
                  <ng-container *ngTemplateOutlet="shopCard; context: { $implicit: shop }" />
                }
              </div>
            }
            @if (otherShopsList().length > 0) {
              <h2 class="shops-section-title">{{ favouriteShopsList().length > 0 ? 'All shops' : 'Shops' }}</h2>
              <div class="shop-card-grid">
                @for (shop of otherShopsList(); track shop.id) {
                  <ng-container *ngTemplateOutlet="shopCard; context: { $implicit: shop }" />
                }
              </div>
            }
          }
        </div>

        @if (!loading()) {
          <div class="pagination-bar page__footer shops-page__footer">
            <span class="pagination-summary">{{ rangeLabel() }}</span>
            <div class="pagination-controls">
              <label class="pagination-page-size">
                <span class="pagination-page-size__label">Per page</span>
                <select
                  class="form-input pagination-page-size__select"
                  aria-label="Items per page"
                  [value]="pageSize()"
                  (change)="onPageSizeChange($event)"
                >
                  @for (option of pageSizeOptions; track option) {
                    <option [value]="option">{{ option }}</option>
                  }
                </select>
              </label>
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
      }
    </div>

    <ng-template #shopCard let-shop>
      <div class="card clickable shop-card shop-card--compact" (click)="goToShop(shop.id)">
        @if (!canManage(shop)) {
          <button
            type="button"
            class="btn btn-icon btn-favourite"
            [class.btn-favourite--active]="isFavourite(shop)"
            [disabled]="togglingFavouriteId() === shop.id"
            [attr.aria-label]="isFavourite(shop) ? 'Leave ' + shop.name : 'Join ' + shop.name"
            [title]="isFavourite(shop) ? 'Leave ' + shop.name : 'Join ' + shop.name"
            (click)="toggleFavourite(shop, $event)"
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
              @if (isFavourite(shop)) {
                <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
              } @else {
                <path d="M16.5 3c-1.74 0-3.41.81-4.5 2.09C10.91 3.81 9.24 3 7.5 3 4.42 3 2 5.42 2 8.5c0 3.78 3.4 6.86 8.55 11.54L12 21.35l1.45-1.32C18.6 15.36 22 12.28 22 8.5 22 5.42 19.58 3 16.5 3zm-4.4 15.55l-.1.1-.1-.1C7.14 14.24 4 11.39 4 8.5 4 6.5 5.5 5 7.5 5c1.54 0 3.04.99 3.57 2.36h1.87C13.46 5.99 14.96 5 16.5 5c2 0 3.5 1.5 3.5 3.5 0 2.89-3.14 5.74-7.9 10.05z"/>
              }
            </svg>
          </button>
        }
        <div class="shop-card__body">
          <h3 class="shop-card__title">
            {{ shop.name }}
            @if (isFavourite(shop)) {
              <span class="badge badge-joined">Joined</span>
            }
          </h3>
          <div class="shop-card__details">
            <div class="view-mobile-only shop-card__row shop-card__row--location">
              <span class="shop-card__value">{{ shop.city }} · {{ shop.address }}</span>
            </div>
            <div class="view-desktop-only shop-card__row">
              <span class="shop-card__label">City</span>
              <span class="shop-card__value">{{ shop.city }}</span>
            </div>
            <div class="view-desktop-only shop-card__row">
              <span class="shop-card__label">Address</span>
              <span class="shop-card__value">{{ shop.address }}</span>
            </div>
            <div class="view-desktop-only shop-card__row">
              <span class="shop-card__label">Email</span>
              <span class="shop-card__value">{{ shop.email || '—' }}</span>
            </div>
            <div class="view-desktop-only shop-card__row">
              <span class="shop-card__label">Phone</span>
              <span class="shop-card__value">{{ shop.phoneNumber || '—' }}</span>
            </div>
            @if (hasSecondaryMeta(shop)) {
              <div class="shop-card__row shop-card__row--stats">
                @if (shop.reviewCount > 0) {
                  <span class="shop-card__rating">
                    <app-star-rating [rating]="roundedRating(shop)" [readonly]="true" />
                    <span class="shop-card__value">{{ shop.averageRating!.toFixed(1) }} ({{ shop.reviewCount }})</span>
                  </span>
                }
                @if (shop.memberCount != null && shop.memberCount > 0) {
                  @if (shop.reviewCount > 0) {
                    <span class="shop-card__meta-sep">·</span>
                  }
                  <span class="shop-card__value">{{ shop.memberCount }} member{{ shop.memberCount === 1 ? '' : 's' }}</span>
                }
              </div>
            }
          </div>
        </div>
        @if (canManage(shop)) {
          <div class="shop-card__actions" (click)="$event.stopPropagation()">
            <button type="button" class="btn btn-sm btn-secondary" (click)="onEdit(shop)">Edit</button>
            <button type="button" class="btn btn-sm btn-danger" (click)="onDelete(shop)">Delete</button>
          </div>
        }
      </div>
    </ng-template>
  `,
  styles: `
    :host {
      display: block;
      min-height: 100%;
    }

    .shops-page {
      display: flex;
      flex-direction: column;
      box-sizing: border-box;
    }

    .shops-page__content {
      flex: 1 1 auto;
    }

    .shops-page__footer {
      flex-shrink: 0;
      margin-top: auto;
    }

    .shops-page .shop-card-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
      gap: 1rem;
      margin-bottom: 1rem;
    }

    .shops-page .shops-section-title + .shop-card-grid:last-of-type {
      margin-bottom: 0;
    }

    .shops-page .shops-section-title {
      margin-bottom: 0.75rem;
    }

    .shops-page .shop-card {
      display: flex;
      flex-direction: column;
      padding: 1rem;
    }

    .shops-page .shop-card .btn-favourite {
      top: 0.5rem;
      right: 0.5rem;
    }

    .shop-card__body {
      flex: 1;
      min-width: 0;
      padding-right: 1.75rem;
    }

    .shop-card__title {
      color: #fff;
      font-size: 1rem;
      font-weight: 600;
      margin: 0 0 0.5rem;
      line-height: 1.3;
      display: -webkit-box;
      -webkit-box-orient: vertical;
      -webkit-line-clamp: 2;
      overflow: hidden;
    }

    .shop-card__details {
      display: flex;
      flex-direction: column;
      gap: 0.2rem;
    }

    .shop-card__row {
      display: grid;
      grid-template-columns: 4.25rem minmax(0, 1fr);
      gap: 0.1rem 0.5rem;
      align-items: start;
      font-size: 0.8125rem;
      line-height: 1.35;
    }

    .shop-card__label {
      color: #888;
      flex-shrink: 0;
    }

    .shop-card__value {
      color: #aaa;
      min-width: 0;
      word-break: break-word;
      display: -webkit-box;
      -webkit-box-orient: vertical;
      -webkit-line-clamp: 2;
      overflow: hidden;
    }

    .shop-card__row--stats {
      display: flex;
      align-items: center;
      gap: 0.35rem;
      flex-wrap: wrap;
      grid-column: 1 / -1;
      margin-top: 0.15rem;
    }

    .shop-card__row--stats .shop-card__value {
      display: inline;
      -webkit-line-clamp: unset;
      overflow: visible;
      word-break: normal;
    }

    .shop-card__rating {
      display: inline-flex;
      align-items: center;
      gap: 0.25rem;
      flex-shrink: 0;
    }

    .shop-card__rating app-star-rating {
      font-size: 0.75rem;
    }

    .shop-card__meta-sep {
      flex-shrink: 0;
      color: #666;
    }

    .shop-card__actions {
      display: flex;
      justify-content: flex-end;
      gap: 0.5rem;
      margin-top: auto;
      padding-top: 0.75rem;
    }

    .shops-form-wrapper {
      display: flex;
      justify-content: center;
    }

    .shops-form-wrapper .form-card {
      width: 100%;
      max-width: 560px;
      padding: 1.75rem;
    }

    .shop-form-group--name,
    .shop-form-group--email,
    .shop-form-group--phone {
      margin-bottom: 1.1rem;
    }

    .shop-form-row--address-city {
      display: grid;
      grid-template-columns: 2fr 1fr;
      gap: 1rem;
      margin-bottom: 1.1rem;
    }

    @media (max-width: 640px) {
      .shop-form-row--address-city {
        grid-template-columns: 1fr;
      }
    }

    .shops-form-actions {
      margin-top: 1.25rem;
    }
  `,
})
export class ShopsComponent implements OnInit {
  private readonly fb = inject(FormBuilder);
  private readonly shopService = inject(ShopService);
  private readonly authService = inject(AuthService);
  private readonly profileService = inject(ProfileService);
  private readonly router = inject(Router);
  private readonly dialog = inject(DialogService);
  private readonly injector = inject(Injector);

  readonly shops = signal<ShopResponseDto[]>([]);
  readonly loading = signal(true);
  readonly showForm = signal(false);
  readonly editingId = signal<string | null>(null);
  readonly togglingFavouriteId = signal<string | null>(null);
  readonly searchInput = signal('');
  readonly currentPage = signal(0);
  readonly pageSizeOptions = [10, 25, 50] as const;
  readonly pageSize = signal(10);
  readonly totalElements = signal(0);
  readonly totalPages = signal(1);

  readonly favouriteShopsList = computed(() => {
    const favIds = new Set(
      this.profileService.currentUser()?.favouriteShops?.map(s => s.id) ?? [],
    );
    return this.shops().filter(s => favIds.has(s.id));
  });

  readonly otherShopsList = computed(() => {
    const favIds = new Set(
      this.profileService.currentUser()?.favouriteShops?.map(s => s.id) ?? [],
    );
    return this.shops().filter(s => !favIds.has(s.id));
  });

  readonly form = this.fb.nonNullable.group({
    name: ['', Validators.required],
    address: ['', Validators.required],
    city: ['', Validators.required],
    phoneNumber: [''],
    email: [''],
  });

  constructor() {
    toObservable(this.searchInput, { injector: this.injector })
      .pipe(skip(1), debounceTime(300), distinctUntilChanged(), takeUntilDestroyed())
      .subscribe(() => {
        this.currentPage.set(0);
        this.loadShops();
      });
  }

  ngOnInit(): void {
    this.loadShops();
  }

  onSearchInput(inputEvent: Event): void {
    const value = (inputEvent.target as HTMLInputElement).value;
    this.searchInput.set(value);
  }

  onPageSizeChange(event: Event): void {
    const value = Number((event.target as HTMLSelectElement).value);
    if (!this.pageSizeOptions.includes(value as (typeof this.pageSizeOptions)[number])) {
      return;
    }
    this.pageSize.set(value);
    this.currentPage.set(0);
    this.loadShops();
  }

  loadShops(options?: { silent?: boolean }): void {
    const silent = options?.silent ?? false;
    if (!silent) {
      this.loading.set(true);
    }
    const q = this.searchInput().trim();
    this.shopService
      .search({
        q: q || undefined,
        page: this.currentPage(),
        size: this.pageSize(),
      })
      .subscribe({
        next: page => {
          this.shops.set(page.content);
          this.totalElements.set(page.totalElements);
          this.totalPages.set(Math.max(1, page.totalPages));
          if (!silent) {
            this.loading.set(false);
          }
        },
        error: () => {
          if (!silent) {
            this.loading.set(false);
          }
        },
      });
  }

  goToPage(page: number): void {
    if (page < 0 || page >= this.totalPages()) return;
    this.currentPage.set(page);
    this.loadShops();
  }

  rangeLabel(): string {
    const total = this.totalElements();
    if (total === 0) return '';
    const start = this.currentPage() * this.pageSize() + 1;
    const end = Math.min((this.currentPage() + 1) * this.pageSize(), total);
    return `Showing ${start}–${end} of ${total}`;
  }

  emptyStateMessage(): string {
    if (this.searchInput().trim()) return 'No shops match your search.';
    return 'No shops yet. Create one to get started!';
  }

  hasSecondaryMeta(shop: ShopResponseDto): boolean {
    return shop.reviewCount > 0 || (shop.memberCount != null && shop.memberCount > 0);
  }

  canManage(shop: ShopResponseDto): boolean {
    const profile = this.profileService.currentUser();
    if (!profile) return false;
    return this.authService.isAdmin()
      || shop.createdBy?.id === profile.id;
  }

  canCreateShop(): boolean {
    const profile = this.profileService.currentUser();
    if (!profile) return false;
    return this.authService.isAdmin() || profile.userType === 'SHOP_OWNER';
  }

  canShowForm(): boolean {
    const id = this.editingId();
    if (id) {
      const shop = this.shops().find(s => s.id === id);
      return shop ? this.canManage(shop) : false;
    }
    return this.canCreateShop();
  }

  goToShop(id: string): void {
    this.router.navigate(['/shops', id]);
  }

  isFavourite(shop: ShopResponseDto): boolean {
    const favIds = this.profileService.currentUser()?.favouriteShops?.map(s => s.id) ?? [];
    return favIds.includes(shop.id);
  }

  toggleFavourite(shop: ShopResponseDto, event: Event): void {
    event.stopPropagation();
    if (this.canManage(shop) || this.togglingFavouriteId() === shop.id) return;

    this.togglingFavouriteId.set(shop.id);
    const op = this.isFavourite(shop)
      ? this.shopService.removeFavourite(shop.id)
      : this.shopService.addFavourite(shop.id);

    op.subscribe({
      next: updatedShop => {
        this.togglingFavouriteId.set(null);
        this.shops.update(current =>
          current.map(s => (s.id === updatedShop.id ? { ...s, ...updatedShop } : s)),
        );
      },
      error: () => this.togglingFavouriteId.set(null),
    });
  }

  roundedRating(shop: ShopResponseDto): number {
    return Math.round(shop.averageRating ?? 0);
  }

  onSubmit(): void {
    if (this.form.invalid) return;
    const profile = this.profileService.currentUser();
    if (!profile) return;

    const val = this.form.getRawValue();
    const id = this.editingId();

    const op = id
      ? this.shopService.update(id, { ...val, createdByUserId: profile.id })
      : this.shopService.create({
          name: val.name,
          address: val.address,
          city: val.city,
          phoneNumber: val.phoneNumber,
        });

    op.subscribe(() => {
      this.cancelEdit();
      this.currentPage.set(0);
      this.loadShops();
    });
  }

  onEdit(shop: ShopResponseDto): void {
    this.editingId.set(shop.id);
    this.showForm.set(true);
    this.form.controls.email.setValidators([Validators.required, Validators.email]);
    this.form.controls.email.updateValueAndValidity();
    this.form.patchValue({
      name: shop.name,
      address: shop.address,
      city: shop.city,
      phoneNumber: shop.phoneNumber,
      email: shop.email,
    });
  }

  onDelete(shop: ShopResponseDto): void {
    void this.dialog
      .confirm(`Delete "${shop.name}"?`, { confirmLabel: 'Delete', confirmVariant: 'danger' })
      .then(ok => {
        if (!ok) return;
        this.shopService.delete(shop.id).subscribe(() => this.loadShops());
      });
  }

  cancelEdit(): void {
    this.editingId.set(null);
    this.showForm.set(false);
    this.form.controls.email.clearValidators();
    this.form.controls.email.updateValueAndValidity();
    this.form.reset({ name: '', address: '', city: '', phoneNumber: '', email: '' });
  }
}
