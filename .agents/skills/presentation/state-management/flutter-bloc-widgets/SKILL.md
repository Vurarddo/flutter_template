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
| **Forms Integration** | [flutter-ui-forms-reactive](../../ui/forms/flutter-ui-forms-reactive/SKILL.md) | Connecting reactive forms to BLoC. |

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

Understanding BLoC ownership and disposal is critical to prevent memory leaks or crashes (`Bad state: Cannot emit new states after calling close`):

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

### 4.1 When to use `BlocProvider(create: ...)`
- In the root of a feature page (e.g., in `<Feature>Page`).
- When a new BLoC instance must be instantiated, scoped strictly to the page, and **disposed automatically** when the user leaves the page:

```dart
@RoutePage()
class FeaturePage extends StatelessWidget {
  final String featureId;

  const FeaturePage({super.key, required this.featureId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FeatureBloc>()..add(FeatureFetchRequested(id: featureId)),
      child: const FeatureView(),
    );
  }
}
```

### 4.2 When to use `BlocProvider.value(...)`
- When opening a **ModalBottomSheet**, **Dialog**, or **New Navigator Route** that needs to share the parent page's BLoC instance.
- Because modals and dialogs live in a separate `Navigator` overlay tree, they cannot access the parent page's `BuildContext` directly.
- `BlocProvider.value` provides the existing instance **WITHOUT** calling `close()` when the dialog or sheet is dismissed:

```dart
// Opening a BottomSheet with existing BLoC
void _showFilterModal(BuildContext context) {
  final featureBloc = context.read<FeatureBloc>();

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (modalContext) {
      // ✅ CORRECT: Reuses existing bloc without disposing it on modal dismiss
      return BlocProvider.value(
        value: featureBloc,
        child: const FeatureFilterSheet(),
      );
    },
  );
}

// ❌ ANTI-PATTERN: DO NOT use create in modals for existing bloc instances!
// showModalBottomSheet(
//   builder: (ctx) => BlocProvider(create: (_) => featureBloc, child: ...) // Will close() prematurely!
// );
```

---

## 5. Context Extensions: `read` vs `watch` vs `select`

| Method | Behavior | Where Allowed | Where Prohibited |
| :--- | :--- | :--- | :--- |
| **`context.read<T>()`** | Retrieves BLoC instance without subscribing to state changes. | Event handlers, callbacks (`onPressed`), `initState`, helper actions. | **DO NOT** use inside `build()` to render dynamic UI values (won't rebuild). |
| **`context.watch<T>()`** | Subscribes current widget to ALL state changes of BLoC. | Small isolated leaf widgets requiring full state. | **DO NOT** use at the top level of large build methods (causes full screen rebuilds). |
| **`context.select<T, R>()`** | Subscribes current widget ONLY to specific property `R`. | Leaf widgets needing a single field (e.g. `final count = context.select<CartBloc, int>((b) => b.state.itemCount);`). | Prefer `BlocSelector` for explicit readability in complex trees. |

---

## 6. Comprehensive Code Examples

### 6.1 Feature Page with `BlocConsumer` & Decomposed Widgets

```dart
class FeatureView extends StatelessWidget {
  const FeatureView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeatureBloc, FeatureState>(
      listenWhen: (previous, current) => current is FeatureFailure,
      listener: (context, state) {
        if (state is FeatureFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      buildWhen: (previous, current) => current is! FeatureFailure,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Feature Details'),
            actions: const [_FilterActionButton()],
          ),
          body: switch (state) {
            FeatureInitial() || FeatureLoadInProgress() => const Center(
                child: CircularProgressIndicator(),
              ),
            FeatureLoadSuccess(:final items, :final isRefreshing) => _FeatureContent(
                items: items,
                isRefreshing: isRefreshing,
              ),
            FeatureFailure() => const SizedBox.shrink(),
          },
        );
      },
    );
  }
}
```

### 6.2 Granular Rebuilding with `BlocSelector`

```dart
class _BadgeCountWidget extends StatelessWidget {
  const _BadgeCountWidget();

  @override
  Widget build(BuildContext context) {
    // Rebuilds ONLY when unreadCount changes, ignoring all other state updates
    return BlocSelector<NotificationBloc, NotificationState, int>(
      selector: (state) => state.unreadCount,
      builder: (context, unreadCount) {
        if (unreadCount == 0) return const SizedBox.shrink();
        return Badge(label: Text('$unreadCount'));
      },
    );
  }
}
```

### 6.3 Multi-Bloc Setup for Complex Pages

```dart
class MultiBlocFeaturePage extends StatelessWidget {
  const MultiBlocFeaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<FeatureBloc>()..add(const FeatureStarted())),
        BlocProvider(create: (_) => getIt<FilterCubit>()),
      ],
      child: const MultiBlocListener(
        listeners: [
          BlocListener<FeatureBloc, FeatureState>(listener: _handleFeatureEffects),
          BlocListener<AuthBloc, AuthState>(listener: _handleAuthEffects),
        ],
        child: FeatureBodyWidget(),
      ),
    );
  }

  static void _handleFeatureEffects(BuildContext context, FeatureState state) {
    // Handle feature side-effects
  }

  static void _handleAuthEffects(BuildContext context, AuthState state) {
    // Handle auth redirection side-effects
  }
}
```

---

## 7. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Passing BLoC to BottomSheet/Dialog using `BlocProvider(create: ...)` with existing instance | **CRITICAL** | Use `BlocProvider.value(value: existingBloc)` so it doesn't get closed on pop. |
| Calling `Navigator.push()` or showing dialogs inside `BlocBuilder` | **CRITICAL** | Move side effects to `BlocListener` / `BlocConsumer.listener`. |
| Using `context.read<Bloc>()` inside `build()` to render changing state | **HIGH** | Use `BlocBuilder`, `BlocSelector`, or `context.select`. |
| Wrapping the entire `Scaffold` in a single unoptimized `BlocBuilder` | **HIGH** | Decompose UI and wrap only specific leaf widgets requiring rebuilds. |
| Deeply nested chains of individual `BlocListener` widgets | **MEDIUM** | Use `MultiBlocListener` to flatten the widget tree. |

---

## 8. Verification Checklist

- [ ] New BLoC instances use `BlocProvider(create: (ctx) => getIt<...>())` at the feature root.
- [ ] Existing BLoC instances passed to modals, dialogs, or sub-routes strictly use `BlocProvider.value(value: ...)`.
- [ ] Visual UI layout is inside `BlocBuilder` / `BlocSelector`; side effects are inside `BlocListener`.
- [ ] `buildWhen` and `listenWhen` are utilized to prevent unnecessary rebuilds/triggers.
- [ ] Widgets dispatch events via `context.read<Bloc>().add(Event())`.
- [ ] Sub-widgets are extracted into separate files within `widgets/` (under 150 lines each).
