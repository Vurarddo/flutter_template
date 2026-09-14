---
name: infrastructure-services-firebase
description: Standards and patterns for Firebase service integrations in lib/infrastructure/services/firebase/ (or lib/infrastructure/firebase/). Covers modular FirebaseInitializer, CrashlyticsService, FCMNotificationService, RemoteConfigService, and clean architecture boundaries.
---

# Infrastructure Firebase Services Architecture

## 1. Overview & When to Apply

Use this skill whenever:
- Initializing Firebase (`Firebase.initializeApp()`) with flavor/environment options.
- Integrating `FirebaseCrashlytics` for uncaught Flutter errors, native crashes, and custom keys.
- Handling Push Notifications via `FirebaseMessaging` (FCM) background/foreground handlers and APNs tokens.
- Fetching feature flags and remote parameters via `FirebaseRemoteConfig`.
- Isolating Firebase SDK dependencies inside `lib/infrastructure/services/firebase/`.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [infrastructure-hub](../infrastructure-hub/SKILL.md) | Infrastructure architecture and service isolation. |
| **DI Setup** | [infrastructure-di](../infrastructure-di/SKILL.md) | Registering Firebase service wrappers as `@lazySingleton`. |
| **Logging** | [infrastructure-logging](../infrastructure-logging/SKILL.md) | Routing error logs to Crashlytics. |

---

## 3. Directory Standard for Firebase Services

```text
lib/infrastructure/services/firebase/
├── firebase_initializer.dart       # Firebase.initializeApp bootstrapping
├── crashlytics_service.dart        # FlutterError.onError & recordError sink
├── fcm_notification_service.dart   # Push notification stream & background handler
└── remote_config_service.dart      # RemoteConfig feature flags & defaults
```

---

## 4. Standard Implementation Patterns

### 4.1 Firebase Crashlytics Service (`crashlytics_service.dart`)

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CrashlyticsService {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  Future<void> initialize() async {
    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = _crashlytics.recordFlutterFatalError;

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    bool fatal = false,
  }) async {
    if (kDebugMode) return;
    await _crashlytics.recordError(exception, stack, reason: reason, fatal: fatal);
  }

  Future<void> setUserId(String userId) => _crashlytics.setUserIdentifier(userId);
  Future<void> setCustomKey(String key, Object value) => _crashlytics.setCustomKey(key, value);
}
```

---

### 4.2 FCM Push Notification Service (`fcm_notification_service.dart`)

```dart
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background data message without UI
}

@lazySingleton
class FcmNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final StreamController<Map<String, dynamic>> _onNotificationClickController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onNotificationClick =>
      _onNotificationClickController.stream;

  Future<void> initialize() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data.isNotEmpty) {
        _onNotificationClickController.add(message.data);
      }
    });
  }

  Future<String?> getDeviceToken() => _messaging.getToken();
}
```

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Placing Firebase classes inside `infrastructure/utils/` | **HIGH** | Place inside `lib/infrastructure/services/firebase/`. |
| Importing `package:firebase_*` directly inside Domain or Presentation BLoCs | **CRITICAL** | Abstract behind Domain interfaces or consume via infrastructure service wrappers. |
| Recording Crashlytics errors in debug mode polluting dashboard | **MEDIUM** | Guard with `if (kDebugMode) return;`. |

---

## 6. Verification Checklist

- [ ] Firebase initialization handles errors gracefully during offline boot.
- [ ] Crashlytics captures fatal framework and asynchronous zone errors.
- [ ] Push notification payload stream is cleanly exposed without direct UI coupling.
- [ ] All Firebase services are registered in GetIt via `injectable`.
