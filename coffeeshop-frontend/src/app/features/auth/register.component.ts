import { Component, inject, signal, ChangeDetectionStrategy } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { FormSelectComponent } from '../../shared/form-select/form-select.component';
import { FormSelectOption } from '../../shared/form-select/form-select-option.model';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { ProfileService } from '../../services/profile.service';

const ROLE_SELECT_OPTIONS: FormSelectOption[] = [
  { value: 'customer', label: 'Customer' },
  { value: 'shop_owner', label: 'Shop Owner' },
];

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [ReactiveFormsModule, RouterLink, FormSelectComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="auth-page">
      <div class="auth-card">
        <h1 class="auth-title">Create Account</h1>
        <p class="auth-subtitle">Join CoffeeShop today</p>

        @if (errorMessage()) {
          <div class="error-message">{{ errorMessage() }}</div>
        }

        <form [formGroup]="form" (ngSubmit)="onSubmit()">
          <div class="form-group">
            <label for="name">Name</label>
            <input id="name" type="text" class="form-input" formControlName="name"
                   placeholder="Your full name" />
          </div>

          <div class="form-group">
            <label for="email">Email</label>
            <input id="email" type="email" class="form-input" formControlName="email"
                   placeholder="you@example.com" />
          </div>

          <div class="form-group">
            <label for="password">Password</label>
            <input id="password" type="password" class="form-input" formControlName="password"
                   placeholder="Choose a password" />
          </div>

          <div class="form-group">
            <label for="role">Account Type</label>
            <app-form-select
              inputId="role"
              formControlName="role"
              placeholder="Account type"
              [options]="roleSelectOptions"
            />
          </div>

          <div class="form-actions">
            <button type="submit" class="btn btn-primary btn-block" [disabled]="loading()">
              {{ loading() ? 'Creating account...' : 'Create Account' }}
            </button>
          </div>
        </form>

        <p class="auth-footer">
          Already have an account? <a routerLink="/login">Sign in</a>
        </p>
      </div>
    </div>
  `,
})
export class RegisterComponent {
  readonly roleSelectOptions = ROLE_SELECT_OPTIONS;

  private readonly fb = inject(FormBuilder);
  private readonly authService = inject(AuthService);
  private readonly profileService = inject(ProfileService);
  private readonly router = inject(Router);

  readonly errorMessage = signal('');
  readonly loading = signal(false);

  readonly form = this.fb.nonNullable.group({
    name: ['', Validators.required],
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(6)]],
    role: ['customer' as 'customer' | 'shop_owner'],
  });

  onSubmit(): void {
    if (this.form.invalid) return;
    this.loading.set(true);
    this.errorMessage.set('');

    const { name, email, password, role } = this.form.getRawValue();
    this.authService.registerAndLogin(name, email, password, role).subscribe({
      next: () => {
        this.loading.set(false);
        this.profileService.getProfile().subscribe();
        void this.router.navigate(['/'], { replaceUrl: true });
      },
      error: (err: { status?: number; error?: { message?: string }; registrationCompleted?: boolean }) => {
        this.loading.set(false);
        if (err.registrationCompleted) {
          this.errorMessage.set(
            'Account created, but automatic sign-in failed. Please sign in manually.',
          );
          void this.router.navigate(['/login']);
          return;
        }
        const status = err.status;
        if (status === 409) {
          this.errorMessage.set('An account with this email already exists.');
        } else if (status === 403) {
          this.errorMessage.set('You cannot register with this role.');
        } else {
          this.errorMessage.set(err.error?.message ?? 'Registration failed. Please try again.');
        }
      },
    });
  }
}
