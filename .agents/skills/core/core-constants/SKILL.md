---
name: core-constants
description: Standards and patterns for global non-UI constants in lib/core/constants/. Covers regex patterns, global time duration constants, pagination defaults, and formatting constants.
---

# Core Constants & Definitions

## 1. Overview & When to Apply

Use this skill whenever:
- Adding or modifying non-UI constants used across multiple layers (`domain`, `data`, `infrastructure`).
- Centralizing regular expressions (email, phone, URL, numeric), pagination limits, default timeouts, or ISO date formatting strings.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [core-hub](../core-hub/SKILL.md) | Core layer laws and zero-Flutter constraint. |
| **Environment Config** | [infrastructure-config](../../infrastructure/infrastructure-config/SKILL.md) | Environment-specific variables (`--dart-define`). |

---

## 3. Standard Implementation Patterns

### 3.1 Regular Expression Constants (`regex_constants.dart`)

```dart
abstract final class RegexConstants {
  static final RegExp email = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  static final RegExp phone = RegExp(
    r'^\+?[0-9]{10,15}$',
  );

  static final RegExp numericOnly = RegExp(r'^\d+$');
  static final RegExp nonDigit = RegExp(r'\D');
}
```

---

### 3.2 Time & Duration Constants (`time_constants.dart`)

```dart
abstract final class TimeConstants {
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration defaultDebounce = Duration(milliseconds: 350);
  static const Duration toastDuration = Duration(seconds: 3);
  static const Duration animationDurationFast = Duration(milliseconds: 200);
  static const Duration animationDurationStandard = Duration(milliseconds: 300);
}
```

---

### 3.3 Pagination & Pagination Limits (`pagination_constants.dart`)

```dart
abstract final class PaginationConstants {
  static const int defaultPageSize = 20;
  static const int initialPage = 1;
  static const int maxPageSize = 100;
}
```

---

## 4. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Putting environment secrets or API keys in `core/constants/` | **CRITICAL** | Use `AppConfig` via `--dart-define` (see `infrastructure-config`). |
| Putting UI colors or text styles in `core/constants/` | **CRITICAL** | Colors belong to `ThemeExtension` in `lib/presentation/theme/`. |
| Re-compiling `RegExp` objects on every method call | **HIGH** | Declare `RegExp` as `static final` constants. |

---

## 5. Verification Checklist

- [ ] Zero UI imports (`package:flutter/*`).
- [ ] No hardcoded environment credentials or URLs.
- [ ] Classes use `abstract final class` with `static const` or `static final` fields.
