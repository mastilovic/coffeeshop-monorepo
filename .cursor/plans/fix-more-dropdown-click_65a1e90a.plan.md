---
name: fix-more-dropdown-click
overview: Fix the More button not showing a dropdown by replacing the @HostListener/stopPropagation pattern with a backdrop overlay, and make the More button only appear on small screens (&lt;480px).
todos:
  - id: update-template
    content: "Update template: remove stopPropagation, add backdrop div, keep dropdown inside @if showMore()"
    status: completed
  - id: update-component-class
    content: Remove @HostListener and ElementRef, change primaryTabs/overflowTabs to only show More on small screens
    status: completed
  - id: update-styles
    content: Add .pill-tabs__backdrop CSS and z-index to .pill-tabs__more in styles.css
    status: completed
  - id: verify-build
    content: Run Angular production build to confirm no errors
    status: completed
isProject: false
---

# Fix More Dropdown Click

## Problem

1. Clicking the "More" button in shop-details tabs does not show the dropdown menu
2. The "More" button should only appear on small screens (&lt;480px), not on desktop

## Root Cause

The `@HostListener('document:click')` + `(click)="$event.stopPropagation()"` approach creates an unreliable race between the document listener closing `showMore` and Angular's signal-driven change detection opening it.

## Solution

Replace the `@HostListener` / `stopPropagation` pattern with a **backdrop overlay** — a fixed-position invisible div that catches outside clicks. Restrict the More button to small screens only.

## Steps

### 1. Update shop-details.component.ts template

In `[coffeeshop-frontend/src/app/features/shop-details/shop-details.component.ts](coffeeshop-frontend/src/app/features/shop-details/shop-details.component.ts)`:

- Remove `(click)="$event.stopPropagation()"` from the `.pill-tabs__more` wrapper div
- After the `@if (overflowTabs().length > 0)` block (but still inside the nav), add a backdrop element:

```html
@if (showMore()) {
  <div class="pill-tabs__backdrop" (click)="showMore.set(false)"></div>
}
```

### 2. Update component class

- Remove the `@HostListener('document:click', ['$event']) onDocumentClick(...)` method entirely
- Remove `ElementRef` from imports and injection (no longer needed)
- Change `primaryTabs` and `overflowTabs` computed signals to only split on small screens:

```typescript
readonly primaryTabs = computed(() => {
  if (!this.isSmallScreen()) return this.visibleTabs();
  return this.visibleTabs().slice(0, 3);
});
readonly overflowTabs = computed(() => {
  if (!this.isSmallScreen()) return [];
  return this.visibleTabs().slice(3);
});
```

### 3. Update styles.css

In `[coffeeshop-frontend/src/styles.css](coffeeshop-frontend/src/styles.css)`, add the backdrop rule:

```css
.pill-tabs__backdrop {
  position: fixed;
  inset: 0;
  z-index: 49;
}
```

And give `.pill-tabs__more` a z-index above the backdrop so the button stays clickable when the dropdown is open:

```css
.pill-tabs__more {
  position: relative;
  flex-shrink: 0;
  z-index: 51;
}
```

### 4. Verify

Run the Angular production build to confirm no compilation errors.