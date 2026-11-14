# Tasks

## 1. Pixel check

- [x] 1.1 Add a repeatable pixel check (stdlib script, not a new dependency and not a golden image) for a square PNG: the canvas size matches the expected slot, a corner pixel is dark charcoal, and a pixel on the cup body is brown (red greater than green and greater than blue). Run it on `coffeeshop-frontend/public/favicon.png` (48×48) and confirm RED: the current teal magnifier fails because the ring is teal and the hole is charcoal.

## 2. Master

- [x] 2.1 Copy `coffeeshop-frontend/public/Coffee Magnifier Logo.png` to `coffeeshop-mobile/assets/brand/coffee-magnifier-icon.png`. If the cup and steam are not optically centered, crop to a square centered on that artwork using the corner charcoal as the background, and keep the crop as the master. Verify the master exists and is square. Delete the spaced public file and `coffeeshop-mobile/assets/brand/find-magnifier-icon.png`. Verify both deleted paths are gone.

## 3. Square icons

- [x] 3.1 Resize the master with `sips -z` into Android `mipmap-*/ic_launcher.png` at mdpi 48, hdpi 72, xhdpi 96, xxhdpi 144, xxxhdpi 192. Verify each pixel size. Confirm `android:icon` is still `@mipmap/ic_launcher`. Re-run the pixel check on `mipmap-xxxhdpi/ic_launcher.png` and confirm GREEN.
- [x] 3.2 Resize the master into every unique iOS and macOS `AppIcon` PNG at `size × scale` (`83.5@2x` is 167×167; shared filenames are written once). Verify each output dimension. Re-run the pixel check on the iOS 1024 icon and on `app_icon_16.png` and confirm GREEN. Confirm neither `Contents.json` changed.
- [x] 3.3 Resize the master into `coffeeshop-mobile/web/favicon.png` (32), `icons/Icon-192.png`, `icons/Icon-512.png`, and both maskable icons at the same 192 and 512 pixels. Verify sizes. Confirm the maskable files match the regular icons byte for byte unless a mask actually clips the steam, in which case inset only the maskable pair and re-check. Confirm `web/manifest.json` and `web/index.html` icon links are unchanged. Re-run the pixel check on `Icon-512.png` and confirm GREEN.
- [x] 3.4 Resize the master into `coffeeshop-frontend/public/favicon.png` and `public/favicon.ico` at 48×48, keeping the current pattern of PNG bytes in the `.ico` name. Leave the `index.html` links unchanged. Re-run the pixel check from task 1.1 and confirm GREEN.
- [x] 3.5 Resize the master into `coffeeshop-mobile/store/google-play/app-icon-512.png` at 512. Verify the size and confirm the pixel check is GREEN.
- [x] 3.6 Pack resized PNGs at 16, 24, 32, 48, 64, 128, and 256 into `coffeeshop-mobile/windows/runner/resources/app_icon.ico` with a Python stdlib script. Do not add Pillow or ImageMagick. Verify `file` reports a Windows icon and `Runner.rc` still references `resources\app_icon.ico`.

## 4. Play feature graphic

- [x] 4.1 Redraw `coffeeshop-mobile/store/google-play/feature-graphic-1024x500.png` with a macOS CoreGraphics script and no new dependency: charcoal sampled from the master, the coffee-cup mark on the left, and the existing copy on the right (`Find`, `Cafes & Events`, a short rule, `Cafes and events, nearby.`) using colors sampled from the current banner. Verify the output is 1024×500, a pixel on the left mark is brown, and the file is not a scaled square.

## 5. Glyphs and the teal requirement

- [x] 5.1 Confirm the web sidebar logo is still the coffee emoji (`&#9749;`) beside `Find: Cafes & Events` and the phone login still uses `Icons.coffee`. Run `npm test` in `coffeeshop-frontend` and `flutter test` in `coffeeshop-mobile` and confirm both pass.
- [x] 5.2 Add a superseded note to the "Find magnifier launcher icon" requirement in `openspec/changes/add-find-loop-logo/specs/app-brand/spec.md` stating it must not be synced because `coffee-magnifier-logo` replaces it. Do not change that change's task checkboxes. Verify the note is present and the main `openspec/specs/app-brand/spec.md` purpose still awaits the archive update described in design.md.

## 6. Feature note

- [x] 6.1 After the behavior above is implemented and verified, write `obsidian/knowledge/features/coffee-magnifier-logo.md` from `obsidian/templates/feature-note.md`. Record what the mark is, the installed surfaces, the in-app glyphs that stayed, where the master and derived icons live, and the checks that were run. Link the note from the Features section of `obsidian/INDEX.md`. Verify both files exist and the index link resolves.
