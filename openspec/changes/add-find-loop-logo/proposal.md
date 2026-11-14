# Proposal

## Why

Launcher and store icons still use the Flutter default placeholder. The Find brand needs a static magnifier mark on a deep teal / charcoal field for Play Store, home screens, and browser favicons.

## What Changes

- Add a Find magnifier logo master asset and install it as Android launcher mipmaps, iOS/macOS AppIcon images, Flutter web favicon/PWA icons, and the Angular web favicon.
- No product-name string changes; no identity/realm/host changes.
- In-app animated SVG / coffee-glyph replacement is out of scope.

## Capabilities

### New Capabilities

### Modified Capabilities

- `app-brand`: Require installed Android, iOS, and web launcher/favicon icons to present the Find magnifier mark (static deep teal / charcoal), not the default Flutter placeholder.

## Impact

- `coffeeshop-mobile` Android mipmaps, iOS/macOS AppIcon sets, `web/favicon.png`, `web/icons/*`.
- `coffeeshop-frontend` favicon.
- Master source under `coffeeshop-mobile/assets/brand/`.
