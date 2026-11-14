# Design

## Context

See proposal.md. Square icon slots already exist and point at fixed filenames. The Angular favicon links in `coffeeshop-frontend/src/index.html` and the Flutter web manifest icons stay as they are. Android has legacy `mipmap-*/ic_launcher.png` files only (no adaptive-icon XML). The Play feature graphic is a 1024×500 composed bitmap, not a scaled square. `sips` is available. Pillow and ImageMagick are not, and this change does not add a package dependency.

## Goals / Non-Goals

**Goals:**

- One canonical master, then exact-size derivatives in the existing filename slots.
- One repeatable pixel check that fails on the teal magnifier and passes on the coffee-cup mark.
- A feature graphic whose left mark matches the master and whose copy matches the current banner.

**Non-Goals:**

- Replacing the web coffee emoji or the phone `Icons.coffee` glyph.
- Changing `Contents.json`, the web manifest, `AndroidManifest.xml` `android:icon`, or `Runner.rc`.
- Adding an image library to either app.
- Adaptive Android icons, splash screens, or a new in-app SVG.

## Decisions

### Canonical master, then delete the public source name

Copy `coffeeshop-frontend/public/Coffee Magnifier Logo.png` (1254×1254) to `coffeeshop-mobile/assets/brand/coffee-magnifier-icon.png` and keep those pixels as the master. Do not downsample the master to 1024 first. Delete the spaced public file afterward so `public/` does not ship a 1.3MB unreferenced asset. Delete `coffeeshop-mobile/assets/brand/find-magnifier-icon.png` so the teal file is no longer a second master.

Before deriving sizes, sample the master. The artwork must be optically centered in the square with its existing charcoal margin. If the cup and steam sit high or low, crop to a square centered on that artwork, keeping charcoal padding, and treat the crop as the master. Do not invent a new background color; sample the corner charcoal.

Alternative considered: serve the spaced filename from `index.html`. Rejected because the name is a poor URL and the file is far too large for a favicon.

### Resize with sips into existing slots

Use `sips -z` so each PNG keeps its current pixel size and path:

- Android: mdpi 48, hdpi 72, xhdpi 96, xxhdpi 144, xxxhdpi 192.
- iOS: each unique `AppIcon` filename at `size × scale` pixels. `83.5@2x` is 167×167. Shared filenames (`20@2x`, `29@1x`, `29@2x`, `40@2x`) are written once.
- macOS: 16, 32, 64, 128, 256, 512, 1024. Shared filenames are written once.
- Flutter web: `favicon.png` at 32. `Icon-192.png`, `Icon-512.png`, and both maskable icons at 192 and 512. Maskable icons use the same pixels as the regular icons. The master already has a large charcoal margin, so do not shrink the mark further.
- Angular: `public/favicon.png` and `public/favicon.ico` at 48. The current `.ico` is PNG bytes with an `.ico` name. Keep that pattern. `index.html` already links both.
- Play listing icon: `store/google-play/app-icon-512.png` at 512.

### Windows icon without a new dependency

`windows/runner/resources/app_icon.ico` is a real multi-image ICO referenced by `Runner.rc`. Pack resized PNGs (16, 24, 32, 48, 64, 128, 256) into an ICO with a short Python stdlib script. Do not add Pillow or ImageMagick.

### Feature graphic is a recomposition

Do not scale the square onto 1024×500. Redraw `store/google-play/feature-graphic-1024x500.png` with a macOS CoreGraphics script (no new dependency): charcoal field sampled from the master, the coffee-cup mark on the left, and the current copy on the right — `Find`, `Cafes & Events`, a short rule, and `Cafes and events, nearby.` Sample the current banner for the white title, teal subtitle, and gray tagline so the type colors stay. Output must be 1024×500.

Alternative considered: paint the new mark over the left half of the existing PNG. Rejected because the old teal ring and the new steam will not share a bounding box, and a patch can leave a teal sliver or cover the wordmark.

### Verification is a pixel predicate, not a golden image

There is no image-diff test today, and a stored golden PNG would duplicate the master. The check samples the derived favicon:

- A corner pixel stays dark charcoal.
- A pixel on the cup body is brown (red channel greater than green and greater than blue).
- The canvas size matches the slot.

Run that check against the current teal Angular favicon first and confirm it fails because the ring is teal (red lower than green/blue) and the hole is charcoal. After the swap, the same check passes. Then run the existing `npm test` in `coffeeshop-frontend` and `flutter test` in `coffeeshop-mobile`. Those suites cover the product-name strings this change must not touch. Do not add a pixel snapshot test.

### Supersede the teal requirement before either change is archived

`openspec/changes/add-find-loop-logo/specs/app-brand/spec.md` still ADDS "Find magnifier launcher icon" (teal, no coffee cup). That requirement is not in the main spec. Add a superseded note to that delta so a later archive does not sync it beside this requirement. Do not mark that change's tasks undone. When this change is archived, extend the purpose sentence in `openspec/specs/app-brand/spec.md` so the capability covers the installed mark as well as the product name. The delta itself has no Purpose section.

## Risks / Trade-offs

- [Steam and bubbles disappear below ~32px] → Accept it. The rim and handle remain the readable mark. Do not add a separate simplified glyph for small slots.
- [Maskable crop clips the steam] → The source margin is already large. If a mask still clips the steam, inset only the maskable pair, and leave the regular icons full-bleed.
- [CoreGraphics text metrics differ from the current banner] → Match copy, colors, and left-mark / right-text structure. Do not chase pixel-identical type.
- [1254 source is an awkward scale factor] → `sips` resampling is enough. No manual per-size redraw.
- [`add-find-loop-logo` archived unchanged would require the teal mark] → The superseded note is part of this change, before either archive.

## Migration Plan

Ship with the next frontend deploy and the next mobile build. Play images are uploaded with the next listing update; they are not in the app binary. Rollback is restoring the icon files and `find-magnifier-icon.png` from git.

## Open Questions

None. In-app glyphs stay, and the feature graphic keeps its current copy.
