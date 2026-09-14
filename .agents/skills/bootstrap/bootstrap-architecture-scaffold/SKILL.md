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

## 4. Multi-Environment Flavors & Native Configuration (`config/`)

### 4.1 Create Environment JSON Files (Added to `.gitignore`):

#### `config/env_dev.json`
```json
{
  "APP_ENV": "dev",
  "BASE_URL": "https://api-dev.example.com",
  "APP_NAME": "App Dev"
}
```

#### `config/env_stage.json`
```json
{
  "APP_ENV": "stage",
  "BASE_URL": "https://api-stage.example.com",
  "APP_NAME": "App Stage"
}
```

#### `config/env_prod.json`
```json
{
  "APP_ENV": "prod",
  "BASE_URL": "https://api.example.com",
  "APP_NAME": "App"
}
```

#### `config/env_template.json` (Committed to Git)
```json
{
  "APP_ENV": "dev",
  "BASE_URL": "https://api-dev.example.com",
  "APP_NAME": "App Dev"
}
```

---

### 4.2 Native Platform Flavors Configuration
Reference guides:
- [Android Flavors](https://docs.flutter.dev/deployment/flavors)
- [iOS Flavors](https://docs.flutter.dev/deployment/flavors-ios)
- [Linux Flavors](https://docs.flutter.dev/deployment/flavors-linux)
- [Windows Flavors](https://docs.flutter.dev/deployment/flavors-windows)

#### A. Android (`android/app/build.gradle.kts`):
```kotlin
android {
    flavorDimensions += "default"
    productFlavors {
        create("dev") {
            dimension = "default"
            applicationIdSuffix = ".dev"
            manifestPlaceholders["appName"] = "App Dev"
            manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher_dev"
        }
        create("stage") {
            dimension = "default"
            applicationIdSuffix = ".stage"
            manifestPlaceholders["appName"] = "App Staging"
            manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher_stage"
        }
        create("prod") {
            dimension = "default"
            manifestPlaceholders["appName"] = "App"
            manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher"
        }
    }
}
```

In `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="${appName}"
    android:icon="${appIcon}">
    ...
</application>
```

#### B. iOS / macOS:
- Configure Xcode Build Configurations (`Debug-dev`, `Release-dev`, `Debug-stage`, `Release-stage`, `Debug-prod`, `Release-prod`).
- Create 3 shared Schemes: `dev`, `stage`, `prod`.
- Configure `ios/Flutter/Debug-dev.xcconfig` etc. with `PRODUCT_BUNDLE_IDENTIFIER` and `APP_DISPLAY_NAME`.

#### C. Linux (`linux/CMakeLists.txt`):
```cmake
if(DEFINED FLUTTER_FLAVOR)
  add_definitions(-DFLUTTER_FLAVOR="${FLUTTER_FLAVOR}")
endif()
```

#### D. Windows (`windows/CMakeLists.txt`):
```cmake
if(DEFINED FLUTTER_FLAVOR)
  add_definitions(-DFLUTTER_FLAVOR="${FLUTTER_FLAVOR}")
endif()
```

---

## 5. VS Code Configuration (`.vscode/`)

Create standard VS Code workspace files:

### 5.1 `.vscode/launch.json`
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "🔧 Debug Dev",
            "request": "launch",
            "type": "dart",
            "program": "lib/main.dart",
            "args": [
                "--flavor",
                "dev",
                "--dart-define-from-file=config/env_dev.json"
            ]
        },
        {
            "name": "⚙️ Profile Dev",
            "request": "launch",
            "type": "dart",
            "program": "lib/main.dart",
            "args": [
                "--flavor",
                "dev",
                "--dart-define-from-file=config/env_dev.json",
                "--profile"
            ]
        },
        {
            "name": "📱 Release Dev",
            "request": "launch",
            "type": "dart",
            "program": "lib/main.dart",
            "args": [
                "--flavor",
                "dev",
                "--dart-define-from-file=config/env_dev.json",
                "--release"
            ]
        },
        {
            "name": "🔧 Debug Stage",
            "request": "launch",
            "type": "dart",
            "program": "lib/main.dart",
            "args": [
                "--flavor",
                "stage",
                "--dart-define-from-file=config/env_stage.json"
            ]
        },
        {
            "name": "⚙️ Profile Stage",
            "request": "launch",
            "type": "dart",
            "program": "lib/main.dart",
            "args": [
                "--flavor",
                "stage",
                "--dart-define-from-file=config/env_stage.json",
                "--profile"
            ]
        },
        {
            "name": "📱 Release Stage",
            "request": "launch",
            "type": "dart",
            "program": "lib/main.dart",
            "args": [
                "--flavor",
                "stage",
                "--dart-define-from-file=config/env_stage.json",
                "--release"
            ]
        },
        {
            "name": "🔧 Debug Prod",
            "request": "launch",
            "type": "dart",
            "program": "lib/main.dart",
            "args": [
                "--flavor",
                "prod",
                "--dart-define-from-file=config/env_prod.json"
            ]
        },
        {
            "name": "⚙️ Profile Prod",
            "request": "launch",
            "type": "dart",
            "program": "lib/main.dart",
            "args": [
                "--flavor",
                "prod",
                "--dart-define-from-file=config/env_prod.json",
                "--profile"
            ]
        },
        {
            "name": "📱 Release Prod",
            "request": "launch",
            "type": "dart",
            "program": "lib/main.dart",
            "args": [
                "--flavor",
                "prod",
                "--dart-define-from-file=config/env_prod.json",
                "--release"
            ]
        },
        {
            "name": "🧪 Run All Tests",
            "request": "launch",
            "type": "dart",
            "program": "test/"
        },
        {
            "name": "🧪 Run Unit Tests",
            "request": "launch",
            "type": "dart",
            "program": "test/unit/"
        },
        {
            "name": "🧪 Run Widget Tests",
            "request": "launch",
            "type": "dart",
            "program": "test/widget/"
        },
        {
            "name": "🧪 Run BLoC Tests",
            "request": "launch",
            "type": "dart",
            "program": "test/bloc/"
        },
        {
            "name": "🔍 Run Integration Tests (UiKit)",
            "request": "launch",
            "type": "dart",
            "program": "integration_test/uikit_page_test.dart"
        }
    ]
}
```

### 5.2 `.vscode/settings.json`
```json
{
    "java.configuration.updateBuildConfiguration": "disabled",
    "[dart]": {
        "editor.formatOnSave": true,
        "editor.formatOnType": true,
        "editor.defaultFormatter": "Dart-Code.dart-code"
    }
}
```

### 5.3 `.vscode/extensions.json`
```json
{
    "recommendations": [
        "Dart-Code.dart-code",
        "Dart-Code.flutter",
        "localizely.flutter-intl",
        "felangel.bloc"
    ]
}
```

---

## 6. Quality & Linter Configuration (`analysis_options.yaml`)

Scaffold the standard root `analysis_options.yaml` with strict BLoC rules, code generation exclusions, and formatter guidelines:

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - build/**
    - lib/**.g.dart
    - lib/l10n/generated/**
    - android/**
    - ios/**
    - web/**
    - windows/**
    - macos/**
    - linux/**
  errors:
    invalid_annotation_target: ignore

linter:
  rules:
    annotate_overrides: false
    constant_identifier_names: false
    no_leading_underscores_for_library_prefixes: false
    prefer_const_constructors: true

bloc:
  rules:
    avoid_flutter_imports: true
    avoid_public_bloc_methods: true
    avoid_public_fields: true
    prefer_void_public_cubit_methods: true

formatter:
  trailing_commas: preserve
  page_width: 100
```

---

## 7. Centralized Configuration Model (`lib/infrastructure/config/app_config.dart`)

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

## 8. Main Bootstrap Entrypoint (`lib/main.dart`)

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

## 9. Application Root Widget (`lib/application.dart`)

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
```

---

## 10. Assets Hierarchy Scaffolding

Scaffold empty asset folders with `.gitkeep` files:
- `assets/fonts/.gitkeep`
- `assets/images/.gitkeep`
- `assets/icons/.gitkeep`
- `assets/svgs/.gitkeep`

---

## 11. Verification Checklist

- [ ] Clean Architecture layer folders created.
- [ ] `config/env_*.json` files generated and added to `.gitignore`.
- [ ] Native platform Flavors configured across Android, iOS, Linux, Windows, macOS.
- [ ] `.vscode/launch.json` created with flavor configs and test runners.
- [ ] `analysis_options.yaml` configured with strict BLoC rules, exclude paths, and `invalid_annotation_target: ignore`.
- [ ] `AppConfig` strongly typed with `String.fromEnvironment`.
- [ ] `lib/main.dart` wrapped in `runZonedGuarded` with `HydratedBloc` & `GetIt` initialization.
- [ ] `lib/application.dart` maps `state.themeMode.toFlutter()` via `AppThemeModeX`.
- [ ] Asset folders initialized with `.gitkeep`.
- [ ] Ready to proceed to [bootstrap-theme-uikit](../bootstrap-theme-uikit/SKILL.md).
