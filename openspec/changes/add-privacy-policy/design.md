# Design

## Context

See proposal.md. Web routes today put `/login` and `/register` behind `guestGuard` and nest everything else under `LayoutComponent` with `authGuard`. There is no public content route and no footer/legal pattern. Mobile Profile has Billing / Browse Users / Logout only; `pubspec.yaml` has no `url_launcher` or WebView. Staging SPA is `https://app.kafenerija.online` with nginx `try_files` so deep links resolve once routed.

## Goals / Non-Goals

**Goals:**

- One public Angular page as the source of truth for policy copy.
- Same URL usable by Google Play and by both clients.
- Minimal new mobile surface: open URL from Profile.

**Non-Goals:**

- Native/WebView policy UI, terms of service, consent checkbox, cookie banner, i18n, or attorney-final legal review.
- Backend endpoints or CMS for policy content.
- Changing auth guards for existing app routes.

## Decisions

### Public top-level Angular route (not under Layout)

Add `path: 'privacy-policy'` as a sibling of `login`/`register` with `loadComponent`, **no** `authGuard` and **no** `guestGuard`. Do not nest under the authenticated `LayoutComponent`; store crawlers and logged-out users must reach it.

Place the component at `coffeeshop-frontend/src/app/features/privacy-policy/` as a standalone component with inline template (same pattern as auth pages). Style as a readable document page (title, last-updated line, section headings) without inventing a new design system.

Alternative considered: static HTML under `public/privacy-policy.html`. Rejected because SPA styling and RouterLink from auth pages would be inconsistent, and nginx already supports the SPA path.

### Draft copy owned by the web page

Embed English draft sections covering: what Find is; account/identity data and Keycloak; reservations; billing/subscriptions; how to contact; that the draft may be updated. Keep the text honest and high-level; do not invent processors or retention periods the product does not have. Mark the page as a draft if useful for honesty, but do not make the page a “coming soon” stub.

### Web links without a site-wide footer

Add a Privacy Policy `routerLink` on login and register footers and on the profile view (near other account actions). Do not add a global footer or sidebar nav item in this change.

### Mobile: `url_launcher` + configured base URL

Add `url_launcher`. On Profile, add an OutlinedButton (or equivalent) “Privacy Policy” that launches the absolute URL. Default host: `https://app.kafenerija.online`. Put the base URL in an existing env/config pattern if one exists for API hosts; otherwise a small constant/config near other app settings is enough for v1. Path is always `/privacy-policy`.

Alternative considered: duplicate Flutter screen with the same markdown. Rejected to avoid two copies drifting.

Alternative considered: in-app WebView. Rejected — new dependency and chrome for little benefit; Play only needs a public URL.

### Testing

- Frontend: component/route tests that `/privacy-policy` renders required topic markers without auth; login/register/profile expose a link to that path (follow existing `*.spec.ts` patterns such as `login.component.spec.ts`).
- Mobile: unit/widget test that the Profile privacy action invokes the launcher with the expected URL (mock `url_launcher` / launch callback). Prefer behavior over implementation details.

## Risks / Trade-offs

- [Draft copy is not legal counsel] → Label as draft/updateable; refine later without changing route or links.
- [Mobile users offline cannot read policy] → Accept for v1; store and most users need the hosted URL.
- [Canonical host changes for true production] → Isolate host in config; path stays `/privacy-policy`.
- [guestGuard on login/register does not apply to policy] → Explicitly leave policy unguarded so signed-in users can also open it.

## Migration Plan

Deploy frontend so `/privacy-policy` is live, then ship the mobile build that links to it. Rollback: remove route/links and the Profile action; store listing URL can be cleared until republished.

## Open Questions

None blocking. Contact email/address for the draft can use a placeholder product contact if none is published yet, and be updated when a real contact is chosen.
