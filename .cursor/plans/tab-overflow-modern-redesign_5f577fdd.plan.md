---
name: tab-overflow-modern-redesign
overview: "Make all pill-tab rows on mobile fully visible with modern UX: scrollable tabs with CSS fade overflow indicators, scroll-snap for polish, and a \"More\" dropdown for the 7-tab shop-details page."
todos:
  - id: css-fade-scrollsnap
    content: "Phase 1: Add scroll-snap + CSS fade overflow indicator to all .pill-tabs in styles.css"
    status: completed
  - id: more-dropdown-shop-details
    content: "Phase 2: Implement 'More...' dropdown pattern on shop-details page for overflow tabs (primaryTabs + overflowTabs computed signals, dropdown template, styles)"
    status: completed
  - id: responsive-threshold
    content: "Phase 3: Add responsive threshold — show fewer primary tabs on very small screens before overflow kicks in"
    status: completed
  - id: click-outside-handler
    content: "Phase 4: Add click-outside handler to close the 'More' dropdown when clicking elsewhere"
    status: completed
  - id: verify-all-tab-rows
    content: "Phase 5: Verify fade indicators work on all other pill-tab rows (reservations sub-tabs, customer tabs) — no template changes needed, CSS handles it"
    status: completed
  - id: final-polish
    content: "Phase 6: Final polish — accessibility (aria roles), mobile testing at 375px, ensure fade doesn't block last tab clicks"
    status: completed
isProject: false
---

# Tab Overflow Modern Redesign

Problem: On mobile, the shop-details page has up to 7 tabs (Users, Menu, Tables, Reservations, Events, Reviews, Employees) that overflow the viewport width. Other pill-tab rows lack visual indicators that more tabs exist beyond the visible edge.

Goal: All pill-tab rows should be fully accessible on mobile with visual polish — users can see all tabs via scroll or dropdown, and know when more tabs are available.

---

## Phase 1: CSS Overflow Indicators (styles.css)

**File:** `coffeeshop-frontend/src/styles.css`

Add to the `.pill-tabs` rules:

1. **Scroll-snap for smooth tab navigation:**
```css
.pill-tabs {
  scroll-snap-type: x mandatory;
  scroll-behavior: smooth;
}
.pill-tab {
  scroll-snap-align: start;
}
```

2. **Fade indicator on the right edge** when content overflows (CSS pseudo-element approach):
```css
.pill-tabs {
  position: relative;
}
.pill-tabs::after {
  content: '';
  position: absolute;
  right: 0;
  top: 0;
  bottom: 0;
  width: 2rem;
  background: linear-gradient(to right, transparent, #1a1a2e);
  pointer-events: none;
  z-index: 1;
  transition: opacity 0.2s;
}
```

The fade makes it visually obvious that more tabs exist, and the gradient blends into the background. Use `pointer-events: none` so it doesn't block taps on the last tab.

3. **Fix for sub-tabs** — `.pill-tabs--sub` has `background: #16213e`, so the fade gradient needs to match:
```css
.pill-tabs--sub::after {
  background: linear-gradient(to right, transparent, #16213e);
}
```

---

## Phase 2: "More" Dropdown for Shop Details (shop-details.component.ts)

**File:** `coffeeshop-frontend/src/app/features/shop-details/shop-details.component.ts`

The shop-details page has 7 tabs — too many for a single row even with scrolling. Implement a "More..." tab that collects overflow tabs into a dropdown.

### Template Changes:

Replace the current tab loop:
```html
<nav class="pill-tabs shop-tabs mb-3">
  @for (t of visibleTabs(); track t.key) {
    <button class="pill-tab" ...>{{ t.label }}</button>
  }
</nav>
```

With:
```html
<nav class="pill-tabs shop-tabs mb-3" role="tablist">
  <!-- Primary tabs (first 4 visible) -->
  @for (t of primaryTabs(); track t.key) {
    <button type="button" class="pill-tab" role="tab"
      [class.pill-tab--active]="activeTab() === t.key"
      [attr.aria-selected]="activeTab() === t.key"
      (click)="onTabChange(t.key)">{{ t.label }}</button>
  }
  <!-- More dropdown for remaining tabs -->
  @if (overflowTabs().length > 0) {
    <div class="pill-tabs__more" (click)="$event.stopPropagation()">
      <button type="button" class="pill-tab"
        [class.pill-tab--active]="isOverflowTabActive()"
        (click)="toggleMore()"
        aria-haspopup="true"
        [attr.aria-expanded]="showMore()">
        More
        <svg width="10" height="6" viewBox="0 0 10 6"><path d="M1 1l4 4 4-4" stroke="currentColor" stroke-width="1.5" fill="none"/></svg>
      </button>
      @if (showMore()) {
        <div class="pill-tabs__more-dropdown" role="menu">
          @for (t of overflowTabs(); track t.key) {
            <button type="button" class="pill-tabs__more-item" role="menuitem"
              [class.pill-tabs__more-item--active]="activeTab() === t.key"
              (click)="onTabChange(t.key); showMore.set(false)">{{ t.label }}</button>
          }
        </div>
      }
    </div>
  }
</nav>
```

### Component Logic Additions:

Add these computed signals and methods to the class:

```typescript
readonly showMore = signal(false);

readonly primaryTabs = computed(() => this.visibleTabs().slice(0, 4));
readonly overflowTabs = computed(() => this.visibleTabs().slice(4));

isOverflowTabActive(): boolean {
  return this.overflowTabs().some(t => t.key === this.activeTab());
}

toggleMore(): void {
  this.showMore.update(v => !v);
}
```

### Styles for the dropdown:

```css
.pill-tabs__more {
  position: relative;
  flex-shrink: 0;
}

.pill-tabs__more-dropdown {
  position: absolute;
  top: calc(100% + 4px);
  right: 0;
  z-index: 50;
  min-width: 140px;
  background: #1a1a2e;
  border: 1px solid #2a2a3e;
  border-radius: 8px;
  box-shadow: 0 8px 24px rgba(0,0,0,0.5);
  padding: 0.25rem;
  display: flex;
  flex-direction: column;
}

.pill-tabs__more-item {
  display: block;
  width: 100%;
  text-align: left;
  padding: 0.5rem 0.75rem;
  background: none;
  border: none;
  border-radius: 6px;
  color: #e0e0e0;
  font-size: 0.875rem;
  font-family: inherit;
  cursor: pointer;
}

.pill-tabs__more-item:hover,
.pill-tabs__more-item--active {
  background: rgba(212, 165, 116, 0.15);
  color: #d4a574;
}
```

Also add a click-outside handler to close the dropdown when clicking elsewhere (hook into document click via `@HostListener` or close on blur).

---

## Phase 3: Responsive Dropdown on Small Screens (styles.css)

For very small screens (< 480px), if even the primary 4 tabs overflow, add a media query that reduces the primary threshold to 3 tabs:

```css
@media (max-width: 480px) {
  .pill-tabs--responsive .pill-tabs__more {
    /* smaller screens show 3 tabs before overflow */
  }
}
```

Or handle this in the component by adjusting the slice count based on a breakpoint signal.

---

## Phase 4: Click-Outside Handler for "More" Dropdown

Add a `@HostListener` to close the "More" dropdown when clicking outside:

```typescript
@HostListener('document:click', ['$event'])
onDocumentClick(event: MouseEvent): void {
  // Close the more dropdown if clicking outside
  if (this.showMore()) {
    this.showMore.set(false);
  }
}
```

The template already uses `(click)="$event.stopPropagation()"` on the more wrapper to prevent immediate close.

---

## Phase 5: Apply Fade Indicators to All Other Pill-Tab Rows

Verify that the global CSS fade (`::after` pseudo-element) works correctly for:
- Reservations page: main tabs (My Reservations / Manage my Shops) — 2 tabs, no overflow needed but fade is harmless
- Reservations page: sub-tabs (Requests/Confirmed, Pending/Approved/Denied) — 2-3 tabs, fade is harmless
- Customer reservations: (Requests/Confirmed) — 2 tabs, fade is harmless

No template changes needed for these — the global CSS already applies.

---

## Phase 6: Verify & Polish

- Test on 375px viewport: verify all shop-details tabs accessible via scroll + More dropdown
- Test on 768px tablet: verify fade indicator appears when tabs overflow
- Check that the dropdown closes when tapping a tab
- Ensure `aria-expanded`, `aria-haspopup`, `role="menu"`, `role="menuitem"` are correct for accessibility
- Verify the fade gradient doesn't block clicks on the last visible tab (`pointer-events: none` on `::after`)