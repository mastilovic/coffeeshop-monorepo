# GitHub Actions — staging configuration

The deploy pipeline **writes all runtime config** before `kubectl apply`. You only configure GitHub **Variables** and **Secrets**; do not edit generated files in the repo.

**Branches:** Pushes to **`dev`** build/test and push `dev-sha-*` images to GHCR (no cluster deploy). Pushes to **`main`** publish `sha-*` / `latest` and **deploy to DOKS**. Manual [Deploy Staging (DOKS)](../.github/workflows/deploy-staging.yml) uses `sha-<7>` from a **main** build unless you specify another tag.

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
