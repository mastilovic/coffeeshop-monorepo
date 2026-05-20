import { Component, inject, signal, computed, OnInit, ChangeDetectionStrategy, DestroyRef } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { takeUntilDestroyed, toSignal } from '@angular/core/rxjs-interop';
import { FormBuilder, FormsModule, ReactiveFormsModule, Validators } from '@angular/forms';
import { FormSelectComponent } from '../../shared/form-select/form-select.component';
import { FormSelectOption } from '../../shared/form-select/form-select-option.model';
import { HttpErrorResponse } from '@angular/common/http';
import { ReservationService } from '../../services/reservation.service';
import { ReservationRequestService } from '../../services/reservation-request.service';
import { ShopService } from '../../services/shop.service';
import { TableService } from '../../services/table.service';
import { EventService } from '../../services/event.service';
import { UserService } from '../../services/user.service';
import { ProfileService } from '../../services/profile.service';
import { AuthService } from '../../services/auth.service';
import { ReservationResponseDto, ReservationRequestResponseDto } from '../../models/reservation.model';
import { ShopResponseDto } from '../../models/shop.model';
import { TableResponseDto } from '../../models/table.model';
import { EventResponseDto } from '../../models/event.model';
import { UserResponseDto } from '../../models/user.model';
import { getAcceptReservationErrorMessage } from '../../utils/api-error';
import { DialogService } from '../../services/dialog.service';

@Component({
  selector: 'app-reservations',
  standalone: true,
  imports: [ReactiveFormsModule, FormsModule, FormSelectComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="page">
      <div class="page-header">
        <h1 class="page-title">{{ pageTitle() }}</h1>
        @if (isShopOwner()) {
          <div style="display:flex;gap:0.5rem;flex-wrap:wrap">
            <button class="btn btn-primary" (click)="toggleOwnerForm('request')">
              {{ ownerFormMode() === 'request' ? 'Cancel' : '+ Request for guest' }}
            </button>
            <button class="btn btn-secondary" (click)="toggleOwnerForm('direct')">
              {{ ownerFormMode() === 'direct' ? 'Cancel' : '+ Create reservation' }}
            </button>
          </div>
        } @else {
          <button class="btn btn-primary" (click)="showRequestForm.set(!showRequestForm())">
            {{ showRequestForm() ? 'Cancel' : '+ Request Reservation' }}
          </button>
        }
      </div>

      @if (showRequestForm() || ownerFormMode() === 'request') {
        <div class="form-card mb-3">
          <form [formGroup]="requestForm" (ngSubmit)="onSubmitRequest()">
            @if (isShopOwner()) {
              <div class="form-group">
                <label for="reservation-guest">Guest</label>
                <app-form-select
                  inputId="reservation-guest"
                  formControlName="guestUserId"
                  placeholder="Select guest"
                  [options]="guestSelectOptions()"
                />
              </div>
            }
            <div class="form-group">
              <label>Shop</label>
              <app-form-select
                formControlName="shopId"
                placeholder="Select shop"
                [options]="shopSelectOptions()"
              />
            </div>
            <div class="form-group">
              <label for="reservation-event">Event</label>
              <app-form-select
                inputId="reservation-event"
                formControlName="eventId"
                placeholder="Select event"
                [options]="eventSelectOptionsForRequest()"
                [ariaDescribedBy]="shopSelectedWithoutEvents() ? 'reservation-event-hint' : null"
              />
              @if (shopSelectedWithoutEvents()) {
                <p id="reservation-event-hint" class="text-muted" role="status" aria-live="polite">
                  No events available for this shop.
                </p>
              } @else if (requestShopHasOnlyBlockedEvents()) {
                <p class="text-muted" role="status" aria-live="polite">
                  You already have a reservation request or reservation for every event at this shop.
                </p>
              } @else if (requestShopHasOnlyFullEvents()) {
                <p class="text-muted" role="status" aria-live="polite">
                  No tables left for events at this shop.
                </p>
              }
            </div>
            <div class="form-group">
              <label>Party size</label>
              <input class="form-input" type="number" formControlName="partySize" min="1" />
            </div>
            <div class="form-actions">
              <button type="submit" class="btn btn-primary" [disabled]="requestForm.invalid || !canSubmitRequest()">Submit Request</button>
            </div>
          </form>
        </div>
      }

      @if (ownerFormMode() === 'direct') {
        <div class="form-card mb-3">
          <form [formGroup]="directForm" (ngSubmit)="onSubmitDirectReservation()">
            <div class="form-group">
              <label for="direct-guest">Guest</label>
              <app-form-select
                inputId="direct-guest"
                formControlName="guestUserId"
                placeholder="Select guest"
                [options]="guestSelectOptions()"
              />
            </div>
            <div class="form-group">
              <label for="direct-shop">Shop</label>
              <app-form-select
                inputId="direct-shop"
                formControlName="shopId"
                placeholder="Select shop"
                [options]="shopSelectOptions()"
              />
            </div>
            <div class="form-group">
              <label for="direct-event">Event</label>
              <app-form-select
                inputId="direct-event"
                formControlName="eventId"
                placeholder="Select event"
                [options]="eventSelectOptionsForDirect()"
                [ariaDescribedBy]="directShopSelectedWithoutEvents() ? 'direct-event-hint' : null"
              />
              @if (directShopSelectedWithoutEvents()) {
                <p id="direct-event-hint" class="text-muted" role="status" aria-live="polite">
                  No events available for this shop.
                </p>
              } @else if (directShopHasOnlyBlockedEvents()) {
                <p class="text-muted" role="status" aria-live="polite">
                  This guest already has a reservation request or reservation for every event at this shop.
                </p>
              } @else if (directShopHasOnlyFullEvents()) {
                <p class="text-muted" role="status" aria-live="polite">
                  No tables left for events at this shop.
                </p>
              }
            </div>
            <div class="form-group">
              <label for="direct-table">Table</label>
              <app-form-select
                inputId="direct-table"
                formControlName="tableId"
                placeholder="Select table"
                [options]="tableSelectOptionsForDirect()"
              />
            </div>
            <div class="form-group">
              <label>Party size</label>
              <input class="form-input" type="number" formControlName="partySize" min="1" />
            </div>
            <div class="form-actions">
              <button type="submit" class="btn btn-primary" [disabled]="directForm.invalid || !canSubmitDirectReservation()">Create reservation</button>
            </div>
          </form>
        </div>
      }

      @if (isShopOwner()) {
        <div class="tabs tabs--sub">
          <button
            class="tab"
            [class.active]="ownerSubTab() === 'pending'"
            (click)="ownerSubTab.set('pending')">
            Pending ({{ pendingRequests().length }})
          </button>
          <button
            class="tab"
            [class.active]="ownerSubTab() === 'approved'"
            (click)="ownerSubTab.set('approved')">
            Approved ({{ myReservations().length }})
          </button>
          <button
            class="tab"
            [class.active]="ownerSubTab() === 'denied'"
            (click)="ownerSubTab.set('denied')">
            Denied ({{ deniedRequests().length }})
          </button>
        </div>

        @if (ownerSubTab() === 'pending') {
          @if (loading()) {
            <div class="loading">Loading requests...</div>
          } @else if (pendingRequests().length === 0) {
            <div class="empty-state"><p>No pending reservation requests.</p></div>
          } @else {
            <div class="table-container table-container--dropdown-safe">
              <table class="data-table">
                <thead>
                  <tr>
                    <th>Guest</th>
                    <th>Shop</th>
                    <th>Event</th>
                    <th>Party Size</th>
                    <th>Status</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  @for (req of pendingRequests(); track req.id) {
                    <tr>
                      <td>{{ req.user?.name ?? '—' }}</td>
                      <td>{{ req.shop.name }}</td>
                      <td>{{ eventLabel(req) }}</td>
                      <td>{{ req.partySize }}</td>
                      <td><span class="badge badge-pending">{{ req.status }}</span></td>
                      <td>
                        <div class="reservation-actions">
                          <app-form-select
                            [compact]="true"
                            placeholder="Select table"
                            [options]="tableSelectOptionsForRequest(req)"
                            [ngModel]="tableSelectValue(req.id)"
                            (ngModelChange)="onTableSelectChange(req.id, $event)"
                          />
                          @if (!hasSuitableTablesForRequest(req)) {
                            <p class="text-muted" role="status">
                              No table large enough for party of {{ req.partySize }}.
                            </p>
                          }
                          <div class="reservation-actions__buttons">
                            <button class="btn btn-sm btn-primary" (click)="onAccept(req)">Accept</button>
                            <button class="btn btn-sm btn-danger" (click)="onDeny(req)">Deny</button>
                          </div>
                        </div>
                      </td>
                    </tr>
                  }
                </tbody>
              </table>
            </div>
          }
        }

        @if (ownerSubTab() === 'approved') {
          @if (myReservations().length === 0) {
            <div class="empty-state"><p>No confirmed reservations.</p></div>
          } @else {
            <div class="table-container">
              <table class="data-table">
                <thead>
                  <tr>
                    <th>Guest</th>
                    <th>Shop</th>
                    <th>Event</th>
                    <th>Table</th>
                    <th>Party Size</th>
                  </tr>
                </thead>
                <tbody>
                  @for (r of myReservations(); track r.id) {
                    <tr>
                      <td>{{ r.user?.name ?? '—' }}</td>
                      <td>{{ r.shop.name }}</td>
                      <td>{{ eventLabel(r) }}</td>
                      <td>{{ r.table ? 'Table ' + r.table.number : 'N/A' }}</td>
                      <td>{{ r.partySize }}</td>
                    </tr>
                  }
                </tbody>
              </table>
            </div>
          }
        }

        @if (ownerSubTab() === 'denied') {
          @if (loading()) {
            <div class="loading">Loading requests...</div>
          } @else if (deniedRequests().length === 0) {
            <div class="empty-state"><p>No denied reservation requests.</p></div>
          } @else {
            <div class="table-container">
              <table class="data-table">
                <thead>
                  <tr>
                    <th>Guest</th>
                    <th>Shop</th>
                    <th>Event</th>
                    <th>Party Size</th>
                    <th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  @for (req of deniedRequests(); track req.id) {
                    <tr>
                      <td>{{ req.user?.name ?? '—' }}</td>
                      <td>{{ req.shop.name }}</td>
                      <td>{{ eventLabel(req) }}</td>
                      <td>{{ req.partySize }}</td>
                      <td><span class="badge badge-denied">{{ req.status }}</span></td>
                    </tr>
                  }
                </tbody>
              </table>
            </div>
          }
        }
      } @else {
        <div class="tabs">
          <button class="tab" [class.active]="activeTab() === 'requests'" (click)="activeTab.set('requests')">
            Reservation Requests
          </button>
          <button class="tab" [class.active]="activeTab() === 'confirmed'" (click)="activeTab.set('confirmed')">
            Confirmed Reservations
          </button>
        </div>

        @if (activeTab() === 'requests') {
          @if (loading()) {
            <div class="loading">Loading requests...</div>
          } @else if (allRequests().length === 0) {
            <div class="empty-state"><p>No reservation requests.</p></div>
          } @else {
            <div class="table-container">
              <table class="data-table">
                <thead>
                  <tr>
                    <th>Shop</th>
                    <th>Event</th>
                    <th>Party Size</th>
                    <th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  @for (req of allRequests(); track req.id) {
                    <tr>
                      <td>{{ req.shop.name }}</td>
                      <td>{{ eventLabel(req) }}</td>
                      <td>{{ req.partySize }}</td>
                      <td>
                        <span class="badge"
                          [class.badge-pending]="req.status === 'PENDING'"
                          [class.badge-accepted]="req.status === 'ACCEPTED'"
                          [class.badge-denied]="req.status === 'DENIED'">
                          {{ req.status }}
                        </span>
                      </td>
                    </tr>
                  }
                </tbody>
              </table>
            </div>
          }
        }

        @if (activeTab() === 'confirmed') {
          @if (myReservations().length === 0) {
            <div class="empty-state"><p>No confirmed reservations.</p></div>
          } @else {
            <div class="table-container">
              <table class="data-table">
                <thead>
                  <tr>
                    <th>Shop</th>
                    <th>Event</th>
                    <th>Table</th>
                    <th>Party Size</th>
                  </tr>
                </thead>
                <tbody>
                  @for (r of myReservations(); track r.id) {
                    <tr>
                      <td>{{ r.shop.name }}</td>
                      <td>{{ eventLabel(r) }}</td>
                      <td>{{ r.table ? 'Table ' + r.table.number : 'N/A' }}</td>
                      <td>{{ r.partySize }}</td>
                    </tr>
                  }
                </tbody>
              </table>
            </div>
          }
        }
      }
    </div>
  `,
})
export class ReservationsComponent implements OnInit {
  private static readonly BLOCKING_REQUEST_STATUSES = new Set(['PENDING', 'ACCEPTED']);

  private readonly fb = inject(FormBuilder);
  private readonly reservationService = inject(ReservationService);
  private readonly requestService = inject(ReservationRequestService);
  private readonly shopService = inject(ShopService);
  private readonly tableService = inject(TableService);
  private readonly profileService = inject(ProfileService);
  private readonly authService = inject(AuthService);
  private readonly eventService = inject(EventService);
  private readonly userService = inject(UserService);
  private readonly destroyRef = inject(DestroyRef);
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly dialog = inject(DialogService);

  readonly shops = signal<ShopResponseDto[]>([]);
  readonly users = signal<UserResponseDto[]>([]);
  readonly eventsForShop = signal<EventResponseDto[]>([]);
  readonly eventsForDirectShop = signal<EventResponseDto[]>([]);
  readonly tables = signal<TableResponseDto[]>([]);
  readonly allReservations = signal<ReservationResponseDto[]>([]);
  readonly allRequests = signal<ReservationRequestResponseDto[]>([]);
  readonly loading = signal(true);
  readonly activeTab = signal<'requests' | 'confirmed'>('requests');
  readonly ownerSubTab = signal<'pending' | 'approved' | 'denied'>('pending');
  readonly showRequestForm = signal(false);
  readonly ownerFormMode = signal<'request' | 'direct' | null>(null);
  readonly selectedTableForRequest = signal<{ reqId: string; tableId: string } | null>(null);

  readonly isShopOwner = computed(() => {
    const profile = this.profileService.currentUser();
    if (!profile) return false;
    if (profile.userType === 'SHOP_OWNER' || this.authService.isAdmin()) return true;
    return this.shops().some(s => s.createdBy?.id === profile.id);
  });

  readonly pageTitle = computed(() =>
    this.isShopOwner() ? 'Reservation Requests' : 'My Reservations',
  );

  readonly shopsForRequest = computed(() => {
    const profile = this.profileService.currentUser();
    if (!profile || !this.isShopOwner()) {
      return this.shops();
    }
    return this.shops().filter(s => s.createdBy?.id === profile.id);
  });

  readonly myReservations = computed(() => {
    const profile = this.profileService.currentUser();
    if (!profile) return [];
    if (this.isShopOwner()) {
      const ownedShopIds = new Set(
        this.shops()
          .filter(s => s.createdBy?.id === profile.id)
          .map(s => s.id),
      );
      return this.allReservations().filter(r => r.shop?.id && ownedShopIds.has(r.shop.id));
    }
    return this.allReservations().filter(r => r.user?.id === profile.id);
  });

  readonly pendingRequests = computed(() =>
    this.allRequests().filter(r => r.status === 'PENDING'),
  );

  readonly deniedRequests = computed(() =>
    this.allRequests().filter(r => r.status === 'DENIED'),
  );

  readonly requestForm = this.fb.nonNullable.group({
    guestUserId: [''],
    shopId: ['', Validators.required],
    eventId: ['', Validators.required],
    partySize: [1, [Validators.required, Validators.min(1)]],
  });

  readonly directForm = this.fb.nonNullable.group({
    guestUserId: ['', Validators.required],
    shopId: ['', Validators.required],
    eventId: ['', Validators.required],
    tableId: ['', Validators.required],
    partySize: [1, [Validators.required, Validators.min(1)]],
  });

  private readonly requestEventId = toSignal(this.requestForm.controls.eventId.valueChanges, {
    initialValue: this.requestForm.controls.eventId.value,
  });

  private readonly requestGuestUserId = toSignal(this.requestForm.controls.guestUserId.valueChanges, {
    initialValue: this.requestForm.controls.guestUserId.value,
  });

  private readonly directEventId = toSignal(this.directForm.controls.eventId.valueChanges, {
    initialValue: this.directForm.controls.eventId.value,
  });

  private readonly directGuestUserId = toSignal(this.directForm.controls.guestUserId.valueChanges, {
    initialValue: this.directForm.controls.guestUserId.value,
  });

  readonly requestTargetUserId = computed(() => {
    const profile = this.profileService.currentUser();
    if (!profile) return '';
    if (this.isShopOwner()) {
      return this.requestGuestUserId();
    }
    return profile.id;
  });

  readonly directTargetUserId = computed(() => this.directGuestUserId());

  readonly selectableEventsForRequest = computed(() => {
    const userId = this.requestTargetUserId();
    if (!userId) {
      return this.eventsForShop();
    }
    const blocked = this.eventIdsBlockedForUser(userId);
    return this.eventsForShop().filter(e => !blocked.has(e.eventId) && !this.isEventFull(e));
  });

  readonly selectableEventsForDirect = computed(() => {
    const userId = this.directTargetUserId();
    if (!userId) {
      return this.eventsForDirectShop();
    }
    const blocked = this.eventIdsBlockedForUser(userId);
    return this.eventsForDirectShop().filter(e => !blocked.has(e.eventId) && !this.isEventFull(e));
  });

  readonly canSubmitRequest = computed(() => {
    const eventId = this.requestEventId();
    if (!eventId) return false;
    const userId = this.requestTargetUserId();
    if (!userId) return false;
    return this.selectableEventsForRequest().some(e => e.eventId === eventId);
  });

  readonly canSubmitDirectReservation = computed(() => {
    const eventId = this.directEventId();
    if (!eventId) return false;
    const userId = this.directTargetUserId();
    if (!userId) return false;
    return this.selectableEventsForDirect().some(e => e.eventId === eventId);
  });

  readonly shopSelectedWithoutEvents = computed(() => {
    const shopId = this.requestForm.controls.shopId.value;
    return !!shopId && this.eventsForShop().length === 0;
  });

  readonly requestShopHasOnlyBlockedEvents = computed(() => {
    const shopId = this.requestForm.controls.shopId.value;
    const userId = this.requestTargetUserId();
    return !!shopId && !!userId && this.eventsForShop().length > 0 && this.selectableEventsForRequest().length === 0;
  });

  readonly requestShopHasOnlyFullEvents = computed(() => {
    const shopId = this.requestForm.controls.shopId.value;
    return !!shopId
      && this.eventsForShop().length > 0
      && this.eventsForShop().every(e => this.isEventFull(e));
  });

  readonly directShopSelectedWithoutEvents = computed(() => {
    const shopId = this.directForm.controls.shopId.value;
    return !!shopId && this.eventsForDirectShop().length === 0;
  });

  readonly directShopHasOnlyBlockedEvents = computed(() => {
    const shopId = this.directForm.controls.shopId.value;
    const userId = this.directTargetUserId();
    return !!shopId && !!userId && this.eventsForDirectShop().length > 0 && this.selectableEventsForDirect().length === 0;
  });

  readonly directShopHasOnlyFullEvents = computed(() => {
    const shopId = this.directForm.controls.shopId.value;
    return !!shopId
      && this.eventsForDirectShop().length > 0
      && this.eventsForDirectShop().every(e => this.isEventFull(e));
  });

  readonly guestSelectOptions = computed((): FormSelectOption[] =>
    this.users().map(u => ({
      value: u.id,
      label: `${u.name} (${u.email})`,
    })),
  );

  readonly shopSelectOptions = computed((): FormSelectOption[] =>
    this.shopsForRequest().map(s => ({ value: s.id, label: s.name })),
  );

  readonly eventSelectOptionsForRequest = computed((): FormSelectOption[] =>
    this.selectableEventsForRequest().map(e => ({
      value: e.eventId,
      label: `${e.eventName} (${e.eventDate}) - ${this.eventAvailabilityLabel(e)}`,
    })),
  );

  readonly eventSelectOptionsForDirect = computed((): FormSelectOption[] =>
    this.selectableEventsForDirect().map(e => ({
      value: e.eventId,
      label: `${e.eventName} (${e.eventDate}) - ${this.eventAvailabilityLabel(e)}`,
    })),
  );

  readonly tableSelectOptionsForDirect = computed((): FormSelectOption[] =>
    this.tablesForDirectShop().map(t => ({
      value: t.id,
      label: `Table ${t.number} (cap: ${t.capacity})`,
    })),
  );

  tablesForRequest(req: ReservationRequestResponseDto): TableResponseDto[] {
    return this.tablesForShop(req.shop.id).filter(t => t.capacity >= req.partySize);
  }

  hasSuitableTablesForRequest(req: ReservationRequestResponseDto): boolean {
    return this.tablesForRequest(req).length > 0;
  }

  tableSelectOptionsForRequest(req: ReservationRequestResponseDto): FormSelectOption[] {
    return [
      { value: '', label: 'Select table' },
      ...this.tablesForRequest(req).map(t => ({
        value: t.id,
        label: `Table ${t.number} (cap: ${t.capacity})`,
      })),
    ];
  }

  tableSelectValue(reqId: string): string {
    const sel = this.selectedTableForRequest();
    return sel?.reqId === reqId ? sel.tableId : '';
  }

  onTableSelectChange(reqId: string, tableId: string): void {
    if (tableId) {
      this.selectedTableForRequest.set({ reqId, tableId });
    } else if (this.selectedTableForRequest()?.reqId === reqId) {
      this.selectedTableForRequest.set(null);
    }
  }

  ngOnInit(): void {
    this.shopService.getAll().subscribe(shops => this.shops.set(shops));
    this.userService.getAll().subscribe(users => this.users.set(users));
    this.tableService.getAll().subscribe(tables => this.tables.set(tables));
    this.requestForm.controls.shopId.valueChanges
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(shopId => this.onShopChange(shopId));
    this.requestForm.controls.guestUserId.valueChanges
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(() => this.requestForm.controls.eventId.setValue(''));
    this.directForm.controls.shopId.valueChanges
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(shopId => this.onDirectShopChange(shopId));
    this.directForm.controls.guestUserId.valueChanges
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(() => {
        this.directForm.controls.eventId.setValue('');
        this.directForm.controls.tableId.setValue('');
      });
    this.loadData();
    this.applyQueryParamPrefill();
  }

  private applyQueryParamPrefill(): void {
    const shopId = this.route.snapshot.queryParamMap.get('shopId');
    const eventId = this.route.snapshot.queryParamMap.get('eventId');
    if (!shopId || !eventId) {
      return;
    }
    this.openRequestFormWithEvent(shopId, eventId);
  }

  private openRequestFormWithEvent(shopId: string, eventId: string): void {
    if (this.isShopOwner()) {
      this.showRequestForm.set(false);
      this.ownerFormMode.set('request');
      this.requestForm.controls.guestUserId.setValidators([Validators.required]);
      this.requestForm.controls.guestUserId.updateValueAndValidity();
    } else {
      this.ownerFormMode.set(null);
      this.showRequestForm.set(true);
    }
    this.requestForm.patchValue({ shopId, eventId: '', partySize: 1 }, { emitEvent: false });
    this.loadEventsForRequestShop(shopId, events => {
      if (events.some(e => e.eventId === eventId)) {
        this.requestForm.controls.eventId.setValue(eventId);
      }
      void this.router.navigate([], {
        relativeTo: this.route,
        queryParams: {},
        replaceUrl: true,
      });
    });
  }

  private eventIdsBlockedForUser(userId: string): Set<string> {
    const blocked = new Set<string>();
    for (const req of this.allRequests()) {
      if (req.user?.id === userId
          && req.eventId
          && ReservationsComponent.BLOCKING_REQUEST_STATUSES.has(req.status)) {
        blocked.add(req.eventId);
      }
    }
    for (const res of this.allReservations()) {
      if (res.user?.id === userId && res.eventId) {
        blocked.add(res.eventId);
      }
    }
    return blocked;
  }

  private isReservationConflict(error: unknown): boolean {
    return error instanceof HttpErrorResponse && error.status === 409;
  }

  private isEventFull(event: EventResponseDto): boolean {
    return event.isFull === true || (event.freeTables ?? 1) <= 0;
  }

  private eventAvailabilityLabel(event: EventResponseDto): string {
    if (this.isEventFull(event)) return 'Full';
    if (typeof event.freeTables === 'number') return `${event.freeTables} left`;
    return 'Available';
  }

  toggleOwnerForm(mode: 'request' | 'direct'): void {
    if (this.ownerFormMode() === mode) {
      this.closeOwnerForms();
      return;
    }
    this.showRequestForm.set(false);
    this.ownerFormMode.set(mode);
    if (mode === 'request') {
      this.requestForm.controls.guestUserId.setValidators([Validators.required]);
    } else {
      this.requestForm.controls.guestUserId.clearValidators();
    }
    this.requestForm.controls.guestUserId.updateValueAndValidity();
  }

  private closeOwnerForms(): void {
    this.ownerFormMode.set(null);
    this.eventsForShop.set([]);
    this.eventsForDirectShop.set([]);
    this.requestForm.controls.guestUserId.clearValidators();
    this.requestForm.controls.guestUserId.updateValueAndValidity();
    this.requestForm.reset({ guestUserId: '', shopId: '', eventId: '', partySize: 1 });
    this.directForm.reset({
      guestUserId: '',
      shopId: '',
      eventId: '',
      tableId: '',
      partySize: 1,
    });
  }

  eventLabel(item: { eventName?: string; eventId?: string }): string {
    if (item.eventName) {
      return item.eventName;
    }
    return item.eventId ?? '—';
  }

  private onShopChange(shopId: string): void {
    this.loadEventsForRequestShop(shopId);
  }

  private loadEventsForRequestShop(
    shopId: string,
    onLoaded?: (events: EventResponseDto[]) => void,
  ): void {
    this.requestForm.controls.eventId.setValue('');
    this.eventsForShop.set([]);
    if (!shopId) {
      onLoaded?.([]);
      return;
    }
    this.eventService.getByShopId(shopId).subscribe(events => {
      this.eventsForShop.set(events);
      onLoaded?.(events);
    });
  }

  private onDirectShopChange(shopId: string): void {
    this.directForm.controls.eventId.setValue('');
    this.directForm.controls.tableId.setValue('');
    this.eventsForDirectShop.set([]);
    if (!shopId) {
      return;
    }
    this.eventService.getByShopId(shopId).subscribe(events => this.eventsForDirectShop.set(events));
  }

  tablesForDirectShop(): TableResponseDto[] {
    const shopId = this.directForm.controls.shopId.value;
    return shopId ? this.tablesForShop(shopId) : [];
  }

  tablesForShop(shopId: string): TableResponseDto[] {
    return this.tables().filter(t => t.shopId === shopId);
  }

  private loadData(): void {
    this.loading.set(true);
    this.reservationService.getAll().subscribe(res => this.allReservations.set(res));
    this.requestService.getAll().subscribe({
      next: requests => {
        this.allRequests.set(requests);
        this.loading.set(false);
      },
      error: () => this.loading.set(false),
    });
  }

  onSubmitRequest(): void {
    if (this.requestForm.invalid || !this.canSubmitRequest()) return;
    const profile = this.profileService.currentUser();
    if (!profile) return;

    const val = this.requestForm.getRawValue();
    const userId = this.isShopOwner() ? val.guestUserId : profile.id;
    if (!userId) {
      return;
    }
    if (!this.selectableEventsForRequest().some(e => e.eventId === val.eventId)) {
      void this.dialog.alert('No tables left for this event.');
      return;
    }

    this.requestService.create({
      userId,
      shopId: val.shopId,
      eventId: val.eventId,
      partySize: val.partySize,
    }).subscribe({
      next: () => {
        this.showRequestForm.set(false);
        this.closeOwnerForms();
        this.loadData();
      },
      error: err => {
        if (this.isReservationConflict(err)) {
          void this.dialog.alert(
            'You already have a reservation for this event or there are no tables left.',
          );
        }
      },
    });
  }

  onSubmitDirectReservation(): void {
    if (this.directForm.invalid || !this.canSubmitDirectReservation()) return;

    const val = this.directForm.getRawValue();
    if (!this.selectableEventsForDirect().some(e => e.eventId === val.eventId)) {
      void this.dialog.alert('No tables left for this event.');
      return;
    }
    this.reservationService.create({
      userId: val.guestUserId,
      tableId: val.tableId,
      eventId: val.eventId,
      partySize: val.partySize,
    }).subscribe({
      next: () => {
        this.closeOwnerForms();
        this.ownerSubTab.set('approved');
        this.loadData();
      },
      error: err => {
        if (this.isReservationConflict(err)) {
          void this.dialog.alert(
            'This guest is already booked for this event or there are no tables left.',
          );
        }
      },
    });
  }

  onAccept(req: ReservationRequestResponseDto): void {
    const sel = this.selectedTableForRequest();
    if (!sel || sel.reqId !== req.id || !sel.tableId) {
      void this.dialog.alert('Please select a table first.');
      return;
    }
    const table = this.tables().find(t => t.id === sel.tableId);
    this.requestService.accept(req.id, { tableId: sel.tableId }).subscribe({
      next: () => this.loadData(),
      error: err =>
        void this.dialog.alert(
          getAcceptReservationErrorMessage(err, {
            partySize: req.partySize,
            tableCapacity: table?.capacity,
          }),
        ),
    });
  }

  onDeny(req: ReservationRequestResponseDto): void {
    void this.dialog
      .confirm('Deny this reservation request?', {
        confirmLabel: 'Deny',
        confirmVariant: 'danger',
      })
      .then(ok => {
        if (!ok) return;
        this.requestService.deny(req.id).subscribe(() => this.loadData());
      });
  }
}
