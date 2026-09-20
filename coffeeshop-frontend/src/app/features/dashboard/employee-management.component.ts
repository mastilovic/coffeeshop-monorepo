import { Component, computed, inject, input, OnInit, signal } from '@angular/core';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { debounceTime, distinctUntilChanged, switchMap } from 'rxjs';
import { NgFor, NgIf } from '@angular/common';
import { AuthService } from '../../services/auth.service';
import { ProfileService } from '../../services/profile.service';
import { ShopEmployeeService } from '../../services/shop-employee.service';
import { SubscriptionService } from '../../services/subscription.service';
import { UserService } from '../../services/user.service';
import { ShopEmployeeDto } from '../../models/shop-employee.model';
import { UserListItemDto } from '../../models/user.model';

@Component({
  selector: 'app-employee-management',
  standalone: true,
  imports: [ReactiveFormsModule, NgFor, NgIf, RouterLink],
  template: `
    <div class="employee-management">
      <h3>Employees</h3>

      <div class="employee-list">
        <div *ngIf="employees().length === 0" class="empty-state">No employees assigned yet.</div>
        <div *ngFor="let emp of employees()" class="employee-row">
          <div class="employee-info">
            <span class="employee-name">{{ emp.name }}</span>
            <span class="employee-email">{{ emp.email }}</span>
            <span *ngIf="emp.isOwner" class="owner-badge">Owner</span>
          </div>
          <button
            *ngIf="canManage() && !emp.isOwner"
            class="btn-remove"
            (click)="removeEmployee(emp)"
          >
            Remove
          </button>
        </div>
      </div>

      <div *ngIf="canManage()" class="add-employee">
        <div class="add-employee-header">
          <h4>Add Employee</h4>
          <span *ngIf="employeesQuotaLabel() as quota" class="quota-label">{{ quota }}</span>
        </div>
        <ng-container *ngIf="canAddEmployee(); else employeeUpgrade">
          <input
            type="text"
            [formControl]="searchControl"
            placeholder="Search users by name or email..."
            class="search-input"
          />
          <div *ngIf="searchResults().length > 0" class="search-results">
            <div
              *ngFor="let user of searchResults()"
              class="search-result-item"
              (click)="addEmployee(user)"
            >
              <span>{{ user.name }}</span>
              <span class="user-email">{{ user.username }}</span>
            </div>
          </div>
          <div *ngIf="searchControl.value && searchResults().length === 0 && !searching()" class="no-results">
            No users found.
          </div>
        </ng-container>
        <ng-template #employeeUpgrade>
          <p class="upgrade-hint">Employee seats require Growth or higher.</p>
          <a routerLink="/profile/billing" class="upgrade-link">Upgrade to Growth</a>
        </ng-template>
      </div>
    </div>
  `,
  styles: [`
    .employee-management {
      padding: 0.75rem;
    }
    .employee-list {
      margin-bottom: 1rem;
    }
    .employee-row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 0.5rem 0.75rem;
      border-bottom: 1px solid #2a2a3e;
      background: #1a1a2e;
    }
    .employee-info {
      display: flex;
      align-items: center;
      gap: 0.75rem;
      flex: 1;
      min-width: 0;
    }
    .employee-name {
      font-weight: 500;
      color: #e0e0e0;
      font-size: 0.875rem;
    }
    .employee-email {
      color: #888;
      font-size: 0.8125rem;
    }
    .owner-badge {
      background: rgba(212, 165, 116, 0.15);
      color: #d4a574;
      padding: 0.125rem 0.5rem;
      border-radius: 9999px;
      font-size: 0.6875rem;
      font-weight: 500;
    }
    .btn-remove {
      background: rgba(192, 57, 43, 0.15);
      color: #c0392b;
      border: 1px solid rgba(192, 57, 43, 0.3);
      padding: 0.25rem 0.5rem;
      border-radius: 6px;
      cursor: pointer;
      font-size: 0.75rem;
      font-family: inherit;
    }
    .btn-remove:hover {
      background: rgba(192, 57, 43, 0.25);
    }
    .empty-state {
      color: #888;
      padding: 0.75rem;
      text-align: center;
    }
    .add-employee {
      border-top: 1px solid #2a2a3e;
      padding-top: 0.75rem;
    }
    .search-input {
      width: 100%;
      padding: 0.5rem 0.75rem;
      border: 1px solid #2a2a3e;
      border-radius: 8px;
      margin-bottom: 0.5rem;
      background: #16213e;
      color: #e0e0e0;
      font-size: 0.875rem;
      font-family: inherit;
    }
    .search-input:focus {
      outline: none;
      border-color: #d4a574;
    }
    .search-results {
      border: 1px solid #2a2a3e;
      border-radius: 8px;
      max-height: 200px;
      overflow-y: auto;
      background: #16213e;
    }
    .search-result-item {
      padding: 0.5rem 0.75rem;
      cursor: pointer;
      display: flex;
      justify-content: space-between;
      align-items: center;
      color: #e0e0e0;
      font-size: 0.875rem;
    }
    .search-result-item:hover {
      background: #2a2a3e;
      color: #d4a574;
    }
    .user-email {
      color: #888;
      font-size: 0.75rem;
    }
    .no-results {
      color: #888;
      padding: 0.5rem;
      text-align: center;
      font-size: 0.875rem;
    }
    h3 {
      margin: 0 0 0.75rem;
      font-size: 1.125rem;
      color: #fff;
    }
    h4 {
      margin: 0 0 0.5rem;
      font-size: 1rem;
      color: #e0e0e0;
    }
    .add-employee-header {
      display: flex;
      align-items: baseline;
      justify-content: space-between;
      gap: 0.75rem;
      margin-bottom: 0.5rem;
    }
    .quota-label {
      font-size: 0.8125rem;
      color: #888;
    }
    .upgrade-hint {
      margin: 0 0 0.5rem;
      color: #888;
      font-size: 0.875rem;
    }
    .upgrade-link {
      font-size: 0.875rem;
      font-weight: 600;
      color: #d4a574;
      text-decoration: none;
    }
    .upgrade-link:hover {
      text-decoration: underline;
    }
  `],
})
export class EmployeeManagementComponent implements OnInit {
  shopId = input.required<string>();

  private readonly authService = inject(AuthService);
  private readonly profileService = inject(ProfileService);
  private readonly shopEmployeeService = inject(ShopEmployeeService);
  private readonly subscriptionService = inject(SubscriptionService);
  private readonly userService = inject(UserService);

  searchControl = new FormControl('', { nonNullable: true });

  employees = signal<ShopEmployeeDto[]>([]);
  searchResults = signal<UserListItemDto[]>([]);
  searching = signal(false);

  readonly canAddEmployee = computed(() => {
    if (!this.canManage()) return false;
    if (!this.subscriptionService.canUseFeature('employee_assign')) return false;
    const limit = this.subscriptionService.getLimit('employees');
    if (!limit || limit.max < 0) return true;
    return limit.used < limit.max;
  });

  readonly employeesQuotaLabel = computed(() => {
    if (!this.canManage()) return null;
    const limit = this.subscriptionService.getLimit('employees');
    if (!limit || limit.max < 0) return null;
    return `${limit.used} / ${limit.max} employees`;
  });

  ngOnInit(): void {
    this.loadEmployees();

    this.searchControl.valueChanges
      .pipe(
        debounceTime(300),
        distinctUntilChanged(),
        switchMap((query) => {
          if (!query || query.trim().length === 0) {
            this.searchResults.set([]);
            return [];
          }
          this.searching.set(true);
          return this.userService.list({ q: query, page: 0, size: 10 });
        }),
      )
      .subscribe({
        next: (page) => {
          this.searchResults.set(page.content ?? []);
          this.searching.set(false);
        },
        error: () => {
          this.searchResults.set([]);
          this.searching.set(false);
        },
      });
  }

  canManage(): boolean {
    if (this.authService.isAdmin()) return true;
    const profile = this.profileService.currentUser();
    if (!profile) return false;
    const employeeList = this.employees();
    return employeeList.some((e) => e.userId === profile.id && e.isOwner);
  }

  loadEmployees(): void {
    this.shopEmployeeService.getEmployees(this.shopId()).subscribe({
      next: (emps) => this.employees.set(emps),
    });
  }

  addEmployee(user: UserListItemDto): void {
    this.shopEmployeeService
      .assignEmployee({ shopId: this.shopId(), userId: user.id })
      .subscribe({
        next: () => {
          this.searchControl.setValue('');
          this.searchResults.set([]);
          this.loadEmployees();
        },
      });
  }

  removeEmployee(emp: ShopEmployeeDto): void {
    this.shopEmployeeService.removeEmployee(emp.shopId, emp.userId).subscribe({
      next: () => this.loadEmployees(),
    });
  }
}
