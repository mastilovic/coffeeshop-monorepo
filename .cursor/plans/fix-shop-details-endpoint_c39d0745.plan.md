---
name: fix-shop-details-endpoint
overview: Fix the GET /shop/{id} endpoint to return full shop data (menus, tables, events, reviews) so the frontend shop details page shows content after creation and enables management buttons.
todos:
  - id: "1"
    content: Create fullShopResponse struct and response builders in shop.go
    status: completed
  - id: "2"
    content: Rewrite GetByID to load and return full shop data
    status: completed
  - id: "3"
    content: Verify Go backend compiles
    status: completed
isProject: false
---

# Fix: Shop Details Endpoint Returns Incomplete Data

## Root Cause

The backend `GET /api/v2/shop/{id}` handler (`GetByID`) returns only a `shopWithOwnerResponse` with 7 fields:

```go
// shop.go lines 53-61
type shopWithOwnerResponse struct {
    ID, Name, Address, City, PhoneNumber, Email string
    CreatedBy *ownerSummary
}
```

The frontend `ShopResponseDto` expects many more fields: `currentMenu`, `menuHistory`, `tables`, `events`, `reviews`, `reviewCount`, `averageRating`, `memberCount`, etc.

Because `GetByID` doesn't include these, the frontend `loadShop()` sets the shop signal with incomplete data. After creating a menu, `loadShop()` is called but `currentMenu` is always missing, so the UI never updates.

This also means `shop().tables` and `shop().events` are always `undefined`, which may contribute to the missing management buttons (though the primary gate is `canManageShopContent` which depends on `createdBy` — already fixed in the earlier `ownerUserId` fix).

## Files to Change

### 1. `coffeeshop-go/internal/handler/shop.go` — Add full shop response and rewrite `GetByID`

Create a new `fullShopResponse` struct in `shop.go` and rewrite `GetByID` (line 242) to return it.

**New struct fields** (matching frontend `ShopResponseDto`):

- `id`, `name`, `address`, `city`, `phoneNumber`, `email` — from `model.Shop`
- `createdBy` — from `fillShopOwners` query (already works)
- `currentMenu` (with items), `menuHistory` (with items) — query menus + menu_items
- `tables` — query tables where `shop_id = ?`
- `events` — query events where `shop_id = ?`
- `reviews`, `reviewCount`, `averageRating` — query reviews + aggregate
- `memberCount` — count from `user_shop` where `relationship_type = 'FAVOURITE'`
- `users` — can leave empty for now (separate endpoint handles members)
- `loyaltyPlan`, `contacts` — query or leave null for now
- `favouriteByCurrentUser` — check if current user has FAVOURITE relationship

**Query approach**: Load all related data with separate queries in the handler, assemble into the response struct. No GORM preloading needed — just direct queries against the known tables.

### 2. No frontend changes needed

The `ShopResponseDto` already expects all these fields. The frontend's `loadShop()` (line 1224) calls `getById()` and sets `this.shop.set(shop)`. Once the backend returns full data, the UI updates automatically.

## Additional Consideration

The `GetShops` (paginated list) endpoint also returns `shopWithOwnerResponse`. The shop list page uses `canManage(shop)` which checks `shop.createdBy?.id === profile.id`. Since `fillShopOwners` already includes `createdBy`, this works once the `ownerUserId` fix is deployed. No changes needed to the list endpoint for now.

## Verification

After the fix, rebuilding the backend container and:
1. Creating a shop as shop_owner should show management buttons (Edit/Delete)
2. Creating a menu should immediately show the menu with items in the UI
3. Tables, events, reviews tabs should show data from the backend
4. `canManageShopContent()` returns true because `shop.createdBy.id === profile.id`
