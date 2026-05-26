# CoffeeShop — DigitalOcean Kubernetes (staging)

Deploy the full stack (Postgres ×2, Keycloak, Spring backend, Angular frontend) to a DOKS cluster using [Kustomize](https://kustomize.io/).

## Architecture

```text
Internet → NGINX Ingress (DO Load Balancer)
  ├─ APP_HOST  → frontend:80 → nginx proxies /api/* → backend:8080
  └─ AUTH_HOST → keycloak:8080

backend → postgres (app DB), keycloak (token/admin API)
keycloak → postgres-keycloak
```

Images are built by GitHub Actions and published to GHCR:

- `ghcr.io/mastilovic/coffeeshop-backend`
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

### 4. TLS (optional for first smoke test)

HTTP-only works for initial checks. For HTTPS, install [cert-manager](https://cert-manager.io/) and add a `Certificate` + TLS block on the Ingress.

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
  ghcr.io/mastilovic/coffeeshop-backend=ghcr.io/mastilovic/coffeeshop-backend:sha-<tag> \
  ghcr.io/mastilovic/coffeeshop-frontend=ghcr.io/mastilovic/coffeeshop-frontend:sha-<tag>

kubectl apply -k .
```

## GitHub Actions deploy

### Automatic deploy (primary)

On every push to **`main`** that touches app, deploy, or workflow paths, [.github/workflows/ci-cd-staging.yml](../.github/workflows/ci-cd-staging.yml) runs:

1. Path-filtered tests (backend and/or frontend; both run when only `deploy/**` changes).
2. **Always** builds and pushes **both** images to GHCR as `sha-<7>` (same commit SHA).
3. Deploys to `coffeeshop-staging` with that tag.

Both images are rebuilt on every `main` deploy so the cluster never pulls a missing tag for one app.

### Manual deploy (rollback / hotfix)

Workflow: [.github/workflows/deploy-staging.yml](../.github/workflows/deploy-staging.yml) (`workflow_dispatch`).

Use when you need to redeploy an existing image without rebuilding (e.g. pin `image_tag` to an older `sha-abc1234` or `latest`).

### Repository variables (`Settings` → `Secrets and variables` → `Actions` → **Variables**)

| Name | Pipeline writes to | Example |
|------|-------------------|---------|
| `STAGING_APP_HOST` | `config.env` → `APP_HOST`, realm template → redirect URIs | `staging.app.coffeeshop.com` |
| `STAGING_AUTH_HOST` | `config.env` → `AUTH_HOST`, `KEYCLOAK_JWT_ISSUER_URI` | `staging.auth.coffeeshop.com` |

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

After the first apply:

```bash
kubectl get ingress -n coffeeshop-staging
```

Point `APP_HOST` and `AUTH_HOST` A records at the Ingress external IP.

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

- **401 after login**: `KEYCLOAK_JWT_ISSUER_URI` must be the **public** issuer (`https://<AUTH_HOST>/realms/coffeeshop`), not `http://keycloak:8080/...`.
- **Keycloak redirect errors**: set `STAGING_APP_HOST` variable to the hostname users open in the browser.
- **Image pull errors**: Add `ghcr-pull` secret or make GHCR packages public.
- **Postgres pending**: Check PVC provisioning (`kubectl get pvc -n coffeeshop-staging`); DO default StorageClass is usually `do-block-storage`.
- **`localhost:8080` / openapi connection refused on deploy**: `KUBE_CONFIG` is empty, truncated, or not a valid DOKS kubeconfig. Recreate the secret from a single-cluster file (see **`KUBE_CONFIG` secret** above). The deploy workflow logs `Context:` and `API server:` before `kubectl apply`.

## Layout

```text
deploy/k8s/
  base/                 # Shared manifests
  overlays/staging/     # Secrets, config, realm, image tags
```

## Pull request CI

- [.github/workflows/backend-ci.yml](../.github/workflows/backend-ci.yml) — backend tests + Docker build (no push).
- [.github/workflows/frontend-ci.yml](../.github/workflows/frontend-ci.yml) — frontend tests + Docker build (no push).

`main` branch builds and deploys are handled only by **CI/CD Staging**.

## Follow-ups (not in v1)

- cert-manager + Let's Encrypt on Ingress
- Managed Postgres instead of in-cluster StatefulSets
- Production overlay and sealed secrets
