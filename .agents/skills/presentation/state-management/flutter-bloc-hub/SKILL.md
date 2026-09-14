---
name: flutter-bloc-hub
description: Primary coordinator and architecture guide for Flutter BLoC & Cubit state management. Use when designing, organizing, refactoring, or auditing presentation state management. Serves as the central entry point and routes to specialized sub-skills for BLoC core patterns, UI widgets & scoping, and HydratedBloc persistence.
---

# Flutter BLoC State Management Hub

## 1. Overview & Architectural Foundations

This skill serves as the central root coordinator for all State Management using `bloc` and `flutter_bloc` within the application. It enforces strict Clean Architecture boundaries, unidirectional data flow (UDF), and routes agents to specialized sub-skills for core logic, UI widgets, and persistence.

### Core State Management Laws (per `AGENTS.md`):

1. **Strict Clean Architecture Boundary:**
   - BLoCs/Cubits MUST ONLY interact with **Domain UseCases**. Direct interaction with `Repositories`, `DataSources`, or `ApiClients` is **STRICTLY PROHIBITED**.
   - DTOs and raw network responses must NEVER cross into BLoC or UI layers.
2. **Pure Dart Constraint:**
   - BLoCs/Cubits MUST NOT import `package:flutter/material.dart` or any Flutter UI packages. Pure Dart only.
3. **No Public Imperative API:**
   - UI MUST ONLY communicate with BLoCs by dispatching typed events: `context.read<FeatureBloc>().add(FeatureEvent())`. Never invoke public methods directly on BLoC classes.
4. **Three-File Pattern:**
   - Feature BLoCs must be split using `part` / `part of`: `_event.dart`, `_state.dart`, and `_bloc.dart`.
5. **Deterministic Immutability:**
   - Base Events and States MUST be `sealed class`. Concrete variants MUST be `final class` extending `Equatable`. Use `@CopyWith()` for states requiring mutation.

---

## 2. State Management Skill Tree & Routing Matrix

Use this matrix to navigate to the specialized sub-skill matching your specific state management task:

| Sub-Domain | Target Sub-Skill | When to Consult |
| :--- | :--- | :--- |
| **Core Architecture & Logic** | [flutter-bloc-core](../flutter-bloc-core/SKILL.md) | BLoC vs Cubit decision, sealed events/states, `bloc_concurrency` (`restartable`, `droppable`, `sequential`), `emit.isDone` async guards, error handling, and `@injectable` DI. |
| **UI Widgets & Scoping** | [flutter-bloc-widgets](../flutter-bloc-widgets/SKILL.md) | `BlocBuilder`, `BlocListener`, `BlocConsumer`, `BlocSelector`, `context.read` vs `watch` vs `select`, `BlocProvider` vs `BlocProvider.value` for dialogs/bottom sheets/routes. |
| **Hydrated Persistence** | [flutter-hydrated-bloc](../flutter-hydrated-bloc/SKILL.md) | Local UI state caching with `HydratedBloc`/`HydratedCubit`, mandatory separation of `fromJson`/`toJson` into `.mixin.dart`, PII safety rules, and fallback strategies. |
| **Navigation Integration** | [flutter-auto-route-hub](../../navigation/flutter-auto-route-hub/SKILL.md) | Navigation architecture, deep linking, and type-safe routing. |
| **Clean Architecture Integration** | [flutter-clean-architecture](../../../flutter-clean-architecture/SKILL.md) | Upstream Domain UseCases, Repository interfaces, and layer boundaries. |
| **UI Presentation Hub** | [flutter-ui-hub](../../ui/flutter-ui-hub/SKILL.md) | Downstream widget decomposition, page templates, and design system integration. |

---

## 3. Directory & File Organization Standard

Structure feature state management directories strictly inside `lib/presentation/state_management/`:

```text
lib/presentation/
├── state_management/
│   └── <feature_name>/
│       ├── <feature_name>_event.dart                   # part of '<feature_name>_bloc.dart';
│       ├── <feature_name>_state.dart                   # part of '<feature_name>_bloc.dart';
│       ├── <feature_name>_bloc.dart                    # main bloc file with imports, DI & handlers
│       └── hydrated_<feature_name>_bloc.mixin.dart    # ONLY if HydratedBloc persistence is required
└── pages/
    └── <feature_name>/
        ├── <feature_name>_page.dart                    # Provides BlocProvider & root layout (<200 lines)
        └── widgets/                                    # Sub-widgets consuming BlocBuilder/Selector (<150 lines)
```

---

## 4. Master State Management Verification Checklist

Before completing any BLoC or Cubit implementation:
- [ ] BLoC file imports pure Dart packages only (`bloc`, `bloc_concurrency`, `equatable`, `injectable`, domain use cases). Zero Flutter UI imports.
- [ ] BLoC is annotated with `@injectable` and injected dependencies are Domain UseCases only.
- [ ] Events and States use Dart 3 `sealed class` (base) and `final class` (variants).
- [ ] Every `await` inside event handlers is immediately followed by `if (emit.isDone) return;`.
- [ ] Appropriate event transformer (`restartable()`, `droppable()`, `sequential()`) is applied where required.
- [ ] UI widgets dispatch events via `context.read<Bloc>().add()` and never call public methods.
- [ ] Side effects (navigation, snackbars, dialogs) are strictly handled in `BlocListener`.
- [ ] Existing instances provided to modal routes/dialogs use `BlocProvider.value(...)` to avoid premature disposal.
