---
name: bootstrap-architecture-scaffold
description: Scaffolds the complete Clean Architecture directory hierarchy, multi-environment Flavors (dev, stage, prod), configuration models, DI container, and core entrypoints (main.dart, application.dart). Use when establishing the architecture backbone for a new Flutter project.
---

# Clean Architecture & Flavors Scaffolding

## 1. Overview & When to Apply

Use this skill to scaffold the architectural backbone of a new Flutter application:
- Generating the Clean Architecture layer folders (`core/`, `domain/`, `data/`, `infrastructure/`, `presentation/`, `l10n/`).
- Setting up multi-environment Flavors (`config/env_dev.json`, `config/env_stage.json`, `config/env_prod.json`, `config/env_template.json`).
- Configuring Android `productFlavors` and iOS Build Configurations / Schemes.
- Authoring production-ready entrypoints: `lib/main.dart` and `lib/application.dart`.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [project-bootstrap-hub](../project-bootstrap-hub/SKILL.md) | Master bootstrapping coordinator. |
| **Architecture Guide** | [flutter-clean-architecture](../../flutter-clean-architecture/SKILL.md) | Layer-First rules, boundaries, and DDD contracts. |
| **Flavors Guide** | [native-flavors-environments](../../native/native-flavors-environments/SKILL.md) | Detailed native Gradle and Xcode flavor settings. |
| **Next Step** | [bootstrap-theme-uikit](../bootstrap-theme-uikit/SKILL.md) | Generating M3 theme (#FFDE3F) and UiKit showcase page. |

---

## 3. Directory Hierarchy Scaffolding

Scaffold the standard directory structure:

```text
lib/
├── core/
│   ├── constants/
│   ├── extensions/
│   └── utils/
├── domain/
├── data/
├── infrastructure/
│   ├── config/
│   ├── di/
│   ├── network/
│   ├── storage/
│   ├── services/
│   └── logging/
├── l10n/
│   ├── intl_en.arb
│   └── intl_uk.arb
└── presentation/
    ├── navigation/
    ├── state-management/
    ├── theme/
    ├── ui/
    │   └── ui-kit/
    └── ui-utils/
        ├── extensions/
        ├── formatters/
        ├── forms/
        └── helpers/
```

---

## 4. Multi-Environment Flavors Setup (`config/`)

Create environment JSON files (added to `.gitignore`):

### `config/env_dev.json`
```json
{
  "APP_ENV": "dev",
  "BASE_URL": "https://api-dev.example.com",
  "APP_NAME": "App Dev"
}
```

### `config/env_stage.json`
```json
{
  "APP_ENV": "stage",
  "BASE_URL": "https://api-stage.example.com",
  "APP_NAME": "App Stage"
}
```

### `config/env_prod.json`
```json
{
  "APP_ENV": "prod",
  "BASE_URL": "https://api.example.com",
  "APP_NAME": "App"
}
```

### `config/env_template.json` (Committed to Git)
```json
{
  "APP_ENV": "dev",
  "BASE_URL": "https://api-dev.example.com",
  "APP_NAME": "App Dev"
}
```

---

## 5. Centralized Configuration Model (`lib/infrastructure/config/app_config.dart`)

```dart
enum AppEnvironment {
  dev,
  stage,
  prod;

  static AppEnvironment fromString(String value) {
    return switch (value.toLowerCase()) {
      'dev' || 'development' => AppEnvironment.dev,
      'stage' || 'staging' => AppEnvironment.stage,
      'prod' || 'production' => AppEnvironment.prod,
      _ => AppEnvironment.dev,
    };
  }
}

abstract final class AppConfig {
  static const String appEnvRaw = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  static const String baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'https://api-dev.example.com');
  static const String appName = String.fromEnvironment('APP_NAME', defaultValue: 'App Dev');

  static final AppEnvironment environment = AppEnvironment.fromString(appEnvRaw);

  static bool get isDev => environment == AppEnvironment.dev;
  static bool get isStage => environment == AppEnvironment.stage;
  static bool get isProd => environment == AppEnvironment.prod;
}
```

---

## 6. Main Bootstrap Entrypoint (`lib/main.dart`)

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_template/application.dart';
import 'package:flutter_template/infrastructure/di/injectable.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Hydrated Bloc storage
      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: kIsWeb
            ? HydratedStorageDirectory.web
            : HydratedStorageDirectory((await getTemporaryDirectory()).path),
      );

      // Initialize Dependency Injection
      await configureDependencies();

      runApp(const Application());
    },
    (error, stackTrace) {
      // Global error reporting / logging
      debugPrint('Unhandled error: $error\n$stackTrace');
    },
  );
}
```

---

## 7. Application Root Widget (`lib/application.dart`)

```dart
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
            themeMode: state.themeMode,
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
```

---

## 8. Verification Checklist

- [ ] Clean Architecture layer folders created.
- [ ] `config/env_*.json` files generated and added to `.gitignore`.
- [ ] `AppConfig` strongly typed with `String.fromEnvironment`.
- [ ] `lib/main.dart` wrapped in `runZonedGuarded` with `HydratedBloc` & `GetIt` initialization.
- [ ] `lib/application.dart` configured with `MaterialApp.router`, `ThemeCubit`, and localization delegates.
- [ ] Ready to proceed to [bootstrap-theme-uikit](../bootstrap-theme-uikit/SKILL.md).
