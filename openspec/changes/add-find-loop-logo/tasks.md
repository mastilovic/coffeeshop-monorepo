# Tasks

## 1. Master asset

- [x] 1.1 Generate the Find magnifier master PNG (deep teal / charcoal, magnifying glass, no wordmark) and save it at `coffeeshop-mobile/assets/brand/find-magnifier-icon.png`. Verify the file exists and is square by reading its dimensions.

## 2. Platform icons

- [x] 2.1 Resize the master into Android `mipmap-*/ic_launcher.png` (mdpi 48, hdpi 72, xhdpi 96, xxhdpi 144, xxxhdpi 192). Verify each file exists at the expected pixel size and `android:icon` remains `@mipmap/ic_launcher`.
- [x] 2.2 Resize the master into every PNG listed in iOS and macOS `AppIcon.appiconset` at the sizes implied by each filename. Verify each output dimension matches the filename scale.
- [x] 2.3 Replace `coffeeshop-mobile/web/favicon.png` and `web/icons/Icon-*.png` / `Icon-maskable-*.png` from the master. Verify files exist at 192 and 512 where applicable.
- [x] 2.4 Update the Angular favicon from the master (`coffeeshop-frontend/public/favicon.ico` and/or `favicon.png` + `index.html` link). Verify the linked favicon file exists.

## 3. Regression

- [x] 3.1 Confirm package ids / app labels / realm are unchanged. Run `npm test` in `coffeeshop-frontend` and `flutter test` in `coffeeshop-mobile` and confirm they pass.
