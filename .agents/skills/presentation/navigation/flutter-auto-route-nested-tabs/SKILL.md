---
name: flutter-auto-route-nested-tabs
description: Best practices for nested navigation, tab bars, shells, and multi-stack routers with AutoRoute. Use when implementing bottom navigation bars, tabs routers (AutoTabsRouter, AutoTabsScaffold), preserving tab history, popping nested stacks to root on re-tap, or scoping child StackRouters.
---

# Flutter AutoRoute Nested Tabs & Shells Guide

## 1. Overview & When to Apply

Use this skill whenever:
- Implementing persistent bottom navigation bars or drawer/rail shell layouts.
- Preserving scroll position and state across tab switches using `AutoTabsRouter`.
- Handling double-tap on an active tab icon to pop the nested stack to its root (`popUntilRoot`).
- Scoping navigation between a nested tab's `StackRouter` and the global `RootStackRouter`.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [flutter-auto-route-hub](../flutter-auto-route-hub/SKILL.md) | Domain architecture, rules, and routing. |
| **Core Routing** | [flutter-auto-route-core](../flutter-auto-route-core/SKILL.md) | Base routes, page definitions, and parameter passing. |
| **Material 3 UI** | [flutter-ui-material](../../ui/flutter-ui-material/SKILL.md) | Material 3 `NavigationBar` styling. |

---

## 3. Declarative Nested Tab Navigation (`AutoTabsRouter`)

`AutoTabsRouter` creates an indexed stack of child routes, keeping the state of each tab alive while providing full independent stack navigation inside each tab:

```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/presentation/navigation/app_router.gr.dart';

@RoutePage()
class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        HomeTabRoute(),
        ExploreTabRoute(),
        ProfileTabRoute(),
      ],
      transitionBuilder: (context, child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return Scaffold(
          body: child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: tabsRouter.activeIndex,
            onDestinationSelected: (index) {
              if (tabsRouter.activeIndex == index) {
                // Pop nested tab stack to root if active tab is tapped again
                tabsRouter.stackRouterOfIndex(index)?.popUntilRoot();
              } else {
                tabsRouter.setActiveIndex(index);
              }
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore),
                label: 'Explore',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
```

---

## 4. Router Scoping: Nested Stack vs Root Router

When navigating from within a tab screen, choosing the correct router scope determines whether bottom navigation remains visible:

```text
┌────────────────────────────────────────────────────────┐
│                   RootStackRouter                      │
│  ├── /login                                            │
│  ├── /main-shell (AutoTabsRouter)                      │
│  │   ├── Tab 1: HomeStackRouter (keeps bottom bar)     │
│  │   ├── Tab 2: ExploreStackRouter                     │
│  │   └── Tab 3: ProfileStackRouter                     │
│  └── /fullscreen-modal (covers bottom bar)             │
└────────────────────────────────────────────────────────┘
```

### 4.1 Navigating Inside Tab (Bottom Bar Visible)
```dart
// Pushes route inside the current tab's nested stack
context.router.push(const SubDetailsRoute());
```

### 4.2 Navigating to Fullscreen (Bottom Bar Hidden)
```dart
// Pushes route onto root stack, overlaying the entire shell and bottom bar
context.router.root.push(const FullscreenPlayerRoute());
```

---

## 5. Shell Routes in `app_router.dart`

```dart
@override
List<AutoRoute> get routes => [
  AutoRoute(
    page: MainShellRoute.page,
    path: '/',
    children: [
      AutoRoute(
        page: HomeTabRoute.page,
        path: 'home',
        children: [
          AutoRoute(page: HomePage.page, path: '', initial: true),
          AutoRoute(page: ItemDetailsPage.page, path: 'details/:id'),
        ],
      ),
      AutoRoute(page: ExplorePage.page, path: 'explore'),
      AutoRoute(page: ProfilePage.page, path: 'profile'),
    ],
  ),
  // Fullscreen route covering shell
  AutoRoute(page: FullscreenPlayerPage.page, path: '/player'),
];
```

---

## 6. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Popping root navigator when user taps active tab | **HIGH** | Target nested stack: `tabsRouter.stackRouterOfIndex(i)?.popUntilRoot()`. |
| Pushing fullscreen pages into a tab stack | **MEDIUM** | Use `context.router.root.push()` when the page must cover the bottom bar. |
| Managing tab index manually with `setState` | **HIGH** | Use `AutoTabsRouter.of(context)` and `tabsRouter.setActiveIndex(i)`. |

---

## 7. Verification Checklist

- [ ] `AutoTabsRouter` declares child tab routes in `routes` list.
- [ ] Active tab re-tap triggers `tabsRouter.stackRouterOfIndex(index)?.popUntilRoot()`.
- [ ] Shell children are properly configured with empty initial path (`path: ''`).
- [ ] Fullscreen views that should hide bottom navigation are pushed to `context.router.root`.
