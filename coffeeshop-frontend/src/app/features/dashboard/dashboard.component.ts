import { Component, inject, signal, OnInit, ChangeDetectionStrategy } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { forkJoin } from 'rxjs';
import { environment } from '../../../environments/environment';
import { ShopResponseDto } from '../../models/shop.model';
import { PageResponseDto, EventResponseDto } from '../../models/event.model';
import { MenuItemResponseDto } from '../../models/menu.model';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="page">
      <div class="page-header">
        <h1 class="page-title">Dashboard</h1>
      </div>

      @if (loading()) {
        <div class="loading">Loading dashboard data...</div>
      } @else {
        <div class="card-grid">
          <div class="stat-card">
            <div class="stat-value">{{ shopCount() }}</div>
            <div class="stat-label">Coffee Shops</div>
          </div>
          <div class="stat-card">
            <div class="stat-value">{{ menuItemCount() }}</div>
            <div class="stat-label">Menu Items</div>
          </div>
          <div class="stat-card">
            <div class="stat-value">{{ eventCount() }}</div>
            <div class="stat-label">Events</div>
          </div>
        </div>
      }
    </div>
  `,
})
export class DashboardComponent implements OnInit {
  private readonly http = inject(HttpClient);
  private readonly api = environment.apiUrl;

  readonly loading = signal(true);
  readonly shopCount = signal(0);
  readonly menuItemCount = signal(0);
  readonly eventCount = signal(0);

  ngOnInit(): void {
    forkJoin({
      shops: this.http.get<ShopResponseDto[]>(`${this.api}/api/v2/shop`),
      events: this.http.get<PageResponseDto<EventResponseDto>>(`${this.api}/api/v2/event`, {
        params: { page: '0', size: '1' },
      }),
      menuItems: this.http.get<MenuItemResponseDto[]>(`${this.api}/api/v2/menu-item`),
    }).subscribe({
      next: ({ shops, events, menuItems }) => {
        this.shopCount.set(shops.length);
        this.eventCount.set(events.totalElements);
        this.menuItemCount.set(menuItems.length);
        this.loading.set(false);
      },
      error: () => this.loading.set(false),
    });
  }
}
