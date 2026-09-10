---
name: flutter-ui-theme-extensions
description: Custom ThemeExtension and domain design token skill. Use when creating or modifying AppCustomColors, defining domain-specific tokens (shimmer colors, borders, badges, status colors, gradients), implementing lerp and copyWith, or configuring BuildContext theme extensions.
---

# Flutter UI Theme Extensions & Custom Tokens Guide

## 1. Overview & When to Apply

Use this skill whenever:
- Creating or extending `AppCustomColors` in `lib/presentation/theme/app_custom_colors.dart`.
- Defining domain-specific or UI-specific design tokens not covered by standard `ColorScheme` (e.g. `cardBorder`, `secondaryText`, `shimmerBase`, `surfaceElevated`, `ratingBackground`, `ratingGold`, `success`, `warning`, `info`).
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

## 3. Standard Implementation Pattern (`app_custom_colors.dart`)

```dart
import 'package:flutter/material.dart';

class AppCustomColors extends ThemeExtension<AppCustomColors> {
  final Color cardBorder;
  final Color secondaryText;
  final Color shimmerBase;
  final Color surfaceElevated;
  final Color ratingBackground;
  final Color ratingGold;
  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color info;
  final Color onInfo;

  const AppCustomColors({
    required this.cardBorder,
    required this.secondaryText,
    required this.shimmerBase,
    required this.surfaceElevated,
    required this.ratingBackground,
    required this.ratingGold,
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
  });

  static const AppCustomColors light = AppCustomColors(
    cardBorder: Color(0xffbec8c8),
    secondaryText: Color(0xff3f4949),
    shimmerBase: Color(0xffe3e9e9),
    surfaceElevated: Color(0xffffffff),
    ratingBackground: Color(0xff213a3b),
    ratingGold: Color(0xffffb703),
    success: Color(0xff2e7d32),
    onSuccess: Color(0xffffffff),
    warning: Color(0xffed6c02),
    onWarning: Color(0xffffffff),
    info: Color(0xff0288d1),
    onInfo: Color(0xffffffff),
  );

  static const AppCustomColors dark = AppCustomColors(
    cardBorder: Color(0xff2d3434),
    secondaryText: Color(0xffaab4b4),
    shimmerBase: Color(0xff232929),
    surfaceElevated: Color(0xff181f1f),
    ratingBackground: Color(0xff10292a),
    ratingGold: Color(0xffffc107),
    success: Color(0xff66bb6a),
    onSuccess: Color(0xff003300),
    warning: Color(0xffffffa726),
    onWarning: Color(0xff3e2723),
    info: Color(0xff29b6f6),
    onInfo: Color(0xff001e3c),
  );

  @override
  AppCustomColors copyWith({
    Color? cardBorder,
    Color? secondaryText,
    Color? shimmerBase,
    Color? surfaceElevated,
    Color? ratingBackground,
    Color? ratingGold,
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
  }) {
    return AppCustomColors(
      cardBorder: cardBorder ?? this.cardBorder,
      secondaryText: secondaryText ?? this.secondaryText,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      ratingBackground: ratingBackground ?? this.ratingBackground,
      ratingGold: ratingGold ?? this.ratingGold,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
    );
  }

  @override
  AppCustomColors lerp(ThemeExtension<AppCustomColors>? other, double t) {
    if (other is! AppCustomColors) {
      return this;
    }
    return AppCustomColors(
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t) ?? cardBorder,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t) ?? secondaryText,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t) ?? shimmerBase,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t) ?? surfaceElevated,
      ratingBackground: Color.lerp(ratingBackground, other.ratingBackground, t) ?? ratingBackground,
      ratingGold: Color.lerp(ratingGold, other.ratingGold, t) ?? ratingGold,
      success: Color.lerp(success, other.success, t) ?? success,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t) ?? onSuccess,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      onWarning: Color.lerp(onWarning, other.onWarning, t) ?? onWarning,
      info: Color.lerp(info, other.info, t) ?? info,
      onInfo: Color.lerp(onInfo, other.onInfo, t) ?? onInfo,
    );
  }
}
```

---

## 4. UI Usage Standard

Always access custom tokens via `context.customColors`:

```dart
class RatingBadge extends StatelessWidget {
  final double rating;

  const RatingBadge({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: customColors.ratingBackground,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 16, color: customColors.ratingGold),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: context.textTheme.labelMedium?.copyWith(
              color: customColors.ratingGold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Nullable fields in `ThemeExtension` causing UI null checks | **HIGH** | Use non-nullable `final Color` fields with fallback in `lerp`. |
| Omitting `lerp` or `copyWith` overrides | **HIGH** | Always implement smooth color interpolation in `lerp`. |
| Missing fallback in `context_extensions.dart` | **MEDIUM** | Provide `theme.extension<AppCustomColors>() ?? AppCustomColors.light`. |

---

## 6. Verification Checklist

- [ ] All custom tokens are defined for both `AppCustomColors.light` and `AppCustomColors.dark`.
- [ ] Fields are non-nullable and immutable.
- [ ] `copyWith` and `lerp` correctly handle all tokens.
- [ ] Registered in `AppTheme.light` and `AppTheme.dark` under `extensions: [...]`.
