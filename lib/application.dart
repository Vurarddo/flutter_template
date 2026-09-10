import 'package:flutter/material.dart';
import 'package:flutter_template/infrastructure/di/injection.dart';
import 'package:flutter_template/presentation/navigation/app_router.dart';
import 'package:flutter_template/presentation/theme/app_theme.dart';

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();

    return MaterialApp.router(
      title: 'TMDB Movies',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter.config(),
    );
  }
}
