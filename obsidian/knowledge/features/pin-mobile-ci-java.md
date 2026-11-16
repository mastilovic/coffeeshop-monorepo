---
title: Pin Mobile CI Java 17
change: pin-mobile-ci-java
created: 2026-11-16
updated: 2026-11-16
status: implemented
tags:
  - feature
  - openspec
  - ci
---

# Pin Mobile CI Java 17

## What It Does

Mobile CI `build-android` pins Temurin Java 17 before `flutter build apk --release`, so Gradle 8.12 does not run on the GitHub runner’s default JDK 25 (which failed with the bare error `25.0.5`).

## Behavior

- Inspecting the workflow shows `actions/setup-java` with `java-version: '17'` in `build-android` before the release APK step.
- On `main`, with analyze/test green, `build-android` produces and uploads the `android-apk` artifact.

Spec delta: `openspec/changes/pin-mobile-ci-java/specs/mobile-ci/spec.md`.

## Where It Lives

- Workflow: `.github/workflows/mobile-ci.yml` (`build-android`)
- Contract check: `scripts/check_mobile_ci_java_pin.py`

## Verification

- `python3 scripts/check_mobile_ci_java_pin.py` → exit 0
- Mobile CI on `main`: https://github.com/mastilovic/coffeeshop-monorepo/actions/runs/43782884617 — `build-android` success; artifact `android-apk` (~25 MB)

## OpenSpec

- Change: `openspec/changes/pin-mobile-ci-java/`
