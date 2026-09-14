---
name: infrastructure-logging
description: Standards and patterns for application logging in lib/infrastructure/logging/. Covers AppLogger, log levels (debug, info, warning, error), PII redaction, Talker integration, and production log filtering.
---

# Infrastructure Logging & Diagnostic Architecture

## 1. Overview & When to Apply

Use this skill whenever:
- Adding or configuring application loggers (`AppLogger`, `Talker`, `Logger`).
- Logging network payloads, BLoC state transitions, navigation events, or background jobs.
- Masking sensitive user data (PII, tokens, credit card numbers) before writing to log sinks.
- Enforcing the rule that raw `print()` / `debugPrint()` is strictly prohibited in production code.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [infrastructure-hub](../infrastructure-hub/SKILL.md) | Infrastructure layer architecture. |
| **Firebase Services** | [infrastructure-services-firebase](../infrastructure-services-firebase/SKILL.md) | Forwarding fatal error logs to Crashlytics. |
| **Environment Config** | [infrastructure-config](../infrastructure-config/SKILL.md) | Controlling log verbosity via `AppConfig.enableLogging`. |

---

## 3. Standard Implementation Pattern (`app_logger.dart`)

```dart
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_template/infrastructure/config/app_config.dart';
import 'package:flutter_template/infrastructure/services/firebase/crashlytics_service.dart';

@lazySingleton
class AppLogger {
  final CrashlyticsService _crashlyticsService;

  AppLogger(this._crashlyticsService);

  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (!AppConfig.enableLogging || !kDebugMode) return;
    developer.log(
      message,
      name: 'DEBUG',
      error: error,
      stackTrace: stackTrace,
      level: 500,
    );
  }

  void info(String message) {
    if (!AppConfig.enableLogging) return;
    developer.log(
      message,
      name: 'INFO',
      level: 800,
    );
  }

  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: 'WARNING',
      error: error,
      stackTrace: stackTrace,
      level: 900,
    );
  }

  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    bool sendToCrashlytics = true,
  }) {
    developer.log(
      message,
      name: 'ERROR',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );

    if (sendToCrashlytics && error != null) {
      _crashlyticsService.recordError(
        error,
        stackTrace,
        reason: message,
      );
    }
  }
}
```

---

## 4. PII Redaction Standard

Always sanitize sensitive fields in network and state logs:

```dart
abstract final class LogSanitizer {
  static final _sensitiveKeys = {'password', 'token', 'authorization', 'access_token', 'refresh_token', 'cvv', 'pin'};

  static Map<String, dynamic> sanitize(Map<String, dynamic> json) {
    final sanitized = Map<String, dynamic>.from(json);
    for (final key in sanitized.keys) {
      if (_sensitiveKeys.contains(key.toLowerCase())) {
        sanitized[key] = '***REDACTED***';
      } else if (sanitized[key] is Map<String, dynamic>) {
        sanitized[key] = sanitize(sanitized[key] as Map<String, dynamic>);
      }
    }
    return sanitized;
  }
}
```

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Using `print()` or `debugPrint()` directly in business/network code | **CRITICAL** | Use `AppLogger.debug()`, `info()`, or `error()`. |
| Logging raw auth tokens or credit card numbers in plaintext | **CRITICAL** | Run through `LogSanitizer.sanitize()`. |
| Flooding production Crashlytics with debug/info logs | **HIGH** | Only forward high-severity errors (`AppLogger.error()`) to Crashlytics. |

---

## 6. Verification Checklist

- [ ] All direct `print()` calls are replaced with `AppLogger`.
- [ ] PII data is stripped before logging payloads.
- [ ] Error logs are recorded to Crashlytics in production.
