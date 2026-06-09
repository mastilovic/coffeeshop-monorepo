---
name: fix-stale-tables-in-reservation-dropdown
overview: Fix the table selector in reservation accept flow not showing newly created tables after navigating back from shop-details. Tables are loaded once in ngOnInit and never refreshed on route re-activation.
todos:
  - id: extract-load-tables
    content: Extract tableService.getAll() call into a loadTables() method
    status: completed
  - id: add-to-load-data
    content: Call loadTables() inside loadData() to refresh on accept/deny/submit
    status: completed
  - id: subscribe-router
    content: Subscribe to router NavigationEnd events to refresh tables on route re-activation
    status: completed
  - id: add-filter-import
    content: Add filter import from rxjs
    status: completed
isProject: false
---

# Fix Stale Tables in Reservation Accept Dropdown

## Root Cause

`ReservationsComponent.tables` signal is populated once in `ngOnInit()` (line 880). Angular's default `RouteReuseStrategy` reuses the component instance when navigating back from shop-details. `ngOnInit()` does not re-fire, so the `tables` signal stays stale — new tables created in shop-details never appear in the dropdown.

## Changes

### Single file: `coffeeshop-frontend/src/app/features/reservations/reservations.component.ts`

**1. Extract table loading into a method**

Add a `loadTables()` private method (line ~997, before `loadData()`):

```typescript
private loadTables(): void {
  this.tableService.getAll().subscribe(tables => this.tables.set(tables));
}
```

**2. Call `loadTables()` inside `loadData()`**

Add `this.loadTables();` as the first line of `loadData()`. This ensures tables refresh after every accept/deny/submit action.

**3. Subscribe to router NavigationEnd in `ngOnInit()`**

Add to `ngOnInit()`, after existing subscriptions:

```typescript
this.router.events
  .pipe(
    filter(event => event instanceof NavigationEnd),
    takeUntilDestroyed(this.destroyRef),
  )
  .subscribe(() => this.loadTables());
```

Requires adding `filter` import from `rxjs` at top of file.

This covers the case where user navigates from `/shops/:id` (after creating tables) back to `/reservations` — the component is reused but `loadTables()` fires on every navigation end.

### Why this approach (not alternatives)

- **Shared service + Subject**: Over-engineered for a single-component bug. Adds complexity.
- **`ngDoCheck` or `onSameUrlNavigation`**: Angular anti-patterns. Router events subscription is the standard approach.
- **Only `loadData()`**: Would miss the navigation-back case (user just clicks sidebar, no action triggers `loadData`).
