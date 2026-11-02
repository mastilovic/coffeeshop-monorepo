---
name: role-visibility-consolidation
overview: Consolidate 11+ role-check patterns into a single UserRole enum + permissions provider, fix EventCreateScreen critical bug (customers can submit events), implement profile edit API and stats, filter dashboard notifications by role, and add route-level guards.
todos:
  - id: create-role-enum
    content: Create UserRole enum with fromString, displayName, displayColor in lib/core/auth/user_role.dart
    status: completed
  - id: create-permissions
    content: Create UserPermissions class + userPermissionsProvider in lib/core/auth/user_permissions.dart
    status: completed
  - id: update-auth-state
    content: Add computed UserRole getter to AuthState in auth_notifier.dart
    status: completed
  - id: add-route-guards
    content: Add role-based route guards in app_router.dart for /events/new and /shops/new
    status: completed
  - id: refactor-events
    content: Refactor event_create_screen.dart, event_list_screen.dart, event_detail_screen.dart, event_providers.dart to use UserPermissions
    status: completed
  - id: refactor-shops
    content: Refactor shop_list_screen.dart, shop_create_screen.dart, shop_manage_permission.dart, shop_detail_screen.dart to use UserPermissions
    status: completed
  - id: refactor-reservations
    content: Refactor reservation_providers.dart and reservation_list_screen.dart to use UserPermissions
    status: completed
  - id: refactor-users
    content: Refactor user_list_screen.dart to use UserRole.displayColor and permissions.isAdmin
    status: completed
  - id: refactor-deprecate
    content: Move normalizeUserType logic into UserRole.fromString, deprecate extensions.dart version
    status: completed
  - id: fix-profile-edit
    content: Wire up real profile edit API call in profile_screen.dart _saveProfile()
    status: completed
  - id: fix-profile-stats
    content: Wire up real stats (favourites, reservations, reviews) in profile_screen.dart stats row
    status: completed
  - id: filter-dashboard
    content: Filter owner-only notifications from dashboard for customers
    status: completed
  - id: add-owner-label
    content: Add 'Your Shop' label to ShopCard when isOwned is true
    status: completed
  - id: verify
    content: Verify all screens against role matrix after refactor
    status: completed
isProject: false
---

# Role Visibility Consolidation & Bug Fixes

## Problem

The coffeeshop-mobile app uses 11+ distinct patterns to check user roles — raw string comparisons against `'admin'`, `'shop_owner'`, `'customer'` scattered across 15+ files. There are no route-level guards. A critical bug allows customers to submit events with no `shopId`. Profile edit is a `TODO` stub and stats are hardcoded `"--"`.

## Files to Create

### 1. `lib/core/auth/user_role.dart` — UserRole enum

Convert the flat `userType` string into a proper enum with a `fromString` factory:

```dart
enum UserRole { customer, shop_owner, admin }
```

- Factory `UserRole.fromString(String raw)` delegates to `normalizeUserType()`
- Extension `displayName` returns human-readable label (e.g., `'Shop Owner'`)
- Extension `displayColor` returns the color currently in `_colorForType()`

### 2. `lib/core/auth/user_permissions.dart` — Permissions class

A single immutable class computed from the current user profile. Exposed via a Riverpod `Provider`:

```dart
class UserPermissions {
  final UserRole role;
  final List<String> ownedShopIds;    // from getMine()
  final List<String> employeeShopIds; // from getMyEmployeeShops()

  bool get isAdmin => role == UserRole.admin;
  bool get isShopOwner => role == UserRole.shop_owner || isAdmin;
  bool get canCreateShop => isShopOwner;
  bool canManageShop(String shopId) => isAdmin || ownedShopIds.contains(shopId);
  bool canManageContent(String shopId) => isAdmin || ownedShopIds.contains(shopId) || employeeShopIds.contains(shopId);
}
```

- Provider `userPermissionsProvider`: reads `authNotifierProvider` for role, chains async `getMine()` and `getMyEmployeeShops()` for shop data, memoizing results.
- Sync helper `canManageShopInList` is a convenience that reads the provider.
- Removes the need for `isOwnedShopInList` (use `canManageShopInList`) — admin bypass for styling becomes `canManageShop(shopId) && !ownedShopIds.contains(shopId)`.

## Files to Modify/Refactor

### 3. `lib/core/auth/auth_notifier.dart` — Expose UserRole in AuthState

Add a computed `UserRole? get role` to `AuthState` using the `userProfile.userType` field. This makes the role available via `ref.watch(authNotifierProvider.select((s) => s.role))`.

### 4. `lib/core/routing/app_router.dart` — Route-level role guards

Add role checks in the global `redirect`:

| Route | Guard |
|---|---|
| `/events/new` | `isShopOwner` only — redirect to `/events` |
| `/shops/new` | `isShopOwner` only — redirect to `/shops` |
| `/users` | No role guard (open to all) |

The redirect reads `ref.read(authNotifierProvider)` and compares `user?.userType`. Keep the existing auth guard first (unauthenticated redirects to `/login`), then layer role checks.

### 5. `lib/features/events/event_create_screen.dart` — Fix customer submission bug

Current bug: `canSubmit` on line 183 only checks `shopId != null`. If `canCreate` is false (customer), the shop selector is hidden, but `shopId` defaults to `null` and `canSubmit` doesn't check `canCreate`.

Fix:
- Remove the `canCreate` widget-level guard (route guard handles it now)
- Add `canCreate` to `canSubmit` formula: `canSubmit = canCreate && shopId != null && ...`
- Remove the inline "not allowed" message (redundant with route guard)

### 6. `lib/features/events/event_list_screen.dart` — Refactor role check

Replace:
```dart
final canCreate = userType == 'shop_owner' || userType == 'admin';
```
With:
```dart
final permissions = ref.watch(userPermissionsProvider);
final canCreate = permissions.canCreateShop;
```

### 7. `lib/features/shops/shop_list_screen.dart` — Refactor role checks

Replace scattered inline checks:
- `_hasCreatePermission` → `permissions.canCreateShop`
- `canManageShopInList(ref, shopId)` → `permissions.canManageShop(shopId)`
- `isOwnedShopInList(ref, shopId)` → `permissions.ownedShopIds.contains(shopId)`
- `isShopFavourite` stays (it's user-data, not role)

### 8. `lib/features/shops/shop_create_screen.dart` — Refactor and add route guard

Replace `_canCreateShop` inline check with `permissions.canCreateShop`. Since route guard now handles this, the screen can remove the "not allowed" fallback UI.

### 9. `lib/features/shop_details/shop_manage_permission.dart` — Simplify

Replace the four separate providers (`canManageShopProvider`, `canManageShopContentProvider`, `ownedShopsProvider`, `shopPermissionsProvider`) with a single `shopPermissionsProvider` that reads from `userPermissionsProvider` filtered to a specific `shopId`. Keep `canManageShopInList` as a thin wrapper.

### 10. `lib/features/shop_details/shop_detail_screen.dart` — Refactor permissions

Replace the composite permission reading with direct `userPermissionsProvider` queries:
```dart
final permissions = ref.watch(userPermissionsProvider);
final canManageShop = permissions.canManageShop(shopId);
final canManageContent = permissions.canManageContent(shopId);
```

### 11. `lib/features/events/event_detail_screen.dart` — Refactor

Replace `canManageShopProvider(shopId)` watch with `userPermissionsProvider.canManageShop(shopId)`.

### 12. `lib/features/events/event_providers.dart` — Refactor

Replace inline `userType == 'admin'` and `userType == 'shop_owner'` with `permissions.isAdmin` and `permissions.isShopOwner`.

### 13. `lib/features/reservations/reservation_providers.dart` — Refactor

Replace `isShopOwner()` function with `permissions.isShopOwner`.

### 14. `lib/features/reservations/reservation_list_screen.dart` — Refactor

Replace `isShopOwner(ref)` with `ref.watch(userPermissionsProvider.select((p) => p.isShopOwner))`.

### 15. `lib/features/users/user_list_screen.dart` — Refactor color helper

Replace `_colorForType()` with `UserRole.displayColor` extension. Replace `isAdmin` with `permissions.isAdmin`.

### 16. `lib/core/utils/extensions.dart` — Deprecate normalizeUserType

Move logic into `UserRole.fromString()`. Keep the function as a thin delegation for backward compat, or remove once all call sites migrated.

### 17. `lib/features/profile/profile_screen.dart` — Implement edit and stats

**Edit flow:**
- In `_saveProfile()`, call `userApiService.update(id, data)` instead of `Future.delayed`
- The service method already exists at `user_api_service.dart:31` — `update(id, data)`
- On success, call `ref.read(authNotifierProvider.notifier).refreshProfile()` to update auth state
- Show a success/error snackbar

**Stats row:**
- Create a `userProfileStatsProvider` (FutureProvider) that calls the profile API and extracts:
  - `favouriteShops.length` for Favourites count
  - Need to add a call for reservation count (check if profile returns this or a separate endpoint)
  - Need to add a call for reviews count (same)
- If the current profile API doesn't return these counts, either:
  a) Call the reservations/reviews APIs with the user's ID and count, or
  b) Leave a note that backend changes are needed
- Wire the counts into the stats row widgets

### 18. `lib/features/dashboard/dashboard_screen.dart` and `dashboard_provider.dart` — Filter notifications

In the notification banner widget, wrap the reservation requests and review notification sections with role checks:
```dart
if (permissions.isShopOwner) ...[
  // reservation request notification
  // review notification
]
```
Customers will still see their own activity feed and personal summary, but not shop-owner-specific notifications.

### 19. `lib/shared/widgets/shop_card.dart` — Add owner label

When `isOwned` is true, add a small "Your Shop" label/badge inside the card (not just the border color). This makes ownership explicit to the user.

### 20. `lib/features/shop_details/shop_detail_screen.dart` and tabs — Pass permissions consistently

Audit all tab files (`community_tab.dart`, `employees_tab.dart`, `events_tab.dart`, `menu_tab.dart`, `reservations_tab.dart`, `reviews_tab.dart`, `tables_tab.dart`) to ensure they read permissions from `userPermissionsProvider` rather than relying on props passed from the parent.

## Verification

After implementation, verify each screen against the role matrix from the deep dive:

- [ ] `/login`, `/register` — public, redirect authed users
- [ ] `/dashboard` — authed only, filtered notifications for customers
- [ ] `/shops` — authed only, "My shops" for owners, FAB hidden for customers
- [ ] `/shops/new` — route-guarded to shop_owner+admin only
- [ ] `/shops/:id` — tabs correct per role (no Tables/Employees for customers)
- [ ] `/events` — authed only, "Reserve" for customers, "+" create for owners
- [ ] `/events/new` — route-guarded to shop_owner+admin only, `canSubmit` prevents null shopId
- [ ] `/events/:id` — delete only for managers, reserve form for non-managers
- [ ] `/reservations` — owner tabs vs customer tabs correct
- [ ] `/profile` — edit works, stats populated
- [ ] `/users` — open to all authenticated, shows name+username+role badge, delete admin-only

## Out of Scope / Backend Dependencies

- The backend user list endpoint (`GET /api/v2/user`) currently returns `id`, `name`, `username`, `userType`. If the goal is to reduce this to only `username` and `fullname`, the backend needs changes — the frontend already only displays non-sensitive fields.
- Profile stats (reservations count, reviews count) may require new API endpoints if the current profile response doesn't include them.
