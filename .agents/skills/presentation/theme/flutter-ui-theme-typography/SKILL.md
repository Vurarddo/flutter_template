---
name: flutter-ui-theme-typography
description: Material 3 TextTheme typography, scale, and custom font integration skill. Use when creating or modifying AppTextTheme, configuring Material 3 text scales (display, headline, title, body, label), setting up custom fonts via FontFamily (flutter_gen), or adjusting letter spacing and font weights.
---

# Flutter UI Theme Typography & TextTheme Guide

## 1. Overview & When to Apply

Use this skill whenever:
- Implementing or modifying `AppTextTheme` in `lib/presentation/theme/app_text_theme.dart`.
- Configuring Material 3 typography scales (Display, Headline, Title, Body, Label).
- Integrating custom fonts generated via `flutter_gen` (`FontFamily` from `lib/presentation/ui_utils/assets/fonts.gen.dart`).
- Setting up semantic text styles, letter spacing, font weights, and text colors linked to `ColorScheme.onSurface` / `onSurfaceVariant`.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Theme Hub** | [flutter-ui-theme-hub](../flutter-ui-theme-hub/SKILL.md) | Central theming architecture and modular layout. |
| **Theme Colors** | [flutter-ui-theme-colors](../flutter-ui-theme-colors/SKILL.md) | Supplying `ColorScheme` for dynamic text coloring. |
| **Material 3 Components** | [flutter-ui-material](../../ui/flutter-ui-material/SKILL.md) | Using `context.textTheme` inside UI widgets. |

---

## 3. Material 3 Typography Scale Matrix

| Style Token | Size (pt) | Weight | Line Height | Tracking | Intended Usage |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `displayLarge` | 57 | Regular (w400) | 64 | -0.25 | Short hero numbers / splash titles |
| `displayMedium` | 45 | Regular (w400) | 52 | 0.0 | High-impact headlines |
| `displaySmall` | 36 | Regular (w400) | 44 | 0.0 | Featured section hero titles |
| `headlineLarge` | 32 | Regular (w400) | 40 | 0.0 | Top-level screen headings |
| `headlineMedium` | 28 | Regular (w400) | 36 | 0.0 | Dialog & section headlines |
| `headlineSmall` | 24 | Regular (w400) | 32 | 0.0 | Prominent card headings |
| `titleLarge` | 22 | Medium (w500) | 28 | 0.0 | AppBar title, modal headers |
| `titleMedium` | 16 | Medium (w500) | 24 | +0.15 | List tile titles, card sub-headers |
| `titleSmall` | 14 | Medium (w500) | 20 | +0.1 | Subsection titles, table headers |
| `bodyLarge` | 16 | Regular (w400) | 24 | +0.5 | Primary body copy, article text |
| `bodyMedium` | 14 | Regular (w400) | 20 | +0.25 | Standard UI text, descriptions |
| `bodySmall` | 12 | Regular (w400) | 16 | +0.4 | Secondary notes, metadata, timestamps |
| `labelLarge` | 14 | Medium (w500) | 20 | +0.1 | Primary button text, tab labels |
| `labelMedium` | 12 | Medium (w500) | 16 | +0.5 | Chips, badges, bottom navigation |
| `labelSmall` | 11 | Medium (w500) | 16 | +0.5 | Overline text, micro tags |

---

## 4. Standard Implementation Pattern (`app_text_theme.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_template/presentation/ui_utils/assets/fonts.gen.dart';

abstract final class AppTextTheme {
  static const String _fontFamily = FontFamily.ufficio;

  static TextTheme createTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: colorScheme.onSurface,
      ),
      displayMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      displaySmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      headlineLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      headlineSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: colorScheme.onSurface,
      ),
      titleSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: colorScheme.onSurface,
      ),
      bodyLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: colorScheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: colorScheme.onSurface,
      ),
      labelMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: colorScheme.onSurface,
      ),
      labelSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
```

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Hardcoding `TextStyle(fontSize: 16, color: Colors.black)` directly in widgets | **CRITICAL** | Use `context.textTheme.bodyLarge` with `.copyWith()` if modifications are needed. |
| Hardcoding raw font family string literals (`fontFamily: 'Ufficio'`) | **HIGH** | Use strongly-typed `FontFamily` from `package:flutter_template/presentation/ui_utils/assets/fonts.gen.dart`. |
| Hardcoded fixed colors inside text styles ignoring theme brightness | **HIGH** | Bind text colors dynamically to `colorScheme.onSurface` and `colorScheme.onSurfaceVariant`. |

---

## 6. Verification Checklist

- [ ] All 15 Material 3 text style tokens are defined in `AppTextTheme`.
- [ ] Custom font families use generated `FontFamily` constants.
- [ ] Text styles dynamically inherit `colorScheme.onSurface` / `onSurfaceVariant`.
- [ ] Widgets access typography strictly via `context.textTheme`.
