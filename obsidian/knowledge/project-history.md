---
title: Project history
created: 2026-11-04
updated: 2026-11-04
tags:
  - knowledge
  - history
---

# Project History

## Summary

This repository started as a coffeeshop mockup in May 2026. The running product is now a Go API, an Angular web app, and a Flutter phone app. The visible name is `na bleji`. Staging moved off DigitalOcean Kubernetes onto a single-node k3s VM.

## Evidence Limits

- The root commit in this checkout is `6b2a25d` (2026-05-20). This is the history available here.
- The milestones below are selected points from Git. They are not a complete release log.

## Milestones

- **2026-05-20 — Repository begins.** Initial commit `6b2a25d`, a mockup demo.
- **2026-05-26 — CI and the first cluster.** Pipelines and a DigitalOcean Kubernetes deploy land the same day.
- **2026-05-27 — Java leaves the runtime.** Commit `c62bead` removes the unused Java service. The old Spring code remains under `archive/coffeeshop-java` and is not deployed.
- **2026-06-09 to 2026-06-10 — Phone app.** Flutter is added, then login moves off the Keycloak SDK onto the backend auth APIs (`2ac9a53`).
- **2026-07 — Owner subscriptions are specified.** The product spec is `coffeeshop/docs/subscription-plan.md`. Implementation lives in `coffeeshop-go/internal/subscription` and the billing screens.
- **2026-11-02 — Notifications and the staging move.** Owner dashboard notifications route to the work they describe. Staging leaves DOKS for k3s on the vServer (`be64f12`).
- **2026-11-04 — Visible rename.** The product name users read becomes `na bleji`. The Keycloak realm id stays `coffeeshop`. See `openspec/specs/app-brand/spec.md`.

## Sources

- Git history: `git log --date=short`
- [Service READMEs](../../coffeeshop-go/README.md)
- [Deploy README](../../deploy/README.md)
