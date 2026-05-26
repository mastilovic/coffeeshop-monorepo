import {
  Component,
  inject,
  Injector,
  signal,
  OnInit,
  ChangeDetectionStrategy,
} from '@angular/core';
import { takeUntilDestroyed, toObservable } from '@angular/core/rxjs-interop';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { debounceTime, distinctUntilChanged, skip } from 'rxjs';
import { FormSelectComponent } from '../../shared/form-select/form-select.component';
import { FormSelectOption } from '../../shared/form-select/form-select-option.model';
import { UserService } from '../../services/user.service';
import { AuthService } from '../../services/auth.service';
import { ProfileService } from '../../services/profile.service';
import { UserListItemDto } from '../../models/user.model';
import { DialogService } from '../../services/dialog.service';

const USER_TYPE_SELECT_OPTIONS: FormSelectOption[] = [
  { value: 'CUSTOMER', label: 'Customer' },
  { value: 'SHOP_OWNER', label: 'Shop Owner' },
  { value: 'ADMIN', label: 'Admin' },
];

@Component({
  selector: 'app-users',
  standalone: true,
  imports: [ReactiveFormsModule, FormSelectComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="page">
      <div class="page-header">
        <h1 class="page-title">Users</h1>
      </div>

      @if (showForm()) {
        <div class="form-card mb-3">
          <h3 style="color:#fff;margin-bottom:1rem">Edit User</h3>
          <form [formGroup]="form" (ngSubmit)="onSubmit()">
            <div class="form-row">
              <div class="form-group">
                <label>Name</label>
                <input class="form-input" formControlName="name" />
              </div>
              <div class="form-group">
                <label>Username</label>
                <input class="form-input" formControlName="username" />
              </div>
            </div>
            <div class="form-group">
              <label>User Type</label>
              <app-form-select
                formControlName="userType"
                placeholder="User type"
                [options]="userTypeSelectOptions"
              />
            </div>
            <div class="form-actions">
              <button type="submit" class="btn btn-primary" [disabled]="form.invalid">Update</button>
              <button type="button" class="btn btn-secondary" (click)="cancelEdit()">Cancel</button>
            </div>
          </form>
        </div>
      }

      <div class="events-toolbar mb-3">
        <input
          class="form-input events-search"
          type="search"
          placeholder="Search by name or username..."
          aria-label="Search users"
          [value]="searchInput()"
          (input)="onSearchInput($event)"
        />
      </div>

      @if (loading()) {
        <div class="loading">Loading users...</div>
      } @else if (totalElements() === 0) {
        <div class="empty-state"><p>{{ emptyStateMessage() }}</p></div>
      } @else {
        <div class="view-mobile-only list-card-grid mb-3">
          @for (user of users(); track user.id) {
            <article class="list-card">
              <div class="list-card__primary">
                <span class="list-card__title">{{ user.name }}</span>
                <span class="list-card__subtitle">{{ user.username }}</span>
              </div>
              <div class="list-card__meta">
                <span class="badge badge-role">{{ user.userType }}</span>
                @for (role of user.roles; track role.id) {
                  <span class="badge badge-role">{{ role.name }}</span>
                }
              </div>
              @if (canEdit(user) || isAdmin()) {
                <div class="list-card__actions">
                  @if (canEdit(user)) {
                    <button class="btn btn-sm btn-secondary" (click)="onEdit(user)">Edit</button>
                  }
                  @if (isAdmin()) {
                    <button class="btn btn-sm btn-danger" (click)="onDelete(user)">Delete</button>
                  }
                </div>
              }
            </article>
          }
        </div>
        <div class="view-desktop-only">
          <div class="table-container">
            <table class="data-table">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Username</th>
                  <th>Type</th>
                  <th>Roles</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                @for (user of users(); track user.id) {
                  <tr>
                    <td>{{ user.name }}</td>
                    <td>{{ user.username }}</td>
                    <td><span class="badge badge-role">{{ user.userType }}</span></td>
                    <td>
                      @for (role of user.roles; track role.id) {
                        <span class="badge badge-role" style="margin-right:0.25rem">{{ role.name }}</span>
                      }
                    </td>
                    <td class="data-table__actions">
                      <div style="display:flex;gap:0.5rem">
                        @if (canEdit(user)) {
                          <button class="btn btn-sm btn-secondary" (click)="onEdit(user)">Edit</button>
                        }
                        @if (isAdmin()) {
                          <button class="btn btn-sm btn-danger" (click)="onDelete(user)">Delete</button>
                        }
                      </div>
                    </td>
                  </tr>
                }
              </tbody>
            </table>
          </div>
        </div>

        <div class="pagination-bar">
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
})
export class UsersComponent implements OnInit {
  readonly userTypeSelectOptions = USER_TYPE_SELECT_OPTIONS;

  private readonly fb = inject(FormBuilder);
  private readonly injector = inject(Injector);
  private readonly userService = inject(UserService);
  private readonly authService = inject(AuthService);
  private readonly profileService = inject(ProfileService);
  private readonly dialog = inject(DialogService);

  readonly users = signal<UserListItemDto[]>([]);
  readonly loading = signal(true);
  readonly showForm = signal(false);
  readonly editingId = signal<string | null>(null);
  readonly searchInput = signal('');
  readonly currentPage = signal(0);
  readonly pageSize = 10;
  readonly totalElements = signal(0);
  readonly totalPages = signal(1);

  readonly form = this.fb.nonNullable.group({
    name: ['', Validators.required],
    username: ['', [Validators.required, Validators.pattern(/^[a-zA-Z0-9_]{3,30}$/)]],
    userType: ['CUSTOMER' as 'CUSTOMER' | 'SHOP_OWNER' | 'ADMIN'],
    roleIds: [[] as string[]],
  });

  constructor() {
    toObservable(this.searchInput, { injector: this.injector })
      .pipe(skip(1), debounceTime(300), distinctUntilChanged(), takeUntilDestroyed())
      .subscribe(() => {
        this.currentPage.set(0);
        this.loadUsers();
      });
  }

  ngOnInit(): void {
    this.loadUsers();
  }

  emptyStateMessage(): string {
    if (this.searchInput().trim()) return 'No users match your search.';
    return 'No users found.';
  }

  onSearchInput(inputEvent: Event): void {
    const value = (inputEvent.target as HTMLInputElement).value;
    this.searchInput.set(value);
  }

  loadUsers(): void {
    this.loading.set(true);
    const q = this.searchInput().trim();
    this.userService
      .list({
        q: q || undefined,
        page: this.currentPage(),
        size: this.pageSize,
      })
      .subscribe({
        next: page => {
          this.users.set(page.content);
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
    this.loadUsers();
  }

  rangeLabel(): string {
    const total = this.totalElements();
    if (total === 0) return '';
    const start = this.currentPage() * this.pageSize + 1;
    const end = Math.min((this.currentPage() + 1) * this.pageSize, total);
    return `Showing ${start}–${end} of ${total}`;
  }

  isAdmin(): boolean {
    return this.authService.isAdmin();
  }

  canEdit(user: UserListItemDto): boolean {
    const profile = this.profileService.currentUser();
    return this.authService.isAdmin() || (!!profile && profile.id === user.id);
  }

  onEdit(user: UserListItemDto): void {
    this.editingId.set(user.id);
    this.showForm.set(true);
    this.form.patchValue({
      name: user.name,
      username: user.username,
      userType: user.userType,
      roleIds: user.roles.map(r => r.id),
    });
  }

  onSubmit(): void {
    if (this.form.invalid) return;
    const id = this.editingId();
    if (!id) return;
    const val = this.form.getRawValue();
    this.userService.update(id, val).subscribe(() => {
      this.cancelEdit();
      this.loadUsers();
    });
  }

  onDelete(user: UserListItemDto): void {
    void this.dialog
      .confirm(`Delete user "${user.name}"?`, { confirmLabel: 'Delete', confirmVariant: 'danger' })
      .then(ok => {
        if (!ok) return;
        this.userService.delete(user.id).subscribe(() => this.loadUsers());
      });
  }

  cancelEdit(): void {
    this.editingId.set(null);
    this.showForm.set(false);
    this.form.reset();
  }
}
