import 'package:flutter/material.dart';

class AppCustomColors extends ThemeExtension<AppCustomColors> {
  final Color cardBorder;
  final Color secondaryText;
  final Color shimmerBase;
  final Color surfaceElevated;
  final Color success;
  final Color warning;
  final Color info;

  const AppCustomColors({
    required this.cardBorder,
    required this.secondaryText,
    required this.shimmerBase,
    required this.surfaceElevated,
    required this.success,
    required this.warning,
    required this.info,
  });

  static const AppCustomColors light = AppCustomColors(
    cardBorder: Color(0xffbec8c8),
    secondaryText: Color(0xff3f4949),
    shimmerBase: Color(0xffe3e9e9),
    surfaceElevated: Color(0xffffffff),
    success: Color(0xff2e7d32),
    warning: Color(0xffed6c02),
    info: Color(0xff0288d1),
  );

  static const AppCustomColors dark = AppCustomColors(
    cardBorder: Color(0xff2d3434),
    secondaryText: Color(0xffaab4b4),
    shimmerBase: Color(0xff232929),
    surfaceElevated: Color(0xff181f1f),
    success: Color(0xff66bb6a),
    warning: Color(0xffffa726),
    info: Color(0xff29b6f6),
  );

  @override
  AppCustomColors copyWith({
    Color? cardBorder,
    Color? secondaryText,
    Color? shimmerBase,
    Color? surfaceElevated,
    Color? success,
    Color? warning,
    Color? info,
  }) {
    return AppCustomColors(
      cardBorder: cardBorder ?? this.cardBorder,
      secondaryText: secondaryText ?? this.secondaryText,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
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
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      info: Color.lerp(info, other.info, t) ?? info,
    );
  }
}
