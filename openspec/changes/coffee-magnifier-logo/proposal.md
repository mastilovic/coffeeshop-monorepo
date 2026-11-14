# Proposal

## Why

The installed icons still show the teal magnifier from `add-find-loop-logo`. The product mark is now the coffee-cup magnifier in `coffeeshop-frontend/public/Coffee Magnifier Logo.png` (cream rim, brown coffee, steam, charcoal field), and that file is not wired to any launcher, favicon, or store image.

## What Changes

- Treat that PNG as the master and install it in place of the teal magnifier on every square icon slot: Android launcher, iOS and macOS AppIcon, Windows icon, Flutter web favicon and PWA icons, and the Angular favicon.
- Replace the Play listing icon and recompose the 1024×500 feature graphic so the left mark is the coffee cup. Keep the existing wordmark and tagline.
- Remove the spaced public filename after the master is copied, so the 1.3MB source is not deployed as a static file.
- Leave product-name strings, realm, hosts, and in-app glyphs unchanged. The web sidebar and dashboard keep the coffee emoji. The phone login screen keeps `Icons.coffee`.

## Capabilities

### New Capabilities

### Modified Capabilities

- `app-brand`: Add a requirement that launcher, favicon, PWA, and Play images show the coffee-cup magnifier on charcoal, not the teal magnifier and not the Flutter placeholder.

## Impact

- Icon files under `coffeeshop-mobile` (Android mipmaps, iOS/macOS AppIcon sets, `windows/runner/resources/app_icon.ico`, `web/favicon.png`, `web/icons/*`) and `coffeeshop-frontend` favicons.
- Store bitmaps at `coffeeshop-mobile/store/google-play/app-icon-512.png` and `feature-graphic-1024x500.png`.
- Master moves to `coffeeshop-mobile/assets/brand/coffee-magnifier-icon.png`. `find-magnifier-icon.png` is retired.
- `add-find-loop-logo` is complete and unarchived. Its delta still requires the teal magnifier, which is not in the main `app-brand` spec yet. Do not sync that requirement. This change's coffee-cup requirement is the one that belongs in `app-brand`.
- No API, label, package-id, or session-key changes.

## Assumptions

- Scope is the installed and store marks listed above. In-app emoji and Material coffee icon stay until a later change.
- The feature graphic keeps its current copy ("Find", "Cafes & Events", "Cafes and events, nearby.") and charcoal field. Only the left mark is replaced.
