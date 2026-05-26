# GitHub Actions — staging configuration

The deploy pipeline **writes all runtime config** before `kubectl apply`. You only configure GitHub **Variables** and **Secrets**; do not edit generated files in the repo.

Deploy workflows install pinned `kubectl` and `kustomize` from official release URLs (no `azure/setup-kubectl` or other marketplace install actions).

CI workflows avoid third-party marketplace actions that download from `codeload.github.com` (for example `dorny/paths-filter`, `docker/*`, `gradle/actions`). Path filtering uses `git diff` in shell; Docker build/push uses the local composite [`.github/actions/docker-build-push`](../.github/actions/docker-build-push); Gradle runs via `./gradlew` after `actions/setup-java` only. If logs still show `Failed to download archive` from `codeload.github.com`, check **Settings → Actions** allowlists — the shell/local approach does not depend on those downloads.

**Branches:** Every push or merge to **`main`** runs the full **CI/CD Staging** pipeline (tests, both images, DOKS deploy) automatically — including empty commits. Pushes to **`dev`** run path-filtered tests/builds and push `dev-sha-*` only (no deploy). Rollback redeploy only: manual [Deploy Staging (DOKS)](../.github/workflows/deploy-staging.yml) with an existing `image_tag`.

## When workflows run

| Trigger | What you see |
|---------|----------------|
| Push or merge to **`main`** | **CI/CD Staging**: backend + frontend tests, both image builds (`sha-*` / `latest`), DOKS deploy. No path filtering on `main`. |
| Push to **`dev`** | **CI/CD Staging** starts; tests/builds only when `coffeeshop/**`, `coffeeshop-frontend/**`, `deploy/**`, or workflow files changed. |
| **PR** | **Backend CI** and **Frontend CI** only — not **CI/CD Staging**. |
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
| `deploy/k8s/overlays/staging/config.env` | Variables `STAGING_APP_HOST`, `STAGING_AUTH_HOST` + fixed keys |
| `deploy/k8s/overlays/staging/secrets.env` | Secrets `STAGING_*` |
| `deploy/k8s/overlays/staging/realm-coffeeshop.json` | Template + `envsubst` (see below) |

Realm template: `realm-coffeeshop.json.template` uses `${STAGING_APP_HOST}` and `${STAGING_KEYCLOAK_BACKEND_CLIENT_SECRET}` substituted in [deploy-staging-reusable.yml](../.github/workflows/deploy-staging-reusable.yml).

## Variables (Actions → Variables)

| Name | Used for | Example value |
|------|----------|---------------|
| `STAGING_APP_HOST` | Ingress host, CORS, Keycloak redirect URIs in rendered realm | `staging.app.coffeeshop.com` |
| `STAGING_AUTH_HOST` | Ingress host, `KEYCLOAK_JWT_ISSUER_URI` | `staging.auth.coffeeshop.com` |

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

## Local deploy (same substitution model)

```bash
cd deploy/k8s/overlays/staging
cp config.env.example config.env    # set APP_HOST / AUTH_HOST
cp secrets.env.example secrets.env  # set passwords; KEYCLOAK_BACKEND_CLIENT_SECRET must match intent for realm
chmod +x render-local.sh
./render-local.sh
kubectl apply -k .
```
