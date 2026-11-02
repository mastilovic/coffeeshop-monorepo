# Design

## Context

See proposal.md for why. Dashboard notification `link` values are produced in `computeNotifications` and followed as-is: mobile `context.go(link)`, web `[routerLink]="note.link"`.

Pending requests use `/reservations`. Mobile `ReservationListScreen` starts on My Requests (tab index 0); Manage Shops is tab index 2 and already badges pending requests per shop. Web `ownerMainTab` defaults to `personal`; `ownerSubTab` already defaults to `pending` under Manage my Shops.

New reviews use `/shops`. Shop list items already include `reviewCount` and `averageRating` via `fillShopListStats` (`TestShop_PaginatedSearch_IncludesReviewStats`). They do not include a 30-day count. Both clients page the list (`GET /api/v2/shop?page=`), so reordering only the loaded page cannot put an off-page shop first.

`resolveShopScope` still returns every shop id. Notification totals stay on that scope.

## Goals / Non-Goals

**Goals:**

- One shared link contract for both clients: `/reservations?tab=manage` and `/shops?recentReviews=30`.
- Shop list payloads carry `recentReviewCount` for the last 30 days, using the same `review_date >= YYYY-MM-DD` cutoff as the dashboard notification.
- While `recentReviews=30` is active, shops with a recent count greater than 0 appear before the others across pages, show their existing average rating, and show a recent-count badge. A chip clears the query.

**Non-Goals:**

- Narrowing which shops the notification counts.
- Hiding shops that have no recent reviews.
- Changing the unrated label or the all-time `reviewCount` / `averageRating` calculation.
- Adding `recentReviewCount` to `GET /shop/mine` or the single-shop detail payload. List decoding defaults a missing field to 0.

## Decisions

### 1. Query parameters are the navigation contract

Pending link becomes `/reservations?tab=manage`. Reviews link becomes `/shops?recentReviews=30`. Mobile GoRouter already reads reservation query params and parses `context.go` query strings. The shops route builder today ignores query params and must pass `recentReviews` into `ShopListScreen`.

Web `routerLink` bound to a raw string does not reliably split `?` into query params. The dashboard notification anchor splits `link` into a path and a query-param map (`Router.parseUrl` or an equivalent split) and binds those separately.

Reservations screens apply `tab=manage` on first load and when the query changes later, because the shell can keep the screen alive. Only a shop owner has a management section; other roles ignore `tab=manage` and stay on personal requests. Web sets `ownerMainTab` to `manage` and leaves `ownerSubTab` at its default `pending`. Mobile `DefaultTabController.initialIndex` is 2 for that query and 0 otherwise.

Alternative: a dedicated route such as `/reservations/manage`. Rejected because both apps already key this screen off `/reservations` plus query params (`shopId`, `eventId`, `request`).

### 2. `recentReviewCount` is filled with the other list stats

Add `recentReviewCount int \`json:"recentReviewCount"\`` on `shopWithOwnerResponse`. `fillShopListStats` runs a second grouped query on `review` for `review_date >=` thirty days ago and sets 0 when a shop has no row. Both the flat list and the paginated list already call `fillShopListStats`, so both responses gain the field. `GET /shop/mine` stays a raw shop model.

The 30-day cutoff matches `computeNotifications`: `time.Now().AddDate(0, 0, -30).Format("2006-01-02")`.

Alternative: return the shop breakdown only on the dashboard notification. Rejected because a cold open of `/shops?recentReviews=30` would not know which cards to badge after the dashboard payload is gone.

### 3. The API orders the recent-reviews view

When `GET /shop` includes `recentReviews=30`, paginated search keeps the current filters and page size and orders rows by the same 30-day review count descending, then by the existing order. It does not filter shops out. The no-page list is sorted the same way after stats are filled. Clients pass that query through only while the route has `recentReviews=30`.

Client-only sort of the current page cannot satisfy "ahead of shops with no recent reviews" once results span pages. The API order is the source of truth. Clients still stable-sort the page they render by `recentReviewCount` descending while the view is active, so the visible page matches the spec if a response arrives unsorted.

Badges render only while the route query is set, and only when `recentReviewCount > 0`. Average rating stays on the existing rating row (`shopRatingLabel` / web `reviewCount > 0`). Dismissing the chip navigates to `/shops` without the query, which drops the badge, the chip, and the special order.

Alternative: filter the list to shops with recent reviews. Rejected in the proposal; other shops stay visible, unmarked.

### 4. Badge copy

The badge text is the recent count plus "new" (for example `2 new`). One shared presentation on mobile `ShopCard` (new optional count, shown only when the list asks for it) and the web shop card template.

## Risks / Trade-offs

- [Global notification scope vs owner management] → Pending counts can include shops the owner does not manage, while Manage Shops only lists their shops. Accepted: this change does not alter `resolveShopScope`.
- [Extra grouped query on every shop list] → Same shape as the existing rating aggregate, limited to the page's shop ids inside `fillShopListStats`. The order-by subquery runs only when `recentReviews=30` is set.
- [Web link parsing] → If the dashboard keeps a raw `routerLink` string, `recentReviews` and `tab` never arrive. Mitigation is the explicit path/query split in decision 1.
- [`DefaultTabController` recreated in `build`] → `initialIndex` can reset the tab on rebuild. Apply the query index when the route param is present; do not invent a new tab controller unless tests show the index is lost.

## Migration Plan

No schema change. Deploy the API first so `recentReviewCount` and the new links exist before the clients depend on them. Rollback is reverting the link strings and ignoring the new JSON field; old clients treat unknown fields as unused and still open `/shops` or `/reservations` if a rollback restores those links.

## Open Questions

None.
