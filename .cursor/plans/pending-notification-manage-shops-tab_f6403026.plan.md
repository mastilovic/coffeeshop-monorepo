---
name: pending-notification-manage-shops-tab
overview: Add a notification dot to the "Manage my Shops" tab when pending reservation requests exist, without duplicating the count already shown on the Pending sub-tab.
todos:
  - id: add-dot-template
    content: Replace .tab__count with conditional .notif-dot in desktop tab template
  - id: add-mobile-count
    content: Add pending count to mobile select option
  - id: add-dot-css
    content: Add .notif-dot CSS class to styles.css
isProject: false
---

# Add Notification Dot to "Manage my Shops" Tab

## Background

The `/reservations` page has two top-level tabs for shop owners. Sub-tabs under "Manage my Shops" already show exact counts. Showing same number on parent tab is redundant. Instead: a subtle notification dot that appears when any pending requests exist.

## Changes Needed

### File 1: `coffeeshop-frontend/src/app/features/reservations/reservations.component.ts`

**1. Desktop "Manage my Shops" tab (lines 137-146)**

Replace the `.tab__count` badge with a conditional notification dot. The dot only renders when `managedPendingRequests().length > 0`.

Current:
```html
<span class="tab__label">Manage my Shops</span>
<span class="tab__count">{{ managedPendingRequests().length }}</span>
```

New:
```html
<span class="tab__label">Manage my Shops</span>
@if (managedPendingRequests().length > 0) {
  <span class="notif-dot" aria-label="Pending reservation requests"></span>
}
```

**2. Mobile select option (line 125)**

Keep count here since mobile has no visual sub-tab context:
```html
<option value="manage">Manage my Shops ({{ managedPendingRequests().length }})</option>
```
(Already done in previous change)

### File 2: `coffeeshop-frontend/src/styles.css`

**3. Add `.notif-dot` CSS**

```css
.notif-dot {
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #e74c3c;
  margin-left: 6px;
  flex-shrink: 0;
}
```
