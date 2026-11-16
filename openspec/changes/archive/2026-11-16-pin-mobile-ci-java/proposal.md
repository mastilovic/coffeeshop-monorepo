# Proposal

## Why

Mobile CI `build-android` on `main` fails during `flutter build apk --release` with a cryptic Gradle error whose entire message is `25.0.5`. GitHub-hosted `ubuntu-latest` runners now default to JDK 25; the app’s Gradle 8.12 toolchain does not support JDK 25, so `assembleRelease` aborts before an APK is produced. Play packaging and release verification need a green Android CI job.

## What Changes

- Pin a Gradle-compatible JDK (Java 17 Temurin) in the Mobile CI `build-android` job before the Flutter/Gradle release build.
- Leave `analyze`, `test`, and `build-ios` unchanged unless they later need the same pin.
- No application Dart/Android product code changes; no **BREAKING** API or runtime behavior changes for end users.

## Capabilities

### New Capabilities

- `mobile-ci`: Continuous integration contract for the phone app’s Android release build on `main`, including the JDK used to run Gradle.

### Modified Capabilities

- (none)

## Impact

- `.github/workflows/mobile-ci.yml` (`build-android` job): add `actions/setup-java` (or equivalent) pinning Java 17 before `flutter build apk --release`.
- CI only: no changes to `coffeeshop-mobile` app sources, Play listing assets, or staging/web deploy.
- After merge to `main`, Mobile CI should produce and upload the `android-apk` artifact again.
