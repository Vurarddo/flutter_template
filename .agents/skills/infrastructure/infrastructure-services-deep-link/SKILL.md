---
name: infrastructure-services-deep-link
description: Standards and patterns for handling Deep Links, App Links, and Universal Links in lib/infrastructure/services/deep_link/. Covers stream subscription, URI parsing, parameter extraction, and bridging to AutoRoute.
---

# Infrastructure Deep Links & Universal Links Service

## 1. Overview & When to Apply

Use this skill whenever:
- Integrating OS deep link listeners (e.g. `app_links` or `uni_links` packages).
- Handling cold-start initial links and incoming background/foreground URI streams.
- Parsing query parameters, path segments, and auth tokens from custom schemes or HTTPS universal links.
- Bridging incoming URIs to `AppRouter` (`auto_route`) without coupling infrastructure to UI widgets.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [infrastructure-hub](../infrastructure-hub/SKILL.md) | Infrastructure architecture and service boundaries. |
| **AutoRoute Core** | [flutter-auto-route-core](../../presentation/navigation/flutter-auto-route-core/SKILL.md) | Deep link URL paths and navigation dispatching. |
| **DI Setup** | [infrastructure-di](../infrastructure-di/SKILL.md) | Registering `DeepLinkService` as `@lazySingleton`. |

---

## 3. Standard Implementation Pattern

```dart
import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  final StreamController<Uri> _linkStreamController = StreamController<Uri>.broadcast();
  StreamSubscription<Uri>? _subscription;

  Stream<Uri> get uriStream => _linkStreamController.stream;

  Future<void> initialize() async {
    // 1. Handle cold-start initial link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _linkStreamController.add(initialUri);
      }
    } catch (_) {
      // Ignore cold start parsing errors
    }

    // 2. Listen to incoming links while app is running
    _subscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _linkStreamController.add(uri);
      },
      onError: (dynamic error) {
        // Log stream error safely
      },
    );
  }

  void dispose() {
    _subscription?.cancel();
    _linkStreamController.close();
  }
}
```

---

## 4. Bridging to AutoRoute Navigation

In `lib/presentation/navigation/` (e.g. in `AppRouter` or top-level listener):

```dart
// Listening to parsed URIs at the presentation boundary
void setupDeepLinkListener(DeepLinkService deepLinkService, AppRouter router) {
  deepLinkService.uriStream.listen((uri) {
    // Let AutoRoute handle matched path or dispatch manual route
    router.navigateNamed(uri.path);
  });
}
```

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Hardcoding `Navigator.push` directly inside the `DeepLinkService` | **CRITICAL** | Expose a pure `Stream<Uri>` and let the presentation layer/router handle navigation. |
| Forgetting to cancel stream subscriptions on service disposal | **HIGH** | Properly cancel `StreamSubscription<Uri>`. |
| Placing deep link handling in `infrastructure/utils/` | **MEDIUM** | Place in `lib/infrastructure/services/deep_link/`. |

---

## 6. Verification Checklist

- [ ] Handles both cold-start initial link and warm background link stream.
- [ ] Decoupled from UI: emits pure `Uri` stream without direct `BuildContext` dependency.
- [ ] Registered as `@lazySingleton` via `injectable`.
