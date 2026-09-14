---
name: flutter-bloc-widgets
description: Complete Flutter UI widgets and scoping guide for flutter_bloc. Use when building UI with BlocBuilder, BlocListener, BlocConsumer, BlocSelector, MultiBlocProvider, MultiBlocListener, deciding between context.read vs watch vs select, or configuring BlocProvider vs BlocProvider.value for bottom sheets, dialogs, and navigation routes.
---

# Flutter BLoC UI Widgets & Scoping Guide

## 1. Overview & When to Apply

Use this skill whenever:
- Connecting BLoC or Cubit instances to Flutter UI trees.
- Choosing the right widget among `BlocBuilder`, `BlocListener`, `BlocConsumer`, and `BlocSelector`.
- Providing BLoC instances using `BlocProvider(create: ...)` versus `BlocProvider.value(...)`.
- Passing existing BLoC instances to `showModalBottomSheet`, `showDialog`, or new navigation routes.
- Optimizing widget rebuild performance using `BlocSelector`, `buildWhen`, and `context.select`.
- Handling one-off side effects (navigation, SnackBars, dialogs) cleanly without polluting widget rendering.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [flutter-bloc-hub](../flutter-bloc-hub/SKILL.md) | Domain architecture and overall routing. |
| **Core BLoC Logic** | [flutter-bloc-core](../flutter-bloc-core/SKILL.md) | Designing states, events, and async safety. |
| **Navigation** | [flutter-auto-route-core](../../navigation/flutter-auto-route-core/SKILL.md) | Type-safe navigation triggered from `BlocListener`. |
| **UI Hub** | [flutter-ui-hub](../../ui/flutter-ui-hub/SKILL.md) | General UI structure, page rules, and decomposition. |

---

## 3. UI Component Responsibility Matrix

| Widget | Primary Responsibility | Ideal Use Case | Strict Anti-Pattern Warning |
| :--- | :--- | :--- | :--- |
| **`BlocBuilder`** | Pure visual rendering and widget rebuilds based on state. | Rendering list items, loading spinners, content views. | **DO NOT** trigger side effects (e.g. `Navigator.push`, `showSnackBar`, analytics) inside `builder`. |
| **`BlocListener`** | Handling one-off UI side effects. | Navigation, showing Dialogs / BottomSheets, SnackBars. | **DO NOT** return UI layout or build widgets inside `listener`. It returns `void`. |
| **`BlocConsumer`** | Combined Listener + Builder in a single tree node. | When both UI rebuild and side effect trigger at the same widget tree level. | Avoid when listener and builder logic are structurally far apart or cluttered. |
| **`BlocSelector`** | Granular rebuild strictly when a specific sub-field changes. | Extracting a single primitive or sub-property from a large state. | Do not use for entire state changes where `BlocBuilder` with `buildWhen` is clearer. |
| **`MultiBlocListener`** | Stacking multiple listeners cleanly without deep nesting indentation. | Pages listening to AuthBloc, NotificationBloc, and FeatureBloc simultaneously. | Avoid creating deeply nested chains of single `BlocListener` widgets. |

---

## 4. `BlocProvider` vs `BlocProvider.value` Scoping Rules

```text
┌────────────────────────────────────────────────────────────────────────┐
│                        BLoC Lifespan Hierarchy                         │
├────────────────────────────────────────────────────────────────────────┤
│  BlocProvider(create: (ctx) => getIt<FeatureBloc>())                  │
│    ├── Owns the lifecycle                                              │
│    └── Automatically calls bloc.close() when removed from widget tree  │
├────────────────────────────────────────────────────────────────────────┤
│  BlocProvider.value(value: context.read<FeatureBloc>())                │
│    ├── Reuses an existing instance                                     │
│    └── Does NOT call bloc.close() when the child tree is popped        │
└────────────────────────────────────────────────────────────────────────┘
```

- **Root Page Scoping:** Always use `BlocProvider(create: ...)` to bind BLoC lifecycle to the route.
- **Modal & Dialog Sharing:** Always use `BlocProvider.value(value: ...)` to prevent premature `.close()`.

---

## 5. Reference Implementations (`examples/`)

- **Feature View with `BlocConsumer`:** [examples/feature_page_bloc_consumer.dart](examples/feature_page_bloc_consumer.dart)
  - Demonstrates isolated `listenWhen` / `listener` (for snackbars) and `buildWhen` / `builder` (for rendering).
- **Modal & BottomSheet Scoping:** [examples/modal_bloc_scoping_sample.dart](examples/modal_bloc_scoping_sample.dart)
  - Demonstrates passing existing BLoC instances to `showModalBottomSheet` via `BlocProvider.value`.

---

## 6. Context Extensions: `read` vs `watch` vs `select`

| Method | Behavior | Where Allowed | Where Prohibited |
| :--- | :--- | :--- | :--- |
| **`context.read<T>()`** | Retrieves BLoC instance without subscribing to state changes. | Event handlers, callbacks (`onPressed`), `initState`, helper actions. | **DO NOT** use inside `build()` to render dynamic UI values (won't rebuild). |
| **`context.watch<T>()`** | Subscribes current widget to ALL state changes of BLoC. | Small isolated leaf widgets requiring full state. | **DO NOT** use at top level of large build methods (causes full screen rebuilds). |
| **`context.select<T, R>()`** | Subscribes current widget ONLY to specific property `R`. | Leaf widgets needing a single field. | Prefer `BlocSelector` for explicit readability in complex trees. |

---

## 7. Verification Checklist

- [ ] Side effects (navigation, snackbars) are strictly isolated in `BlocListener`.
- [ ] Visual widgets are rendered via `BlocBuilder` with `buildWhen` or `BlocSelector`.
- [ ] `BlocProvider.value` is used when passing BLoCs to BottomSheets or Dialogs.
- [ ] No `context.watch()` calls at the root of large screen widget trees.
