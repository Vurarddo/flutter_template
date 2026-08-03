---
name: flutter-theme
description: Enforces Material 3 design token & theming standards. Enforces zero hardcoded colors/styles in UI, explicit Component Themes (inputDecorationTheme, cardTheme, buttonThemes), mandatory ThemeExtension with lerp/copyWith for custom tokens, and BuildContext extension getters. Use when building UI components, defining app themes, or configuring design system tokens.
---

# Flutter Theme & Design System Expert Skill

## When to Apply

Use this skill whenever defining design system tokens, creating `ThemeData` configurations, writing `ThemeExtension` classes, or styling presentation widgets.

---

## Core Rules for Theming & Tokens

1. **Zero Hardcoded Colors & Styles:**
   - **STRICTLY PROHIBITED:** Direct use of `Color(0xFF...)`, `Colors.blue`, or inline `TextStyle()` allocations inside `build()`.
   - All colors MUST be retrieved from `context.colorScheme` or `context.customColors`.
   - All text styles MUST derive from `context.textTheme` (use `.copyWith()` only for small deltas).

2. **Global Component Themes First:**
   - Centralize default styling for buttons, inputs, cards, and app bars in `ThemeData` so feature widgets remain thin.

3. **Mandatory `ThemeExtension` for Custom Tokens:**
   - Custom tokens (e.g., status badges, crypto trend colors `trendUp`/`trendDown`, chart palettes) MUST be implemented via `ThemeExtension<T>` with `lerp` and `copyWith`.

4. **Clean Context Extensions:**
   - Always use `BuildContext` extension getters (`context.colorScheme`, `context.customColors`) instead of verbose `Theme.of(context)` chains.

---

## 1. Custom Theme Extension Standard (`AppCustomColors`)

```dart
import 'package:flutter/material.dart';

/// Custom Design System Tokens not covered by standard Material ColorScheme.
@immutable
class AppCustomColors extends ThemeExtension<AppCustomColors> {
  final Color success;
  final Color warning;
  final Color trendUp;
  final Color trendDown;
  final Color cardBackgroundSecondary;

  const AppCustomColors({
    required this.success,
    required this.warning,
    required this.trendUp,
    required this.trendDown,
    required this.cardBackgroundSecondary,
  });

  @override
  AppCustomColors copyWith({
    Color? success,
    Color? warning,
    Color? trendUp,
    Color? trendDown,
    Color? cardBackgroundSecondary,
  }) {
    return AppCustomColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      trendUp: trendUp ?? this.trendUp,
      trendDown: trendDown ?? this.trendDown,
      cardBackgroundSecondary:
          cardBackgroundSecondary ?? this.cardBackgroundSecondary,
    );
  }

  @override
  AppCustomColors lerp(ThemeExtension<AppCustomColors>? other, double t) {
    if (other is! AppCustomColors) return this;

    return AppCustomColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      trendUp: Color.lerp(trendUp, other.trendUp, t)!,
      trendDown: Color.lerp(trendDown, other.trendDown, t)!,
      cardBackgroundSecondary: Color.lerp(
        cardBackgroundSecondary,
        other.cardBackgroundSecondary,
        t,
      )!,
    );
  }
}

```

---

## 2. Centralized Theme Architecture (`AppTheme`)

```dart
import 'package:flutter/material.dart';

abstract final class AppTheme {
  // Light Custom Palette
  static const _lightCustomColors = AppCustomColors(
    success: Color(0xFF2E7D32),
    warning: Color(0xFFED6C02),
    trendUp: Color(0xFF00C853),
    trendDown: Color(0xFFD50000),
    cardBackgroundSecondary: Color(0xFFF5F5F5),
  );

  // Dark Custom Palette
  static const _darkCustomColors = AppCustomColors(
    success: Color(0xFF66BB6A),
    warning: Color(0xFFFFB74D),
    trendUp: Color(0xFF00E676),
    trendDown: Color(0xFFFF5252),
    cardBackgroundSecondary: Color(0xFF1E1E1E),
  );

  static ThemeData get light => _buildTheme(Brightness.light, _lightCustomColors);
  static ThemeData get dark => _buildTheme(Brightness.dark, _darkCustomColors);

  static ThemeData _buildTheme(Brightness brightness, AppCustomColors customColors) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2196F3),
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,

      // Global Component Themes
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF0F0F0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      extensions: [customColors],
    );
  }
}

```

---

## 3. BuildContext Extension Helpers

```dart
import 'package:flutter/material.dart';

extension BuildContextThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  AppCustomColors get customColors =>
      theme.extension<AppCustomColors>() ??
      (throw StateError('AppCustomColors extension is not registered in ThemeData'));
}

```

---

## Anti-Patterns (Strictly Prohibited)

| Anti-Pattern                                                   | Severity     | Corrective Action                                 |
| -------------------------------------------------------------- | ------------ | ------------------------------------------------- |
| Hardcoded `Color(0xFF...)` or `Colors.*` in UI feature widgets | **CRITICAL** | Move color to `ColorScheme` or `AppCustomColors`. |

|
| Creating large `TextStyle(...)` literals inside `build()` | **HIGH** | Derive styles from `context.textTheme`.

|
| Missing `lerp` implementation in `ThemeExtension` | **HIGH** | Implement `Color.lerp` for smooth theme switching.

|
| Duplicate `BoxDecoration` / input styles scattered across widgets | **MEDIUM** | Centralize in `inputDecorationTheme`, `cardTheme`, or UI Kit primitives.

|

---

## Agent Verification Checklist

When creating or modifying UI components or theme rules:

1. **Zero Hardcoded Styles:** Confirm zero direct `Color(...)` or `TextStyle(...)` allocations exist in UI widgets.

2. **Context Extension Usage:** Confirm theme reading uses `context.colorScheme`, `context.textTheme`, or `context.customColors`.

3. **Dual Palette Parity:** Ensure every token in `_lightCustomColors` exists in `_darkCustomColors`.

4. **Global Defaults:** Confirm form fields, buttons, and cards rely on global component themes before adding local overrides.
