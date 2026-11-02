import { Component, computed, inject, Injector, OnInit, signal, ChangeDetectionStrategy } from '@angular/core';
import { takeUntilDestroyed, toObservable } from '@angular/core/rxjs-interop';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { debounceTime, distinctUntilChanged, skip } from 'rxjs';
import { EventService } from '../../services/event.service';
import { ShopService } from '../../services/shop.service';
import { ReservationService } from '../../services/reservation.service';
import { ReservationRequestService } from '../../services/reservation-request.service';
import { AuthService } from '../../services/auth.service';
import { ProfileService } from '../../services/profile.service';
import { ReservationResponseDto, ReservationRequestResponseDto } from '../../models/reservation.model';
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
import { SubscriptionService } from '../../services/subscription.service';
import {
  futureDateValidator,
  normalizeDateTimeLocal,
} from '../../utils/event-form.utils';
import {
  canReserveForEvent as isEventReservable,
  eventAvailabilityLabel,
  eventIdsBlockedForUser,
  isEventFull,
} from '../../utils/reservation-event.utils';

@Component({
  selector: 'app-events',
  standalone: true,
  imports: [ReactiveFormsModule, DateRangePickerComponent, DateTimePickerComponent, FormSelectComponent, RouterLink],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="page page--with-footer">
      <div class="page__content">
        <div class="page-header">
          <div class="page-header__title-group">
            <h1 class="page-title">Events</h1>
            @if (eventsQuotaLabel(); as quota) {
              <p class="text-muted events-quota">{{ quota }}</p>
            }
          </div>
          @if (canCreateEvent()) {
            <button class="btn btn-primary" (click)="toggleForm()">
              {{ showForm() ? 'Cancel' : '+ Add Event' }}
            </button>
          } @else if (showEventCreateUpgrade()) {
            <a routerLink="/profile/billing" class="upgrade-link">Upgrade to Growth</a>
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
          <div class="compact-list">
            @for (event of events(); track event.eventId) {
              <article class="compact-row">
                <div class="compact-row__start">
                  <div class="compact-row__text">
                    <span class="compact-row__primary">{{ event.eventName }}</span>
                    <span class="compact-row__secondary">
                      {{ displayShopName(event) }} &middot; {{ event.eventDate }}
                      @if (event.description) { &middot; {{ event.description }} }
                    </span>
                  </div>
                </div>
                <span class="badge" [class]="availabilityBadgeClass(event)">{{ availabilityLabel(event) }}</span>
                <div class="compact-row__end">
                  @if (canManageEvent(event)) {
                    <button class="btn btn--compact btn-secondary" (click)="onEdit(event)" aria-label="Edit event">
                      <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                    </button>
                    <button class="btn btn--compact btn-danger" (click)="onDelete(event)" aria-label="Delete event">
                      <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                    </button>
                  }
                  @if (canShowReserveButton(event)) {
                    <button
                      type="button"
                      class="btn btn--compact btn-primary"
                      [attr.aria-label]="reserveTooltip(event)"
                      [title]="reserveTooltip(event)"
                      (click)="onReserve(event)"
                    >
                      Reserve
                    </button>
                  }
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
  styles: [`
    :host {
      display: block;
      min-height: 100%;
    }

    .page-header__title-group {
      display: flex;
      flex-direction: column;
      gap: 0.25rem;
    }

    .events-quota {
      margin: 0;
      font-size: 0.8125rem;
    }

    .upgrade-link {
      font-size: 0.875rem;
      font-weight: 600;
      color: #d4a574;
      text-decoration: none;
      white-space: nowrap;
      align-self: center;
    }

    .upgrade-link:hover {
      text-decoration: underline;
    }
  `],
})
export class EventsComponent implements OnInit {
  private readonly fb = inject(FormBuilder);
  private readonly eventService = inject(EventService);
  private readonly shopService = inject(ShopService);
  private readonly reservationService = inject(ReservationService);
  private readonly requestService = inject(ReservationRequestService);
  private readonly authService = inject(AuthService);
  private readonly profileService = inject(ProfileService);
  private readonly injector = inject(Injector);
  private readonly router = inject(Router);
  private readonly dialog = inject(DialogService);
  private readonly subscriptionService = inject(SubscriptionService);

  readonly canManageEvents = computed(() => {
    const profile = this.profileService.currentUser();
    if (!profile) return false;
    return this.authService.isAdmin() || profile.userType === 'SHOP_OWNER';
  });

  readonly eventsQuotaLabel = computed(() => {
    if (!this.canManageEvents()) return null;
    const limit = this.subscriptionService.getLimit('events');
    if (!limit) return null;
    if (limit.max < 0) return `${limit.used} / Unlimited events this month`;
    return `${limit.used} / ${limit.max} events this month`;
  });

  readonly canCreateEvent = computed(() => {
    if (!this.canManageEvents()) return false;
    if (!this.subscriptionService.canUseFeature('event_create')) return false;
    const limit = this.subscriptionService.getLimit('events');
    if (limit && limit.max >= 0 && limit.used >= limit.max) return false;
    return true;
  });

  readonly showEventCreateUpgrade = computed(() =>
    this.canManageEvents() && !this.subscriptionService.canUseFeature('event_create'),
  );

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
  readonly allRequests = signal<ReservationRequestResponseDto[]>([]);
  readonly allReservations = signal<ReservationResponseDto[]>([]);

  readonly isShopOwnerUser = computed(() => {
    const profile = this.profileService.currentUser();
    return !!profile && profile.userType === 'SHOP_OWNER';
  });

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

    this.reservationService.getAll().subscribe(res => this.allReservations.set(res));
    this.requestService.getAll().subscribe(req => this.allRequests.set(req));

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

  availabilityBadgeClass(event: EventResponseDto): string {
    if (isEventFull(event)) return 'badge-denied';
    return 'badge-accepted';
  }

  canManageEvent(event: EventResponseDto): boolean {
    if (!this.canCreateEvent()) return false;
    if (this.authService.isAdmin()) return true;
    return this.ownedShopIds().has(event.shopId);
  }

  canShowForm(): boolean {
    const id = this.editingId();
    if (id) {
      const event = this.events().find(e => e.eventId === id);
      return event ? this.canManageEvent(event) : false;
    }
    return this.canCreateEvent();
  }

  canShowReserveButton(event: EventResponseDto): boolean {
    if (!isEventReservable(event)) return false;
    if (this.isShopOwnerUser() && this.ownedShopIds().has(event.shopId)) return false;
    const profile = this.profileService.currentUser();
    if (!profile) return false;
    const blocked = eventIdsBlockedForUser(
      this.allRequests(),
      this.allReservations(),
      profile.id,
    );
    return !blocked.has(event.eventId);
  }

  reserveTooltip(event: EventResponseDto): string {
    if (isEventFull(event)) {
      return 'No tables left for this event';
    }
    if (this.isShopOwnerUser() && this.ownedShopIds().has(event.shopId)) {
      return 'Use Reservations to request for a guest at your shop';
    }
    const profile = this.profileService.currentUser();
    if (profile) {
      const blocked = eventIdsBlockedForUser(
        this.allRequests(),
        this.allReservations(),
        profile.id,
      );
      if (blocked.has(event.eventId)) {
        return 'You already have a reservation request or reservation for this event';
      }
    }
    return isEventReservable(event)
      ? `Reserve for ${event.eventName}`
      : 'This event has already passed';
  }

  availabilityLabel(event: EventResponseDto): string {
    return eventAvailabilityLabel(event);
  }

  onReserve(event: EventResponseDto): void {
    if (!this.canShowReserveButton(event)) return;
    void this.router.navigate(['/reservations'], {
      queryParams: { shopId: event.shopId, eventId: event.eventId },
    });
  }

  onSubmit(): void {
    if (this.form.invalid) return;
    if (!this.editingId() && this.form.controls.eventDate.hasError('pastDate')) return;
    if (!this.editingId() && !this.canCreateEvent()) return;

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
