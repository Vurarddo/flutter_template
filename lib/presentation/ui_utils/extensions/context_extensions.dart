import 'package:flutter/material.dart';
import 'package:flutter_template/presentation/theme/app_custom_colors.dart';

extension ContextThemeExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;

  AppCustomColors get customColors =>
      theme.extension<AppCustomColors>() ?? AppCustomColors.light;
}

extension ContextResponsiveExtensions on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;
}
