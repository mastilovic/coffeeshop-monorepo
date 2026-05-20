import { Component, inject, signal, computed, OnInit, ChangeDetectionStrategy } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
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
  imports: [ReactiveFormsModule, StarRatingComponent, CitySearchSelectComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="page">
      <div class="page-header">
        <h1 class="page-title">Shops</h1>
        @if (canCreateShop()) {
          <button class="btn btn-primary" (click)="showForm.set(!showForm())">
            {{ showForm() ? 'Cancel' : '+ New Shop' }}
          </button>
        }
      </div>

      @if (showForm() && canShowForm()) {
        <div class="form-card mb-3">
          <form [formGroup]="form" (ngSubmit)="onSubmit()">
            <div class="form-row">
              <div class="form-group">
                <label>Name</label>
                <input class="form-input" formControlName="name" placeholder="Shop name" />
              </div>
              @if (editingId()) {
                <div class="form-group">
                  <label>Email</label>
                  <input class="form-input" type="email" formControlName="email" placeholder="shop@example.com" />
                </div>
              }
            </div>
            <div class="form-row">
              <div class="form-group">
                <label>Address</label>
                <input class="form-input" formControlName="address" placeholder="Street address" />
              </div>
              <div class="form-group">
                <label>City</label>
                <app-city-search-select formControlName="city" />
              </div>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label>Phone</label>
                <input class="form-input" formControlName="phoneNumber" placeholder="+1 234 567 890" />
              </div>
            </div>
            <div class="form-actions">
              <button type="submit" class="btn btn-primary" [disabled]="form.invalid">
                {{ editingId() ? 'Update' : 'Create' }}
              </button>
              @if (editingId()) {
                <button type="button" class="btn btn-secondary" (click)="cancelEdit()">Cancel</button>
              }
            </div>
          </form>
        </div>
      }

      @if (loading()) {
        <div class="loading">Loading shops...</div>
      } @else if (shops().length === 0) {
        <div class="empty-state"><p>No shops yet. Create one to get started!</p></div>
      } @else {
        @if (favouriteShopsList().length > 0) {
          <h2 class="shops-section-title">Your communities</h2>
          <div class="card-grid">
          @for (shop of favouriteShopsList(); track shop.id) {
            <div class="card clickable shop-card" (click)="goToShop(shop.id)">
              @if (!canManage(shop)) {
                <button
                  type="button"
                  class="btn btn-icon btn-favourite"
                  [class.btn-favourite--active]="isFavourite(shop)"
                  [attr.aria-label]="isFavourite(shop) ? 'Leave ' + shop.name : 'Join ' + shop.name"
                  [title]="isFavourite(shop) ? 'Leave ' + shop.name : 'Join ' + shop.name"
                  (click)="toggleFavourite(shop, $event)"
                >
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                    @if (isFavourite(shop)) {
                      <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
                    } @else {
                      <path d="M16.5 3c-1.74 0-3.41.81-4.5 2.09C10.91 3.81 9.24 3 7.5 3 4.42 3 2 5.42 2 8.5c0 3.78 3.4 6.86 8.55 11.54L12 21.35l1.45-1.32C18.6 15.36 22 12.28 22 8.5 22 5.42 19.58 3 16.5 3zm-4.4 15.55l-.1.1-.1-.1C7.14 14.24 4 11.39 4 8.5 4 6.5 5.5 5 7.5 5c1.54 0 3.04.99 3.57 2.36h1.87C13.46 5.99 14.96 5 16.5 5c2 0 3.5 1.5 3.5 3.5 0 2.89-3.14 5.74-7.9 10.05z"/>
                    }
                  </svg>
                </button>
              }
              <h3 style="color:#fff;margin-bottom:0.5rem">
                {{ shop.name }}
                @if (isFavourite(shop)) {
                  <span class="badge badge-joined">Joined</span>
                }
              </h3>
              @if (shop.memberCount != null && shop.memberCount > 0) {
                <p class="text-muted" style="font-size:0.875rem;margin-bottom:0.5rem">{{ shop.memberCount }} community member{{ shop.memberCount === 1 ? '' : 's' }}</p>
              }
              @if (shop.reviewCount > 0) {
                <div style="display:flex;align-items:center;gap:0.5rem;margin-bottom:0.5rem">
                  <app-star-rating [rating]="roundedRating(shop)" [readonly]="true" />
                  <span class="text-muted" style="font-size:0.875rem">
                    {{ shop.averageRating!.toFixed(1) }} ({{ shop.reviewCount }})
                  </span>
                </div>
              }
              <p class="text-muted" style="font-size:0.875rem;margin-bottom:0.25rem">{{ shop.city }} &middot; {{ shop.address }}</p>
              <p class="text-muted" style="font-size:0.875rem;margin-bottom:0.25rem">{{ shop.email }}</p>
              <p class="text-muted" style="font-size:0.875rem">{{ shop.phoneNumber }}</p>
              @if (canManage(shop)) {
                <div style="display:flex;gap:0.5rem;margin-top:1rem" (click)="$event.stopPropagation()">
                  <button class="btn btn-sm btn-secondary" (click)="onEdit(shop)">Edit</button>
                  <button class="btn btn-sm btn-danger" (click)="onDelete(shop)">Delete</button>
                </div>
              }
            </div>
          }
          </div>
        }
        @if (otherShopsList().length > 0) {
          <h2 class="shops-section-title">{{ favouriteShopsList().length > 0 ? 'All shops' : 'Shops' }}</h2>
          <div class="card-grid">
          @for (shop of otherShopsList(); track shop.id) {
            <div class="card clickable shop-card" (click)="goToShop(shop.id)">
              @if (!canManage(shop)) {
                <button
                  type="button"
                  class="btn btn-icon btn-favourite"
                  [class.btn-favourite--active]="isFavourite(shop)"
                  [attr.aria-label]="isFavourite(shop) ? 'Leave ' + shop.name : 'Join ' + shop.name"
                  [title]="isFavourite(shop) ? 'Leave ' + shop.name : 'Join ' + shop.name"
                  (click)="toggleFavourite(shop, $event)"
                >
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                    @if (isFavourite(shop)) {
                      <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
                    } @else {
                      <path d="M16.5 3c-1.74 0-3.41.81-4.5 2.09C10.91 3.81 9.24 3 7.5 3 4.42 3 2 5.42 2 8.5c0 3.78 3.4 6.86 8.55 11.54L12 21.35l1.45-1.32C18.6 15.36 22 12.28 22 8.5 22 5.42 19.58 3 16.5 3zm-4.4 15.55l-.1.1-.1-.1C7.14 14.24 4 11.39 4 8.5 4 6.5 5.5 5 7.5 5c1.54 0 3.04.99 3.57 2.36h1.87C13.46 5.99 14.96 5 16.5 5c2 0 3.5 1.5 3.5 3.5 0 2.89-3.14 5.74-7.9 10.05z"/>
                    }
                  </svg>
                </button>
              }
              <h3 style="color:#fff;margin-bottom:0.5rem">
                {{ shop.name }}
                @if (isFavourite(shop)) {
                  <span class="badge badge-joined">Joined</span>
                }
              </h3>
              @if (shop.memberCount != null && shop.memberCount > 0) {
                <p class="text-muted" style="font-size:0.875rem;margin-bottom:0.5rem">{{ shop.memberCount }} community member{{ shop.memberCount === 1 ? '' : 's' }}</p>
              }
              @if (shop.reviewCount > 0) {
                <div style="display:flex;align-items:center;gap:0.5rem;margin-bottom:0.5rem">
                  <app-star-rating [rating]="roundedRating(shop)" [readonly]="true" />
                  <span class="text-muted" style="font-size:0.875rem">
                    {{ shop.averageRating!.toFixed(1) }} ({{ shop.reviewCount }})
                  </span>
                </div>
              }
              <p class="text-muted" style="font-size:0.875rem;margin-bottom:0.25rem">{{ shop.city }} &middot; {{ shop.address }}</p>
              <p class="text-muted" style="font-size:0.875rem;margin-bottom:0.25rem">{{ shop.email }}</p>
              <p class="text-muted" style="font-size:0.875rem">{{ shop.phoneNumber }}</p>
              @if (canManage(shop)) {
                <div style="display:flex;gap:0.5rem;margin-top:1rem" (click)="$event.stopPropagation()">
                  <button class="btn btn-sm btn-secondary" (click)="onEdit(shop)">Edit</button>
                  <button class="btn btn-sm btn-danger" (click)="onDelete(shop)">Delete</button>
                </div>
              }
            </div>
          }
          </div>
        }
      }
    </div>
  `,
})
export class ShopsComponent implements OnInit {
  private readonly fb = inject(FormBuilder);
  private readonly shopService = inject(ShopService);
  private readonly authService = inject(AuthService);
  private readonly profileService = inject(ProfileService);
  private readonly router = inject(Router);
  private readonly dialog = inject(DialogService);

  readonly shops = signal<ShopResponseDto[]>([]);
  readonly loading = signal(true);
  readonly showForm = signal(false);
  readonly editingId = signal<string | null>(null);
  readonly togglingFavouriteId = signal<string | null>(null);

  readonly favouriteShopsList = computed(() => {
    const favIds = new Set(
      this.profileService.currentUser()?.favouriteShops?.map(s => s.id) ?? [],
    );
    return this.sortedShops().filter(s => favIds.has(s.id));
  });

  readonly otherShopsList = computed(() => {
    const favIds = new Set(
      this.profileService.currentUser()?.favouriteShops?.map(s => s.id) ?? [],
    );
    return this.sortedShops().filter(s => !favIds.has(s.id));
  });

  readonly sortedShops = computed(() => {
    const favIds = new Set(
      this.profileService.currentUser()?.favouriteShops?.map(s => s.id) ?? [],
    );
    return [...this.shops()].sort((a, b) => {
      const aFav = favIds.has(a.id);
      const bFav = favIds.has(b.id);
      if (aFav !== bFav) return aFav ? -1 : 1;
      return a.name.localeCompare(b.name);
    });
  });

  readonly form = this.fb.nonNullable.group({
    name: ['', Validators.required],
    address: ['', Validators.required],
    city: ['', Validators.required],
    phoneNumber: [''],
    email: [''],
  });

  ngOnInit(): void {
    this.shopService.getAll().subscribe(shops => {
      this.shops.set(shops);
      this.loading.set(false);
    });
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
      next: updated => {
        this.shops.update(list => list.map(s => (s.id === shop.id ? updated : s)));
        this.togglingFavouriteId.set(null);
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
      this.shopService.getAll().subscribe(shops => this.shops.set(shops));
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
        this.shopService.delete(shop.id).subscribe(() => {
          this.shops.update(list => list.filter(s => s.id !== shop.id));
        });
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
