import { Routes } from '@angular/router';
import { authGuard } from './services/auth.guard';
import { adminGuard } from './services/admin.guard';
import { guestGuard } from './services/guest.guard';

export const routes: Routes = [
  {
    path: 'login',
    loadComponent: () => import('./features/auth/login.component').then(m => m.LoginComponent),
    canActivate: [guestGuard],
  },
  {
    path: 'register',
    loadComponent: () => import('./features/auth/register.component').then(m => m.RegisterComponent),
    canActivate: [guestGuard],
  },
  {
    path: '',
    loadComponent: () => import('./shared/layout/layout.component').then(m => m.LayoutComponent),
    canActivate: [authGuard],
    children: [
      { path: 'dashboard', loadComponent: () => import('./features/dashboard/dashboard.component').then(m => m.DashboardComponent) },
      { path: 'events', loadComponent: () => import('./features/events/events.component').then(m => m.EventsComponent) },
      { path: 'reservations', loadComponent: () => import('./features/reservations/reservations.component').then(m => m.ReservationsComponent) },
      { path: 'users', loadComponent: () => import('./features/users/users.component').then(m => m.UsersComponent) },
      { path: 'shops', loadComponent: () => import('./features/shops/shops.component').then(m => m.ShopsComponent) },
      { path: 'shops/:id', loadComponent: () => import('./features/shop-details/shop-details.component').then(m => m.ShopDetailsComponent) },
      { path: 'profile', loadComponent: () => import('./features/profile/profile.component').then(m => m.ProfileComponent) },
      { path: 'profile/billing', loadComponent: () => import('./features/profile/billing/billing.component').then(m => m.BillingComponent) },
      {
        path: 'profile/billing/custom',
        loadComponent: () =>
          import('./features/billing/custom-plan-builder.component').then(
            m => m.CustomPlanBuilderComponent,
          ),
      },
      {
        path: 'admin/subscription-pricing',
        loadComponent: () =>
          import('./features/admin/subscription-pricing/subscription-pricing.component').then(
            m => m.SubscriptionPricingComponent,
          ),
        canActivate: [adminGuard],
      },
      {
        path: 'admin/subscriptions',
        loadComponent: () =>
          import('./features/admin/subscriptions/subscriptions-admin.component').then(
            m => m.SubscriptionsAdminComponent,
          ),
        canActivate: [adminGuard],
      },
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
    ],
  },
  { path: '**', redirectTo: '' },
];
