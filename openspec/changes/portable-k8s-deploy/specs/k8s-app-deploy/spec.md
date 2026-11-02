# Spec Delta

## Purpose

Deploys the CoffeeShop Kubernetes stack to any cluster that meets the bootstrap contract, using environment overlays and small platform adapters, including the move of staging onto the Debian vServer.

## ADDED Requirements

### Requirement: Environment overlay deploys the full stack

Applying the staging environment overlay SHALL deploy frontend, Go backend, Keycloak, application Postgres, Keycloak Postgres, and Ingress in one namespace. Image tags SHALL come from GHCR (`ghcr.io/mastilovic/coffeeshop-backend-go` and `ghcr.io/mastilovic/coffeeshop-frontend`). Runtime hosts and secrets SHALL continue to come from the existing `STAGING_*` GitHub variables and secrets (or the local `config.env` / `secrets.env` render path).

#### Scenario: Staging overlay apply

- **WHEN** an operator applies the staging overlay to a Ready cluster with platform add-ons installed
- **THEN** backend, frontend, and Keycloak rollouts succeed and both Postgres pods become Ready

#### Scenario: Hosts still come from staging config

- **WHEN** `STAGING_APP_HOST` and `STAGING_AUTH_HOST` are set to `app.kafenerija.online` and `auth.kafenerija.online`
- **THEN** the Ingress rules use those hosts

### Requirement: Platform differences stay out of app workloads

App Deployment, StatefulSet, and Service manifests in the shared base SHALL NOT encode a specific cloud provider (load-balancer annotations, cloud CSI class names, or DigitalOcean-only install steps). Provider-specific behavior SHALL live in a platform adapter that an environment overlay includes. Adding a future cluster (managed Kubernetes or another VM) SHALL NOT require copying those app workload manifests.

#### Scenario: Base workloads are provider-neutral

- **WHEN** a reviewer inspects the shared app base
- **THEN** those workloads have no DigitalOcean load-balancer or block-storage identifiers

#### Scenario: New cluster reuses the same app base

- **WHEN** an operator adds a second environment overlay for another cluster
- **THEN** that overlay references the same app base and a platform adapter, not a forked copy of backend/frontend/Keycloak/Postgres manifests

### Requirement: Environment owns the namespace

The shared app base SHALL NOT pin a single environment namespace. The staging overlay SHALL set the staging namespace. A later production overlay SHALL be able to use a different namespace without editing base workload files.

#### Scenario: Staging namespace comes from the overlay

- **WHEN** the staging overlay is applied
- **THEN** workloads land in the staging namespace

#### Scenario: Base does not hardcode staging

- **WHEN** a reviewer inspects the shared app base namespace definition
- **THEN** it does not force the name `coffeeshop-staging` as the only possible environment

### Requirement: Staging public DNS targets the vServer

After cutover, `app.kafenerija.online` and `auth.kafenerija.online` SHALL resolve to the vServer public IPv4 `195.234.126.162`. Users SHALL reach the staging UI and Keycloak on those names through the VM ingress, not through a DigitalOcean load balancer. DigitalOcean Kubernetes SHALL no longer be the staging deploy target.

#### Scenario: DNS cutover

- **WHEN** the registrar A records for `app` and `auth` on `kafenerija.online` are set to `195.234.126.162`
- **THEN** those names resolve to the vServer and HTTP/HTTPS to them is served by the VM cluster

#### Scenario: Staging CI no longer deploys to DigitalOcean Kubernetes

- **WHEN** CI/CD Staging or the manual staging deploy runs after cutover
- **THEN** it applies to the vServer cluster, not to the previous DigitalOcean Kubernetes cluster

### Requirement: Staging CI does not expose the Kubernetes API

Continuous deployment of staging SHALL apply the overlay to the vServer cluster without requiring the Kubernetes API to be reachable from the public internet. GitHub-hosted `kubectl` using a public kubeconfig SHALL NOT be the k3s path. Managed Kubernetes clusters added later MAY keep the kubeconfig-secret pattern.

#### Scenario: Staging deploy with API closed to the internet

- **WHEN** GitHub Actions deploys staging and TCP 6443 on the vServer is not open to the internet
- **THEN** the overlay is still applied and rollouts complete

#### Scenario: Managed cluster can still use kubeconfig

- **WHEN** a future environment runs on managed Kubernetes with a public API
- **THEN** deploy MAY authenticate with a kubeconfig secret without changing the app overlay contract
