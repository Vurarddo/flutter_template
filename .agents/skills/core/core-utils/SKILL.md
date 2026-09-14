---
name: core-utils
description: Standards and implementation patterns for Pure Dart utilities in lib/core/utils/. Covers algorithmic helpers, regex validators, cryptography hashing, debounce timers, and currency calculations without Flutter SDK dependencies.
---

# Pure Dart Core Utilities

## 1. Overview & When to Apply

Use this skill whenever:
- Adding or modifying non-UI utility classes (e.g., `Debouncer`, `Throttler`, `CurrencyCalculator`, `CryptoUtils`, `ValidationUtils`).
- Implementing algorithmic computations that need to run across isolates or in background compute tasks.
- Ensuring utility functions remain testable, deterministic, and free of Flutter dependencies.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [core-hub](../core-hub/SKILL.md) | Core layer laws and zero-Flutter constraint. |
| **Pure Dart Extensions** | [core-extensions](../core-extensions/SKILL.md) | Extensions on primitive types. |
| **Unit Testing** | [testing-unit](../../testing/testing-unit/SKILL.md) | Unit testing pure algorithmic utilities. |

---

## 3. Standard Implementation Patterns

### 3.1 Pure Dart Debouncer (`debouncer.dart`)

```dart
import 'dart:async';

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  bool get isActive => _timer?.isActive ?? false;
}
```

---

### 3.2 Pure Dart Validation Utils (`validation_utils.dart`)

```dart
import 'package:flutter_template/core/constants/regex_constants.dart';

abstract final class ValidationUtils {
  /// Validates standard email address format.
  static bool isValidEmail(String? input) {
    if (input == null || input.trim().isEmpty) return false;
    return RegexConstants.email.hasMatch(input.trim());
  }

  /// Validates international phone format.
  static bool isValidPhone(String? input) {
    if (input == null || input.trim().isEmpty) return false;
    return RegexConstants.phone.hasMatch(input.trim());
  }

  /// Validates password strength (min 8 chars, 1 letter, 1 digit).
  static bool isStrongPassword(String? input) {
    if (input == null || input.length < 8) return false;
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(input);
    final hasDigit = RegExp(r'\d').hasMatch(input);
    return hasLetter && hasDigit;
  }
}
```

---

### 3.3 Currency & Precision Math (`currency_calculator.dart`)

```dart
import 'dart:math';

abstract final class CurrencyCalculator {
  /// Rounds a monetary amount to standard decimal precision avoiding floating-point drift.
  static double roundToCents(double amount, {int precision = 2}) {
    final factor = pow(10, precision);
    return (amount * factor).round() / factor;
  }

  /// Calculates percentage discount safely.
  static double calculateDiscount({
    required double originalPrice,
    required double discountedPrice,
  }) {
    if (originalPrice <= 0) return 0.0;
    final discount = ((originalPrice - discountedPrice) / originalPrice) * 100;
    return discount.clamp(0.0, 100.0);
  }
}
```

---

## 4. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Creating stateful singleton "Manager" classes in `core/utils/` | **CRITICAL** | Use `abstract final class` with static pure methods or register via DI. |
| Using `Timer` in `Debouncer` without providing `cancel()` cleanup | **HIGH** | Always implement `cancel()` to prevent memory/timer leaks. |
| Floating point arithmetic for currency without rounding | **MEDIUM** | Use explicit rounding or integer cents representation. |

---

## 5. Verification Checklist

- [ ] Zero Flutter SDK imports in `lib/core/utils/`.
- [ ] Utilities use `abstract final` or pure class instances.
- [ ] Timer-based utilities expose clean cancellation lifecycle methods.
- [ ] 100% test coverage for math and regex validation methods.
