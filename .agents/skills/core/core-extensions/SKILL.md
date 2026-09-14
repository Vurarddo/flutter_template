---
name: core-extensions
description: Standards and implementation patterns for Pure Dart extensions in lib/core/extensions/. Covers DateTime manipulation, String transformations, num/currency formatting, Iterable filtering, and Map utilities without any Flutter SDK dependencies.
---

# Pure Dart Core Extensions

## 1. Overview & When to Apply

Use this skill whenever:
- Adding or modifying non-UI extensions on Dart primitive types (`DateTime`, `String`, `num`, `double`, `int`, `Iterable`, `List`, `Map`).
- Standardizing formatting for dates, timestamps, durations, and text manipulations across domain and data layers.
- Enforcing the rule that all extensions in `lib/core/extensions/` must remain 100% pure Dart.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [core-hub](../core-hub/SKILL.md) | Core layer laws and zero-Flutter constraint. |
| **UI Extensions** | [flutter-ui-utils-extensions](../../presentation/ui-utils/flutter-ui-utils-extensions/SKILL.md) | BuildContext & Widget extensions (lives in `presentation/ui_utils/`). |
| **Unit Testing** | [testing-unit](../../testing/testing-unit/SKILL.md) | Writing unit tests for pure Dart extension methods. |

---

## 3. Standard Implementation Patterns

### 3.1 `DateTime` Extensions (`date_time_extensions.dart`)

```dart
import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  /// Returns date formatted as ISO 8601 string without time (YYYY-MM-DD).
  String toIsoDateString() => DateFormat('yyyy-MM-dd').format(this);

  /// Checks if this date falls on the current calendar day.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Checks if this date was yesterday.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Returns start of the day (00:00:00.000).
  DateTime get startOfDay => DateTime(year, month, day);

  /// Returns end of the day (23:59:59.999).
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);
}
```

---

### 3.2 `String` Extensions (`string_extensions.dart`)

```dart
extension StringCasingExtensions on String {
  /// Capitalizes the first letter of the string.
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Converts snake_case or kebab-case to camelCase.
  String toCamelCase() {
    final words = split(RegExp(r'[_\-]'));
    if (words.isEmpty) return this;
    final buffer = StringBuffer(words.first.toLowerCase());
    for (int i = 1; i < words.length; i++) {
      buffer.write(words[i].capitalize());
    }
    return buffer.toString();
  }

  /// Safely extracts initials from a full name (e.g. "John Doe" -> "JD").
  String get initials {
    final parts = trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
```

---

### 3.3 `Iterable` & `List` Extensions (`iterable_extensions.dart`)

```dart
extension IterableExtensions<T> on Iterable<T> {
  /// Returns the first element matching [test] or null if not found.
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  /// Separates elements with a separator item.
  Iterable<T> separateWith(T separator) sync* {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return;
    yield iterator.current;
    while (iterator.moveNext()) {
      yield separator;
      yield iterator.current;
    }
  }
}
```

---

## 4. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Adding `BuildContext` or `Widget` methods in `lib/core/extensions/` | **CRITICAL** | Move to `lib/presentation/ui_utils/extensions/`. |
| Writing complex mutative state inside extensions | **HIGH** | Extensions should be pure functions returning new values. |
| Neglecting null/empty checks on String index access | **HIGH** | Always guard against empty strings before calling `this[0]`. |

---

## 5. Verification Checklist

- [ ] Zero Flutter SDK imports in all extension files.
- [ ] Covered with unit tests for edge cases (empty strings, leap years, empty lists).
- [ ] Extension names use consistent PascalCase (`TypeX` or `TypeExtensions`).
