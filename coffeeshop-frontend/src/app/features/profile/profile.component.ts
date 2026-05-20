import { Component, computed, inject, signal, OnInit, ChangeDetectionStrategy } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { FormMultiSelectComponent } from '../../shared/form-multi-select/form-multi-select.component';
import { FormSelectOption } from '../../shared/form-select/form-select-option.model';
import { ProfileService } from '../../services/profile.service';
import { UserService } from '../../services/user.service';
import { ShopService } from '../../services/shop.service';
import { UserResponseDto } from '../../models/user.model';
import { ShopSummaryDto } from '../../models/shop.model';

@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [ReactiveFormsModule, FormMultiSelectComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="page">
      <div class="page-header">
        <h1 class="page-title">Profile</h1>
        @if (!editing()) {
          <button class="btn btn-primary" (click)="startEdit()">Edit Profile</button>
        }
      </div>

      @if (loading()) {
        <div class="loading">Loading profile...</div>
      } @else if (!user()) {
        <div class="empty-state"><p>Could not load profile.</p></div>
      } @else if (editing()) {
        <div class="form-card">
          @if (errorMessage()) {
            <div class="error-message">{{ errorMessage() }}</div>
          }
          <form [formGroup]="form" (ngSubmit)="onSubmit()">
            <div class="form-row">
              <div class="form-group">
                <label>Name</label>
                <input class="form-input" formControlName="name" />
              </div>
              <div class="form-group">
                <label>Email</label>
                <input class="form-input" type="email" formControlName="email" />
              </div>
            </div>
            <div class="form-group">
              <label>Favourite Shops</label>
              <app-form-multi-select
                formControlName="favouriteShopIds"
                placeholder="Select favourite shops"
                [options]="favouriteShopSelectOptions()"
              />
            </div>
            <div class="form-actions">
              <button type="submit" class="btn btn-primary" [disabled]="form.invalid">Save</button>
              <button type="button" class="btn btn-secondary" (click)="editing.set(false)">Cancel</button>
            </div>
          </form>
        </div>
      } @else {
        <div class="card" style="max-width:600px">
          <div style="display:grid;gap:1rem">
            <div>
              <span class="text-muted" style="font-size:0.75rem;display:block">Name</span>
              <span style="color:#fff">{{ user()!.name }}</span>
            </div>
            <div>
              <span class="text-muted" style="font-size:0.75rem;display:block">Email</span>
              <span style="color:#fff">{{ user()!.email }}</span>
            </div>
            <div>
              <span class="text-muted" style="font-size:0.75rem;display:block">Account Type</span>
              <span class="badge badge-role">{{ user()!.userType }}</span>
            </div>
            <div>
              <span class="text-muted" style="font-size:0.75rem;display:block">Roles</span>
              @for (role of user()!.roles; track role.id) {
                <span class="badge badge-role" style="margin-right:0.25rem">{{ role.name }}</span>
              } @empty {
                <span class="text-muted">None</span>
              }
            </div>
            <div>
              <span class="text-muted" style="font-size:0.75rem;display:block">Favourite Shops</span>
              @for (shop of user()!.favouriteShops; track shop.id) {
                <span class="badge badge-pending" style="margin-right:0.25rem">{{ shop.name }}</span>
              } @empty {
                <span class="text-muted">None</span>
              }
            </div>
          </div>
        </div>
      }
    </div>
  `,
})
export class ProfileComponent implements OnInit {
  private readonly fb = inject(FormBuilder);
  private readonly profileService = inject(ProfileService);
  private readonly userService = inject(UserService);
  private readonly shopService = inject(ShopService);

  readonly user = signal<UserResponseDto | null>(null);
  readonly allShops = signal<ShopSummaryDto[]>([]);
  readonly favouriteShopSelectOptions = computed((): FormSelectOption[] =>
    this.allShops().map(s => ({ value: s.id, label: s.name })),
  );
  readonly loading = signal(true);
  readonly editing = signal(false);
  readonly errorMessage = signal('');

  readonly form = this.fb.nonNullable.group({
    name: ['', Validators.required],
    email: ['', [Validators.required, Validators.email]],
    favouriteShopIds: [[] as string[]],
  });

  ngOnInit(): void {
    this.profileService.getProfile().subscribe({
      next: (user) => {
        this.user.set(user);
        this.loading.set(false);
      },
      error: () => this.loading.set(false),
    });
    this.shopService.getAll().subscribe(shops => this.allShops.set(shops));
  }

  startEdit(): void {
    const u = this.user();
    if (!u) return;
    this.editing.set(true);
    this.form.patchValue({
      name: u.name,
      email: u.email,
      favouriteShopIds: u.favouriteShops?.map(s => s.id) ?? [],
    });
  }

  onSubmit(): void {
    if (this.form.invalid) return;
    const u = this.user();
    if (!u) return;
    this.errorMessage.set('');

    const val = this.form.getRawValue();
    this.userService.update(u.id, {
      name: val.name,
      email: val.email,
      userType: u.userType,
      roleIds: u.roles.map(r => r.id),
      favouriteShopIds: val.favouriteShopIds,
    }).subscribe({
      next: () => {
        this.editing.set(false);
        this.profileService.getProfile().subscribe(user => this.user.set(user));
      },
      error: (err) => {
        this.errorMessage.set(err.error?.message ?? 'Update failed.');
      },
    });
  }
}
