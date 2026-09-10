---
name: flutter-ui-theme-colors
description: Material 3 ColorScheme design tokens and palette construction skill. Use when creating or modifying AppColorScheme, setting up Light/Dark ColorScheme palettes, mapping semantic color roles (primary, secondary, tertiary, surface, error, surface containers, outlines), or tuning contrast.
---

# Flutter UI Theme Colors & ColorScheme Guide

## 1. Overview & When to Apply

Use this skill whenever:
- Defining or editing `AppColorScheme.light` and `AppColorScheme.dark` in `lib/presentation/theme/app_color_scheme.dart`.
- Configuring Material 3 color roles (`primary`, `secondary`, `tertiary`, `surface`, `error`, `outline`, `scrim`).
- Implementing M3 surface elevation containers (`surfaceDim`, `surfaceBright`, `surfaceContainerLowest`, `surfaceContainerLow`, `surfaceContainer`, `surfaceContainerHigh`, `surfaceContainerHighest`).
- Ensuring WCAG accessible contrast between background and foreground (`onPrimary`, `onSurface`, `onSurfaceVariant`, etc.).

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Theme Hub** | [flutter-ui-theme-hub](../flutter-ui-theme-hub/SKILL.md) | Central theming architecture and modular layout. |
| **Theme Extensions** | [flutter-ui-theme-extensions](../flutter-ui-theme-extensions/SKILL.md) | Domain tokens that don't fit standard ColorScheme roles. |
| **Material 3 Components** | [flutter-ui-material](../../ui/flutter-ui-material/SKILL.md) | Applying colors to M3 UI widgets. |

---

## 3. Material 3 Color Roles Matrix

Material 3 defines explicit semantic pairs. Every colored background MUST use its matching `on*` color for text and icons:

| Color Role | Purpose | On-Role (Text/Icon) | Container Role | On-Container Role |
| :--- | :--- | :--- | :--- | :--- |
| **Primary** | Key branding, main CTA buttons, active state | `onPrimary` | `primaryContainer` | `onPrimaryContainer` |
| **Secondary** | Secondary actions, filter chips, badges | `onSecondary` | `secondaryContainer` | `onSecondaryContainer` |
| **Tertiary** | Accent highlights, balancing accents | `onTertiary` | `tertiaryContainer` | `onTertiaryContainer` |
| **Error** | Critical alerts, validation errors | `onError` | `errorContainer` | `onErrorContainer` |
| **Surface** | Page background, card/dialog backgrounds | `onSurface` | `surfaceContainer*` | `onSurfaceVariant` |
| **Outline** | Distinct borders, separators | `outline` | `outlineVariant` | Subtle borders |

---

## 4. Standard Implementation Pattern (`app_color_scheme.dart`)

```dart
import 'package:flutter/material.dart';

abstract final class AppColorScheme {
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xff003d3f),
    surfaceTint: Color(0xff00696c),
    onPrimary: Color(0xffffffff),
    primaryContainer: Color(0xff16797c),
    onPrimaryContainer: Color(0xffffffff),
    secondary: Color(0xff213a3b),
    onSecondary: Color(0xffffffff),
    secondaryContainer: Color(0xff587273),
    onSecondaryContainer: Color(0xffffffff),
    tertiary: Color(0xff243752),
    onTertiary: Color(0xffffffff),
    tertiaryContainer: Color(0xff5c6e8c),
    onTertiaryContainer: Color(0xffffffff),
    error: Color(0xff740006),
    onError: Color(0xffffffff),
    errorContainer: Color(0xffcf2c27),
    onErrorContainer: Color(0xffffffff),
    surface: Color(0xfff4fbfa),
    onSurface: Color(0xff0c1212),
    onSurfaceVariant: Color(0xff2e3838),
    outline: Color(0xff4b5454),
    outlineVariant: Color(0xff656f6f),
    shadow: Color(0xff000000),
    scrim: Color(0xff000000),
    inverseSurface: Color(0xff2b3232),
    inversePrimary: Color(0xff80d4d7),
    primaryFixed: Color(0xff16797c),
    onPrimaryFixed: Color(0xffffffff),
    primaryFixedDim: Color(0xff005f62),
    onPrimaryFixedVariant: Color(0xffffffff),
    secondaryFixed: Color(0xff587273),
    onSecondaryFixed: Color(0xffffffff),
    secondaryFixedDim: Color(0xff40595a),
    onSecondaryFixedVariant: Color(0xffffffff),
    tertiaryFixed: Color(0xff5c6e8c),
    onTertiaryFixed: Color(0xffffffff),
    tertiaryFixedDim: Color(0xff435672),
    onTertiaryFixedVariant: Color(0xffffffff),
    surfaceDim: Color(0xffc1c8c7),
    surfaceBright: Color(0xfff4fbfa),
    surfaceContainerLowest: Color(0xffffffff),
    surfaceContainerLow: Color(0xffeff5f4),
    surfaceContainer: Color(0xffe3e9e9),
    surfaceContainerHigh: Color(0xffd8dede),
    surfaceContainerHighest: Color(0xffccd3d3),
  );

  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xff96eaee),
    surfaceTint: Color(0xff80d4d7),
    onPrimary: Color(0xff002b2c),
    primaryContainer: Color(0xff479da1),
    onPrimaryContainer: Color(0xff000000),
    secondary: Color(0xffc6e2e2),
    onSecondary: Color(0xff10292a),
    secondaryContainer: Color(0xff7b9696),
    onSecondaryContainer: Color(0xff000000),
    tertiary: Color(0xffcbddff),
    onTertiary: Color(0xff132640),
    tertiaryContainer: Color(0xff7f92b1),
    onTertiaryContainer: Color(0xff000000),
    error: Color(0xffffd2cc),
    onError: Color(0xff540003),
    errorContainer: Color(0xffff5449),
    onErrorContainer: Color(0xff000000),
    surface: Color(0xff0e1415),
    onSurface: Color(0xffffffff),
    onSurfaceVariant: Color(0xffd4dede),
    outline: Color(0xffaab4b4),
    outlineVariant: Color(0xff889292),
    shadow: Color(0xff000000),
    scrim: Color(0xff000000),
    inverseSurface: Color(0xffdde4e3),
    inversePrimary: Color(0xff005153),
    primaryFixed: Color(0xff9cf1f4),
    onPrimaryFixed: Color(0xff001415),
    primaryFixedDim: Color(0xff80d4d7),
    onPrimaryFixedVariant: Color(0xff003d3f),
    secondaryFixed: Color(0xffcce8e8),
    onSecondaryFixed: Color(0xff001415),
    secondaryFixedDim: Color(0xffb0cccc),
    onSecondaryFixedVariant: Color(0xff213a3b),
    tertiaryFixed: Color(0xffd5e3ff),
    onTertiaryFixed: Color(0xff001129),
    tertiaryFixedDim: Color(0xffb5c7e9),
    onTertiaryFixedVariant: Color(0xff243752),
    surfaceDim: Color(0xff0e1415),
    surfaceBright: Color(0xff3f4646),
    surfaceContainerLowest: Color(0xff040808),
    surfaceContainerLow: Color(0xff181f1f),
    surfaceContainer: Color(0xff232929),
    surfaceContainerHigh: Color(0xff2d3434),
    surfaceContainerHighest: Color(0xff383f3f),
  );
}
```

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Hardcoding `Color(0x...)` directly inside UI widgets | **CRITICAL** | Access colors via `context.colorScheme.<role>`. |
| Mismatched foreground/background (e.g. `onPrimary` on `surface`) | **HIGH** | Always pair surfaces with their designated `on*` color token. |
| Missing `brightness` configuration on ColorScheme | **HIGH** | Explicitly provide `brightness: Brightness.light` or `.dark`. |
| Leaving container roles undefined | **MEDIUM** | Define all Material 3 container tokens (`surfaceContainer*`). |

---

## 6. Verification Checklist

- [ ] `AppColorScheme` defines both `light` and `dark` constants.
- [ ] Contrast ratio between background and `on*` tokens meets WCAG AA standards (≥ 4.5:1).
- [ ] No hardcoded colors exist in widgets; all colors reference `context.colorScheme`.
- [ ] Package imports are strictly used (`import 'package:flutter_template/...';`).
