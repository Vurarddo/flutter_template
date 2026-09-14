---
name: flutter-auto-route-core
description: Core routing configuration, page definitions, parameters, and type-safe navigation with AutoRoute. Use when configuring AppRouter, annotating @RoutePage screens, passing @pathParam or @queryParam arguments, executing push/replace/pop operations, or configuring custom route transitions.
---

# Flutter AutoRoute Core Routing & Parameters Guide

## 1. Overview & When to Apply

Use this skill whenever:
- Setting up or modifying the main `AppRouter` configuration.
- Annotating screen widgets with `@RoutePage()`.
- Passing strongly-typed arguments, `@pathParam`, or `@queryParam` across screens.
- Performing type-safe navigation actions (`push`, `replace`, `pop`, `maybePop`, `navigate`, `popUntil`).
- Configuring custom page transitions (`CustomRoute`, slide, fade).

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [flutter-auto-route-hub](../flutter-auto-route-hub/SKILL.md) | Domain architecture, rules, and routing. |
| **Nested Navigation** | [flutter-auto-route-nested-tabs](../flutter-auto-route-nested-tabs/SKILL.md) | Tabs, shells, and bottom navigation. |
| **Guards** | [flutter-auto-route-guards](../flutter-auto-route-guards/SKILL.md) | Protecting routes and handling deep links. |
| **BLoC Integration** | [flutter-bloc-widgets](../../state-management/flutter-bloc-widgets/SKILL.md) | Dispatching navigation from `BlocListener`. |

---

## 3. Single Root Router Setup (`app_router.dart`)

```dart
import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_template/presentation/navigation/app_router.gr.dart';
import 'package:flutter_template/presentation/navigation/guards/auth_guard.dart';

@singleton
@AutoRouterConfig(replaceInRouteName: 'Page|Screen,Route')
class AppRouter extends RootStackRouter {
  final AuthGuard _authGuard;

  AppRouter(this._authGuard);

  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
        // Public Auth Route
        AutoRoute(
          page: LoginRoute.page,
          path: '/login',
        ),

        // Protected Main Flow
        AutoRoute(
          page: MainShellRoute.page,
          path: '/',
          initial: true,
          guards: [_authGuard],
          children: [
            AutoRoute(page: HomeRoute.page, path: 'home', initial: true),
            AutoRoute(page: ProfileRoute.page, path: 'profile'),
          ],
        ),

        // Parameterized Custom Route with Slide Transition
        CustomRoute(
          page: ItemDetailsRoute.page,
          path: '/item/:id',
          transitionsBuilder: TransitionsBuilders.slideLeft,
          durationInMilliseconds: 300,
        ),

        // 404 Wildcard Fallback (Must always be last)
        AutoRoute(
          page: NotFoundRoute.page,
          path: '*',
        ),
      ];
}
```

---

## 4. Screen Page Definition & Parameter Standards

### 4.1 Annotation & Primitive ID Preference

Always pass lightweight primitive IDs or Value Objects rather than full mutable domain entities:

```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ItemDetailsPage extends StatelessWidget {
  final String id;
  final String? filterTag;

  const ItemDetailsPage({
    super.key,
    @pathParam required this.id,
    @queryParam this.filterTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Item $id')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.router.maybePop(),
          child: const Text('Go Back'),
        ),
      ),
    );
  }
}
```

---

## 5. Type-Safe Navigation Operations Reference

| Operation | Method Call | Behavioral Mechanics |
| :--- | :--- | :--- |
| **Push** | `context.router.push(const ProfileRoute())` | Pushes a new route onto the current stack. |
| **Replace** | `context.router.replace(const HomeRoute())` | Replaces the top route in the stack with a new one. |
| **Pop** | `context.router.pop()` | Pops the top route unconditionally. |
| **Maybe Pop** | `context.router.maybePop()` | Safely attempts to pop if canPop() is true, respecting `PopScope`. |
| **Pop Until** | `context.router.popUntil((route) => route.settings.name == HomeRoute.name)` | Pops routes until matching predicate. |
| **Pop Until Root** | `context.router.popUntilRoot()` | Clears the stack back down to the root route. |
| **Navigate** | `context.router.navigate(const DetailsRoute())` | Navigates to an existing route in history or pushes if new. |

---

## 6. Composition Root Integration (`main.dart`)

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();

    return MaterialApp.router(
      routerConfig: appRouter.config(),
    );
  }
}
```

---

## 7. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Instantiating `AppRouter()` inside a widget `build()` method | **CRITICAL** | Register `AppRouter` as singleton via DI and instantiate once at root. |
| Using untyped string paths (`pushNamed('/details')`) | **HIGH** | Use generated type-safe routes: `push(DetailsRoute(id: ...))`. |
| Passing large mutable domain entities via route parameters | **HIGH** | Pass primitive IDs (`@pathParam String id`) and let the screen load data. |
| Editing generated `app_router.gr.dart` by hand | **CRITICAL** | Re-run `build_runner` code generation instead of manual edits. |

---

## 8. Verification Checklist

- [ ] `AppRouter` is annotated with `@singleton` and `@AutoRouterConfig(replaceInRouteName: 'Page|Screen,Route')`.
- [ ] Every navigated screen is annotated with `@RoutePage()` and has a `const` constructor.
- [ ] Route parameters use `@pathParam` / `@queryParam` with primitive types.
- [ ] Wildcard route (`path: '*'`) is placed as the last element in the routes list.
- [ ] Code generation was run and `app_router.gr.dart` contains up-to-date route definitions.
