---
name: flutter-ui-kit-hub
description: Primary coordinator and architecture guide for authoring pure UI Kit components in lib/presentation/ui_kit/. Enforces atomic design, 100% pure stateless widgets, zero BLoC/Domain dependencies, design token access, and mandatory dual-theme @Preview coverage. Use when designing, creating, refactoring, or auditing reusable UI components.
---

# Flutter UI Kit Master Coordinator & Architecture

## 1. Overview & Golden UI Kit Laws

This skill serves as the central entry point for the **UI Kit** subsystem (`lib/presentation/ui_kit/`). It defines strict architectural boundaries to guarantee that all reusable components remain pure, portable, decoupled, and easily testable.

### 🛡️ Golden UI Kit Laws:
1. **100% Pure & Decoupled:** Components in `lib/presentation/ui_kit/` MUST NEVER import BLoCs, Cubits, Repositories, Use Cases, or external network clients. They only accept primitive data or pure UI models.
2. **Stateless First:** UI Kit widgets should be `StatelessWidget` by default. Use `StatefulWidget` strictly for internal interaction states (e.g., hover ticker, focus highlights).
3. **No Direct Hardcoded Colors/Fonts:** ALL colors and text styles must be retrieved dynamically via `context.colorScheme`, `context.customColors` (`ThemeExtension`), or `context.textTheme`.
4. **Mandatory `@Preview` Coverage:** EVERY UI Kit widget MUST include `@Preview` definitions for both **Light** and **Dark** themes.
5. **Strict Line Limit:** Keep each UI Kit component file under **150–200 lines**. Extract internal sub-elements into private widget classes if needed.

---

## 2. UI Kit Subsystem Mesh & Routing Matrix

| Task / Area | Target Skill | Purpose |
| :--- | :--- | :--- |
| **Component Authoring** | [flutter-ui-kit-components](../flutter-ui-kit-components/SKILL.md) | Standard recipes for buttons, cards, badges, dialogs, bottom sheets, snackbars. |
| **Widget Previews** | [flutter-ui-kit-preview](../flutter-ui-kit-preview/SKILL.md) | `@Preview` decorators, `PreviewWrapper`, dual-theme verification, state matrices. |
| **Parent UI Hub** | [flutter-ui-hub](../../flutter-ui-hub/SKILL.md) | Global presentation layer rules and overall UI routing. |
| **Theming System** | [flutter-ui-theme-hub](../../../theme/flutter-ui-theme-hub/SKILL.md) | Material 3 ColorScheme, TextTheme, and ThemeExtensions. |
| **Reactive Form Controls** | [flutter-ui-forms-custom-controls](../../forms/flutter-ui-forms-custom-controls/SKILL.md) | Binding UI Kit input fields with `reactive_forms`. |

---

## 3. Directory Layout Standard (`lib/presentation/ui_kit/`)

Organize reusable UI components by category:

```text
lib/presentation/ui_kit/
├── buttons/                    # AppButton, AppIconButton, AppSegmentedButton
│   ├── app_button.dart
│   └── app_icon_button.dart
├── cards/                      # AppCard, AppOutlinedCard, AppElevatedCard
│   └── app_card.dart
├── badges/                     # AppBadge, AppStatusIndicator, AppChip
│   └── app_badge.dart
├── inputs/                     # Base styled text fields, search bars, checkboxes
│   ├── app_text_field.dart
│   └── app_search_bar.dart
├── feedback/                   # AppSnackbar, AppBanner, AppLoadingIndicator
│   ├── app_snackbar.dart
│   └── app_shimmer.dart
└── modals/                     # AppBottomSheet, AppDialog, AppConfirmationModal
    ├── app_bottom_sheet.dart
    └── app_dialog.dart
```

---

## 4. Component API Design Standard

Every UI Kit component must follow a clean, strongly-typed API contract using enums for visual variants:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_template/presentation/ui_utils/extensions/context_extensions.dart';

enum AppButtonVariant { primary, secondary, tonal, outlined, text }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Widget? leadingIcon;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.leadingIcon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Styling driven dynamically by Theme tokens
    final colorScheme = context.colorScheme;
    // ...
    return ElevatedButton(...);
  }
}
```

---

## 5. UI Kit Verification Checklist

Before adding or updating any UI Kit widget:
- [ ] Widget is located inside `lib/presentation/ui_kit/<category>/`.
- [ ] Zero BLoC/Domain dependencies exist in the component.
- [ ] All colors derive from `colorScheme` or `customColors`.
- [ ] Component includes Light and Dark `@Preview` functions wrapped in `PreviewWrapper`.
- [ ] File length is strictly under 150–200 lines.
