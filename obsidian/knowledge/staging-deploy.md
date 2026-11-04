---
title: Staging deploy
created: 2026-11-04
updated: 2026-11-04
tags:
  - knowledge
  - deploy
---

# Staging Deploy

## Summary

Local development is Docker Compose. Staging is a single-node k3s cluster on a Linux VM, deployed with Kustomize. DigitalOcean Kubernetes is no longer the staging target.

## Layout

```text
Internet → VM :80/:443 (ingress-nginx)
  ├─ app host  → frontend nginx → /api/v1 and /api/v2 → Go backend
  └─ auth host → Keycloak

backend → app Postgres and Keycloak
Keycloak → its own Postgres
```

- App images: `ghcr.io/mastilovic/coffeeshop-backend-go` and `ghcr.io/mastilovic/coffeeshop-frontend`.
- Staging hosts are `app.kafenerija.online` and `auth.kafenerija.online`.
- The cluster contract is "a cluster with kubeconfig", split into cluster bootstrap, platform (ingress, cert-manager, storage), and an environment overlay. `deploy/k8s/base` is the portable app. Staging selects the k3s platform component.
- k3s is reached by a self-hosted runner or SSH on the VM. The Kubernetes API is not published on the public internet.
- Traefik is disabled on this k3s install so the ingress class stays `nginx`.

## What Not to Mix Up

- Compose in `coffeeshop/` is the laptop stack (frontend `4200`, API `18080`, Keycloak `8080`, app Postgres `25432`). It is not the staging runtime.
- Generated staging files (`config.env`, `secrets.env`, the rendered realm) come from GitHub variables and secrets. They are not committed.
- TLS scheme has to match the JWT issuer and CORS. `STAGING_PUBLIC_SCHEME` must be `https` after the certificate is ready, then the stack is redeployed.

## Reference

- [Deploy README](../../deploy/README.md)
- [k3s bootstrap](../../deploy/bootstrap/k3s/README.md)
- OpenSpec change `portable-k8s-deploy` records why staging left DOKS.

Re-check the staging overlay and GitHub variable names before changing hosts, namespaces, or image tags.
