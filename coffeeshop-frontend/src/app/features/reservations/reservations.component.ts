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
          <div style="display:flex;gap:0.5rem;flex-wrap:wrap">
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
          <select
            class="tab-select view-mobile-only mb-3"
            aria-label="Reservation section"
            [value]="ownerMainTab()"
            (change)="onOwnerMainTabSelect($event)"
          >
            <option value="personal">My Reservations</option>
            <option value="manage">Manage my Shops</option>
          </select>
          <div class="tabs tabs--primary view-desktop-only" role="tablist" aria-label="Reservation sections">
            <button
              type="button"
              class="tab"
              role="tab"
              [class.active]="ownerMainTab() === 'personal'"
              [attr.aria-selected]="ownerMainTab() === 'personal'"
              (click)="ownerMainTab.set('personal')">
              <span class="tab__label">My Reservations</span>
            </button>
            <button
              type="button"
              class="tab"
              role="tab"
              [class.active]="ownerMainTab() === 'manage'"
              [attr.aria-selected]="ownerMainTab() === 'manage'"
              (click)="ownerMainTab.set('manage')">
              <span class="tab__label">Manage my Shops</span>
            </button>
          </div>

          @if (ownerMainTab() === 'personal') {
            <div class="tabs-nav__panel">
              <div class="tabs-nav__panel-header">
                <select
                  class="tab-select view-mobile-only mb-3"
                  aria-label="My reservations"
                  [value]="personalActiveTab()"
                  (change)="onPersonalActiveTabSelect($event)"
                >
                  <option value="requests">Reservation Requests ({{ myPersonalRequests().length }})</option>
                  <option value="confirmed">Confirmed Reservations ({{ myPersonalReservations().length }})</option>
                </select>
                <div class="tabs tabs--sub view-desktop-only" role="tablist" aria-label="My reservations">
                  <button
                    type="button"
                    class="tab"
                    role="tab"
                    [class.active]="personalActiveTab() === 'requests'"
                    [attr.aria-selected]="personalActiveTab() === 'requests'"
                    (click)="personalActiveTab.set('requests')">
                    <span class="tab__label">Reservation Requests</span>
                    <span class="tab__count">{{ myPersonalRequests().length }}</span>
                  </button>
                  <button
                    type="button"
                    class="tab"
                    role="tab"
                    [class.active]="personalActiveTab() === 'confirmed'"
                    [attr.aria-selected]="personalActiveTab() === 'confirmed'"
                    (click)="personalActiveTab.set('confirmed')">
                    <span class="tab__label">Confirmed Reservations</span>
                    <span class="tab__count">{{ myPersonalReservations().length }}</span>
                  </button>
                </div>
              </div>
              <div class="tabs-nav__panel-body">
                @if (personalActiveTab() === 'requests') {
                  @if (myPersonalRequests().length === 0) {
                    <div class="empty-state"><p>No reservation requests.</p></div>
                  } @else {
                    <div class="view-mobile-only list-card-grid mb-3">
                      @for (req of myPersonalRequests(); track req.id) {
                        <article class="list-card">
                          <div class="list-card__primary">
                            <span class="list-card__title">{{ req.shop.name }}</span>
                            <span class="list-card__subtitle">{{ eventLabel(req) }}</span>
                          </div>
                          <div class="list-card__meta">
                            Party {{ req.partySize }} ·
                            <span class="badge"
                              [class.badge-pending]="req.status === 'PENDING'"
                              [class.badge-accepted]="req.status === 'ACCEPTED'"
                              [class.badge-denied]="req.status === 'DENIED'">
                              {{ req.status }}
                            </span>
                          </div>
                        </article>
                      }
                    </div>
                    <div class="view-desktop-only">
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
                            @for (req of myPersonalRequests(); track req.id) {
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
                    </div>
                  }
                }

                @if (personalActiveTab() === 'confirmed') {
                  @if (myPersonalReservations().length === 0) {
                    <div class="empty-state"><p>No confirmed reservations.</p></div>
                  } @else {
                    <div class="view-mobile-only list-card-grid mb-3">
                      @for (r of myPersonalReservations(); track r.id) {
                        <article class="list-card">
                          <div class="list-card__primary">
                            <span class="list-card__title">{{ r.shop.name }}</span>
                            <span class="list-card__subtitle">{{ eventLabel(r) }}</span>
                          </div>
                          <div class="list-card__meta">
                            {{ r.table ? 'Table ' + r.table.number : 'N/A' }} · Party {{ r.partySize }}
                          </div>
                        </article>
                      }
                    </div>
                    <div class="view-desktop-only">
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
                            @for (r of myPersonalReservations(); track r.id) {
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
                    </div>
                  }
                }
              </div>
            </div>
          }

          @if (ownerMainTab() === 'manage') {
            <div class="tabs-nav__panel">
              <div class="tabs-nav__panel-header">
                <select
                  class="tab-select view-mobile-only mb-3"
                  aria-label="Manage shop reservations"
                  [value]="ownerSubTab()"
                  (change)="onOwnerSubTabSelect($event)"
                >
                  <option value="pending">Pending ({{ managedPendingRequests().length }})</option>
                  <option value="approved">Approved ({{ managedReservations().length }})</option>
                  <option value="denied">Denied ({{ managedDeniedRequests().length }})</option>
                </select>
                <div class="tabs tabs--sub view-desktop-only" role="tablist" aria-label="Manage my shops">
                  <button
                    type="button"
                    class="tab"
                    role="tab"
                    [class.active]="ownerSubTab() === 'pending'"
                    [attr.aria-selected]="ownerSubTab() === 'pending'"
                    (click)="ownerSubTab.set('pending')">
                    <span class="tab__label">Pending</span>
                    <span class="tab__count">{{ managedPendingRequests().length }}</span>
                  </button>
                  <button
                    type="button"
                    class="tab"
                    role="tab"
                    [class.active]="ownerSubTab() === 'approved'"
                    [attr.aria-selected]="ownerSubTab() === 'approved'"
                    (click)="ownerSubTab.set('approved')">
                    <span class="tab__label">Approved</span>
                    <span class="tab__count">{{ managedReservations().length }}</span>
                  </button>
                  <button
                    type="button"
                    class="tab"
                    role="tab"
                    [class.active]="ownerSubTab() === 'denied'"
                    [attr.aria-selected]="ownerSubTab() === 'denied'"
                    (click)="ownerSubTab.set('denied')">
                    <span class="tab__label">Denied</span>
                    <span class="tab__count">{{ managedDeniedRequests().length }}</span>
                  </button>
                </div>
              </div>
              <div class="tabs-nav__panel-body">
                @if (ownerSubTab() === 'pending') {
                  @if (loading()) {
                    <div class="loading">Loading requests...</div>
                  } @else if (managedPendingRequests().length === 0) {
                    <div class="empty-state"><p>No pending reservation requests.</p></div>
                  } @else {
                    <div class="view-mobile-only list-card-grid mb-3">
                      @for (req of managedPendingRequests(); track req.id) {
                        <article class="list-card">
                          <div class="list-card__primary">
                            <span class="list-card__title">{{ req.user?.name ?? '—' }}</span>
                            <span class="list-card__subtitle">{{ req.shop.name }} · {{ eventLabel(req) }}</span>
                          </div>
                          <div class="list-card__meta">
                            Party {{ req.partySize }} · <span class="badge badge-pending">{{ req.status }}</span>
                          </div>
                          <div class="list-card__actions reservation-actions">
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
                        </article>
                      }
                    </div>
                    <div class="view-desktop-only">
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
                            @for (req of managedPendingRequests(); track req.id) {
                              <tr>
                                <td>{{ req.user?.name ?? '—' }}</td>
                                <td>{{ req.shop.name }}</td>
                                <td>{{ eventLabel(req) }}</td>
                                <td>{{ req.partySize }}</td>
                                <td><span class="badge badge-pending">{{ req.status }}</span></td>
                                <td class="data-table__actions">
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
                    </div>
                  }
                }

                @if (ownerSubTab() === 'approved') {
                  @if (managedReservations().length === 0) {
                    <div class="empty-state"><p>No confirmed reservations.</p></div>
                  } @else {
                    <div class="view-mobile-only list-card-grid mb-3">
                      @for (r of managedReservations(); track r.id) {
                        <article class="list-card">
                          <div class="list-card__primary">
                            <span class="list-card__title">{{ r.user?.name ?? '—' }}</span>
                            <span class="list-card__subtitle">{{ r.shop.name }} · {{ eventLabel(r) }}</span>
                          </div>
                          <div class="list-card__meta">
                            {{ r.table ? 'Table ' + r.table.number : 'N/A' }} · Party {{ r.partySize }}
                          </div>
                        </article>
                      }
                    </div>
                    <div class="view-desktop-only">
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
                            @for (r of managedReservations(); track r.id) {
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
                    </div>
                  }
                }

                @if (ownerSubTab() === 'denied') {
                  @if (loading()) {
                    <div class="loading">Loading requests...</div>
                  } @else if (managedDeniedRequests().length === 0) {
                    <div class="empty-state"><p>No denied reservation requests.</p></div>
                  } @else {
                    <div class="view-mobile-only list-card-grid mb-3">
                      @for (req of managedDeniedRequests(); track req.id) {
                        <article class="list-card">
                          <div class="list-card__primary">
                            <span class="list-card__title">{{ req.user?.name ?? '—' }}</span>
                            <span class="list-card__subtitle">{{ req.shop.name }} · {{ eventLabel(req) }}</span>
                          </div>
                          <div class="list-card__meta">
                            Party {{ req.partySize }} · <span class="badge badge-denied">{{ req.status }}</span>
                          </div>
                        </article>
                      }
                    </div>
                    <div class="view-desktop-only">
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
                            @for (req of managedDeniedRequests(); track req.id) {
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
                    </div>
                  }
                }
              </div>
            </div>
          }
          </div>
        </div>
      } @else {
        <select
          class="tab-select view-mobile-only mb-3"
          aria-label="Reservations"
          [value]="activeTab()"
          (change)="onActiveTabSelect($event)"
        >
          <option value="requests">Reservation Requests</option>
          <option value="confirmed">Confirmed Reservations</option>
        </select>
        <div class="tabs view-desktop-only">
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
            <div class="view-mobile-only list-card-grid mb-3">
              @for (req of allRequests(); track req.id) {
                <article class="list-card">
                  <div class="list-card__primary">
                    <span class="list-card__title">{{ req.shop.name }}</span>
                    <span class="list-card__subtitle">{{ eventLabel(req) }}</span>
                  </div>
                  <div class="list-card__meta">
                    Party {{ req.partySize }} ·
                    <span class="badge"
                      [class.badge-pending]="req.status === 'PENDING'"
                      [class.badge-accepted]="req.status === 'ACCEPTED'"
                      [class.badge-denied]="req.status === 'DENIED'">
                      {{ req.status }}
                    </span>
                  </div>
                </article>
              }
            </div>
            <div class="view-desktop-only">
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
            </div>
          }
        }

        @if (activeTab() === 'confirmed') {
          @if (myReservations().length === 0) {
            <div class="empty-state"><p>No confirmed reservations.</p></div>
          } @else {
            <div class="view-mobile-only list-card-grid mb-3">
              @for (r of myReservations(); track r.id) {
                <article class="list-card">
                  <div class="list-card__primary">
                    <span class="list-card__title">{{ r.shop.name }}</span>
                    <span class="list-card__subtitle">{{ eventLabel(r) }}</span>
                  </div>
                  <div class="list-card__meta">
                    {{ r.table ? 'Table ' + r.table.number : 'N/A' }} · Party {{ r.partySize }}
                  </div>
                </article>
              }
            </div>
            <div class="view-desktop-only">
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
            </div>
          }
        }
      }
    </div>
  `,
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
    const shops =
      this.requestFormMode() === 'guest'
        ? this.shopsForGuestRequest()
        : this.shopsForSelfRequest();
    return shops.map(s => ({ value: s.id, label: s.name }));
  });

  readonly eventSelectOptionsForRequest = computed((): FormSelectOption[] =>
    this.selectableEventsForRequest().map(e => ({
      value: e.eventId,
      label: `${e.eventName} (${e.eventDate}) - ${this.formatEventAvailability(e)}`,
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

  onOwnerMainTabSelect(event: Event): void {
    this.ownerMainTab.set((event.target as HTMLSelectElement).value as 'personal' | 'manage');
  }

  onPersonalActiveTabSelect(event: Event): void {
    this.personalActiveTab.set((event.target as HTMLSelectElement).value as 'requests' | 'confirmed');
  }

  onOwnerSubTabSelect(event: Event): void {
    this.ownerSubTab.set((event.target as HTMLSelectElement).value as 'pending' | 'approved' | 'denied');
  }

  onActiveTabSelect(event: Event): void {
    this.activeTab.set((event.target as HTMLSelectElement).value as 'requests' | 'confirmed');
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
