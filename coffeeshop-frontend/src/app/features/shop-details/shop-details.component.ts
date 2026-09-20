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
import { EmployeeManagementComponent } from '../dashboard/employee-management.component';
import { LoyaltyManagementComponent } from './loyalty-management.component';
import { LoyaltyPlanResponseDto } from '../../models/loyalty-plan.model';
import { ShopEmployeeService } from '../../services/shop-employee.service';
import { getAcceptReservationErrorMessage } from '../../utils/api-error';
import {
  canReserveForEvent,
  eventAvailabilityLabel as formatEventAvailability,
  eventIdsBlockedForUser,
  isEventFull,
} from '../../utils/reservation-event.utils';
import { DialogService } from '../../services/dialog.service';
import { SubscriptionService } from '../../services/subscription.service';
import { DateTimePickerComponent } from '../../shared/date-time-picker/date-time-picker.component';
import { todayIso } from '../../shared/calendar/calendar-date.utils';
import {
  futureDateValidator,
  normalizeDateTimeLocal,
} from '../../utils/event-form.utils';

type Tab = 'users' | 'menu' | 'tables' | 'reservations' | 'events' | 'reviews' | 'employees' | 'loyalty';
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
    EmployeeManagementComponent,
    LoyaltyManagementComponent,
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="page">
      @if (loading()) {
        <div class="loading">Loading shop details...</div>
      } @else if (!shop()) {
        <div class="empty-state"><p>Shop not found.</p><a routerLink="/shops">Back to shops</a></div>
      } @else {
        <nav class="shop-breadcrumb" aria-label="Breadcrumb">
          <a routerLink="/shops" class="shop-breadcrumb__link">
            <svg width="14" height="14" viewBox="0 0 16 16" aria-hidden="true"><path d="M10 3L5 8l5 5" stroke="currentColor" stroke-width="1.5" fill="none"/></svg>
            Shops
          </a>
          <span class="shop-breadcrumb__current">{{ shop()!.name }}</span>
        </nav>

        <div class="page-header">
          <div class="page-header__title-row">
            <h1 class="page-title">
              {{ shop()!.name }}
              @if (isFavourite()) {
                <span class="badge badge-joined">Joined</span>
              }
            </h1>
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
                <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                  @if (isFavourite()) {
                    <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
                  } @else {
                    <path d="M16.5 3c-1.74 0-3.41.81-4.5 2.09C10.91 3.81 9.24 3 7.5 3 4.42 3 2 5.42 2 8.5c0 3.78 3.4 6.86 8.55 11.54L12 21.35l1.45-1.32C18.6 15.36 22 12.28 22 8.5 22 5.42 19.58 3 16.5 3zm-4.4 15.55l-.1.1-.1-.1C7.14 14.24 4 11.39 4 8.5 4 6.5 5.5 5 7.5 5c1.54 0 3.04.99 3.57 2.36h1.87C13.46 5.99 14.96 5 16.5 5c2 0 3.5 1.5 3.5 3.5 0 2.89-3.14 5.74-7.9 10.05z"/>
                  }
                </svg>
              </button>
            }
          </div>
          <p class="text-muted">{{ shop()!.city }} &middot; {{ shop()!.address }} &middot; {{ shop()!.email }}</p>
        </div>

        <nav class="pill-tabs shop-tabs mb-3" role="tablist" aria-label="Shop section">
          @for (t of visibleTabs(); track t.key) {
            <button type="button" class="pill-tab" role="tab"
              [class.pill-tab--active]="activeTab() === t.key"
              [attr.aria-selected]="activeTab() === t.key"
              (click)="onTabChange(t.key)">
              {{ t.label }}
            </button>
          }
        </nav>

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
            <div class="compact-list">
              @for (u of members(); track u.id) {
                <article class="compact-row">
                  <div class="compact-row__start">
                    <span class="compact-row__avatar">{{ u.name.charAt(0).toUpperCase() }}</span>
                    <div class="compact-row__text">
                      <span class="compact-row__primary">{{ u.name }}</span>
                      <span class="compact-row__secondary">{{ u.username }}</span>
                    </div>
                  </div>
                </article>
              }
            </div>

            <div class="pagination-bar mb-3">
              <span class="pagination-summary">{{ membersRangeLabel() }}</span>
              <div class="pagination-controls">
                <button class="btn btn-secondary btn-sm" [disabled]="membersPage() === 0" (click)="goToMembersPage(membersPage() - 1)">Previous</button>
                <span class="pagination-page">Page {{ membersPage() + 1 }} of {{ membersTotalPages() }}</span>
                <button class="btn btn-secondary btn-sm" [disabled]="membersPage() >= membersTotalPages() - 1" (click)="goToMembersPage(membersPage() + 1)">Next</button>
              </div>
            </div>
          }

          @if (canPostCommunity()) {
            <div class="form-card mb-3">
              <h3 class="mb-2">Post announcement</h3>
              <p class="text-muted mb-2" style="font-size:0.875rem">Announcements appear pinned at the top of the feed.</p>
              <textarea class="form-input" rows="3" placeholder="Share news with your community..."
                [value]="announcementDraft()"
                (input)="announcementDraft.set($any($event.target).value)"></textarea>
              <button type="button" class="btn btn-primary" style="margin-top:0.5rem"
                [disabled]="!announcementDraft().trim() || postingAnnouncement()"
                (click)="onAnnouncementSubmit()">Post announcement</button>
            </div>
          } @else if (showCommunityUpgrade()) {
            <div class="form-card mb-3 upgrade-banner">
              <p class="text-muted" style="margin:0">Post announcements to your community with Growth or higher.</p>
              <a routerLink="/profile/billing" class="upgrade-link">Upgrade to Growth</a>
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
                      @if (post.type === 'ANNOUNCEMENT') { <span class="badge badge-joined" style="margin-left:0.5rem">Announcement</span> }
                      @if (post.pinned) { <span class="badge" style="margin-left:0.5rem;background:#4a3728;color:#f5d0a0">Pinned</span> }
                      <p class="text-muted" style="font-size:0.8rem;margin:0.25rem 0 0">{{ formatPostDate(post.createdAt) }}</p>
                    </div>
                    @if (canDeletePost(post)) { <button type="button" class="btn btn-sm btn-danger" (click)="onDeletePost(post)">Delete</button> }
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
          @if (canManageShopContent()) {
            <div class="tab-toolbar mb-3">
              @if (menusQuotaLabel(); as quota) {
                <p class="text-muted usage-quota">{{ quota }}</p>
              }
              @if (canCreateMenu()) {
                <button class="btn btn-secondary" (click)="onCreateMenu()">+ New Menu</button>
              } @else if (showMenusUpgrade()) {
                <a routerLink="/profile/billing" class="upgrade-link">Upgrade to Growth</a>
              }
            </div>
          }

          <h3 class="mb-2">Current menu</h3>
          @if (!shop()!.currentMenu) {
            <div class="empty-state"><p>No menu yet.</p>
              @if (canManageShopContent()) { <p class="text-muted">Create a menu to start adding items.</p> }
            </div>
          } @else {
            @if (shop()!.currentMenu!.label) { <p class="text-muted mb-2">{{ shop()!.currentMenu!.label }}</p> }

            @if (shop()!.currentMenu!.items.length > 0) {
              <nav class="pill-tabs pill-tabs--filter mb-2" aria-label="Filter menu items">
                <button type="button" class="pill-tab pill-tab--filter"
                  [class.pill-tab--active]="menuTypeFilter() === 'ALL'"
                  (click)="menuTypeFilter.set('ALL')">All</button>
                <button type="button" class="pill-tab pill-tab--filter"
                  [class.pill-tab--active]="menuTypeFilter() === 'DRINK'"
                  (click)="menuTypeFilter.set('DRINK')">Drinks</button>
                <button type="button" class="pill-tab pill-tab--filter"
                  [class.pill-tab--active]="menuTypeFilter() === 'FOOD'"
                  (click)="menuTypeFilter.set('FOOD')">Food</button>
                <button type="button" class="pill-tab pill-tab--filter"
                  [class.pill-tab--active]="menuTypeFilter() === 'DESSERT'"
                  (click)="menuTypeFilter.set('DESSERT')">Desserts</button>
                <button type="button" class="pill-tab pill-tab--filter"
                  [class.pill-tab--active]="menuTypeFilter() === 'OTHER'"
                  (click)="menuTypeFilter.set('OTHER')">Other</button>
              </nav>
            }

            @if (canManageShopContent()) {
              @if (showMenuForm()) {
                <div class="form-card mb-3">
                  <form [formGroup]="menuForm" (ngSubmit)="onMenuSubmit()">
                    <div class="form-row">
                      <div class="form-group"><label>Name</label><input class="form-input" formControlName="name" /></div>
                      <div class="form-group"><label>Price</label><input class="form-input" type="number" step="0.01" formControlName="price" /></div>
                    </div>
                    <div class="form-row">
                      <div class="form-group"><label>Currency</label><app-form-select formControlName="priceCurrency" placeholder="Currency" [options]="menuCurrencySelectOptions" /></div>
                      <div class="form-group"><label>Image URL</label><input class="form-input" formControlName="imageUrl" /></div>
                    </div>
                    <div class="form-group"><label>Description</label><input class="form-input" formControlName="description" /></div>
                    <div class="form-group"><label>Type</label><app-form-select formControlName="itemType" placeholder="Item type" [options]="menuItemTypeSelectOptions" /></div>
                    <div class="form-actions">
                      <button type="submit" class="btn btn-primary" [disabled]="menuForm.invalid">{{ editingMenuItemId() ? 'Update' : 'Add' }}</button>
                      <button type="button" class="btn btn-secondary" (click)="showMenuForm.set(false); editingMenuItemId.set(null)">Cancel</button>
                    </div>
                  </form>
                </div>
              } @else {
                <button class="btn btn-primary mb-2" (click)="showMenuForm.set(true)">+ Add Item</button>
              }
            }

            @if (filteredMenuItems().length === 0) {
              <div class="empty-state">
                <p>@if (menuTypeFilter() === 'ALL') { No menu items. } @else { No items match this filter. }</p>
              </div>
            } @else {
              <div class="compact-list">
                @for (item of filteredMenuItems(); track item.id) {
                  <article class="compact-row">
                    <div class="compact-row__start">
                      <div class="compact-row__text">
                        <span class="compact-row__primary">{{ item.name }}</span>
                        <span class="compact-row__secondary">{{ formatMenuItemType(item.itemType) }} &middot; {{ item.description }}</span>
                      </div>
                    </div>
                    <span class="compact-row__meta compact-row__meta--accent">{{ item.price }} {{ item.priceCurrency }}</span>
                    @if (canManageShopContent()) {
                      <div class="compact-row__end">
                        <button class="btn btn--compact btn-secondary" (click)="onEditMenuItem(item)">Edit</button>
                        <button class="btn btn--compact btn-danger" (click)="onDeleteMenuItem(item)">Del</button>
                      </div>
                    }
                  </article>
                }
              </div>
            }
          }

          @if (!isCustomer() && shop()!.menuHistory.length > 0) {
            <h3 class="mt-4 mb-2">Menu history</h3>
            @for (historical of shop()!.menuHistory; track historical.id) {
              <details class="form-card mb-2">
                <summary style="cursor:pointer;font-weight:600">
                  {{ historical.label || 'Menu' }}
                  @if (historical.createdAt) { <span class="text-muted"> — {{ formatMenuDate(historical.createdAt) }}</span> }
                </summary>
                @if (historical.items.length === 0) {
                  <p class="text-muted mt-2">No items.</p>
                } @else {
                  <div class="compact-list mt-2">
                    @for (item of historical.items; track item.id) {
                      <article class="compact-row">
                        <div class="compact-row__start">
                          <div class="compact-row__text">
                            <span class="compact-row__primary">{{ item.name }}</span>
                            <span class="compact-row__secondary">{{ formatMenuItemType(item.itemType) }} &middot; {{ item.description }}</span>
                          </div>
                        </div>
                        <span class="compact-row__meta compact-row__meta--accent">{{ item.price }} {{ item.priceCurrency }}</span>
                      </article>
                    }
                  </div>
                }
              </details>
            }
          }
        }

        <!-- TABLES TAB -->
        @if (activeTab() === 'tables') {
          @if (canManageShopContent()) {
            <div class="tab-toolbar mb-2">
              @if (tablesQuotaLabel(); as quota) {
                <p class="text-muted usage-quota">{{ quota }}</p>
              }
              @if (showTableForm()) {
                <div class="form-card mb-3" style="width:100%">
                  <form [formGroup]="tableForm" (ngSubmit)="onTableSubmit()">
                    <div class="form-row">
                      <div class="form-group"><label>Table Number</label><input class="form-input" type="number" formControlName="number" /></div>
                      <div class="form-group"><label>Capacity</label><input class="form-input" type="number" formControlName="capacity" /></div>
                    </div>
                    <div class="form-actions">
                      <button type="submit" class="btn btn-primary" [disabled]="tableForm.invalid">{{ editingTableId() ? 'Update' : 'Add' }}</button>
                      <button type="button" class="btn btn-secondary" (click)="showTableForm.set(false); editingTableId.set(null)">Cancel</button>
                    </div>
                  </form>
                </div>
              } @else if (canAddTable()) {
                <button class="btn btn-primary" (click)="openAddTableForm()">+ Add Table</button>
              } @else if (showTablesUpgrade()) {
                <a routerLink="/profile/billing" class="upgrade-link">Upgrade to Growth</a>
              }
            </div>
          }

          @if (shop()!.tables.length === 0) {
            <div class="empty-state"><p>No tables.</p></div>
          } @else {
            <div class="compact-list">
              @for (t of shop()!.tables; track t.id) {
                <article class="compact-row">
                  <div class="compact-row__start">
                    <span class="compact-row__avatar" style="font-size:0.75rem">T{{ t.number }}</span>
                    <div class="compact-row__text">
                      <span class="compact-row__primary">Table {{ t.number }}</span>
                      <span class="compact-row__secondary">Capacity {{ t.capacity }}</span>
                    </div>
                  </div>
                  @if (canManageShopContent()) {
                    <div class="compact-row__end">
                      <button class="btn btn--compact btn-secondary" (click)="onEditTable(t)">Edit</button>
                      <button class="btn btn--compact btn-danger" (click)="onDeleteTable(t)">Del</button>
                    </div>
                  }
                </article>
              }
            </div>
          }
        }

        <!-- RESERVATIONS TAB -->
        @if (activeTab() === 'reservations') {
          <nav class="pill-tabs pill-tabs--sub mb-3" role="tablist" aria-label="Reservation status">
            <button type="button" class="pill-tab pill-tab--sub" role="tab"
              [class.pill-tab--active]="reservationSubTab() === 'pending'"
              [attr.aria-selected]="reservationSubTab() === 'pending'"
              (click)="reservationSubTab.set('pending')">
              Pending <span class="tab__count">{{ pendingRequests().length }}</span>
            </button>
            <button type="button" class="pill-tab pill-tab--sub" role="tab"
              [class.pill-tab--active]="reservationSubTab() === 'approved'"
              [attr.aria-selected]="reservationSubTab() === 'approved'"
              (click)="reservationSubTab.set('approved')">
              Approved <span class="tab__count">{{ reservations().length }}</span>
            </button>
            <button type="button" class="pill-tab pill-tab--sub" role="tab"
              [class.pill-tab--active]="reservationSubTab() === 'denied'"
              [attr.aria-selected]="reservationSubTab() === 'denied'"
              (click)="reservationSubTab.set('denied')">
              Denied <span class="tab__count">{{ deniedRequests().length }}</span>
            </button>
          </nav>

          @if (reservationSubTab() === 'pending') {
            @if (pendingRequests().length === 0) {
              <div class="empty-state"><p>No pending reservation requests.</p></div>
            } @else if (canManageShopContent()) {
              <div class="compact-list">
                @for (req of pendingRequests(); track req.id) {
                  <article class="compact-row">
                    <div class="compact-row__start">
                      <span class="compact-row__avatar">{{ (req.user?.name ?? '?').charAt(0).toUpperCase() }}</span>
                      <div class="compact-row__text">
                        <span class="compact-row__primary">{{ req.user?.name ?? '—' }}</span>
                        <span class="compact-row__secondary">{{ eventLabel(req) }} &middot; Party {{ req.partySize }}</span>
                      </div>
                    </div>
                    <span class="badge badge-pending">{{ req.status }}</span>
                    <div class="compact-row__end" style="flex-wrap:wrap">
                      <app-form-select [compact]="true" placeholder="Table"
                        [options]="tableSelectOptionsForRequest(req)"
                        [ngModel]="tableSelectValue(req.id)"
                        (ngModelChange)="onTableSelectChange(req.id, $event)" />
                      @if (!hasSuitableTablesForRequest(req)) {
                        <span class="text-muted" style="font-size:0.6875rem">No table for party of {{ req.partySize }}</span>
                      }
                      <button class="btn btn--compact btn-primary" (click)="onAcceptRequest(req)">Accept</button>
                      <button class="btn btn--compact btn-danger" (click)="onDenyRequest(req)">Deny</button>
                    </div>
                  </article>
                }
              </div>
            } @else if (canSelfReserveAtShop()) {
              <div class="compact-list">
                @for (req of pendingRequests(); track req.id) {
                  <article class="compact-row">
                    <div class="compact-row__start">
                      <div class="compact-row__text">
                        <span class="compact-row__primary">{{ eventLabel(req) }}</span>
                        <span class="compact-row__secondary">Party {{ req.partySize }}</span>
                      </div>
                    </div>
                    <span class="badge badge-pending">{{ req.status }}</span>
                  </article>
                }
              </div>
            }
          }

          @if (reservationSubTab() === 'approved') {
            @if (reservations().length === 0) {
              <div class="empty-state"><p>{{ canSelfReserveAtShop() ? 'No confirmed reservations for this shop.' : 'No approved reservations for this shop.' }}</p></div>
            } @else {
              <div class="compact-list">
                @for (r of reservations(); track r.id) {
                  <article class="compact-row">
                    <div class="compact-row__start">
                      <div class="compact-row__text">
                        @if (canManageShopContent()) { <span class="compact-row__primary">{{ r.user.name }}</span> }
                        <span class="compact-row__secondary">{{ eventLabel(r) }} &middot; {{ r.table ? 'Table ' + r.table.number : 'N/A' }} &middot; Party {{ r.partySize }}</span>
                      </div>
                    </div>
                  </article>
                }
              </div>
            }
          }

          @if (reservationSubTab() === 'denied') {
            @if (deniedRequests().length === 0) {
              <div class="empty-state"><p>No denied reservation requests.</p></div>
            } @else {
              <div class="compact-list">
                @for (req of deniedRequests(); track req.id) {
                  <article class="compact-row">
                    <div class="compact-row__start">
                      <div class="compact-row__text">
                        @if (canManageShopContent()) { <span class="compact-row__primary">{{ req.user?.name ?? '—' }}</span> }
                        <span class="compact-row__secondary">{{ eventLabel(req) }} &middot; Party {{ req.partySize }}</span>
                      </div>
                    </div>
                    <span class="badge badge-denied">{{ req.status }}</span>
                  </article>
                }
              </div>
            }
          }
        }

        <!-- EVENTS TAB -->
        @if (activeTab() === 'events') {
          @if (canManageShopContent()) {
            @if (showEventForm()) {
              <div class="form-card mb-3">
                <form [formGroup]="eventForm" (ngSubmit)="onEventSubmit()">
                  <div class="form-row">
                    <div class="form-group"><label>Event Name</label><input class="form-input" formControlName="eventName" placeholder="Event name" /></div>
                    <div class="form-group"><label>Event Date</label>
                      <app-date-time-picker formControlName="eventDate" [minDate]="editingEventId() ? null : todayIsoValue()" />
                      @if (eventForm.controls.eventDate.touched && eventForm.controls.eventDate.hasError('pastDate')) { <span class="form-error">Event date must be in the future.</span> }
                    </div>
                  </div>
                  <div class="form-group"><label>Description</label><input class="form-input" formControlName="description" placeholder="Event description" /></div>
                  <div class="form-actions">
                    <button type="submit" class="btn btn-primary" [disabled]="eventForm.invalid">{{ editingEventId() ? 'Update' : 'Create' }}</button>
                    <button type="button" class="btn btn-secondary" (click)="cancelEventForm()">Cancel</button>
                  </div>
                </form>
              </div>
            } @else {
              <button class="btn btn-primary mb-2" (click)="openAddEventForm()">+ Add Event</button>
            }
          }

          @if (shop()!.events.length === 0) {
            <div class="empty-state"><p>No events.</p>
              @if (canManageShopContent()) { <p class="text-muted">Add an event for customers to reserve.</p> }
            </div>
          } @else {
            <div class="compact-list">
              @for (e of shop()!.events; track e.eventId) {
                <article class="compact-row">
                  <div class="compact-row__start">
                    <div class="compact-row__text">
                      <span class="compact-row__primary">{{ e.eventName }}</span>
                      <span class="compact-row__secondary">{{ e.eventDate }} &middot; {{ eventAvailabilityLabel(e) }}@if (e.description) { &middot; {{ e.description }} }</span>
                    </div>
                  </div>
                  @if (canSelfReserveAtShop() || canManageShopContent()) {
                    <div class="compact-row__end">
                      @if (canSelfReserveAtShop()) {
                        <button type="button" class="btn btn--compact btn-primary"
                          [disabled]="!canShowReserveButton(e)"
                          [title]="reserveTooltip(e)"
                          (click)="onReserveEventClick(e)">Reserve</button>
                      }
                      @if (canManageShopContent()) {
                        <button class="btn btn--compact btn-secondary" (click)="onEditEvent(e)">Edit</button>
                        <button class="btn btn--compact btn-danger" (click)="onDeleteEvent(e)">Del</button>
                      }
                    </div>
                  }
                </article>
              }
            </div>
          }

          @if (canSelfReserveAtShop() && selectedEventForRequest(); as event) {
            <div class="form-card mt-3">
              <h3 class="mb-2">Request reservation</h3>
              <p class="text-muted mb-2">{{ event.eventName }} &middot; {{ event.eventDate }}</p>
              <form [formGroup]="eventRequestForm" (ngSubmit)="onSubmitEventRequest()">
                <div class="form-group"><label>Party size</label><input class="form-input" type="number" formControlName="partySize" min="1" /></div>
                <div class="form-actions">
                  <button type="submit" class="btn btn-primary" [disabled]="eventRequestForm.invalid || !canSubmitEventRequest()">Submit request</button>
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
                <app-star-rating style="margin-top:0.5rem" [rating]="roundedAverageRating(shop()!)" [readonly]="true" />
              </div>
              <div class="stat-card">
                <div class="stat-value">{{ shop()!.reviewCount }}</div>
                <div class="stat-label">{{ shop()!.reviewCount === 1 ? 'Review' : 'Reviews' }}</div>
              </div>
            </div>
          }

          @if (canLeaveReview() && !showReviewForm()) {
            <button type="button" class="btn btn-primary mb-2" (click)="showReviewForm.set(true)">Leave review</button>
          }

          @if (showReviewForm()) {
            <form class="form-card mb-3" [formGroup]="reviewForm" (ngSubmit)="onReviewSubmit()">
              <h3 class="mb-2">Leave a review</h3>
              <div class="form-group"><label>Rating</label><app-star-rating formControlName="rating" />
                @if (reviewForm.controls.rating.touched && reviewForm.controls.rating.invalid) { <p class="text-muted" style="font-size:0.75rem;margin-top:0.25rem">Rating must be between 1 and 5.</p> }
              </div>
              <div class="form-group"><label for="review-description">Description</label><textarea id="review-description" class="form-input" rows="4" formControlName="description" placeholder="Share your experience"></textarea></div>
              <div class="form-group form-group--toggle">
                <span class="form-label" id="review-comments-enabled-label">Allow comments on this review</span>
                <label class="toggle-switch" aria-labelledby="review-comments-enabled-label">
                  <input type="checkbox" formControlName="commentsEnabled" /><span class="toggle-slider" aria-hidden="true"></span>
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
                  <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:0.75rem;margin-bottom:0.5rem">
                    <div style="margin-bottom:0"><app-star-rating [rating]="r.rating" [readonly]="true" /></div>
                    @if (canManageShopContent() && !isReviewAuthor(r)) {
                      @if (canModerateReviews()) {
                        <button type="button" class="btn btn-sm btn-danger" (click)="onDeleteReview(r)">Delete</button>
                      } @else if (showReviewsUpgrade()) {
                        <a routerLink="/profile/billing" class="upgrade-link">Upgrade to Growth</a>
                      }
                    }
                  </div>
                  <p class="text-muted" style="font-size:0.875rem">{{ r.description }}</p>
                  <p class="text-muted" style="font-size:0.75rem;margin-top:0.5rem">By {{ r.user.name }}</p>
                  @if (isReviewAuthor(r)) {
                    <label class="toggle-switch" style="margin-top:0.75rem;font-size:0.875rem">
                      <input type="checkbox" [checked]="r.commentsEnabled" (change)="onCommentsEnabledChange(r, $any($event.target).checked)" />
                      <span class="toggle-slider" aria-hidden="true"></span><span>Allow comments</span>
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
                              <p style="font-size:0.75rem;color:#9ca3af;margin-bottom:0.25rem">{{ c.user.name }} · {{ formatCommentDate(c.createdAt) }}</p>
                              <p style="font-size:0.875rem;color:#e5e7eb">{{ c.body }}</p>
                            </div>
                          }
                        </div>
                      }
                      <textarea class="form-input" rows="2" placeholder="Write a comment..."
                        [value]="commentDraft(r.id)"
                        (input)="updateCommentDraft(r.id, $any($event.target).value)"></textarea>
                      <button type="button" class="btn btn-secondary" style="margin-top:0.5rem"
                        [disabled]="!commentDraft(r.id).trim()"
                        (click)="onCommentSubmit(r.id)">Post comment</button>
                    }
                  </div>
                </div>
              }
            </div>
          }
        }

        <!-- Employees tab -->
        @if (activeTab() === 'employees') {
          <app-employee-management [shopId]="shop()!.id" />
        }

        <!-- Loyalty tab -->
        @if (activeTab() === 'loyalty') {
          <app-loyalty-management
            [shopId]="shop()!.id"
            [shopFields]="loyaltyShopFields()"
            [loyaltyPlan]="shop()!.loyaltyPlan"
            (loyaltyPlanChange)="onLoyaltyPlanChange($event)"
          />
        }
      }
    </div>
  `,
  styles: [`
    :host {
      display: block;
    }

    .shop-breadcrumb {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      margin-bottom: 0.75rem;
      font-size: 0.875rem;
    }

    .shop-breadcrumb__link {
      display: inline-flex;
      align-items: center;
      gap: 0.375rem;
      color: #888;
      text-decoration: none;
      transition: color 0.15s;
    }

    .shop-breadcrumb__link:hover {
      color: #d4a574;
    }

    .shop-breadcrumb__current {
      color: #aaa;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    .page-header__title-row {
      display: flex;
      align-items: center;
      gap: 0.75rem;
    }

    .page-header__title-row .page-title {
      margin-bottom: 0;
    }

    .pill-tabs.shop-tabs {
      overflow-x: auto;
      -webkit-overflow-scrolling: touch;
      scrollbar-width: none;
    }

    .pill-tabs.shop-tabs::-webkit-scrollbar {
      display: none;
    }

    .pill-tabs.shop-tabs .pill-tab {
      flex-shrink: 0;
    }

    @media (max-width: 768px) {
      .page-header__title-row {
        flex-wrap: wrap;
      }
    }

    .tab-toolbar {
      display: flex;
      align-items: center;
      gap: 1rem;
      flex-wrap: wrap;
    }

    .usage-quota {
      margin: 0;
      font-size: 0.8125rem;
    }

    .upgrade-link {
      font-size: 0.875rem;
      font-weight: 600;
      color: #d4a574;
      text-decoration: none;
      white-space: nowrap;
    }

    .upgrade-link:hover {
      text-decoration: underline;
    }

    .upgrade-banner {
      display: flex;
      flex-direction: column;
      align-items: flex-start;
      gap: 0.5rem;
    }
  `],
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
  private readonly shopEmployeeService = inject(ShopEmployeeService);
  private readonly subscriptionService = inject(SubscriptionService);

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

  readonly menuTypeFilter = signal<MenuItemType | 'ALL'>('ALL');

  readonly filteredMenuItems = computed(() => {
    const items = this.shop()?.currentMenu?.items ?? [];
    const filter = this.menuTypeFilter();
    if (filter === 'ALL') return items;
    return items.filter(item => item.itemType === filter);
  });

  readonly pendingRequests = computed(() =>
    this.allShopRequests().filter(req => req.status === 'PENDING'),
  );

  readonly deniedRequests = computed(() =>
    this.allShopRequests().filter(req => req.status === 'DENIED'),
  );

  readonly canManageShop = computed<boolean>(() => {
    const shop = this.shop();
    const profile = this.profileService.currentUser();
    if (!shop || !profile) return false;
    if (this.authService.isAdmin()) return true;
    return shop.createdBy?.id === profile.id;
  });

  readonly employeeShopIds = signal<string[]>([]);

  readonly canManageShopContent = computed<boolean>(() => {
    if (this.canManageShop()) return true;
    const shop = this.shop();
    return !!shop && this.employeeShopIds().includes(shop.id);
  });

  readonly isCustomer = computed(() => {
    const profile = this.profileService.currentUser();
    return !!profile && profile.userType === 'CUSTOMER' && !this.canManageShopContent();
  });

  readonly canSelfReserveAtShop = computed(() => !this.canManageShopContent());

  readonly visibleTabs = computed(() => {
    let tabs = this.isCustomer() ? this.tabs.filter(t => t.key !== 'tables') : this.tabs;
    if (!this.canManageShop()) {
      tabs = tabs.filter(t => t.key !== 'employees');
    }
    if (!this.showLoyaltyTab()) {
      tabs = tabs.filter(t => t.key !== 'loyalty');
    }
    return tabs;
  });

  readonly tablesQuotaLabel = computed(() => {
    if (!this.canManageShopContent()) return null;
    const limit = this.subscriptionService.getLimit('tables');
    if (!limit || limit.max < 0) return null;
    return `${limit.used} / ${limit.max} tables`;
  });

  readonly canAddTable = computed(() => {
    if (!this.canManageShopContent()) return false;
    if (this.subscriptionService.canUseFeature('unlimited_tables')) return true;
    const limit = this.subscriptionService.getLimit('tables');
    if (!limit || limit.max < 0) return true;
    return limit.used < limit.max;
  });

  readonly showTablesUpgrade = computed(() =>
    this.canManageShopContent()
    && !this.canAddTable()
    && !this.subscriptionService.canUseFeature('unlimited_tables'),
  );

  readonly menusQuotaLabel = computed(() => {
    if (!this.canManageShopContent()) return null;
    const limit = this.subscriptionService.getLimit('menus');
    if (!limit || limit.max < 0) return null;
    return `${limit.used} / ${limit.max} menus`;
  });

  readonly canCreateMenu = computed(() => {
    if (!this.canManageShopContent()) return false;
    if (this.subscriptionService.canUseFeature('unlimited_menus')) return true;
    const limit = this.subscriptionService.getLimit('menus');
    if (!limit || limit.max < 0) return true;
    return limit.used < limit.max;
  });

  readonly showMenusUpgrade = computed(() =>
    this.canManageShopContent()
    && !this.canCreateMenu()
    && !this.subscriptionService.canUseFeature('unlimited_menus'),
  );

  readonly canPostCommunity = computed(() =>
    this.canManageShopContent() && this.subscriptionService.canUseFeature('community_post'),
  );

  readonly showCommunityUpgrade = computed(() =>
    this.canManageShopContent() && !this.subscriptionService.canUseFeature('community_post'),
  );

  readonly canModerateReviews = computed(() =>
    this.canManageShopContent() && this.subscriptionService.canUseFeature('review_moderate'),
  );

  readonly showReviewsUpgrade = computed(() =>
    this.canManageShopContent() && !this.subscriptionService.canUseFeature('review_moderate'),
  );

  readonly showLoyaltyTab = computed(() =>
    this.canManageShop() && (
      this.subscriptionService.canUseFeature('loyalty_basic')
      || this.subscriptionService.canUseFeature('loyalty_premium')
    ),
  );

  readonly loyaltyShopFields = computed(() => {
    const shop = this.shop();
    if (!shop) {
      return { name: '', address: '', city: '', phoneNumber: '', email: '' };
    }
    return {
      name: shop.name,
      address: shop.address,
      city: shop.city,
      phoneNumber: shop.phoneNumber,
      email: shop.email,
    };
  });

  readonly blockedEventIdsForCurrentUser = computed(() => {
    const profile = this.profileService.currentUser();
    if (!profile) return new Set<string>();
    return eventIdsBlockedForUser(
      this.allUserRequests(),
      this.allUserReservations(),
      profile.id,
    );
  });

  readonly canSubmitEventRequest = computed(() => {
    const event = this.selectedEventForRequest();
    if (!event) return false;
    return this.selectableEventsForUser().some(e => e.eventId === event.eventId);
  });

  readonly selectableEventsForUser = computed(() => {
    const shop = this.shop();
    if (!shop) return [];
    return shop.events.filter(e =>
      canReserveForEvent(e)
      && (this.canSelfReserveAtShop()
        ? !this.blockedEventIdsForCurrentUser().has(e.eventId)
        : true),
    );
  });

  readonly togglingFavourite = signal(false);
  readonly showMenuForm = signal(false);
  readonly editingMenuItemId = signal<string | null>(null);
  readonly showTableForm = signal(false);
  readonly editingTableId = signal<string | null>(null);
  readonly showReviewForm = signal(false);
  readonly showEventForm = signal(false);
  readonly editingEventId = signal<string | null>(null);

  readonly members = signal<UserSummaryDto[]>([]);
  readonly membersTotalElements = signal(0);
  readonly membersTotalPages = signal(1);
  readonly membersPage = signal(0);
  readonly membersLoading = signal(false);
  readonly membersSearchInput = signal('');

  readonly communityPosts = signal<CommunityPostResponseDto[]>([]);
  readonly communityPage = signal(0);
  readonly communityHasMore = signal(false);
  readonly communityLoading = signal(false);
  readonly announcementDraft = signal('');
  readonly postingAnnouncement = signal(false);

  readonly commentDrafts = signal<Record<string, string>>({});

  readonly tabs: { key: Tab; label: string }[] = [
    { key: 'users', label: 'Users' },
    { key: 'menu', label: 'Menu' },
    { key: 'tables', label: 'Tables' },
    { key: 'reservations', label: 'Reservations' },
    { key: 'events', label: 'Events' },
    { key: 'reviews', label: 'Reviews' },
    { key: 'loyalty', label: 'Loyalty' },
    { key: 'employees', label: 'Employees' },
  ];

  readonly menuForm = this.fb.nonNullable.group({
    name: ['', Validators.required],
    price: [0, [Validators.required, Validators.min(0.01)]],
    priceCurrency: ['' as MenuCurrency, Validators.required],
    description: [''],
    imageUrl: [''],
    itemType: ['' as MenuItemType, Validators.required],
  });

  readonly menuItemTypeSelectOptions: FormSelectOption[] = MENU_ITEM_TYPES.map(t => ({
    value: t.value,
    label: t.label,
  }));

  readonly menuCurrencySelectOptions: FormSelectOption[] = MENU_CURRENCIES.map(c => ({
    value: c.value,
    label: c.label,
  }));

  readonly tableForm = this.fb.nonNullable.group({
    number: [1, [Validators.required, Validators.min(1)]],
    capacity: [2, [Validators.required, Validators.min(1)]],
  });

  readonly reviewForm = this.fb.nonNullable.group({
    rating: [0, [Validators.required, Validators.min(1), Validators.max(5)]],
    description: ['', Validators.required],
    commentsEnabled: [true],
  });

  readonly eventForm = this.fb.nonNullable.group({
    eventName: ['', Validators.required],
    eventDate: ['', Validators.required],
    description: [''],
  });

  readonly eventRequestForm = this.fb.nonNullable.group({
    partySize: [1, [Validators.required, Validators.min(1)]],
  });

  readonly todayIsoValue = todayIso;

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id');
    if (!id) {
      this.loading.set(false);
      return;
    }
    this.shopService.getById(id).subscribe(shop => {
      this.shop.set(shop);
      this.loading.set(false);
    });
    this.loadShopData(id);
    if (this.profileService.currentUser()) {
      this.shopEmployeeService.getMyEmployeeShops().subscribe(shops => {
      this.employeeShopIds.set(shops.map(s => s.id));
    });
    }
  }

  private loadShopData(shopId: string): void {
    this.reservationService.getAll().subscribe(res => this.allUserReservations.set(res));
    this.requestService.getAll().subscribe(req => this.allUserRequests.set(req));
    this.requestService.getAll(shopId).subscribe(req => this.allShopRequests.set(req));
    this.reservationService.getAll().subscribe(res => this.reservations.set(res.filter(r => r.shop?.id === shopId)));
    this.loadMembers(shopId);
    this.loadCommunity(shopId);
  }

  onTabChange(tab: Tab): void {
    this.activeTab.set(tab);
    if (tab === 'reservations') {
      this.reservationSubTab.set('pending');
    }
  }

  isFavourite(): boolean {
    const shop = this.shop();
    if (!shop) return false;
    if (shop.favouriteByCurrentUser !== undefined) {
      return shop.favouriteByCurrentUser;
    }
    const profile = this.profileService.currentUser();
    if (!profile) return false;
    return profile.favouriteShops?.some(s => s.id === shop.id) ?? false;
  }

  toggleFavourite(): void {
    const shop = this.shop();
    if (!shop) return;
    const wasFavourite = this.isFavourite();
    this.shop.update(s => s ? { ...s, favouriteByCurrentUser: !wasFavourite } : s);
    this.togglingFavourite.set(true);
    const op = wasFavourite
      ? this.shopService.removeFavourite(shop.id)
      : this.shopService.addFavourite(shop.id);
    op.subscribe({
      next: updatedShop => {
        this.shop.update(s => s ? {
          ...s,
          ...updatedShop,
          favouriteByCurrentUser: updatedShop.favouriteByCurrentUser ?? !wasFavourite,
        } : s);
        this.togglingFavourite.set(false);
      },
      error: () => {
        this.shop.update(s => s ? { ...s, favouriteByCurrentUser: wasFavourite } : s);
        this.togglingFavourite.set(false);
      },
    });
  }

  // --- Menu ---
  formatMenuItemType(type: MenuItemType): string {
    const map: Record<MenuItemType, string> = {
      FOOD: 'Food',
      DRINK: 'Drink',
      DESSERT: 'Dessert',
      OTHER: 'Other',
    };
    return map[type] ?? type;
  }

  formatMenuDate(date: string): string {
    return new Date(date).toLocaleDateString();
  }

  onCreateMenu(): void {
    if (!this.shop()?.currentMenu) {
      const shop = this.shop();
      if (!shop) return;
      this.menuService.createForShop(shop.id).subscribe(menu => {
        this.shop.update(s => s ? { ...s, currentMenu: menu } : s);
      });
    }
  }

  onMenuSubmit(): void {
    if (this.menuForm.invalid || !this.shop()?.currentMenu) return;
    const menuId = this.shop()!.currentMenu!.id;
    const val = this.menuForm.getRawValue();
    const id = this.editingMenuItemId();

    const op = id
      ? this.menuItemService.update(id, { ...val, menuId })
      : this.menuItemService.create({ ...val, menuId });

    op.subscribe(item => {
      this.shop.update(s => {
        if (!s?.currentMenu) return s;
        const items = id
          ? s.currentMenu.items.map(i => i.id === id ? item : i)
          : [...s.currentMenu.items, item];
        return { ...s, currentMenu: { ...s.currentMenu, items } };
      });
      this.showMenuForm.set(false);
      this.editingMenuItemId.set(null);
      this.menuForm.reset({ name: '', price: 0, priceCurrency: '' as MenuCurrency, description: '', imageUrl: '', itemType: '' as MenuItemType });
    });
  }

  onEditMenuItem(item: MenuItemResponseDto): void {
    this.editingMenuItemId.set(item.id);
    this.showMenuForm.set(true);
    this.menuForm.patchValue({
      name: item.name,
      price: item.price,
      priceCurrency: item.priceCurrency,
      description: item.description,
      imageUrl: item.imageUrl ?? '',
      itemType: item.itemType,
    });
  }

  onDeleteMenuItem(item: MenuItemResponseDto): void {
    void this.dialog.confirm(`Delete "${item.name}"?`, { confirmLabel: 'Delete', confirmVariant: 'danger' }).then(ok => {
      if (!ok) return;
      this.menuItemService.delete(item.id).subscribe(() => {
        this.shop.update(s => {
          if (!s?.currentMenu) return s;
          return { ...s, currentMenu: { ...s.currentMenu, items: s.currentMenu.items.filter(i => i.id !== item.id) } };
        });
      });
    });
  }

  // --- Tables ---
  openAddTableForm(): void {
    this.showTableForm.set(true);
    this.editingTableId.set(null);
    this.tableForm.reset({ number: 1, capacity: 2 });
  }

  onTableSubmit(): void {
    if (this.tableForm.invalid || !this.shop()) return;
    const shopId = this.shop()!.id;
    const val = this.tableForm.getRawValue();
    const id = this.editingTableId();

    const op = id
      ? this.tableService.update(id, { ...val, shopId })
      : this.tableService.create({ ...val, shopId });

    op.subscribe(table => {
      this.shop.update(s => {
        if (!s) return s;
        const tables = id
          ? s.tables.map(t => t.id === id ? table : t)
          : [...s.tables, table];
        return { ...s, tables };
      });
      this.showTableForm.set(false);
      this.editingTableId.set(null);
    });
  }

  onEditTable(t: TableResponseDto): void {
    this.editingTableId.set(t.id);
    this.showTableForm.set(true);
    this.tableForm.patchValue({ number: t.number, capacity: t.capacity });
  }

  onDeleteTable(t: TableResponseDto): void {
    void this.dialog.confirm(`Delete table ${t.number}?`, { confirmLabel: 'Delete', confirmVariant: 'danger' }).then(ok => {
      if (!ok) return;
      this.tableService.delete(t.id).subscribe(() => {
        this.shop.update(s => s ? { ...s, tables: s.tables.filter(tb => tb.id !== t.id) } : s);
      });
    });
  }

  // --- Reservations ---
  eventLabel(item: { eventName?: string; eventId?: string }): string {
    return item.eventName ?? item.eventId ?? '—';
  }

  eventAvailabilityLabel(e: EventResponseDto): string {
    return formatEventAvailability(e);
  }

  tablesForRequest(req: ReservationRequestResponseDto): TableResponseDto[] {
    const shop = this.shop();
    if (!shop) return [];
    const reservedTableIds = new Set(
      this.reservations()
        .filter(r => !req.eventId || r.eventId === req.eventId)
        .map(r => r.table?.id)
        .filter(Boolean),
    );
    return shop.tables.filter(t => !reservedTableIds.has(t.id));
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

  onAcceptRequest(req: ReservationRequestResponseDto): void {
    const sel = this.selectedTableForRequest();
    if (!sel || sel.reqId !== req.id || !sel.tableId) {
      void this.dialog.alert('Please select a table first.');
      return;
    }
    const table = this.shop()?.tables.find(t => t.id === sel.tableId);
    this.requestService.accept(req.id, { tableId: sel.tableId }).subscribe({
      next: () => {
        const shopId = this.shop()?.id;
        if (shopId) {
          this.requestService.getAll(shopId).subscribe(reqs => this.allShopRequests.set(reqs));
          this.reservationService.getAll().subscribe(res => {
        this.reservations.set(res.filter(r => r.shop?.id === shopId));
      });
        }
      },
      error: err => void this.dialog.alert(getAcceptReservationErrorMessage(err, { partySize: req.partySize, tableCapacity: table?.capacity })),
    });
  }

  onDenyRequest(req: ReservationRequestResponseDto): void {
    void this.dialog.confirm('Deny this reservation request?', { confirmLabel: 'Deny', confirmVariant: 'danger' }).then(ok => {
      if (!ok) return;
      this.requestService.deny(req.id).subscribe(() => {
        const shopId = this.shop()?.id;
        if (shopId) {
          this.requestService.getAll(shopId).subscribe(reqs => this.allShopRequests.set(reqs));
        }
      });
    });
  }

  // --- Events ---
  openAddEventForm(): void {
    this.editingEventId.set(null);
    this.showEventForm.set(true);
    this.applyEventDateValidators();
    this.eventForm.reset({ eventName: '', eventDate: '', description: '' });
  }

  onEventSubmit(): void {
    if (this.eventForm.invalid || !this.shop()) return;
    const shopId = this.shop()!.id;
    const val = this.eventForm.getRawValue();
    const id = this.editingEventId();

    const op = id
      ? this.eventService.update(id, { ...val, shopId })
      : this.eventService.create({ ...val, shopId });

    op.subscribe(event => {
      this.shop.update(s => {
        if (!s) return s;
        const events = id
          ? s.events.map(e => e.eventId === id ? event : e)
          : [...s.events, event];
        return { ...s, events };
      });
      this.showEventForm.set(false);
      this.editingEventId.set(null);
    });
  }

  onEditEvent(e: EventResponseDto): void {
    this.editingEventId.set(e.eventId);
    this.applyEventDateValidators();
    this.showEventForm.set(true);
    this.eventForm.patchValue({ eventName: e.eventName, eventDate: normalizeDateTimeLocal(e.eventDate), description: e.description });
  }

  onDeleteEvent(e: EventResponseDto): void {
    void this.dialog.confirm(`Delete "${e.eventName}"?`, { confirmLabel: 'Delete', confirmVariant: 'danger' }).then(ok => {
      if (!ok) return;
      this.eventService.delete(e.eventId).subscribe(() => {
        this.shop.update(s => s ? { ...s, events: s.events.filter(ev => ev.eventId !== e.eventId) } : s);
      });
    });
  }

  cancelEventForm(): void {
    this.showEventForm.set(false);
    this.editingEventId.set(null);
    this.eventForm.reset({ eventName: '', eventDate: '', description: '' });
  }

  private applyEventDateValidators(): void {
    const dateControl = this.eventForm.controls.eventDate;
    if (this.editingEventId()) {
      dateControl.setValidators([Validators.required]);
    } else {
      dateControl.setValidators([Validators.required, futureDateValidator()]);
    }
    dateControl.updateValueAndValidity();
  }

  canShowReserveButton(e: EventResponseDto): boolean {
    if (!canReserveForEvent(e)) return false;
    return !this.blockedEventIdsForCurrentUser().has(e.eventId);
  }

  reserveTooltip(e: EventResponseDto): string {
    if (isEventFull(e)) return 'No tables left for this event';
    if (this.blockedEventIdsForCurrentUser().has(e.eventId)) return 'You already have a reservation request or reservation for this event';
    return `Reserve for ${e.eventName}`;
  }

  onReserveEventClick(e: EventResponseDto): void {
    this.selectedEventForRequest.set(e);
    this.eventRequestForm.patchValue({ partySize: 1 });
  }

  cancelEventRequest(): void {
    this.selectedEventForRequest.set(null);
    this.eventRequestForm.reset({ partySize: 1 });
  }

  onSubmitEventRequest(): void {
    if (this.eventRequestForm.invalid || !this.canSubmitEventRequest()) return;
    const profile = this.profileService.currentUser();
    if (!profile) return;
    const event = this.selectedEventForRequest();
    if (!event) return;
    const val = this.eventRequestForm.getRawValue();

    this.submittingEventRequest.set(true);
    this.requestService.create({ userId: profile.id, shopId: event.shopId, eventId: event.eventId, partySize: val.partySize }).subscribe({
      next: () => {
        this.submittingEventRequest.set(false);
        this.cancelEventRequest();
        this.activeTab.set('reservations');
        this.reservationSubTab.set('pending');
        const shopId = this.shop()?.id;
        if (shopId) this.requestService.getAll(shopId).subscribe(reqs => this.allShopRequests.set(reqs));
      },
      error: err => {
        this.submittingEventRequest.set(false);
        if (err instanceof HttpErrorResponse && err.status === 409) {
          void this.dialog.alert('You already have a reservation for this event or there are no tables left.');
        }
      },
    });
  }

  // --- Reviews ---
  canLeaveReview(): boolean {
    const profile = this.profileService.currentUser();
    if (!profile || !this.shop()) return false;
    if (this.canManageShopContent()) return false;
    return true;
  }

  toggleReviewForm(): void {
    this.showReviewForm.set(false);
    this.reviewForm.reset({ rating: 0, description: '', commentsEnabled: true });
  }

  onReviewSubmit(): void {
    if (this.reviewForm.invalid || !this.shop()) return;
    const shopId = this.shop()!.id;
    const val = this.reviewForm.getRawValue();
    this.reviewService.create({ ...val, shopId }).subscribe(review => {
      this.shop.update(s => s ? { ...s, reviews: [review, ...s.reviews], reviewCount: s.reviewCount + 1 } : s);
      this.toggleReviewForm();
    });
  }

  isReviewAuthor(r: ReviewResponseDto): boolean {
    const profile = this.profileService.currentUser();
    return !!profile && r.user.id === profile.id;
  }

  onCommentsEnabledChange(r: ReviewResponseDto, enabled: boolean): void {
    this.reviewService.update(r.id, { ...r, commentsEnabled: enabled }).subscribe(updated => {
      this.shop.update(s => s ? { ...s, reviews: s.reviews.map(rv => rv.id === updated.id ? updated : rv) } : s);
    });
  }

  onDeleteReview(r: ReviewResponseDto): void {
    void this.dialog.confirm('Delete this review?', { confirmLabel: 'Delete', confirmVariant: 'danger' }).then(ok => {
      if (!ok) return;
      this.reviewService.delete(r.id).subscribe(() => {
        this.shop.update(s => s ? {
          ...s,
          reviews: s.reviews.filter(rv => rv.id !== r.id),
          reviewCount: Math.max(0, s.reviewCount - 1),
        } : s);
      });
    });
  }

  formatAverageRating(shop: ShopResponseDto): string {
    return shop.averageRating?.toFixed(1) ?? '—';
  }

  roundedAverageRating(shop: ShopResponseDto): number {
    return Math.round(shop.averageRating ?? 0);
  }

  formatCommentDate(date: string): string {
    return new Date(date).toLocaleDateString();
  }

  commentDraft(reviewId: string): string {
    return this.commentDrafts()[reviewId] ?? '';
  }

  updateCommentDraft(reviewId: string, value: string): void {
    this.commentDrafts.update(prev => ({ ...prev, [reviewId]: value }));
  }

  onCommentSubmit(reviewId: string): void {
    const body = this.commentDraft(reviewId).trim();
    if (!body) return;
    this.reviewCommentService.create(reviewId, { body }).subscribe(comment => {
      this.shop.update(s => {
        if (!s) return s;
        return {
          ...s,
          reviews: s.reviews.map(r => r.id === reviewId ? { ...r, comments: [...(r.comments ?? []), comment] } : r),
        };
      });
      this.updateCommentDraft(reviewId, '');
    });
  }

  // --- Community ---
  private loadMembers(shopId: string): void {
    this.membersLoading.set(true);
    this.communityService.getMembers(
      shopId,
      this.membersPage(),
      10,
      this.membersSearchInput().trim() || undefined,
    ).subscribe({
      next: page => {
        this.members.set(page.content);
        this.membersTotalElements.set(page.totalElements);
        this.membersTotalPages.set(Math.max(1, page.totalPages));
        this.membersLoading.set(false);
      },
      error: () => this.membersLoading.set(false),
    });
  }

  onMembersSearchInput(inputEvent: Event): void {
    const value = (inputEvent.target as HTMLInputElement).value;
    this.membersSearchInput.set(value);
    const shopId = this.shop()?.id;
    if (shopId) {
      this.membersPage.set(0);
      this.loadMembers(shopId);
    }
  }

  goToMembersPage(page: number): void {
    const shopId = this.shop()?.id;
    if (!shopId || page < 0 || page >= this.membersTotalPages()) return;
    this.membersPage.set(page);
    this.loadMembers(shopId);
  }

  membersRangeLabel(): string {
    const total = this.membersTotalElements();
    if (total === 0) return '';
    const start = this.membersPage() * 10 + 1;
    const end = Math.min((this.membersPage() + 1) * 10, total);
    return `Showing ${start}–${end} of ${total}`;
  }

  membersEmptyStateMessage(): string {
    if (this.membersSearchInput().trim()) return 'No members match your search.';
    return 'No members yet.';
  }

  private loadCommunity(shopId: string): void {
    this.communityLoading.set(true);
    this.communityService.getPosts(shopId, 0, 5).subscribe({
      next: page => {
        this.communityPosts.set(page.content);
        this.communityHasMore.set(page.totalPages > 1);
        this.communityLoading.set(false);
      },
      error: () => this.communityLoading.set(false),
    });
  }

  loadMoreCommunityPosts(): void {
    const shopId = this.shop()?.id;
    const currentPage = this.communityPage();
    if (!shopId || this.communityLoading()) return;
    this.communityLoading.set(true);
    this.communityService.getPosts(shopId, currentPage + 1, 5).subscribe({
      next: page => {
        this.communityPosts.update(prev => [...prev, ...page.content]);
        this.communityPage.update(p => p + 1);
        this.communityHasMore.set(this.communityPage() < page.totalPages - 1);
        this.communityLoading.set(false);
      },
      error: () => this.communityLoading.set(false),
    });
  }

  onAnnouncementSubmit(): void {
    const shopId = this.shop()?.id;
    const body = this.announcementDraft().trim();
    if (!shopId || !body) return;
    this.postingAnnouncement.set(true);
    this.communityService.createAnnouncement(shopId, { body }).subscribe({
      next: (post: CommunityPostResponseDto) => {
        this.communityPosts.update(prev => [post, ...prev]);
        this.announcementDraft.set('');
        this.postingAnnouncement.set(false);
      },
      error: () => this.postingAnnouncement.set(false),
    });
  }

  canDeletePost(post: CommunityPostResponseDto): boolean {
    const profile = this.profileService.currentUser();
    return this.canManageShopContent() || (!!profile && post.author.id === profile.id);
  }

  onDeletePost(post: CommunityPostResponseDto): void {
    void this.dialog.confirm('Delete this post?', { confirmLabel: 'Delete', confirmVariant: 'danger' }).then(ok => {
      if (!ok) return;
      this.communityService.deletePost(post.shopId, post.id).subscribe(() => {
        this.communityPosts.update(prev => prev.filter(p => p.id !== post.id));
      });
    });
  }

  formatPostDate(date: string): string {
    return new Date(date).toLocaleString();
  }

  onLoyaltyPlanChange(plan: LoyaltyPlanResponseDto): void {
    this.shop.update(s => s ? { ...s, loyaltyPlan: plan } : s);
  }
}
