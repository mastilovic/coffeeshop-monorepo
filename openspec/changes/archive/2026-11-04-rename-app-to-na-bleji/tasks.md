# Tasks

## 1. Web copy

- [x] 1.1 Set the document title in `coffeeshop-frontend/src/index.html` to `na bleji`, the sidebar brand in `layout.component.ts` to `na bleji`, the login subtitle to `Sign in to your na bleji account`, and the register subtitle to `Join na bleji today`. Leave `coffeeshop_access_token` and `coffeeshop_refresh_token` in `auth.service.ts` unchanged. Verify by reading those four strings and both token key constants.

## 2. Phone in-app name

- [x] 2.1 Set `AppConfig.appName` to `na bleji` and use it for `MaterialApp.title` in `coffeeshop-mobile/lib/app.dart` and the login heading in `login_screen.dart`. Leave `AppConfig.packageName` and the `CoffeeshopApp` class name unchanged. Verify by reading those three sites, then run `flutter test` in `coffeeshop-mobile` and confirm it passes.

## 3. Installed labels

- [x] 3.1 Set `android:label` in `coffeeshop-mobile/android/app/src/main/AndroidManifest.xml` to `na bleji`. Leave `applicationId` in `android/app/build.gradle.kts` unchanged. Verify by reading the label and the application id.
- [x] 3.2 Set `CFBundleDisplayName` and `CFBundleName` in `coffeeshop-mobile/ios/Runner/Info.plist` to `na bleji`. Leave the bundle identifier build setting unchanged. Verify by reading both plist strings.
- [x] 3.3 Set `CFBundleName` and `CFBundleDisplayName` in `coffeeshop-mobile/macos/Runner/Info.plist` to the literal `na bleji`. Keep `PRODUCT_NAME` and `PRODUCT_BUNDLE_IDENTIFIER` in `macos/Runner/Configs/AppInfo.xcconfig`. Verify by reading the plist literals and that `PRODUCT_NAME` is still `coffeeshop_mobile`.
- [x] 3.4 Set `name` and `short_name` in `coffeeshop-mobile/web/manifest.json`, and the `<title>` and `apple-mobile-web-app-title` in `coffeeshop-mobile/web/index.html`, to `na bleji`. Verify by reading those four values.

## 4. Identity stays

- [x] 4.1 Confirm the diff touches only the files in tasks 1.1–3.4. Confirm `realm` in `coffeeshop/docker/keycloak/realm-coffeeshop.json` is still `coffeeshop` and the web token key constants are unchanged. Verify with `git diff --stat` and by reading those two identity spots.
