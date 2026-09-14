import 'package:flutter/material.dart';
import 'package:flutter_template/presentation/theme/app_theme.dart';

/// Standard container providing MaterialApp context, theme, and scaffold for @Preview functions.
class PreviewWrapper extends StatelessWidget {
  final Widget child;
  final Brightness brightness;
  final String? title;

  const PreviewWrapper({
    super.key,
    required this.child,
    this.brightness = Brightness.light,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: brightness == Brightness.light ? AppTheme.lightTheme : AppTheme.darkTheme,
      home: Scaffold(
        appBar: title != null ? AppBar(title: Text(title!)) : null,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    );
  }
}
