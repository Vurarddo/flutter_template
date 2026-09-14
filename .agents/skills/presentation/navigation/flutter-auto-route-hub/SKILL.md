---
name: flutter-auto-route-hub
description: Primary coordinator and architecture guide for AutoRoute navigation in Flutter. Use when designing, organizing, refactoring, or auditing application routing, page definitions, route guards, nested tab navigation, and deep linking. Serves as the central entry point and routes to specialized navigation sub-skills.
---

# Flutter AutoRoute Navigation Hub

## 1. Overview & Architectural Foundations

This skill serves as the central root coordinator for all application routing and navigation using `auto_route`. It enforces strict Clean Architecture presentation boundaries, type safety, single-instance router configuration, and routes agents to specialized navigation sub-skills.

### Core Navigation Laws (per `AGENTS.md`):

1. **Strict Presentation Boundary:**
   - `BuildContext`, `context.router`, `AutoRouter`, and navigation calls MUST stay strictly within Presentation widgets, `BlocListener` callbacks, or specialized UI Navigation Adapters.
   - Domain and Data layers MUST NEVER import `auto_route` or manage navigation states.
2. **Composition Root Single Instance:**
   - Instantiate `AppRouter` ONCE at the application composition root or inject via `injectable`/`get_it`.
   - Pass `MaterialApp.router(routerConfig: appRouter.config(...))` at the top level — NEVER instantiate `AppRouter` inside a widget's `build()` method.
3. **Type-Safe Route Calls:**
   - NEVER use raw string navigation (`pushNamed('/details')`).
   - Pass data strictly using generated `*Route` constructors (`context.router.push(UserDetailsRoute(id: '123'))`).
4. **Lightweight Route Arguments:**
   - Pass primitive IDs or lightweight Value Objects in route arguments. Never pass heavy, mutable entity trees across route boundaries; let destination screens fetch their own state.
5. **Code Generation:**
   - After updating route annotations (`@RoutePage`, `@AutoRouterConfig`), re-generate routing files using `flutter pub run build_runner build --delete-conflicting-outputs`.

---

## 2. Navigation Skill Tree & Routing Matrix

Use this matrix to navigate to the specialized sub-skill matching your specific navigation task:

| Sub-Domain | Target Sub-Skill | When to Consult |
| :--- | :--- | :--- |
| **Core Routes & Parameters** | [flutter-auto-route-core](../flutter-auto-route-core/SKILL.md) | `@AutoRouterConfig`, `@RoutePage`, `push`/`replace`/`pop`/`maybePop`, `@pathParam`, `@queryParam`, transition animations, and `AppRouter` configuration. |
| **Nested Tabs & Shells** | [flutter-auto-route-nested-tabs](../flutter-auto-route-nested-tabs/SKILL.md) | `AutoTabsRouter`, `AutoTabsScaffold`, bottom navigation bars, preserving tab states, popping nested stacks to root, and nested `StackRouter` scoping. |
| **Guards & Deep Linking** | [flutter-auto-route-guards](../flutter-auto-route-guards/SKILL.md) | `AutoRouteGuard`, `NavigationResolver`, dynamic re-evaluation with `reevaluateListenable`, `deepLinkBuilder`, and 404 wildcard fallback routes. |
| **BLoC UI Integration** | [flutter-bloc-widgets](../../state-management/flutter-bloc-widgets/SKILL.md) | Triggering route navigation from `BlocListener` / `BlocConsumer` side-effect handlers. |
| **UI Presentation Hub** | [flutter-ui-hub](../../ui/flutter-ui-hub/SKILL.md) | Main UI design system and screen layout decomposition. |

---

## 3. Directory & File Organization Standard

Structure navigation files strictly inside `lib/presentation/navigation/`:

```text
lib/presentation/
├── navigation/
│   ├── app_router.dart         # Main @AutoRouterConfig class (<200 lines)
│   ├── app_router.gr.dart      # Generated code (Do NOT edit manually)
│   └── guards/                 # AutoRouteGuard implementations
│       ├── auth_guard.dart
│       └── onboarding_guard.dart
└── pages/
    └── <feature>/
        ├── <feature>_page.dart # Annotated with @RoutePage()
        └── widgets/
```

---

## 4. Master Navigation Verification Checklist

Before completing any navigation task:
- [ ] `AppRouter` is a singleton injected via DI or created once at the application root (`MaterialApp.router`).
- [ ] Screens are annotated with `@RoutePage()` and use `*Route` generated classes for navigation.
- [ ] Route parameters use primitive IDs rather than full mutable entity objects.
- [ ] Domain and Data layers contain zero imports of `auto_route` or UI packages.
- [ ] Nested tab routers properly isolate child stack navigation from root stack navigation.
- [ ] Dynamic guards configure `reevaluateListenable` for automatic re-checks on session changes.
- [ ] Code generation (`build_runner`) was executed and `app_router.gr.dart` is in sync.
