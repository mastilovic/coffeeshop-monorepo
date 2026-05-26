import {
  Component,
  inject,
  Injector,
  signal,
  computed,
  OnInit,
  ChangeDetectionStrategy,
} from '@angular/core';
import { takeUntilDestroyed, toObservable } from '@angular/core/rxjs-interop';
import { debounceTime, distinctUntilChanged, skip } from 'rxjs';
import { HttpErrorResponse } from '@angular/common/http';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { FormBuilder, FormsModule, ReactiveFormsModule, Validators } from '@angular/forms';
import { FormSelectComponent } from '../../shared/form-select/form-select.component';
import { FormSelectOption } from '../../shared/form-select/form-select-option.model';
import { ShopService } from '../../services/shop.service';
import { MenuItemService } from '../../services/menu-item.service';
import { MenuService } from '../../services/menu.service';
import { TableService } from '../../services/table.service';
import { ReservationService } from '../../services/reservation.service';
import { ReservationRequestService } from '../../services/reservation-request.service';
import { ReviewService } from '../../services/review.service';
import { ReviewCommentService } from '../../services/review-comment.service';
import { EventService } from '../../services/event.service';
import { ProfileService } from '../../services/profile.service';
import { AuthService } from '../../services/auth.service';
import { ShopResponseDto } from '../../models/shop.model';
import { MenuItemResponseDto, MenuItemType, MenuCurrency, MENU_ITEM_TYPES, MENU_CURRENCIES } from '../../models/menu.model';
import { TableResponseDto } from '../../models/table.model';
import { ReservationResponseDto, ReservationRequestResponseDto } from '../../models/reservation.model';
import { EventResponseDto } from '../../models/event.model';
import { ReviewResponseDto } from '../../models/review.model';
import { CommunityPostResponseDto } from '../../models/community.model';
import { UserSummaryDto } from '../../models/user.model';
import { CommunityService } from '../../services/community.service';
import { StarRatingComponent } from '../../shared/star-rating/star-rating.component';
import { getAcceptReservationErrorMessage } from '../../utils/api-error';
import {
  canReserveForEvent,
  eventAvailabilityLabel as formatEventAvailability,
  eventIdsBlockedForUser,
  isEventFull,
} from '../../utils/reservation-event.utils';
import { DialogService } from '../../services/dialog.service';
import { DateTimePickerComponent } from '../../shared/date-time-picker/date-time-picker.component';
import { todayIso } from '../../shared/calendar/calendar-date.utils';
import {
  futureDateValidator,
  normalizeDateTimeLocal,
} from '../../utils/event-form.utils';

type Tab = 'users' | 'menu' | 'tables' | 'reservations' | 'events' | 'reviews';
type ReservationSubTab = 'pending' | 'approved' | 'denied';

@Component({
  selector: 'app-shop-details',
  standalone: true,
  imports: [
    ReactiveFormsModule,
    FormsModule,
    RouterLink,
    StarRatingComponent,
    FormSelectComponent,
    DateTimePickerComponent,
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="page">
      @if (loading()) {
        <div class="loading">Loading shop details...</div>
      } @else if (!shop()) {
        <div class="empty-state"><p>Shop not found.</p><a routerLink="/shops">Back to shops</a></div>
      } @else {
        <div class="page-header">
          <div>
            <h1 class="page-title">
              {{ shop()!.name }}
              @if (isFavourite()) {
                <span class="badge badge-joined">Joined</span>
              }
            </h1>
            <p class="text-muted">{{ shop()!.city }} &middot; {{ shop()!.address }} &middot; {{ shop()!.email }}</p>
          </div>
          <div style="display:flex;align-items:center;gap:0.75rem">
            @if (!canManageShop()) {
              <button
                type="button"
                class="btn btn-icon btn-favourite"
                [class.btn-favourite--active]="isFavourite()"
                [disabled]="togglingFavourite()"
                [attr.aria-label]="isFavourite() ? 'Leave ' + shop()!.name : 'Join ' + shop()!.name"
                [title]="isFavourite() ? 'Leave ' + shop()!.name : 'Join ' + shop()!.name"
                (click)="toggleFavourite()"
              >
                <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                  @if (isFavourite()) {
                    <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
                  } @else {
                    <path d="M16.5 3c-1.74 0-3.41.81-4.5 2.09C10.91 3.81 9.24 3 7.5 3 4.42 3 2 5.42 2 8.5c0 3.78 3.4 6.86 8.55 11.54L12 21.35l1.45-1.32C18.6 15.36 22 12.28 22 8.5 22 5.42 19.58 3 16.5 3zm-4.4 15.55l-.1.1-.1-.1C7.14 14.24 4 11.39 4 8.5 4 6.5 5.5 5 7.5 5c1.54 0 3.04.99 3.57 2.36h1.87C13.46 5.99 14.96 5 16.5 5c2 0 3.5 1.5 3.5 3.5 0 2.89-3.14 5.74-7.9 10.05z"/>
                  }
                </svg>
              </button>
            }
            <a routerLink="/shops" class="btn btn-secondary">Back</a>
          </div>
        </div>

        <select
          class="tab-select view-mobile-only mb-3"
          aria-label="Shop section"
          [value]="activeTab()"
          (change)="onPrimaryTabSelect($event)"
        >
          @for (t of visibleTabs(); track t.key) {
            <option [value]="t.key">{{ t.label }}</option>
          }
        </select>

        <div class="tabs view-desktop-only">
          @for (t of visibleTabs(); track t.key) {
            <button class="tab" [class.active]="activeTab() === t.key" (click)="onTabChange(t.key)">
              {{ t.label }}
            </button>
          }
        </div>

        <!-- COMMUNITY TAB -->
        @if (activeTab() === 'users') {
          @if (!canManageShop() && !isFavourite()) {
            <div class="form-card mb-3" style="display:flex;align-items:center;justify-content:space-between;gap:1rem;flex-wrap:wrap">
              <p style="margin:0">Join this shop's community to connect with other members.</p>
              <button type="button" class="btn btn-primary" [disabled]="togglingFavourite()" (click)="toggleFavourite()">
                Join community
              </button>
            </div>
          }

          <h3 class="mb-2">Members ({{ membersTotalElements() }})</h3>

          <div class="events-toolbar mb-3">
            <input
              class="form-input events-search"
              type="search"
              placeholder="Search by name or username..."
              aria-label="Search community members"
              [value]="membersSearchInput()"
              (input)="onMembersSearchInput($event)"
            />
          </div>

          @if (membersLoading()) {
            <div class="loading mb-3">Loading members...</div>
          } @else if (membersTotalElements() === 0) {
            <div class="empty-state mb-3"><p>{{ membersEmptyStateMessage() }}</p></div>
          } @else {
            <div class="view-mobile-only list-card-grid mb-3">
              @for (u of members(); track u.id) {
                <article class="list-card">
                  <div class="list-card__primary">
                    <span class="list-card__title">{{ u.name }}</span>
                    <span class="list-card__subtitle">{{ u.username }}</span>
                  </div>
                </article>
              }
            </div>
            <div class="view-desktop-only">
              <div class="table-container mb-3">
                <table class="data-table">
                  <thead><tr><th>Name</th><th>Username</th></tr></thead>
                  <tbody>
                    @for (u of members(); track u.id) {
                      <tr><td>{{ u.name }}</td><td>{{ u.username }}</td></tr>
                    }
                  </tbody>
                </table>
              </div>
            </div>

            <div class="pagination-bar mb-3">
              <span class="pagination-summary">{{ membersRangeLabel() }}</span>
              <div class="pagination-controls">
                <button
                  class="btn btn-secondary btn-sm"
                  [disabled]="membersPage() === 0"
                  (click)="goToMembersPage(membersPage() - 1)"
                >
                  Previous
                </button>
                <span class="pagination-page">Page {{ membersPage() + 1 }} of {{ membersTotalPages() }}</span>
                <button
                  class="btn btn-secondary btn-sm"
                  [disabled]="membersPage() >= membersTotalPages() - 1"
                  (click)="goToMembersPage(membersPage() + 1)"
                >
                  Next
                </button>
              </div>
            </div>
          }

          @if (isShopOwner()) {
            <div class="form-card mb-3">
              <h3 class="mb-2">Post announcement</h3>
              <p class="text-muted mb-2" style="font-size:0.875rem">Announcements appear pinned at the top of the feed.</p>
              <textarea
                class="form-input"
                rows="3"
                placeholder="Share news with your community..."
                [value]="announcementDraft()"
                (input)="announcementDraft.set($any($event.target).value)"></textarea>
              <button
                type="button"
                class="btn btn-primary"
                style="margin-top:0.5rem"
                [disabled]="!announcementDraft().trim() || postingAnnouncement()"
                (click)="onAnnouncementSubmit()">
                Post announcement
              </button>
            </div>
          }

          <h3 class="mb-2">Activity</h3>
          @if (communityLoading() && communityPosts().length === 0) {
            <div class="loading">Loading activity...</div>
          } @else if (communityPosts().length === 0) {
            <div class="empty-state"><p>No posts yet.</p></div>
          } @else {
            <div class="mb-3" style="display:flex;flex-direction:column;gap:1rem">
              @for (post of communityPosts(); track post.id) {
                <div class="form-card community-post" [class.community-post--pinned]="post.pinned">
                  <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:0.75rem;margin-bottom:0.5rem">
                    <div>
                      <strong>{{ post.author.name }}</strong>
                      @if (post.type === 'ANNOUNCEMENT') {
                        <span class="badge badge-joined" style="margin-left:0.5rem">Announcement</span>
                      }
                      @if (post.pinned) {
                        <span class="badge" style="margin-left:0.5rem;background:#4a3728;color:#f5d0a0">Pinned</span>
                      }
                      <p class="text-muted" style="font-size:0.8rem;margin:0.25rem 0 0">{{ formatPostDate(post.createdAt) }}</p>
                    </div>
                    @if (canDeletePost(post)) {
                      <button type="button" class="btn btn-sm btn-danger" (click)="onDeletePost(post)">Delete</button>
                    }
                  </div>
                  <p style="margin:0;white-space:pre-wrap">{{ post.body }}</p>
                </div>
              }
            </div>
            @if (communityHasMore()) {
              <button type="button" class="btn btn-secondary mb-3" [disabled]="communityLoading()" (click)="loadMoreCommunityPosts()">
                {{ communityLoading() ? 'Loading...' : 'Load more' }}
              </button>
            }
          }
        }

        <!-- MENU TAB -->
        @if (activeTab() === 'menu') {
          @if (canManageShop()) {
            <div class="mb-3">
              <button class="btn btn-secondary" (click)="onCreateMenu()">+ New Menu</button>
            </div>
          }

          <h3 class="mb-2">Current menu</h3>
          @if (!shop()!.currentMenu) {
            <div class="empty-state">
              <p>No menu yet.</p>
              @if (canManageShop()) {
                <p class="text-muted">Create a menu to start adding items.</p>
              }
            </div>
          } @else {
            @if (shop()!.currentMenu!.label) {
              <p class="text-muted mb-2">{{ shop()!.currentMenu!.label }}</p>
            }
            @if (canManageShop()) {
              @if (showMenuForm()) {
            <div class="form-card mb-3">
              <form [formGroup]="menuForm" (ngSubmit)="onMenuSubmit()">
                <div class="form-row">
                  <div class="form-group">
                    <label>Name</label>
                    <input class="form-input" formControlName="name" />
                  </div>
                  <div class="form-group">
                    <label>Price</label>
                    <input class="form-input" type="number" step="0.01" formControlName="price" />
                  </div>
                </div>
                <div class="form-row">
                  <div class="form-group">
                    <label>Currency</label>
                    <app-form-select
                      formControlName="priceCurrency"
                      placeholder="Currency"
                      [options]="menuCurrencySelectOptions"
                    />
                  </div>
                  <div class="form-group">
                    <label>Image URL</label>
                    <input class="form-input" formControlName="imageUrl" />
                  </div>
                </div>
                <div class="form-group">
                  <label>Description</label>
                  <input class="form-input" formControlName="description" />
                </div>
                <div class="form-group">
                  <label>Type</label>
                  <app-form-select
                    formControlName="itemType"
                    placeholder="Item type"
                    [options]="menuItemTypeSelectOptions"
                  />
                </div>
                <div class="form-actions">
                  <button type="submit" class="btn btn-primary" [disabled]="menuForm.invalid">
                    {{ editingMenuItemId() ? 'Update' : 'Add' }}
                  </button>
                  <button type="button" class="btn btn-secondary" (click)="showMenuForm.set(false); editingMenuItemId.set(null)">Cancel</button>
                </div>
              </form>
            </div>
          } @else {
            <button class="btn btn-primary mb-2" (click)="showMenuForm.set(true)">+ Add Item</button>
          }
          }

            @if (shop()!.currentMenu!.items.length === 0) {
              <div class="empty-state"><p>No menu items.</p></div>
            } @else {
            <div class="view-mobile-only list-card-grid mb-3">
              @for (item of shop()!.currentMenu!.items; track item.id) {
                <article class="list-card">
                  <div class="list-card__primary">
                    <span class="list-card__title">{{ item.name }}</span>
                    <span class="list-card__subtitle">{{ item.price }} {{ item.priceCurrency }}</span>
                  </div>
                  <div class="list-card__meta list-card__meta--clamp">
                    {{ formatMenuItemType(item.itemType) }} · {{ item.description }}
                  </div>
                  @if (canManageShop()) {
                    <div class="list-card__actions">
                      <button class="btn btn-sm btn-secondary" (click)="onEditMenuItem(item)">Edit</button>
                      <button class="btn btn-sm btn-danger" (click)="onDeleteMenuItem(item)">Delete</button>
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
                      <th>Name</th><th>Type</th><th>Description</th><th>Price</th>
                      @if (canManageShop()) { <th>Actions</th> }
                    </tr>
                  </thead>
                  <tbody>
                    @for (item of shop()!.currentMenu!.items; track item.id) {
                      <tr>
                        <td>{{ item.name }}</td>
                        <td>{{ formatMenuItemType(item.itemType) }}</td>
                        <td>{{ item.description }}</td>
                        <td>{{ item.price }} {{ item.priceCurrency }}</td>
                        @if (canManageShop()) {
                          <td class="data-table__actions">
                            <div style="display:flex;gap:0.5rem">
                              <button class="btn btn-sm btn-secondary" (click)="onEditMenuItem(item)">Edit</button>
                              <button class="btn btn-sm btn-danger" (click)="onDeleteMenuItem(item)">Delete</button>
                            </div>
                          </td>
                        }
                      </tr>
                    }
                  </tbody>
                </table>
              </div>
            </div>
            }
          }

          @if (!isCustomer() && shop()!.menuHistory.length > 0) {
            <h3 class="mt-4 mb-2">Menu history</h3>
            @for (historical of shop()!.menuHistory; track historical.id) {
              <details class="form-card mb-2">
                <summary style="cursor:pointer;font-weight:600">
                  {{ historical.label || 'Menu' }}
                  @if (historical.createdAt) {
                    <span class="text-muted"> — {{ formatMenuDate(historical.createdAt) }}</span>
                  }
                </summary>
                @if (historical.items.length === 0) {
                  <p class="text-muted mt-2">No items.</p>
                } @else {
                  <div class="view-mobile-only list-card-grid mt-2">
                    @for (item of historical.items; track item.id) {
                      <article class="list-card">
                        <div class="list-card__primary">
                          <span class="list-card__title">{{ item.name }}</span>
                          <span class="list-card__subtitle">{{ item.price }} {{ item.priceCurrency }}</span>
                        </div>
                        <div class="list-card__meta list-card__meta--clamp">
                          {{ formatMenuItemType(item.itemType) }} · {{ item.description }}
                        </div>
                      </article>
                    }
                  </div>
                  <div class="view-desktop-only">
                    <div class="table-container mt-2">
                      <table class="data-table">
                        <thead>
                          <tr><th>Name</th><th>Type</th><th>Description</th><th>Price</th></tr>
                        </thead>
                        <tbody>
                          @for (item of historical.items; track item.id) {
                            <tr>
                              <td>{{ item.name }}</td>
                              <td>{{ formatMenuItemType(item.itemType) }}</td>
                              <td>{{ item.description }}</td>
                              <td>{{ item.price }} {{ item.priceCurrency }}</td>
                            </tr>
                          }
                        </tbody>
                      </table>
                    </div>
                  </div>
                }
              </details>
            }
          }
        }

        <!-- TABLES TAB -->
        @if (activeTab() === 'tables') {
          @if (canManageShop()) {
          @if (showTableForm()) {
            <div class="form-card mb-3">
              <form [formGroup]="tableForm" (ngSubmit)="onTableSubmit()">
                <div class="form-row">
                  <div class="form-group">
                    <label>Table Number</label>
                    <input class="form-input" type="number" formControlName="number" />
                  </div>
                  <div class="form-group">
                    <label>Capacity</label>
                    <input class="form-input" type="number" formControlName="capacity" />
                  </div>
                </div>
                <div class="form-actions">
                  <button type="submit" class="btn btn-primary" [disabled]="tableForm.invalid">
                    {{ editingTableId() ? 'Update' : 'Add' }}
                  </button>
                  <button type="button" class="btn btn-secondary" (click)="showTableForm.set(false); editingTableId.set(null)">Cancel</button>
                </div>
              </form>
            </div>
          } @else {
            <button class="btn btn-primary mb-2" (click)="openAddTableForm()">+ Add Table</button>
          }
          }

          @if (shop()!.tables.length === 0) {
            <div class="empty-state"><p>No tables.</p></div>
          } @else {
            <div class="view-mobile-only list-card-grid mb-3">
              @for (t of shop()!.tables; track t.id) {
                <article class="list-card">
                  <div class="list-card__primary">
                    <span class="list-card__title">Table {{ t.number }}</span>
                    <span class="list-card__subtitle">Capacity {{ t.capacity }}</span>
                  </div>
                  @if (canManageShop()) {
                    <div class="list-card__actions">
                      <button class="btn btn-sm btn-secondary" (click)="onEditTable(t)">Edit</button>
                      <button class="btn btn-sm btn-danger" (click)="onDeleteTable(t)">Delete</button>
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
                      <th>#</th><th>Capacity</th>
                      @if (canManageShop()) { <th>Actions</th> }
                    </tr>
                  </thead>
                  <tbody>
                    @for (t of shop()!.tables; track t.id) {
                      <tr>
                        <td>{{ t.number }}</td>
                        <td>{{ t.capacity }}</td>
                        @if (canManageShop()) {
                          <td class="data-table__actions">
                            <div style="display:flex;gap:0.5rem">
                              <button class="btn btn-sm btn-secondary" (click)="onEditTable(t)">Edit</button>
                              <button class="btn btn-sm btn-danger" (click)="onDeleteTable(t)">Delete</button>
                            </div>
                          </td>
                        }
                      </tr>
                    }
                  </tbody>
                </table>
              </div>
            </div>
          }
        }

        <!-- RESERVATIONS TAB -->
        @if (activeTab() === 'reservations') {
          <select
            class="tab-select view-mobile-only mb-3"
            aria-label="Reservation status"
            [value]="reservationSubTab()"
            (change)="onReservationSubTabSelect($event)"
          >
            <option value="pending">Pending ({{ pendingRequests().length }})</option>
            <option value="approved">Approved ({{ reservations().length }})</option>
            <option value="denied">Denied ({{ deniedRequests().length }})</option>
          </select>
          <div class="tabs tabs--sub view-desktop-only">
            <button
              class="tab"
              [class.active]="reservationSubTab() === 'pending'"
              (click)="reservationSubTab.set('pending')">
              Pending ({{ pendingRequests().length }})
            </button>
            <button
              class="tab"
              [class.active]="reservationSubTab() === 'approved'"
              (click)="reservationSubTab.set('approved')">
              Approved ({{ reservations().length }})
            </button>
            <button
              class="tab"
              [class.active]="reservationSubTab() === 'denied'"
              (click)="reservationSubTab.set('denied')">
              Denied ({{ deniedRequests().length }})
            </button>
          </div>

          @if (reservationSubTab() === 'pending') {
            @if (pendingRequests().length === 0) {
              <div class="empty-state"><p>No pending reservation requests.</p></div>
            } @else if (canManageShop()) {
              <div class="view-mobile-only list-card-grid mb-3">
                @for (req of pendingRequests(); track req.id) {
                  <article class="list-card">
                    <div class="list-card__primary">
                      <span class="list-card__title">{{ req.user?.name ?? '—' }}</span>
                      <span class="list-card__subtitle">{{ eventLabel(req) }}</span>
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
                        <p class="text-muted" role="status">No table large enough for party of {{ req.partySize }}.</p>
                      }
                      <div class="reservation-actions__buttons">
                        <button class="btn btn-sm btn-primary" (click)="onAcceptRequest(req)">Accept</button>
                        <button class="btn btn-sm btn-danger" (click)="onDenyRequest(req)">Deny</button>
                      </div>
                    </div>
                  </article>
                }
              </div>
              <div class="view-desktop-only">
                <div class="table-container table-container--dropdown-safe">
                  <table class="data-table">
                    <thead>
                      <tr><th>Guest</th><th>Event</th><th>Party Size</th><th>Status</th><th>Actions</th></tr>
                    </thead>
                    <tbody>
                      @for (req of pendingRequests(); track req.id) {
                        <tr>
                          <td>{{ req.user?.name ?? '—' }}</td>
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
                                <button class="btn btn-sm btn-primary" (click)="onAcceptRequest(req)">Accept</button>
                                <button class="btn btn-sm btn-danger" (click)="onDenyRequest(req)">Deny</button>
                              </div>
                            </div>
                          </td>
                        </tr>
                      }
                    </tbody>
                  </table>
                </div>
              </div>
            } @else if (canSelfReserveAtShop()) {
              <div class="view-mobile-only list-card-grid mb-3">
                @for (req of pendingRequests(); track req.id) {
                  <article class="list-card">
                    <div class="list-card__primary">
                      <span class="list-card__title">{{ eventLabel(req) }}</span>
                      <span class="list-card__subtitle">Party {{ req.partySize }}</span>
                    </div>
                    <div class="list-card__meta"><span class="badge badge-pending">{{ req.status }}</span></div>
                  </article>
                }
              </div>
              <div class="view-desktop-only">
                <div class="table-container">
                  <table class="data-table">
                    <thead><tr><th>Event</th><th>Party Size</th><th>Status</th></tr></thead>
                    <tbody>
                      @for (req of pendingRequests(); track req.id) {
                        <tr>
                          <td>{{ eventLabel(req) }}</td>
                          <td>{{ req.partySize }}</td>
                          <td><span class="badge badge-pending">{{ req.status }}</span></td>
                        </tr>
                      }
                    </tbody>
                  </table>
                </div>
              </div>
            }
          }

          @if (reservationSubTab() === 'approved') {
            @if (reservations().length === 0) {
              <div class="empty-state"><p>{{ canSelfReserveAtShop() ? 'No confirmed reservations for this shop.' : 'No approved reservations for this shop.' }}</p></div>
            } @else {
              <div class="view-mobile-only list-card-grid mb-3">
                @for (r of reservations(); track r.id) {
                  <article class="list-card">
                    <div class="list-card__primary">
                      @if (canManageShop()) {
                        <span class="list-card__title">{{ r.user.name }}</span>
                      }
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
                        @if (canManageShop()) { <th>Guest</th> }
                        <th>Event</th><th>Table</th><th>Party Size</th>
                      </tr>
                    </thead>
                    <tbody>
                      @for (r of reservations(); track r.id) {
                        <tr>
                          @if (canManageShop()) { <td>{{ r.user.name }}</td> }
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

          @if (reservationSubTab() === 'denied') {
            @if (deniedRequests().length === 0) {
              <div class="empty-state"><p>No denied reservation requests.</p></div>
            } @else {
              <div class="view-mobile-only list-card-grid mb-3">
                @for (req of deniedRequests(); track req.id) {
                  <article class="list-card">
                    <div class="list-card__primary">
                      @if (canManageShop()) {
                        <span class="list-card__title">{{ req.user?.name ?? '—' }}</span>
                      }
                      <span class="list-card__subtitle">{{ eventLabel(req) }}</span>
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
                        @if (canManageShop()) { <th>Guest</th> }
                        <th>Event</th><th>Party Size</th><th>Status</th>
                      </tr>
                    </thead>
                    <tbody>
                      @for (req of deniedRequests(); track req.id) {
                        <tr>
                          @if (canManageShop()) { <td>{{ req.user?.name ?? '—' }}</td> }
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
        }

        <!-- EVENTS TAB -->
        @if (activeTab() === 'events') {
          @if (canManageShop()) {
            @if (showEventForm()) {
              <div class="form-card mb-3">
                <form [formGroup]="eventForm" (ngSubmit)="onEventSubmit()">
                  <div class="form-row">
                    <div class="form-group">
                      <label>Event Name</label>
                      <input class="form-input" formControlName="eventName" placeholder="Event name" />
                    </div>
                    <div class="form-group">
                      <label>Event Date</label>
                      <app-date-time-picker
                        formControlName="eventDate"
                        [minDate]="editingEventId() ? null : todayIsoValue()"
                      />
                      @if (eventForm.controls.eventDate.touched && eventForm.controls.eventDate.hasError('pastDate')) {
                        <span class="form-error">Event date must be in the future.</span>
                      }
                    </div>
                  </div>
                  <div class="form-group">
                    <label>Description</label>
                    <input class="form-input" formControlName="description" placeholder="Event description" />
                  </div>
                  <div class="form-actions">
                    <button type="submit" class="btn btn-primary" [disabled]="eventForm.invalid">
                      {{ editingEventId() ? 'Update' : 'Create' }}
                    </button>
                    <button type="button" class="btn btn-secondary" (click)="cancelEventForm()">Cancel</button>
                  </div>
                </form>
              </div>
            } @else {
              <button class="btn btn-primary mb-2" (click)="openAddEventForm()">+ Add Event</button>
            }
          }

          @if (shop()!.events.length === 0) {
            <div class="empty-state">
              <p>No events.</p>
              @if (canManageShop()) {
                <p class="text-muted">Add an event for customers to reserve.</p>
              }
            </div>
          } @else {
            <div class="view-mobile-only list-card-grid mb-3">
              @for (e of shop()!.events; track e.eventId) {
                <article class="list-card">
                  <div class="list-card__primary">
                    <span class="list-card__title">{{ e.eventName }}</span>
                    <span class="list-card__subtitle">{{ e.eventDate }}</span>
                  </div>
                  <div class="list-card__meta list-card__meta--clamp">
                    {{ e.description }} · {{ eventAvailabilityLabel(e) }}
                  </div>
                  @if (canSelfReserveAtShop() || canManageShop()) {
                    <div class="list-card__actions">
                      @if (canSelfReserveAtShop()) {
                        <button
                          type="button"
                          class="btn btn-sm btn-primary"
                          [disabled]="!canShowReserveButton(e)"
                          [title]="reserveTooltip(e)"
                          (click)="onReserveEventClick(e)"
                        >
                          Reserve
                        </button>
                      }
                      @if (canManageShop()) {
                        <button class="btn btn-sm btn-secondary" (click)="onEditEvent(e)">Edit</button>
                        <button class="btn btn-sm btn-danger" (click)="onDeleteEvent(e)">Delete</button>
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
                      <th>Name</th><th>Date</th><th>Description</th><th>Availability</th>
                      @if (canSelfReserveAtShop() || canManageShop()) { <th>Actions</th> }
                    </tr>
                  </thead>
                  <tbody>
                    @for (e of shop()!.events; track e.eventId) {
                      <tr>
                        <td>{{ e.eventName }}</td>
                        <td>{{ e.eventDate }}</td>
                        <td>{{ e.description }}</td>
                        <td>{{ eventAvailabilityLabel(e) }}</td>
                        @if (canSelfReserveAtShop() || canManageShop()) {
                          <td class="data-table__actions">
                            @if (canSelfReserveAtShop()) {
                              <button
                                type="button"
                                class="btn btn-sm btn-primary"
                                [disabled]="!canShowReserveButton(e)"
                                [title]="reserveTooltip(e)"
                                (click)="onReserveEventClick(e)"
                              >
                                Reserve
                              </button>
                            }
                            @if (canManageShop()) {
                              <div style="display:flex;gap:0.5rem">
                                <button class="btn btn-sm btn-secondary" (click)="onEditEvent(e)">Edit</button>
                                <button class="btn btn-sm btn-danger" (click)="onDeleteEvent(e)">Delete</button>
                              </div>
                            }
                          </td>
                        }
                      </tr>
                    }
                  </tbody>
                </table>
              </div>
            </div>
          }

          @if (canSelfReserveAtShop() && selectedEventForRequest(); as event) {
            <div class="form-card mt-3">
              <h3 class="mb-2">Request reservation</h3>
              <p class="text-muted mb-2">{{ event.eventName }} &middot; {{ event.eventDate }}</p>
              <form [formGroup]="eventRequestForm" (ngSubmit)="onSubmitEventRequest()">
                <div class="form-group">
                  <label>Party size</label>
                  <input class="form-input" type="number" formControlName="partySize" min="1" />
                </div>
                <div class="form-actions">
                  <button type="submit" class="btn btn-primary" [disabled]="eventRequestForm.invalid || !canSubmitEventRequest()">
                    Submit request
                  </button>
                  <button type="button" class="btn btn-secondary" (click)="cancelEventRequest()">Cancel</button>
                </div>
              </form>
            </div>
          }
        }

        <!-- REVIEWS TAB -->
        @if (activeTab() === 'reviews') {
          @if (shop()!.reviewCount > 0) {
            <div class="card-grid mb-3">
              <div class="stat-card">
                <div class="stat-value">{{ formatAverageRating(shop()!) }}</div>
                <div class="stat-label">Average rating</div>
                <app-star-rating
                  style="margin-top:0.5rem"
                  [rating]="roundedAverageRating(shop()!)"
                  [readonly]="true" />
              </div>
              <div class="stat-card">
                <div class="stat-value">{{ shop()!.reviewCount }}</div>
                <div class="stat-label">{{ shop()!.reviewCount === 1 ? 'Review' : 'Reviews' }}</div>
              </div>
            </div>
          }

          @if (canLeaveReview() && !showReviewForm()) {
            <button type="button" class="btn btn-primary mb-2" (click)="showReviewForm.set(true)">
              Leave review
            </button>
          }

          @if (showReviewForm()) {
            <form class="form-card mb-3" [formGroup]="reviewForm" (ngSubmit)="onReviewSubmit()">
              <h3 class="mb-2">Leave a review</h3>
              <div class="form-group">
                <label>Rating</label>
                <app-star-rating formControlName="rating" />
                @if (reviewForm.controls.rating.touched && reviewForm.controls.rating.invalid) {
                  <p class="text-muted" style="font-size:0.75rem;margin-top:0.25rem">Rating must be between 1 and 5.</p>
                }
              </div>
              <div class="form-group">
                <label for="review-description">Description</label>
                <textarea
                  id="review-description"
                  class="form-input"
                  rows="4"
                  formControlName="description"
                  placeholder="Share your experience"></textarea>
              </div>
              <div class="form-group form-group--toggle">
                <span class="form-label" id="review-comments-enabled-label">Allow comments on this review</span>
                <label class="toggle-switch" aria-labelledby="review-comments-enabled-label">
                  <input type="checkbox" formControlName="commentsEnabled" />
                  <span class="toggle-slider" aria-hidden="true"></span>
                  <span class="sr-only">Allow comments on this review</span>
                </label>
              </div>
              <div class="form-actions">
                <button type="submit" class="btn btn-primary" [disabled]="reviewForm.invalid">Submit review</button>
                <button type="button" class="btn btn-secondary" (click)="toggleReviewForm()">Cancel</button>
              </div>
            </form>
          }

          @if (shop()!.reviews.length === 0) {
            <div class="empty-state"><p>No reviews yet.</p></div>
          } @else {
            <div class="card-grid">
              @for (r of shop()!.reviews; track r.id) {
                <div class="card">
                  <div style="margin-bottom:0.5rem">
                    <app-star-rating [rating]="r.rating" [readonly]="true" />
                  </div>
                  <p class="text-muted" style="font-size:0.875rem">{{ r.description }}</p>
                  <p class="text-muted" style="font-size:0.75rem;margin-top:0.5rem">By {{ r.user.name }}</p>

                  @if (isReviewAuthor(r)) {
                    <label class="toggle-switch" style="margin-top:0.75rem;font-size:0.875rem">
                      <input
                        type="checkbox"
                        [checked]="r.commentsEnabled"
                        (change)="onCommentsEnabledChange(r, $any($event.target).checked)" />
                      <span class="toggle-slider" aria-hidden="true"></span>
                      <span>Allow comments</span>
                    </label>
                  }

                  <div style="margin-top:1rem;padding-top:0.75rem;border-top:1px solid #374151">
                    <p style="font-size:0.875rem;color:#fff;margin-bottom:0.5rem">Comments</p>
                    @if (!r.commentsEnabled) {
                      <p class="text-muted" style="font-size:0.75rem">Comments are turned off.</p>
                    } @else {
                      @if ((r.comments ?? []).length === 0) {
                        <p class="text-muted" style="font-size:0.75rem;margin-bottom:0.5rem">No comments yet.</p>
                      } @else {
                        <div style="display:flex;flex-direction:column;gap:0.5rem;margin-bottom:0.75rem">
                          @for (c of r.comments; track c.id) {
                            <div style="background:#1f2937;border-radius:0.375rem;padding:0.5rem 0.75rem">
                              <p style="font-size:0.75rem;color:#9ca3af;margin-bottom:0.25rem">
                                {{ c.user.name }} · {{ formatCommentDate(c.createdAt) }}
                              </p>
                              <p style="font-size:0.875rem;color:#e5e7eb">{{ c.body }}</p>
                            </div>
                          }
                        </div>
                      }
                      <textarea
                        class="form-input"
                        rows="2"
                        placeholder="Write a comment..."
                        [value]="commentDraft(r.id)"
                        (input)="updateCommentDraft(r.id, $any($event.target).value)"></textarea>
                      <button
                        type="button"
                        class="btn btn-secondary"
                        style="margin-top:0.5rem"
                        [disabled]="!commentDraft(r.id).trim()"
                        (click)="onCommentSubmit(r.id)">
                        Post comment
                      </button>
                    }
                  </div>
                </div>
              }
            </div>
          }
        }
      }

    </div>
  `,
})
export class ShopDetailsComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly injector = inject(Injector);
  private readonly fb = inject(FormBuilder);
  private readonly shopService = inject(ShopService);
  private readonly menuItemService = inject(MenuItemService);
  private readonly menuService = inject(MenuService);
  private readonly tableService = inject(TableService);
  private readonly reservationService = inject(ReservationService);
  private readonly requestService = inject(ReservationRequestService);
  private readonly profileService = inject(ProfileService);
  private readonly authService = inject(AuthService);
  private readonly reviewService = inject(ReviewService);
  private readonly reviewCommentService = inject(ReviewCommentService);
  private readonly communityService = inject(CommunityService);
  private readonly eventService = inject(EventService);
  private readonly dialog = inject(DialogService);

  readonly shop = signal<ShopResponseDto | null>(null);
  readonly loading = signal(true);
  readonly activeTab = signal<Tab>('users');
  readonly reservationSubTab = signal<ReservationSubTab>('pending');
  readonly reservations = signal<ReservationResponseDto[]>([]);
  readonly allShopRequests = signal<ReservationRequestResponseDto[]>([]);
  readonly allUserRequests = signal<ReservationRequestResponseDto[]>([]);
  readonly allUserReservations = signal<ReservationResponseDto[]>([]);
  readonly selectedTableForRequest = signal<{ reqId: string; tableId: string } | null>(null);
  readonly selectedEventForRequest = signal<EventResponseDto | null>(null);
  readonly submittingEventRequest = signal(false);

  readonly pendingRequests = computed(() =>
    this.allShopRequests().filter(req => req.status === 'PENDING'),
  );

  readonly deniedRequests = computed(() =>
    this.allShopRequests().filter(req => req.status === 'DENIED'),
  );

  readonly canManageShop = computed(() => {
    const shop = this.shop();
    const profile = this.profileService.currentUser();
    if (!shop || !profile) return false;
    if (this.authService.isAdmin()) return true;
    return shop.createdBy?.id === profile.id;
  });

  readonly isCustomer = computed(() => {
    const profile = this.profileService.currentUser();
    return !!profile && profile.userType === 'CUSTOMER' && !this.canManageShop();
  });

  readonly canSelfReserveAtShop = computed(() => !this.canManageShop());

  readonly visibleTabs = computed(() =>
    this.isCustomer() ? this.tabs.filter(t => t.key !== 'tables') : this.tabs,
  );

  readonly blockedEventIdsForCurrentUser = computed(() => {
    const profile = this.profileService.currentUser();
    if (!profile) return new Set<string>();
    return eventIdsBlockedForUser(
      this.allUserRequests(),
      this.allUserReservations(),
      profile.id,
    );
  });

  readonly isShopOwner = computed(() => {
    const shop = this.shop();
    const profile = this.profileService.currentUser();
    return !!shop && !!profile && shop.createdBy?.id === profile.id;
  });

  readonly canLeaveReview = computed(() => {
    const profile = this.profileService.currentUser();
    const shop = this.shop();
    if (!profile || !shop) return false;
    if (profile.userType !== 'CUSTOMER') return false;
    if (this.canManageShop()) return false;
    const alreadyReviewed = shop.reviews.some(r => r.user.id === profile.id);
    return !alreadyReviewed;
  });

  readonly showMenuForm = signal(false);
  readonly editingMenuItemId = signal<string | null>(null);
  readonly showTableForm = signal(false);
  readonly editingTableId = signal<string | null>(null);
  readonly showEventForm = signal(false);
  readonly editingEventId = signal<string | null>(null);
  readonly todayIsoValue = todayIso;
  readonly showReviewForm = signal(false);
  readonly togglingFavourite = signal(false);
  readonly communityPosts = signal<CommunityPostResponseDto[]>([]);
  readonly communityLoading = signal(false);
  readonly communityPage = signal(0);
  readonly communityTotalPages = signal(0);
  readonly announcementDraft = signal('');
  readonly postingAnnouncement = signal(false);

  readonly communityHasMore = computed(
    () => this.communityPage() + 1 < this.communityTotalPages(),
  );

  readonly members = signal<UserSummaryDto[]>([]);
  readonly membersSearchInput = signal('');
  readonly membersPage = signal(0);
  readonly membersPageSize = 10;
  readonly membersTotalElements = signal(0);
  readonly membersTotalPages = signal(1);
  readonly membersLoading = signal(false);

  readonly isFavourite = computed(() => {
    const shop = this.shop();
    const profile = this.profileService.currentUser();
    if (!shop || !profile) return false;
    return profile.favouriteShops?.some(s => s.id === shop.id) ?? false;
  });

  readonly tabs: { key: Tab; label: string }[] = [
    { key: 'users', label: 'Community' },
    { key: 'menu', label: 'Menu' },
    { key: 'tables', label: 'Tables' },
    { key: 'reservations', label: 'Reservations' },
    { key: 'events', label: 'Events' },
    { key: 'reviews', label: 'Reviews' },
  ];

  readonly menuItemTypes = MENU_ITEM_TYPES;
  readonly menuItemTypeSelectOptions: FormSelectOption[] = MENU_ITEM_TYPES.map(t => ({
    value: t.value,
    label: t.label,
  }));
  readonly menuCurrencySelectOptions: FormSelectOption[] = MENU_CURRENCIES.map(c => ({
    value: c.value,
    label: c.label,
  }));

  readonly menuForm = this.fb.nonNullable.group({
    name: ['', Validators.required],
    description: [''],
    price: [0, [Validators.required, Validators.min(0)]],
    priceCurrency: ['RSD' as MenuCurrency, Validators.required],
    imageUrl: [''],
    itemType: ['FOOD' as MenuItemType, Validators.required],
  });

  readonly tableForm = this.fb.nonNullable.group({
    number: [1, [Validators.required, Validators.min(1)]],
    capacity: [2, [Validators.required, Validators.min(1)]],
  });

  readonly reviewForm = this.fb.nonNullable.group({
    rating: [0, [Validators.required, Validators.min(1), Validators.max(5)]],
    description: ['', Validators.required],
    commentsEnabled: [true],
  });

  readonly eventRequestForm = this.fb.nonNullable.group({
    partySize: [1, [Validators.required, Validators.min(1)]],
  });

  readonly eventForm = this.fb.nonNullable.group({
    eventName: ['', Validators.required],
    eventDate: ['', Validators.required],
    description: [''],
  });

  readonly commentDrafts = signal<Record<string, string>>({});

  private shopId = '';

  constructor() {
    toObservable(this.membersSearchInput, { injector: this.injector })
      .pipe(skip(1), debounceTime(300), distinctUntilChanged(), takeUntilDestroyed())
      .subscribe(() => {
        if (this.activeTab() === 'users') {
          this.loadMembers(true);
        }
      });
  }

  ngOnInit(): void {
    this.shopId = this.route.snapshot.paramMap.get('id') ?? '';
    this.loadShop();
  }

  private loadShop(): void {
    this.shopService.getById(this.shopId).subscribe({
      next: (shop) => {
        this.shop.set(shop);
        this.loading.set(false);
        if (this.isCustomer() && this.activeTab() === 'tables') {
          this.activeTab.set('menu');
        }
        this.loadReservations();
        if (this.activeTab() === 'users') {
          this.loadMembers(true);
          this.loadCommunityPosts(true);
        }
      },
      error: () => this.loading.set(false),
    });
  }

  toggleFavourite(): void {
    const shop = this.shop();
    if (!shop || this.canManageShop() || this.togglingFavourite()) return;

    this.togglingFavourite.set(true);
    const op = this.isFavourite()
      ? this.shopService.removeFavourite(shop.id)
      : this.shopService.addFavourite(shop.id);

    op.subscribe({
      next: updated => {
        this.shop.set(updated);
        this.togglingFavourite.set(false);
        if (this.activeTab() === 'users') {
          this.loadMembers(true);
          this.loadCommunityPosts(true);
        }
      },
      error: () => this.togglingFavourite.set(false),
    });
  }

  onTabChange(tab: Tab): void {
    if (this.isCustomer() && tab === 'tables') {
      this.activeTab.set('menu');
      return;
    }
    this.activeTab.set(tab);
    if (tab === 'users') {
      this.loadMembers(true);
      this.loadCommunityPosts(true);
    }
    if (tab !== 'events') {
      this.selectedEventForRequest.set(null);
      this.cancelEventForm();
    }
  }

  onPrimaryTabSelect(event: Event): void {
    const value = (event.target as HTMLSelectElement).value as Tab;
    this.onTabChange(value);
  }

  onReservationSubTabSelect(event: Event): void {
    const value = (event.target as HTMLSelectElement).value as 'pending' | 'approved' | 'denied';
    this.reservationSubTab.set(value);
  }

  membersEmptyStateMessage(): string {
    if (this.membersSearchInput().trim()) return 'No members match your search.';
    return 'No community members yet. Be the first to join!';
  }

  onMembersSearchInput(inputEvent: Event): void {
    const value = (inputEvent.target as HTMLInputElement).value;
    this.membersSearchInput.set(value);
  }

  loadMembers(resetPage = false): void {
    if (!this.shopId) return;
    if (resetPage) {
      this.membersPage.set(0);
    }
    this.membersLoading.set(true);
    const q = this.membersSearchInput().trim();
    this.communityService
      .getMembers(this.shopId, this.membersPage(), this.membersPageSize, q || undefined)
      .subscribe({
        next: page => {
          this.members.set(page.content);
          this.membersTotalElements.set(page.totalElements);
          this.membersTotalPages.set(Math.max(1, page.totalPages));
          this.membersLoading.set(false);
        },
        error: () => this.membersLoading.set(false),
      });
  }

  goToMembersPage(page: number): void {
    if (page < 0 || page >= this.membersTotalPages()) return;
    this.membersPage.set(page);
    this.loadMembers();
  }

  membersRangeLabel(): string {
    const total = this.membersTotalElements();
    if (total === 0) return '';
    const start = this.membersPage() * this.membersPageSize + 1;
    const end = Math.min((this.membersPage() + 1) * this.membersPageSize, total);
    return `Showing ${start}–${end} of ${total}`;
  }

  loadCommunityPosts(reset = false): void {
    if (!this.shopId) return;
    const page = reset ? 0 : this.communityPage() + 1;
    if (reset) {
      this.communityPosts.set([]);
      this.communityPage.set(0);
      this.communityTotalPages.set(0);
    }
    this.communityLoading.set(true);
    this.communityService.getPosts(this.shopId, page, 20).subscribe({
      next: result => {
        this.communityPosts.update(existing =>
          reset ? result.content : [...existing, ...result.content],
        );
        this.communityPage.set(result.page);
        this.communityTotalPages.set(result.totalPages);
        this.communityLoading.set(false);
      },
      error: () => this.communityLoading.set(false),
    });
  }

  loadMoreCommunityPosts(): void {
    this.loadCommunityPosts(false);
  }

  onAnnouncementSubmit(): void {
    const body = this.announcementDraft().trim();
    if (!body || this.postingAnnouncement()) return;
    this.postingAnnouncement.set(true);
    this.communityService.createAnnouncement(this.shopId, { body }).subscribe({
      next: () => {
        this.announcementDraft.set('');
        this.postingAnnouncement.set(false);
        this.loadCommunityPosts(true);
      },
      error: () => this.postingAnnouncement.set(false),
    });
  }

  onDeletePost(post: CommunityPostResponseDto): void {
    void this.dialog
      .confirm('Delete this post?', { confirmLabel: 'Delete', confirmVariant: 'danger' })
      .then(ok => {
        if (!ok) return;
        this.communityService.deletePost(this.shopId, post.id).subscribe({
          next: () => this.loadCommunityPosts(true),
        });
      });
  }

  canDeletePost(post: CommunityPostResponseDto): boolean {
    const profile = this.profileService.currentUser();
    if (!profile) return false;
    if (this.isShopOwner()) return true;
    return post.author.id === profile.id;
  }

  formatPostDate(iso: string): string {
    return new Date(iso).toLocaleString(undefined, {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  }

  private loadReservations(): void {
    const profile = this.profileService.currentUser();
    if (!this.canManageShop() && profile) {
      this.reservationService.getAll().subscribe(all => {
        this.allUserReservations.set(all.filter(r => r.user?.id === profile.id));
        this.reservations.set(
          all.filter(r => r.shop?.id === this.shopId && r.user?.id === profile.id),
        );
      });
      this.requestService.getAll().subscribe(all => {
        this.allUserRequests.set(all);
        this.allShopRequests.set(
          all.filter(r => r.shop?.id === this.shopId && r.user?.id === profile.id),
        );
      });
      return;
    }

    this.reservationService.getAll().subscribe(all => {
      this.reservations.set(all.filter(r => r.shop?.id === this.shopId));
    });
    this.requestService.getAll(this.shopId).subscribe(requests => {
      this.allShopRequests.set(requests);
    });
  }

  onAcceptRequest(req: ReservationRequestResponseDto): void {
    const sel = this.selectedTableForRequest();
    if (!sel || sel.reqId !== req.id || !sel.tableId) {
      void this.dialog.alert('Please select a table first.');
      return;
    }
    const table = (this.shop()?.tables ?? []).find(t => t.id === sel.tableId);
    this.requestService.accept(req.id, { tableId: sel.tableId }).subscribe({
      next: () => this.loadReservations(),
      error: err =>
        void this.dialog.alert(
          getAcceptReservationErrorMessage(err, {
            partySize: req.partySize,
            tableCapacity: table?.capacity,
          }),
        ),
    });
  }

  onDenyRequest(req: ReservationRequestResponseDto): void {
    void this.dialog
      .confirm('Deny this reservation request?', {
        confirmLabel: 'Deny',
        confirmVariant: 'danger',
      })
      .then(ok => {
        if (!ok) return;
        this.requestService.deny(req.id).subscribe(() => this.loadReservations());
      });
  }

  tablesForRequest(req: ReservationRequestResponseDto): TableResponseDto[] {
    return (this.shop()?.tables ?? []).filter(t => t.capacity >= req.partySize);
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

  eventLabel(item: { eventName?: string; eventId?: string }): string {
    if (item.eventName) {
      return item.eventName;
    }
    return item.eventId ?? '—';
  }

  eventAvailabilityLabel(event: EventResponseDto): string {
    return formatEventAvailability(event);
  }

  isEventBlockedForCurrentUser(eventId: string): boolean {
    return this.blockedEventIdsForCurrentUser().has(eventId);
  }

  canShowReserveButton(event: EventResponseDto): boolean {
    return canReserveForEvent(event) && !this.isEventBlockedForCurrentUser(event.eventId);
  }

  reserveTooltip(event: EventResponseDto): string {
    if (isEventFull(event)) return 'No tables left for this event';
    if (this.isEventBlockedForCurrentUser(event.eventId)) {
      return 'You already have a reservation request or reservation for this event';
    }
    return canReserveForEvent(event)
      ? `Reserve for ${event.eventName}`
      : 'This event has already passed';
  }

  onReserveEventClick(event: EventResponseDto): void {
    if (!this.canShowReserveButton(event)) return;
    this.selectedEventForRequest.set(event);
    this.eventRequestForm.reset({ partySize: 1 });
  }

  cancelEventRequest(): void {
    this.selectedEventForRequest.set(null);
    this.eventRequestForm.reset({ partySize: 1 });
  }

  canSubmitEventRequest(): boolean {
    const event = this.selectedEventForRequest();
    if (!event) return false;
    return this.canShowReserveButton(event);
  }

  onSubmitEventRequest(): void {
    if (this.eventRequestForm.invalid || !this.canSubmitEventRequest() || this.submittingEventRequest()) {
      return;
    }
    const profile = this.profileService.currentUser();
    const event = this.selectedEventForRequest();
    if (!profile || !event) return;

    this.submittingEventRequest.set(true);
    const partySize = this.eventRequestForm.controls.partySize.value;
    this.requestService
      .create({
        userId: profile.id,
        shopId: this.shopId,
        eventId: event.eventId,
        partySize,
      })
      .subscribe({
        next: () => {
          this.submittingEventRequest.set(false);
          this.cancelEventRequest();
          this.loadReservations();
          this.reservationSubTab.set('pending');
          void this.dialog.alert('Reservation request submitted.');
        },
        error: err => {
          this.submittingEventRequest.set(false);
          if (err instanceof HttpErrorResponse && err.status === 409) {
            void this.dialog.alert(
              'You already have a reservation for this event or there are no tables left.',
            );
          }
        },
      });
  }

  onCreateMenu(): void {
    if (!this.shop()?.currentMenu) {
      this.executeCreateMenu();
      return;
    }
    void this.dialog
      .confirm('Create a new menu? The current menu will become read-only history.', {
        confirmLabel: 'Yes',
        cancelLabel: 'No',
      })
      .then(ok => {
        if (ok) this.executeCreateMenu();
      });
  }

  private executeCreateMenu(): void {
    this.menuService.createForShop(this.shopId).subscribe({
      next: () => this.loadShop(),
      error: () =>
        void this.dialog.alert('Could not create menu. Only the shop owner can create menus.'),
    });
  }

  formatMenuDate(iso: string): string {
    return new Date(iso).toLocaleDateString(undefined, {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
    });
  }

  formatMenuItemType(type: MenuItemType | undefined): string {
    if (!type) return '—';
    return this.menuItemTypes.find(t => t.value === type)?.label ?? type;
  }

  onMenuSubmit(): void {
    if (this.menuForm.invalid) return;
    const shop = this.shop();
    if (!shop?.currentMenu) {
      void this.dialog.alert('Create a menu before adding items.');
      return;
    }

    const val = { ...this.menuForm.getRawValue(), menuId: shop.currentMenu.id };
    const id = this.editingMenuItemId();
    const op = id
      ? this.menuItemService.update(id, val)
      : this.menuItemService.create(val);

    op.subscribe(() => {
      this.showMenuForm.set(false);
      this.editingMenuItemId.set(null);
      this.menuForm.reset({ name: '', description: '', price: 0, priceCurrency: 'RSD', imageUrl: '', itemType: 'FOOD' });
      this.loadShop();
    });
  }

  onEditMenuItem(item: MenuItemResponseDto): void {
    this.editingMenuItemId.set(item.id);
    this.showMenuForm.set(true);
    this.menuForm.patchValue({
      name: item.name,
      description: item.description,
      price: item.price,
      priceCurrency: item.priceCurrency,
      imageUrl: item.imageUrl,
      itemType: item.itemType ?? 'FOOD',
    });
  }

  onDeleteMenuItem(item: MenuItemResponseDto): void {
    void this.dialog
      .confirm(`Delete "${item.name}"?`, { confirmLabel: 'Delete', confirmVariant: 'danger' })
      .then(ok => {
        if (!ok) return;
        this.menuItemService.delete(item.id).subscribe(() => this.loadShop());
      });
  }

  private nextTableNumber(): number {
    const tables = this.shop()?.tables ?? [];
    if (tables.length === 0) return 1;
    return Math.max(...tables.map(t => t.number)) + 1;
  }

  openAddTableForm(): void {
    this.editingTableId.set(null);
    this.tableForm.reset({ number: this.nextTableNumber(), capacity: 2 });
    this.showTableForm.set(true);
  }

  onTableSubmit(): void {
    if (this.tableForm.invalid) return;
    const val = { ...this.tableForm.getRawValue(), shopId: this.shopId };
    const id = this.editingTableId();
    const op = id
      ? this.tableService.update(id, val)
      : this.tableService.create(val);

    op.subscribe(() => {
      this.showTableForm.set(false);
      this.editingTableId.set(null);
      this.tableForm.reset({ number: this.nextTableNumber(), capacity: 2 });
      this.loadShop();
    });
  }

  onEditTable(t: TableResponseDto): void {
    this.editingTableId.set(t.id);
    this.showTableForm.set(true);
    this.tableForm.patchValue({ number: t.number, capacity: t.capacity });
  }

  onDeleteTable(t: TableResponseDto): void {
    void this.dialog
      .confirm(`Delete table #${t.number}?`, { confirmLabel: 'Delete', confirmVariant: 'danger' })
      .then(ok => {
        if (!ok) return;
        this.tableService.delete(t.id).subscribe(() => this.loadShop());
      });
  }

  openAddEventForm(): void {
    this.editingEventId.set(null);
    this.eventForm.reset({ eventName: '', eventDate: '', description: '' });
    this.applyEventDateValidatorsForMode();
    this.showEventForm.set(true);
  }

  onEditEvent(event: EventResponseDto): void {
    this.editingEventId.set(event.eventId);
    this.applyEventDateValidatorsForMode();
    this.showEventForm.set(true);
    this.eventForm.patchValue({
      eventName: event.eventName,
      eventDate: normalizeDateTimeLocal(event.eventDate),
      description: event.description,
    });
  }

  onEventSubmit(): void {
    if (this.eventForm.invalid) return;
    if (!this.editingEventId() && this.eventForm.controls.eventDate.hasError('pastDate')) return;

    const val = { ...this.eventForm.getRawValue(), shopId: this.shopId };
    const id = this.editingEventId();
    const op = id ? this.eventService.update(id, val) : this.eventService.create(val);

    op.subscribe(() => {
      this.cancelEventForm();
      this.loadShop();
    });
  }

  onDeleteEvent(event: EventResponseDto): void {
    void this.dialog
      .confirm(`Delete "${event.eventName}"?`, { confirmLabel: 'Delete', confirmVariant: 'danger' })
      .then(ok => {
        if (!ok) return;
        this.eventService.delete(event.eventId).subscribe(() => this.loadShop());
      });
  }

  cancelEventForm(): void {
    this.editingEventId.set(null);
    this.showEventForm.set(false);
    this.eventForm.reset({ eventName: '', eventDate: '', description: '' });
    this.applyEventDateValidatorsForMode();
  }

  private applyEventDateValidatorsForMode(): void {
    const dateControl = this.eventForm.controls.eventDate;
    if (this.editingEventId()) {
      dateControl.setValidators([Validators.required]);
    } else {
      dateControl.setValidators([Validators.required, futureDateValidator()]);
    }
    dateControl.updateValueAndValidity();
  }

  toggleReviewForm(): void {
    const next = !this.showReviewForm();
    this.showReviewForm.set(next);
    if (!next) {
      this.reviewForm.reset({ rating: 0, description: '', commentsEnabled: true });
    }
  }

  isReviewAuthor(review: ReviewResponseDto): boolean {
    const profile = this.profileService.currentUser();
    return !!profile && profile.id === review.user.id;
  }

  commentDraft(reviewId: string): string {
    return this.commentDrafts()[reviewId] ?? '';
  }

  updateCommentDraft(reviewId: string, value: string): void {
    this.commentDrafts.update(drafts => ({ ...drafts, [reviewId]: value }));
  }

  formatAverageRating(shop: ShopResponseDto): string {
    return shop.averageRating != null ? shop.averageRating.toFixed(1) : '—';
  }

  roundedAverageRating(shop: ShopResponseDto): number {
    return Math.round(shop.averageRating ?? 0);
  }

  formatCommentDate(iso: string): string {
    return new Date(iso).toLocaleString(undefined, {
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  }

  onCommentsEnabledChange(review: ReviewResponseDto, enabled: boolean): void {
    this.reviewService.update(review.id, { commentsEnabled: enabled }).subscribe({
      next: () => this.loadShop(),
      error: () => void this.dialog.alert('Could not update comment settings.'),
    });
  }

  onCommentSubmit(reviewId: string): void {
    const body = this.commentDraft(reviewId).trim();
    if (!body) return;

    this.reviewCommentService.create(reviewId, { body }).subscribe({
      next: () => {
        this.commentDrafts.update(drafts => ({ ...drafts, [reviewId]: '' }));
        this.loadShop();
      },
      error: () =>
        void this.dialog.alert('Could not post comment. Comments may be disabled for this review.'),
    });
  }

  onReviewSubmit(): void {
    if (this.reviewForm.invalid) {
      this.reviewForm.markAllAsTouched();
      return;
    }

    const val = this.reviewForm.getRawValue();
    this.reviewService
      .create({
        description: val.description,
        rating: val.rating,
        shopId: this.shopId,
        commentsEnabled: val.commentsEnabled,
      })
      .subscribe({
        next: () => {
          this.showReviewForm.set(false);
          this.reviewForm.reset({ rating: 0, description: '', commentsEnabled: true });
          this.loadShop();
        },
        error: () =>
          void this.dialog.alert('Could not submit review. You may have already reviewed this shop.'),
      });
  }
}
