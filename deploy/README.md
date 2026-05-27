# CoffeeShop — DigitalOcean Kubernetes (staging)

Deploy the full stack (Postgres ×2, Keycloak, Spring backend, Go backend, Angular frontend) to a DOKS cluster using [Kustomize](https://kustomize.io/).

## Architecture

```text
Internet → NGINX Ingress (DO Load Balancer)
  ├─ APP_HOST  → frontend:80 → nginx proxies /api/v1/* → backend:8080
  │                          → nginx proxies /api/v2/* → backend-go:8080
  └─ AUTH_HOST → keycloak:8080

backend, backend-go → postgres (app DB), keycloak (token/admin API)
keycloak → postgres-keycloak
```

`backend-go` reads `DATABASE_URL`, Keycloak, and CORS from the shared `coffeeshop-config` ConfigMap and `coffeeshop-secrets` Secret (same as the Java backend).

Images are built by GitHub Actions and published to GHCR:

- `ghcr.io/mastilovic/coffeeshop-backend-go`
- `ghcr.io/mastilovic/coffeeshop-frontend`

## One-time cluster setup

### 1. Connect kubectl

```bash
doctl auth init
doctl kubernetes cluster kubeconfig save <your-cluster-name>
kubectl get nodes
```

### 2. Install NGINX Ingress Controller

Use the [DigitalOcean marketplace](https://marketplace.digitalocean.com/apps/nginx-ingress-controller) or Helm:

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace
```

Manifests expect `ingressClassName: nginx`.

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

### 4. Install cert-manager (once per cluster)

Required for HTTPS on the CoffeeShop Ingress. The app manifests already define TLS and a `letsencrypt-prod` issuer annotation; this step installs the controller and ClusterIssuers.

```bash
cd deploy/k8s/infra/cert-manager
chmod +x install.sh
./install.sh
```

Or use GitHub Actions: **Install cert-manager (DOKS)** (`workflow_dispatch`). See [deploy/k8s/infra/cert-manager/README.md](k8s/infra/cert-manager/README.md) for verification and troubleshooting.

On **2 GB** nodes, install cert-manager after staging memory patches are applied; consider **≥2 vCPU / 4 GB** for a stable single-node stack.

### 5. Deploy staging and enable HTTPS

1. Deploy the app (local `kubectl apply -k deploy/k8s/overlays/staging` or push to **`main`** / **Deploy Staging**).
2. Wait until the certificate is Ready:
   ```bash
   kubectl get certificate coffeeshop-tls -n coffeeshop-staging
   ```
3. Set GitHub variable `STAGING_PUBLIC_SCHEME=https` and redeploy so JWT issuer and CORS use `https://` (see [GITHUB_SETUP.md](GITHUB_SETUP.md)).

HTTP-only smoke tests work before step 3 if `STAGING_PUBLIC_SCHEME` stays `http`.

## GitHub configuration

The deploy pipeline generates `config.env`, `secrets.env`, and `realm-coffeeshop.json` from GitHub **Variables**, **Secrets**, and `realm-coffeeshop.json.template`. You do not commit those generated files.

See **[GITHUB_SETUP.md](GITHUB_SETUP.md)** for the full list of Variables and Secrets.

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

| Branch | Workflow | Tests + Docker | GHCR tags | DOKS deploy |
|--------|----------|----------------|-----------|-------------|
| **`dev`** | [ci-cd-staging.yml](../.github/workflows/ci-cd-staging.yml) | Yes | `dev-sha-<7>` | No |
| **`main`** (staging) | Same | Yes | `sha-<7>`, `latest` | Yes |
| **PR** | [backend-ci.yml](../.github/workflows/backend-ci.yml), [frontend-ci.yml](../.github/workflows/frontend-ci.yml) | Yes | None (`push: false`) | No |

Recommended flow: feature branch → PR into **`dev`** → PR **`dev` → `main`** when ready for staging.

### Automatic CI/CD (primary)

**`main`** — every push or merge (including from `dev`) runs the full pipeline automatically:

1. Backend and frontend tests (always on `main`, no path filter).
2. Builds and pushes both images as `sha-<7>` and `latest`.
3. Deploys to `coffeeshop-staging` with `sha-<7>`.

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
| `KUBE_CONFIG` | `~/.kube/config` in the deploy job |
| `STAGING_POSTGRES_PASSWORD` | `secrets.env` |
| `STAGING_KEYCLOAK_POSTGRES_PASSWORD` | `secrets.env` |
| `STAGING_KEYCLOAK_ADMIN` | `secrets.env` |
| `STAGING_KEYCLOAK_ADMIN_PASSWORD` | `secrets.env` |
| `STAGING_KEYCLOAK_BACKEND_CLIENT_SECRET` | `secrets.env` + rendered realm `secret` |

Details: **[GITHUB_SETUP.md](GITHUB_SETUP.md)**

### `KUBE_CONFIG` secret (required)

`kubectl` talks to whatever cluster is in this file. If the secret is missing or malformed, you will see:

`Get "http://localhost:8080/openapi/v2": connection refused` — that means CI is **not** using your DOKS API; fix the secret, do not use `--validate=false`.

**Create a dedicated staging kubeconfig** (`doctl save` does not support `--kubeconfig`; use `show`):

```bash
doctl kubernetes cluster kubeconfig show <your-cluster-id> > ~/.kube/config-coffeeshop-staging
chmod 600 ~/.kube/config-coffeeshop-staging

kubectl --kubeconfig ~/.kube/config-coffeeshop-staging config current-context
kubectl --kubeconfig ~/.kube/config-coffeeshop-staging cluster-info
```

Copy the **entire file** into GitHub → **Secrets** → `KUBE_CONFIG`.

Checklist for the secret:

- Includes `apiVersion`, `clusters`, `contexts`, `users`, and `current-context`
- `server:` under `clusters` is `https://...` (DigitalOcean), not `http://localhost:8080`
- `current-context` matches your staging cluster name

### First-time setup

1. Configure variables and secrets below (especially `KUBE_CONFIG`).
2. Install NGINX Ingress on the cluster (see above).
3. Push to `main` — **CI/CD Staging** should build, push, and deploy automatically.

### Manual deploy only

1. Actions → **Deploy Staging (DOKS)** → **Run workflow**.
2. Set `image_tag` (e.g. `sha-abc1234` from a prior **CI/CD Staging** run, or `latest`).

## DNS

After the first apply, get the load balancer IP:

```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}{"\n"}'
kubectl get ingress coffeeshop -n coffeeshop-staging \
  -o custom-columns='APP:.spec.rules[0].host,AUTH:.spec.rules[1].host'
```

At your registrar (e.g. Namecheap **Advanced DNS** for `kafenerija.online`), add two **A** records to that IP:

| Host | FQDN (must match GitHub `STAGING_*_HOST`) |
|------|------------------------------------------|
| `app` | `app.kafenerija.online` |
| `auth` | `auth.kafenerija.online` |

Users open **`http://app.kafenerija.online/`** (or `https://` after TLS). Ingress hosts must match GitHub variables; redeploy after changing variables.

## Verification checklist

```bash
kubectl get pods -n coffeeshop-staging
kubectl rollout status deployment/backend -n coffeeshop-staging
```

| Check | Command / action |
|-------|------------------|
| SPA loads | `curl -sS "http://$APP_HOST/" \| head` |
| API via frontend proxy | `curl -sS -o /dev/null -w "%{http_code}" "http://$APP_HOST/api/v1/..."` |
| Keycloak ready | `curl -sS "http://$AUTH_HOST/health/ready"` |
| Login / register | Use the UI; watch backend logs for JWT issuer errors |

### Common issues

- **401 after login**: JWT `iss` must match `KEYCLOAK_JWT_ISSUER_URI` on the backend (e.g. `http://<AUTH_HOST>/realms/coffeeshop` when `STAGING_PUBLIC_SCHEME=http`), not `http://keycloak:8080/...`.
- **Keycloak redirect errors**: set `STAGING_APP_HOST` variable to the hostname users open in the browser.
- **Image pull errors**: Add `ghcr-pull` secret or make GHCR packages public.
- **Postgres pending**: Check PVC provisioning (`kubectl get pvc -n coffeeshop-staging`); DO default StorageClass is usually `do-block-storage`.
- **`localhost:8080` / openapi connection refused on deploy**: `KUBE_CONFIG` is empty, truncated, or not a valid DOKS kubeconfig. Recreate the secret from a single-cluster file (see **`KUBE_CONFIG` secret** above). The deploy workflow logs `Context:` and `API server:` before `kubectl apply`.
- **`Insufficient cpu` / pods Pending**: See **Resource sizing** below; resize the DOKS node pool or apply reduced requests from the repo.

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

Add headroom for `ingress-nginx` and DOKS system pods (`kube-system`). On a **2 GB** single-node pool, scheduling can still be tight; prefer **≥2 vCPU / 4 GB** droplets for reliable staging.

If pods are **OOMKilled**, raise limits on the affected workload (e.g. Postgres to `128Mi` request / `320Mi` limit in the staging patch). If Postgres stays **Pending** with `Insufficient memory`, use **Bootstrap on 2GB nodes** below or resize the node pool.

### Bootstrap on 2GB nodes

If Keycloak schedules before `postgres-keycloak` and both DB pods stay **Pending**, free scheduler headroom once:

```bash
kubectl scale deployment keycloak backend -n coffeeshop-staging --replicas=0
kubectl wait --for=condition=ready pod/postgres-0 pod/postgres-keycloak-0 -n coffeeshop-staging --timeout=180s
kubectl scale deployment keycloak backend -n coffeeshop-staging --replicas=1
```

Optional cluster tweaks (not in this repo): lower `ingress-nginx` controller requests via Helm, or reduce/disable DOKS Hubble if you do not need it.

Verify after deploy:

```bash
kubectl describe node | grep -A6 "Allocated resources"
kubectl get pods -n coffeeshop-staging
kubectl rollout status deployment/keycloak -n coffeeshop-staging
kubectl top pods -n coffeeshop-staging   # requires metrics-server
```

## Layout

```text
deploy/k8s/
  base/                 # Shared manifests
  overlays/staging/     # Secrets, config, realm, image tags
```

## Pull request CI

- [.github/workflows/backend-ci.yml](../.github/workflows/backend-ci.yml) — backend tests + Docker build (no push).
- [.github/workflows/frontend-ci.yml](../.github/workflows/frontend-ci.yml) — frontend tests + Docker build (no push).

Push builds for **`dev`** and staging deploys for **`main`** are handled by **CI/CD Staging**.

## Follow-ups (not in v1)

- Managed Postgres instead of in-cluster StatefulSets
- Production overlay and sealed secrets
