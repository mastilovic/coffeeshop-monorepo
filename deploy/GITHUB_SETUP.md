# GitHub Actions — staging configuration

The deploy pipeline **writes all runtime config** before `kubectl apply`. You only configure GitHub **Variables** and **Secrets**; do not edit generated files in the repo.

Deploy workflows install pinned `kubectl` and `kustomize` from official release URLs (no `azure/setup-kubectl` or other marketplace install actions).

CI workflows avoid third-party marketplace actions that download from `codeload.github.com` (for example `dorny/paths-filter`, `docker/*`, `gradle/actions`). Path filtering uses `git diff` in shell; Docker build/push uses the local composite [`.github/actions/docker-build-push`](../.github/actions/docker-build-push); Gradle runs via `./gradlew` after `actions/setup-java` only. If logs still show `Failed to download archive` from `codeload.github.com`, check **Settings → Actions** allowlists — the shell/local approach does not depend on those downloads.

**Branches:** Every push or merge to **`main`** runs the full **CI/CD Staging** pipeline (tests, three images, DOKS deploy) automatically — including empty commits. Pushes to **`dev`** run path-filtered tests/builds and push `dev-sha-*` only (no deploy). Rollback redeploy only: manual [Deploy Staging (DOKS)](../.github/workflows/deploy-staging.yml) with an existing `image_tag`.

## When workflows run

| Trigger | What you see |
|---------|----------------|
| Push or merge to **`main`** | **CI/CD Staging**: Go backend and frontend tests; two image builds (`sha-*` / `latest`); DOKS deploy. Triggered when `coffeeshop-go/**`, `coffeeshop-frontend/**`, `deploy/**`, or workflow files change. |
| Push to **`dev`** | **CI/CD Staging** starts; tests/builds only when `coffeeshop/**`, `coffeeshop-go/**`, `coffeeshop-frontend/**`, `deploy/**`, or workflow files changed. |
| **PR** | **Backend CI**, **Backend Go CI**, and **Frontend CI** only — not **CI/CD Staging**. |
| **Deploy Staging (DOKS)** (manual) | Redeploy an existing image without rebuilding — rollback/hotfix only. |

### No runs appear in Actions at all?

This is not fixed by workflow YAML — check repository settings:

1. **Settings → Actions → General** → **Allow all actions and reusable workflows**.
2. Confirm `.github/workflows/ci-cd-staging.yml` exists on **`main`** on GitHub (compare with `git ls-remote origin main`).
3. If this repo is a **fork**, enable Actions under **Actions** tab → “I understand my workflows will run…”.
4. Actions tab → select **CI/CD Staging**, branch **All branches**, not only failed runs.

## Generated during deploy (do not commit)

| File | Source |
|------|--------|
| `deploy/k8s/overlays/staging/config.env` | Variables `STAGING_APP_HOST`, `STAGING_AUTH_HOST`, `STAGING_PUBLIC_SCHEME` + fixed keys |
| `deploy/k8s/overlays/staging/secrets.env` | Secrets `STAGING_*` |
| `deploy/k8s/overlays/staging/realm-coffeeshop.json` | Template + `envsubst` (see below) |

Realm template: `realm-coffeeshop.json.template` uses `${STAGING_APP_HOST}` and `${STAGING_KEYCLOAK_BACKEND_CLIENT_SECRET}` substituted in [deploy-staging-reusable.yml](../.github/workflows/deploy-staging-reusable.yml).

## Variables (Actions → Variables)

| Name | Used for | Example (`kafenerija.online`) |
|------|----------|-------------------------------|
| `STAGING_APP_HOST` | Ingress app host, CORS, Keycloak client redirect/web origins | `app.kafenerija.online` |
| `STAGING_AUTH_HOST` | Ingress auth host, Keycloak `KC_HOSTNAME`, JWT issuer host | `auth.kafenerija.online` |
| `STAGING_PUBLIC_SCHEME` | Prefix for `KEYCLOAK_JWT_ISSUER_URI` and `CORS_ALLOWED_ORIGINS` (`http` or `https`; defaults to `http` if unset) | `http` |

Hostnames only — **no** `http://` prefix in `STAGING_APP_HOST` / `STAGING_AUTH_HOST`.

Changing variables does **not** update the cluster until the next deploy (push to `main` or **Deploy Staging (DOKS)**).

### DNS (Namecheap or any registrar)

Point two **A** records at your ingress load balancer IP:

```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}{"\n"}'
```

| Type | Host | Example FQDN |
|------|------|----------------|
| A | `app` | `app.kafenerija.online` |
| A | `auth` | `auth.kafenerija.online` |

Verify: `dig +short app.kafenerija.online` returns the LB IP.

### Verify Ingress matches GitHub variables

```bash
kubectl get ingress coffeeshop -n coffeeshop-staging \
  -o custom-columns='APP:.spec.rules[0].host,AUTH:.spec.rules[1].host'
```

Both columns must match `STAGING_APP_HOST` and `STAGING_AUTH_HOST`. If they show old hosts, redeploy after updating variables.

## Secrets (Actions → Secrets)

| Name | Used for |
|------|----------|
| `KUBE_CONFIG` | Full kubeconfig (`doctl kubernetes cluster kubeconfig show <cluster-id>`) |
| `STAGING_POSTGRES_PASSWORD` | App Postgres |
| `STAGING_KEYCLOAK_POSTGRES_PASSWORD` | Keycloak Postgres |
| `STAGING_KEYCLOAK_ADMIN` | Keycloak admin username |
| `STAGING_KEYCLOAK_ADMIN_PASSWORD` | Keycloak admin password |
| `STAGING_KEYCLOAK_BACKEND_CLIENT_SECRET` | Backend client secret in rendered realm + backend Deployment |

## Kubeconfig

```bash
doctl kubernetes cluster kubeconfig show <your-cluster-id> > ~/.kube/config-coffeeshop-staging
kubectl --kubeconfig ~/.kube/config-coffeeshop-staging cluster-info
```

Paste the entire file into secret `KUBE_CONFIG`.

## Keycloak realm re-import

Keycloak starts with `--import-realm`. If realm `coffeeshop` **already exists** in Postgres, a redeploy may **not** update client redirect URIs.

After changing `STAGING_APP_HOST` or the realm template:

1. **Keycloak Admin** at `http://<STAGING_AUTH_HOST>/` (or `https://` when TLS is enabled) → **Clients** → `coffeeshop-backend` → add `http://<STAGING_APP_HOST>/*` and `https://<STAGING_APP_HOST>/*` to **Valid redirect URIs** and **Web origins**, or  
2. Staging-only: delete the Keycloak deployment and Keycloak Postgres PVC to force a clean import (loses Keycloak users).

## Post-deploy verification

```bash
kubectl exec -n coffeeshop-staging deploy/backend -- env | grep KEYCLOAK_JWT_ISSUER_URI
# e.g. http://auth.kafenerija.online/realms/coffeeshop

curl -sS -o /dev/null -w "%{http_code}\n" "http://app.kafenerija.online/"
curl -sS -o /dev/null -w "%{http_code}\n" "http://auth.kafenerija.online/health/ready"
```

Browser: `http://<STAGING_APP_HOST>/` — register/login. If **401 after login**, decode the JWT `iss` claim; it must exactly match `KEYCLOAK_JWT_ISSUER_URI` on the backend (same scheme and host).

When you add TLS later, set `STAGING_PUBLIC_SCHEME=https`, redeploy, and use `https://` URLs in the browser.

If pods stay **Pending** with `Insufficient cpu` or `Insufficient memory`, see [deploy/README.md — Resource sizing](README.md#resource-sizing).

## Local deploy (same substitution model)

```bash
cd deploy/k8s/overlays/staging
cp config.env.example config.env    # set APP_HOST / AUTH_HOST / PUBLIC_SCHEME
cp secrets.env.example secrets.env  # set passwords; KEYCLOAK_BACKEND_CLIENT_SECRET must match realm
chmod +x render-local.sh
./render-local.sh
kubectl apply -k .
```
