---
name: dashboard-two-column-redesign
overview: "Redesign dashboard with a two-column layout: compact inline stats bar at top, wide activity feed on the left, and side widgets (notifications, upcoming events, top shops, personal summary) on the right. Extend backend to return additional summary data."
todos:
  - id: extend-backend-response
    content: Extend dashboard handler response with topShops, upcomingEvents, personalSummary, and notifications queries
    status: completed
  - id: update-frontend-model
    content: Add new interfaces to dashboard.model.ts — TopShopItem, UpcomingEventItem, DashboardPersonalSummary, DashboardNotification
    status: completed
  - id: rewrite-dashboard-layout
    content: Rewrite dashboard.component.ts — slim inline stats bar, two-column layout, side widgets, mobile responsive
    status: completed
  - id: polish-styles
    content: Polish styles for slim stats bar, two-column grid, widget cards, notification badges, mobile collapse
    status: completed
isProject: false
---

# Dashboard Two-Column Redesign

## Problem
The 4 large stat cards dominate the page and push the meaningful activity feed below the fold. The dashboard should prioritize recent activity, with stats being secondary.

## Solution
Two-column layout with a slim inline stats bar at the very top.

### Layout Structure
```
┌─────────────────────────────────────────────────────┐
│  Dashboard                                          │
│  ☕ 12 shops   ⭐ 48 reviews   👥 230 members   📅 8 │  ← slim inline stats bar
├──────────────────────────┬──────────────────────────┤
│                          │  ⚠ Notifications (3)      │
│  RECENT ACTIVITY         │  Pending requests...      │
│  ┌────────────────────┐  │                          │
│  │ ● Today            │  │  📅 Upcoming Events       │
│  │  Shop X: New event │  │  Jun 8 - Coffee Tasting   │
│  │  "Latte Art Comp"  │  │  Jun 12 - Open Mic       │
│  │  ★★★★☆ by Ana     │  │                          │
│  ├────────────────────┤  │  🏆 Top Shops            │
│  │ ● Yesterday        │  │  1. Downtown Brew ★4.8   │
│  │  Shop Y: Review    │  │  2. Riverside ★4.5       │
│  │  "Great place!"    │  │  3. Garden Cafe ★4.3     │
│  │  ★★★★★ by Mark    │  │                          │
│  └────────────────────┘  │  👤 Your Summary          │
│                          │  3 Favourites             │
│                          │  2 Reservations           │
│                          │  5 Reviews written        │
├──────────────────────────┴──────────────────────────┤
│  Mobile: single column, widgets collapse below feed  │
└─────────────────────────────────────────────────────┘
```

---

## Backend Changes

### Extend `GET /api/v2/dashboard/activity` response

**File:** `coffeeshop-go/internal/handler/dashboard.go`

Add new fields to the response struct:

```go
type dashboardActivityResponse struct {
    Aggregate      dashboardAggregate       `json:"aggregate"`
    Activities     []dashboardActivityItem  `json:"activities"`
    TopShops       []topShopItem            `json:"topShops"`
    UpcomingEvents []upcomingEventItem      `json:"upcomingEvents"`
    PersonalSummary dashboardPersonalSummary `json:"personalSummary"`
    Notifications  []dashboardNotification  `json:"notifications"`
}

type topShopItem struct {
    ShopID        string   `json:"shopId"`
    ShopName      string   `json:"shopName"`
    City          string   `json:"city"`
    AverageRating *float64 `json:"averageRating"`
    ReviewCount   int      `json:"reviewCount"`
}

type upcomingEventItem struct {
    EventID     string `json:"eventId"`
    EventName   string `json:"eventName"`
    EventDate   string `json:"eventDate"`
    ShopID      string `json:"shopId"`
    ShopName    string `json:"shopName"`
}

type dashboardPersonalSummary struct {
    FavouriteShops   int `json:"favouriteShops"`
    Reservations     int `json:"reservations"`
    ReviewsWritten   int `json:"reviewsWritten"`
}

type dashboardNotification struct {
    Type    string `json:"type"`    // "pending_requests", "new_reviews"
    Message string `json:"message"`
    Count   int    `json:"count"`
    Link    string `json:"link"`    // optional deep link
}
```

**New queries added to handler:**
1. **Top shops** (top 5 by average rating, scoped): `SELECT s.id, s.name, s.city, AVG(r.rating) as avg_rating, COUNT(r.id) as review_count FROM shop s LEFT JOIN review r ON r.shop_id = s.id WHERE s.id IN (scope) GROUP BY s.id ORDER BY avg_rating DESC LIMIT 5`
2. **Upcoming events** (next 10, scoped): same as existing but returned separately for the widget
3. **Personal summary**: count favourites, reservations, reviews for the current user
4. **Notifications**: count pending reservation requests for scoped shops

---

## Frontend Changes

### Rewrite `dashboard.component.ts`

**File:** `coffeeshop-frontend/src/app/features/dashboard/dashboard.component.ts`

**Template structure:**

1. **Slim inline stats bar** — horizontal row, 4 items each with icon + number, compact, border-bottom separator
2. **Two-column grid** (desktop) / single column (mobile):
   - **Left column (flex: 1, ~65%)**: Activity feed with timeline design (keep existing, polish)
   - **Right column (width: ~320px, ~35%)**: Stacked widgets:
     - Notifications widget (collapsible, shows count badge)
     - Upcoming events widget (compact list, clickable)
     - Top shops widget (numbered list with rating stars)
     - Personal summary widget (icon + count rows)

3. **Mobile**: All widgets stack below the activity feed in single column

**Component class:**
- New signals: `topShops`, `upcomingEvents`, `personalSummary`, `notifications`
- Update model interfaces to match extended backend response
- `relativeTime()` stays
- Keep `OnPush` change detection

### Update `dashboard.model.ts`

**File:** `coffeeshop-frontend/src/app/models/dashboard.model.ts`

Add interfaces for new response fields: `TopShopItem`, `UpcomingEventItem`, `DashboardPersonalSummary`, `DashboardNotification`.

### Styles (embedded in component)

- Slim stats bar: `display: flex; gap: 1.5rem; padding: 0.5rem 0; font-size: 0.85rem; border-bottom: 1px solid #2a2a3e`
- Two-column layout: `display: flex; gap: 2rem` (desktop), `flex-direction: column` (mobile)
- Right column: `flex: 0 0 320px` (desktop), full width (mobile)
- Widget cards: compact, rounded, border, subtle background, consistent spacing
- Notification badge: small colored pill

---

## Files to Modify
- `coffeeshop-go/internal/handler/dashboard.go` — extend response struct and add new queries
- `coffeeshop-frontend/src/app/models/dashboard.model.ts` — add new interfaces
- `coffeeshop-frontend/src/app/features/dashboard/dashboard.component.ts` — two-column layout rewrite

## Files to Create
None — all changes are modifications to existing files
