# Proposal

## Why

A shop owner who taps a dashboard notification does not land where the work is. Reservation requests open the owner's personal requests instead of shop management, and new reviews open a shops list that does not say which shops those reviews belong to or show a rating for them.

## What Changes

- The pending-reservation notification opens the owner management section of Reservations (Manage Shops on mobile, Manage my Shops on web), on the pending requests section.
- The new-reviews notification opens Shops with a 30-day recent-reviews view.
- Each shop in the shops list reports how many reviews it received in the last 30 days.
- Shops with reviews in that window show their average rating and a recent-count badge, and sort to the top while the recent-reviews view is active. A dismissible chip returns the list to its normal order.
- Shops with no reviews in the window stay unbadged and keep the existing "No rating yet" label.
- Notification totals stay scoped the way they are today (every shop), so the badge set matches the notification count.

## Capabilities

### New Capabilities

- `dashboard-notifications`: Shop-owner dashboard notification destinations, including the reservation-management landing tab and the per-shop recent-review indicator on the shops list.

### Modified Capabilities

- None. There are no existing specs.

## Impact

- API: dashboard notification links in `coffeeshop-go/internal/handler/dashboard.go`, and shop list stats in `coffeeshop-go/internal/handler/shop.go` (`recentReviewCount` on each list item).
- Mobile: reservations route/tab in `coffeeshop-mobile`, and shops list plus `ShopCard` for the recent-review badge and sort.
- Web: `reservations.component.ts` and `shops.component.ts` honor the same query parameters.
- Clients that follow the notification `link` will receive the new query strings. The shop list response gains a field; existing rating fields stay.
