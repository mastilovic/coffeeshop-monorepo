# cert-manager (cluster bootstrap)

Installs [cert-manager](https://cert-manager.io/) and applies Let’s Encrypt **ClusterIssuer** resources used by the CoffeeShop Ingress (ingress-shim).

## Prerequisites

1. **NGINX Ingress** with `ingressClassName: nginx` (see [deploy/README.md](../../../README.md)).
2. **DNS:** `APP_HOST` and `AUTH_HOST` A records point at the ingress load balancer IP; port **80** reachable (HTTP-01).
3. **kubectl** and **Helm 3** configured for your cluster.

## Install

```bash
cd deploy/k8s/infra/cert-manager
chmod +x install.sh
./install.sh
```

Options:

| Env | Default | Purpose |
|-----|---------|---------|
| `CERT_MANAGER_CHART_VERSION` | `v1.16.2` | Pin Helm chart version |
| `SMALL_NODE` | `1` | Set to `0` for chart default resource requests |

## Rollout order

1. `./install.sh` (this directory)
2. Deploy app: `kubectl apply -k deploy/k8s/overlays/staging` or GitHub **CI/CD Staging**
3. Wait until `Certificate` `coffeeshop-tls` is **Ready** in `coffeeshop-staging`
4. Set GitHub variable `STAGING_PUBLIC_SCHEME=https` and redeploy (see [GITHUB_SETUP.md](../../../GITHUB_SETUP.md))

Do **not** set `STAGING_PUBLIC_SCHEME=https` before the certificate is Ready.

## How it connects to the app

- Base Ingress defines `spec.tls` and `secretName: coffeeshop-tls`.
- Staging patch sets `cert-manager.io/cluster-issuer: letsencrypt-prod`.
- cert-manager creates a `Certificate` from the Ingress (ingress-shim) and stores TLS in `coffeeshop-tls`.

`letsencrypt-staging` in `clusterissuers.yaml` is for experiments only. Staging Ingress uses **`letsencrypt-prod`** (browser-trusted; required for Go OIDC / JWT issuer discovery).

## Verify

```bash
kubectl get pods -n cert-manager
kubectl get clusterissuer
kubectl get certificate,order,challenge -n coffeeshop-staging
kubectl describe certificate coffeeshop-tls -n coffeeshop-staging
kubectl get secret coffeeshop-tls -n coffeeshop-staging
```

Public cert (replace host):

```bash
openssl s_client -connect auth.kafenerija.online:443 -servername auth.kafenerija.online </dev/null 2>/dev/null \
  | openssl x509 -noout -issuer -dates
```

## Troubleshooting

| Symptom | Check |
|---------|--------|
| `ClusterIssuer` not Ready | `kubectl describe clusterissuer letsencrypt-prod` |
| `Certificate` Pending | `kubectl describe certificate coffeeshop-tls -n coffeeshop-staging` |
| Challenge stuck | DNS to LB IP, port 80 open, Ingress hosts match DNS |
| Backend 401 / PKIX errors | Use `letsencrypt-prod`, not staging issuer; set `STAGING_PUBLIC_SCHEME=https` after cert Ready |

## GitHub Actions

One-time cluster bootstrap: **Actions → Install cert-manager (DOKS)** (`workflow_dispatch`). Uses the same `KUBE_CONFIG` secret as staging deploy.

App deploy workflows do **not** install cert-manager automatically.
