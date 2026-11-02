# Proposal

## Why

Staging deploy is fused to DigitalOcean Kubernetes: kubeconfig, LoadBalancer, `do-block-storage`, and GitHub Actions that `kubectl` into a public managed API. A clean Debian vServer (4 CPU, 8 GB) cannot reuse that path, and the next Hetzner or extra VM would copy the whole stack again. Staging should move onto this machine, and the repo should treat “a cluster with kubeconfig” as the contract so new hosts are overlay + bootstrap, not a rewrite.

## What Changes

- Split deploy into three layers: **cluster** (Kubernetes exists), **platform** (disks, ingress, TLS), **environment** (hosts, secrets, images, namespace).
- Add a repeatable **k3s bootstrap** for a clean Linux VM (Traefik off, local-path storage, host-bound 80/443). Reuse existing ingress-nginx + cert-manager install for the platform layer.
- Keep `deploy/k8s/base` as the portable app. Introduce kustomize **platform components** (`k3s`, extract today’s DOKS assumptions) and keep **environment overlays** (`staging` now, `prod` later).
- **BREAKING**: staging **moves** to this vServer. `app.kafenerija.online` / `auth.kafenerija.online` A records point at the VM (`195.234.126.162`), not a DigitalOcean load balancer. DOKS is no longer the staging cluster after cutover.
- Stop hardcoding the staging namespace in `deploy/k8s/base` so a future `prod` overlay can use a different namespace.
- Change GitHub deploy so it can target this k3s cluster **without** exposing the Kubernetes API on the public internet (self-hosted runner on the VM, or SSH + `kubectl` on the box). Managed clusters later keep the existing kubeconfig-secret pattern.
- Document the new-VM runbook (bootstrap, firewall 22/80/443, GHCR pull, DNS, TLS, CI wiring). Panel backups remain the disk safety net for local-path volumes.

## Capabilities

### New Capabilities

- `cluster-bootstrap`: Turn a clean Linux VM into a single-node Kubernetes cluster that can run CoffeeShop (k3s, ingress class `nginx`, cert-manager, local storage).
- `k8s-app-deploy`: Deploy the CoffeeShop stack to any such cluster via environment overlay + platform component, including staging cutover and CI that reaches k3s without a public API.

### Modified Capabilities

- None. There are no existing specs.

## Impact

- `deploy/k8s/`: base namespace, new `components/` (platform-k3s, platform-doks), staging overlay includes k3s component, optional `deploy/bootstrap/k3s`.
- `deploy/k8s/infra/cert-manager/`: still the TLS installer; docs drop DOKS-only language.
- `.github/workflows/`: CI/CD Staging and Deploy Staging no longer assume GitHub-hosted `kubectl` against DOKS `KUBE_CONFIG`; k3s uses a runner or SSH. Managed k8s keeps kubeconfig secrets.
- DNS at the registrar: A records for app/auth hosts → vServer IP.
- Runtime: same images (`ghcr.io/mastilovic/coffeeshop-*`), same GitHub `STAGING_*` variables/secrets. No application API changes.
- Out of scope: Flux/Argo, Terraform, a `prod` overlay, Hetzner cluster creation, Docker Compose as the staging runtime, opening k3s `:6443` to the internet.
