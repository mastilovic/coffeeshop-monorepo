import { Component, inject, signal, computed, OnInit, ChangeDetectionStrategy, DestroyRef } from '@angular/core';
import { ActivatedRoute, Router, NavigationEnd } from '@angular/router';
import { takeUntilDestroyed, toSignal } from '@angular/core/rxjs-interop';
import { filter } from 'rxjs';
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
import {
  canReserveForEvent,
  eventAvailabilityLabel,
  eventIdsBlockedForUser,
  isEventFull,
} from '../../utils/reservation-event.utils';
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
          <div class="page-header__actions">
            <button class="btn btn-primary" (click)="openRequestForm('guest')">
              {{ showRequestForm() && requestFormMode() === 'guest' ? 'Cancel' : '+ Request for guest' }}
            </button>
            <button class="btn btn-secondary" (click)="openRequestForm('self')">
              {{ showRequestForm() && requestFormMode() === 'self' ? 'Cancel' : '+ Request Reservation' }}
            </button>
          </div>
        } @else {
          <button class="btn btn-primary" (click)="openRequestForm('self')">
            {{ showRequestForm() ? 'Cancel' : '+ Request Reservation' }}
          </button>
        }
      </div>

      @if (showRequestForm()) {
        <div class="form-card mb-3">
          <form [formGroup]="requestForm" (ngSubmit)="onSubmitRequest()">
            @if (requestFormMode() === 'guest') {
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
                  @if (requestFormMode() === 'guest') {
                    This guest already has a reservation request or reservation for every event at this shop.
                  } @else {
                    You already have a reservation request or reservation for every event at this shop.
                  }
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

      @if (isShopOwner()) {
        <div class="tabs-nav">
          <div class="tabs-nav__shell">
            <nav class="pill-tabs" role="tablist" aria-label="Reservation sections">
              <button type="button" class="pill-tab" role="tab"
                [class.pill-tab--active]="ownerMainTab() === 'personal'"
                [attr.aria-selected]="ownerMainTab() === 'personal'"
                (click)="ownerMainTab.set('personal')">
                <span class="pill-tab__label">My Reservations</span>
              </button>
              <button type="button" class="pill-tab" role="tab"
                [class.pill-tab--active]="ownerMainTab() === 'manage'"
                [attr.aria-selected]="ownerMainTab() === 'manage'"
                (click)="ownerMainTab.set('manage')">
                <span class="pill-tab__label">Manage my Shops</span>
                @if (managedPendingRequests().length > 0) {
                  <span class="notif-dot" aria-label="Pending reservation requests">{{ managedPendingRequests().length }}</span>
                }
              </button>
            </nav>

            @if (ownerMainTab() === 'personal') {
              <div class="tabs-nav__panel">
                <div class="tabs-nav__panel-header">
                  <nav class="pill-tabs pill-tabs--sub" role="tablist" aria-label="My reservations">
                    <button type="button" class="pill-tab pill-tab--sub" role="tab"
                      [class.pill-tab--active]="personalActiveTab() === 'requests'"
                      [attr.aria-selected]="personalActiveTab() === 'requests'"
                      (click)="personalActiveTab.set('requests')">
                      <span class="pill-tab__label">Requests</span>
                      <span class="tab__count">{{ myPersonalRequests().length }}</span>
                    </button>
                    <button type="button" class="pill-tab pill-tab--sub" role="tab"
                      [class.pill-tab--active]="personalActiveTab() === 'confirmed'"
                      [attr.aria-selected]="personalActiveTab() === 'confirmed'"
                      (click)="personalActiveTab.set('confirmed')">
                      <span class="pill-tab__label">Confirmed</span>
                      <span class="tab__count">{{ myPersonalReservations().length }}</span>
                    </button>
                  </nav>
                </div>
                <div class="tabs-nav__panel-body">
                  @if (personalActiveTab() === 'requests') {
                    @if (myPersonalRequests().length === 0) {
                      <div class="empty-state"><p>No reservation requests.</p></div>
                    } @else {
                      <div class="compact-list">
                        @for (req of myPersonalRequests(); track req.id) {
                          <article class="compact-row">
                            <div class="compact-row__start">
                              <span class="compact-row__avatar">{{ req.shop.name.charAt(0).toUpperCase() }}</span>
                              <div class="compact-row__text">
                                <span class="compact-row__primary">{{ req.shop.name }}</span>
                                <span class="compact-row__secondary">{{ eventLabel(req) }} &middot; Party {{ req.partySize }}</span>
                              </div>
                            </div>
                            <span class="badge"
                              [class.badge-pending]="req.status === 'PENDING'"
                              [class.badge-accepted]="req.status === 'ACCEPTED'"
                              [class.badge-denied]="req.status === 'DENIED'">{{ req.status }}</span>
                          </article>
                        }
                      </div>
                    }
                  }
                  @if (personalActiveTab() === 'confirmed') {
                    @if (myPersonalReservations().length === 0) {
                      <div class="empty-state"><p>No confirmed reservations.</p></div>
                    } @else {
                      <div class="compact-list">
                        @for (r of myPersonalReservations(); track r.id) {
                          <article class="compact-row">
                            <div class="compact-row__start">
                              <span class="compact-row__avatar">{{ r.shop.name.charAt(0).toUpperCase() }}</span>
                              <div class="compact-row__text">
                                <span class="compact-row__primary">{{ r.shop.name }}</span>
                                <span class="compact-row__secondary">{{ eventLabel(r) }} &middot; {{ r.table ? 'Table ' + r.table.number : 'N/A' }} &middot; Party {{ r.partySize }}</span>
                              </div>
                            </div>
                          </article>
                        }
                      </div>
                    }
                  }
                </div>
              </div>
            }

            @if (ownerMainTab() === 'manage') {
              <div class="tabs-nav__panel tabs-nav__panel--overflow-visible">
                <div class="tabs-nav__panel-header">
                  <nav class="pill-tabs pill-tabs--sub" role="tablist" aria-label="Manage my shops">
                    <button type="button" class="pill-tab pill-tab--sub" role="tab"
                      [class.pill-tab--active]="ownerSubTab() === 'pending'"
                      [attr.aria-selected]="ownerSubTab() === 'pending'"
                      (click)="ownerSubTab.set('pending')">
                      <span class="pill-tab__label">Pending</span>
                      <span class="tab__count">{{ managedPendingRequests().length }}</span>
                    </button>
                    <button type="button" class="pill-tab pill-tab--sub" role="tab"
                      [class.pill-tab--active]="ownerSubTab() === 'approved'"
                      [attr.aria-selected]="ownerSubTab() === 'approved'"
                      (click)="ownerSubTab.set('approved')">
                      <span class="pill-tab__label">Approved</span>
                      <span class="tab__count">{{ managedReservations().length }}</span>
                    </button>
                    <button type="button" class="pill-tab pill-tab--sub" role="tab"
                      [class.pill-tab--active]="ownerSubTab() === 'denied'"
                      [attr.aria-selected]="ownerSubTab() === 'denied'"
                      (click)="ownerSubTab.set('denied')">
                      <span class="pill-tab__label">Denied</span>
                      <span class="tab__count">{{ managedDeniedRequests().length }}</span>
                    </button>
                  </nav>
                </div>
                <div class="tabs-nav__panel-body">
                  @if (ownerSubTab() === 'pending') {
                    @if (loading()) {
                      <div class="loading">Loading requests...</div>
                    } @else if (managedPendingRequests().length === 0) {
                      <div class="empty-state"><p>No pending reservation requests.</p></div>
                    } @else {
                      <div class="compact-list">
                        @for (req of managedPendingRequests(); track req.id) {
                          <article class="compact-row">
                            <div class="compact-row__start">
                              <span class="compact-row__avatar">{{ (req.user?.name ?? '?').charAt(0).toUpperCase() }}</span>
                              <div class="compact-row__text">
                                <span class="compact-row__primary">{{ req.user?.name ?? '—' }}</span>
                                <span class="compact-row__secondary">{{ req.shop.name }} &middot; {{ eventLabel(req) }} &middot; Party {{ req.partySize }}</span>
                              </div>
                            </div>
                            <span class="badge badge-pending">{{ req.status }}</span>
                            <div class="compact-row__end" style="flex-wrap:wrap">
                              <app-form-select
                                [compact]="true"
                                placeholder="Table"
                                [options]="tableSelectOptionsForRequest(req)"
                                [ngModel]="tableSelectValue(req.id)"
                                (ngModelChange)="onTableSelectChange(req.id, $event)"
                              />
                              @if (!hasSuitableTablesForRequest(req)) {
                                <span class="text-muted" style="font-size:0.6875rem">No table for party of {{ req.partySize }}</span>
                              }
                              <button class="btn btn--compact btn-primary" (click)="onAccept(req)">Accept</button>
                              <button class="btn btn--compact btn-danger" (click)="onDeny(req)">Deny</button>
                            </div>
                          </article>
                        }
                      </div>
                    }
                  }

                  @if (ownerSubTab() === 'approved') {
                    @if (managedReservations().length === 0) {
                      <div class="empty-state"><p>No confirmed reservations.</p></div>
                    } @else {
                      <div class="compact-list">
                        @for (r of managedReservations(); track r.id) {
                          <article class="compact-row">
                            <div class="compact-row__start">
                              <span class="compact-row__avatar">{{ (r.user?.name ?? '?').charAt(0).toUpperCase() }}</span>
                              <div class="compact-row__text">
                                <span class="compact-row__primary">{{ r.user?.name ?? '—' }}</span>
                                <span class="compact-row__secondary">{{ r.shop.name }} &middot; {{ eventLabel(r) }} &middot; {{ r.table ? 'Table ' + r.table.number : 'N/A' }} &middot; Party {{ r.partySize }}</span>
                              </div>
                            </div>
                          </article>
                        }
                      </div>
                    }
                  }

                  @if (ownerSubTab() === 'denied') {
                    @if (loading()) {
                      <div class="loading">Loading requests...</div>
                    } @else if (managedDeniedRequests().length === 0) {
                      <div class="empty-state"><p>No denied reservation requests.</p></div>
                    } @else {
                      <div class="compact-list">
                        @for (req of managedDeniedRequests(); track req.id) {
                          <article class="compact-row">
                            <div class="compact-row__start">
                              <span class="compact-row__avatar">{{ (req.user?.name ?? '?').charAt(0).toUpperCase() }}</span>
                              <div class="compact-row__text">
                                <span class="compact-row__primary">{{ req.user?.name ?? '—' }}</span>
                                <span class="compact-row__secondary">{{ req.shop.name }} &middot; {{ eventLabel(req) }} &middot; Party {{ req.partySize }}</span>
                              </div>
                            </div>
                            <span class="badge badge-denied">{{ req.status }}</span>
                          </article>
                        }
                      </div>
                    }
                  }
                </div>
              </div>
            }
          </div>
        </div>
      } @else {
        <nav class="pill-tabs mb-3" role="tablist" aria-label="Reservations">
          <button type="button" class="pill-tab" role="tab"
            [class.pill-tab--active]="activeTab() === 'requests'"
            [attr.aria-selected]="activeTab() === 'requests'"
            (click)="activeTab.set('requests')">
            Reservation Requests
          </button>
          <button type="button" class="pill-tab" role="tab"
            [class.pill-tab--active]="activeTab() === 'confirmed'"
            [attr.aria-selected]="activeTab() === 'confirmed'"
            (click)="activeTab.set('confirmed')">
            Confirmed Reservations
          </button>
        </nav>

        @if (activeTab() === 'requests') {
          @if (loading()) {
            <div class="loading">Loading requests...</div>
          } @else if (allRequests().length === 0) {
            <div class="empty-state"><p>No reservation requests.</p></div>
          } @else {
            <div class="compact-list">
              @for (req of allRequests(); track req.id) {
                <article class="compact-row">
                  <div class="compact-row__start">
                    <span class="compact-row__avatar">{{ req.shop.name.charAt(0).toUpperCase() }}</span>
                    <div class="compact-row__text">
                      <span class="compact-row__primary">{{ req.shop.name }}</span>
                      <span class="compact-row__secondary">{{ eventLabel(req) }} &middot; Party {{ req.partySize }}</span>
                    </div>
                  </div>
                  <span class="badge"
                    [class.badge-pending]="req.status === 'PENDING'"
                    [class.badge-accepted]="req.status === 'ACCEPTED'"
                    [class.badge-denied]="req.status === 'DENIED'">{{ req.status }}</span>
                </article>
              }
            </div>
          }
        }

        @if (activeTab() === 'confirmed') {
          @if (myReservations().length === 0) {
            <div class="empty-state"><p>No confirmed reservations.</p></div>
          } @else {
            <div class="compact-list">
              @for (r of myReservations(); track r.id) {
                <article class="compact-row">
                  <div class="compact-row__start">
                    <span class="compact-row__avatar">{{ r.shop.name.charAt(0).toUpperCase() }}</span>
                    <div class="compact-row__text">
                      <span class="compact-row__primary">{{ r.shop.name }}</span>
                      <span class="compact-row__secondary">{{ eventLabel(r) }} &middot; {{ r.table ? 'Table ' + r.table.number : 'N/A' }} &middot; Party {{ r.partySize }}</span>
                    </div>
                  </div>
                </article>
              }
            </div>
          }
        }
      }
    </div>
  `,
  styles: [`
    :host {
      display: block;
    }

    .page-header__actions {
      display: flex;
      gap: 0.5rem;
      flex-wrap: wrap;
    }

    @media (max-width: 768px) {
      .page-header__actions {
        width: 100%;
        flex-direction: column;
      }

      .page-header__actions .btn {
        width: 100%;
        min-height: 44px;
      }
    }
  `],
})
export class ReservationsComponent implements OnInit {
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
  readonly tables = signal<TableResponseDto[]>([]);
  readonly allReservations = signal<ReservationResponseDto[]>([]);
  readonly allRequests = signal<ReservationRequestResponseDto[]>([]);
  readonly loading = signal(true);
  readonly activeTab = signal<'requests' | 'confirmed'>('requests');
  readonly personalActiveTab = signal<'requests' | 'confirmed'>('requests');
  readonly ownerMainTab = signal<'personal' | 'manage'>('personal');
  readonly ownerSubTab = signal<'pending' | 'approved' | 'denied'>('pending');
  readonly showRequestForm = signal(false);
  readonly requestFormMode = signal<'guest' | 'self' | null>(null);
  readonly selectedTableForRequest = signal<{ reqId: string; tableId: string } | null>(null);

  readonly isShopOwner = computed(() => {
    const profile = this.profileService.currentUser();
    if (!profile) return false;
    if (profile.userType === 'SHOP_OWNER' || this.authService.isAdmin()) return true;
    return this.shops().some(s => s.createdBy?.id === profile.id);
  });

  readonly pageTitle = computed(() =>
    this.isShopOwner() ? 'Reservations' : 'My Reservations',
  );

  readonly ownedShopIds = computed(() => {
    const profile = this.profileService.currentUser();
    if (!profile) return new Set<string>();
    return new Set(
      this.shops()
        .filter(s => s.createdBy?.id === profile.id)
        .map(s => s.id),
    );
  });

  readonly shopsForGuestRequest = computed(() =>
    this.shops().filter(s => this.ownedShopIds().has(s.id)),
  );

  readonly shopsForSelfRequest = computed(() => {
    if (!this.isShopOwner()) {
      return this.shops();
    }
    return this.shops().filter(s => !this.ownedShopIds().has(s.id));
  });

  readonly managedPendingRequests = computed(() =>
    this.allRequests().filter(
      r => r.status === 'PENDING' && r.shop?.id && this.ownedShopIds().has(r.shop.id),
    ),
  );

  readonly managedDeniedRequests = computed(() =>
    this.allRequests().filter(
      r => r.status === 'DENIED' && r.shop?.id && this.ownedShopIds().has(r.shop.id),
    ),
  );

  readonly managedReservations = computed(() =>
    this.allReservations().filter(
      r => r.shop?.id && this.ownedShopIds().has(r.shop.id),
    ),
  );

  readonly myPersonalRequests = computed(() => {
    const profile = this.profileService.currentUser();
    if (!profile) return [];
    return this.allRequests().filter(r => r.user?.id === profile.id);
  });

  readonly myPersonalReservations = computed(() => {
    const profile = this.profileService.currentUser();
    if (!profile) return [];
    return this.allReservations().filter(
      r => r.user?.id === profile.id && r.shop?.id && !this.ownedShopIds().has(r.shop.id),
    );
  });

  readonly myReservations = computed(() => {
    const profile = this.profileService.currentUser();
    if (!profile) return [];
    return this.allReservations().filter(r => r.user?.id === profile.id);
  });

  readonly requestForm = this.fb.nonNullable.group({
    guestUserId: [''],
    shopId: ['', Validators.required],
    eventId: ['', Validators.required],
    partySize: [1, [Validators.required, Validators.min(1)]],
  });

  private readonly requestEventId = toSignal(this.requestForm.controls.eventId.valueChanges, {
    initialValue: this.requestForm.controls.eventId.value,
  });

  private readonly requestGuestUserId = toSignal(this.requestForm.controls.guestUserId.valueChanges, {
    initialValue: this.requestForm.controls.guestUserId.value,
  });

  readonly requestTargetUserId = computed(() => {
    const profile = this.profileService.currentUser();
    if (!profile) return '';
    if (this.requestFormMode() === 'guest') {
      return this.requestGuestUserId();
    }
    return profile.id;
  });

  readonly selectableEventsForRequest = computed(() => {
    const userId = this.requestTargetUserId();
    const reservable = this.eventsForShop().filter(e => canReserveForEvent(e));
    if (!userId) {
      return reservable;
    }
    const blocked = eventIdsBlockedForUser(this.allRequests(), this.allReservations(), userId);
    return reservable.filter(e => !blocked.has(e.eventId));
  });

  readonly canSubmitRequest = computed(() => {
    const eventId = this.requestEventId();
    if (!eventId) return false;
    const userId = this.requestTargetUserId();
    if (!userId) return false;
    return this.selectableEventsForRequest().some(e => e.eventId === eventId);
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
      && this.eventsForShop().every(e => isEventFull(e));
  });

  readonly guestSelectOptions = computed((): FormSelectOption[] =>
    this.users().map(u => ({
      value: u.id,
      label: `${u.name} (${u.username})`,
    })),
  );

  readonly shopSelectOptions = computed((): FormSelectOption[] => {
    const list =
      this.requestFormMode() === 'guest'
        ? this.shopsForGuestRequest()
        : this.shopsForSelfRequest();
    return list.map(s => ({ value: s.id, label: s.name }));
  });

  readonly eventSelectOptionsForRequest = computed((): FormSelectOption[] =>
    this.selectableEventsForRequest().map(e => ({
      value: e.eventId,
      label: `${e.eventName} (${e.eventDate}) - ${this.formatEventAvailability(e)}`,
    })),
  );

  tablesForRequest(req: ReservationRequestResponseDto): TableResponseDto[] {
    const reservedTableIds = new Set(
      this.allReservations()
        .filter(r => !req.eventId || r.eventId === req.eventId)
        .map(r => r.table?.id)
        .filter(Boolean),
    );
    return this.tablesForShop(req.shop.id).filter(t =>
      !reservedTableIds.has(t.id),
    );
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
    this.loadTables();
    this.router.events
      .pipe(
        filter(event => event instanceof NavigationEnd),
        takeUntilDestroyed(this.destroyRef),
      )
      .subscribe(() => this.loadTables());
    this.requestForm.controls.shopId.valueChanges
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(shopId => this.onShopChange(shopId));
    this.requestForm.controls.guestUserId.valueChanges
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(() => this.requestForm.controls.eventId.setValue(''));
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
    const mode = this.ownedShopIds().has(shopId) ? 'guest' : 'self';
    this.requestFormMode.set(mode);
    this.showRequestForm.set(true);
    this.applyGuestValidatorsForMode(mode);
    this.requestForm.patchValue({ shopId, eventId: '', partySize: 1 }, { emitEvent: false });
    this.loadEventsForRequestShop(shopId, events => {
      if (events.some(e => e.eventId === eventId && canReserveForEvent(e))) {
        this.requestForm.controls.eventId.setValue(eventId);
      }
      void this.router.navigate([], {
        relativeTo: this.route,
        queryParams: {},
        replaceUrl: true,
      });
    });
  }

  private isReservationConflict(error: unknown): boolean {
    return error instanceof HttpErrorResponse && error.status === 409;
  }

  private formatEventAvailability(event: EventResponseDto): string {
    const label = eventAvailabilityLabel(event);
    return label === '—' ? 'Available' : label;
  }

  openRequestForm(mode: 'guest' | 'self'): void {
    if (this.showRequestForm() && this.requestFormMode() === mode) {
      this.closeRequestForm();
      return;
    }
    this.requestFormMode.set(mode);
    this.showRequestForm.set(true);
    this.applyGuestValidatorsForMode(mode);
    if (this.requestForm.controls.shopId.value) {
      const shopId = this.requestForm.controls.shopId.value;
      const allowed =
        mode === 'guest'
          ? this.shopsForGuestRequest().some(s => s.id === shopId)
          : this.shopsForSelfRequest().some(s => s.id === shopId);
      if (!allowed) {
        this.requestForm.controls.shopId.setValue('');
        this.eventsForShop.set([]);
      }
    }
  }

  private applyGuestValidatorsForMode(mode: 'guest' | 'self'): void {
    if (mode === 'guest') {
      this.requestForm.controls.guestUserId.setValidators([Validators.required]);
    } else {
      this.requestForm.controls.guestUserId.clearValidators();
    }
    this.requestForm.controls.guestUserId.updateValueAndValidity();
  }

  private closeRequestForm(): void {
    this.showRequestForm.set(false);
    this.requestFormMode.set(null);
    this.eventsForShop.set([]);
    this.requestForm.controls.guestUserId.clearValidators();
    this.requestForm.controls.guestUserId.updateValueAndValidity();
    this.requestForm.reset({ guestUserId: '', shopId: '', eventId: '', partySize: 1 });
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

  tablesForShop(shopId: string): TableResponseDto[] {
    return this.tables().filter(t => t.shopId === shopId);
  }

  private loadTables(): void {
    this.tableService.getAll().subscribe(tables => this.tables.set(tables));
  }

  private loadData(): void {
    this.loadTables();
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
    const userId =
      this.requestFormMode() === 'guest' ? val.guestUserId : profile.id;
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
        const mode = this.requestFormMode();
        this.closeRequestForm();
        if (mode === 'guest') {
          this.ownerMainTab.set('manage');
          this.ownerSubTab.set('pending');
        } else if (this.isShopOwner()) {
          this.ownerMainTab.set('personal');
          this.personalActiveTab.set('requests');
        } else {
          this.activeTab.set('requests');
        }
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
