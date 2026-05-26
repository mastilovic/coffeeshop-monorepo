---
name: Downgrade checkout to v3
overview: "Replace all `actions/checkout@v4` references with `actions/checkout@v3` across four workflow files (9 steps total). No other input changes required; `fetch-depth: 0` on the `changes` job is supported in v3."
todos:
  - id: replace-checkout
    content: Replace actions/checkout@v4 with @v3 in ci-cd-staging, backend-ci, frontend-ci, deploy-staging-reusable (9 steps)
    status: completed
  - id: push-verify
    content: Push to main and confirm CI/CD Staging checkout steps pass on the new run
    status: completed
isProject: false
---

# Downgrade `actions/checkout` v4 to v3

## Scope

Mechanical find-and-replace in all workflow YAML that use checkout today:

| File | Occurrences |
|------|-------------|
| [`.github/workflows/ci-cd-staging.yml`](.github/workflows/ci-cd-staging.yml) | 5 (`changes`, `backend-test`, `frontend-test`, `build-backend`, `build-frontend`) |
| [`.github/workflows/backend-ci.yml`](.github/workflows/backend-ci.yml) | 2 (`build-and-test`, `docker`) |
| [`.github/workflows/frontend-ci.yml`](.github/workflows/frontend-ci.yml) | 2 (`build`, `docker`) |
| [`.github/workflows/deploy-staging-reusable.yml`](.github/workflows/deploy-staging-reusable.yml) | 1 (`deploy`) |

[`deploy-staging.yml`](.github/workflows/deploy-staging.yml) does not call checkout directly (it uses the reusable workflow).

**Change per step:**

```yaml
# Before
- uses: actions/checkout@v4

# After
- uses: actions/checkout@v3
```

Preserve existing `with:` blocks unchanged, including `fetch-depth: 0` on the `changes` job in [`ci-cd-staging.yml`](.github/workflows/ci-cd-staging.yml) (lines 34–36).

**Out of scope:** `actions/setup-java@v4`, `actions/setup-node@v4`, and other first-party actions stay on v4 unless you ask to change those separately.

---

## Expectations (important)

Your failed run showed **403 / “account suspended” during `git fetch`**, while **SSH `git ls-remote` works** from your machine. That points to a **GitHub/API/runner issue**, not a checkout action version bug.

- [`fix_codeload_action_failures` plan](.cursor/plans/fix_codeload_action_failures_5dd3c270.plan.md) already notes **`actions/checkout@v4` succeeds** in your environment; only third-party marketplace actions failed on codeload.
- Downgrading to **v3** uses the same `actions/checkout` first-party action family and the same HTTPS + `GITHUB_TOKEN` fetch path — it is **unlikely to fix** a 403 on fetch, but it matches your requested pin.

```mermaid
flowchart LR
  runner[Actions runner]
  checkoutV3[actions/checkout@v3]
  github[github.com git HTTPS]
  runner --> checkoutV3 --> github
```

---

## Implementation steps

1. Replace `actions/checkout@v4` → `actions/checkout@v3` in all four workflow files (9 lines).
2. Optional one-line note in [`deploy/GITHUB_SETUP.md`](deploy/GITHUB_SETUP.md): workflows pin `actions/checkout@v3` (only if you want docs in sync; skip if you prefer minimal diffs).
3. Commit and push to **`main`** (touches `.github/workflows/**` → triggers **CI/CD Staging**).

---

## Verification

1. In Actions, open the new run → confirm **Prepare all required actions** resolves `actions/checkout@v3` (not v4).
2. Confirm **`changes`** (and other jobs) pass the checkout step.
3. If checkout still 403s, the fix is **not** action version — re-run later or contact GitHub Support with the run URL; compare HTTPS locally: `git ls-remote https://github.com/mastilovic/coffeeshop-monorepo.git HEAD`.

---

## Success criteria

- No remaining `actions/checkout@v4` in `.github/workflows/`.
- CI jobs get past checkout; downstream steps (path filter, tests, docker composite, deploy) can run.
