---
name: fix-reservation-endpoints
overview: Fix reservation and reservation-request endpoints to return enriched DTOs matching frontend expectations, and fix List authorization so shop owners can manage customer requests.
todos:
  - id: "1"
    content: Add enriched response types and rewrite GetAll/GetByID in reservation.go
    status: completed
  - id: "2"
    content: Fix List authorization + add enriched response types in reservation_request.go
    status: completed
  - id: "3"
    content: Verify Go backend compiles
    status: completed
isProject: false
---

# Fix: Reservation Endpoints Return Incomplete Data

## Root Causes

**Cause 1 — Flat IDs, not nested DTOs:** Both `GET /api/v2/reservation` and `GET /api/v2/reservation-request` return raw model entities (`model.Reservation`, `model.ReservationRequest`). These have flat fields like `userId`, `shopId`, `tableId`. The frontend expects nested objects: `user: {id, name, username}`, `shop: {id, name, ...}`, `table: {id, number, capacity}`, plus `eventName`/`eventDate`. Templates access `req.shop.name`, `req.user?.name`, `r.table.number` — all return `undefined` because the response has `req.shopId` (a string), not `req.shop` (an object).

**Cause 2 — `List` always filters by current user:** In `reservation_request.go` line 43:
```go
query := h.db.WithContext(r.Context()).Where("user_id = ?", user.ID)
```
This means a shop owner calling `GET /api/v2/reservation-request?shopId=X` only sees their OWN requests for shop X, never customer requests. The `shopId` param is an additional AND filter on top of `user_id`.

**Cause 3 — No filtering on `GetAll` reservations:** `GET /api/v2/reservation` returns every reservation in the system. No `?shopId=` support.

## Files to Change

### 1. `coffeeshop-go/internal/handler/reservation.go` — Add enriched response + shopId filter

**New response types:**
```go
type reservationResponse struct {
    ID                   string          `json:"id"`
    PartySize            int             `json:"partySize"`
    ReservationRequestID *string         `json:"reservationRequestId"`
    User                 *ownerSummary   `json:"user"`
    Shop                 *shopSummary    `json:"shop"`
    Table                *tableSummary   `json:"table"`
    EventID              *string         `json:"eventId,omitempty"`
    EventName            *string         `json:"eventName,omitempty"`
    EventDate            *string         `json:"eventDate,omitempty"`
}

type shopSummary struct {
    ID          string `json:"id"`
    Name        string `json:"name"`
    Address     string `json:"address"`
    City        string `json:"city"`
    PhoneNumber string `json:"phoneNumber"`
    Email       string `json:"email"`
}
```

**Rewrite `GetAll`:**
- Accept optional `?shopId=` query param
- Join with `users`, `shop`, `tables`, `event` tables
- Return `[]reservationResponse`

**Rewrite `GetByID`:**
- Same join logic, return `reservationResponse`

### 2. `coffeeshop-go/internal/handler/reservation_request.go` — Fix auth + add enriched response

**New response types:**
```go
type reservationRequestResponse struct {
    ID            string          `json:"id"`
    PartySize     int             `json:"partySize"`
    Status        string          `json:"status"`
    ReservationID *string         `json:"reservationId,omitempty"`
    User          *ownerSummary   `json:"user"`
    Shop          *shopSummary    `json:"shop"`
    EventID       *string         `json:"eventId,omitempty"`
    EventName     *string         `json:"eventName,omitempty"`
    EventDate     *string         `json:"eventDate,omitempty"`
}
```

**Rewrite `List`:**
- If `?shopId=` provided AND current user is shop owner/employee/admin for that shop → return ALL requests for that shop (filter by `shop_id` only, no `user_id` filter)
- Otherwise → return current user's own requests (existing behavior)
- Join with `users`, `shop`, `event` tables
- Return `[]reservationRequestResponse`

### 3. No frontend changes needed

Frontend DTOs already define the expected shapes. Once backend returns nested objects, UI renders correctly.

## Verification

After rebuild:
1. Regular user sees "My Reservations" tab with their own requests/reservations showing shop names, event names, table numbers
2. Shop owner sees "Manage my Shops" tab with customer pending requests listed with guest names, shop names, event names
3. Shop owner can select a table and accept/deny customer requests
4. Confirmed reservations show table numbers and shop names
