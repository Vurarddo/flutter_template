---
name: flutter-ui-performance
description: Expert UI skill enforcing atomic widget composition, 3-tier responsive/adaptive layout strategy for Mobile/Tablet/Desktop/Web, Sliver-first scrolling architecture, layout bug resolution, 60/120 FPS animation performance, hover/keyboard/scrollbar desktop paradigms, and zero helper build methods. Use when creating UI pages/widgets, solving layout errors, handling responsive breakpoints, building animations, or optimizing scroll performance.
---

# Flutter UI, Layouts, Slivers & Desktop/Web Performance Expert Skill

## When to Apply

Use this skill for any work inside `lib/presentation/`: constructing pages and widgets, resolving layout bugs (`RenderFlex overflow`, `Unbounded height`), implementing multi-platform responsive breakpoints (Mobile, Tablet, Desktop, Web), handling desktop-specific UX paradigms (hover, keyboard shortcuts, explicit scrollbars), building animations, or optimizing scroll frame rates.

---

## 1. Widget Tree Architecture & Composition Rules

1. **Atomic Widget Decomposition:**
   - Maximum lines per UI file: **150–200 lines**.
   - **STRICTLY PROHIBITED:** Helper methods returning widgets (e.g., `Widget _buildHeader()`). They break Flutter's element tree diffing algorithm, forcing complete subtree rebuilds.
   - **Always extract subtrees into standalone `StatelessWidget` or `StatefulWidget` classes** inside `widgets/` or `parts/` directories.

2. **`const` Constructors Optimization:**
   - Mark ALL static widget calls, padding, and text styles with `const` to allow Flutter to reuse element instances during rebuilds.

3. **Design Tokens & Theme Extensions:**
   - **NO hardcoded hex colors (`Color(0xFF...)`) or inline `TextStyle`** in feature widgets.
   - Colors: `Theme.of(context).colorScheme` or `context.customColors` (`ThemeExtension`).
   - Typography: `Theme.of(context).textTheme`.

4. **UI Kit Decoupling:**
   - Reusable stateless UI components must reside in `lib/presentation/ui_kit/`.
   - UI Kit components must be 100% pure, receiving primitive data or UI-models, with zero BLoC/Domain dependencies.

---

## 2. Layout Negotiating & Responsive Strategy (Mobile, Tablet, Desktop, Web)

### Core Layout Law

> **Constraints go down. Sizes go up. Parent sets position.**

### Measuring Available Space Correctly

- **Window Space:** Use `MediaQuery.sizeOf(context)` or `context.mediaQuery.sizeOf()` (Flutter 3.10+) to measure total screen dimensions. **DO NOT** use `MediaQuery.of(context)` or `context.mediaQuery` as it triggers unnecessary rebuilds on unrelated system changes.
- **Parent Constraints:** Use `LayoutBuilder` to obtain parent limits (`constraints.maxWidth` / `constraints.maxHeight`).
- **No Platform Hardware Sniffing:** Do NOT check `Platform.isAndroid` or `kIsWeb` to dictate layout decisions. Always rely on width-based breakpoint logic and capability detection (`PointerDeviceKind`).

### Multi-Platform Breakpoint Standard

| Platform Tier     | Width Range (`dp`) | Layout Paradigm & Navigation Structure                                               |
| :---------------- | :----------------- | :----------------------------------------------------------------------------------- |
| **Mobile**        | `< 600`            | Single column layout, Modal Bottom Sheets, `NavigationBar` at bottom.                |
| **Tablet**        | `600 – 1024`       | 2-column grid/split view, Dialogs, `NavigationRail` on left side.                    |
| **Desktop / Web** | `>= 1024`          | Multi-pane persistent views, Context Menus, Persistent Sidebar / `NavigationDrawer`. |

### Desktop & Web Content Constraints

- **Wide Screen Containment:** Wide screens (>1200dp) MUST NOT allow reading text or forms to stretch edge-to-edge. Wrap primary content in a centered container:
  ```dart
  Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1200),
      child: child,
    ),
  )
  ```

### Adaptive Navigation Shell Pattern

Automatically adapt the navigation scaffolding based on available screen width:

```dart
class AdaptiveNavigationShell extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;

  const AdaptiveNavigationShell({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    // Mobile Layout
    if (width < 600) {
      return Scaffold(
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: const [...],
        ),
      );
    }

    // Tablet Layout
    if (width < 1024) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: const [...],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    // Desktop & Large Web Layout
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 250,
            child: PersistentSidebar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}

```

---

## 3. Desktop & Web Input Interactions Strategy

Interactive components on Desktop and Web must support hardware peripherals (mouse, keyboard, scroll wheels).

1. **Hover & Cursor States:**

- Every clickable non-button element on Desktop/Web MUST provide visual hover feedback and explicit cursor pointers.

```dart
MouseRegion(
  cursor: SystemMouseCursors.click,
  child: InkWell(
    onTap: onTap,
    hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
    child: child,
  ),
)

```

2. **Explicit Scrollbars:**

- On Desktop and Web, long scrollable views MUST feature a visible, draggable scrollbar tied to a dedicated `ScrollController`.

```dart
final scrollController = ScrollController();

Scrollbar(
  controller: scrollController,
  thumbVisibility: true, // Always show on desktop
  child: ListView.builder(
    controller: scrollController,
    itemCount: 100,
    itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
  ),
)

```

3. **Keyboard Shortcuts & Focus Navigation:**

- Forms and primary dialogs on Desktop/Web MUST support `FocusTraversalGroup` for key navigation (Tab/Shift+Tab) and `Shortcuts` / `Actions` for core actions (Enter to submit, Escape to close).

---

## 4. Layout Error Resolution Matrix

| Layout Error                                       | Cause                                                                         | Corrective Pattern                                                                                                     |
| -------------------------------------------------- | ----------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| **`RenderFlex overflowed by X pixels`**            | Content exceeds `Row`/`Column` spatial limits.                                | Wrap overflowing children in `Expanded` or `Flexible`. For text, set `overflow: TextOverflow.ellipsis` and `maxLines`. |
| **`Vertical viewport was given unbounded height`** | Scrollable (`ListView`/`GridView`) inside an unconstrained parent (`Column`). | **Preferred:** Convert outer structure to `CustomScrollView` + Slivers.<br>                                            |

<br>**Alternative:** Wrap list in `Expanded` or set `shrinkWrap: true` + `physics: NeverScrollableScrollPhysics()`. |
| **`Incorrect use of ParentData widget`** | `Expanded`, `Flexible`, or `Positioned` used under unsupported parents. | Ensure `Expanded`/`Flexible` are DIRECT children of `Row`/`Column`/`Flex`. Ensure `Positioned` is a DIRECT child of `Stack`. |
| **`InputDecorator... unbounded width`** | `TextField` directly inside horizontal `Flex` / `Row`. | Wrap `TextField` in `Expanded`, `Flexible`, or a fixed-width `SizedBox`. |

---

## 5. Sliver-First Architecture

For complex scrollable screens containing headers, lists, grids, or collapsible bars, ALWAYS prefer **`CustomScrollView`** with Slivers over nested `ListView`s.

```dart
class FeaturePage extends StatelessWidget {
  const FeaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(
            title: Text('Dashboard'),
          ),
          const SliverToBoxAdapter(
            child: FeatureHeaderSection(),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => FeatureListItem(index: index),
                childCount: 100, // Lazy building
              ),
            ),
          ),
        ],
      ),
    );
  }
}

```

---

## 6. High-Performance Animation Strategy (60/120 FPS)

### Animation Tool Decision Ladder

1. **Implicit Animations (Simplest):**

- Use `AnimatedContainer`, `AnimatedOpacity`, `AnimatedAlign`, `AnimatedCrossFade` for single-property state transitions.

2. **One-Shot / Retriggered Animations:**

- Use `TweenAnimationBuilder<T>` without manually managing an `AnimationController` lifecycle.

3. **Explicit Choreography (Complex):**

- Use `AnimationController` + `CurvedAnimation` + `AnimatedBuilder` ONLY for repeating, reverse, staggered, or drag-driven animations.

### Animation Execution Standard

- **Lifecycle Safety:** Initialize `AnimationController` in `initState` (or inject via state). ALWAYS call `controller.dispose()` in `dispose()`. **NEVER instantiate controllers inside `build()**`.
- **Isolate Subtree Rebuilds (The `child` parameter):**
  Pass heavy static subtrees into the `child` parameter of `AnimatedBuilder` / `ListenableBuilder` so Flutter transforms the widget on the raster layer without rebuilding its code every frame.

```dart
AnimatedBuilder(
  animation: _controller,
  child: const HeavyStaticSubtree(), // Built ONCE
  builder: (context, child) {
    return Transform.rotate(
      angle: _controller.value * 2.0 * math.pi,
      child: child, // Reused across animation ticks
    );
  },
);

```

- **RepaintBoundary:** Wrap frequently repainting regions (e.g., custom painters, heavy animations) in a `RepaintBoundary` to isolate pixel rasterization from the main layer tree.
- **Accessibility:** Respect system animation preferences:

```dart
if (MediaQuery.disableAnimationsOf(context)) {
  // Jump directly to end state without animation
}

```

---

## 7. UI/UX Standard States & Off-Main-Thread Processing

Every feature screen MUST explicitly handle three states:

- **Loading:** Skeleton loader or `CircularProgressIndicator.adaptive()`.
- **Empty:** Informative visual, clear copy, and primary CTA button.
- **Error:** User-friendly message and a Retry action button.

**Off-Main-Thread Processing:**

- NEVER execute heavy operations (e.g., JSON parsing, heavy list sorting, cryptographic calculations) directly inside `build()` or BLoC sync methods.
- Offload expensive computations using **`compute()`** or **`Isolate.run()`**.

---

## Anti-Patterns (Strictly Prohibited)

| Anti-Pattern                                                               | Severity     | Corrective Action                                                           |
| -------------------------------------------------------------------------- | ------------ | --------------------------------------------------------------------------- |
| Helper build methods (`Widget _buildRow()`)                                | **CRITICAL** | Convert to `class _RowWidget extends StatelessWidget`.                      |
| Creating `AnimationController` inside `build()`                            | **CRITICAL** | Initialize in `initState` and `dispose()` when widget is unmounted.         |
| Hardcoded colors or text styles                                            | **HIGH**     | Use `Theme.of(context)` tokens or custom `ThemeExtension`.                  |
| Using `MediaQuery.of(context)` or `context.mediaQuery` for layout size     | **HIGH**     | Replace with `MediaQuery.sizeOf(context)` or `context.mediaQuery.sizeOf()`. |
| Allowing text or form content to stretch unbounded across 4K Desktop views | **HIGH**     | Wrap large desktop views in `ConstrainedBox(maxWidth: 1200)`.               |
| Omitting `ScrollController` on Web/Desktop `Scrollbar` widgets             | **HIGH**     | Bind `Scrollbar` explicitly to a `ScrollController` attached to the list.   |
| `SingleChildScrollView` + `Column` for large lists                         | **HIGH**     | Replace with `CustomScrollView` + `SliverList` or `ListView.builder`.       |
| Sync heavy operations blocking the main isolate                            | **HIGH**     | Move execution to `compute()` / `Isolate.run()`.                            |

---

## Agent Execution Checklist

When generating or refactoring UI code:

1. **Zero Helper Builders:** Ensure zero `Widget _buildX()` methods exist in the file.
2. **File Size Limit:** Ensure file length remains under 200 lines.
3. **Responsive Breakpoints:** Confirm the interface adapts across Mobile (`<600`), Tablet (`600–1024`), and Desktop (`>=1024`).
4. **Desktop Constraints & Input:** Verify `ConstrainedBox(maxWidth: ...)` protects ultra-wide layouts, hover states (`MouseRegion`) are active, and scrollbars are explicitly managed.
5. **MediaQuery Efficiency:** Confirm `MediaQuery.sizeOf(context)` or `context.mediaQuery.sizeOf()` is used for size measurements.
6. **Animation Efficiency:** Confirm `AnimationController` instances are properly disposed and `child` references are reused in builders.
7. **Const Completeness:** Confirm `const` is applied to all eligible constructor calls.
