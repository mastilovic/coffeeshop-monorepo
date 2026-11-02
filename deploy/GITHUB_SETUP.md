# GitHub Actions — staging configuration

The deploy pipeline **writes all runtime config** before `kubectl apply`. You only configure GitHub **Variables** and **Secrets**; do not edit generated files in the repo.

Deploy workflows install pinned `kubectl` and `kustomize` from official release URLs into `$HOME/.local/bin` when they are missing (no `sudo`, so the self-hosted runner works). Prefer the k3s `kubectl` already on the VM.

CI workflows avoid third-party marketplace actions that download from `codeload.github.com` (for example `dorny/paths-filter`, `docker/*`, `gradle/actions`). Path filtering uses `git diff` in shell; Docker build/push uses the local composite [`.github/actions/docker-build-push`](../.github/actions/docker-build-push); Gradle runs via `./gradlew` after `actions/setup-java` only. If logs still show `Failed to download archive` from `codeload.github.com`, check **Settings → Actions** allowlists — the shell/local approach does not depend on those downloads.

**Branches:** Every push or merge to **`main`** runs the full **CI/CD Staging** pipeline (tests, images, k3s deploy) automatically — including empty commits. Pushes to **`dev`** run path-filtered tests/builds and push `dev-sha-*` only (no deploy). Rollback redeploy only: manual [Deploy Staging](../.github/workflows/deploy-staging.yml) with an existing `image_tag`.

Staging **apply** runs on a self-hosted runner labeled **`k3s-staging`** using the node kubeconfig (`kubeconfig_source: local-k3s`). Image **builds** stay on `ubuntu-latest`. `KUBE_CONFIG` is **not required** for k3s staging.

Do not destroy the previous DigitalOcean Kubernetes cluster until the public HTTPS smoke test in this file passes. Until then, DNS rollback (A records back to the old load balancer) remains valid.

## Self-hosted runner (`k3s-staging`)

Install the [GitHub Actions runner](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/adding-self-hosted-runners) on the staging VM as a systemd service.

1. Repo **Settings → Actions → Runners → New self-hosted runner** (Linux x64).
2. Labels: `linux` and **`k3s-staging`** (in addition to `self-hosted`).
3. Run as a dedicated user that can read the k3s kubeconfig (copy `/etc/rancher/k3s/k3s.yaml` to that user's `~/.kube/config`, mode **0600**).
4. The runner dials out to GitHub; it must **not** listen on a public port. Leave Kubernetes API **6443** closed on the provider firewall.

The reusable deploy workflow selects this runner with:

```yaml
runs_on: '["self-hosted","linux","k3s-staging"]'
kubeconfig_source: local-k3s
```

Managed Kubernetes later can call the same reusable workflow with `runs_on: '["ubuntu-latest"]'` and `kubeconfig_source: secret` plus a `KUBE_CONFIG` secret.

## When workflows run

| Trigger | What you see |
|---------|----------------|
| Push or merge to **`main`** | **CI/CD Staging**: backend and frontend tests; image builds (`sha-*` / `latest`) on GitHub-hosted; deploy on `k3s-staging`. Triggered when `coffeeshop-go/**`, `coffeeshop-frontend/**`, `deploy/**`, or workflow files change. |
| Push to **`dev`** | **CI/CD Staging** starts; tests/builds only when those paths changed. |
| **PR** | **Backend CI** and **Frontend CI** only — not **CI/CD Staging**. |
| **Deploy Staging** (manual) | Redeploy an existing image without rebuilding — rollback/hotfix only. Runs on `k3s-staging`. |
| **Install cert-manager** (manual) | One-time: Helm install cert-manager + apply ClusterIssuers (`deploy/k8s/infra/cert-manager/install.sh`) on `k3s-staging`. Prefer running `install.sh` over SSH during first bootstrap. |

### No runs appear in Actions at all?

This is not fixed by workflow YAML — check repository settings:

1. **Settings → Actions → General** → **Allow all actions and reusable workflows**.
2. Confirm `.github/workflows/ci-cd-staging.yml` exists on **`main`** on GitHub (compare with `git ls-remote origin main`).
3. If this repo is a **fork**, enable Actions under **Actions** tab → “I understand my workflows will run…”.
4. Actions tab → select **CI/CD Staging**, branch **All branches**, not only failed runs.
5. Confirm a runner with label **`k3s-staging`** is Idle. Deploy jobs wait if the runner is offline.

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

Changing variables does **not** update the cluster until the next deploy (push to `main` or **Deploy Staging**).

### DNS (Namecheap or any registrar)

Point two **A** records at the vServer (`195.234.126.162`), not a cloud load balancer:

| Type | Host | Example FQDN | Value |
|------|------|----------------|--------|
| A | `app` | `app.kafenerija.online` | `195.234.126.162` |
| A | `auth` | `auth.kafenerija.online` | `195.234.126.162` |

Verify: `dig +short app.kafenerija.online` returns `195.234.126.162`.

### Verify Ingress matches GitHub variables

```bash
kubectl get ingress coffeeshop -n coffeeshop-staging \
  -o custom-columns='APP:.spec.rules[0].host,AUTH:.spec.rules[1].host'
```

Both columns must match `STAGING_APP_HOST` and `STAGING_AUTH_HOST`. If they show old hosts, redeploy after updating variables.

## Secrets (Actions → Secrets)

| Name | Used for |
|------|----------|
| `STAGING_POSTGRES_PASSWORD` | App Postgres |
| `STAGING_KEYCLOAK_POSTGRES_PASSWORD` | Keycloak Postgres |
| `STAGING_KEYCLOAK_ADMIN` | Keycloak admin username |
| `STAGING_KEYCLOAK_ADMIN_PASSWORD` | Keycloak admin password |
| `STAGING_KEYCLOAK_BACKEND_CLIENT_SECRET` | Backend client secret in rendered realm + backend Deployment |
| `KUBE_CONFIG` | **Not used for k3s staging.** Optional for a future managed cluster (`kubeconfig_source: secret`). |

## TLS / cert-manager

cert-manager is **not** installed by **CI/CD Staging** or **Deploy Staging**. Install it once per cluster before expecting HTTPS certificates.

### One-time install

1. On the VM (preferred during bootstrap):
   ```bash
   cd deploy/k8s/infra/cert-manager && ./install.sh
   ```
   Or **Actions → Install cert-manager → Run workflow** (runs on `k3s-staging`, uses the local kubeconfig — not `KUBE_CONFIG`).
2. Deploy the app (**CI/CD Staging** on `main` or **Deploy Staging**).
3. Wait until the certificate is Ready (after DNS points at the VM):
   ```bash
   kubectl get certificate coffeeshop-tls -n coffeeshop-staging
   ```
4. Set variable **`STAGING_PUBLIC_SCHEME`** to **`https`** and redeploy.

Do **not** set `STAGING_PUBLIC_SCHEME=https` until step 3 succeeds, or the backend JWT issuer URL will not match a working HTTPS endpoint.

Details: [deploy/k8s/infra/cert-manager/README.md](k8s/infra/cert-manager/README.md).

## Keycloak realm re-import

Keycloak starts with `--import-realm`. If realm `coffeeshop` **already exists** in Postgres, a redeploy may **not** update client redirect URIs.

After changing `STAGING_APP_HOST` or the realm template:

1. **Keycloak Admin** at `http://<STAGING_AUTH_HOST>/` (or `https://` when TLS is enabled) → **Clients** → `coffeeshop-backend` → add `http://<STAGING_APP_HOST>/*` and `https://<STAGING_APP_HOST>/*` to **Valid redirect URIs** and **Web origins**, or
2. Staging-only: delete the Keycloak deployment and Keycloak Postgres PVC to force a clean import (loses Keycloak users).

## Post-deploy verification

```bash
kubectl exec -n coffeeshop-staging deploy/backend -- env | grep KEYCLOAK_JWT_ISSUER_URI
# e.g. https://auth.kafenerija.online/realms/coffeeshop

curl -sS -o /dev/null -w "%{http_code}\n" "https://app.kafenerija.online/"
curl -sS -o /dev/null -w "%{http_code}\n" "https://auth.kafenerija.online/health/ready"
```

Browser: `https://<STAGING_APP_HOST>/` — register/login. If **401 after login**, decode the JWT `iss` claim; it must exactly match `KEYCLOAK_JWT_ISSUER_URI` on the backend (same scheme and host).

If pods stay **Pending** with `Insufficient cpu` or `Insufficient memory`, see [deploy/README.md — Resource sizing](README.md#resource-sizing). Staging applies reduced memory requests via `patches/resources-small-node.yaml` (Keycloak unchanged).

## Local deploy (same substitution model)

```bash
cd deploy/k8s/overlays/staging
cp config.env.example config.env    # set APP_HOST / AUTH_HOST / PUBLIC_SCHEME
cp secrets.env.example secrets.env  # set passwords; KEYCLOAK_BACKEND_CLIENT_SECRET must match realm
chmod +x render-local.sh
./render-local.sh
kubectl apply -k .
```
