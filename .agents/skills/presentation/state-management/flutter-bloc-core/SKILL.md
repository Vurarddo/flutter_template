---
name: flutter-bloc-core
description: Core architecture patterns and best practices for Flutter BLoC and Cubit. Use when creating BLoC or Cubit classes, designing sealed states and events, configuring event transformers (bloc_concurrency), handling async guards (emit.isDone), implementing error handling, or deciding between BLoC and Cubit.
---

# Flutter BLoC & Cubit Core Architecture Guide

## 1. Overview & When to Apply

Use this skill whenever:
- Designing or implementing new BLoC or Cubit classes in `lib/presentation/state_management/`.
- Deciding whether to use a **BLoC** or a **Cubit** for a given feature.
- Defining strongly-typed events and states using Dart 3 `sealed class` and `final class`.
- Applying event concurrency transformers (`restartable`, `droppable`, `sequential`) via `bloc_concurrency`.
- Enforcing asynchronous safety guards (`if (emit.isDone) return;`) and structured error logging.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [flutter-bloc-hub](../flutter-bloc-hub/SKILL.md) | Domain architecture, laws, and routing. |
| **UI Integration** | [flutter-bloc-widgets](../flutter-bloc-widgets/SKILL.md) | Connecting BLoC to widgets via Providers, Builders, and Listeners. |
| **Persistence** | [flutter-hydrated-bloc](../flutter-hydrated-bloc/SKILL.md) | State persistence and mixin extraction. |
| **Domain Layer** | [flutter-clean-architecture](../../../flutter-clean-architecture/SKILL.md) | Injecting Domain UseCases and Entities. |

---

## 3. BLoC vs Cubit Decision Matrix

| Criterion | Use **Cubit** | Use **BLoC** |
| :--- | :--- | :--- |
| **Complexity** | Simple, linear, synchronous or straightforward async transitions. | Complex workflows, multi-step operations, branchy async state machines. |
| **Trigger Mechanism** | Direct public method calls (e.g., `cubit.toggleTheme()`, `cubit.selectTab(2)`). | Explicit typed events dispatched via `bloc.add(Event())`. |
| **Concurrency Control** | Not supported natively (events execute as called without queue control). | **Mandatory** when requiring `restartable()`, `droppable()`, or `sequential()`. |
| **Event Auditing / Tracing** | States only in `BlocObserver`. No event stream logs. | Full event-to-state traceability in analytics, debug logs, and Sentry/Crashlytics. |
| **Use Case Examples** | Theme switch, bottom nav index, password visibility toggle, simple counter. | Search/autocomplete query, payment/form submission, paginated feed, multi-step wizard. |

---

## 4. File Structure & 3-File Pattern Standard

Feature BLoCs MUST be split into three separate files using `part` / `part of` directives:

```text
lib/presentation/state_management/<feature_name>/
├── <feature_name>_event.dart    # part of '<feature_name>_bloc.dart';
├── <feature_name>_state.dart    # part of '<feature_name>_bloc.dart';
└── <feature_name>_bloc.dart     # main bloc file with DI, dependencies, and event handlers
```

---

## 5. Reference Implementation (`examples/sample_bloc/`)

A production-ready reference implementation is available in `examples/sample_bloc/`:

- **Events Definition:** [examples/sample_bloc/sample_event.dart](examples/sample_bloc/sample_event.dart)
  - `sealed class SampleEvent` with `final class` concrete event variants.
- **States Definition:** [examples/sample_bloc/sample_state.dart](examples/sample_bloc/sample_state.dart)
  - `sealed class SampleState` with `@CopyWith()` for modified states (`Initial`, `InProgress`, `Success`, `Failure`).
- **BLoC Class Implementation:** [examples/sample_bloc/sample_bloc.dart](examples/sample_bloc/sample_bloc.dart)
  - `@injectable` registration, `bloc_concurrency` event transformers, async emitter guards (`if (emit.isDone) return;`), and error logging via `addError(e, st)`.

---

## 6. Strict Architectural Constraints

1. **Zero Flutter SDK Imports in BLoC Layer:** Never import `package:flutter/material.dart` or UI packages.
2. **Never Call Public Methods on BLoCs:** UI dispatches actions strictly via `context.read<FeatureBloc>().add(Event())`.
3. **Always Check Emitter Status:** After every `await`, check `if (emit.isDone) return;`.
4. **No Direct Repository Calls:** BLoCs interact exclusively through injected Domain Use Cases.

---

## 7. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Exposing public methods on BLoC classes | **CRITICAL** | Keep methods private; trigger actions strictly via Events. |
| Missing `if (emit.isDone) return;` after `await` | **HIGH** | Add safety guard after every async operation. |
| Emitting states without `bloc_concurrency` on search/click buttons | **HIGH** | Use `restartable()` for search inputs and `droppable()` for submit buttons. |
| Importing Flutter UI libraries into BLoCs | **CRITICAL** | Use pure Dart types; map to Flutter widgets/enums in UI layer. |

---

## 8. Verification Checklist

- [ ] 3-file structure applied with `part` / `part of`.
- [ ] Events and States modeled with `sealed` and `final` classes.
- [ ] Concurrency transformers applied (`restartable`, `droppable`, `sequential`).
- [ ] All event handlers check `if (emit.isDone) return;` after awaits.
- [ ] Zero Flutter SDK imports in BLoC / Cubit files.
- [ ] Annotated with `@injectable` for DI registration.
