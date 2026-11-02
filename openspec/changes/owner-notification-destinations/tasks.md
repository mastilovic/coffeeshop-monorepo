# Tasks

## 1. API links and recent review counts

- [x] 1.1 Change the pending-requests notification link to `/reservations?tab=manage` and the new-reviews link to `/shops?recentReviews=30` in `computeNotifications`, without changing the shop scope or the 30-day count. Verify with a dashboard activity test that both links match and the new-reviews count is still the 30-day total.
- [x] 1.2 Add `recentReviewCount` to `shopWithOwnerResponse` and fill it in `fillShopListStats` with the same `review_date` cutoff as the dashboard (0 when the shop has no recent reviews). Verify by extending `TestShop_PaginatedSearch_IncludesReviewStats` so the reviewed shop reports `recentReviewCount` 1 and the unreviewed shop reports 0, with `reviewCount` and `averageRating` unchanged.
- [x] 1.3 When `GET /shop` includes `recentReviews=30`, order paginated and flat list results by that 30-day count descending and still return shops with a count of 0. Verify with an integration test that a shop with a recent review appears before a shop with none on page 0, and that omitting the query does not apply that order requirement.

## 2. Mobile destinations

- [x] 2.1 Read `tab` on the `/reservations` route and start a shop owner's `ReservationListScreen` on Manage Shops (index 2) when `tab=manage`, including when the query changes on an already-open screen. Ignore the param for non-owners. Verify with a widget test that a shop owner on `/reservations?tab=manage` sees the Manage Shops panel and a shop owner on `/reservations` still sees My Requests.
- [x] 2.2 Pass `recentReviews` from `/shops` into the shop list request, sort the loaded page by `recentReviewCount` descending while it is `30`, and show a dismissible chip that clears the query. Verify with a widget test that opening `/shops?recentReviews=30` requests the query, shows the chip, and that dismissing the chip drops the query.
- [x] 2.3 Show a `{count} new` badge on `ShopCard` only when the recent-reviews view is active and `recentReviewCount` is greater than 0, leaving the existing average-rating and "No rating yet" lines in place. Verify by extending `shop_card_test.dart` for the badge shown, the badge hidden, and an unrated shop still reading "No rating yet".

## 3. Web destinations

- [x] 3.1 Split each dashboard notification `link` into a path and query params before binding the anchor, so `/reservations?tab=manage` and `/shops?recentReviews=30` navigate with those params. Verify in `dashboard.component.spec.ts` that the pending-requests link exposes `tab=manage` and the new-reviews link exposes `recentReviews=30`.
- [x] 3.2 When a shop owner opens Reservations with `tab=manage`, set `ownerMainTab` to `manage` (pending sub-tab stays the default), including on later query changes. Without the param, keep `personal`. Verify in `reservations.component.spec.ts` for both URLs.
- [x] 3.3 Pass `recentReviews=30` through shop search while the route has it, sort that page by `recentReviewCount` descending, show the average rating plus a `{count} new` badge only for shops with a recent count greater than 0, and clear the query from a dismissible chip. Verify in a shops component test that a recently reviewed shop is badged and ordered first, an unreviewed shop stays "No rating yet" without a badge, and dismissing the chip removes `recentReviews`.
