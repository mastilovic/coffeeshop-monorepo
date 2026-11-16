# mobile-ci Specification

## Purpose

Defines the continuous-integration contract for producing a phone-app Android release APK on `main`, including the JDK Gradle must run under.

## Requirements

### Requirement: Android release build uses a Gradle-compatible JDK

The Mobile CI `build-android` job on `main` SHALL configure a JDK of major version 17 (Temurin or equivalent LTS distribution) for the job environment before invoking the Android release APK build. The configured JDK major version MUST be one supported by the repository’s Gradle wrapper used for that build (currently Gradle 8.12). The job MUST NOT rely on the GitHub-hosted runner’s default JDK when that default is unsupported by the Gradle wrapper.

#### Scenario: Workflow pins Java 17 for Android release

- **WHEN** the Mobile CI workflow definition for the `build-android` job is inspected
- **THEN** it configures Java 17 for that job before the release APK build step

#### Scenario: Unsupported runner default JDK is overridden

- **WHEN** the GitHub-hosted runner’s default JDK major version is 25 (or any major version unsupported by the project Gradle wrapper)
- **THEN** the `build-android` job still uses the pinned Java 17 toolchain for Gradle instead of that default

#### Scenario: Android release APK build can complete on main

- **WHEN** Mobile CI `build-android` runs on `main` with the pinned JDK and a green analyze/test gate
- **THEN** `flutter build apk --release` completes successfully and the job uploads the release APK artifact
