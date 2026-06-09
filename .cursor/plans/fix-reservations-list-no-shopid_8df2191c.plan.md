---
name: fix-reservations-list-no-shopid
overview: Fix the reservation-request List endpoint to return requests for all managed shops when called without a shopId by a shop owner/admin, so the dedicated reservations page shows customer requests.
todos:
  - id: "1"
    content: Rewrite List authorization logic to include managed shops when no shopId
    status: completed
  - id: "2"
    content: Verify Go backend compiles
    status: completed
isProject: false
---

# Fix: Reservations Tab Empty for Shop Owners

## Root Cause

`reservations.component.ts` `loadData()` (line 996) calls:

```ts
this.requestService.getAll().subscribe(...)
```

No `shopId` parameter. The backend `List` handler in `reservation_request.go` falls into the `else` branch (line 74-78) which executes:

```go
query = query.Where("rr.user_id = ?", user.ID)
```

Shop owner only sees their OWN reservation requests — never customer requests for their shops.

The shop details page (`shop-details.component.ts`) works because `loadReservations()` calls `this.requestService.getAll(this.shopId)` — passes `shopId`, triggering the manager branch that returns all requests for that shop.

## Fix

Change `reservation_request.go` `List` method (lines 72-79). Replace the `else` branch with logic that checks if the user manages any shops:

**Current (lines 72-79):**
```go
if shopID != "" && (h.authorizer.IsAdmin(r.Context()) || h.authorizer.IsShopOwnerOrEmployee(r.Context(), shopID)) {
    query = query.Where("rr.shop_id = ?", shopID)
} else {
    query = query.Where("rr.user_id = ?", user.ID)
    if shopID != "" {
        query = query.Where("rr.shop_id = ?", shopID)
    }
}
```

**New logic:**

1. `shopId` provided + user manages that shop → `WHERE rr.shop_id = ?` (unchanged)
2. No `shopId` + user is admin → no additional filter (see everything)
3. No `shopId` + user owns shops → `WHERE rr.shop_id IN (owned) OR rr.user_id = ?` (managed requests + own requests)
4. No `shopId` + regular user → `WHERE rr.user_id = ?` (unchanged)

The OR ensures shop owners also see their personal requests at shops they don't own — frontend `myPersonalRequests` filter needs those too.

## File Changed

`coffeeshop-go/internal/handler/reservation_request.go` — `List` method, lines 72-79.

## Verification

After rebuild:
1. Shop owner opens `/reservations` → "Manage my Shops" tab shows customer pending requests
2. Shop owner's "My Reservations" tab still shows their own personal requests
3. Regular user sees only their own requests (unchanged behavior)
4. Admin sees everything