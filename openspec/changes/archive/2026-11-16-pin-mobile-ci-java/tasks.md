# Tasks

## 1. Contract check for Java pin

- [x] 1.1 Write a failing stdlib Python check (same style as `scripts/check_coffee_mark.py`) that reads `.github/workflows/mobile-ci.yml` and asserts the `build-android` job configures `actions/setup-java` with `java-version` 17 before the release APK build step. Run it and confirm RED (pin missing).
- [x] 1.2 Add `actions/setup-java@v4` to `build-android` in `.github/workflows/mobile-ci.yml` with Temurin Java 17, placed so `JAVA_HOME` is set before `flutter build apk --release`. Re-run the script from 1.1 and confirm GREEN. Do not change `analyze`, `test`, or `build-ios`.

## 2. CI verification and docs

- [x] 2.1 After the workflow change is on a branch that triggers Mobile CI (or after merge to `main`), confirm `build-android` succeeds and the `android-apk` artifact is uploaded. Record the run URL and conclusion.
- [x] 2.2 Write `obsidian/knowledge/features/pin-mobile-ci-java.md` from `obsidian/templates/feature-note.md`. Record the JDK pin, the contract script, and the verification run. Link it from the Features section of `obsidian/INDEX.md`.
