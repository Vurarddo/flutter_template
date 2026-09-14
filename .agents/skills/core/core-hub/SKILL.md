---
name: core-hub
description: Primary coordinator and architecture guide for the Core layer (lib/core/). Enforces Pure Dart boundaries (strictly zero Flutter SDK imports), routing to specialized sub-skills for global extensions, algorithmic utilities, constants, and data transformers.
---

# Core Layer Coordinator & Architecture Hub

## 1. Overview & Core Layer Philosophy

The `lib/core/` directory contains **framework-agnostic, pure Dart foundations, utilities, extensions, and constants** shared across all layers of the application (`domain`, `data`, `presentation`, `infrastructure`).

### Core Laws of `lib/core/`:
1. **100% Pure Dart (Strict Zero-Flutter Rule):**
   - Strictly **PROHIBITED** to import `package:flutter/...`, `dart:ui`, or any UI-related packages inside `lib/core/`.
   - The Core layer must be testable via pure Dart VM unit tests without `flutter_test` widget pump overhead.
2. **Global Accessibility:**
   - Any layer can import and consume `lib/core/`.
   - `lib/core/` must **NEVER** depend on `lib/domain/`, `lib/data/`, `lib/presentation/`, or `lib/infrastructure/`.
3. **No Business Rules:**
   - Contains general algorithmic logic (math, date formatting, regex, string manipulation), NOT domain business rules (which belong in `lib/domain/`).

---

## 2. Core Skill Tree & Routing Matrix

Use this matrix to navigate to the specialized sub-skill matching your task:

| Sub-Domain | Target Sub-Skill | Purpose |
| :--- | :--- | :--- |
| **Pure Dart Extensions** | [core-extensions](../core-extensions/SKILL.md) | Extensions on `DateTime`, `String`, `num`, `Iterable`, `Map` with zero Flutter imports. |
| **Algorithmic Utilities** | [core-utils](../core-utils/SKILL.md) | Pure Dart calculation utilities, regex validators, cryptography, currency math, debouncers. |
| **Global Constants** | [core-constants](../core-constants/SKILL.md) | Application-wide constants, regex patterns, duration limits, date formats. |
| **Infrastructure Hub** | [infrastructure-hub](../../infrastructure/infrastructure-hub/SKILL.md) | External SDKs, network, storage, DI, and platform services. |
| **UI Utils Hub** | [flutter-ui-utils-hub](../../presentation/ui-utils/flutter-ui-utils-hub/SKILL.md) | UI-specific extensions (`BuildContext`), formatters, and reactive form accessors. |
| **Clean Architecture Hub** | [flutter-clean-architecture](../../flutter-clean-architecture/SKILL.md) | System-wide layer separation, DDD, and dependency flow. |

---

## 3. Directory Standard for `lib/core/`

```text
lib/core/
├── constants/               # Global non-UI constants
│   ├── regex_constants.dart
│   ├── time_constants.dart
│   └── format_constants.dart
├── extensions/              # Pure Dart extensions (NO package:flutter)
│   ├── date_time_extensions.dart
│   ├── string_extensions.dart
│   ├── num_extensions.dart
│   └── iterable_extensions.dart
└── utils/                   # Pure Dart algorithms and helper utilities
    ├── currency_calculator.dart
    ├── string_utils.dart
    └── debouncer.dart
```

---

## 4. Extension Location Strategy Matrix

| Type of Extension | Target Directory | Imports Allowed | Example |
| :--- | :--- | :--- | :--- |
| **Pure Dart Logic** | `lib/core/extensions/` | Pure Dart (`dart:core`, `dart:math`, `intl`) | `dateTime.isToday`, `string.isEmail`, `num.toCurrency` |
| **Flutter / BuildContext** | `lib/presentation/ui_utils/extensions/` | `package:flutter/...` | `context.colorScheme`, `widget.unfocusWrapper()`, `textStyle.withWeight` |

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Importing `package:flutter/material.dart` inside `lib/core/` | **CRITICAL** | Remove Flutter import; move UI-specific code to `presentation/ui_utils/`. |
| Placing domain business logic (e.g. `isUserEligibleForPromo`) in `core/` | **HIGH** | Move to a UseCase or Domain Entity method in `lib/domain/`. |
| Importing `data/` or `infrastructure/` from `core/` | **CRITICAL** | Invert dependency; Core must remain independent of outer layers. |

---

## 6. Master Core Verification Checklist

Before completing changes in `lib/core/`:
- [ ] File contains zero Flutter SDK imports (`package:flutter/*`).
- [ ] Code is pure Dart, deterministic, and covered by unit tests.
- [ ] Files stay strictly within 150–200 lines.
- [ ] Uses package imports (`import 'package:flutter_template/core/...';`).
