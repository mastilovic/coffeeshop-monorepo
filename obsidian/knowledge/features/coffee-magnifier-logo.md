---
title: Coffee magnifier logo
change: coffee-magnifier-logo
created: 2026-11-14
updated: 2026-11-14
status: implemented
tags:
  - feature
  - openspec
---

# Coffee magnifier logo

## What It Does

Launcher icons, browser favicons, installable web icons, and the Play listing use the coffee-cup magnifier: a cream cup and handle shaped like a magnifying glass, brown coffee in the lens, and cream steam, on a charcoal field. Square icons have no wordmark. The Play feature graphic keeps the copy `Find`, `Cafes & Events`, and `Cafes and events, nearby.`

## Behavior

Installed and store images show that mark, including the smallest 16px macOS slot. The web sidebar still shows the coffee emoji beside `Find: Cafes & Events`. The phone login screen still shows the Material coffee icon. Scenarios are in the change spec: [app-brand delta](../../../openspec/changes/coffee-magnifier-logo/specs/app-brand/spec.md).

## Where It Lives

- Master: `coffeeshop-mobile/assets/brand/coffee-magnifier-icon.png` (centered crop of the source artwork).
- Pixel check: `scripts/check_coffee_mark.py`.
- Derived icons: Android `mipmap-*/ic_launcher.png`, iOS and macOS AppIcon sets, `coffeeshop-mobile/windows/runner/resources/app_icon.ico`, Flutter `web/favicon.png` and `web/icons/`, Angular `coffeeshop-frontend/public/favicon.png` and `favicon.ico`, Play `store/google-play/app-icon-512.png` and `feature-graphic-1024x500.png`.

## Verification

- `python3 scripts/check_coffee_mark.py --size 48 coffeeshop-frontend/public/favicon.png` failed on the previous teal magnifier (no brown cup pixel), then passed after the swap. The same check passed on the 16px macOS icon, the 192px Android icon, the iOS 1024 icon, the Flutter 512 icon, and the Play 512 icon.
- The feature graphic is 1024×500, with brown pixels on the left half and the existing wordmark on the right.
- `npm test` in `coffeeshop-frontend`: 71 passed.
- `flutter test` in `coffeeshop-mobile`: all tests passed.

## OpenSpec

- Change: `openspec/changes/coffee-magnifier-logo/`
