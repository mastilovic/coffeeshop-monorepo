import { Component, inject, signal, computed, OnInit, ChangeDetectionStrategy } from '@angular/core';
import { DecimalPipe } from '@angular/common';
import { RouterLink } from '@angular/router';
import { DashboardService } from '../../services/dashboard.service';
import { AuthService } from '../../services/auth.service';
import {
  DashboardActivityItem,
  DashboardAggregate,
  DashboardNotification,
  DashboardPersonalSummary,
  TopShopItem,
  UpcomingEventItem,
} from '../../models/dashboard.model';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [RouterLink, DecimalPipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="page">
      <div class="page-header">
        <h1 class="page-title">Dashboard</h1>
      </div>

      @if (loading()) {
        <div class="loading">Loading dashboard data...</div>
      } @else {
        <div class="stats-bar" aria-label="Summary statistics">
          <div class="stats-bar__item">
            <span class="stats-bar__icon" aria-hidden="true">&#9749;</span>
            <span class="stats-bar__value">{{ aggregate().shopCount }}</span>
            <span class="stats-bar__label">Shops</span>
          </div>
          <div class="stats-bar__item">
            <span class="stats-bar__icon" aria-hidden="true">&#11088;</span>
            <span class="stats-bar__value">{{ aggregate().reviewCount }}</span>
            <span class="stats-bar__label">
              Reviews
              @if (aggregate().averageRating !== null) {
                <span class="stats-bar__sublabel">avg {{ aggregate().averageRating | number:'1.1-1' }}</span>
              }
            </span>
          </div>
          <div class="stats-bar__item">
            <span class="stats-bar__icon" aria-hidden="true">&#128101;</span>
            <span class="stats-bar__value">{{ aggregate().memberCount }}</span>
            <span class="stats-bar__label">Members</span>
          </div>
          <div class="stats-bar__item">
            <span class="stats-bar__icon" aria-hidden="true">&#128197;</span>
            <span class="stats-bar__value">{{ aggregate().eventCount }}</span>
            <span class="stats-bar__label">Events</span>
          </div>
        </div>

        <div class="dashboard-layout">
          <section class="dashboard-main" aria-labelledby="activity-heading">
            <h2 id="activity-heading" class="section-title">Recent Activity</h2>

            @if (activities().length === 0) {
              <div class="activity-feed__empty">
                <p>No recent activity to show.</p>
                <p class="text-muted">Start exploring shops, write reviews, or join communities to see activity here.</p>
              </div>
            } @else {
              <div class="activity-list">
                @for (item of activities(); track item.timestamp + item.type + item.shopId) {
                  <div class="activity-item" [class]="'activity-item--' + item.type">
                    <div class="activity-item__content">
                      <div class="activity-item__header">
                        <a class="activity-item__shop" [routerLink]="['/shops', item.shopId]">{{ item.shopName }}</a>
                        <span class="activity-item__time">{{ relativeTime(item.timestamp) }}</span>
                      </div>
                      <p class="activity-item__title">{{ item.title }}</p>
                      @if (item.body) {
                        <p class="activity-item__body">{{ item.body }}</p>
                      }
                      <div class="activity-item__meta">
                        @if (item.rating !== undefined) {
                          <span class="activity-item__rating" [attr.aria-label]="'Rating: ' + item.rating + ' out of 5'">
                            @for (star of [1,2,3,4,5]; track star) {
                              <span class="activity-item__star" [class.filled]="star <= item.rating!">&#9733;</span>
                            }
                          </span>
                        }
                        @if (item.actorName) {
                          <span class="activity-item__actor">by {{ item.actorName }}</span>
                        }
                      </div>
                    </div>
                  </div>
                }
              </div>
            }
          </section>

          <aside class="dashboard-sidebar" aria-label="Dashboard widgets">
            @if (notifications().length > 0 && !isCustomer()) {
              <div class="widget">
                <div class="widget__header">
                  <h3 class="widget__title">Notifications</h3>
                  <span class="widget__badge">{{ notificationTotal() }}</span>
                </div>
                <ul class="widget-list">
                  @for (note of notifications(); track note.type) {
                    <li class="widget-list__item">
                      <a class="widget-list__link" [routerLink]="note.link">
                        <span class="widget-list__count">{{ note.count }}</span>
                        <span class="widget-list__text">{{ note.message }}</span>
                      </a>
                    </li>
                  }
                </ul>
              </div>
            }

            <div class="widget">
              <h3 class="widget__title">Upcoming Events</h3>
              @if (upcomingEvents().length === 0) {
                <p class="widget__empty">No upcoming events.</p>
              } @else {
                <ul class="widget-list">
                  @for (evt of upcomingEvents(); track evt.eventId) {
                    <li class="widget-list__item">
                      <a class="widget-list__link widget-list__link--stacked" [routerLink]="['/shops', evt.shopId]">
                        <span class="widget-list__primary">{{ evt.eventName }}</span>
                        <span class="widget-list__secondary">{{ formatEventDate(evt.eventDate) }} · {{ evt.shopName }}</span>
                      </a>
                    </li>
                  }
                </ul>
              }
            </div>

            <div class="widget">
              <h3 class="widget__title">Top Shops</h3>
              @if (topShops().length === 0) {
                <p class="widget__empty">No rated shops yet.</p>
              } @else {
                <ol class="widget-list widget-list--numbered">
                  @for (shop of topShops(); track shop.shopId; let i = $index) {
                    <li class="widget-list__item">
                      <a class="widget-list__link widget-list__link--stacked" [routerLink]="['/shops', shop.shopId]">
                        <span class="widget-list__primary">
                          <span class="widget-list__rank">{{ i + 1 }}.</span>
                          {{ shop.shopName }}
                        </span>
                        <span class="widget-list__secondary">
                          @if (shop.averageRating !== null) {
                            &#9733; {{ shop.averageRating | number:'1.1-1' }}
                          }
                          · {{ shop.reviewCount }} reviews
                          @if (shop.city) {
                            · {{ shop.city }}
                          }
                        </span>
                      </a>
                    </li>
                  }
                </ol>
              }
            </div>

            <div class="widget">
              <h3 class="widget__title">Your Summary</h3>
              <ul class="summary-list">
                <li class="summary-list__item">
                  <span class="summary-list__icon" aria-hidden="true">&#9829;</span>
                  <span class="summary-list__label">Favourites</span>
                  <span class="summary-list__value">{{ personalSummary().favouriteShops }}</span>
                </li>
                <li class="summary-list__item">
                  <span class="summary-list__icon" aria-hidden="true">&#128197;</span>
                  <span class="summary-list__label">Reservations</span>
                  <span class="summary-list__value">{{ personalSummary().reservations }}</span>
                </li>
                <li class="summary-list__item">
                  <span class="summary-list__icon" aria-hidden="true">&#11088;</span>
                  <span class="summary-list__label">Reviews written</span>
                  <span class="summary-list__value">{{ personalSummary().reviewsWritten }}</span>
                </li>
              </ul>
            </div>
          </aside>
        </div>
      }
    </div>
  `,
  styles: [`
    :host {
      display: block;
    }

    /* Slim inline stats bar */
    .stats-bar {
      display: flex;
      flex-wrap: wrap;
      gap: 1rem 1.5rem;
      padding: 0.625rem 0 1rem;
      margin-bottom: 1.25rem;
      border-bottom: 1px solid #2a2a3e;
    }

    .stats-bar__item {
      display: flex;
      align-items: center;
      gap: 0.375rem;
      min-width: 0;
    }

    .stats-bar__icon {
      font-size: 1rem;
      line-height: 1;
      flex-shrink: 0;
    }

    .stats-bar__value {
      font-size: 1rem;
      font-weight: 700;
      color: #d4a574;
    }

    .stats-bar__label {
      font-size: 0.75rem;
      color: #888;
      text-transform: uppercase;
      letter-spacing: 0.04em;
    }

    .stats-bar__sublabel {
      margin-left: 0.25rem;
      text-transform: none;
      letter-spacing: 0;
      color: #666;
      font-size: 0.7rem;
    }

    /* Two-column layout */
    .dashboard-layout {
      display: flex;
      flex-direction: column;
      gap: 1.5rem;
    }

    @media (min-width: 900px) {
      .dashboard-layout {
        flex-direction: row;
        align-items: flex-start;
        gap: 2rem;
      }
    }

    .dashboard-main {
      flex: 1;
      min-width: 0;
    }

    .dashboard-sidebar {
      display: flex;
      flex-direction: column;
      gap: 1rem;
      width: 100%;
    }

    @media (min-width: 900px) {
      .dashboard-sidebar {
        flex: 0 0 320px;
        max-width: 320px;
      }
    }

    .section-title {
      font-size: 1.125rem;
      font-weight: 700;
      color: #e0e0e0;
      margin: 0 0 1rem 0;
    }

    /* Activity feed */
    .activity-feed__empty {
      text-align: center;
      padding: 2.5rem 1rem;
      color: #aaa;
      border: 1px dashed #2a2a3e;
      border-radius: 12px;
    }

    .activity-feed__empty .text-muted {
      font-size: 0.875rem;
      color: #666;
      margin-top: 0.5rem;
    }

    .activity-list {
      display: flex;
      flex-direction: column;
      gap: 0;
      border-left: 2px solid #2a2a3e;
      padding-left: 1.25rem;
      margin-left: 0.25rem;
    }

    .activity-item {
      position: relative;
      padding: 0.875rem 0;
      border-bottom: 1px solid #1e1e30;
    }

    .activity-item:last-child {
      border-bottom: none;
    }

    .activity-item::before {
      content: '';
      position: absolute;
      left: -1.55rem;
      top: 1.1rem;
      width: 8px;
      height: 8px;
      border-radius: 50%;
      background: #2a2a3e;
      border: 2px solid #1a1a2e;
    }

    .activity-item--review::before { background: #e2b04a; }
    .activity-item--event::before { background: #4a90d9; }
    .activity-item--community_post::before { background: #4caf50; }

    .activity-item__content {
      display: flex;
      flex-direction: column;
      gap: 0.3rem;
    }

    .activity-item__header {
      display: flex;
      justify-content: space-between;
      align-items: baseline;
      flex-wrap: wrap;
      gap: 0.375rem;
    }

    .activity-item__shop {
      font-weight: 600;
      color: #d4a574;
      text-decoration: none;
      font-size: 0.875rem;
    }

    .activity-item__shop:hover {
      text-decoration: underline;
    }

    .activity-item__time {
      font-size: 0.7rem;
      color: #666;
      white-space: nowrap;
    }

    .activity-item__title {
      margin: 0;
      font-size: 0.9rem;
      color: #e0e0e0;
      font-weight: 500;
    }

    .activity-item__body {
      margin: 0;
      font-size: 0.8rem;
      color: #999;
      line-height: 1.4;
    }

    .activity-item__meta {
      display: flex;
      align-items: center;
      gap: 0.625rem;
      flex-wrap: wrap;
    }

    .activity-item__rating {
      display: inline-flex;
      gap: 1px;
    }

    .activity-item__star {
      color: #333;
      font-size: 0.8rem;
    }

    .activity-item__star.filled {
      color: #e2b04a;
    }

    .activity-item__actor {
      font-size: 0.75rem;
      color: #777;
    }

    /* Sidebar widgets */
    .widget {
      background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
      border: 1px solid #2a2a3e;
      border-radius: 10px;
      padding: 0.875rem 1rem;
    }

    .widget__header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 0.5rem;
      margin-bottom: 0.625rem;
    }

    .widget__title {
      margin: 0 0 0.625rem 0;
      font-size: 0.8rem;
      font-weight: 700;
      color: #ccc;
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }

    .widget__header .widget__title {
      margin-bottom: 0;
    }

    .widget__badge {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      min-width: 1.25rem;
      height: 1.25rem;
      padding: 0 0.375rem;
      border-radius: 999px;
      background: #c0392b;
      color: #fff;
      font-size: 0.7rem;
      font-weight: 700;
    }

    .widget__empty {
      margin: 0;
      font-size: 0.8rem;
      color: #666;
    }

    .widget-list {
      list-style: none;
      margin: 0;
      padding: 0;
      display: flex;
      flex-direction: column;
      gap: 0.375rem;
    }

    .widget-list--numbered {
      list-style: none;
    }

    .widget-list__item {
      margin: 0;
    }

    .widget-list__link {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      padding: 0.375rem 0;
      text-decoration: none;
      color: inherit;
      border-radius: 6px;
      transition: background 0.15s;
    }

    .widget-list__link:hover {
      background: rgba(212, 165, 116, 0.06);
    }

    .widget-list__link--stacked {
      flex-direction: column;
      align-items: flex-start;
      gap: 0.125rem;
    }

    .widget-list__count {
      flex-shrink: 0;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      min-width: 1.5rem;
      height: 1.5rem;
      border-radius: 6px;
      background: rgba(212, 165, 116, 0.15);
      color: #d4a574;
      font-size: 0.75rem;
      font-weight: 700;
    }

    .widget-list__text {
      font-size: 0.8rem;
      color: #bbb;
      line-height: 1.3;
    }

    .widget-list__primary {
      font-size: 0.85rem;
      color: #e0e0e0;
      font-weight: 500;
      line-height: 1.3;
    }

    .widget-list__secondary {
      font-size: 0.75rem;
      color: #777;
      line-height: 1.3;
    }

    .widget-list__rank {
      color: #d4a574;
      margin-right: 0.25rem;
    }

    /* Personal summary */
    .summary-list {
      list-style: none;
      margin: 0;
      padding: 0;
      display: flex;
      flex-direction: column;
      gap: 0.5rem;
    }

    .summary-list__item {
      display: flex;
      align-items: center;
      gap: 0.5rem;
    }

    .summary-list__icon {
      font-size: 0.9rem;
      width: 1.25rem;
      text-align: center;
      flex-shrink: 0;
    }

    .summary-list__label {
      flex: 1;
      font-size: 0.8rem;
      color: #aaa;
    }

    .summary-list__value {
      font-size: 0.9rem;
      font-weight: 700;
      color: #d4a574;
    }

    @media (max-width: 640px) {
      .stats-bar {
        gap: 0.75rem 1rem;
      }

      .stats-bar__label {
        display: none;
      }

      .activity-item__header {
        flex-direction: column;
        gap: 0.125rem;
      }
    }
  `],
})
export class DashboardComponent implements OnInit {
  private readonly dashboardService = inject(DashboardService);
  private readonly authService = inject(AuthService);

  readonly isCustomer = computed(() => this.authService.realmRoles().includes('customer'));

  readonly loading = signal(true);
  readonly aggregate = signal<DashboardAggregate>({
    shopCount: 0,
    reviewCount: 0,
    averageRating: null,
    eventCount: 0,
    memberCount: 0,
  });
  readonly activities = signal<DashboardActivityItem[]>([]);
  readonly topShops = signal<TopShopItem[]>([]);
  readonly upcomingEvents = signal<UpcomingEventItem[]>([]);
  readonly personalSummary = signal<DashboardPersonalSummary>({
    favouriteShops: 0,
    reservations: 0,
    reviewsWritten: 0,
  });
  readonly notifications = signal<DashboardNotification[]>([]);

  ngOnInit(): void {
    this.dashboardService.getActivity().subscribe({
      next: (response) => {
        this.aggregate.set(response.aggregate);
        this.activities.set(response.activities ?? []);
        this.topShops.set(response.topShops ?? []);
        this.upcomingEvents.set(response.upcomingEvents ?? []);
        this.personalSummary.set(response.personalSummary ?? {
          favouriteShops: 0,
          reservations: 0,
          reviewsWritten: 0,
        });
        this.notifications.set(response.notifications ?? []);
        this.loading.set(false);
      },
      error: () => this.loading.set(false),
    });
  }

  notificationTotal(): number {
    return this.notifications().reduce((sum, n) => sum + n.count, 0);
  }

  formatEventDate(dateStr: string): string {
    const date = new Date(dateStr);
    if (Number.isNaN(date.getTime())) {
      return dateStr;
    }
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
  }

  relativeTime(timestamp: string): string {
    const now = new Date();
    const date = new Date(timestamp);
    const diffMs = now.getTime() - date.getTime();

    if (diffMs < 0) {
      const diffMsFuture = date.getTime() - now.getTime();
      const daysFuture = Math.floor(diffMsFuture / 86400000);
      if (daysFuture === 0) return 'Today';
      if (daysFuture === 1) return 'Tomorrow';
      if (daysFuture < 7) return `In ${daysFuture} days`;
      if (daysFuture < 30) return `In ${Math.ceil(daysFuture / 7)} weeks`;
      return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
    }

    const seconds = Math.floor(diffMs / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);

    if (seconds < 60) return 'Just now';
    if (minutes < 60) return `${minutes}m ago`;
    if (hours < 24) return `${hours}h ago`;
    if (days === 1) return 'Yesterday';
    if (days < 7) return `${days}d ago`;
    if (days < 30) return `${Math.ceil(days / 7)}w ago`;
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
  }
}
