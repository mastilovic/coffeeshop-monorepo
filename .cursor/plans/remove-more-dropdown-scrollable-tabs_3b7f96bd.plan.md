---
name: remove-more-dropdown-scrollable-tabs
overview: Remove the More dropdown system from shop-details tabs. Replace with simple scrollable pill-tabs row — all tabs visible, horizontally scrollable on small screens (same pattern as reservations sub-tabs).
todos:
  - id: simplify-template
    content: "Simplify template: replace primaryTabs/overflowTabs/More/backdrop blocks with single @for over visibleTabs()"
    status: completed
  - id: remove-dead-members
    content: "Remove dead component members: showMore, primaryTabs, overflowTabs, isSmallScreen, isOverflowTabActive, toggleMore, matchMedia in ngOnInit"
    status: completed
  - id: remove-css
    content: "Remove unused More CSS from styles.css: pill-tabs__more, backdrop, dropdown, dropdown items"
    status: completed
  - id: verify-build
    content: Verify Angular production build
    status: completed
isProject: false
---

# Remove More Dropdown — Use Scrollable Tabs

## Goal

Strip out the "More" dropdown logic from shop-details tabs. Show all tabs in a horizontally scrollable pill-tabs row (already styled with `overflow-x: auto`). Same pattern as reservations manage-my-shops sub-tabs.

## Changes

### 1. Simplify template in shop-details.component.ts

In `[coffeeshop-frontend/src/app/features/shop-details/shop-details.component.ts](coffeeshop-frontend/src/app/features/shop-details/shop-details.component.ts)`, replace the current tab nav (lines 113-144) with a single `@for` over `visibleTabs()`:

```html
<nav class="pill-tabs shop-tabs mb-3" role="tablist" aria-label="Shop section">
  @for (t of visibleTabs(); track t.key) {
    <button type="button" class="pill-tab" role="tab"
      [class.pill-tab--active]="activeTab() === t.key"
      [attr.aria-selected]="activeTab() === t.key"
      (click)="onTabChange(t.key)">
      {{ t.label }}
    </button>
  }
</nav>
```

No `@if` blocks, no More button, no backdrop, no dropdown.

### 2. Remove dead component class members

Remove these from the class:
- `readonly showMore` signal
- `readonly primaryTabs` computed
- `readonly overflowTabs` computed
- `private readonly isSmallScreen` signal
- `isOverflowTabActive()` method
- `toggleMore()` method
- `matchMedia` setup in `ngOnInit` (lines 886-888)

### 3. Remove unused CSS from styles.css

In `[coffeeshop-frontend/src/styles.css](coffeeshop-frontend/src/styles.css)`:
- Remove `.pill-tabs__more` rule block (lines 1218-1223)
- Remove `.pill-tabs__backdrop` and `.pill-tabs__backdrop--open` rules
- Remove `.pill-tabs__more-dropdown` and `.pill-tabs__more-dropdown--open` rules
- Remove `.pill-tabs__more-item` and `.pill-tabs__more-item:hover` / `--active` rules

Component-scoped `.pill-tabs.shop-tabs` styles stay — they provide `overflow-x: auto` and hidden scrollbar for horizontal scrolling.

### 4. Verify build