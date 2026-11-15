---
title: Privacy policy page
change: add-privacy-policy
created: 2026-11-15
updated: 2026-11-15
status: implemented
tags:
  - feature
  - openspec
---

# Privacy policy page

## What It Does

Find exposes a public draft privacy policy at `/privacy-policy` on the web app. Login, register, and profile link to it. The phone Profile screen opens the same hosted URL in the system browser.

## Behavior

- Unauthenticated and signed-in visitors can open `/privacy-policy` without being forced through login.
- Draft copy covers accounts/identity (Keycloak), reservations, and billing/subscriptions, and names the product `Find`.
- Web entry points: login, register, profile.
- Mobile opens `https://app.kafenerija.online/privacy-policy` (from `AppConfig.privacyPolicyUrl`); it does not embed a native copy of the policy body.

Spec: `openspec/changes/add-privacy-policy/specs/privacy-policy/spec.md`

## Where It Lives

- Web route: `coffeeshop-frontend/src/app/app.routes.ts`
- Page: `coffeeshop-frontend/src/app/features/privacy-policy/privacy-policy.component.ts`
- Links: login, register, profile components
- Mobile URL: `coffeeshop-mobile/lib/core/config/app_config.dart`
- Mobile action: `coffeeshop-mobile/lib/features/profile/profile_screen.dart` (`url_launcher`)

## Verification

- `npx ng test --watch=false --include=src/app/features/privacy-policy/privacy-policy.component.spec.ts --include=src/app/features/auth/login.component.spec.ts --include=src/app/features/auth/register.component.spec.ts --include=src/app/features/profile/profile.component.spec.ts` (7 passed)
- `flutter test test/features/profile/profile_privacy_policy_test.dart test/core/config/app_config_test.dart` (passed)

## OpenSpec

- Change: `openspec/changes/add-privacy-policy/`
