---
name: flutter-ui-material
description: Material 3 Design System implementation skill enforcing ColorScheme dynamic generation, ThemeData (Light and Dark), component themes (InputDecorationTheme, CardTheme, FilledButtonTheme), and custom ThemeExtensions for domain tokens. Use when building M3 UI widgets, configuring themes, or styling components.
---

# Material 3 Design System & Dynamic Theming Guide

## 1. Overview & When to Apply

Use this skill whenever:
- Implementing or styling Material 3 components (`FilledButton`, `Card`, `SegmentedButton`, `NavigationBar`, `Badge`, `FloatingActionButton`).
- Accessing design tokens (`context.colorScheme`, `context.textTheme`, `context.customColors`).
- Configuring `ThemeData` for both Light and Dark modes.
- Defining custom design tokens (e.g. trading status badges, gradients) using `ThemeExtension`.
- Setting up component themes (`inputDecorationTheme`, `cardTheme`, `appBarTheme`).

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Theme Coordinator** | [flutter-ui-theme-hub](../../theme/flutter-ui-theme-hub/SKILL.md) | Modular theme system (`AppTheme`, `AppColorScheme`, `AppTextTheme`, `AppCustomColors`). |
| **Theme Colors** | [flutter-ui-theme-colors](../../theme/flutter-ui-theme-colors/SKILL.md) | Material 3 ColorScheme specifications & palettes. |
| **Theme Typography** | [flutter-ui-theme-typography](../../theme/flutter-ui-theme-typography/SKILL.md) | TextTheme scales and custom font setup. |
| **Theme Extensions** | [flutter-ui-theme-extensions](../../theme/flutter-ui-theme-extensions/SKILL.md) | Custom domain tokens and ThemeExtension patterns. |
| **Parent Hub** | [flutter-ui-hub](../flutter-ui-hub/SKILL.md) | Presentation rules and UI standards. |
| **Cupertino** | [flutter-ui-cupertino](../flutter-ui-cupertino/SKILL.md) | iOS platform comparisons & adaptive widgets. |
| **Previews** | [flutter-ui-kit-preview](../ui-kit/flutter-ui-kit-preview/SKILL.md) | Dual-theme preview verification (Light & Dark). |

---

## 3. Theme Configuration Standards

### 3.1 Custom `ThemeExtension` for Domain Tokens

```dart
@immutable
class AppCustomColors extends ThemeExtension<AppCustomColors> {
  final Color success;
  final Color warning;
  final Color info;

  const AppCustomColors({
    required this.success,
    required this.warning,
    required this.info,
  });

  @override
  AppCustomColors copyWith({Color? success, Color? warning, Color? info}) {
    return AppCustomColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  AppCustomColors lerp(ThemeExtension<AppCustomColors>? other, double t) {
    if (other is! AppCustomColors) return this;
    return AppCustomColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }

  static const light = AppCustomColors(
    success: Color(0xFF2E7D32),
    warning: Color(0xFFED6C02),
    info: Color(0xFF0288D1),
  );

  static const dark = AppCustomColors(
    success: Color(0xFF66BB6A),
    warning: Color(0xFFFFA726),
    info: Color(0xFF29B6F6),
  );
}
```

### 3.2 Dynamic `ThemeData` Setup

```dart
class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E88E5),
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: const [AppCustomColors.light],
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E88E5),
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: const [AppCustomColors.dark],
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
```

---

## 4. UI Component Token Access Standard

Always use `context.colorScheme` and `context.textTheme`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_template/presentation/ui_utils/extensions/context_extensions.dart';

class FeatureCard extends StatelessWidget {
  final String title;
  final String description;

  const FeatureCard({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Card(
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text(description, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
```

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Hardcoded colors (`Color(0xFF...)`) in widgets | **CRITICAL** | Access via `context.colorScheme` or `context.customColors`. |
| Hardcoded text styles with fixed colors | **HIGH** | Use `context.textTheme` with `.copyWith(color: ...)`. |
| Missing Dark theme support in custom tokens | **HIGH** | Define distinct light/dark palettes in `ThemeExtension`. |
| Using deprecated `primaryColor` or `accentColor` | **MEDIUM** | Use `colorScheme.primary` and `colorScheme.secondary`. |

---

## 6. Verification Checklist

- [ ] `useMaterial3: true` is enabled across all `ThemeData` definitions.
- [ ] No raw `Color(...)` values exist inside feature widgets.
- [ ] Both Light and Dark theme palettes are implemented and visually verified.
- [ ] Custom domain tokens are implemented via `ThemeExtension` with `lerp` and `copyWith`.
- [ ] All typography uses `context.textTheme` tokens.
