import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand / Primary
  static const Color primary = Color(0xFFE50914); // Cinematic Red
  static const Color primaryDark = Color(0xFFB81D24);
  static const Color primaryContainerLight = Color(0xFFFFDAD6);
  static const Color primaryContainerDark = Color(0xFF93000A);

  // Secondary / Accents
  static const Color secondary = Color(0xFF221F1F);
  static const Color secondaryLight = Color(0xFF535F70);

  // Rating & Status
  static const Color ratingGold = Color(0xFFFFB800);
  static const Color ratingBackgroundLight = Color(0xFFFFF8E1);
  static const Color ratingBackgroundDark = Color(0xFF332900);

  // Dark Theme Backgrounds & Surfaces
  static const Color darkBackground = Color(0xFF121214);
  static const Color darkSurface = Color(0xFF1E1E22);
  static const Color darkSurfaceElevated = Color(0xFF282830);
  static const Color darkBorder = Color(0xFF383842);

  // Light Theme Backgrounds & Surfaces
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF1F3F5);
  static const Color lightBorder = Color(0xFFE9ECEF);

  // Shimmer
  static const Color shimmerBaseDark = Color(0xFF282830);
  static const Color shimmerHighlightDark = Color(0xFF383844);
  static const Color shimmerBaseLight = Color(0xFFE9ECEF);
  static const Color shimmerHighlightLight = Color(0xFFF8F9FA);
}
