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
