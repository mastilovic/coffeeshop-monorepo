# Tasks

## 1. Portable kustomize layout

- [x] 1.1 Move `deploy/k8s/base/namespace.yaml` into `deploy/k8s/overlays/staging/namespace.yaml`, drop it from `base/kustomization.yaml`, and keep overlay `namespace: coffeeshop-staging`. Verify `kustomize build deploy/k8s/overlays/staging` (after a dummy `config.env` / `secrets.env` / realm if required) emits a Namespace named `coffeeshop-staging` and `deploy/k8s/base` no longer contains that file.
- [x] 1.2 Add kustomize Component `deploy/k8s/components/platform-k3s` that sets Postgres PVC `storageClassName: local-path`, and stub Component `deploy/k8s/components/platform-doks` with no workload patches. Verify the k3s component directory is a valid `kind: Component` and the doks stub builds on its own.
- [x] 1.3 Include `platform-k3s` from `overlays/staging/kustomization.yaml`. Verify `kustomize build deploy/k8s/overlays/staging` sets `local-path` on both Postgres volume claims and that base StatefulSets still omit a cloud StorageClass.
- [x] 1.4 Confirm base Deployments, StatefulSets, and Services have no DigitalOcean load-balancer or `do-block-storage` identifiers. Verify with a grep over `deploy/k8s/base` that those strings are absent.

## 2. k3s bootstrap script and runbook

- [x] 2.1 Add idempotent `deploy/bootstrap/k3s/install.sh` that installs k3s with Traefik disabled and does not install Docker. Verify the script exists, is executable, and greps to `--disable traefik`.
- [x] 2.2 Extend the bootstrap runbook (script comments or `deploy/bootstrap/k3s/README.md`) with Helm ingress-nginx (class `nginx`), existing `deploy/k8s/infra/cert-manager/install.sh`, firewall ports 22/80/443 only (not 6443), optional `ghcr-pull` if GHCR is private, and hostNetwork fallback if ServiceLB does not bind 80/443. Verify those steps are written and the cert-manager command matches the existing installer path.
- [x] 2.3 Rewrite DigitalOcean-only cluster setup in `deploy/README.md` to the three-layer model (cluster / platform / environment), k3s as the staging cluster, and DNS A records to `195.234.126.162`. Verify the README no longer tells operators to `doctl kubernetes cluster kubeconfig save` as the staging path and still documents `ingressClassName: nginx`.

## 3. Staging CI on the VM

- [x] 3.1 Parameterize `.github/workflows/deploy-staging-reusable.yml` with `runs-on` (default `ubuntu-latest`) and `kubeconfig_source` (`secret` vs `local-k3s`). For `local-k3s`, use the node kubeconfig and skip the DigitalOcean `https://` kubeconfig assertion. Verify the workflow file contains both inputs and the DOKS-only server check runs only for `secret`.
- [x] 3.2 Point `.github/workflows/ci-cd-staging.yml` and `.github/workflows/deploy-staging.yml` at `runs-on: [self-hosted, linux, k3s-staging]` and `kubeconfig_source: local-k3s`. Leave image build jobs on `ubuntu-latest`. Verify build jobs still use `ubuntu-latest` and both deploy callers pass the self-hosted labels.
- [x] 3.3 Update `.github/workflows/install-cert-manager.yml` naming and `deploy/GITHUB_SETUP.md` so cert-manager install and staging deploy describe the self-hosted runner / local kubeconfig path, not GitHub-hosted `KUBE_CONFIG` against DOKS. Verify `GITHUB_SETUP.md` documents runner label `k3s-staging` and that `KUBE_CONFIG` is not required for k3s staging.

## 4. Bootstrap the vServer

- [x] 4.1 SSH to `informaten@195.234.126.162`, run `deploy/bootstrap/k3s/install.sh` with sudo, and confirm the node is Ready. Verify `kubectl get nodes` on the VM shows Ready and a second run of the script does not wipe the node.
- [x] 4.2 Install ingress-nginx (Helm) and cert-manager (`install.sh`) on that cluster. Verify an `ingress-nginx` controller exists, cert-manager deployments are Available, ClusterIssuers exist, and `kubectl get sc` includes `local-path`.
- [x] 4.3 Restrict the provider firewall to TCP 22/80/443 and confirm 6443 is not open. Verify `ss` or equivalent shows 80/443 listening and a remote check of 6443 from outside the VM fails or is filtered.

## 5. First staging apply on k3s

- [x] 5.1 Render staging config/secrets/realm (`render-local.sh` or equivalent) on the VM or operator machine, create `ghcr-pull` only if image pulls fail, and `kubectl apply -k deploy/k8s/overlays/staging`. Verify all pods in `coffeeshop-staging` become Ready, both Postgres PVCs are Bound, and `kubectl describe node` memory requests fit in 8 GB.
- [x] 5.2 Hit ingress by IP before DNS cutover. Verify `curl -sS -H 'Host: app.kafenerija.online' http://195.234.126.162/` returns the SPA and Keycloak health via `Host: auth.kafenerija.online` succeeds.

## 6. DNS cutover and TLS

- [x] 6.1 Point `app.kafenerija.online` and `auth.kafenerija.online` A records at `195.234.126.162`. Verify `dig +short` for both names returns that IP.
- [x] 6.2 Wait until certificate `coffeeshop-tls` is Ready; set `STAGING_PUBLIC_SCHEME=https` and redeploy if it was `http`. Verify `kubectl get certificate coffeeshop-tls -n coffeeshop-staging` is Ready and HTTPS loads for both hosts.

## 7. Self-hosted runner and CI switch

- [x] 7.1 Install a GitHub Actions runner on the VM as a systemd service with labels `linux` and `k3s-staging`, using a user that can read the local k3s kubeconfig (mode 0600). Verify the runner appears Idle in the repo and does not listen on a public port.
- [ ] 7.2 Run workflow **Deploy Staging** once with an existing GHCR `image_tag`. Verify the job runs on `k3s-staging`, `kubectl apply` targets this cluster, and rollouts succeed while 6443 remains closed to the internet.

## 8. Cutover integration

- [x] 8.1 Smoke the public names: SPA at `https://app.kafenerija.online/`, API via the frontend proxy, Keycloak ready at `https://auth.kafenerija.online/health/ready`. Verify those three checks pass and login still works.
- [ ] 8.2 Confirm staging CI/CD no longer needs a working DOKS kubeconfig. Verify a deploy job does not read `KUBE_CONFIG` for k3s and docs state DOKS can be destroyed only after this smoke test (DNS rollback remains valid until then).
