import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_template/l10n/generated/l10n.dart';
import 'package:flutter_template/presentation/theme/app_theme.dart';

class WidgetTestWrapper extends StatelessWidget {
  final Widget child;
  final Brightness brightness;
  final Locale locale;

  const WidgetTestWrapper({
    super.key,
    required this.child,
    this.brightness = Brightness.light,
    this.locale = const Locale('en'),
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: brightness == Brightness.dark ? AppTheme.darkTheme : AppTheme.lightTheme,
      locale: locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(body: child),
    );
  }
}
