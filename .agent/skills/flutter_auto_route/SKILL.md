---
name: flutter-auto-route
description: Implements type-safe navigation and deep links with auto_route using a single AppRouter configuration, generated PageRouteInfo classes, nested routes for shells and tabs, reevaluateListenable for dynamic guards, deepLinkBuilder for links, and clear scope targeting. Use when adding routes, guards, nested stacks, tab dashboards, push-replace-pop semantics, or handling deep linking.
---

# Flutter AutoRoute Navigation Expert Skill

## When to Apply

Use this skill whenever setting up app navigation, defining screen routes, implementing route guards (authentication/authorization checks), creating bottom navigation bars with nested stacks, passing typed parameters between screens, configuring deep links, or handling page transitions.

---

## Naming Conventions

| Artifact            | Standard                             | Example                                          |
| :------------------ | :----------------------------------- | :----------------------------------------------- |
| **Router File**     | `app_router.dart`                    | `lib/presentation/navigation/app_router.dart`    |
| **Generated File**  | `app_router.gr.dart`                 | `lib/presentation/navigation/app_router.gr.dart` |
| **Screen Widget**   | `[Feature]Page` or `[Feature]Screen` | `UserProfilePage`                       |
| **Generated Route** | `[Feature]Route`                     | `UserProfileRoute`                      |
| **Guard Class**     | `[Feature]Guard`                     | `AuthGuard`, `PinGuard`                          |

---

## Core Architectural Rules & Standards

1. **Strict Presentation Boundary:**
   - **CRITICAL:** `BuildContext`, `context.router`, or `AutoRouter` APIs MUST stay strictly within Presentation widgets, `BlocListener` callbacks, or specialized UI Navigation Adapters.
   - Domain and Data layers MUST NEVER import `auto_route` or manage navigation states directly.

2. **Composition Root Single Instance:**
   - Instantiate `AppRouter` ONCE at the application composition root (or inject via DI).
   - Pass `MaterialApp.router(routerConfig: appRouter.config())` at the top level — NEVER instantiate `AppRouter` inside a widget's `build()` method.

3. **Type-Safe Route Calls & Lightweight Arguments:**
   - NEVER use raw string navigation (`pushNamed('/details')`).
   - Pass data strictly using generated `*Route` constructors.
   - **Data Transfer Policy:** Pass primitive IDs or light Value Objects in route arguments (e.g. `UserRoute(id: 123)`) instead of large mutable entity trees. Let the target screen load its own state.

4. **Dynamic Guard Re-evaluation:**
   - Use `AutoRouteGuard` for route access protection.
   - Provide a `reevaluateListenable` to `appRouter.config()` so guards automatically re-run when global application states flip (e.g., user logout).

5. **Targeting the Correct Router Scope:**
   - Always target the correct router scope. Use `context.router` for current scope navigation or explicit parent lookups (`context.router.root` / `AutoTabsRouter.of(context)`) to prevent unintended root stack pops when operating within nested tabs/shells.

---

## 1. Single Root Router Setup with Re-evaluation & Deep Links

Configure `@AutoRouterConfig` and handle deep links centrally.

```dart
import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/presentation/navigation/app_router.gr.dart';
import 'package:my_app/presentation/navigation/guards/auth_guard.dart';

@singleton
@AutoRouterConfig(replaceInRouteName: 'Page|Screen,Route')
class AppRouter extends RootStackRouter {
  final AuthGuard _authGuard;

  AppRouter(this._authGuard);

  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
        // Public Flow
        AutoRoute(
          page: LoginRoute.page,
          path: '/login',
        ),

        // Protected Main Shell
        AutoRoute(
          page: MainShellRoute.page,
          path: '/',
          initial: true,
          guards: [_authGuard],
          children: [
            AutoRoute(page: HomeRoute.page, path: 'home', initial: true),
            AutoRoute(page: ProfileRoute.page, path: 'profile'),
            AutoRoute(page: SettingsRoute.page, path: 'settings'),
          ],
        ),

        // Parameterized Route (Minimal ID passing)
        CustomRoute(
          page: UserDetailsRoute.page,
          path: '/user/:id',
          transitionsBuilder: TransitionsBuilders.slideLeft,
          durationInMilliseconds: 300,
        ),

        // Wildcard 404 Fallback (Must be last)
        AutoRoute(page: NotFoundRoute.page, path: '*'),
      ];
}

```

### Application Root Binding (`main.dart`)

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();
    final authStateNotifier = getIt<AuthStateNotifier>();

    return MaterialApp.router(
      routerConfig: appRouter.config(
        // Re-evaluate guards automatically on auth state change
        reevaluateListenable: authStateNotifier,
        deepLinkBuilder: (deepLink) {
          if (deepLink.path.startsWith('/protected') && !authStateNotifier.isAuthenticated) {
            return DeepLink.single(const LoginRoute());
          }
          return deepLink;
        },
      ),
    );
  }
}

```

---

## 2. Screen Page Definition & Minimal Parameter Passing

Annotate destination screens with `@RoutePage()` and accept lightweight parameters (e.g. `id`).

```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class UserDetailsPage extends StatelessWidget {
  final String id; // Primitive ID preference over heavy entity model

  const UserDetailsPage({
    super.key,
    @pathParam required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User ID: $id')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.router.maybePop(),
          child: const Text('Back'),
        ),
      ),
    );
  }
}

```

---

## 3. Dynamic `AutoRouteGuard` Implementation

Implement thread-safe access control using `AutoRouteGuard`.

```dart
import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/domain/repositories/auth_repository.dart';
import 'package:my_app/presentation/navigation/app_router.gr.dart';

@singleton
class AuthGuard extends AutoRouteGuard {
  final AuthRepository _authRepository;

  AuthGuard(this._authRepository);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final isAuthenticated = await _authRepository.isAuthenticated();

    if (isAuthenticated) {
      resolver.next(true); // Proceed to requested route
    } else {
      // Redirect to login and resume stack upon successful authorization
      router.push(
        LoginRoute(
          onLoginSuccess: () {
            resolver.next(true);
          },
        ),
      );
    }
  }
}

```

---

## 4. Declarative Nested Tab Navigation (`AutoTabsRouter`)

Use `AutoTabsRouter` to preserve tab state and handle correct child scope navigation.

```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:my_app/presentation/navigation/app_router.gr.dart';

@RoutePage()
class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        HomeRoute(),
        ProfileRoute(),
        SettingsRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: tabsRouter.activeIndex,
            onTap: (index) {
              if (tabsRouter.activeIndex == index) {
                // Pop nested stack to root if tab re-selected
                tabsRouter.stackRouterOfIndex(index)?.popUntilRoot();
              } else {
                tabsRouter.setActiveIndex(index);
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
            ],
          ),
        );
      },
    );
  }
}

```

---

## 5. UI-Layer BLoC Navigation Handling

Navigation must be executed in the UI layer using `BlocListener`.

```dart
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listenWhen: (previous, current) => previous != current,
      listener: (context, state) {
        switch (state) {
          case LoginSuccess():
            context.router.replace(const HomeRoute());
          case LoginFailure(:final message):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          default:
            break;
        }
      },
      child: const Scaffold(
        body: LoginForm(),
      ),
    );
  }
}

```

---

## Anti-Patterns (Strictly Prohibited)

| Anti-Pattern                                                 | Severity     | Corrective Action                                           |
| ------------------------------------------------------------ | ------------ | ----------------------------------------------------------- |
| Instantiating `AppRouter` inside a widget's `build()` method | **CRITICAL** | Instantiate `AppRouter` once at composition root or via DI. |

|
| Importing `auto_route` inside Domain or Data layers | **CRITICAL** | Restrict navigation strictly to Presentation widgets or UI listeners.

|
| Hand-editing generated `app_router.gr.dart` files | **CRITICAL** | Re-run `build_runner` after modifying routes or annotations.

|
| Using string-based paths (`pushNamed('/user/123')`) for internal navigation | **HIGH** | Use generated `*Route` objects (`push(UserDetailsRoute(id: '123'))`).

|
| Passing heavy mutable domain entities across route boundaries | **HIGH** | Pass primitive IDs or lightweight Value Objects.

|
| Pushing to Root Router when targeting a nested Child StackRouter | **MEDIUM** | Use context-appropriate router scope (`tabsRouter.stackRouterOfIndex(i)`).

|

---

## Agent Verification Checklist

When reviewing navigation setup:

1. **Single Router Instance:** `AppRouter` is created once at root and passed to `MaterialApp.router`.

2. **Layer Isolation:** Domain/Data layers do not depend on `auto_route`.

3. **Type-Safe Calls:** Route changes use generated `*Route` classes.

4. **Light Parameters:** Routes pass IDs/strings instead of mutable entities.

5. **Re-evaluate Listenable:** Session switches trigger guard re-evaluation.

6. **CodeGen Executed:** `build_runner` generates clean `app_router.gr.dart`.
