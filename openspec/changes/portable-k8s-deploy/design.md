# Design

## Context

See proposal.md for why. Specs: `cluster-bootstrap`, `k8s-app-deploy`.

Today `deploy/k8s/base` is already a portable app (ClusterIP services, PVCs with no StorageClass, Ingress class `nginx`). Coupling lives around it: `base/namespace.yaml` is named `coffeeshop-staging`, GitHub deploy always `runs-on: ubuntu-latest` with secret `KUBE_CONFIG`, cert-manager/install workflows are labeled DOKS, and DNS docs tell operators to point A records at a DigitalOcean load balancer. Staging hosts stay `app.kafenerija.online` / `auth.kafenerija.online`. Target machine: Debian vServer `195.234.126.162`, 4 CPU / 8 GB, SSH `informaten@`.

## Goals / Non-Goals

**Goals:**

- One k3s bootstrap script plus existing Helm ingress-nginx and `deploy/k8s/infra/cert-manager/install.sh`.
- Staging overlay includes a `platform-k3s` component; app base stays provider-neutral; namespace lives in the overlay.
- Image builds stay on GitHub-hosted runners. Staging apply runs on the VM so `:6443` stays off the internet.
- Cut over DNS after the overlay is healthy on the VM; keep DOKS until that is proven so rollback is a DNS flip.

**Non-Goals:**

- Flux/Argo, Terraform, a `prod` overlay, or creating a Hetzner cluster in this change.
- Building container images on the 8 GB VM.
- Opening the Kubernetes API to GitHub or the internet.
- Replacing cert-manager HTTP-01 or changing `ingressClassName: nginx`.

## Decisions

### 1. k3s with Traefik disabled, nginx Ingress kept

Install k3s (not kubeadm, k0s, or MicroK8s) with Traefik off so Ingress objects keep `ingressClassName: nginx`. k3s provides local-path as default StorageClass (PVCs in base already omit `storageClassName`) and ServiceLB (Klipper) so a LoadBalancer Service for ingress-nginx binds host 80/443.

```
curl -sfL https://get.k3s.io | sh -s - --disable traefik
```

Script: `deploy/bootstrap/k3s/install.sh` (idempotent: k3s installer is safe to re-run). Then Helm ingress-nginx (same chart as `deploy/README.md`) and existing cert-manager `install.sh`. Do not install Docker on the VM.

Alternative: keep Traefik and change Ingress class. Rejected — every future managed cluster would need the Traefik class too, or staging would diverge from base.

Alternative: kubeadm. Rejected — extra control-plane RAM on a single node with no HA.

### 2. Environment overlays + kustomize Components for platforms

```
deploy/
  bootstrap/k3s/install.sh
  k8s/
    base/                 # app only; drop namespace.yaml
    components/
      platform-k3s/       # optional storageClassName=local-path on Postgres PVCs
      platform-doks/      # stub: managed default StorageClass / LB, no workload patches
    overlays/
      staging/            # namespace, STAGING_* env, platform-k3s, small-node patch
    infra/cert-manager/   # unchanged installer
```

`overlays/staging/kustomization.yaml` sets `namespace: coffeeshop-staging`, lists `namespace.yaml`, and `components: [../../components/platform-k3s]`. A later `overlays/prod` copies that pattern with a different namespace and platform component. Do not add `overlays/hetzner` / `overlays/digitalocean`.

`platform-doks` is a stub in this change so the adapter pattern exists; staging does not use it after cutover.

### 3. Namespace leaves base

Move `namespace.yaml` from `base/` into `overlays/staging/`. Remove it from `base/kustomization.yaml`. Overlay `namespace:` plus an explicit Namespace object owned by the overlay. Prevents kustomize from putting namespaced resources in `coffeeshop-prod` while a cluster-scoped Namespace object remains `coffeeshop-staging`.

### 4. Staging deploy job on a self-hosted runner; builds stay hosted

Image build jobs stay `ubuntu-latest` and push to GHCR. The reusable deploy workflow gains:

- `runs-on` input defaulting to `ubuntu-latest` for managed clusters.
- Staging k3s: `runs-on: [self-hosted, linux, k3s-staging]`.
- `kubeconfig_source`: `local-k3s` (use `/etc/rancher/k3s/k3s.yaml` or a 0600 copy the runner user can read) vs `secret` (`KUBE_CONFIG`, current path).

Staging CI/CD and manual Deploy Staging pass the self-hosted runner and `local-k3s`. Drop the check that kubeconfig must look like DOKS. Keep rendering `config.env` / `secrets.env` / realm from GitHub variables and secrets inside the job so secrets are not stored as files on the VM except for the apply working copy.

Install the GitHub Actions runner on the VM as a systemd service, label `k3s-staging`, running as a user that can `kubectl` to the local API. Do not put the runner on a public port; it dials out to GitHub.

Alternative: GitHub-hosted job + `KUBE_CONFIG` pointing at `https://195.234.126.162:6443`. Rejected — public API on a cheap VPS.

Alternative: GitHub-hosted job SSH/scp and remote `kubectl`. Viable, but needs a deploy key and copying the rendered overlay. The self-hosted job reuses the existing render-then-`kubectl apply -k` steps. SSH remains the human bootstrap path, not CI.

### 5. Firewall and DNS

Provider panel firewall (and host firewall if enabled): allow TCP 22, 80, 443 from the internet. Do not allow 6443. A records:

| Host | Name | Value |
|------|------|--------|
| A | app | 195.234.126.162 |
| A | auth | 195.234.126.162 |

Apply the overlay and prove pods Ready **before** flipping DNS so Let's Encrypt HTTP-01 and user traffic move together. After the certificate is Ready, `STAGING_PUBLIC_SCHEME=https` if it is not already.

### 6. GHCR pull

If GHCR packages are private, create `ghcr-pull` in `coffeeshop-staging` (documented in the bootstrap runbook; same as current README). If they are public, skip. Do not bake a PAT into git.

## Risks / Trade-offs

- [Single-node k3s is not HA] → Accept for staging. Panel disk backups are the recovery path for local-path Postgres. Document restore = restore VM backup, not `kubectl`.
- [Self-hosted runner is a privileged GitHub credential on the VM] → Dedicated OS user, 0600 kubeconfig, no extra sudo beyond what k3s needs. Revoke runner on compromise.
- [DNS TTL during cutover] → Lower TTL before the flip; keep DOKS until HTTPS works on the VM. Rollback = restore A records to the DigitalOcean LB IP.
- [ingress-nginx LoadBalancer vs host ports on k3s] → Prefer Helm defaults + ServiceLB. If 80/443 do not bind, Helm `--set controller.hostNetwork=true` as a documented fallback.
- [8 GB still includes Keycloak] → Keep `resources-small-node.yaml`. Verify `kubectl describe node` allocated memory after first apply.
- [Keycloak realm already in old Postgres] → New empty PVCs on the VM; realm import runs on first start. This is a new database, not a migration of DOKS volumes unless the operator copies dumps (out of scope).
- [cert-manager HTTP-01 before DNS] → Expect Certificate not Ready until A records hit the VM. Do not set `https` issuer URLs before that.

## Migration Plan

1. SSH to the VM. Install k3s (Traefik off), helm ingress-nginx, cert-manager. Confirm node Ready, local-path StorageClass, 80/443 listening, 6443 not public.
2. Move namespace to the staging overlay; add platform components; point staging at `platform-k3s`.
3. Render staging config (existing `STAGING_*` or `render-local.sh`) and `kubectl apply -k` from the laptop using a copied kubeconfig **only on the operator machine** (or kubectl on the VM). Do not put that kubeconfig in GitHub for k3s.
4. Verify pods Ready via `/etc/hosts` or `curl -H Host:app.kafenerija.online http://195.234.126.162/`.
5. Flip DNS A records. Wait for `coffeeshop-tls` Ready. Set `STAGING_PUBLIC_SCHEME=https` and redeploy if needed.
6. Install the self-hosted runner. Switch reusable deploy to `k3s-staging` + `local-k3s`. Run manual Deploy Staging once.
7. Retire DOKS when satisfied. Until then, DNS rollback is valid.

## Open Questions

- Whether GHCR packages are currently public (affects only whether `ghcr-pull` is required, not the overlay shape).
