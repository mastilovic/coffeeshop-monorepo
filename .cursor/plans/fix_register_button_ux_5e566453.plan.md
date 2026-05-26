---
name: Fix register button UX
overview: "The Create Account button looks clickable but does nothing because Angular form validation fails silently—the button is only disabled during API loading, not when the form is invalid. The fix aligns register with other forms: disable the button when invalid, show field errors on submit, and add hints for strict username/password rules."
todos:
  - id: disable-invalid
    content: Change submit button to [disabled]="form.invalid || loading()"
    status: completed
  - id: submit-feedback
    content: "On invalid submit: markAllAsTouched() + optional validation banner in errorMessage"
    status: completed
  - id: field-errors
    content: Add form-error spans per field (touched + hasError) for name, username, email, password
    status: completed
  - id: field-hints
    content: Add username/password helper hints under labels
    status: completed
  - id: manual-verify
    content: Manually verify disabled/enabled states and error messages on /register
    status: completed
isProject: false
---

# Fix /register Create Account button

## Root cause

In [`register.component.ts`](coffeeshop-frontend/src/app/features/auth/register.component.ts):

```65:67:coffeeshop-frontend/src/app/features/auth/register.component.ts
            <button type="submit" class="btn btn-primary btn-block" [disabled]="loading()">
              {{ loading() ? 'Creating account...' : 'Create Account' }}
            </button>
```

```97:98:coffeeshop-frontend/src/app/features/auth/register.component.ts
  onSubmit(): void {
    if (this.form.invalid) return;
```

The button is **only** disabled while `loading()` is true. Invalid forms still look enabled (full opacity, normal cursor). A click runs `onSubmit()`, hits `if (this.form.invalid) return`, and exits with **no feedback**.

Hidden validators users often trip without knowing:

| Field | Rule | Common mistake |
|-------|------|----------------|
| username | `^[a-zA-Z0-9_]{3,30}$` | spaces, hyphens, `@`, or fewer than 3 chars |
| password | min 6 chars | short password |
| email | `Validators.email` | typo in domain |

Backend matches username rules in [`RegisterRequest.java`](coffeeshop/src/main/java/com/coffeeshop/coffeeshop/auth/RegisterRequest.java).

Other forms in the app already disable submit when invalid (e.g. [`profile.component.ts`](coffeeshop-frontend/src/app/features/profile/profile.component.ts) line 58, [`events.component.ts`](coffeeshop-frontend/src/app/features/events/events.component.ts) line 83). Register (and login) are inconsistent.

```mermaid
flowchart TD
  click[User clicks Create Account]
  click --> submit[onSubmit]
  submit --> check{form.valid?}
  check -->|no| silent[return silently - current bug]
  check -->|yes| api[registerAndLogin API]
  silent --> looksEnabled[Button still looks enabled]
```

## Implementation (single file)

**File:** [`coffeeshop-frontend/src/app/features/auth/register.component.ts`](coffeeshop-frontend/src/app/features/auth/register.component.ts)

### 1. Disable button when form is invalid

Match profile/events pattern:

```html
[disabled]="form.invalid || loading()"
```

Existing global `.btn:disabled` styles in [`styles.css`](coffeeshop-frontend/src/styles.css) (opacity 0.5, `not-allowed` cursor) will then clearly indicate when submit is blocked.

### 2. Surface validation on submit attempt

In `onSubmit()`, when invalid:

- Call `this.form.markAllAsTouched()` so touched-based error messages appear
- Optionally set a short banner via existing `errorMessage()` signal, e.g. *"Please fix the errors below."* (cleared on successful resubmit)

### 3. Per-field error messages

Follow the pattern used in [`events.component.ts`](coffeeshop-frontend/src/app/features/events/events.component.ts) (`form-error` + `touched` + `hasError`):

- **name** — required: "Name is required."
- **username** — required / pattern: "Username is required." / "Use 3–30 letters, numbers, or underscores only."
- **email** — required / email: "Email is required." / "Enter a valid email address."
- **password** — required / minlength: "Password is required." / "Password must be at least 6 characters."

Use existing `.form-error` class from [`styles.css`](coffeeshop-frontend/src/styles.css) (lines 312–316). No new CSS required.

### 4. Preventive hints (optional but high value)

Add subtle helper text under labels (not errors) so users do not hit silent failures:

- Username: `3–30 characters, letters, numbers, and underscores only`
- Password: `At least 6 characters`

Can be a small muted line or extend placeholders—keep consistent with auth page styling.

## Out of scope (unless you want it)

- **Login page** ([`login.component.ts`](coffeeshop-frontend/src/app/features/auth/login.component.ts)) has the same `[disabled]="loading()"` + silent `form.invalid` return pattern. Same fix can be applied in a follow-up.
- **form-select overlay** — unlikely cause; role defaults to `customer` and is valid. No change needed unless QA reproduces click interception with dropdown open.

## Verification

1. Open `/register` with empty fields — button disabled (dimmed).
2. Fill name, email, role; use username `ab` or `my name` — button stays disabled; after touching fields, errors visible.
3. Valid username `test_user`, password `secret`, valid email — button enabled; submit succeeds (or shows API error in red banner, which is expected).
4. During submit — button shows "Creating account..." and is disabled via `loading()`.

No backend or route changes required.
