# Proposal

## Why

Store listings and users need a reachable privacy policy. Neither the Angular SPA nor the Flutter app exposes one today, and almost every web route requires authentication, so a store URL cannot work until a public page exists.

## What Changes

- Add a public web route at `/privacy-policy` with draft policy copy covering accounts/identity (Keycloak), reservations, and billing/subscriptions. The page is reachable without signing in.
- Link to that page from the web login and register screens and from the signed-in web profile screen.
- On mobile, add a Profile action that opens the same public URL in the system browser (single source of truth; no duplicated in-app policy screen).
- Document the canonical URL for Google Play: `https://app.kafenerija.online/privacy-policy`.

Out of scope for this change: terms of service, register consent checkbox, cookie banner, in-app WebView, Serbian localization, and final attorney-reviewed legal copy.

## Capabilities

### New Capabilities

- `privacy-policy`: Public privacy policy page on web, in-app entry points on web and mobile, and the canonical public URL used by both clients.

### Modified Capabilities

- (none)

## Impact

- Frontend: new public route in `coffeeshop-frontend/src/app/app.routes.ts`, new privacy-policy feature component, links on login/register/profile.
- Mobile: Profile link in `coffeeshop-mobile/lib/features/profile/profile_screen.dart`; new `url_launcher` dependency and a configured privacy-policy base URL.
- No backend API, auth, or Keycloak changes.
- Draft policy text is product-accurate but not final legal counsel; refine later without changing the route or integration points.

## Assumptions

- English-only draft for v1.
- Mobile opens the hosted web page rather than embedding a native copy.
- Staging host `app.kafenerija.online` is the canonical public URL until a separate production host is introduced.
