# Design

## Context

See proposal.md for why the visible name changes. Today every user-visible brand surface reads `na bleji` after the archived rename. Phone UI already funnels in-app title and login heading through `AppConfig.appName`. Web still uses four inline literals. Platform labels (Android, iOS, macOS, Flutter web) each hold their own string. Identity keys and package ids remain `coffeeshop*` by design.

This change introduces a **full** vs **short** split that the previous rename did not need.

## Goals / Non-Goals

**Goals:**

- Put `Find: Cafes & Events` on in-app brand surfaces and browser/page titles listed in `specs/app-brand/spec.md`.
- Put `Find` on constrained installed labels and PWA short name / apple-mobile-web-app title.
- Keep one phone-app source of truth for full and short names.
- Change platform display labels without changing bundle filenames or application ids.

**Non-Goals:**

- Logo, favicon, or launcher-icon replacement (loop logo deferred).
- Renaming Dart/Go/npm packages, classes, imports, image names, Kubernetes names, the Keycloak realm, or public hosts.
- Editing READMEs, pubspec description, Obsidian notes, or the integration-test group name.
- Introducing a shared brand package across web and mobile.

## Decisions

### Full name in-app and chrome; short name on install labels

| Surface | String |
|---|---|
| Web sidebar, web `<title>`, phone login heading, `MaterialApp.title`, Flutter web `<title>`, manifest `name` | `Find: Cafes & Events` |
| Web login / register subtitles | `Sign in to your Find account` / `Join Find today` |
| Android `android:label`, iOS/macOS `CFBundleDisplayName` + `CFBundleName`, manifest `short_name`, `apple-mobile-web-app-title` | `Find` |

Auth uses the short name because embedding `Find: Cafes & Events` in those sentences is awkward; recorded as the default from exploration.

Alternative considered: full name everywhere. Rejected for launcher truncation and awkward auth sentences.

### Phone: `appName` + `appShortName`

Set `AppConfig.appName` to `Find: Cafes & Events` and add `AppConfig.appShortName` = `Find`. Keep using `appName` for `MaterialApp.title` and the login heading. Platform label files take the short literal (or `appShortName` only where Dart owns the string — it does not own Android/iOS/macOS plists).

Leave `AppConfig.packageName` and the `CoffeeshopApp` class name unchanged.

Alternative considered: a single constant. Rejected because full and short must diverge.

### Web: replace four literals in place

Same four files as the previous rename. No frontend brand constant — still only four call sites, and auth sentences are not the bare name.

### Display labels only; keep macOS PRODUCT_NAME

- Android: `android:label` → `Find`. Leave `applicationId`.
- iOS: `CFBundleDisplayName` and `CFBundleName` → `Find`. Leave bundle id.
- macOS: keep `PRODUCT_NAME = coffeeshop_mobile` in `AppInfo.xcconfig`; set plist display/name literals to `Find`.
- Flutter web: `name` → full; `short_name` → `Find`; `<title>` → full; `apple-mobile-web-app-title` → `Find`.

### No logo work; no broad search-replace

Task allow-list matches the previous rename’s file set (plus the new `appShortName` constant). Do not touch realm JSON, token keys, or icons.

### Testing approach

No existing widget/frontend test asserts the brand string. Per project TDD rules, add the smallest failing checks that lock the new strings (e.g. read `AppConfig.appName` / `appShortName` in a Dart unit test; for web, a focused component or string assertion if a test harness already covers those templates). If a harness does not exist for a surface, verify by reading the edited literals and run the existing frontend/mobile suites for regressions — record that limitation in the task verification step.

## Risks / Trade-offs

- [Long full name truncates in narrow sidebar] → Accept; short name is reserved for install labels. Sidebar can wrap or ellipsize with existing CSS.
- [Auth copy assumption overturned] → Spec and tasks use short-name sentences; flip both if product wants the full name in those lines.
- [macOS `PRODUCT_NAME` overwrites menu title later] → Plist holds literal `Find`; `PRODUCT_NAME` stays the `.app` filename on purpose.
- [Launcher labels change only on a new mobile build] → Expected. Web updates with the next frontend deploy.

## Migration Plan

Deploy the web frontend as usual. Ship a new mobile build for launcher and home-screen labels. Rollback is reverting those files. Existing web sessions keep current token keys. No Keycloak, DNS, or cluster change.

## Open Questions

None that block implementation. Auth short-name copy is an explicit recorded assumption.
