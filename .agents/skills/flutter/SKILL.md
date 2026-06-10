---
name: flutter
description: >
  Flutter hub skill — entry point for all Flutter work in this repo.
  Displays a skill index and routes to the right sub-skill before acting.
  Trigger: /flutter, "flutter help", "what flutter skills", "use flutter skill".
disable-model-invocation: true
---

# Flutter

Hub for Flutter development in this monorepo (`coffeeshop-mobile/`). One-shot reference when invoked with no task; router when invoked with a task.

## On invoke

**No specific task** (e.g. `/flutter` alone) → display the skill index below. Do not start implementation.

**Task included** (e.g. `/flutter fix login overflow`) →
1. Match task to sub-skill(s) using the routing table
2. **Read** the matched `SKILL.md` file(s) before writing code
3. Proceed with the task following that skill's workflow

Invoke a sub-skill directly anytime: `/flutter-add-widget-test`, `/flutter-use-http-package`, etc.

## Flutter skills

| Skill | Trigger | Use when |
|-------|---------|----------|
| **flutter-apply-architecture-best-practices** | `/flutter-apply-architecture-best-practices` | Structuring a new project or refactoring layers (UI, Logic, Data) |
| **flutter-setup-declarative-routing** | `/flutter-setup-declarative-routing` | `go_router`, deep linking, `MaterialApp.router` |
| **flutter-use-http-package** | `/flutter-use-http-package` | REST API calls with the `http` package |
| **flutter-implement-json-serialization** | `/flutter-implement-json-serialization` | Model classes with `fromJson` / `toJson` |
| **flutter-setup-localization** | `/flutter-setup-localization` | i18n setup (`flutter_localizations`, `intl`, `l10n.yaml`) |
| **flutter-build-responsive-layout** | `/flutter-build-responsive-layout` | Adaptive layouts for phone, tablet, desktop |
| **flutter-fix-layout-issues** | `/flutter-fix-layout-issues` | RenderFlex overflow, unbounded constraints, layout errors |
| **flutter-add-widget-preview** | `/flutter-add-widget-preview` | Interactive widget previews via `previews.dart` |
| **flutter-add-widget-test** | `/flutter-add-widget-test` | Component tests with `WidgetTester` |
| **flutter-add-integration-test** | `/flutter-add-integration-test` | End-to-end flows with `integration_test` |

All live under `.agents/skills/<skill-name>/SKILL.md`.

## Related Dart skills

Flutter work often pairs with these — read when the task matches:

| Skill | Trigger | Use when |
|-------|---------|----------|
| **dart-run-static-analysis** | `/dart-run-static-analysis` | `dart analyze`, `dart fix --apply`, pre-commit quality |
| **dart-fix-runtime-errors** | `/dart-fix-runtime-errors` | Active stack traces, hot-reload verification |
| **dart-add-unit-test** | `/dart-add-unit-test` | Unit tests for providers, repositories, pure logic |
| **dart-generate-test-mocks** | `/dart-generate-test-mocks` | Mockito + `build_runner` for API/DB mocks |
| **dart-collect-coverage** | `/dart-collect-coverage` | LCOV coverage reports |
| **dart-resolve-package-conflicts** | `/dart-resolve-package-conflicts` | `pub get` version conflicts |
| **dart-use-pattern-matching** | `/dart-use-pattern-matching` | Switch expressions, pattern matching |
| **dart-use-ffigen** | `/dart-use-ffigen` | Auto-generate FFI bindings |
| **dart-setup-ffi-assets** | `/dart-setup-ffi-assets` | Native C/C++ assets via Dart hooks |
| **dart-migrate-to-checks-package** | `/dart-migrate-to-checks-package` | Migrate `matcher` → `checks` in tests |
| **dart-build-cli-app** | `/dart-build-cli-app` | Dart CLI tools (not typical for mobile) |

## Routing table

| Task signal | Primary skill | Also consider |
|-------------|---------------|---------------|
| Project structure, feature folders, layers | flutter-apply-architecture-best-practices | — |
| Navigation, routes, deep links | flutter-setup-declarative-routing | — |
| API calls, auth tokens, HTTP errors | flutter-use-http-package | flutter-implement-json-serialization |
| JSON models, DTOs, parsing | flutter-implement-json-serialization | flutter-use-http-package |
| Translations, locales, ARB files | flutter-setup-localization | — |
| Tablet/desktop layout, breakpoints | flutter-build-responsive-layout | — |
| Overflow, constraint errors | flutter-fix-layout-issues | flutter-build-responsive-layout |
| New screen/widget UI work | flutter-add-widget-preview | flutter-build-responsive-layout |
| Widget-level test | flutter-add-widget-test | dart-generate-test-mocks |
| Full user-flow test | flutter-add-integration-test | flutter-add-widget-test |
| Analyzer warnings, lint fixes | dart-run-static-analysis | — |
| Runtime crash, red screen | dart-fix-runtime-errors | flutter-fix-layout-issues |
| Provider/repo unit test | dart-add-unit-test | dart-generate-test-mocks |
| `pub get` fails | dart-resolve-package-conflicts | — |

Multiple skills may apply — read all matches, then implement.

## Project context

- **App**: `coffeeshop-mobile/` — Flutter mobile client for the coffeeshop monorepo
- **Backend**: `coffeeshop-go/` — Go API (auth, products, orders)
- **Conventions**: Match existing patterns in `lib/core/`, `lib/features/` before introducing new abstractions

## Agents (not skills)

For mobile UX/design decisions (touch targets, nav patterns, accessibility), also consider the `mobile-design` agent.
