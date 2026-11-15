# Tasks

## 1. Public web privacy policy page

- [x] 1.1 Write a failing frontend test that navigating to `/privacy-policy` without auth renders a page whose content mentions accounts/identity (Keycloak), reservations, and billing or subscriptions, and uses the short product name `Find`. Run the test and confirm RED (missing route/component).
- [x] 1.2 Add a public top-level `privacy-policy` route (no `authGuard` / `guestGuard`, not under `LayoutComponent`) and a standalone privacy-policy component with draft English copy covering those topics. Re-run the test from 1.1 and confirm GREEN. Run the relevant frontend tests and confirm no regressions.

## 2. Web entry points

- [x] 2.1 Write failing tests that login, register, and profile pages each expose a Privacy Policy link to `/privacy-policy`. Run them and confirm RED.
- [x] 2.2 Add the Privacy Policy links on login, register, and the signed-in profile view. Re-run the tests from 2.1 and confirm GREEN.

## 3. Mobile Profile opens hosted URL

- [x] 3.1 Add `url_launcher` to `coffeeshop-mobile` and a privacy-policy URL on `AppConfig` defaulting to `https://app.kafenerija.online/privacy-policy`. Verify `flutter pub get` succeeds and the constant resolves to that URL in a small unit test (or existing config test pattern).
- [x] 3.2 Write a failing Profile test that choosing Privacy Policy invokes launching `AppConfig`’s privacy-policy URL (mock the launcher). Run it and confirm RED.
- [x] 3.3 Add the Profile Privacy Policy action that opens the configured URL in the system browser (no in-app duplicate policy body). Re-run the test from 3.2 and confirm GREEN. Run `flutter test` for the affected suite and confirm it passes.

## 4. Integration check and feature note

- [x] 4.1 Manually or via targeted tests confirm: unauthenticated `/privacy-policy` does not redirect to login; signed-in access still shows the page; mobile action uses the absolute `/privacy-policy` URL. Record the commands run.
- [x] 4.2 Write `obsidian/knowledge/features/add-privacy-policy.md` from `obsidian/templates/feature-note.md`. Record the public route, draft topics, web/mobile entry points, canonical URL, and verification commands. Link it from the Features section of `obsidian/INDEX.md`. Verify both files exist and the index link resolves.
