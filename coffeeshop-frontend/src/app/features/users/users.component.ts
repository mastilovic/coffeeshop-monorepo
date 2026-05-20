import { Component, inject, signal, OnInit, ChangeDetectionStrategy } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { FormSelectComponent } from '../../shared/form-select/form-select.component';
import { FormSelectOption } from '../../shared/form-select/form-select-option.model';
import { UserService } from '../../services/user.service';
import { AuthService } from '../../services/auth.service';
import { ProfileService } from '../../services/profile.service';
import { UserResponseDto } from '../../models/user.model';
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
                <label>Email</label>
                <input class="form-input" type="email" formControlName="email" />
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

      @if (loading()) {
        <div class="loading">Loading users...</div>
      } @else if (users().length === 0) {
        <div class="empty-state"><p>No users found.</p></div>
      } @else {
        <div class="table-container">
          <table class="data-table">
            <thead>
              <tr>
                <th>Name</th>
                <th>Email</th>
                <th>Type</th>
                <th>Roles</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              @for (user of users(); track user.id) {
                <tr>
                  <td>{{ user.name }}</td>
                  <td>{{ user.email }}</td>
                  <td><span class="badge badge-role">{{ user.userType }}</span></td>
                  <td>
                    @for (role of user.roles; track role.id) {
                      <span class="badge badge-role" style="margin-right:0.25rem">{{ role.name }}</span>
                    }
                  </td>
                  <td>
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
      }
    </div>
  `,
})
export class UsersComponent implements OnInit {
  readonly userTypeSelectOptions = USER_TYPE_SELECT_OPTIONS;

  private readonly fb = inject(FormBuilder);
  private readonly userService = inject(UserService);
  private readonly authService = inject(AuthService);
  private readonly profileService = inject(ProfileService);
  private readonly dialog = inject(DialogService);

  readonly users = signal<UserResponseDto[]>([]);
  readonly loading = signal(true);
  readonly showForm = signal(false);
  readonly editingId = signal<string | null>(null);

  readonly form = this.fb.nonNullable.group({
    name: ['', Validators.required],
    email: ['', [Validators.required, Validators.email]],
    userType: ['CUSTOMER' as 'CUSTOMER' | 'SHOP_OWNER' | 'ADMIN'],
    roleIds: [[] as string[]],
  });

  ngOnInit(): void {
    this.userService.getAll().subscribe(users => {
      this.users.set(users);
      this.loading.set(false);
    });
  }

  isAdmin(): boolean {
    return this.authService.isAdmin();
  }

  canEdit(user: UserResponseDto): boolean {
    const profile = this.profileService.currentUser();
    return this.authService.isAdmin() || (!!profile && profile.id === user.id);
  }

  onEdit(user: UserResponseDto): void {
    this.editingId.set(user.id);
    this.showForm.set(true);
    this.form.patchValue({
      name: user.name,
      email: user.email,
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
      this.userService.getAll().subscribe(users => this.users.set(users));
    });
  }

  onDelete(user: UserResponseDto): void {
    void this.dialog
      .confirm(`Delete user "${user.name}"?`, { confirmLabel: 'Delete', confirmVariant: 'danger' })
      .then(ok => {
        if (!ok) return;
        this.userService.delete(user.id).subscribe(() => {
          this.users.update(list => list.filter(u => u.id !== user.id));
        });
      });
  }

  cancelEdit(): void {
    this.editingId.set(null);
    this.showForm.set(false);
    this.form.reset();
  }
}
