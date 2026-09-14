---
name: flutter-auto-route-guards
description: Route protection, authentication guards, dynamic re-evaluation, and deep link handling with AutoRoute. Use when implementing AutoRouteGuard, protecting private routes, redirecting unauthenticated users, configuring reevaluateListenable on auth state changes, or writing custom deepLinkBuilder logic.
---

# Flutter AutoRoute Guards & Deep Linking Guide

## 1. Overview & When to Apply

Use this skill whenever:
- Protecting private routes against unauthenticated or unauthorized access.
- Implementing `AutoRouteGuard` with `NavigationResolver`.
- Automatically re-evaluating route guards when user authentication state changes (`reevaluateListenable`).
- Handling deep links and universal links via `deepLinkBuilder`.
- Configuring 404 fallback routes for unknown URLs.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [flutter-auto-route-hub](../flutter-auto-route-hub/SKILL.md) | Domain architecture, rules, and routing. |
| **Core Routing** | [flutter-auto-route-core](../flutter-auto-route-core/SKILL.md) | Base routes and parameter configuration. |
| **BLoC Widgets** | [flutter-bloc-widgets](../../state-management/flutter-bloc-widgets/SKILL.md) | Auth state listeners and session management. |

---

## 3. `AutoRouteGuard` Implementation

Implement access control with `AutoRouteGuard` by checking repository/state and either proceeding (`resolver.next(true)`) or redirecting to the login flow:

```dart
import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_template/domain/auth/repositories/i_auth_repository.dart';
import 'package:flutter_template/presentation/navigation/app_router.gr.dart';

@singleton
class AuthGuard extends AutoRouteGuard {
  final IAuthRepository _authRepository;

  AuthGuard(this._authRepository);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final isAuthenticated = await _authRepository.isAuthenticated();

    if (isAuthenticated) {
      // User is authenticated, proceed to requested destination
      resolver.next(true);
    } else {
      // User is not authenticated, redirect to Login and resume on success
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

## 4. Dynamic Guard Re-Evaluation (`reevaluateListenable`)

When a user logs out or their token expires, the router should automatically re-evaluate guards without manual navigation calls:

```dart
class AuthStateNotifier extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  void updateAuthStatus(bool status) {
    if (_isAuthenticated != status) {
      _isAuthenticated = status;
      notifyListeners(); // Triggers router guard re-evaluation!
    }
  }
}
```

### Binding in `main.dart`:

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();
    final authNotifier = getIt<AuthStateNotifier>();

    return MaterialApp.router(
      routerConfig: appRouter.config(
        reevaluateListenable: authNotifier,
        deepLinkBuilder: (deepLink) {
          if (deepLink.path.startsWith('/protected') && !authNotifier.isAuthenticated) {
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

## 5. Deep Link Handling Standard

```dart
deepLinkBuilder: (PlatformDeepLink deepLink) {
  // Custom deep link transformation or validation
  final uri = deepLink.uri;

  if (uri.path.startsWith('/invite')) {
    final code = uri.queryParameters['code'];
    if (code != null) {
      return DeepLink.single(AcceptInviteRoute(code: code));
    }
  }

  return deepLink;
}
```

---

## 6. Wildcard 404 Route (`NotFoundPage`)

Every application router MUST define a wildcard fallback route placed at the end of the route list:

```dart
// In app_router.dart:
AutoRoute(
  page: NotFoundRoute.page,
  path: '*',
),
```

---

## 7. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Hardcoding imperative navigation in guard without `resolver.next(true)` | **CRITICAL** | Call `resolver.next(true)` in `onLoginSuccess` callback to resume target flow. |
| Forgetting `reevaluateListenable` on auth state change | **HIGH** | Pass a `ChangeNotifier` to `appRouter.config(reevaluateListenable: ...)` for automatic session sync. |
| Placing wildcard route (`*`) before other routes | **HIGH** | Always place `path: '*'` as the very last element in `routes`. |

---

## 8. Verification Checklist

- [ ] `AuthGuard` is registered as `@singleton` and injected into `AppRouter`.
- [ ] Guard passes `onLoginSuccess` callback to login screen to unblock resolver.
- [ ] `appRouter.config()` provides `reevaluateListenable` for auto re-evaluation on logout.
- [ ] Wildcard 404 route is the last route declared in `app_router.dart`.
