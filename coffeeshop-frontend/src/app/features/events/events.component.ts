import { Component, computed, inject, Injector, OnInit, signal, ChangeDetectionStrategy } from '@angular/core';
import { takeUntilDestroyed, toObservable } from '@angular/core/rxjs-interop';
import {
  AbstractControl,
  FormBuilder,
  ReactiveFormsModule,
  ValidationErrors,
  ValidatorFn,
  Validators,
} from '@angular/forms';
import { Router } from '@angular/router';
import { debounceTime, distinctUntilChanged, skip } from 'rxjs';
import { EventService } from '../../services/event.service';
import { ShopService } from '../../services/shop.service';
import { AuthService } from '../../services/auth.service';
import { ProfileService } from '../../services/profile.service';
import { EventResponseDto } from '../../models/event.model';
import { ShopResponseDto } from '../../models/shop.model';
import { todayIso } from '../../shared/calendar/calendar-date.utils';
import {
  DateRangePickerComponent,
  DateRangeValue,
} from '../../shared/date-range-picker/date-range-picker.component';
import { DateTimePickerComponent } from '../../shared/date-time-picker/date-time-picker.component';
import { FormSelectComponent } from '../../shared/form-select/form-select.component';
import { FormSelectOption } from '../../shared/form-select/form-select-option.model';
import { DialogService } from '../../services/dialog.service';

function futureDateValidator(): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    const value = control.value as string;
    if (!value) return null;
    const parsed = new Date(value);
    if (Number.isNaN(parsed.getTime())) return { invalidDate: true };
    if (parsed <= new Date()) return { pastDate: true };
    return null;
  };
}

@Component({
  selector: 'app-events',
  standalone: true,
  imports: [ReactiveFormsModule, DateRangePickerComponent, DateTimePickerComponent, FormSelectComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="page">
      <div class="page-header">
        <h1 class="page-title">Events</h1>
        @if (canCreateEvent()) {
          <button class="btn btn-primary" (click)="toggleForm()">
            {{ showForm() ? 'Cancel' : '+ Add Event' }}
          </button>
        }
      </div>

      @if (showForm() && canShowForm()) {
        <div class="form-card mb-3">
          <form [formGroup]="form" (ngSubmit)="onSubmit()">
            <div class="form-row">
              <div class="form-group">
                <label>Event Name</label>
                <input class="form-input" formControlName="eventName" placeholder="Event name" />
              </div>
              <div class="form-group">
                <label>Event Date</label>
                <app-date-time-picker
                  formControlName="eventDate"
                  [minDate]="editingId() ? null : todayIsoValue()"
                />
                @if (form.controls.eventDate.touched && form.controls.eventDate.hasError('pastDate')) {
                  <span class="form-error">Event date must be in the future.</span>
                }
              </div>
            </div>
            <div class="form-group">
              <label>Shop</label>
              <app-form-select
                formControlName="shopId"
                placeholder="Select shop"
                [options]="shopSelectOptions()"
              />
            </div>
            <div class="form-group">
              <label>Description</label>
              <input class="form-input" formControlName="description" placeholder="Event description" />
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

      <div class="events-toolbar mb-3">
        <input
          class="form-input events-search"
          type="search"
          placeholder="Search by name, shop, city, or description..."
          aria-label="Search events"
          [value]="searchInput()"
          (input)="onSearchInput($event)"
        />
        <app-date-range-picker
          [dateFrom]="dateFrom()"
          [dateTo]="dateTo()"
          (rangeChange)="onDateRangeChange($event)"
        />
      </div>

      @if (loading()) {
        <div class="loading">Loading events...</div>
      } @else if (totalElements() === 0) {
        <div class="empty-state">
          <p>{{ emptyStateMessage() }}</p>
        </div>
      } @else {
        <div class="table-container">
          <table class="data-table">
            <thead>
              <tr>
                <th>Name</th>
                <th>Shop</th>
                <th>City</th>
                <th>Date</th>
                <th>Description</th>
                <th>Availability</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              @for (event of events(); track event.eventId) {
                <tr>
                  <td>{{ event.eventName }}</td>
                  <td>{{ displayShopName(event) }}</td>
                  <td>{{ event.shopCity ?? '—' }}</td>
                  <td>{{ event.eventDate }}</td>
                  <td>{{ event.description }}</td>
                  <td>{{ availabilityLabel(event) }}</td>
                  <td class="event-row-actions">
                    <div class="event-row-actions__inner">
                      @if (canManageEvent(event)) {
                        <button class="btn btn-sm btn-secondary" (click)="onEdit(event)">Edit</button>
                        <button class="btn btn-sm btn-danger" (click)="onDelete(event)">Delete</button>
                      }
                      <button
                        type="button"
                        class="btn btn-icon btn-reserve"
                        [disabled]="!canReserveForEvent(event)"
                        [attr.aria-label]="reserveTooltip(event)"
                        [title]="reserveTooltip(event)"
                        (click)="onReserve(event)"
                      >
                        <svg
                          xmlns="http://www.w3.org/2000/svg"
                          width="18"
                          height="18"
                          viewBox="0 0 24 24"
                          fill="none"
                          stroke="currentColor"
                          stroke-width="2"
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          aria-hidden="true"
                        >
                          <path d="M6 12V8a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v4" />
                          <path d="M4 20v-2a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v2" />
                          <path d="M8 12v6" />
                          <path d="M16 12v6" />
                        </svg>
                      </button>
                    </div>
                  </td>
                </tr>
              }
            </tbody>
          </table>
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
export class EventsComponent implements OnInit {
  private readonly fb = inject(FormBuilder);
  private readonly eventService = inject(EventService);
  private readonly shopService = inject(ShopService);
  private readonly authService = inject(AuthService);
  private readonly profileService = inject(ProfileService);
  private readonly injector = inject(Injector);
  private readonly router = inject(Router);
  private readonly dialog = inject(DialogService);

  readonly canCreateEvent = computed(() => {
    const profile = this.profileService.currentUser();
    if (!profile) return false;
    return this.authService.isAdmin() || profile.userType === 'SHOP_OWNER';
  });

  readonly todayIsoValue = todayIso;

  readonly events = signal<EventResponseDto[]>([]);
  readonly shops = signal<ShopResponseDto[]>([]);
  readonly shopSelectOptions = computed((): FormSelectOption[] =>
    this.shops().map(s => ({ value: s.id, label: s.name })),
  );
  readonly loading = signal(true);
  readonly showForm = signal(false);
  readonly editingId = signal<string | null>(null);
  readonly searchInput = signal('');
  readonly dateFrom = signal('');
  readonly dateTo = signal('');
  readonly currentPage = signal(0);
  readonly pageSize = 10;
  readonly totalElements = signal(0);
  readonly totalPages = signal(1);

  private readonly ownedShopIds = signal<Set<string>>(new Set());

  readonly form = this.fb.nonNullable.group({
    eventName: ['', Validators.required],
    eventDate: ['', Validators.required],
    description: [''],
    shopId: ['', Validators.required],
  });

  constructor() {
    toObservable(this.searchInput, { injector: this.injector })
      .pipe(skip(1), debounceTime(300), distinctUntilChanged(), takeUntilDestroyed())
      .subscribe(() => {
        this.currentPage.set(0);
        this.loadEvents();
      });
  }

  ngOnInit(): void {
    this.shopService.getMine().subscribe(shops => {
      this.shops.set(shops);
      this.ownedShopIds.set(new Set(shops.map(s => s.id)));
    });

    this.loadEvents();
  }

  emptyStateMessage(): string {
    if (this.searchInput().trim()) return 'No events match your search.';
    if (this.dateFrom() || this.dateTo()) return 'No events match the selected date range.';
    return 'No events yet.';
  }

  toggleForm(): void {
    if (this.showForm()) {
      this.cancelEdit();
    } else {
      this.editingId.set(null);
      this.applyDateValidatorsForMode();
      this.showForm.set(true);
    }
  }

  onSearchInput(inputEvent: Event): void {
    const value = (inputEvent.target as HTMLInputElement).value;
    this.searchInput.set(value);
  }

  onDateRangeChange(range: DateRangeValue): void {
    this.dateFrom.set(range.dateFrom);
    this.dateTo.set(range.dateTo);
    this.currentPage.set(0);
    this.loadEvents();
  }

  loadEvents(): void {
    this.loading.set(true);
    const q = this.searchInput().trim();
    const from = this.dateFrom().trim();
    const to = this.dateTo().trim();
    this.eventService
      .search({
        q: q || undefined,
        dateFrom: from || undefined,
        dateTo: to || undefined,
        page: this.currentPage(),
        size: this.pageSize,
      })
      .subscribe({
        next: page => {
          this.events.set(page.content);
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
    this.loadEvents();
  }

  rangeLabel(): string {
    const total = this.totalElements();
    if (total === 0) return '';
    const start = this.currentPage() * this.pageSize + 1;
    const end = Math.min((this.currentPage() + 1) * this.pageSize, total);
    return `Showing ${start}–${end} of ${total}`;
  }

  displayShopName(event: EventResponseDto): string {
    return event.shopName ?? event.shopId.slice(0, 8);
  }

  canManageEvent(event: EventResponseDto): boolean {
    if (!this.canCreateEvent()) return false;
    if (this.authService.isAdmin()) return true;
    return this.ownedShopIds().has(event.shopId);
  }

  canReserveForEvent(event: EventResponseDto): boolean {
    if (event.isFull === true || (event.freeTables ?? 1) <= 0) return false;
    const parsed = new Date(event.eventDate);
    if (Number.isNaN(parsed.getTime())) return true;
    return parsed > new Date();
  }

  reserveTooltip(event: EventResponseDto): string {
    if (event.isFull === true || (event.freeTables ?? 1) <= 0) {
      return 'No tables left for this event';
    }
    return this.canReserveForEvent(event) ? `Reserve for ${event.eventName}` : 'This event has already passed';
  }

  availabilityLabel(event: EventResponseDto): string {
    if (event.isFull === true || (event.freeTables ?? 1) <= 0) return 'Full';
    if (typeof event.freeTables === 'number') return `${event.freeTables} left`;
    return '—';
  }

  onReserve(event: EventResponseDto): void {
    if (!this.canReserveForEvent(event)) return;
    void this.router.navigate(['/reservations'], {
      queryParams: { shopId: event.shopId, eventId: event.eventId },
    });
  }

  canShowForm(): boolean {
    const id = this.editingId();
    if (id) {
      const event = this.events().find(e => e.eventId === id);
      return event ? this.canManageEvent(event) : false;
    }
    return this.canCreateEvent();
  }

  onSubmit(): void {
    if (this.form.invalid) return;
    if (!this.editingId() && this.form.controls.eventDate.hasError('pastDate')) return;

    const val = this.form.getRawValue();
    const id = this.editingId();

    const op = id
      ? this.eventService.update(id, val)
      : this.eventService.create(val);

    op.subscribe(() => {
      this.cancelEdit();
      this.loadEvents();
    });
  }

  onEdit(event: EventResponseDto): void {
    this.editingId.set(event.eventId);
    this.applyDateValidatorsForMode();
    this.showForm.set(true);
    this.form.patchValue({
      eventName: event.eventName,
      eventDate: normalizeDateTimeLocal(event.eventDate),
      description: event.description,
      shopId: event.shopId,
    });
  }

  onDelete(event: EventResponseDto): void {
    void this.dialog
      .confirm(`Delete "${event.eventName}"?`, { confirmLabel: 'Delete', confirmVariant: 'danger' })
      .then(ok => {
        if (!ok) return;
        this.eventService.delete(event.eventId).subscribe(() => {
          const remainingOnPage = this.events().length - 1;
          if (remainingOnPage === 0 && this.currentPage() > 0) {
            this.currentPage.update(p => p - 1);
          }
          this.loadEvents();
        });
      });
  }

  cancelEdit(): void {
    this.editingId.set(null);
    this.showForm.set(false);
    this.form.reset({ eventName: '', eventDate: '', description: '', shopId: '' });
    this.applyDateValidatorsForMode();
  }

  private applyDateValidatorsForMode(): void {
    const dateControl = this.form.controls.eventDate;
    if (this.editingId()) {
      dateControl.setValidators([Validators.required]);
    } else {
      dateControl.setValidators([Validators.required, futureDateValidator()]);
    }
    dateControl.updateValueAndValidity();
  }
}

function normalizeDateTimeLocal(value: string): string {
  if (!value) return '';
  if (value.includes('T')) {
    return value.length >= 16 ? value.slice(0, 16) : value;
  }
  return `${value}T00:00`;
}
