---
name: flutter-ui-kit-components
description: Authoring standards and implementation recipes for pure UI Kit components in Flutter. Covers design tokens consumption, buttons, cards, status badges, modal dialogs, bottom sheets, snackbars, and typed variant APIs. Use when creating or updating reusable UI Kit widgets.
---

# Flutter UI Kit Component Authoring Guide

## 1. Overview & When to Apply

Use this skill whenever:
- Implementing reusable atomic widgets (Buttons, Cards, Badges, Chips) in `lib/presentation/ui_kit/`.
- Building reusable modals, bottom sheets, confirmation dialogs, or snackbars.
- Establishing consistent component APIs with typed variants and sizes.
- Handling loading, disabled, hover, and pressed states inside UI Kit widgets.
- Ensuring strict token consumption without hardcoding pixel values or hex colors.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent UI Kit Hub** | [flutter-ui-kit-hub](../flutter-ui-kit-hub/SKILL.md) | UI Kit architecture, laws, and folder standards. |
| **Widget Previews** | [flutter-ui-kit-preview](../flutter-ui-kit-preview/SKILL.md) | Attaching `@Preview` decorators to components. |
| **Theming Tokens** | [flutter-ui-theme-hub](../../../theme/flutter-ui-theme-hub/SKILL.md) | Accessing ColorScheme, TextTheme, and CustomColors. |
| **Custom Controls** | [flutter-ui-forms-custom-controls](../../forms/flutter-ui-forms-custom-controls/SKILL.md) | Wrapping UI Kit inputs with reactive form bindings. |

---

## 3. Standard Implementation Recipes

### 3.1 AppBadge Component Recipe
```dart
import 'package:flutter/material.dart';
import 'package:flutter_template/presentation/ui_utils/extensions/context_extensions.dart';

enum AppBadgeVariant { neutral, success, warning, error, primary }

class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeVariant variant;
  final Widget? icon;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.neutral,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    final (backgroundColor, foregroundColor) = switch (variant) {
      AppBadgeVariant.primary => (colorScheme.primaryContainer, colorScheme.onPrimaryContainer),
      AppBadgeVariant.success => (colorScheme.tertiaryContainer, colorScheme.onTertiaryContainer),
      AppBadgeVariant.warning => (colorScheme.errorContainer.withValues(alpha: 0.3), colorScheme.onErrorContainer),
      AppBadgeVariant.error   => (colorScheme.errorContainer, colorScheme.onErrorContainer),
      AppBadgeVariant.neutral => (colorScheme.surfaceContainerHighest, colorScheme.onSurfaceVariant),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(size: 14, color: foregroundColor),
              child: icon!,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 3.2 AppCard Component Recipe
```dart
import 'package:flutter/material.dart';

import 'package:flutter_template/presentation/ui_utils/extensions/context_extensions.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool isSelected;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    final borderSide = isSelected
        ? BorderSide(color: colorScheme.primary, width: 2)
        : BorderSide(color: colorScheme.outlineVariant);

    return Card(
      elevation: 0,
      color: isSelected ? colorScheme.primaryContainer.withValues(alpha: 0.15) : colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: borderSide,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
```

### 3.3 AppDialog & Bottom Sheet Utilities
```dart
import 'package:flutter/material.dart';

import 'package:flutter_template/presentation/ui_utils/extensions/context_extensions.dart';

abstract class AppModals {
  static Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) {
    final colorScheme = context.colorScheme;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            style: isDestructive
                ? FilledButton.styleFrom(backgroundColor: colorScheme.error, foregroundColor: colorScheme.onError)
                : null,
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}
```

---

## 4. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Hardcoding raw colors (`Color(0xFF...)`) in UI Kit widgets | **CRITICAL** | Derive colors dynamically from `context.colorScheme` or `context.customColors`. |
| Importing BLoC/Cubit or UseCases inside UI Kit files | **CRITICAL** | UI Kit components must only accept pure data props and callbacks. |
| Missing `@Preview` definitions on UI Kit files | **HIGH** | Add `@Preview` functions for both Light and Dark themes. |
| Inconsistent spacing/padding not matching design tokens | **MEDIUM** | Use standard multiples of 4dp/8dp for insets and radii. |

---

## 5. Verification Checklist

- [ ] Component is decoupled from business logic and receives only primitive/UI models.
- [ ] Visual variants are modeled via strongly-typed enums.
- [ ] ColorScheme tokens adapt seamlessly to Light and Dark modes.
- [ ] Hover and pressed states are handled for desktop and touch targets.
- [ ] Component is paired with a corresponding `@Preview` in the same file or preview directory.
