# Tasks

## 1. Phone brand constants

- [x] 1.1 Add a failing Dart unit test that expects `AppConfig.appName` to be `Find: Cafes & Events` and `AppConfig.appShortName` to be `Find`. Run `flutter test` for that file in `coffeeshop-mobile` and confirm it fails for the missing/wrong values (RED).
- [x] 1.2 Set `AppConfig.appName` to `Find: Cafes & Events` and add `AppConfig.appShortName` = `Find` in `coffeeshop-mobile/lib/core/config/app_config.dart`. Keep `MaterialApp.title` and the login heading on `AppConfig.appName`. Leave `packageName` and `CoffeeshopApp` unchanged. Re-run the new test and confirm it passes (GREEN), then run `flutter test` in `coffeeshop-mobile` for regressions.

## 2. Web copy

- [x] 2.1 Add failing frontend unit tests that expect the login subtitle `Sign in to your Find account`, the register subtitle `Join Find today`, and the sidebar brand `Find: Cafes & Events`. Run the new specs and confirm they fail for the current `na bleji` strings (RED).
- [x] 2.2 Set the document title in `coffeeshop-frontend/src/index.html` to `Find: Cafes & Events`, the sidebar brand in `layout.component.ts` to `Find: Cafes & Events`, the login subtitle to `Sign in to your Find account`, and the register subtitle to `Join Find today`. Leave `coffeeshop_access_token` and `coffeeshop_refresh_token` unchanged. Re-run the new specs (GREEN), confirm the four literals by reading them, then run the relevant frontend unit tests.

## 3. Installed labels

- [x] 3.1 Set `android:label` in `coffeeshop-mobile/android/app/src/main/AndroidManifest.xml` to `Find`. Leave `applicationId` unchanged. Verify by reading the label and the application id.
- [x] 3.2 Set `CFBundleDisplayName` and `CFBundleName` in `coffeeshop-mobile/ios/Runner/Info.plist` to `Find`. Leave the bundle identifier unchanged. Verify by reading both plist strings.
- [x] 3.3 Set `CFBundleName` and `CFBundleDisplayName` in `coffeeshop-mobile/macos/Runner/Info.plist` to `Find`. Keep `PRODUCT_NAME` and `PRODUCT_BUNDLE_IDENTIFIER` in `macos/Runner/Configs/AppInfo.xcconfig`. Verify by reading the plist literals and that `PRODUCT_NAME` is still `coffeeshop_mobile`.
- [x] 3.4 Set Flutter web `manifest.json` `name` to `Find: Cafes & Events` and `short_name` to `Find`; set `<title>` to `Find: Cafes & Events` and `apple-mobile-web-app-title` to `Find` in `coffeeshop-mobile/web/index.html`. Verify by reading those four values.

## 4. Identity stays

- [x] 4.1 Confirm the diff touches only the files in tasks 1.1–3.4 (plus the new tests). Confirm `realm` in `coffeeshop/docker/keycloak/realm-coffeeshop.json` is still `coffeeshop` and the web token key constants are unchanged. Verify with `git diff --stat` and by reading those two identity spots. Confirm no logo/icon files changed.
