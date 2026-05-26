---
name: Shops favourite no resort
overview: Stop the Shops tab from refetching/reordering the shop list when a user toggles favourite, while still allowing the shop to move between the “Your communities” and “All shops” sections based on updated favourite status.
todos:
  - id: inspect-current-toggle-flow
    content: Confirm `toggleFavourite()` refetches shops and causes order changes; confirm profile refresh is already happening in `ShopService`.
    status: pending
  - id: remove-refetch-update-local
    content: Update `ShopsComponent.toggleFavourite()` to stop calling `loadShops()` and instead patch the `shops` signal with the returned `ShopResponseDto`.
    status: pending
  - id: verify-no-reorder
    content: Verify toggling favourite moves between sections but does not reshuffle the list order (and avoids an extra `/api/v1/shop` request).
    status: pending
isProject: false
---

# Prevent shop list reordering on favourite toggle

## What’s happening
- `ShopsComponent` renders two sections based on favourite status by filtering the current `shops()` array into `favouriteShopsList()` and `otherShopsList()`.
- When you toggle favourite, we already refresh the profile via `ShopService.addFavourite/removeFavourite()` → `ProfileService.getProfile()`.
- **Additionally**, `toggleFavourite()` calls `loadShops({ silent: true })`, replacing `shops()` from the backend, which can change ordering and looks like an “extra sort”.

Key spots:
- Grouping into two lists: `coffeeshop-frontend/src/app/features/shops/shops.component.ts` (around `favouriteShopsList` / `otherShopsList`).
- Extra refetch on toggle: `toggleFavourite()` in `coffeeshop-frontend/src/app/features/shops/shops.component.ts` (currently calls `this.loadShops({ silent: true })`).
- Profile refresh already happens in `coffeeshop-frontend/src/app/services/shop.service.ts` via `switchMap(... this.profileService.getProfile() ...)`.

## Proposed change
- In `coffeeshop-frontend/src/app/features/shops/shops.component.ts`:
  - **Remove the `loadShops({ silent: true })` call** after a successful favourite toggle.
  - Instead, update the local `shops` signal in-place for that one shop using the `ShopResponseDto` returned from `addFavourite/removeFavourite` (replace the matching item by `id`).
    - This preserves the existing list order.
    - The shop will still move between sections because favourite status is derived from the refreshed profile (or, if needed, from `shop.favouriteByCurrentUser`).

## Verification
- Manual: open Shops tab, note ordering of cards in “All shops”, toggle favourite on a mid-list shop.
  - Expected: shop may move between sections, but **relative ordering inside the unchanged source list is preserved** (no full-list reorder / reshuffle).
  - No extra network call to `/api/v1/shop` should be triggered by favourite toggle (only the favourite endpoint + profile refresh).

## Notes / fallback
- If any UI still relies purely on `currentUser().favouriteShops`, we keep that behavior (shop moves sections) while preventing backend reordering by avoiding the list refetch.
- If backend does not return updated `favouriteByCurrentUser`, we can still keep the in-place replacement (other fields may change) and let profile refresh drive the UI state.