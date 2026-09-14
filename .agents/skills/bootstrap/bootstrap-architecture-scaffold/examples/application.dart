import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_template/infrastructure/config/app_config.dart';
import 'package:flutter_template/infrastructure/di/injectable.dart';
import 'package:flutter_template/l10n/generated/l10n.dart';
import 'package:flutter_template/presentation/navigation/app_router.dart';
import 'package:flutter_template/presentation/state-management/theme/theme_cubit.dart';
import 'package:flutter_template/presentation/state-management/theme/theme_state.dart';
import 'package:flutter_template/presentation/theme/app_theme.dart';
import 'package:flutter_template/presentation/ui_utils/extensions/app_theme_mode_extension.dart';

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();

    return BlocProvider<ThemeCubit>(
      create: (_) => getIt<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: AppConfig.isDev,
            routerConfig: appRouter.config(),
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode.toFlutter(),
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
          );
        },
      ),
    );
  }
}
