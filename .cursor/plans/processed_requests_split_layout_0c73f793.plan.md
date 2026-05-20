---
name: Processed requests split layout
overview: Restyle the shop details "Processed requests" section so Approved (left) and Denied (right) appear side-by-side in a two-column layout, stacking on narrow viewports—frontend-only in `shop-details.component.ts` and optional shared CSS.
todos:
  - id: processed-split-css
    content: "frontend-agent: Add .processed-requests-split grid styles to styles.css with mobile stack breakpoint"
    status: completed
  - id: processed-split-template
    content: "frontend-agent: Wrap Approved/Denied in two-column layout in shop-details.component.ts template"
    status: completed
  - id: processed-split-verify
    content: "frontend-agent: npm run build and spot-check shop reservations tab layout"
    status: completed
isProject: false
---

# Processed requests two-column layout

## Current state

In [`shop-details.component.ts`](coffeeshop-frontend/src/app/features/shop-details/shop-details.component.ts), **Processed requests** is already split logically:

- `pendingRequests` / `deniedRequests` computed signals and `reservations()` for approved (from prior work)
- **Approved** and **Denied** render as stacked blocks (h4 + table, one below the other) at lines 240–282

No TypeScript or API changes are needed.

## Target layout

```mermaid
flowchart TB
  subgraph processed [Processed requests h3]
    subgraph row [two_column_split]
      L[Left: Approved]
      R[Right: Denied]
    end
  end
  L --> reservationsAPI
  R --> deniedRequests computed
```

| Column | Position | Content (unchanged) |
|--------|----------|---------------------|
| **Approved** | Left 50% | `reservations()` table: Guest, Event, Table, Party Size |
| **Denied** | Right 50% | `deniedRequests()` table: Guest, Event, Party Size, Status |

Keep the parent **Processed requests** `h3`; move **Approved** / **Denied** `h4` headings inside each column.

## Implementation (`frontend-agent`)

### 1. Wrapper in template

Replace the stacked Approved/Denied blocks (lines 242–282) with a single wrapper, e.g.:

```html
<h3 class="mb-2 mt-3" ...>Processed requests</h3>
<div class="processed-requests-split">
  <div class="processed-requests-column">
    <h4>Approved</h4>
    <!-- existing approved empty state + table -->
  </div>
  <motion.div class="processed-requests-column">
    <h4>Denied</h4>
    <!-- existing denied empty state + table -->
  </div>
</div>
```

(Use `div`, not `motion.div` — typo-free.)

- Remove extra `mb-3` on inner table containers where the column gap is enough; keep `table-container` for horizontal scroll on small tables.
- Each column owns its empty state so one side can be empty while the other has data.

### 2. CSS

Add to [`styles.css`](coffeeshop-frontend/src/styles.css) (matches existing `.form-row` 2-column pattern at line 130):

```css
.processed-requests-split {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.5rem;
  align-items: start;
}

@media (max-width: 768px) {
  .processed-requests-split {
    grid-template-columns: 1fr;
  }
}
```

Optional: `.processed-requests-column { min-width: 0; }` so wide tables scroll inside the column instead of overflowing the grid.

Do not use `ngClass` / `ngStyle` per project conventions; class-only layout.

### 3. Accessibility

- Preserve `h3` → `h4` hierarchy under **Processed requests**.
- Tables and empty states unchanged; no new interactive controls.

### 4. Verification

- `npm run build` in `coffeeshop-frontend`.
- On `/shops/{id}` → Reservations: with both approved and denied data, columns appear left/right on desktop; stack vertically below ~768px width.

## Out of scope

- Pending requests layout (stays full width above Processed).
- Global `/reservations` page.
- Backend changes.

## Files touched

| File | Change |
|------|--------|
| [`shop-details.component.ts`](coffeeshop-frontend/src/app/features/shop-details/shop-details.component.ts) | Wrap Approved/Denied in two-column grid markup |
| [`styles.css`](coffeeshop-frontend/src/styles.css) | `.processed-requests-split` (+ optional column helper) |
