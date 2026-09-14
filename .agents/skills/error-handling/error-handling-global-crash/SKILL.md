---
name: error-handling-global-crash
description: Standards and patterns for global uncaught exception handling, crash reporting, and observability in main.dart. Covers runZonedGuarded, FlutterError.onError, PlatformDispatcher.instance.onError, BlocObserver error logging, and Firebase Crashlytics / Sentry integration.
---

# Global Crash Reporting & Uncaught Error Monitoring

## 1. Overview & When to Apply

Use this skill whenever:
- Configuring root application error guards in `lib/main.dart`.
- Setting up framework-level rendering error catchers (`FlutterError.onError`).
- Capturing uncaught asynchronous and platform dispatcher errors (`PlatformDispatcher.instance.onError`).
- Forwarding BLoC errors from `BlocObserver.onError` to Crashlytics / Sentry.
- Ensuring zero crashes go untracked in production while maintaining smooth debug experiences.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [error-handling-hub](../error-handling-hub/SKILL.md) | End-to-end error handling architecture. |
| **Firebase Services** | [infrastructure-services-firebase](../../infrastructure/infrastructure-services-firebase/SKILL.md) | Firebase Crashlytics initialization and logging. |
| **Logging** | [infrastructure-logging](../../infrastructure/infrastructure-logging/SKILL.md) | Structured logging with PII sanitization via `AppLogger`. |

---

## 3. Production `main.dart` Root Configuration

```dart
// lib/main.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_template/application.dart';
import 'package:flutter_template/infrastructure/di/injection.dart';
import 'package:flutter_template/infrastructure/logging/app_logger.dart';
import 'package:flutter_template/presentation/state_management/app_bloc_observer.dart';

void main() {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Dependency Injection setup
    await configureDependencies();

    // 2. Global BLoC Observer for error & state lifecycle tracking
    Bloc.observer = getIt<AppBlocObserver>();

    // 3. Flutter Framework Rendering Crashes (Widget Build & Layout Errors)
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _reportFatalError(details.exception, details.stack);
    };

    // 4. Platform Dispatcher Async Crashes (Isolates & Native Bridges)
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      _reportFatalError(error, stack);
      return true; // Prevents process termination
    };

    runApp(const Application());
  }, (Object error, StackTrace stack) {
    // 5. Root Async Zone Fallback
    _reportFatalError(error, stack);
  });
}

void _reportFatalError(Object error, StackTrace? stack) {
  AppLogger.error(
    'Uncaught Fatal Application Exception',
    error: error,
    stackTrace: stack,
  );

  if (!kDebugMode) {
    // FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  }
}
```

---

## 4. `AppBlocObserver` Error Monitoring

```dart
// lib/presentation/state_management/app_bloc_observer.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_template/infrastructure/logging/app_logger.dart';

@lazySingleton
class AppBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    AppLogger.error(
      'Unhandled error in ${bloc.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );

    // Forward non-fatal BLoC exceptions to Crashlytics
    // FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: false);

    super.onError(bloc, error, stackTrace);
  }
}
```

---

## 5. Custom Error Widget for Production (No Red Screen of Death)

```dart
void setupCustomErrorWidget() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (kDebugMode) {
      return ErrorWidget(details.exception);
    }

    return Material(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.warning_amber_rounded, size: 48, color: Colors.amber),
              SizedBox(height: 16),
              Text(
                'Something went wrong. Please restart the app.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  };
}
```

---

## 6. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Leaving `runZonedGuarded` or `PlatformDispatcher.instance.onError` unconfigured | **CRITICAL** | Configure all 3 root crash hooks in `main()`. |
| Sending raw PII (passwords, tokens) in error logs to Crashlytics | **CRITICAL** | Sanitize logs via `AppLogger` before recording errors. |
| Calling `exit(1)` on uncaught errors | **HIGH** | Return `true` in `PlatformDispatcher.onError` to prevent hard crashes where recoverable. |

---

## 7. Verification Checklist

- [ ] `main.dart` wraps startup in `runZonedGuarded`.
- [ ] `FlutterError.onError` and `PlatformDispatcher.instance.onError` are wired.
- [ ] `AppBlocObserver` intercepts all BLoC `addError()` calls.
- [ ] Production error widget prevents red screen of death.
