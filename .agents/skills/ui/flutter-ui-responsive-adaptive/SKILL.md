---
name: flutter-ui-responsive-adaptive
description: Implements 3-tier responsive breakpoints (Mobile <600, Tablet 600-1024, Desktop/Web >=1024), adaptive navigation shells, efficient space measurement (MediaQuery.sizeOf, LayoutBuilder), and Desktop/Web input ergonomics (hover states, mouse cursors, keyboard shortcuts, explicit scrollbars). Use when building multi-platform adaptive layouts or resolving responsive bugs.
---

# Flutter Responsive & Adaptive Multi-Platform Layout Guide

## 1. Overview & When to Apply

Use this skill whenever:
- Designing or implementing layouts that must adapt across Mobile, Tablet, Desktop, and Web.
- Measuring layout space efficiently using `MediaQuery.sizeOf(context)` or `LayoutBuilder`.
- Building adaptive navigation shells (switching between `NavigationBar`, `NavigationRail`, and `NavigationDrawer` / Sidebar).
- Handling Desktop & Web input ergonomics (mouse hover, cursor states, scrollbars, keyboard focus traversal).
- Enforcing content width constraints (`ConstrainedBox(maxWidth: 1200)`) on wide 4K screens.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [flutter-ui-hub](../flutter-ui-hub/SKILL.md) | Presentation rules and UI routing. |
| **Material 3** | [flutter-ui-material](../flutter-ui-material/SKILL.md) | Navigation components & tokens. |
| **Cupertino** | [flutter-ui-cupertino](../flutter-ui-cupertino/SKILL.md) | iOS-specific navigation and modal paradigms. |
| **Performance** | [flutter-ui-performance](../flutter-ui-performance/SKILL.md) | Avoiding unnecessary rebuilds during window resizing. |

---

## 3. Responsive Breakpoint Standards

| Platform Tier | Width Range (`dp`) | Layout Paradigm & Navigation Structure |
| :--- | :--- | :--- |
| **Mobile** | `< 600` | Single column layout, modal bottom sheets, bottom `NavigationBar`. |
| **Tablet** | `600 – 1024` | 2-column split view / grid, dialogs, left `NavigationRail`. |
| **Desktop / Web** | `>= 1024` | Multi-pane persistent views, context menus, persistent sidebar / `NavigationDrawer`. |

### Measuring Space: Rule of Thumb
- **Window Dimensions:** ALWAYS use `MediaQuery.sizeOf(context)` (Flutter 3.10+). Never use `MediaQuery.of(context)` as it causes rebuilds on unrelated system changes (e.g. keyboard insets, brightness).
- **Parent Constraints:** ALWAYS use `LayoutBuilder` to obtain parent constraints (`constraints.maxWidth`).

---

## 4. Adaptive Navigation Shell Pattern

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

    // 1. Mobile Layout (< 600dp)
    if (width < 600) {
      return Scaffold(
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      );
    }

    // 2. Tablet Layout (600 - 1024dp)
    if (width < 1024) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.selected,
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text('Home')),
                NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('Settings')),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    // 3. Desktop / Web Layout (>= 1024dp)
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 260,
            child: PersistentAppDrawer(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: body,
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

## 5. Desktop & Web Ergonomics

### 5.1 Hover & Mouse Cursors
```dart
MouseRegion(
  cursor: SystemMouseCursors.click,
  child: InkWell(
    onTap: () => onAction(),
    hoverColor: context.colorScheme.primary.withValues(alpha: 0.08),
    borderRadius: BorderRadius.circular(8),
    child: child,
  ),
);
```

### 5.2 Explicit Scrollbar Binding
On Desktop and Web, always bind visible scrollbars to an explicit `ScrollController`:
```dart
class DesktopScrollableList extends StatefulWidget {
  const DesktopScrollableList({super.key});

  @override
  State<DesktopScrollableList> createState() => _DesktopScrollableListState();
}

class _DesktopScrollableListState extends State<DesktopScrollableList> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true, // Always visible on desktop
      child: ListView.builder(
        controller: _scrollController,
        itemCount: 100,
        itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
      ),
    );
  }
}
```

---

## 6. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Using `MediaQuery.of(context)` for width | **HIGH** | Replace with `MediaQuery.sizeOf(context)`. |
| Unbounded full-width forms on wide Desktop screens | **HIGH** | Wrap desktop content in `ConstrainedBox(maxWidth: 1200)`. |
| Missing `ScrollController` on desktop `Scrollbar` | **HIGH** | Provide a shared `ScrollController` to both `Scrollbar` and scrollable view. |
| Checking `Platform.isAndroid` for layout | **MEDIUM** | Use width breakpoints (`width < 600`) instead of OS sniffing. |

---

## 7. Verification Checklist

- [ ] `MediaQuery.sizeOf(context)` is used instead of `MediaQuery.of(context)`.
- [ ] Layout behaves correctly across Mobile (`<600`), Tablet (`600-1024`), and Desktop (`>=1024`).
- [ ] Wide screen views (>1200dp) contain max-width bounds (`ConstrainedBox`).
- [ ] Clickable desktop elements have `MouseRegion(cursor: SystemMouseCursors.click)` and hover states.
- [ ] Desktop scrollbars are explicitly bound to their `ScrollController`.
