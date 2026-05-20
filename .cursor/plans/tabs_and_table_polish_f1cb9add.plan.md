---
name: Tabs and table polish
overview: Shrink primary tabs to content width (like the original underline tabs) and tighten panel/table styling so sub-tabs connect cleanly to the data table with no awkward gap or double borders.
todos:
  - id: primary-tabs-fit-content
    content: Set .tabs--primary to inline-flex/fit-content; remove flex:1 from primary .tab buttons
    status: pending
  - id: panel-table-flush
    content: Zero panel-body padding for tables; scope empty-state padding; remove inner table-container border in panel
    status: pending
  - id: verify-layout
    content: Build frontend and visually confirm primary width + flush table under sub-tabs
    status: pending
isProject: false
---

# Primary tab width and panel table polish

## Issues

| Issue | Cause |
|-------|--------|
| My Reservations / Manage my Shops stretch full width | [`styles.css`](coffeeshop-frontend/src/styles.css) `.tabs--primary .tab { flex: 1 }` (line 605) |
| Gap between sub-tabs and table | `.tabs-nav__panel-body { padding: 1rem 1.25rem }` plus nested `.table-container` border/radius inside an already-bordered panel |

No TypeScript changes required; markup in [`reservations.component.ts`](coffeeshop-frontend/src/app/features/reservations/reservations.component.ts) stays as-is.

## 1. Primary tabs — content width (not full bleed)

In [`styles.css`](coffeeshop-frontend/src/styles.css), update `.tabs--primary`:

- Add `display: inline-flex` and `width: fit-content` (with `max-width: 100%` for small screens)
- Remove `flex: 1` from `.tabs--primary .tab` so each button sizes to its label (same behavior as the original `.tabs` row)

Result: segmented control hugs the two labels, aligned left under the page header like before.

## 2. Panel body — flush table layout

Tighten `.tabs-nav__panel-body` and scoped children:

```css
.tabs-nav__panel-body {
  padding: 0;
}

/* Empty/loading only — keep breathing room */
.tabs-nav__panel-body .empty-state,
.tabs-nav__panel-body .loading {
  padding: 1.25rem;
}

/* Table flush under sub-tab header — no gap, no double frame */
.tabs-nav__panel-body .table-container {
  margin: 0;
  border: none;
  border-radius: 0;
}

.tabs-nav__panel-body .data-table th:first-child,
.tabs-nav__panel-body .data-table td:first-child {
  padding-left: 1.25rem;
}

.tabs-nav__panel-body .data-table th:last-child,
.tabs-nav__panel-body .data-table td:last-child {
  padding-right: 1.25rem;
}
```

Effects:

- Sub-tab header (`#16213e`) sits directly above the table; no padded “dead zone”
- Single visual frame from `.tabs-nav__panel` border (no inner box around the table)
- Horizontal cell padding preserves readable margins without outer body padding
- Pending manage tab keeps `table-container--dropdown-safe` (overflow unchanged)

Optional subtle polish: last tbody row bottom padding via existing `.data-table td` rules — no template change.

## 3. Sub-tab header — minor alignment

Keep header strip as-is; optionally reduce horizontal padding on `.tabs-nav__panel-header .tabs--sub` from `0 0.5rem` to `0` so sub-tabs align with table column inset (1.25rem). Low-risk tweak in the same CSS block.

## Files touched

- [`coffeeshop-frontend/src/styles.css`](coffeeshop-frontend/src/styles.css) only

## Verification

As shop owner on Reservations:

1. Primary bar is only as wide as “My Reservations” + “Manage my Shops”, left-aligned
2. Switching sub-tabs: table starts immediately under the sub-tab row (no visible gap)
3. Table reads as part of the panel (one border around the whole card)
4. Empty states still have comfortable padding
5. Manage → Pending: table dropdown still not clipped

Build: `npm run build` in `coffeeshop-frontend`.
