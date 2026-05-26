import {
  Component,
  inject,
  signal,
  OnInit,
  OnDestroy,
  ChangeDetectionStrategy,
  PLATFORM_ID,
} from '@angular/core';
import { isPlatformBrowser } from '@angular/common';
import { NavigationEnd, Router, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { filter, Subscription } from 'rxjs';
import { AuthService } from '../../services/auth.service';
import { ProfileService } from '../../services/profile.service';
import { DialogHostComponent } from '../dialog-host/dialog-host.component';

@Component({
  selector: 'app-layout',
  standalone: true,
  imports: [RouterOutlet, RouterLink, RouterLinkActive, DialogHostComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div
      class="layout"
      [class.sidebar-collapsed]="sidebarCollapsed() && !mobileNavOpen()"
      [class.mobile-nav-open]="mobileNavOpen()"
    >
      @if (mobileNavOpen()) {
        <button
          type="button"
          class="sidebar-backdrop"
          aria-label="Close navigation menu"
          (click)="closeMobileNav()"
        ></button>
      }

      <aside class="sidebar">
        <div class="sidebar-header">
          <span class="sidebar-logo">&#9749;</span>
          @if (!sidebarCollapsed() || mobileNavOpen()) {
            <span class="sidebar-brand">CoffeeShop</span>
          }
          <button
            type="button"
            class="sidebar-toggle"
            aria-label="Collapse sidebar"
            (click)="sidebarCollapsed.set(!sidebarCollapsed())"
          >
            {{ sidebarCollapsed() ? '&#9654;' : '&#9664;' }}
          </button>
          <button
            type="button"
            class="sidebar-close"
            aria-label="Close navigation menu"
            (click)="closeMobileNav()"
          >
            &#10005;
          </button>
        </div>

        <nav class="sidebar-nav">
          @for (item of navItems; track item.path) {
            <a
              [routerLink]="item.path"
              routerLinkActive="active"
              [routerLinkActiveOptions]="{ exact: item.exact }"
              class="nav-item"
              (click)="closeMobileNav()"
            >
              <span class="nav-icon">{{ item.icon }}</span>
              @if (!sidebarCollapsed() || mobileNavOpen()) {
                <span class="nav-label">{{ item.label }}</span>
              }
            </a>
          }
        </nav>
      </aside>

      <div class="main-wrapper">
        <header class="topbar">
          <div class="topbar-left">
            <button
              type="button"
              class="mobile-menu-btn"
              aria-label="Open navigation menu"
              [attr.aria-expanded]="mobileNavOpen()"
              (click)="toggleMobileNav()"
            >
              <span class="mobile-menu-icon" aria-hidden="true"></span>
            </button>
            <span class="topbar-brand">&#9749; CoffeeShop</span>
          </div>
          <div class="topbar-right">
            <div class="profile-menu" (click)="profileOpen.set(!profileOpen())">
              <span class="profile-username">{{ profileService.currentUser()?.username ?? 'User' }}</span>
              <span class="profile-caret">&#9662;</span>

              @if (profileOpen()) {
                <div class="dropdown">
                  <a routerLink="/profile" class="dropdown-item" (click)="profileOpen.set(false); closeMobileNav()">Profile</a>
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

    .sidebar-backdrop {
      display: none;
    }

    .sidebar {
      width: 240px;
      background: #1a1a2e;
      border-right: 1px solid #2a2a3e;
      display: flex;
      flex-direction: column;
      transition: width 0.2s, transform 0.25s ease;
      flex-shrink: 0;
      z-index: 200;
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
    .sidebar-close {
      display: none;
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
      min-width: 0;
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

    .topbar-left {
      display: flex;
      align-items: center;
      gap: 0.75rem;
      min-width: 0;
    }

    .mobile-menu-btn {
      display: none;
      align-items: center;
      justify-content: center;
      width: 2.5rem;
      height: 2.5rem;
      padding: 0;
      background: none;
      border: 1px solid #2a2a3e;
      border-radius: 8px;
      color: #e0e0e0;
      cursor: pointer;
    }
    .mobile-menu-btn:hover {
      background: #16213e;
    }

    .mobile-menu-icon,
    .mobile-menu-icon::before,
    .mobile-menu-icon::after {
      display: block;
      width: 1.125rem;
      height: 2px;
      background: currentColor;
      border-radius: 1px;
    }
    .mobile-menu-icon {
      position: relative;
    }
    .mobile-menu-icon::before,
    .mobile-menu-icon::after {
      content: '';
      position: absolute;
      left: 0;
    }
    .mobile-menu-icon::before {
      top: -5px;
    }
    .mobile-menu-icon::after {
      top: 5px;
    }

    .topbar-brand {
      display: none;
      font-weight: 700;
      font-size: 1rem;
      color: #d4a574;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
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
      max-width: 8rem;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
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
      overflow-x: clip;
      -webkit-overflow-scrolling: touch;
    }

    @media (max-width: 768px) {
      .sidebar-backdrop {
        display: block;
        position: fixed;
        inset: 0;
        z-index: 150;
        background: rgba(0, 0, 0, 0.55);
        border: none;
        cursor: pointer;
      }

      .sidebar {
        position: fixed;
        top: 0;
        left: 0;
        bottom: 0;
        width: 260px !important;
        transform: translateX(-100%);
        box-shadow: 8px 0 32px rgba(0, 0, 0, 0.45);
      }

      .layout.mobile-nav-open .sidebar {
        transform: translateX(0);
      }

      .sidebar-toggle {
        display: none;
      }

      .sidebar-close {
        display: block;
        margin-left: auto;
        background: none;
        border: none;
        color: #888;
        cursor: pointer;
        font-size: 1rem;
        padding: 0.25rem;
        line-height: 1;
      }

      .mobile-menu-btn {
        display: inline-flex;
      }

      .topbar-brand {
        display: inline;
      }

      .topbar {
        padding: 0 1rem;
      }

      .profile-username {
        max-width: 6rem;
      }
    }
  `],
})
export class LayoutComponent implements OnInit, OnDestroy {
  readonly authService = inject(AuthService);
  readonly profileService = inject(ProfileService);
  private readonly router = inject(Router);
  private readonly platformId = inject(PLATFORM_ID);

  readonly sidebarCollapsed = signal(false);
  readonly profileOpen = signal(false);
  readonly mobileNavOpen = signal(false);

  private navSubscription?: Subscription;
  private mediaQuery?: MediaQueryList;
  private mediaQueryListener?: () => void;

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

    this.navSubscription = this.router.events
      .pipe(filter((event) => event instanceof NavigationEnd))
      .subscribe(() => this.closeMobileNav());

    if (isPlatformBrowser(this.platformId)) {
      this.mediaQuery = window.matchMedia('(min-width: 769px)');
      this.mediaQueryListener = () => {
        if (this.mediaQuery?.matches) {
          this.closeMobileNav();
        }
      };
      this.mediaQuery.addEventListener('change', this.mediaQueryListener);
    }
  }

  ngOnDestroy(): void {
    this.navSubscription?.unsubscribe();
    if (this.mediaQuery && this.mediaQueryListener) {
      this.mediaQuery.removeEventListener('change', this.mediaQueryListener);
    }
  }

  toggleMobileNav(): void {
    this.mobileNavOpen.update((open) => !open);
    if (this.mobileNavOpen()) {
      this.profileOpen.set(false);
    }
  }

  closeMobileNav(): void {
    this.mobileNavOpen.set(false);
  }

  onLogout(): void {
    this.profileService.clearProfile();
    this.authService.logout();
  }
}
