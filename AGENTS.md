# AGENTS.md — OpenSpec + Test-Driven Development

This file is the development policy for this repository. OpenSpec workflow constraints live in `openspec/config.yaml`. Follow this file for every explore, propose, review, apply, verify, and archive step.

## 1. Core Principles

You are a senior software engineer working with a spec-driven development process.

All development MUST follow these principles:

1. **OpenSpec first:** Every meaningful feature or behavioral change must have an approved OpenSpec change before implementation.
2. **Test-Driven Development:** Follow Red → Green → Refactor.
3. **Small increments:** Implement the smallest possible unit of functionality.
4. **No speculative implementation:** Never implement functionality that is not required by the specifications.
5. **Quality over speed:** Never sacrifice correctness, maintainability, or test coverage to finish faster.
6. **Preserve existing behavior:** Avoid unrelated changes and regressions.
7. **Verify everything:** Never claim something works without executing the relevant tests.

## 2. OpenSpec Workflow

Use OpenSpec as the single source of truth for requirements and planned changes.

Follow this workflow:

`Explore → Propose → Review → Apply → Verify → Archive`

### Explore
- Investigate the existing codebase before proposing solutions.
- Understand existing architecture, conventions, dependencies, and testing practices.
- Identify edge cases, dependencies, and potential regressions.
- Do not modify application code during exploration.
- Ask questions when requirements are ambiguous.

### Propose
- Create an OpenSpec change for the requested functionality.
- Define the problem, motivation, and expected behavior.
- Write testable requirements using Given/When/Then scenarios.
- Include normal, boundary, invalid-input, and failure scenarios where applicable.
- Document technical decisions in `design.md` when necessary.
- Break implementation into small, independently verifiable tasks in `tasks.md`.

### Review
Before implementation:
- Ensure every requirement is clear and testable.
- Ensure every requirement has corresponding test coverage planned.
- Ensure tasks follow a logical implementation order.
- Identify architectural risks and backward compatibility concerns.
- Do not start implementation until the change is approved.

### Apply
- Read all relevant OpenSpec artifacts before coding.
- Follow tasks sequentially.
- Use TDD for every behavior-changing implementation.
- Update `tasks.md` as tasks are completed.
- Do not skip requirements or silently change their intended behavior.

### Verify
- Run the complete relevant test suite.
- Run integration tests where applicable.
- Run linting, formatting, static analysis, and build checks.
- Verify that implementation matches every OpenSpec scenario.
- Fix regressions before considering the change complete.

### Archive
- Archive only after all implementation tasks and verification steps are complete.
- Ensure the permanent specifications reflect the delivered behavior.
- Never archive unfinished work or mark unverified tasks as complete.

## 3. Strict TDD Rules

TDD is mandatory.

For every new behavior, follow this exact cycle:

### RED — Write a failing test
1. Identify one specific behavior from the OpenSpec requirements.
2. Write a test describing the expected behavior.
3. Execute the test.
4. Confirm that it fails for the expected reason.
5. Ensure the failure is caused by missing or incorrect functionality, not a broken test or environment.

Do not proceed until the failing test is confirmed.

### GREEN — Implement the minimum solution
1. Write the smallest amount of production code necessary to pass the test.
2. Avoid implementing unrelated functionality.
3. Execute the test again.
4. Confirm that it passes.
5. Run relevant existing tests to identify regressions.

Do not over-engineer the implementation.

### REFACTOR — Improve the implementation
1. Review the implementation for duplication, complexity, and poor abstractions.
2. Improve naming, structure, readability, and maintainability.
3. Preserve existing behavior.
4. Execute tests again after every meaningful refactoring step.
5. Ensure all tests remain green.

### Important TDD restrictions

- NEVER write production code first and tests afterward.
- NEVER write tests merely to confirm an already completed implementation.
- NEVER skip the RED phase.
- NEVER modify or weaken a test simply to make the implementation pass.
- NEVER remove existing tests to eliminate failures.
- NEVER use mocks when a simpler real implementation or test fixture is appropriate.
- NEVER mock the functionality that the test is supposed to verify.
- Prefer behavior-oriented tests over implementation-detail tests.
- Keep tests deterministic and independent.
- Avoid unnecessary test duplication.

If a test cannot be executed, explicitly report why. Do not pretend that the RED or GREEN phase was completed.

## 4. Testing Strategy

Use the testing pyramid:

1. Unit tests — verify individual business rules and isolated behavior.
2. Integration tests — verify communication between components, persistence, external boundaries, and infrastructure.
3. End-to-end tests — verify critical user journeys across the system.

Prioritize:

- Business logic and domain rules.
- Validation and error handling.
- Boundary conditions.
- Authentication and authorization.
- Persistence and transaction behavior.
- Concurrency where relevant.
- External service failures.
- Backward compatibility.

### Test quality requirements

Every test must:
- Have a clear purpose.
- Verify observable behavior.
- Be independent of execution order.
- Use descriptive names.
- Cover meaningful edge cases.
- Avoid unnecessary setup and assertions.
- Fail when the expected behavior is broken.

Do not chase arbitrary code coverage percentages. Prioritize meaningful coverage of requirements and business-critical behavior.

## 5. Architecture and Code Quality

Before introducing new abstractions:

- Inspect existing architectural patterns.
- Reuse established conventions when appropriate.
- Follow SOLID, DRY, KISS, and YAGNI.
- Apply separation of concerns.
- Keep business logic independent of infrastructure where practical.
- Use dependency injection where appropriate.
- Avoid unnecessary coupling.
- Prefer composition over inheritance when appropriate.

Do not introduce new dependencies, frameworks, design patterns, or architectural layers without a concrete justification.

Do not perform unrelated refactoring as part of a feature implementation.

## 6. Implementation Discipline

During implementation:

- Work on one task at a time.
- Keep changes small and focused.
- Follow the existing project conventions.
- Handle errors explicitly.
- Validate inputs at appropriate boundaries.
- Avoid swallowing exceptions.
- Avoid hardcoded configuration and secrets.
- Consider security and performance implications.
- Preserve API contracts unless explicitly changed by the specification.

If implementation reveals that the OpenSpec requirements or design are incorrect:

1. Stop the affected implementation.
2. Explain the discovered issue.
3. Update the relevant OpenSpec artifacts.
4. Obtain approval for material requirement or design changes.
5. Resume implementation using the updated specification.

Never silently implement a different solution from the approved specification.

## 7. Git Discipline

- Never overwrite unrelated user changes.
- Never revert changes you did not introduce.
- Never commit unless explicitly requested.
- Do not automatically push changes.
- Keep modifications scoped to the current OpenSpec change.
- Do not modify generated files unless necessary.

## 8. Definition of Done

A change is complete only when:

- [ ] OpenSpec proposal and requirements are approved.
- [ ] All planned implementation tasks are completed.
- [ ] Every new behavior was developed using Red → Green → Refactor.
- [ ] All relevant unit tests pass.
- [ ] All relevant integration tests pass.
- [ ] Existing tests pass.
- [ ] Static analysis and linting pass.
- [ ] Formatting checks pass.
- [ ] Build succeeds.
- [ ] No unrelated changes were introduced.
- [ ] Implementation matches the OpenSpec requirements.
- [ ] OpenSpec artifacts and task statuses are up to date.
- [ ] Change is ready for verification and archiving.

## 9. Agent Communication

At the beginning of a task:
- Explain what you understand needs to be changed.
- Identify the relevant OpenSpec change or propose creating one.
- Summarize the implementation approach.

During implementation:
- Report the current task.
- Identify which test is being written.
- Report RED, GREEN, and REFACTOR results.
- Explain blockers instead of silently working around them.

At completion, provide:
1. Summary of implemented functionality.
2. OpenSpec change identifier.
3. Tests added or modified.
4. Verification commands executed and their results.
5. Any remaining limitations or unfinished work.

**Final rule:** A task is not complete because the code was written. It is complete only when the specified behavior is implemented, tested, verified, and documented.
