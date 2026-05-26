---
name: Pagination footer pinned bottom
overview: Make list/search pages render their `.pagination-bar` as a true page footer that sits at the bottom of the viewport when content is short, across all search-driven pages, without making it sticky during scroll.
todos:
  - id: global-page-footer-utility
    content: Add global `.page--with-footer`, `.page__content`, `.page__footer` styles in `coffeeshop-frontend/src/styles.css`.
    status: pending
  - id: shops-template-footer
    content: Refactor `shops.component.ts` to use `page--with-footer` + `page__content` + `page__footer` while keeping existing shops-specific classes as needed.
    status: pending
  - id: users-template-footer
    content: Refactor `users.component.ts` template so `.pagination-bar` is in `page__footer` and content is in `page__content`.
    status: pending
  - id: events-template-footer
    content: Refactor `events.component.ts` template so `.pagination-bar` is in `page__footer` and content is in `page__content`.
    status: pending
  - id: spot-check-other-pagination
    content: Search for other `.pagination-bar` usages and apply the same structure where it represents a page footer.
    status: pending
isProject: false
---

# Pin pagination footer to page bottom

## Goal

Ensure the `div.pagination-bar` used as the list footer is **not attached directly under the results content** and instead behaves like a **page footer**: when results are short, it sits at the bottom of the viewport; when results are long, it stays at the bottom of the content (non-sticky).

## Key observation

- `LayoutComponent` gives the main content area a fixed height (`.layout { height: 100vh }`) and makes the route container scrollable (`.content { flex: 1; overflow-y: auto }`) in [`coffeeshop-frontend/src/app/shared/layout/layout.component.ts`](coffeeshop-frontend/src/app/shared/layout/layout.component.ts).
- `.page` currently only sets padding/max-width and **does not stretch to the available height**, so a footer placed after short content will “float” mid-page in the scroll container in [`coffeeshop-frontend/src/styles.css`](coffeeshop-frontend/src/styles.css).

## Approach

### 1) Add a reusable “page with footer” layout utility (global CSS)

Update [`coffeeshop-frontend/src/styles.css`](coffeeshop-frontend/src/styles.css) to introduce a generic pattern:

- `.page--with-footer { display: flex; flex-direction: column; min-height: 100%; }`
- `.page__content { flex: 1 1 auto; }`
- `.page__footer { flex-shrink: 0; margin-top: auto; }`

This makes any page component able to pin its footer to the bottom of the available `.content` viewport height.

### 2) Update each list/search page to use that structure

For each page that uses `.pagination-bar` as a list footer, adjust the template structure to:

- Wrap the main UI in `<div class="page__content">…</div>`
- Render the pagination bar as a sibling `<div class="pagination-bar page__footer">…</div>`
- Apply `class="page page--with-footer …"` on the outer page container

Concrete targets:

- [`coffeeshop-frontend/src/app/features/shops/shops.component.ts`](coffeeshop-frontend/src/app/features/shops/shops.component.ts)
  - Keep existing `.shops-page__content` as part of `page__content` (or replace with `page__content`), and make the footer `margin-top: auto` via `.page__footer` (can keep `shops-page__footer` for shops-specific tweaks).
- [`coffeeshop-frontend/src/app/features/users/users.component.ts`](coffeeshop-frontend/src/app/features/users/users.component.ts)
  - Move the existing `<div class="pagination-bar">` (currently rendered after the table) into a `page__footer` sibling.
- [`coffeeshop-frontend/src/app/features/events/events.component.ts`](coffeeshop-frontend/src/app/features/events/events.component.ts)
  - Same refactor: lift `<div class="pagination-bar">` into `page__footer` sibling.

(If there are other list/search pages using `.pagination-bar`, we’ll apply the same structural pattern.)

### 3) Minimal per-page overrides only if needed

- Prefer the global utility classes over bespoke `.shops-page__footer` rules.
- If spacing looks off, adjust only the page footer spacing (e.g. keep `padding-top/border-top` from `.pagination-bar`, and avoid extra `margin-top` that would fight `margin-top: auto`).

## Verification checklist

- Shops/Users/Events with 0–2 rows/cards: pagination bar sits at the **bottom of the viewport** within the scrollable `.content` region.
- With many items: pagination appears at the bottom of the content (you scroll to reach it).
- Loading state behavior unchanged (footer only shown when intended by current `@if` conditions).
