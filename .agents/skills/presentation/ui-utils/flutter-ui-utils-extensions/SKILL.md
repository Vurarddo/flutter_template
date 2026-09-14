---
name: flutter-ui-utils-extensions
description: Standards and patterns for Flutter and BuildContext UI extensions in lib/presentation/ui_utils/extensions/. Covers context.colorScheme, context.textTheme, context.customColors, media query helpers, safe area insets, and fluent UI widget wrappers.
---

# Flutter UI & Context Extensions

## 1. Overview & When to Apply

Use this skill whenever:
- Adding or refactoring `BuildContext` extensions for theme, typography, color schemes, media query metrics, or localization shortcuts.
- Adding UI widget extension wrappers (e.g. `.unfocusWrapper()`, `.paddingAll()`, `.sliverBox()`).
- Adding `TextStyle` modifier extensions for concise typography adjustments.
- Enforcing the rule that Flutter/UI-specific extensions live in `lib/presentation/ui_utils/extensions/` (while pure Dart extensions live in `lib/core/extensions/`).

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [flutter-ui-utils-hub](../flutter-ui-utils-hub/SKILL.md) | Presentation helper boundaries and directory standards. |
| **Theming System** | [flutter-ui-theme-hub](../../theme/flutter-ui-theme-hub/SKILL.md) | Custom theme extensions and Material 3 ColorSchemes. |
| **Parent UI Coordinator** | [flutter-ui-hub](../../ui/flutter-ui-hub/SKILL.md) | Presentation layer architectural laws and widget decomposition. |

---

## 3. Standard Implementation Patterns & Naming Convention

> [!IMPORTANT]
> **Strict `...X` Naming Convention:**
> ALL public Dart extensions must be suffixed with `X` (e.g. `BuildContextX`, `WidgetX`, `TextStyleX`, `AppThemeModeX`).
> Never use `...Extension` or `...Extensions` (e.g. BAD: `BuildContextExtension`, GOOD: `BuildContextX`).

### 3.1 `BuildContext` Theme & Layout Extensions (`context_extensions.dart`)

```dart
import 'package:flutter/material.dart';

import 'package:flutter_template/presentation/theme/app_custom_colors.dart';

extension BuildContextThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  Brightness get brightness => theme.brightness;
  bool get isDark => brightness == Brightness.dark;

  AppCustomColors get customColors =>
      theme.extension<AppCustomColors>() ?? AppCustomColors.light;
}

extension BuildContextLayoutX on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);
  Orientation get orientation => MediaQuery.orientationOf(this);

  bool get isKeyboardVisible => MediaQuery.viewInsetsOf(this).bottom > 0;
}
```

> [!TIP]
> Always prefer targeted `MediaQuery.sizeOf(context)`, `MediaQuery.viewInsetsOf(context)`, and `MediaQuery.orientationOf(context)` methods (Flutter 3.10+) to avoid unnecessary widget rebuilds when unrelated media query attributes change.

---

### 3.2 Fluent Widget Extensions (`widget_extensions.dart`)

```dart
import 'package:flutter/material.dart';

extension WidgetX on Widget {
  /// Wraps a widget in a GestureDetector that dismisses the keyboard when tapped outside.
  Widget unfocusWrapper() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: this,
    );
  }

  /// Converts a standard Box widget into a SliverToBoxAdapter.
  Widget toSliver() => SliverToBoxAdapter(child: this);

  /// Conditionally displays a widget.
  Widget visible(bool isVisible, {Widget defaultWidget = const SizedBox.shrink()}) {
    return isVisible ? this : defaultWidget;
  }
}
```

---

### 3.3 `TextStyle` Modifier Extensions (`text_style_extensions.dart`)

```dart
import 'package:flutter/material.dart';

extension TextStyleX on TextStyle {
  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle withOpacity(double opacity) => copyWith(color: color?.withValues(alpha: opacity));
  TextStyle withWeight(FontWeight weight) => copyWith(fontWeight: weight);
  TextStyle withSize(double size) => copyWith(fontSize: size);
  TextStyle withHeight(double height) => copyWith(height: height);
}
```

---

## 4. Location Strategy: UI Extensions vs Core Extensions

- **`lib/presentation/ui_utils/extensions/`:** Extensions that require `package:flutter/...` (`BuildContext`, `Widget`, `Color`, `TextStyle`, `EdgeInsets`, `BoxDecoration`).
- **`lib/core/extensions/`:** Pure Dart extensions (`DateTime`, `String`, `num`, `Iterable`, `Map`) with **zero Flutter SDK imports**.

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Naming extension `BuildContextExtension` or `ThemeExtensions` | **HIGH** | Use `X` suffix: `BuildContextThemeX`, `BuildContextLayoutX`, `WidgetX`. |
| Verbose `Theme.of(context).colorScheme.primary` in UI code | **MEDIUM** | Use `context.colorScheme.primary`. |
| Using `MediaQuery.of(context).size` when only size is needed | **HIGH** | Use `MediaQuery.sizeOf(context)` or `context.screenSize`. |
| Placing pure Dart extensions (e.g. `DateTime.isToday`) in `ui_utils/extensions/` | **HIGH** | Move to `lib/core/extensions/date_time_extensions.dart`. |
| Placing `BuildContext` extensions in `lib/core/extensions/` | **CRITICAL** | Core layer must not import Flutter SDK. Move to `presentation/ui_utils/extensions/`. |

---

## 6. Verification Checklist

- [ ] All public extensions use the `...X` suffix.
- [ ] All UI extensions are located in `lib/presentation/ui_utils/extensions/`.
- [ ] No `Theme.of(context)` calls remain in feature UI files; replaced with `context.colorScheme`, `context.textTheme`, etc.
- [ ] Selective MediaQuery methods (`sizeOf`, `viewInsetsOf`) are used to prevent rebuild churn.
- [ ] Extension files are strictly under 150–200 lines each.
