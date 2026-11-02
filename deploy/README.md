# CoffeeShop — Kubernetes deploy

Deploy the full stack (Postgres ×2, Keycloak, Go backend, Angular frontend) with [Kustomize](https://kustomize.io/). Staging runs on a **single-node k3s** VM. The same app base can target a managed cluster later via a platform component.

## Layers

```text
Cluster     k3s on a Linux VM (or later: managed Kubernetes)
Platform    ingress-nginx (class nginx), cert-manager, local-path or cloud CSI
Environment overlays/staging — hosts, secrets, namespace, image tags
```

```text
Internet → VM :80/:443 (NGINX Ingress, ingressClassName: nginx)
  ├─ APP_HOST  → frontend:80 → nginx proxies /api/v1/* and /api/v2/* → backend:8080
  └─ AUTH_HOST → keycloak:8080

backend → postgres (app DB), keycloak (token/admin API)
keycloak → postgres-keycloak
```

Images are built by GitHub Actions and published to GHCR:

- `ghcr.io/mastilovic/coffeeshop-backend-go`
- `ghcr.io/mastilovic/coffeeshop-frontend`

## One-time cluster setup (staging k3s)

Target: Debian vServer `195.234.126.162` (4 CPU / 8 GB). Do not install Docker.

### 1. k3s

```bash
ssh informaten@195.234.126.162
sudo ./deploy/bootstrap/k3s/install.sh   # from a clone of this repo
kubectl get nodes
```

Details: [bootstrap/k3s/README.md](bootstrap/k3s/README.md). Traefik is disabled so Ingress stays `ingressClassName: nginx`.

### 2. NGINX Ingress Controller

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace
```

Manifests expect `ingressClassName: nginx`. If 80/443 do not bind, use the hostNetwork fallback in the bootstrap README.

### 3. GHCR pull secret (if packages are private)

```bash
kubectl create namespace coffeeshop-staging
kubectl create secret docker-registry ghcr-pull \
  --docker-server=ghcr.io \
  --docker-username=<github-username> \
  --docker-password=<github-pat-with-read:packages> \
  -n coffeeshop-staging
```

Then add to each Deployment in the overlay:

```yaml
spec:
  template:
    spec:
      imagePullSecrets:
        - name: ghcr-pull
```

Skip if GHCR packages are public.

### 4. Install cert-manager (once per cluster)

```bash
cd deploy/k8s/infra/cert-manager
chmod +x install.sh
./install.sh
```

Or GitHub Actions: **Install cert-manager** (`workflow_dispatch`) on the `k3s-staging` self-hosted runner. See [deploy/k8s/infra/cert-manager/README.md](k8s/infra/cert-manager/README.md).

### 5. Deploy staging and enable HTTPS

1. Apply the overlay (`kubectl apply -k deploy/k8s/overlays/staging` or **CI/CD Staging** / **Deploy Staging** after the runner is installed).
2. Prove the SPA via `curl -H 'Host: app.kafenerija.online' http://195.234.126.162/` **before** flipping DNS.
3. Point DNS (below), then wait until the certificate is Ready:
   ```bash
   kubectl get certificate coffeeshop-tls -n coffeeshop-staging
   ```
4. Set GitHub variable `STAGING_PUBLIC_SCHEME=https` and redeploy so JWT issuer and CORS use `https://` (see [GITHUB_SETUP.md](GITHUB_SETUP.md)).

HTTP-only smoke tests work before step 4 if `STAGING_PUBLIC_SCHEME` stays `http`.

Keep the previous DigitalOcean cluster until HTTPS works here. Rollback is restoring A records to that load balancer. Destroy DOKS only after the smoke test in [GITHUB_SETUP.md](GITHUB_SETUP.md).

## GitHub configuration

The deploy pipeline generates `config.env`, `secrets.env`, and `realm-coffeeshop.json` from GitHub **Variables**, **Secrets**, and `realm-coffeeshop.json.template`. You do not commit those generated files.

Staging apply runs on a **self-hosted runner** labeled `k3s-staging` using the node kubeconfig (`local-k3s`). Image builds stay on GitHub-hosted runners. `KUBE_CONFIG` is **not** required for k3s staging (that secret is the managed-cluster path).

See **[GITHUB_SETUP.md](GITHUB_SETUP.md)**.

## Local deploy (manual)

```bash
cd deploy/k8s/overlays/staging
cp config.env.example config.env    # set APP_HOST / AUTH_HOST
cp secrets.env.example secrets.env
chmod +x render-local.sh && ./render-local.sh

kustomize edit set image \
  ghcr.io/mastilovic/coffeeshop-backend-go=ghcr.io/mastilovic/coffeeshop-backend-go:sha-<tag> \
  ghcr.io/mastilovic/coffeeshop-frontend=ghcr.io/mastilovic/coffeeshop-frontend:sha-<tag>

kubectl apply -k .
```

## GitHub Actions — branch workflow

| Branch | Workflow | Tests + Docker | GHCR tags | Staging deploy (k3s) |
|--------|----------|----------------|-----------|----------------------|
| **`dev`** | [ci-cd-staging.yml](../.github/workflows/ci-cd-staging.yml) | Yes | `dev-sha-<7>` | No |
| **`main`** (staging) | Same | Yes | `sha-<7>`, `latest` | Yes |
| **PR** | [backend-ci.yml](../.github/workflows/backend-ci.yml), [frontend-ci.yml](../.github/workflows/frontend-ci.yml) | Yes | None (`push: false`) | No |

Recommended flow: feature branch → PR into **`dev`** → PR **`dev` → `main`** when ready for staging.

### Automatic CI/CD (primary)

**`main`** — every push or merge (including from `dev`) runs the full pipeline automatically:

1. Backend and frontend tests (always on `main`, no path filter).
2. Builds and pushes both images as `sha-<7>` and `latest` (GitHub-hosted).
3. Deploys to `coffeeshop-staging` with `sha-<7>` on the `k3s-staging` runner.

**`dev`** — every push starts **CI/CD Staging**; tests and builds run only when app, frontend, or deploy paths changed. Images are tagged `dev-sha-<7>` only; deploy is skipped.

**PRs** use Backend CI / Frontend CI, not CI/CD Staging.

If **no runs appear** after pushing to `main`, see [GITHUB_SETUP.md](GITHUB_SETUP.md) (Actions must be enabled in repository settings).

Both images are rebuilt on every `main` deploy so the cluster never pulls a missing tag for one app.

### Manual deploy (rollback / hotfix)

Workflow: [.github/workflows/deploy-staging.yml](../.github/workflows/deploy-staging.yml) (`workflow_dispatch`).

Use when you need to redeploy an existing image without rebuilding (e.g. pin `image_tag` to an older `sha-abc1234` or `latest`).

### Repository variables (`Settings` → `Secrets and variables` → `Actions` → **Variables**)

| Name | Pipeline writes to | Example (`kafenerija.online`) |
|------|-------------------|-------------------------------|
| `STAGING_APP_HOST` | `config.env` → `APP_HOST`, realm template → redirect URIs | `app.kafenerija.online` |
| `STAGING_AUTH_HOST` | `config.env` → `AUTH_HOST`, Keycloak `KC_HOSTNAME` | `auth.kafenerija.online` |
| `STAGING_PUBLIC_SCHEME` | `KEYCLOAK_JWT_ISSUER_URI`, `CORS_ALLOWED_ORIGINS` scheme (`http` or `https`; default `http`) | `http` |

### Repository secrets

| Name | Pipeline writes to |
|------|-------------------|
| `STAGING_POSTGRES_PASSWORD` | `secrets.env` |
| `STAGING_KEYCLOAK_POSTGRES_PASSWORD` | `secrets.env` |
| `STAGING_KEYCLOAK_ADMIN` | `secrets.env` |
| `STAGING_KEYCLOAK_ADMIN_PASSWORD` | `secrets.env` |
| `STAGING_KEYCLOAK_BACKEND_CLIENT_SECRET` | `secrets.env` + rendered realm `secret` |
| `KUBE_CONFIG` | **Not used for k3s staging.** Optional later for a managed cluster (`kubeconfig_source: secret`). |

### First-time setup

1. Bootstrap k3s, ingress-nginx, cert-manager (above).
2. Configure `STAGING_*` variables and secrets.
3. Install the GitHub Actions runner labeled `linux,k3s-staging` (see GITHUB_SETUP.md).
4. Push to `main` — **CI/CD Staging** should build, push, and deploy automatically.

### Manual deploy only

1. Actions → **Deploy Staging** → **Run workflow**.
2. Set `image_tag` (e.g. `sha-abc1234` from a prior **CI/CD Staging** run, or `latest`).

## DNS

Point A records at the **vServer**, not a cloud load balancer:

| Type | Host | FQDN | Value |
|------|------|------|--------|
| A | `app` | `app.kafenerija.online` | `195.234.126.162` |
| A | `auth` | `auth.kafenerija.online` | `195.234.126.162` |

```bash
dig +short app.kafenerija.online
dig +short auth.kafenerija.online
kubectl get ingress coffeeshop -n coffeeshop-staging \
  -o custom-columns='APP:.spec.rules[0].host,AUTH:.spec.rules[1].host'
```

Users open **`https://app.kafenerija.online/`** after TLS (or `http://` before `STAGING_PUBLIC_SCHEME=https`). Ingress hosts must match GitHub variables; redeploy after changing variables.

## Verification checklist

```bash
kubectl get pods -n coffeeshop-staging
kubectl rollout status deployment/backend -n coffeeshop-staging
```

| Check | Command / action |
|-------|------------------|
| SPA loads | `curl -sS "https://$APP_HOST/" \| head` |
| API via frontend proxy | `curl -sS -o /dev/null -w "%{http_code}" "https://$APP_HOST/api/v1/..."` |
| Keycloak ready | `curl -sS "https://$AUTH_HOST/health/ready"` |
| Login / register | Use the UI; watch backend logs for JWT issuer errors |

### Common issues

- **401 after login**: JWT `iss` must match `KEYCLOAK_JWT_ISSUER_URI` on the backend (e.g. `https://<AUTH_HOST>/realms/coffeeshop` when `STAGING_PUBLIC_SCHEME=https`), not `http://keycloak:8080/...`.
- **Keycloak redirect errors**: set `STAGING_APP_HOST` variable to the hostname users open in the browser.
- **Image pull errors**: Add `ghcr-pull` secret or make GHCR packages public.
- **Postgres pending**: Check PVC provisioning (`kubectl get pvc -n coffeeshop-staging`); k3s default is `local-path`.
- **`Insufficient cpu` / pods Pending**: See **Resource sizing** below.

## Resource sizing

App Deployments use `maxSurge: 0` so rollouts do not temporarily run two backend/frontend/Keycloak pods (avoids a deploy-time CPU spike; brief unavailability during image updates).

### Base defaults ([`deploy/k8s/base`](k8s/base))

| Workload | CPU request | Memory request | Memory limit |
|----------|-------------|----------------|--------------|
| backend | 50m | 64Mi | 256Mi |
| keycloak | 150m | 384Mi | 768Mi |
| postgres (×2) | 50m each | 192Mi each | 384Mi each |
| frontend | 25m | 64Mi | 128Mi |

**Base steady-state (namespace only):** ~325m CPU, ~896Mi memory requests.

### Staging small-node patch ([`overlays/staging/patches/resources-small-node.yaml`](k8s/overlays/staging/patches/resources-small-node.yaml))

Applied only when using `kubectl apply -k deploy/k8s/overlays/staging`. Keycloak is **not** reduced.

| Workload | CPU request | Memory request | Memory limit |
|----------|-------------|----------------|--------------|
| backend | 50m | 32Mi | 192Mi |
| keycloak | 150m | 384Mi | 768Mi |
| postgres (×2) | 50m each | 96Mi each | 256Mi each |
| frontend | 25m | 32Mi | 96Mi |

**Staging steady-state (namespace only):** ~325m CPU, ~640Mi memory requests.

The staging vServer is **4 CPU / 8 GB**, which fits k3s + ingress + cert-manager + this patch. On a **2 GB** node, scheduling can still be tight.

If pods are **OOMKilled**, raise limits on the affected workload (e.g. Postgres to `128Mi` request / `320Mi` limit in the staging patch). If Postgres stays **Pending** with `Insufficient memory`, use **Bootstrap on small nodes** below.

### Bootstrap on small nodes

If Keycloak schedules before `postgres-keycloak` and both DB pods stay **Pending**, free scheduler headroom once:

```bash
kubectl scale deployment keycloak backend -n coffeeshop-staging --replicas=0
kubectl wait --for=condition=ready pod/postgres-0 pod/postgres-keycloak-0 -n coffeeshop-staging --timeout=180s
kubectl scale deployment keycloak backend -n coffeeshop-staging --replicas=1
```

Verify after deploy:

```bash
kubectl describe node | grep -A6 "Allocated resources"
kubectl get pods -n coffeeshop-staging
kubectl rollout status deployment/keycloak -n coffeeshop-staging
kubectl top pods -n coffeeshop-staging   # requires metrics-server
```

## Layout

```text
deploy/
  bootstrap/k3s/        # VM cluster install
  k8s/
    base/               # Portable app manifests (no environment namespace)
    components/
      platform-k3s/     # local-path StorageClass
      platform-doks/    # stub for managed Kubernetes
    overlays/staging/   # namespace, secrets, config, realm, image tags
    infra/cert-manager/
```

## Pull request CI

- [.github/workflows/backend-ci.yml](../.github/workflows/backend-ci.yml) — backend tests + Docker build (no push).
- [.github/workflows/frontend-ci.yml](../.github/workflows/frontend-ci.yml) — frontend tests + Docker build (no push).

Push builds for **`dev`** and staging deploys for **`main`** are handled by **CI/CD Staging**.

## Follow-ups (not in v1)

- Managed Postgres instead of in-cluster StatefulSets
- Production overlay and sealed secrets
- Flux/Argo for multiple clusters
