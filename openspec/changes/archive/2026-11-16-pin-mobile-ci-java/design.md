# Design

## Context

See proposal.md for motivation. Today `.github/workflows/mobile-ci.yml` `build-android` checks out, installs Flutter 3.32.7, runs `flutter pub get`, then `flutter build apk --release` with no explicit JDK setup. Gradle wrapper is 8.12 (`coffeeshop-mobile/android/gradle/wrapper/gradle-wrapper.properties`). GitHub `ubuntu-latest` now supplies JDK 25 by default; Gradle 8.12 fails early with the bare error `25.0.5`. No other workflow in this repo currently uses `actions/setup-java`.

## Goals / Non-Goals

**Goals:**

- Make `build-android` use a fixed, Gradle-supported JDK before the Flutter/Gradle release build.
- Keep the change minimal and local to Mobile CI Android packaging.
- Provide a small, deterministic check that the workflow pins Java 17 (TDD-friendly RED→GREEN on the YAML contract).

**Non-Goals:**

- Upgrading Gradle / AGP / Flutter to gain JDK 25 support.
- Changing `compileSdk` / `targetSdk` / signing / applicationId.
- Pinning Java on `analyze`, `test`, or `build-ios` unless a later failure shows they need it.
- Fixing the separate CI/CD Staging “deploy skipped” issue.

## Decisions

1. **Pin Java 17 (Temurin) via `actions/setup-java@v4` in `build-android` only**
   - Rationale: Java 17 is the LTS Flutter/Android CI docs commonly recommend; Gradle 8.12 supports 17 (and 21). Temurin is the usual Actions distribution.
   - Place the step after checkout and before (or immediately after) `subosito/flutter-action`, and always before `flutter build apk --release`, so `JAVA_HOME` is set for Gradle.
   - Alternative considered: Java 21 — also supported by Gradle 8.12; prefer 17 as the safer, more common Flutter CI pin.
   - Alternative considered: upgrade Gradle to a JDK-25-capable release — larger blast radius; out of scope.

2. **Contract test as a small script that asserts the workflow YAML**
   - Rationale: product TDD still applies to the CI contract; a local script can fail RED before the pin exists and GREEN after, without waiting on a full Actions run for the RED phase.
   - Assert at least: `build-android` job contains `actions/setup-java` (or `@v4`) and `java-version: '17'` (or equivalent `17`) ahead of the release APK step.
   - Final verification remains a Mobile CI `build-android` run on `main` (or a workflow_dispatch/re-run after merge).

3. **Do not change path filters or job `if` gates**
   - Keep `build-android` on `main` only; this change only makes that job succeed when it runs.

## Risks / Trade-offs

- [Runner image changes again] → Mitigation: explicit `setup-java` keeps the job independent of runner defaults.
- [Flutter action overwrites JAVA_HOME] → Mitigation: if a future Flutter action reset is observed, reorder so `setup-java` runs after `flutter-action`, or set `java-version` in both places; verify with one CI run.
- [Java 17 too old for a future AGP bump] → Mitigation: bump the pinned major in the same workflow when Gradle/AGP requirements change; keep the contract test’s expected version in sync.

## Migration Plan

1. Land the workflow pin + contract script on a branch; merge to `main` (or re-run Mobile CI after merge).
2. Confirm `build-android` is green and `android-apk` artifact uploads.
3. Rollback: remove the `setup-java` step (reverts to runner default; expected to fail again on JDK 25 runners).
