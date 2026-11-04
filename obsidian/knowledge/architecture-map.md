---
title: Architecture map
created: 2026-11-04
updated: 2026-11-04
tags:
  - knowledge
  - architecture
---

# Architecture Map

## Summary

na bleji is one Go API with two clients. Angular and Flutter both call `/api/v2`. Keycloak issues tokens; the Go service is the domain boundary. The old Java backend is archived and is not part of the running stack.

## Request Path

1. Locally, root `docker compose up --build` starts Compose from `coffeeshop/`. The web UI is nginx on port 4200 and proxies API traffic to the Go backend. Direct API access is port 18080. Keycloak is on port 8080.
2. The web app (`coffeeshop-frontend`) and the phone app (`coffeeshop-mobile`) sign in through `POST /api/v2/auth/login` and send `Authorization: Bearer` on later calls. They do not use a Keycloak SDK.
3. `coffeeshop-go` validates the Keycloak JWT, owns shop, reservation, event, review, and subscription state in Postgres, and calls Keycloak only for token exchange and admin user operations.
4. App data and Keycloak data are separate Postgres databases. Staging uses the same split under `deploy/k8s/`.

## Modules

| Path | Role |
|---|---|
| `coffeeshop-go` | chi router, GORM, `/api/v2` handlers |
| `coffeeshop-frontend` | Angular web app |
| `coffeeshop-mobile` | Flutter phone app |
| `coffeeshop` | Local Compose and Keycloak realm import |
| `deploy` | Kustomize base, k3s bootstrap, staging overlay |
| `archive/coffeeshop-java` | Retired Spring backend |

## Boundaries to Preserve

- Clients talk to the Go API. They do not call Keycloak token or admin endpoints themselves.
- New HTTP routes belong on `/api/v2`. The v1 prefix in older docs is the retired Java surface.
- `CUSTOMER`, `SHOP_OWNER`, and `ADMIN` are user types. Shop access also depends on the `user_shop` relationship (`OWNER` or `EMPLOYEE`). A shop-owner type alone does not grant access to every shop.
- Owner billing entitlements and customer loyalty plans are different models. See [Plans and entitlements](plans-and-entitlements.md).

## References

- [Go API README](../../coffeeshop-go/README.md)
- [Local Compose](../../coffeeshop/README.md)
- [Kubernetes deploy](../../deploy/README.md)

This is a navigation aid. Re-check handlers and client services when changing a path.
