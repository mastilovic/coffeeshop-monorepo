---
name: Fix deploy kubectl action
overview: Replace failing third-party GitHub Actions (`azure/setup-kubectl@v4`, `imranismail/setup-kustomize@v2`) in the deploy reusable workflow with pinned shell installs so Deploy Staging (DOKS) and CI/CD deploy jobs no longer depend on codeload.github.com action tarballs.
todos:
  - id: replace-tool-install
    content: "In deploy-staging-reusable.yml: remove azure/setup-kubectl@v4 and imranismail/setup-kustomize@v2; add pinned shell install step for kubectl + kustomize"
    status: completed
  - id: verify-doks-manual
    content: Push to main; run Deploy Staging (DOKS) from Actions UI with image_tag latest or known sha-*
    status: pending
  - id: confirm-deploy-job
    content: Confirm run passes Install/Verify cluster steps; fix STAGING_* secrets/vars only if later steps fail
    status: pending
isProject: false
---

# Fix Deploy Staging kubectl/kustomize download failure

## Problem

**Deploy Staging (DOKS)** (and the **deploy** job in CI/CD Staging via [`deploy-staging-reusable.yml`](.github/workflows/deploy-staging-reusable.yml)) fails at job setup:

```text
Failed to download archive 'https://codeload.github.com/Azure/setup-kubectl/tar.gz/...'
```

`actions/checkout@v4` succeeds; **`azure/setup-kubectl@v4`** fails before any cluster steps run. This is a **marketplace action download** failure, not missing secrets or bad kubeconfig.

The next step [`imranismail/setup-kustomize@v2`](.github/workflows/deploy-staging-reusable.yml) (line 68) can fail the same way once kubectl is fixed.

```mermaid
flowchart LR
  checkout[checkout OK]
  kubectl[setup-kubectl FAIL]
  kustomize[setup-kustomize]
  deploy[kubectl apply]
  checkout --> kubectl
  kubectl --> kustomize
  kustomize --> deploy
```

**Scope:** Only [`.github/workflows/deploy-staging-reusable.yml`](.github/workflows/deploy-staging-reusable.yml). No changes to [`ci-cd-staging.yml`](.github/workflows/ci-cd-staging.yml) unless you later re-merge dev/dispatch improvements separately.

---

## Recommended fix: shell install (no marketplace dependency)

Replace lines 64–68 with a single step that installs **pinned** CLI versions from official release URLs. This avoids `codeload.github.com` for kubectl/kustomize entirely.

```yaml
      - name: Install kubectl and kustomize
        run: |
          set -euo pipefail
          KUBECTL_VERSION="v1.32.0"
          KUSTOMIZE_VERSION="5.6.0"
          curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -o kubectl
          chmod +x kubectl
          sudo mv kubectl /usr/local/bin/kubectl
          kubectl version --client
          curl -fsSL "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_amd64.tar.gz" | tar xz
          sudo mv kustomize /usr/local/bin/kustomize
          kustomize version
```

**Why pinned versions:** `azure/setup-kubectl` with `latest` has historically broken when `dl.k8s.io` stable.txt points at a missing build. Pinning avoids that class of failure too.

**Versions:** `v1.32.0` / `5.6.0` are examples — pick current stable minors compatible with your DOKS cluster (1.28+ is typical for DOKS). Adjust only the two constants if your cluster docs specify a minimum.

Remove these steps entirely:

```yaml
      - name: Setup kubectl
        uses: azure/setup-kubectl@v4
      - name: Setup Kustomize
        uses: imranismail/setup-kustomize@v2
```

All downstream steps (`Configure kubeconfig`, `Verify cluster connection`, `kustomize edit set image`, `kubectl apply`) stay unchanged.

---

## Alternative (smaller diff, may still hit codeload)

If you prefer to keep marketplace actions:

```yaml
      - name: Setup kubectl
        uses: azure/setup-kubectl@v5
        with:
          version: 'v1.32.0'
```

Retry the workflow. If codeload still fails for `@v5`, use the shell install approach above (primary recommendation).

---

## Verification (GitHub UI only)

1. Merge/push the change to **`main`** (touches `.github/workflows/**` → triggers **CI/CD Staging** if your current [`ci-cd-staging.yml`](.github/workflows/ci-cd-staging.yml) path filters match).
2. **Actions → Deploy Staging (DOKS) → Run workflow**
   - Branch: `main`
   - `image_tag`: `latest` (or a known-good `sha-*` from GHCR)
3. Confirm the run passes:
   - **Install kubectl and kustomize** (or Setup kubectl)
   - **Configure kubeconfig** / **Verify cluster connection**
   - **Deploy to cluster** (rollouts may fail for app/config reasons — that is a separate issue from this fix)
4. If deploy fails later with missing vars/secrets, fix per [deploy/GITHUB_SETUP.md](deploy/GITHUB_SETUP.md) (`STAGING_APP_HOST`, `KUBE_CONFIG`, etc.) — not part of this change.

---

## Optional doc touch (one line)

In [deploy/GITHUB_SETUP.md](deploy/GITHUB_SETUP.md) or [deploy/README.md](deploy/README.md), note that deploy installs `kubectl`/`kustomize` via pinned binaries in the workflow (no `azure/setup-kubectl`). Low priority.

---

## Out of scope

| Item | Reason |
|------|--------|
| Re-adding `dev` / `workflow_dispatch` to CI/CD | Separate from deploy tool install; do incrementally after deploy is green |
| `gh` CLI verification | Per your preference |
| Changing `actions/checkout@v4` | Already works |

---

## Success criteria

- Manual **Deploy Staging (DOKS)** completes past the install step (no codeload error for `setup-kubectl`).
- `kubectl cluster-info` step runs (proves binary + `KUBE_CONFIG`).
- CI/CD **deploy** job (when triggered) uses the same reusable workflow and benefits automatically.
