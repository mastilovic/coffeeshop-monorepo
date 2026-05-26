---
name: Fix Actions Not Triggering
overview: GitHub Actions workflows are not triggering despite correct YAML configuration. The root cause is likely a GitHub repo-level settings issue (Actions disabled or minutes exhausted), compounded by a gh CLI account mismatch that prevents CLI-based diagnosis.
todos:
  - id: fix-gh-auth
    content: "Fix gh CLI authentication: login as `mastilovic` (repo owner) instead of `amastilovic-pd`"
    status: pending
  - id: check-actions-settings
    content: Check GitHub repo Settings > Actions > General -- ensure Actions is enabled and permissions are correct
    status: pending
  - id: check-billing
    content: Check Actions billing/minutes to rule out quota exhaustion
    status: pending
  - id: add-workflow-dispatch
    content: Add workflow_dispatch trigger with optional skip_tests to ci-cd-staging.yml
    status: pending
  - id: verify-pipeline
    content: Push a change to main and confirm CI/CD Staging run appears in Actions tab
    status: pending
isProject: false
---

# Fix GitHub Actions Not Triggering on Push/Merge

## Root Cause Analysis

The workflow YAML is **correct** -- there is nothing wrong with the trigger configuration:

```6:6:.github/workflows/ci-cd-staging.yml
    branches: [dev, main]
```

No `paths` filter on push. Every push to `main` or `dev` should create a run. The file exists on remote `main` (verified at `f5496bf`). Multiple commits since the last successful run (`b4432c6`) should have triggered workflows but didn't.

### Finding 1: `gh` CLI Account Mismatch (blocks CLI diagnosis)

Two different GitHub accounts are in play:

- **SSH** (`git push`/`pull`): authenticates as **`mastilovic`** -- the repo owner
- **`gh` CLI**: authenticated as **`amastilovic-pd`** -- a **different** account with NO access to the private repo

This is why `gh run list`, `gh workflow list`, and all GitHub API calls return **404 Not Found**. You cannot diagnose or interact with Actions from the CLI until this is fixed.

### Finding 2: GitHub Actions Disabled/Restricted at Repo Level

Since the YAML is valid and files are on the correct branch, the only explanation for **zero workflow runs** across ~8 commits is a **platform-level block**:

- **Most likely**: Actions is disabled or restricted in repo Settings. After commit `b4432c6` (the last working run), something changed at the repo settings level.
- **Also possible**: GitHub Actions minutes exhausted on the free tier (2,000 min/month for private repos).

---

## Phase 1: Fix `gh` CLI Access (required for diagnosis)

Authenticate `gh` with the `mastilovic` account that owns the repo:

```bash
gh auth login
```

Select `github.com`, authenticate as `mastilovic` (not `amastilovic-pd`). Alternatively, add `amastilovic-pd` as a collaborator on the repo via GitHub.com.

After fixing auth, verify with:

```bash
gh run list --repo mastilovic/coffeeshop-monorepo --limit 5
gh workflow list --repo mastilovic/coffeeshop-monorepo
```

---

## Phase 2: Check and Fix GitHub Repo Settings

On **https://github.com/mastilovic/coffeeshop-monorepo**, check these settings (logged in as `mastilovic`):

### 2a. Actions Permissions
**Settings > Actions > General > Actions permissions**
- Must be set to **"Allow all actions and reusable workflows"**
- If set to "Disable actions" -- that's the root cause

### 2b. Workflow Permissions
**Settings > Actions > General > Workflow permissions**
- Should be **"Read and write permissions"** (needed for `packages: write` in build jobs)
- Check "Allow GitHub Actions to create and approve pull requests" if needed

### 2c. Actions Billing
**Settings > Billing and plans** (or org billing if under an org)
- Verify Actions minutes are not exhausted for the current billing cycle
- Private repos on free plan: 2,000 min/month

---

## Phase 3: Workflow Improvement -- Add `workflow_dispatch`

Add a manual trigger to [`.github/workflows/ci-cd-staging.yml`](.github/workflows/ci-cd-staging.yml) as a fallback so you can always trigger the pipeline from the UI or CLI, even if push triggers fail:

```yaml
on:
  push:
    branches: [dev, main]
  workflow_dispatch:
    inputs:
      skip_tests:
        description: 'Skip unit tests (emergency deploy only)'
        type: boolean
        default: false
```

Wire `skip_tests` into the test jobs:

```yaml
  backend-test:
    if: >-
      (needs.changes.outputs.backend == 'true' || needs.changes.outputs.deploy == 'true')
      && inputs.skip_tests != true
```

Same for `frontend-test`.

---

## Phase 4: Verify the Fix

After enabling Actions in repo settings:

1. Push a trivial change to `main` -- confirm a **CI/CD Staging** run appears within 30 seconds
2. If `workflow_dispatch` was added, test: **Actions > CI/CD Staging > Run workflow** on `main`
3. On a green build from `main`, confirm the **deploy** job runs (not skipped)
4. Push to `dev` -- confirm run appears with **deploy** skipped (gated to `main` only)

---

## Summary of All Workflow Triggers

| Workflow | Trigger | Branches |
|----------|---------|----------|
| CI/CD Staging | `push` (+ `workflow_dispatch` after fix) | `dev`, `main` |
| Backend CI | `pull_request` only | any (path-filtered) |
| Frontend CI | `pull_request` only | any (path-filtered) |
| Deploy Staging (DOKS) | `workflow_dispatch` only | manual |
| Deploy Staging (reusable) | `workflow_call` only | called by CI/CD Staging |

**Backend CI** and **Frontend CI** will never appear on direct pushes to `main` -- they are PR-only. This is expected behavior, not a bug.
