---
name: dashboard-global-scope-fix
overview: Remove user-specific shop scoping from the dashboard so that aggregate stats, recent activity, upcoming events, and top shops show global data to all users. Keep personal summary user-specific. Hide notifications for customers.
todos:
  - id: backend-simplify-scope
    content: Simplify resolveShopScope to always return all shop IDs for all users
    status: completed
  - id: backend-skip-notifications-customer
    content: Pass user type to buildResponse and skip computeNotifications for CUSTOMER users
    status: completed
  - id: frontend-hide-notifications-customer
    content: Inject AuthService in dashboard component and hide notifications widget for customers
    status: completed
isProject: false
---

# Dashboard Global Scope Fix

## Problem
The dashboard's `resolveShopScope` function filters shop data based on user role. For CUSTOMER users, scope = favourited shops + reviewed shops. A new customer with no favourites or reviews gets an empty scope, causing all dashboard sections (except personal summary) to show empty.

## Solution
Make all dashboard sections global (all shops) for all users. Only `personalSummary` remains user-specific. Notifications are hidden for customers.

### Backend Changes

**File: `coffeeshop-go/internal/handler/dashboard.go`**

1. **Simplify `resolveShopScope`** (lines 112-146): Remove the role-based switch. Always return ALL shop IDs (what admin currently gets). The function becomes a simple query: `SELECT id FROM shop`.

2. **Modify `GetActivity` handler** (lines 95-110): Pass the user type (from `auth.User.UserType`) to `buildResponse` so it can decide whether to include notifications.

3. **Modify `buildResponse`** (lines 148-168): Accept the user type. Skip `computeNotifications` when the user is a CUSTOMER (return empty slice). Everything else uses the full shop scope.

### Frontend Changes

**File: `coffeeshop-frontend/src/app/features/dashboard/dashboard.component.ts`**

1. **Inject `AuthService`**: Add `private readonly authService = inject(AuthService)`.
2. **Add `isCustomer` computed**: `readonly isCustomer = computed(() => this.authService.realmRoles().includes('customer'))`.
3. **Hide notifications for customers**: Change the notifications template guard from `@if (notifications().length > 0)` to `@if (notifications().length > 0 && !isCustomer())`. This provides defense-in-depth alongside the backend change.

## No New Files
All changes are modifications to two existing files.