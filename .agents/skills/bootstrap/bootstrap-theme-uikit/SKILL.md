---
name: bootstrap-theme-uikit
description: Generates a complete Material 3 Theme with primary color #FFDE3F (Light & Dark ColorScheme, TextTheme, AppCustomColors ThemeExtension), an injectable Hydrated ThemeCubit for persistent theme mode switching, and an interactive adaptive UiKitPage showcase landing displaying all core UI widgets. Use when generating project theming and the design system showcase.
---

# Material 3 Theme (#FFDE3F) & UiKit Showcase Scaffolding

## 1. Overview & When to Apply

Use this skill during the theming and presentation scaffolding phase:
- Generating dynamic **Light** and **Dark** Material 3 themes centered around primary brand color `#FFDE3F`.
- Implementing `AppCustomColors` `ThemeExtension` with custom domain tokens.
- Creating an `@injectable` `ThemeCubit` (`HydratedCubit<ThemeState>`) with serialization separated into `hydrated_theme_cubit.mixin.dart`.
- Generating an interactive, adaptive `UiKitPage` landing showcase (inspired by Material Theme Builder) rendering all key design system components.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [project-bootstrap-hub](../project-bootstrap-hub/SKILL.md) | Master bootstrapping coordinator. |
| **Theme System** | [flutter-ui-theme-hub](../../presentation/theme/flutter-ui-theme-hub/SKILL.md) | In-depth Material 3 theming guidelines. |
| **Hydrated BLoC** | [flutter-hydrated-bloc](../../presentation/state-management/flutter-hydrated-bloc/SKILL.md) | Mixin extraction for persistent states. |
| **UI Kit Architecture** | [flutter-ui-kit-hub](../../presentation/ui/ui-kit/flutter-ui-kit-hub/SKILL.md) | Pure stateless widget composition standards. |
| **Next Step** | [bootstrap-verification-docs](../bootstrap-verification-docs/SKILL.md) | Code generation, test execution, and runbook documentation. |

---

## 3. Theme Architecture (`lib/presentation/theme/`)

- **Primary Color:** `const Color(0xFFFFDE3F)` (Warm Gold / Vibrant Yellow).
- **Color Scheme Setup:** See [examples/app_color_scheme.dart](examples/app_color_scheme.dart).
- **Custom Tokens ThemeExtension:** See [examples/app_custom_colors.dart](examples/app_custom_colors.dart).
- **ThemeData Assembly (`app_theme.dart`):**
  ```dart
  abstract final class AppTheme {
    static ThemeData get lightTheme => ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: AppColorScheme.light,
      textTheme: AppTextTheme.textTheme,
      extensions: const [AppCustomColors.light],
    );

    static ThemeData get darkTheme => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: AppColorScheme.dark,
      textTheme: AppTextTheme.textTheme,
      extensions: const [AppCustomColors.dark],
    );
  }
  ```

---

## 4. Injectable Hydrated `ThemeCubit` (`lib/presentation/state_management/theme/`)

> [!IMPORTANT]
> **Zero Flutter SDK Imports in BLoC / Cubit:**
> `ThemeCubit`, `ThemeState`, and `HydratedThemeCubitMixin` must NEVER import `package:flutter/material.dart` (enforced by `avoid_flutter_imports`). Map to Flutter types in UI via `AppThemeModeX.toFlutter()`.

- **Complete Implementation Guide & Code:** See [examples/theme_cubit_bundle.dart](examples/theme_cubit_bundle.dart) covering:
  1. Pure Dart `AppThemeMode` & `ThemeState` (`theme_state.dart`).
  2. Isolated serialization `HydratedThemeCubitMixin` (`hydrated_theme_cubit.mixin.dart`).
  3. `@lazySingleton` `ThemeCubit` (`theme_cubit.dart`).
  4. Presentation extension `AppThemeModeX` (`app_theme_mode_extension.dart`).

---

## 5. Adaptive `UiKitPage` Showcase (`lib/presentation/pages/uikit/`)

Create an interactive landing showcase rendering all design tokens and UI Kit components:

```text
lib/presentation/pages/uikit/
├── uikit_page.dart
└── widgets/
    ├── uikit_header_section.dart
    ├── uikit_color_palette_section.dart
    ├── uikit_typography_section.dart
    ├── uikit_buttons_section.dart
    ├── uikit_inputs_section.dart
    ├── uikit_surfaces_section.dart
    └── uikit_feedback_section.dart
```

### Showcase Sections Breakdown:
1. **Header & Theme Switcher:** Displays app name, environment badge (`dev`/`stage`/`prod`), and `SegmentedButton<ThemeMode>`.
2. **Color Palette Section:** Swatches for `primary`, `secondary`, `tertiary`, `surface`, `error`, and custom tokens `success`, `warning`, `info`.
3. **Typography Scale:** Sample text for `displayLarge`, `headlineMedium`, `titleMedium`, `bodyLarge`, `labelSmall`.
4. **Buttons & Actions:** Interactive `FilledButton`, `ElevatedButton`, `FilledTonalButton`, `OutlinedButton`, `TextButton`, `IconButton`.
5. **Form Controls:** `ReactiveForm` with text inputs, password toggle, email validation, dropdown, date picker, checkbox/switch.
6. **Cards & Surfaces:** Elevated cards, outlined cards, varying corner radii and surface tints.
7. **Badges, Chips & Feedback:** Status chips, action chips, badges, and snackbar/dialog triggers.

---

## 6. Verification Checklist

- [ ] Material 3 Theme configured with primary color `#FFDE3F`.
- [ ] Light and Dark `ThemeData` instances verified with distinct ColorSchemes.
- [ ] `AppCustomColors` `ThemeExtension` registered.
- [ ] `ThemeCubit` annotated with `@lazySingleton` and tested with `HydratedStorage`.
- [ ] `UiKitPage` renders all component sections without layout overflow.
- [ ] Ready to proceed to [bootstrap-verification-docs](../bootstrap-verification-docs/SKILL.md).
