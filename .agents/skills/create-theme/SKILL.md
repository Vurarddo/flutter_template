---
name: create-theme
description: Scaffolds a complete, production-ready Flutter Material 3 theming system with modular files. Use when the user invokes /create-theme, asks to generate a new theme, setup app themes, or scaffold theme boilerplate files (AppTheme, AppColorScheme, AppTextTheme, AppCustomColors).
---

# Create Theme Workflow (`/create-theme`)

## 1. Overview & When to Apply

Use this skill whenever:
- The user runs `/create-theme` or asks to generate/scaffold a new theming system.
- Setting up the standard modular architecture under `lib/presentation/theme/`.
- Generating default Material 3 tokens, light/dark palettes, typography, and `ThemeExtension` boilerplate.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Theme Coordinator** | [flutter-ui-theme-hub](../ui/theme/flutter-ui-theme-hub/SKILL.md) | Theming architecture guidelines and conventions. |
| **Theme Colors** | [flutter-ui-theme-colors](../ui/theme/flutter-ui-theme-colors/SKILL.md) | Material 3 ColorScheme specifications. |
| **Theme Typography** | [flutter-ui-theme-typography](../ui/theme/flutter-ui-theme-typography/SKILL.md) | TextTheme scales and custom font setup. |
| **Theme Extensions** | [flutter-ui-theme-extensions](../ui/theme/flutter-ui-theme-extensions/SKILL.md) | Custom domain tokens and ThemeExtension patterns. |

---

## 3. Scaffolding Step-by-Step Recipe

When `/create-theme` is invoked, execute these steps in order:

### Step 1: Create `lib/presentation/theme/app_color_scheme.dart`
Define `AppColorScheme.light` and `AppColorScheme.dark` with all Material 3 semantic roles (`primary`, `surface`, `error`, `surfaceContainer*`, `outline*`).

### Step 2: Create `lib/presentation/theme/app_text_theme.dart`
Define `AppTextTheme.createTextTheme(ColorScheme colorScheme)` using `FontFamily` from `lib/presentation/ui_utils/assets/fonts.gen.dart` and 15 Material 3 typography tokens.

### Step 3: Create `lib/presentation/theme/app_custom_colors.dart`
Define `AppCustomColors extends ThemeExtension<AppCustomColors>` with:
- Non-nullable fields (`cardBorder`, `secondaryText`, `shimmerBase`, `surfaceElevated`, `ratingBackground`, `ratingGold`, `success`, `warning`, `info`).
- `static const AppCustomColors light` and `dark`.
- `copyWith` and `lerp` implementations.

### Step 4: Create `lib/presentation/theme/app_theme.dart`
Assemble `AppTheme.light` and `AppTheme.dark`:
- Set `useMaterial3: true`.
- Pass `colorScheme`, `textTheme`, `extensions: [customColors]`.
- Configure M3 component themes (`appBarTheme`, `cardTheme`, `dividerTheme`, `elevatedButtonTheme`, `inputDecorationTheme`).

### Step 5: Verify Context Extensions & App Integration
Ensure `lib/presentation/ui_utils/extensions/context_extensions.dart` provides:
```dart
extension ContextThemeExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  AppCustomColors get customColors =>
      theme.extension<AppCustomColors>() ?? AppCustomColors.light;
}
```
And `lib/application.dart` configures:
```dart
MaterialApp.router(
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
  themeMode: ThemeMode.system,
  ...
);
```

### Step 6: Validate via Static Analysis
Run `dart analyze` to verify clean compilation with zero warnings or errors.

---

## 4. Verification Checklist

- [ ] All 4 modular theme files exist under `lib/presentation/theme/`.
- [ ] No file exceeds 150–200 lines.
- [ ] `dart analyze` reports zero issues.
