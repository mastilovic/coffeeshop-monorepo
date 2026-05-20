---
name: Comments Toggle Switch
overview: Replace the two "Allow comments" checkboxes in the shop Reviews UI with styled toggle switches that match the dark theme, without changing backend behavior or form logic.
todos:
  - id: toggle-styles
    content: Add .toggle-switch / .toggle-slider styles to styles.css
    status: completed
  - id: toggle-shop-details
    content: Replace both Allow comments checkboxes in shop-details.component.ts with toggle markup
    status: completed
isProject: false
---

# Allow comments: checkbox to toggle switch

## Scope

UI-only change in [`shop-details.component.ts`](coffeeshop-frontend/src/app/features/shop-details/shop-details.component.ts). No API or form model changes (`commentsEnabled` stays a boolean checkbox under the hood).

Two places to update:

1. **Leave review form** (lines ~425–429) — `formControlName="commentsEnabled"`
2. **Review author control** on each card (lines ~449–456) — `[checked]` + `(change)` calling `onCommentsEnabledChange`

There is no existing toggle component in the app; checkboxes are used elsewhere only.

## Implementation

### 1. Add global toggle styles

Add reusable classes to [`styles.css`](coffeeshop-frontend/src/styles.css) (fits existing global form/button patterns):

```css
.toggle-switch {
  display: inline-flex;
  align-items: center;
  gap: 0.75rem;
  cursor: pointer;
  user-select: none;
}
.toggle-switch input {
  position: absolute;
  opacity: 0;
  width: 0;
  height: 0;
}
.toggle-slider {
  width: 44px;
  height: 24px;
  background: #374151;
  border-radius: 999px;
  position: relative;
  transition: background 0.2s;
  flex-shrink: 0;
}
.toggle-slider::after {
  content: '';
  position: absolute;
  top: 2px;
  left: 2px;
  width: 20px;
  height: 20px;
  background: #fff;
  border-radius: 50%;
  transition: transform 0.2s;
}
.toggle-switch input:checked + .toggle-slider {
  background: #d4a574; /* matches accent in styles.css */
}
.toggle-switch input:checked + .toggle-slider::after {
  transform: translateX(20px);
}
.toggle-switch input:focus-visible + .toggle-slider {
  outline: 2px solid #d4a574;
  outline-offset: 2px;
}
```

### 2. Replace markup in shop-details template

**Leave review form:**

```html
<label class="toggle-switch">
  <input type="checkbox" formControlName="commentsEnabled" />
  <span class="toggle-slider" aria-hidden="true"></span>
  <span>Allow comments on this review</span>
</label>
```

**Review author row:**

```html
<label class="toggle-switch" style="margin-top:0.75rem;font-size:0.875rem">
  <input
    type="checkbox"
    [checked]="r.commentsEnabled"
    (change)="onCommentsEnabledChange(r, $any($event.target).checked)" />
  <span class="toggle-slider" aria-hidden="true"></span>
  <span>Allow comments</span>
</label>
```

Keep `isReviewAuthor(r)` guard unchanged.

### 3. Verify

- Run `npm run build` in `coffeeshop-frontend`
- Manually: toggle on/off in leave-review form; author toggle on existing review still calls `PUT` and shows/hides comment form

## Optional (out of scope)

Extract `app-toggle-switch` with `ControlValueAccessor` if toggles are needed elsewhere later; not required for this task.
