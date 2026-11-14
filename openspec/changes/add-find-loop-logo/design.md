# Design

## Context

See proposal.md. Product strings already say Find; icons are still Flutter defaults. Plan locks a static magnifier on deep teal / charcoal for store and launcher surfaces.

## Goals / Non-Goals

**Goals:**

- One master PNG magnifier mark; derive all platform sizes from it.
- Replace Android mipmaps, iOS/macOS AppIcons, Flutter web icons/favicon, Angular favicon.

**Non-Goals:**

- Animated SVG in sidebar/login.
- Changing app labels, package ids, or brand strings.

## Decisions

### Master asset then resize

Generate a 1024×1024 square PNG at `coffeeshop-mobile/assets/brand/find-magnifier-icon.png`. Use `sips` to write exact pixel sizes into existing filename slots so `Contents.json` and manifest references stay unchanged.

### Palette

Charcoal field `#121C1F`–`#152228`; magnifier stroke/fill deep teal `#0D5C63`–`#147B83`. No purple glow, no cream, no coffee cup, no infinity loop.

### Verification without pixel golden tests

Assert the master file exists and platform icon paths are non-empty; run existing unit suites for regressions.

## Risks / Trade-offs

- [AI-generated master needs crop/safe-area tweak] → Keep magnifier inside ~80% of canvas; regenerate if mask clips.
- [`.ico` for Angular] → Prefer PNG favicon linked from `index.html` if writing `.ico` is awkward; keep a PNG copy at `public/favicon.png`.

## Migration Plan

Ship with next mobile build and frontend deploy. Rollback is restoring previous icon files from git.
