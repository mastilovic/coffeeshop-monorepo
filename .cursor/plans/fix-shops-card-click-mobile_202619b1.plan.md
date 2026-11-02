---
name: fix-shops-card-click-mobile
overview: Fix intermittent click failures on shop cards by replacing the (click) handler on a div with a proper routerLink on an anchor element, and adding touch-friendly improvements.
todos:
  - id: replace-div-with-anchor
    content: Replace <div (click)> with <a routerLink> on shop card wrapper
    status: completed
  - id: fix-child-event-prevention
    content: Add event.preventDefault() to child click handlers (favourite button, action buttons) to prevent anchor navigation
    status: completed
  - id: remove-dead-code
    content: Remove goToShop() method from component class
    status: completed
  - id: add-anchor-css
    content: "Add text-decoration: none to .shop-card CSS to prevent link underline"
    status: completed
  - id: verify-build
    content: Verify Angular production build compiles successfully
    status: completed
isProject: false
---

# Fix Intermittent Shop Card Click on Mobile

## Root Cause

The shop card uses `(click)="goToShop(shop.id)"` on a `<div>` element. On mobile browsers, click events on non-interactive `<div>` elements are unreliable — touch event handling can miss or drop the click, especially when the browser treats it as a scroll gesture or when Angular's change detection re-renders the card. The `OnPush` change detection combined with the `loading` signal briefly hiding/re-showing cards can further disrupt event binding timing.

## Fix

### File: `coffeeshop-frontend/src/app/features/shops/shops.component.ts`

**1. Replace `<div (click)>` with `<a routerLink>` on the shop card.**

Change the card wrapper from:
```html
<div class="card clickable shop-card" (click)="goToShop(shop.id)">
```
to:
```html
<a class="card clickable shop-card" [routerLink]="['/shops', shop.id]">
```

This makes the entire card a proper anchor link, which:
- Works reliably on all mobile browsers (anchors are natively clickable)
- Supports keyboard navigation (Enter to activate)
- Supports right-click / long-press "Open in new tab"
- Removes the need for the `goToShop` method entirely

**2. Keep child click handlers unchanged.** The favourite button's `(click)="toggleFavourite(shop, $event)"` already calls `event.stopPropagation()` and `event.preventDefault()` to prevent the anchor navigation. Verify the action buttons wrapper also has `(click)="$event.stopPropagation(); $event.preventDefault()"`.

**3. Update the child event prevention.** When using `<a routerLink>`, child clicks need `event.preventDefault()` in addition to `stopPropagation()` to prevent the anchor from navigating.

**4. Remove dead code.** Remove the `goToShop(id: string)` method from the class since it's no longer needed.

**5. Add `text-decoration: none` to `.shop-card`** to prevent the default anchor underline from appearing on the card.