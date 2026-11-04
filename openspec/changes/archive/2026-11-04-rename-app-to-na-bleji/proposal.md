# Proposal

## Why

The product is still presented as CoffeeShop. The name people should read is **na bleji**, lowercase, on every surface they can see.

## What Changes

- Replace the user-visible product name with the exact string `na bleji` in the web app, the phone app, the browser tab, and the names under the home-screen icons.
- Auth copy becomes "Sign in to your na bleji account" and "Join na bleji today".
- Package names, modules, Keycloak realm and client ids, container images, Kubernetes names, token storage keys, folders, and the `kafenerija.online` hosts stay as they are.
- The hosted Keycloak page keeps showing the realm id `coffeeshop`.

## Capabilities

### New Capabilities

- `app-brand`: The product name shown to users on web, mobile, browser chrome, and home-screen labels.

### Modified Capabilities

## Impact

- Web: sidebar brand, login subtitle, register subtitle, and document title in `coffeeshop-frontend`.
- Mobile: login heading, app-switcher title, Android `android:label`, iOS `CFBundleDisplayName`, and the Flutter web install name and title in `coffeeshop-mobile`.
- Tests that assert the old visible name.
- No API, auth, or deploy changes.
