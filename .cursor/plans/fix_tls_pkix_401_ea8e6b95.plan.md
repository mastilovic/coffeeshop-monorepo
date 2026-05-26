---
name: fix_tls_pkix_401
overview: Resolve 401s caused by backend JWT decoder TLS trust failure by moving staging Ingress from Let’s Encrypt staging to production issuer, then validating cert-manager issuance and backend issuer discovery.
todos:
  - id: switch-staging-issuer
    content: Change staging ingress cert-manager annotation to `letsencrypt-prod` in `deploy/k8s/overlays/staging/patches/ingress-cert-manager-issuer.yaml`.
    status: completed
  - id: deploy-and-watch-acme
    content: Deploy staging overlay and monitor Certificate/Order/Challenge resources until `coffeeshop-tls` is Ready.
    status: completed
  - id: verify-cert-chain
    content: Confirm served TLS chain for `auth` host is publicly trusted (openssl) and backend can resolve OIDC discovery.
    status: completed
  - id: validate-auth-flow
    content: Re-login over HTTPS with fresh tokens and verify protected API endpoints no longer return 401 due to JwtDecoder init errors.
    status: completed
isProject: false
---

# Fix JWT PKIX Failure After TLS

## Root Cause
The backend fails JWT issuer discovery over HTTPS because Java cannot validate the TLS chain served by `auth.kafenerija.online`.

Evidence from [coffeeshop/error.md](/Users/amastilovic/Desktop/dev/coffeeshop-monorepo/coffeeshop/error.md):
- `Unable to resolve the Configuration with the provided Issuer of "https://auth.kafenerija.online/realms/coffeeshop"`
- `SSLHandshakeException ... PKIX path building failed`

Current staging Ingress is pinned to Let’s Encrypt staging in [deploy/k8s/overlays/staging/patches/ingress-cert-manager-issuer.yaml](/Users/amastilovic/Desktop/dev/coffeeshop-monorepo/deploy/k8s/overlays/staging/patches/ingress-cert-manager-issuer.yaml), which is not trusted by default JVM truststores.

## Implementation Plan

### 1) Switch staging Ingress to trusted CA
- Update [deploy/k8s/overlays/staging/patches/ingress-cert-manager-issuer.yaml](/Users/amastilovic/Desktop/dev/coffeeshop-monorepo/deploy/k8s/overlays/staging/patches/ingress-cert-manager-issuer.yaml):
  - Change `cert-manager.io/cluster-issuer` from `letsencrypt-staging` to `letsencrypt-prod`.
- Keep `KEYCLOAK_JWT_ISSUER_URI=https://<AUTH_HOST>/realms/coffeeshop` flow unchanged (already generated in [deploy-staging-reusable.yml](/Users/amastilovic/Desktop/dev/coffeeshop-monorepo/.github/workflows/deploy-staging-reusable.yml)).

### 2) Deploy and monitor certificate issuance
- Apply staging manifests and watch cert-manager resources in `coffeeshop-staging`:
  - `Ingress` annotation and `tls.secretName`
  - `Certificate` readiness (`coffeeshop-tls`)
  - `CertificateRequest`, `Order`, `Challenge`
- Verify `ClusterIssuer` readiness for `letsencrypt-prod` from [deploy/k8s/infra/cert-manager/clusterissuers.yaml](/Users/amastilovic/Desktop/dev/coffeeshop-monorepo/deploy/k8s/infra/cert-manager/clusterissuers.yaml).

### 3) Verify served cert and backend trust path
- Validate public cert chain on `auth.kafenerija.online:443` (openssl).
- Confirm backend runtime env has HTTPS issuer (`KEYCLOAK_JWT_ISSUER_URI`).
- Restart backend rollout only if needed after cert/issuer stabilization.

### 4) Validate auth end-to-end
- Confirm OIDC discovery URL resolves with trusted cert:
  - `https://auth.<host>/realms/coffeeshop/.well-known/openid-configuration`
- Clear stale browser tokens and re-login over `https://app.<host>`.
- Verify protected API calls return expected authz results (no `JwtDecoderInitializationException` / PKIX logs).

## Verification Commands (runbook)
- `kubectl -n coffeeshop-staging get ingress coffeeshop -o yaml`
- `kubectl -n coffeeshop-staging get certificate,certificaterequest,order,challenge`
- `kubectl -n coffeeshop-staging describe certificate coffeeshop-tls`
- `kubectl get clusterissuer letsencrypt-prod -o yaml`
- `echo | openssl s_client -servername auth.kafenerija.online -connect auth.kafenerija.online:443 2>/dev/null | openssl x509 -noout -issuer -subject -dates`
- `kubectl -n coffeeshop-staging exec deploy/backend -- printenv KEYCLOAK_JWT_ISSUER_URI`

## Risk / Rollback Notes
- Let’s Encrypt prod has rate limits; avoid repeated reissue loops.
- If issuance fails, inspect `Challenge`/`Order` events before retrying.
- Rollback option: temporarily set issuer back to staging only if you also revert backend issuer to HTTP/internal for non-prod testing; otherwise PKIX failures will persist.
