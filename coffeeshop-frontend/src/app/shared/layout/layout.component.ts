import { Component, inject, signal, OnInit, ChangeDetectionStrategy } from '@angular/core';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { ProfileService } from '../../services/profile.service';
import { DialogHostComponent } from '../dialog-host/dialog-host.component';

@Component({
  selector: 'app-layout',
  standalone: true,
  imports: [RouterOutlet, RouterLink, RouterLinkActive, DialogHostComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="layout" [class.sidebar-collapsed]="sidebarCollapsed()">
      <aside class="sidebar">
        <div class="sidebar-header">
          <span class="sidebar-logo">&#9749;</span>
          @if (!sidebarCollapsed()) {
            <span class="sidebar-brand">CoffeeShop</span>
          }
          <button class="sidebar-toggle" (click)="sidebarCollapsed.set(!sidebarCollapsed())">
            {{ sidebarCollapsed() ? '&#9654;' : '&#9664;' }}
          </button>
        </div>

        <nav class="sidebar-nav">
          @for (item of navItems; track item.path) {
            <a [routerLink]="item.path" routerLinkActive="active" [routerLinkActiveOptions]="{ exact: item.exact }" class="nav-item">
              <span class="nav-icon">{{ item.icon }}</span>
              @if (!sidebarCollapsed()) {
                <span class="nav-label">{{ item.label }}</span>
              }
            </a>
          }
        </nav>
      </aside>

      <div class="main-wrapper">
        <header class="topbar">
          <div class="topbar-left"></div>
          <div class="topbar-right">
            <div class="profile-menu" (click)="profileOpen.set(!profileOpen())">
              <span class="profile-username">{{ profileService.currentUser()?.username ?? 'User' }}</span>
              <span class="profile-caret">&#9662;</span>

              @if (profileOpen()) {
                <div class="dropdown">
                  <a routerLink="/profile" class="dropdown-item" (click)="profileOpen.set(false)">Profile</a>
                  <button class="dropdown-item" (click)="onLogout()">Logout</button>
                </div>
              }
            </div>
          </div>
        </header>

        <main class="content">
          <router-outlet />
        </main>
      </div>
    </div>
    <app-dialog-host />
  `,
  styles: [`
    .layout {
      display: flex;
      height: 100vh;
      overflow: hidden;
    }

    .sidebar {
      width: 240px;
      background: #1a1a2e;
      border-right: 1px solid #2a2a3e;
      display: flex;
      flex-direction: column;
      transition: width 0.2s;
      flex-shrink: 0;
    }
    .sidebar-collapsed .sidebar {
      width: 64px;
    }

    .sidebar-header {
      display: flex;
      align-items: center;
      gap: 0.75rem;
      padding: 1.25rem;
      border-bottom: 1px solid #2a2a3e;
    }
    .sidebar-logo {
      font-size: 1.5rem;
    }
    .sidebar-brand {
      font-weight: 700;
      font-size: 1.125rem;
      color: #d4a574;
      white-space: nowrap;
    }
    .sidebar-toggle {
      margin-left: auto;
      background: none;
      border: none;
      color: #888;
      cursor: pointer;
      font-size: 0.75rem;
      padding: 0.25rem;
    }

    .sidebar-nav {
      flex: 1;
      padding: 0.75rem 0.5rem;
      display: flex;
      flex-direction: column;
      gap: 0.25rem;
      overflow-y: auto;
    }

    .nav-item {
      display: flex;
      align-items: center;
      gap: 0.75rem;
      padding: 0.75rem 1rem;
      border-radius: 8px;
      color: #aaa;
      text-decoration: none;
      font-size: 0.9375rem;
      transition: background 0.15s, color 0.15s;
      white-space: nowrap;
    }
    .nav-item:hover {
      background: #16213e;
      color: #e0e0e0;
      text-decoration: none;
    }
    .nav-item.active {
      background: rgba(212, 165, 116, 0.1);
      color: #d4a574;
    }
    .nav-icon {
      font-size: 1.125rem;
      width: 1.5rem;
      text-align: center;
      flex-shrink: 0;
    }

    .main-wrapper {
      flex: 1;
      display: flex;
      flex-direction: column;
      overflow: hidden;
    }

    .topbar {
      height: 56px;
      background: #1a1a2e;
      border-bottom: 1px solid #2a2a3e;
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0 1.5rem;
      flex-shrink: 0;
    }

    .profile-menu {
      position: relative;
      display: flex;
      align-items: center;
      gap: 0.5rem;
      cursor: pointer;
      padding: 0.5rem 0.75rem;
      border-radius: 8px;
      transition: background 0.15s;
    }
    .profile-menu:hover {
      background: #16213e;
    }
    .profile-username {
      font-size: 0.875rem;
      color: #e0e0e0;
    }
    .profile-caret {
      font-size: 0.625rem;
      color: #888;
    }

    .dropdown {
      position: absolute;
      top: 100%;
      right: 0;
      margin-top: 0.25rem;
      background: #1a1a2e;
      border: 1px solid #2a2a3e;
      border-radius: 8px;
      min-width: 160px;
      padding: 0.375rem;
      z-index: 100;
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.4);
    }
    .dropdown-item {
      display: block;
      width: 100%;
      padding: 0.625rem 0.875rem;
      background: none;
      border: none;
      color: #e0e0e0;
      font-size: 0.875rem;
      font-family: inherit;
      text-align: left;
      text-decoration: none;
      border-radius: 6px;
      cursor: pointer;
      transition: background 0.15s;
    }
    .dropdown-item:hover {
      background: #16213e;
      text-decoration: none;
    }

    .content {
      flex: 1;
      overflow-y: auto;
    }
  `],
})
export class LayoutComponent implements OnInit {
  readonly authService = inject(AuthService);
  readonly profileService = inject(ProfileService);

  readonly sidebarCollapsed = signal(false);
  readonly profileOpen = signal(false);

  readonly navItems = [
    { path: '/dashboard', label: 'Dashboard', icon: '📊', exact: true },
    { path: '/events', label: 'Events', icon: '📅', exact: false },
    { path: '/reservations', label: 'My Reservations', icon: '🪑', exact: false },
    { path: '/users', label: 'Users', icon: '👥', exact: false },
    { path: '/shops', label: 'Shops', icon: '☕', exact: false },
  ];

  ngOnInit(): void {
    if (this.authService.isAuthenticated()) {
      this.profileService.getProfile().subscribe();
    }
  }

  onLogout(): void {
    this.profileService.clearProfile();
    this.authService.logout();
  }
}
