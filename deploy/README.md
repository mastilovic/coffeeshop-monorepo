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

## Local deploy (manual)

```bash
cd deploy/k8s/overlays/staging
cp config.env.example config.env    # edit APP_HOST / AUTH_HOST
cp secrets.env.example secrets.env  # set strong passwords

# Match realm client secret with KEYCLOAK_BACKEND_CLIENT_SECRET in secrets.env
# Update redirectUris/webOrigins in realm-coffeeshop.json if hosts differ from the example.

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

| Name | Example |
|------|---------|
| `STAGING_APP_HOST` | `staging.app.example.com` |
| `STAGING_AUTH_HOST` | `staging.auth.example.com` |

### Repository secrets

| Name | Purpose |
|------|---------|
| `KUBE_CONFIG` | Full kubeconfig file from `doctl kubernetes cluster kubeconfig save` |
| `STAGING_POSTGRES_PASSWORD` | App database password |
| `STAGING_KEYCLOAK_POSTGRES_PASSWORD` | Keycloak database password |
| `STAGING_KEYCLOAK_ADMIN` | Keycloak admin username (e.g. `admin`) |
| `STAGING_KEYCLOAK_ADMIN_PASSWORD` | Keycloak admin password |
| `STAGING_KEYCLOAK_BACKEND_CLIENT_SECRET` | Must match `coffeeshop-backend` client secret in `realm-coffeeshop.json` |

### First-time setup

1. Configure variables and secrets below.
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
- **Keycloak redirect errors**: `realm-coffeeshop.json` `redirectUris` / `webOrigins` must include `https://<APP_HOST>`.
- **Image pull errors**: Add `ghcr-pull` secret or make GHCR packages public.
- **Postgres pending**: Check PVC provisioning (`kubectl get pvc -n coffeeshop-staging`); DO default StorageClass is usually `do-block-storage`.

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
