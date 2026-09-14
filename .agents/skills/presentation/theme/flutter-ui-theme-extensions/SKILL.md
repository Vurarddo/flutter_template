---
name: flutter-ui-theme-extensions
description: Custom ThemeExtension and domain design token skill. Use when creating or modifying AppCustomColors, defining domain-specific tokens (shimmer colors, borders, badges, status colors, gradients), implementing lerp and copyWith, or configuring BuildContext theme extensions.
---

# Flutter UI Theme Extensions & Custom Tokens Guide

## 1. Overview & When to Apply

Use this skill whenever:
- Creating or extending `AppCustomColors` in `lib/presentation/theme/app_custom_colors.dart`.
- Defining domain-specific or UI-specific design tokens not covered by standard `ColorScheme` (e.g. `cardBorder`, `secondaryText`, `shimmerBase`, `surfaceElevated`, `success`, `warning`, `info`).
- Implementing `ThemeExtension<T>` with immutable fields, `copyWith`, and proper linear interpolation (`lerp`).
- Accessing custom tokens in widgets via `context.customColors`.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Theme Hub** | [flutter-ui-theme-hub](../flutter-ui-theme-hub/SKILL.md) | Central theming architecture and modular layout. |
| **Theme Colors** | [flutter-ui-theme-colors](../flutter-ui-theme-colors/SKILL.md) | Aligning custom tokens with ColorScheme palettes. |
| **Material 3 Components** | [flutter-ui-material](../../ui/flutter-ui-material/SKILL.md) | Using custom tokens inside UI components. |

---

## 3. Core ThemeExtension Rules

1. **Immutable Fields:** All token properties must be `final Color`.
2. **Dual Palettes:** Define `static const AppCustomColors light` and `dark` instances.
3. **Accurate `lerp()`:** Implement `Color.lerp()` for smooth animated theme transitions.
4. **Context Accessor:** Access tokens strictly via `context.customColors` (never `Theme.of(context).extension<AppCustomColors>()!` directly).

---

## 4. Reference Implementation (`examples/`)

- **Standard `AppCustomColors` Extension:** [examples/custom_theme_extension.dart](examples/custom_theme_extension.dart)
  - Full template with light/dark values, `copyWith`, and `lerp`.

---

## 5. Verification Checklist

- [ ] `AppCustomColors` extends `ThemeExtension<AppCustomColors>`.
- [ ] Both `light` and `dark` palettes are provided.
- [ ] `copyWith()` and `lerp()` properly handle all fields.
- [ ] Registered in `ThemeData.extensions` in `AppTheme`.
