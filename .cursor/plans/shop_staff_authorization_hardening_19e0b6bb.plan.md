---
name: Shop staff authorization hardening
overview: Close the remaining backend authorization gaps (shopless events) so announcements, menu, tables, events, and employees can only be mutated by shop owners/employees (admin as superuser, employees owner-only), and surface 403 errors in the mobile app with a clear message.
todos:
  - id: event-authz
    content: Require shopId on event create; make shopless event update/delete admin-only in event.go
    status: completed
  - id: backend-tests
    content: Add integration tests for 403/400 cases (customer blocked, employee allowed, owner-only employee mgmt)
    status: completed
  - id: mobile-forbidden
    content: Add ForbiddenException for 403 in api_exception.dart and regenerate freezed code
    status: completed
  - id: mobile-format
    content: Handle forbidden case in formatApiError so snackbars show the backend message
    status: completed
  - id: verify
    content: Run go test, flutter analyze, and manually verify 403 message in app
    status: completed
isProject: false
---

# Shop Staff Authorization Hardening

## Agreed policy (from your answers)

- Announcements, menu, menu items, tables, events: manageable by shop **owner, employee, or admin**. Customers get a 403 with a clear message.
- Employee assignment/removal and shop delete: **owner or admin only** (already enforced).
- Events must belong to a shop: `shopId` required on create; legacy shopless events become admin-only for edit/delete.
- Mobile app keeps management buttons visible for employees; 403s show a clear error message.

## Current state (verified in code)

The Go backend already enforces most of this via `ShopAuthorizer` (`coffeeshop-go/internal/auth/shop_authorizer.go`), returning `{"message": "..."}` with HTTP 403:

- Announcements create/delete: `RequireShopOwnerOrEmployeeOrAdmin` in [coffeeshop-go/internal/handler/community.go](coffeeshop-go/internal/handler/community.go)
- Menu, menu items, tables: same check in `menu.go`, `menu_item.go`, `table.go`
- Employees assign/remove: `RequireShopOwnerOrAdmin` in [coffeeshop-go/internal/handler/shop_employee.go](coffeeshop-go/internal/handler/shop_employee.go)

**Real gaps:**

1. Events with no `shopId` skip authorization entirely — any logged-in user can create/edit/delete them ([coffeeshop-go/internal/handler/event.go](coffeeshop-go/internal/handler/event.go), the check is wrapped in `if req.ShopID != nil && *req.ShopID != ""`).
2. The mobile app maps 403 to a generic `UnknownException` with no dedicated handling ([coffeeshop-mobile/lib/core/network/api_exception.dart](coffeeshop-mobile/lib/core/network/api_exception.dart)).

## Backend changes (`coffeeshop-go`)

### 1. `internal/handler/event.go`

- `Create`: reject missing/empty `shopId` with `apperror.BadRequest("shopId is required")`, then run the existing `RequireShopOwnerOrEmployeeOrAdmin` check unconditionally.
- `Update` / `Delete`: when the existing event has no shop, require admin (`h.authorizer.RequireAdmin`) instead of skipping the check; keep the owner/employee/admin check when a shop is set.

### 2. Integration tests (`cmd/api/integration_test.go`)

Using the existing harness (`setupTestHarness`, `tokenForUser`, `doJSON`), add coverage:

- Customer token gets 403 on: create table, create menu, create menu item, create event, create announcement, assign employee.
- Employee token succeeds (2xx) on: create table, create menu, create event, create announcement — but gets 403 on assign/remove employee and shop delete.
- Event create without `shopId` returns 400.
- Non-admin edit/delete of a shopless event returns 403.

## Mobile changes (`coffeeshop-mobile`)

### 3. `lib/core/network/api_exception.dart`

Add a dedicated forbidden variant and map status 403 to it, preferring the backend message:

```dart
const factory ApiException.forbiddenException({
  required String message,
}) = ForbiddenException;
```

In `fromDioException`, before the fallback branch:

```dart
} else if (statusCode == 403) {
  return ApiException.forbiddenException(
    message: _extractMessage(data) ??
        'You don\'t have permission to perform this action.',
  );
}
```

Then regenerate freezed code: `dart run build_runner build --delete-conflicting-outputs` in `coffeeshop-mobile`.

### 4. `lib/core/utils/api_error.dart`

Add the `forbiddenException` case to the exhaustive `when` in `formatApiError` so all existing snackbars (`community_tab.dart`, `menu_tab.dart`, `tables_tab.dart`, `events_tab.dart`, `employees_tab.dart`, `event_create_screen.dart`, `event_detail_screen.dart`) automatically display the backend's message, e.g. "Failed to save: Only the shop owner, an employee, or an admin can perform this action".

### 5. No UI-gating changes

Per your decision, employees keep the management buttons (`canManageContent` unchanged), and the Employees tab stays owner-only (`canManageShop`, already correct). The event create screen already forces shop selection, so the new backend `shopId` requirement doesn't need UI work.

## Verification

- Backend: `go test ./...` in `coffeeshop-go`.
- Mobile: `flutter analyze` and existing tests; manually exercise a customer account against a management endpoint to confirm the snackbar shows the backend's 403 message.