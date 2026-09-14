---
name: flutter-ui-stateless-stateful
description: Comprehensive guide on StatelessWidget vs StatefulWidget selection, element tree diffing optimization, widget lifecycle management (initState, didUpdateWidget, dispose), and separating local UI state from BLoC. Use when decomposing UI trees, managing local controllers/focus, or optimizing widget rebuilds.
---

# Flutter StatelessWidget & StatefulWidget Expert Guide

## 1. Overview & When to Apply

Use this skill whenever:
- Deciding whether to implement a component as `StatelessWidget` or `StatefulWidget`.
- Decomposing large widget trees into modular, fine-grained sub-widgets.
- Managing local ephemeral UI state (e.g. `AnimationController`, `TextEditingController`, `FocusNode`, `ScrollController`, `TabController`).
- Handling widget lifecycle methods (`initState`, `didUpdateWidget`, `didChangeDependencies`, `dispose`).
- Preventing unnecessary element tree churn and optimizing rebuild diffs.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [flutter-ui-hub](../flutter-ui-hub/SKILL.md) | High-level presentation laws and routing. |
| **BLoC Widgets & Scoping** | [flutter-bloc-widgets](../../state-management/flutter-bloc-widgets/SKILL.md) | Integrating BLoC/Cubit with UI widgets without mixing local state. |
| **Performance** | [flutter-ui-performance](../flutter-ui-performance/SKILL.md) | RepaintBoundary and frame rate optimizations. |
| **Theming** | [flutter-ui-material](../flutter-ui-material/SKILL.md) | Accessing design tokens inside build methods. |
| **Previews** | [flutter-ui-kit-preview](../ui-kit/flutter-ui-kit-preview/SKILL.md) | Visual testing of isolated widgets. |

---

## 3. Decision Matrix: StatelessWidget vs StatefulWidget vs BLoC

| State Type | Example | Implementation Choice | Rationale |
| :--- | :--- | :--- | :--- |
| **Pure Presentation** | Card, Badge, User Avatar, Static Header | `StatelessWidget` with `const` constructor | 100% pure, no internal state, maximum element reuse. |
| **Ephemeral UI State** | Active tab index, text selection, hover expand, animation ticker | `StatefulWidget` (local `State<T>`) | Scoped strictly to the widget lifecycle. Disposed with the widget. |
| **Business / Domain State** | Auth status, fetched list of items, shopping cart, form submission | **BLoC / Cubit** via `flutter_bloc` | Global, shared, testable, and domain-driven. |

---

## 4. Element Tree Diffing & Why Helper Methods are Banned

### The Helper Method Flaw:
```dart
// ❌ BAD: Forces complete subtree rebuild and loses element caching!
class BadWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(), // Every time BadWidget rebuilds, this allocates new widgets!
        _buildBody(),
      ],
    );
  }

  Widget _buildHeader() => Container(child: const Text('Header'));
}
```

### The Standalone Widget Solution:
```dart
// ✅ GOOD: Flutter can diff and skip _HeaderWidget if its inputs are unchanged!
class GoodWidget extends StatelessWidget {
  const GoodWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _HeaderWidget(),
        _BodyWidget(),
      ],
    );
  }
}

class _HeaderWidget extends StatelessWidget {
  const _HeaderWidget();

  @override
  Widget build(BuildContext context) {
    return Container(child: const Text('Header'));
  }
}
```

---

## 5. StatefulWidget Lifecycle Best Practices

```dart
class FeatureSearchInput extends StatefulWidget {
  final String initialQuery;
  final ValueChanged<String> onSubmitted;

  const FeatureSearchInput({
    super.key,
    required this.initialQuery,
    required this.onSubmitted,
  });

  @override
  State<FeatureSearchInput> createState() => _FeatureSearchInputState();
}

class _FeatureSearchInputState extends State<FeatureSearchInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    // 1. Initialize controllers & listeners once
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant FeatureSearchInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 2. React to parent property changes
    if (oldWidget.initialQuery != widget.initialQuery &&
        _controller.text != widget.initialQuery) {
      _controller.text = widget.initialQuery;
    }
  }

  @override
  void dispose() {
    // 3. ALWAYS dispose controllers to prevent memory leaks
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        hintText: 'Search...',
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => _controller.clear(),
        ),
      ),
    );
  }
}
```

---

## 6. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Helper builder methods (`Widget _buildX()`) inside classes | **CRITICAL** | Extract to separate `StatelessWidget` classes. |
| Forgetting to call `.dispose()` on `TextEditingController` / `FocusNode` | **CRITICAL** | Call `.dispose()` inside `State.dispose()`. |
| Putting business logic / network calls inside `State.initState()` | **CRITICAL** | Dispatch a BLoC event (`context.read<Bloc>().add(...)`) instead. |
| Storing BLoC-manageable data in local `setState` | **HIGH** | Move shared or persistent state to BLoC/Cubit. |
| Missing `const` on Stateless subtrees | **MEDIUM** | Add `const` to all static constructor calls. |

---

## 7. Verification Checklist

- [ ] All UI helper methods are converted into standalone `StatelessWidget` classes.
- [ ] Every `StatefulWidget` properly disposes of its controllers and focus nodes in `dispose()`.
- [ ] No direct API/Repository calls exist within widget classes.
- [ ] Property changes from parent widgets are handled in `didUpdateWidget` if necessary.
- [ ] File line count remains strictly within 150–200 lines.
