import 'package:flutter/material.dart';
import 'package:flutter_template/presentation/theme/app_colors.dart';

@immutable
class AppCustomColors extends ThemeExtension<AppCustomColors> {
  final Color ratingGold;
  final Color ratingBackground;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color cardBorder;
  final Color secondaryText;
  final Color surfaceElevated;

  const AppCustomColors({
    required this.ratingGold,
    required this.ratingBackground,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.cardBorder,
    required this.secondaryText,
    required this.surfaceElevated,
  });

  static const AppCustomColors light = AppCustomColors(
    ratingGold: AppColors.ratingGold,
    ratingBackground: AppColors.ratingBackgroundLight,
    shimmerBase: AppColors.shimmerBaseLight,
    shimmerHighlight: AppColors.shimmerHighlightLight,
    cardBorder: AppColors.lightBorder,
    secondaryText: Color(0xFF6C757D),
    surfaceElevated: AppColors.lightSurfaceElevated,
  );

  static const AppCustomColors dark = AppCustomColors(
    ratingGold: AppColors.ratingGold,
    ratingBackground: AppColors.ratingBackgroundDark,
    shimmerBase: AppColors.shimmerBaseDark,
    shimmerHighlight: AppColors.shimmerHighlightDark,
    cardBorder: AppColors.darkBorder,
    secondaryText: Color(0xFF9E9EA8),
    surfaceElevated: AppColors.darkSurfaceElevated,
  );

  @override
  AppCustomColors copyWith({
    Color? ratingGold,
    Color? ratingBackground,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? cardBorder,
    Color? secondaryText,
    Color? surfaceElevated,
  }) {
    return AppCustomColors(
      ratingGold: ratingGold ?? this.ratingGold,
      ratingBackground: ratingBackground ?? this.ratingBackground,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      cardBorder: cardBorder ?? this.cardBorder,
      secondaryText: secondaryText ?? this.secondaryText,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
    );
  }

  @override
  AppCustomColors lerp(ThemeExtension<AppCustomColors>? other, double t) {
    if (other is! AppCustomColors) {
      return this;
    }

    return AppCustomColors(
      ratingGold: Color.lerp(ratingGold, other.ratingGold, t) ?? ratingGold,
      ratingBackground:
          Color.lerp(ratingBackground, other.ratingBackground, t) ??
              ratingBackground,
      shimmerBase:
          Color.lerp(shimmerBase, other.shimmerBase, t) ?? shimmerBase,
      shimmerHighlight:
          Color.lerp(shimmerHighlight, other.shimmerHighlight, t) ??
              shimmerHighlight,
      cardBorder:
          Color.lerp(cardBorder, other.cardBorder, t) ?? cardBorder,
      secondaryText:
          Color.lerp(secondaryText, other.secondaryText, t) ?? secondaryText,
      surfaceElevated:
          Color.lerp(surfaceElevated, other.surfaceElevated, t) ??
              surfaceElevated,
    );
  }
}
