# Proposal

## Why

The product is still presented as `na bleji`. Users should read **Find: Cafes & Events** as the full product name, with **Find** as the short name on constrained surfaces (home screen, launcher, PWA short name).

## What Changes

- Replace the user-visible product name: full string `Find: Cafes & Events` on in-app titles and browser chrome; short string `Find` on installed-app / launcher labels and PWA `short_name`.
- Auth copy uses the short name: `Sign in to your Find account` and `Join Find today` (assumption recorded until overturned).
- No logo or icon asset changes in this change (coffee glyph / `Icons.coffee` / current launcher icons stay).
- Package names, modules, Keycloak realm and client ids, container images, Kubernetes names, token storage keys, folders, and public hosts stay as they are.
- The hosted Keycloak page keeps showing the realm id `coffeeshop`.

## Capabilities

### New Capabilities

### Modified Capabilities

- `app-brand`: Replace the `na bleji` visible-name and installed-label requirements with full name `Find: Cafes & Events`, short name `Find`, and short-name auth copy. Identity-and-hosts requirement stays.

## Impact

- Web: sidebar brand, login subtitle, register subtitle, and document title in `coffeeshop-frontend`.
- Mobile: `AppConfig` brand constants, login heading, app-switcher title, Android `android:label`, iOS/macOS display names, Flutter web install name / short name / titles in `coffeeshop-mobile`.
- Tests that assert the old visible name (none known today; verify during apply).
- No API, auth, or deploy changes.
