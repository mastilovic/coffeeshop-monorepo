# na bleji Knowledge Index

Use this as a small map to durable project knowledge, not as a copy of the codebase or docs.

The product name users see is `na bleji`. Repository modules, the Keycloak realm, and package ids still use `coffeeshop`.

## How to Use

- For a task, open only the notes relevant to its app, feature, or failure mode.
- Treat notes as shortcuts to context. Verify code paths, configuration, and behavior that may have changed.
- Add a note only when a finding is non-obvious and likely to save future investigation. Keep it short and link to source files, tests, or docs.
- After adding or moving a note, update the topic list below. Delete or revise stale notes instead of accumulating contradictory guidance.

## Topics

- [Project history](knowledge/project-history.md) — how the repo got to the current Go, web, and mobile stack.
- [Architecture map](knowledge/architecture-map.md) — app boundaries and the request path.
- [Auth and identity](knowledge/auth-and-identity.md) — Keycloak, bearer tokens, and names that must not be renamed together.
- [Plans and entitlements](knowledge/plans-and-entitlements.md) — owner subscriptions versus shop loyalty plans.
- [Staging deploy](knowledge/staging-deploy.md) — k3s staging and what local Compose is for.

## Workflows

- [Feature development commands](feature-development-commands.md) — OpenSpec commands for ideas, plans, implementation, and bug investigations.
- `AGENTS.md` — spec-first and test-driven policy. OpenSpec workflow constraints are in `openspec/config.yaml`.

## Existing References

Use these maintained references when they already answer the question:

- `coffeeshop-go/README.md` for the API surface.
- `coffeeshop/README.md` and `coffeeshop/docs/` for local Compose, Keycloak, and the owner-subscription product spec.
- `coffeeshop-frontend/README.md` and `coffeeshop-mobile/README.md` for client dev servers.
- `deploy/README.md` for the Kubernetes layout and staging runbook.
- `openspec/` for active and archived change plans.
