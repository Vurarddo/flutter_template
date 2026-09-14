---
name: flutter-ui-utils-hub
description: Primary coordinator and architecture guide for Flutter UI Utilities (lib/presentation/ui_utils/). Enforces presentation helper boundaries, routing to specialized sub-skills for BuildContext extensions, TextInputFormatters, Reactive Forms accessors/adapters, and system UI helpers.
---

# Flutter UI Utils Coordinator & Architecture Hub

## 1. Overview & Presentation Helper Layer Boundaries

The `lib/presentation/ui_utils/` directory houses **infrastructure tools, helpers, formatters, and extensions exclusively for the Presentation layer**.

Code inside `ui_utils/`:
1. **Depends on Flutter/UI Frameworks:** Utilizes `package:flutter/...`, `reactive_forms`, `flutter/services.dart`, or UI layout packages.
2. **Contains Zero Domain / Business Rules:** Pure transformation, presentation formatting, and UI adapters.
3. **Contains Zero Standalone Visual Components:** UI widgets belonging to the reusable design system live in `lib/presentation/ui_kit/`, while screens and feature-specific dialogs live in `lib/presentation/pages/`.

### Strict Layer Separation Matrix

| Directory | Scope & Dependencies | Examples |
| :--- | :--- | :--- |
| **`lib/core/extensions/` & `core/utils/`** | **Pure Dart Only.** Strictly NO `package:flutter` or UI imports. Shared across all layers. | Date ISO formatters, calculation math, regex string validators, pure data converters. |
| **`lib/presentation/ui_utils/`** | **UI Helpers & Formatters.** Flutter/UI-dependent helpers, extensions, formatters, and accessors. | `TextInputFormatter`, `ControlValueAccessor`, `HapticFeedbackHelper`, `BuildContext` extensions. |
| **`lib/presentation/ui_kit/`** | **Reusable Design System Widgets.** Stateless, decoupled visual components. | `AppButton`, `AppTextField`, `AppCard`, `AppModalSheet`. |
| **`lib/presentation/pages/<feature>/`** | **Feature Screens & Dialogs.** Stateful UI with BLoC/Cubit, routing, and analytics. | `SubscriptionDialog`, `ProfilePage`, `CheckoutSheet`. |

---

## 2. UI Utils Skill Tree & Routing Matrix

Use this matrix to navigate to the specialized sub-skill matching your specific UI utility task:

| Sub-Domain | Target Sub-Skill | Purpose |
| :--- | :--- | :--- |
| **UI Context Extensions** | [flutter-ui-utils-extensions](../flutter-ui-utils-extensions/SKILL.md) | `BuildContext` helpers (`context.colorScheme`, `context.textTheme`, `context.customColors`, `isDark`, media queries, fluent widget wrappers). |
| **Input Formatters** | [flutter-ui-utils-formatters](../flutter-ui-utils-formatters/SKILL.md) | Custom `TextInputFormatter` implementations (phone masks, payment card numbers, currency inputs, text filters). |
| **Reactive Forms Adapters** | [flutter-ui-utils-forms](../flutter-ui-utils-forms/SKILL.md) | Custom `ControlValueAccessor` implementations, UI-level form helpers, and focus traversal utilities. |
| **System UI Helpers** | [flutter-ui-utils-helpers](../flutter-ui-utils-helpers/SKILL.md) | System overlays, haptic feedback helpers, keyboard unfocus utilities, clipboard management. |
| **Localization Integration** | [l10n-presentation-integration](../../../l10n/l10n-presentation-integration/SKILL.md) | `context.localization` accessors, `DomainFailure` string mappers, and locale-aware formatters. |
| **Parent UI Coordinator** | [flutter-ui-hub](../../ui/flutter-ui-hub/SKILL.md) | Central UI architecture coordinator, widget decomposition, slivers, responsive layouts. |
| **UI Kit Architecture** | [flutter-ui-kit-hub](../../ui/ui-kit/flutter-ui-kit-hub/SKILL.md) | Reusable visual design system components. |
| **Theming System** | [flutter-ui-theme-hub](../../theme/flutter-ui-theme-hub/SKILL.md) | Material 3 ColorSchemes, TextThemes, and ThemeExtensions. |

---

## 3. Directory Standard for `lib/presentation/ui_utils/`

```text
lib/presentation/ui_utils/
├── assets/                  # Assets and SVGs generated via flutter_gen (lib/presentation/ui_utils/assets/)
├── extensions/              # UI-specific extensions (BuildContext, Widget wrappers, TextStyle modifiers)
│   ├── context_extensions.dart
│   ├── widget_extensions.dart
│   └── text_style_extensions.dart
├── formatters/              # Custom TextInputFormatter classes
│   ├── card_number_formatter.dart
│   ├── phone_number_formatter.dart
│   └── currency_input_formatter.dart
├── forms/                   # Reactive Forms UI adapters & ControlValueAccessors
│   ├── date_time_value_accessor.dart
│   ├── color_hex_value_accessor.dart
│   └── form_focus_helper.dart
└── helpers/                 # System UI & platform interaction helpers
    ├── haptic_feedback_helper.dart
    ├── system_ui_overlay_helper.dart
    └── keyboard_helper.dart
```

---

## 4. Technical Constraints & Architecture Rules

1. **Package Imports:** ALWAYS use package imports (`import 'package:flutter_template/...';`). Relative imports are strictly forbidden.
2. **No Monolithic Utils Files:** Split extensions, formatters, and helpers by single responsibility. Max file length: 150–200 lines.
3. **Stateless & Pure:** Formatters and accessors must be pure, immutable, and deterministic where possible.
4. **No Direct Domain/Repository Access:** UI utils must never import or interact with Domain Repositories, UseCases, or Data DTOs.
5. **Context Extension Standard:** Always access themes via `context.colorScheme`, `context.textTheme`, and `context.customColors` instead of `Theme.of(context)` directly in UI code.

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Placing feature-specific dialogs (e.g. `SubscriptionDialog`) in `ui_utils` | **CRITICAL** | Move to `lib/presentation/pages/<feature>/widgets/` or `lib/presentation/pages/<feature>/`. |
| Placing pure Dart logic (no Flutter SDK imports) in `ui_utils` | **HIGH** | Move pure Dart extensions/helpers to `lib/core/extensions/` or `lib/core/utils/`. |
| Creating visual UI Kit widgets inside `ui_utils` | **HIGH** | Move reusable design system widgets to `lib/presentation/ui_kit/`. |
| Accessing `Theme.of(context)` or `MediaQuery.of(context)` directly across UI files | **MEDIUM** | Use extensions in `lib/presentation/ui_utils/extensions/context_extensions.dart`. |

---

## 6. Master UI Utils Verification Checklist

Before completing any UI utils implementation:
- [ ] Code strictly belongs to the Presentation helper layer (no business logic, no full UI feature dialogs).
- [ ] Flutter/UI dependencies are justified; pure Dart logic is located in `lib/core/`.
- [ ] Files are kept under 150–200 lines and properly decomposed into `extensions/`, `formatters/`, `forms/`, or `helpers/`.
- [ ] All imports use absolute package paths (`package:flutter_template/...`).
- [ ] Unit tests are written for custom formatters and `ControlValueAccessor` classes.
