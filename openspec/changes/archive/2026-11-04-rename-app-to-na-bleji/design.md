# Design

## Context

See proposal.md for why the visible name changes. The string `CoffeeShop` (and the scaffold names `CoffeeshopFrontend`, `coffeeshop_mobile`, and `Coffeeshop Mobile`) is hardcoded on a few screens and in platform labels. `AppConfig.appName` exists in the phone app and is unused. `MaterialApp.title` and the login heading are separate literals. Web copy is inline in the sidebar, login, and register templates, plus the document title.

Session keys live in `coffeeshop-frontend/src/app/services/auth.service.ts` as `coffeeshop_access_token` and `coffeeshop_refresh_token`. Android `applicationId`, iOS bundle identifier, and macOS `PRODUCT_NAME` / `PRODUCT_BUNDLE_IDENTIFIER` are package identity. On macOS, `PRODUCT_NAME` is also the `.app` filename.

## Goals / Non-Goals

**Goals:**

- Put the exact string `na bleji` on each surface in `specs/app-brand/spec.md`.
- Keep one phone-app constant for the in-app title and login heading.
- Change platform display labels without changing bundle filenames or application ids.

**Non-Goals:**

- Renaming Dart/Go/npm packages, classes, imports, image names, Kubernetes names, the Keycloak realm, or public hosts.
- Editing READMEs, the pubspec description, or the integration-test group name. Those strings are not on a user screen.
- Introducing a shared brand package across web and mobile.

## Decisions

### Replace visible literals; leave identity keys

Web has four user-visible strings and no brand constant. Replace them in place:

- `coffeeshop-frontend/src/index.html` document title → `na bleji`
- `coffeeshop-frontend/src/app/shared/layout/layout.component.ts` sidebar brand → `na bleji`
- `coffeeshop-frontend/src/app/features/auth/login.component.ts` subtitle → `Sign in to your na bleji account`
- `coffeeshop-frontend/src/app/features/auth/register.component.ts` subtitle → `Join na bleji today`

Do not change `ACCESS_TOKEN_KEY` / `REFRESH_TOKEN_KEY` or `environment.prod.ts`.

Alternative considered: a frontend brand constant. Four call sites do not need one, and the sentences are not the bare name.

### Point the phone UI at `AppConfig.appName`

Set `AppConfig.appName` to `na bleji`. Use it for `MaterialApp.title` in `coffeeshop-mobile/lib/app.dart` and the login heading in `coffeeshop-mobile/lib/features/auth/login_screen.dart`. Leave `AppConfig.packageName` and the `CoffeeshopApp` class name as they are.

Alternative considered: three more independent literals. The constant already exists and is the drift risk.

### Display labels only on Android, iOS, macOS, and Flutter web

- Android: `android:label` in `coffeeshop-mobile/android/app/src/main/AndroidManifest.xml`. Debug and profile manifests do not set a label. Leave `applicationId` in `build.gradle.kts`.
- iOS: `CFBundleDisplayName` and `CFBundleName` in `coffeeshop-mobile/ios/Runner/Info.plist`. Leave the bundle identifier.
- macOS: keep `PRODUCT_NAME = coffeeshop_mobile` and `PRODUCT_BUNDLE_IDENTIFIER` in `macos/Runner/Configs/AppInfo.xcconfig`, so the `.app` filename stays free of a space. Set `CFBundleName` and `CFBundleDisplayName` in `macos/Runner/Info.plist` to the literal `na bleji`. The menu title follows `CFBundleName`; Finder follows `CFBundleDisplayName`.
- Flutter web: `name` and `short_name` in `coffeeshop-mobile/web/manifest.json`, plus `<title>` and `apple-mobile-web-app-title` in `coffeeshop-mobile/web/index.html`.

Alternative considered: changing `PRODUCT_NAME` to `na bleji`. That renames the macOS bundle file and can break the Flutter macOS assemble step, which writes `$PRODUCT_NAME.app`.

### No test renames

No widget or frontend test asserts the brand string. The integration-test group title `CoffeeShop Integration Tests` stays. Implementation checks the edited files and runs the existing frontend and mobile test commands that already cover those screens.

## Risks / Trade-offs

- [A later edit copies `PRODUCT_NAME` back over the macOS menu title] → The plist holds the literal `na bleji`, and `PRODUCT_NAME` stays the bundle filename on purpose.
- [iOS `CFBundleName` still reads `coffeeshop_mobile` in Settings] → Set both `CFBundleName` and `CFBundleDisplayName`. `na bleji` is within the short-name length.
- [A broad search-and-replace rewrites realm ids, token keys, or image names] → The task list is an allow-list of files. Anything outside it stays.
- [Launcher labels change only on a new mobile build] → Expected. The web title changes with the next frontend deploy. No data migration.

## Migration Plan

Deploy the web frontend as usual. Ship a new mobile build for the launcher and home-screen labels. Rollback is reverting those files. Existing web sessions keep their current token keys. No Keycloak, DNS, or cluster change.
