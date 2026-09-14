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
- Generating an interactive, adaptive `UiKitPage` landing showcase (inspired by Material Theme Builder) rendering all key design system components: Color Palette, Typography, Buttons, Form Inputs, Cards, Badges, Modals, and live ThemeMode switching.

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

### 3.1 Primary Brand Color & Seed
- **Primary Color:** `const Color(0xFFFFDE3F)` (Warm Gold / Vibrant Yellow).

### 3.2 Color Scheme Setup (`lib/presentation/theme/app_color_scheme.dart`)

```dart
import 'package:flutter/material.dart';

abstract final class AppColorScheme {
  static const Color primarySeed = Color(0xFFFFDE3F);

  static final ColorScheme light = ColorScheme.fromSeed(
    seedColor: primarySeed,
    brightness: Brightness.light,
    primary: primarySeed,
    onPrimary: const Color(0xFF221B00),
    primaryContainer: const Color(0xFFFFE264),
    onPrimaryContainer: const Color(0xFF241A00),
    surface: const Color(0xFFFFFBF0),
    onSurface: const Color(0xFF1E1B16),
  );

  static final ColorScheme dark = ColorScheme.fromSeed(
    seedColor: primarySeed,
    brightness: Brightness.dark,
    primary: primarySeed,
    onPrimary: const Color(0xFF3B2F00),
    primaryContainer: const Color(0xFF554400),
    onPrimaryContainer: const Color(0xFFFFE264),
    surface: const Color(0xFF16130E),
    onSurface: const Color(0xFFE9E1D8),
  );
}
```

### 3.3 Custom Tokens Extension (`lib/presentation/theme/app_custom_colors.dart`)

```dart
import 'package:flutter/material.dart';

@immutable
class AppCustomColors extends ThemeExtension<AppCustomColors> {
  final Color success;
  final Color warning;
  final Color info;
  final Color shimmerBase;
  final Color shimmerHighlight;

  const AppCustomColors({
    required this.success,
    required this.warning,
    required this.info,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  static const AppCustomColors light = AppCustomColors(
    success: Color(0xFF2E7D32),
    warning: Color(0xFFED6C02),
    info: Color(0xFF0288D1),
    shimmerBase: Color(0xFFE0E0E0),
    shimmerHighlight: Color(0xFFF5F5F5),
  );

  static const AppCustomColors dark = AppCustomColors(
    success: Color(0xFF66BB6A),
    warning: Color(0xFFFFA726),
    info: Color(0xFF29B6F6),
    shimmerBase: Color(0xFF2C2C2C),
    shimmerHighlight: Color(0xFF3D3D3D),
  );

  @override
  AppCustomColors copyWith({
    Color? success,
    Color? warning,
    Color? info,
    Color? shimmerBase,
    Color? shimmerHighlight,
  }) {
    return AppCustomColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    );
  }

  @override
  AppCustomColors lerp(ThemeExtension<AppCustomColors>? other, double t) {
    if (other is! AppCustomColors) return this;
    return AppCustomColors(
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      info: Color.lerp(info, other.info, t) ?? info,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t) ?? shimmerBase,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t) ?? shimmerHighlight,
    );
  }
}
```

### 3.4 Main Theme Factory (`lib/presentation/theme/app_theme.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_template/presentation/theme/app_color_scheme.dart';
import 'package:flutter_template/presentation/theme/app_custom_colors.dart';
import 'package:flutter_template/presentation/theme/app_text_theme.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: AppColorScheme.light,
      textTheme: AppTextTheme.textTheme,
      extensions: const [AppCustomColors.light],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: AppColorScheme.dark,
      textTheme: AppTextTheme.textTheme,
      extensions: const [AppCustomColors.dark],
    );
  }
}
```

---

## 4. Injectable Hydrated `ThemeCubit` (`lib/presentation/state-management/theme/`)

### 4.1 State (`theme_state.dart`)
```dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

final class ThemeState extends Equatable {
  final ThemeMode themeMode;

  const ThemeState({this.themeMode = ThemeMode.system});

  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(themeMode: themeMode ?? this.themeMode);
  }

  @override
  List<Object?> get props => [themeMode];
}
```

### 4.2 Serialization Mixin (`hydrated_theme_cubit.mixin.dart`)
```dart
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:flutter_template/presentation/state-management/theme/theme_state.dart';

mixin HydratedThemeCubitMixin on HydratedMixin<ThemeState> {
  @override
  String get storagePrefix => 'ThemeCubit';

  @override
  ThemeState fromJson(Map<String, dynamic> json) {
    try {
      final index = json['themeModeIndex'] as int?;
      return ThemeState(
        themeMode: index != null ? ThemeMode.values[index] : ThemeMode.system,
      );
    } catch (_) {
      return const ThemeState(themeMode: ThemeMode.system);
    }
  }

  @override
  Map<String, dynamic> toJson(ThemeState state) {
    return {'themeModeIndex': state.themeMode.index};
  }
}
```

### 4.3 Cubit Implementation (`theme_cubit.dart`)
```dart
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_template/presentation/state-management/theme/hydrated_theme_cubit.mixin.dart';
import 'package:flutter_template/presentation/state-management/theme/theme_state.dart';

@lazySingleton
class ThemeCubit extends HydratedCubit<ThemeState> with HydratedThemeCubitMixin {
  ThemeCubit() : super(const ThemeState());

  void setThemeMode(ThemeMode mode) {
    emit(state.copyWith(themeMode: mode));
  }

  void toggleTheme() {
    final next = switch (state.themeMode) {
      ThemeMode.system || ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
    };
    emit(state.copyWith(themeMode: next));
  }
}
```

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
1. **Header & Theme Switcher:** Displays app name, environment badge (`dev`/`stage`/`prod`), and a `SegmentedButton<ThemeMode>` (System / Light / Dark).
2. **Color Palette Section:** Renders color swatches for `primary`, `secondary`, `tertiary`, `surface`, `error`, `primaryContainer`, plus custom tokens `success`, `warning`, `info`.
3. **Typography Scale:** Renders sample text for `displayLarge`, `headlineMedium`, `titleMedium`, `bodyLarge`, `labelSmall`.
4. **Buttons & Actions:** Renders interactive `FilledButton`, `ElevatedButton`, `FilledTonalButton`, `OutlinedButton`, `TextButton`, and `IconButton`.
5. **Form Controls:** Renders `ReactiveForm` with text inputs, password toggle, email validation, dropdown selection, date picker, and checkbox/switch.
6. **Cards & Surfaces:** Renders elevated cards, outlined cards, and containers with varying corner radii and surface tints.
7. **Badges, Chips & Feedback:** Renders status chips, action chips, badges, and snackbar/dialog triggers.

---

## 6. Verification Checklist

- [ ] Material 3 Theme configured with primary color `#FFDE3F`.
- [ ] Light and Dark `ThemeData` instances verified with distinct ColorSchemes.
- [ ] `AppCustomColors` `ThemeExtension` registered.
- [ ] `ThemeCubit` annotated with `@lazySingleton` and tested with `HydratedStorage`.
- [ ] `UiKitPage` renders all component sections without layout overflow.
- [ ] Ready to proceed to [bootstrap-verification-docs](../bootstrap-verification-docs/SKILL.md).
