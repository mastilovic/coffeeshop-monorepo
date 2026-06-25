---
name: fix-event-delete-visibility
overview: Restrict event delete button visibility to shop owners and admins only, matching the web frontend behavior. Also close a backend middleware defense-in-depth gap.
todos:
  - id: fix-event-delete-provider
    content: Change _EventDeleteAction to use canManageShopProvider instead of canManageShopContentProvider
    status: completed
  - id: fix-middleware-gap
    content: Add shop-employees/me to protected endpoints in publicbearer.go isPublicEndpoint
    status: completed
  - id: verify
    content: Run dart analyze to verify no errors introduced
    status: completed
isProject: false
---

# Fix Event Delete Button Visibility for Non-Owners

## Problem

The `_EventDeleteAction` widget in `event_detail_screen.dart` uses `canManageShopContentProvider`, which grants permission to **admins, shop owners, AND shop employees**. This means a customer who is also an employee of a shop (has an `EMPLOYEE` relationship in `user_shop`) sees the event delete trashcan icon, even though they shouldn't have delete access.

The web frontend restricts event deletion to **shop owners and admins only**. The mobile app should match this.

## Root Cause

```122:146:coffeeshop-mobile/lib/features/events/event_detail_screen.dart
class _EventDeleteAction extends ConsumerWidget {
  // ...
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canManageAsync = ref.watch(canManageShopContentProvider(shopId));
    // canManageShopContentProvider returns true for: admin, owner, OR employee
    // should be canManageShopProvider: admin OR owner only
```

`canManageShopContentProvider` includes employees (content managers), but `canManageShopProvider` only includes owners and admins — which is what the web frontend uses for event deletion.

## Changes

### 1. Fix event detail screen delete gate

In `event_detail_screen.dart`, change `_EventDeleteAction` from `canManageShopContentProvider` to `canManageShopProvider`.

**Before:**
```dart
final canManageAsync = ref.watch(canManageShopContentProvider(shopId));
```

**After:**
```dart
final canManageAsync = ref.watch(canManageShopProvider(shopId));
```

This imports are already in place — `shop_manage_permission.dart` exports both providers.

### 2. Close backend middleware gap

In `publicbearer.go`, add `GET /api/v2/shop-employees/me` to the protected endpoints list (alongside `/api/v2/profile` and `/api/v2/shop/mine`). This is defense-in-depth: the handler already requires a current user, but the endpoint should require a valid token at the middleware level.

In the `isPublicEndpoint` function, add:
```
path != "/api/v2/shop-employees/me"
```

## How the two providers differ

| Provider | Admin | Shop Owner | Shop Employee | Customer |
|----------|-------|------------|---------------|----------|
| `canManageShopProvider` | Yes | Yes (for that shop) | No | No |
| `canManageShopContentProvider` | Yes | Yes | Yes | No (unless employee) |

Event deletion should use `canManageShopProvider` (owner or admin). Content management like menu items, tables, and community posts should continue using `canManageShopContentProvider` (which includes employees).

## Community post deletion (no change needed)

The community tab lets customers delete their own posts via `_canDeletePost()`:

```89:93:coffeeshop-mobile/lib/features/shop_details/tabs/community_tab.dart
  bool _canDeletePost(CommunityPostResponseDto post) {
    if (widget.canManage) return true;
    final userId = ref.read(authNotifierProvider).user?.id;
    return userId != null && post.authorId == userId;
  }
```

This is correct and matches the web app — post authors can delete their own posts. No change needed here.

## Files to change

| File | Change |
|------|--------|
| `coffeeshop-mobile/lib/features/events/event_detail_screen.dart` | `_EventDeleteAction`: `canManageShopContentProvider` → `canManageShopProvider` |
| `coffeeshop-go/internal/middleware/publicbearer.go` | Add `shop-employees/me` to protected exclusion list |