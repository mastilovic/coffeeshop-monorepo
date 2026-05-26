---
name: cert_manager_tls
overview: Add cert-manager-managed TLS to the existing NGINX Ingress using Let’s Encrypt (staging + prod), wired through your Kustomize overlays so staging can move from HTTP to HTTPS cleanly.
todos:
  - id: infra-cert-manager-kustomize
    content: Create `deploy/k8s/infra/cert-manager` kustomization with Let’s Encrypt `ClusterIssuer` staging+prod (email trialprodigy45@gmail.com, http01 nginx solver).
    status: pending
  - id: base-ingress-tls
    content: "Extend `deploy/k8s/base/ingress.yaml` with `spec.tls` (hosts placeholders + `secretName: coffeeshop-tls`) so overlays can fill hosts."
    status: pending
  - id: staging-overlay-tls-replacements
    content: Update staging overlay replacements to also populate `spec.tls[0].hosts[0]` and `[1]` from `coffeeshop-config` APP_HOST/AUTH_HOST.
    status: pending
  - id: staging-issuer-patch
    content: Add a staging-only patch setting `metadata.annotations[cert-manager.io/cluster-issuer]=letsencrypt-staging` on the `coffeeshop` Ingress.
    status: pending
  - id: verify-and-promote
    content: Document/execute verification commands (Certificate/Secret/Challenge) and then promote to `letsencrypt-prod` via prod overlay or issuer patch switch.
    status: pending
isProject: false
---

# cert-manager + TLS via Ingress-shim (Kustomize)

## What you have today
- Existing HTTP-only Ingress at [deploy/k8s/base/ingress.yaml](deploy/k8s/base/ingress.yaml) with two hosts:
  - `spec.rules[0].host = APP_HOST_PLACEHOLDER` → `frontend:80`
  - `spec.rules[1].host = AUTH_HOST_PLACEHOLDER` → `keycloak:8080`
- Staging overlay [deploy/k8s/overlays/staging/kustomization.yaml](deploy/k8s/overlays/staging/kustomization.yaml) already injects `APP_HOST`/`AUTH_HOST` into `spec.rules.*.host` via `replacements`.
- NGINX Ingress controller is installed.

## Goal
- Enable HTTPS for both `APP_HOST` and `AUTH_HOST` using cert-manager and Let’s Encrypt.
- Use **Ingress-shim**: cert-manager auto-creates the `Certificate` from the `Ingress` annotation + `spec.tls`.

## Design choices
- **ACME email**: `trialprodigy45@gmail.com`
- **Issuers**:
  - `letsencrypt-staging` for initial validation / smoke tests
  - `letsencrypt-prod` for real browser-trusted certs
- **Challenge type**: HTTP-01 via NGINX (no DNS provider automation required)

## Implementation outline (repo structure + kustomize wiring)

### 1) Add cluster-level cert-manager resources (applied once per cluster)
Add a new folder to hold infra manifests, e.g.
- `deploy/k8s/infra/cert-manager/`
  - `clusterissuers.yaml` (contains BOTH `ClusterIssuer`s)
  - `kustomization.yaml`

`ClusterIssuer`s to include:
- `letsencrypt-staging` using `https://acme-staging-v02.api.letsencrypt.org/directory`
- `letsencrypt-prod` using `https://acme-v02.api.letsencrypt.org/directory`

Solver config:
- `http01.ingress.class: nginx`

Apply flow (manual / CI):
- Install cert-manager (Helm) in the cluster.
- `kubectl apply -k deploy/k8s/infra/cert-manager`

### 2) Make base Ingress TLS-capable (but environment-selectable)
Update [deploy/k8s/base/ingress.yaml](deploy/k8s/base/ingress.yaml) to include:
- `spec.tls[0].hosts: [APP_HOST_PLACEHOLDER, AUTH_HOST_PLACEHOLDER]`
- `spec.tls[0].secretName: coffeeshop-tls`
- Do **not** hardcode the issuer in base (or if you do, ensure overlays patch it).

### 3) Patch staging overlay to select the issuer + fill TLS hosts
In [deploy/k8s/overlays/staging/kustomization.yaml](deploy/k8s/overlays/staging/kustomization.yaml):

- Add **two more replacements** (in addition to the existing `spec.rules.*.host`):
  - Replace `spec.tls.0.hosts.0` from `coffeeshop-config.data.APP_HOST`
  - Replace `spec.tls.0.hosts.1` from `coffeeshop-config.data.AUTH_HOST`

- Add a staging-only patch to set the cert-manager issuer annotation on the Ingress:
  - `metadata.annotations["cert-manager.io/cluster-issuer"] = "letsencrypt-staging"`

This keeps staging initially on Let’s Encrypt staging (safe, no rate limits) while you validate routing.

### 4) (Optional but recommended) Prepare a production overlay pattern
Even if you don’t create it now, define the intended structure:
- `deploy/k8s/overlays/prod/` mirroring staging:
  - same host replacements
  - patch `cert-manager.io/cluster-issuer` to `letsencrypt-prod`

### 5) DNS + HTTP-01 prerequisites
Before expecting certificates to issue:
- Both `APP_HOST` and `AUTH_HOST` must resolve to the NGINX ingress LoadBalancer.
- Port 80 must be reachable (Let’s Encrypt HTTP-01).

Reference commands (staging namespace shown):
- Get ingress LB IP: `kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}{"\n"}'`
- Confirm Ingress hosts: `kubectl get ingress coffeeshop -n coffeeshop-staging -o custom-columns='APP:.spec.rules[0].host,AUTH:.spec.rules[1].host'`

### 6) Verification / debugging checklist
After applying staging overlay:
- cert-manager health:
  - `kubectl get pods -n cert-manager`
  - `kubectl logs -n cert-manager deploy/cert-manager`
- In staging namespace:
  - `kubectl describe ingress coffeeshop -n coffeeshop-staging`
  - `kubectl get certificate -n coffeeshop-staging` (created by ingress-shim)
  - `kubectl describe certificate coffeeshop-tls -n coffeeshop-staging`
  - `kubectl get secret coffeeshop-tls -n coffeeshop-staging`
- If issuance fails:
  - `kubectl get orders.acme.cert-manager.io -A`
  - `kubectl get challenges.acme.cert-manager.io -A`
  - `kubectl describe challenge <name> -n coffeeshop-staging`

## Rollout sequence
1. Install cert-manager (Helm) on the cluster.
2. Apply `ClusterIssuer`s (`letsencrypt-staging` + `letsencrypt-prod`).
3. Deploy staging overlay with TLS enabled + `letsencrypt-staging` issuer.
4. Once HTTPS works end-to-end, switch staging (or prod overlay) to `letsencrypt-prod`.
