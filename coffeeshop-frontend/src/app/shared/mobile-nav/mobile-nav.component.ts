import { Component, ChangeDetectionStrategy } from '@angular/core';
import { RouterLink, RouterLinkActive } from '@angular/router';

@Component({
  selector: 'app-mobile-nav',
  standalone: true,
  imports: [RouterLink, RouterLinkActive],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <nav class="mobile-nav" aria-label="Mobile navigation">
      @for (item of navItems; track item.path) {
        <a
          [routerLink]="[item.path]"
          routerLinkActive="mobile-nav__item--active"
          [routerLinkActiveOptions]="{ exact: item.exact }"
          class="mobile-nav__item"
          [attr.aria-label]="item.label"
        >
          <span class="mobile-nav__icon" aria-hidden="true">{{ item.icon }}</span>
          <span class="mobile-nav__label">{{ item.label }}</span>
        </a>
      }
    </nav>
  `,
  styles: [`
    .mobile-nav {
      display: none;
      position: fixed;
      bottom: 0;
      left: 0;
      right: 0;
      z-index: 200;
      height: calc(56px + env(safe-area-inset-bottom, 0px));
      padding-bottom: env(safe-area-inset-bottom, 0px);
      background: rgba(26, 26, 46, 0.92);
      backdrop-filter: blur(20px);
      -webkit-backdrop-filter: blur(20px);
      border-top: 1px solid rgba(42, 42, 62, 0.8);
      flex-direction: row;
      justify-content: space-around;
      align-items: center;
    }

    .mobile-nav__item {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      gap: 2px;
      min-width: 44px;
      min-height: 44px;
      padding: 4px 8px;
      border-radius: 10px;
      color: #888;
      text-decoration: none;
      transition: color 0.2s, background 0.2s;
      position: relative;
      -webkit-tap-highlight-color: transparent;
      user-select: none;
    }

    .mobile-nav__item:hover {
      color: #e0e0e0;
      text-decoration: none;
      background: rgba(255, 255, 255, 0.05);
    }

    .mobile-nav__item:active {
      transform: scale(0.92);
    }

    .mobile-nav__item--active {
      color: #d4a574;
    }

    .mobile-nav__item--active::before {
      content: '';
      position: absolute;
      top: 0;
      left: 50%;
      transform: translateX(-50%);
      width: 24px;
      height: 3px;
      border-radius: 0 0 3px 3px;
      background: #d4a574;
    }

    .mobile-nav__icon {
      font-size: 1.35rem;
      line-height: 1;
      transition: transform 0.2s;
    }

    .mobile-nav__item--active .mobile-nav__icon {
      transform: translateY(-1px);
    }

    .mobile-nav__label {
      font-size: 0.625rem;
      font-weight: 500;
      letter-spacing: 0.02em;
      line-height: 1;
    }

    @media (max-width: 768px) {
      .mobile-nav {
        display: flex;
      }
    }
  `],
})
export class MobileNavComponent {
  readonly navItems = [
    { path: '/dashboard', label: 'Home', icon: '🏠', exact: true },
    { path: '/events', label: 'Events', icon: '📅', exact: false },
    { path: '/reservations', label: 'Reserv.', icon: '🪑', exact: false },
    { path: '/shops', label: 'Shops', icon: '☕', exact: false },
    { path: '/users', label: 'Users', icon: '👥', exact: false },
  ];
}
