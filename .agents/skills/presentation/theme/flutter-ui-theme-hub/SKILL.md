---
name: flutter-ui-theme-hub
description: Primary coordinator and architecture guide for Flutter Material 3 theming system. Use when configuring app themes, splitting theme files (AppTheme, AppColorScheme, AppTextTheme, AppCustomColors), setting up Light/Dark modes, or managing theme extensions. Routes to specialized sub-skills for colors, typography, and theme extensions.
---

# Flutter UI Theme Coordinator & Architecture Hub

## 1. Overview & Theming Architecture Principles

This skill coordinates the theming architecture for Flutter applications following Material 3 guidelines and Clean Architecture boundaries. 

Theme configuration is split into focused, single-responsibility modules under `lib/presentation/theme/`:

```text
lib/presentation/theme/
├── app_theme.dart            # Main ThemeData builder (Light & Dark modes, component themes)
├── app_color_scheme.dart     # Material 3 ColorScheme definitions (Light & Dark palettes)
├── app_text_theme.dart       # Material 3 TextTheme configuration with custom fonts
└── app_custom_colors.dart    # ThemeExtension for domain-specific semantic tokens
```

### Core Theming Rules (per `AGENTS.md`):
1. **Material 3 Foundation:** Always enable `useMaterial3: true` and build `ThemeData` driven by `ColorScheme`.
2. **Modular File Separation:** Theme classes must never exceed 150–200 lines. Split colors, typography, extensions, and theme configuration into dedicated files.
3. **No Hardcoded Colors in UI:** Widgets must never use raw `Color(0x...)` or static color classes. All UI colors are accessed strictly via `context.colorScheme` or `context.customColors`.
4. **Mandatory Dual-Theme Support:** Both **Light** and **Dark** themes must be fully supported with distinct semantic tokens.
5. **Type-Safe Theme Extensions:** Custom design tokens (e.g. status badges, shimmer bases, card borders) must be encapsulated in `ThemeExtension` with immutable non-nullable fields, `lerp`, and `copyWith`.

---

## 2. Theme Sub-Skill Tree & Routing Matrix

Use this matrix to navigate to specialized sub-skills matching your theming task:

| Sub-Domain | Target Sub-Skill | When to Activate |
| :--- | :--- | :--- |
| **Color Schemes & Palettes** | [flutter-ui-theme-colors](../flutter-ui-theme-colors/SKILL.md) | Defining `AppColorScheme.light` & `AppColorScheme.dark`, M3 surface containers, outlines, and role mappings. |
| **Typography & Font Management** | [flutter-ui-theme-typography](../flutter-ui-theme-typography/SKILL.md) | Configuring `AppTextTheme`, Material 3 text scales (display, headline, title, body, label), and `FontFamily` setup. |
| **Theme Extensions & Custom Tokens** | [flutter-ui-theme-extensions](../flutter-ui-theme-extensions/SKILL.md) | Creating `AppCustomColors`, implementing `ThemeExtension<T>`, `lerp`, `copyWith`, and domain tokens. |
| **UI Context Extensions** | [flutter-ui-utils-extensions](../../ui-utils/flutter-ui-utils-extensions/SKILL.md) | `BuildContext` helpers (`context.colorScheme`, `context.textTheme`, `context.customColors`, `isDark`). |
| **Parent UI Coordinator** | [flutter-ui-hub](../../ui/flutter-ui-hub/SKILL.md) | Presentation layer laws, widget architecture, responsive layouts, and UI kit integration. |
| **Material 3 Components** | [flutter-ui-material](../../ui/flutter-ui-material/SKILL.md) | Styling M3 widgets (`FilledButton`, `Card`, `NavigationBar`, `InputDecoration`). |

---

## 3. Standard `AppTheme` Implementation Pattern

```dart
import 'package:flutter/material.dart';
import 'package:flutter_template/presentation/theme/app_color_scheme.dart';
import 'package:flutter_template/presentation/theme/app_custom_colors.dart';
import 'package:flutter_template/presentation/theme/app_text_theme.dart';

abstract final class AppTheme {
  static ThemeData get light => _buildTheme(
        colorScheme: AppColorScheme.light,
        customColors: AppCustomColors.light,
      );

  static ThemeData get dark => _buildTheme(
        colorScheme: AppColorScheme.dark,
        customColors: AppCustomColors.dark,
      );

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required AppCustomColors customColors,
  }) {
    final textTheme = AppTextTheme.createTextTheme(colorScheme);

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      extensions: <ThemeExtension<dynamic>>[
        customColors,
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.outlineVariant,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
      ),
    );
  }
}
```

---

## 4. Context Extensions Standard for Theming

All theme data is consumed in widgets via extensions in `lib/presentation/ui_utils/extensions/context_extensions.dart`:

```dart
extension ContextThemeExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;

  AppCustomColors get customColors =>
      theme.extension<AppCustomColors>() ?? AppCustomColors.light;
}
```

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Monolithic theme file with colors, text, and component styles | **HIGH** | Split into `app_color_scheme.dart`, `app_text_theme.dart`, `app_custom_colors.dart`, `app_theme.dart`. |
| Hardcoded colors in UI widgets | **CRITICAL** | Access colors exclusively via `context.colorScheme` or `context.customColors`. |
| Omitting Dark theme support | **CRITICAL** | Provide both `.light` and `.dark` schemes and extensions. |
| Using deprecated `primaryColor` or `accentColor` | **HIGH** | Use Material 3 `colorScheme.primary`, `colorScheme.secondary`. |

---

## 6. Theme Master Verification Checklist

Before completing theme implementation or refactoring:
- [ ] Theme configuration is split into modular files under `lib/presentation/theme/`.
- [ ] Both `AppTheme.light` and `AppTheme.dark` are defined and tested.
- [ ] `AppCustomColors` extends `ThemeExtension<AppCustomColors>` with proper `lerp` and `copyWith`.
- [ ] `useMaterial3: true` is enabled on all `ThemeData` builders.
- [ ] All UI widgets access tokens via `context.colorScheme`, `context.textTheme`, or `context.customColors`.
- [ ] Static analysis passes with `dart analyze` (no issues).
