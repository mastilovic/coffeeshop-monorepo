---
title: Feature development commands
created: 2026-11-04
updated: 2026-11-04
tags:
  - workflow
  - openspec
---

# Feature Development Commands

Use this as a quick path through feature and bug work in this repo. Start with the source material you have; do not invent requirements to make a plan look complete.

Development policy is `AGENTS.md` at the repository root. OpenSpec workflow constraints live in `openspec/config.yaml`. Follow both: approved spec first, then Red → Green → Refactor, then verify before archive.

Plans live under `openspec/`. The commands below are the Cursor commands in `.cursor/commands/`.

## 1. Start With an Idea or Partial Information

Use Explore when you have a direction, notes, or constraints but not enough detail to define behavior:

```text
/opsx-explore I want <outcome>. Current context: <what is known>. Explore the relevant code, tests, docs, and Obsidian notes. Identify options, risks, and decisions needed. Do not edit code or create a change yet.
```

Answer the focused questions. Once scope and expected behavior are clear, create the plan:

```text
/opsx-propose <kebab-case-name> <summarize the agreed behavior and constraints>
```

Review the proposal, spec scenarios, design, and tasks before implementation.

## 2. Start With a Bug Symptom

When you know what went wrong but not why, investigate first:

```text
/opsx-explore Investigate <observed symptom>. Evidence: <logs, steps, affected users, and timing>. Separate confirmed facts from hypotheses, find the likely cause, and recommend the smallest safe fix. Do not edit code or create a change yet.
```

After the cause is understood:

- For a narrow, well-understood bug, ask to implement the focused fix and regression test.
- For a cross-app, behavior-changing, or multi-step fix, capture the agreed outcome with `/opsx-propose <name> <summary>`, review the plan, then apply it.
- If investigation is the whole task, keep the findings as an investigation summary and do not force them into an implementation plan.

## 3. Check and Implement a Plan

List active changes when you are not sure what is already in progress:

```bash
openspec list --json
openspec status --all
```

Check one change before implementation:

```bash
openspec status --change "<change-name>"
```

Revise an existing plan without editing code:

```text
/opsx-update <change-name> <what changed in the plan>
```

After reviewing its artifacts, implement its tasks:

```text
/opsx-apply <change-name>
```

The apply workflow follows the task list, updates task status, and pauses if the implementation conflicts with the plan or needs a material decision.

## 4. Verify and Finish

Run the tests required by the change and validate its OpenSpec artifacts:

```bash
openspec validate <change-name>
git diff --check
```

Typical checks, depending on what changed:

- Go: tests in `coffeeshop-go`
- Web: `ng test` in `coffeeshop-frontend`
- Mobile: `flutter test` in `coffeeshop-mobile`

When implementation and required tasks are complete, sync delta specs if they should land in `openspec/specs/` before archive, then archive the change:

```text
/opsx-sync <change-name>
/opsx-archive <change-name>
```

Then add only durable, reusable discoveries to the relevant Obsidian note and update `INDEX.md`. Do not copy the entire OpenSpec plan into Obsidian.
