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
