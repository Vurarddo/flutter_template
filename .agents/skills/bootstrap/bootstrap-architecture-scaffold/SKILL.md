---
name: bootstrap-architecture-scaffold
description: Scaffolds the complete Clean Architecture directory hierarchy, multi-environment Flavors (dev, stage, prod), configuration models, DI container, initial domain/data example feature, .gitignore, and core entrypoints (main.dart, application.dart). Use when establishing the architecture backbone for a new Flutter project.
---

# Clean Architecture, Flavors & Domain/Data Scaffolding

## 1. Overview & When to Apply

Use this skill to scaffold the architectural backbone of a new Flutter application:
- Generating the Clean Architecture layer folders (`core/`, `domain/`, `data/`, `infrastructure/`, `presentation/`, `l10n/`).
- Scaffolding the **initial template feature** (`example`) across `domain/` and `data/` (`ExampleItem`, `ExampleFailure`, `IExampleRepository`, `GetExampleItemsUseCase`, `ExampleItemDto`, `ExampleApiClient`, `ExampleRepositoryImpl`) so that `build_runner` and DI immediately compile.
- Setting up the complete, production-ready `.gitignore` protecting environment credentials (`config/env_*.json`) and excluding all generated files.
- Setting up multi-environment Flavors (`config/env_dev.json`, `config/env_stage.json`, `config/env_prod.json`, `config/env_template.json`).
- Configuring Android `productFlavors` and iOS Build Configurations / Schemes.
- Authoring production-ready entrypoints: `lib/main.dart` and `lib/application.dart`.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [project-bootstrap-hub](../project-bootstrap-hub/SKILL.md) | Master bootstrapping coordinator. |
| **Architecture Guide** | [flutter-clean-architecture](../../flutter-clean-architecture/SKILL.md) | Layer-First rules, boundaries, and DDD contracts. |
| **Domain Entities** | [domain-entities-freezed](../../domain/domain-entities-freezed/SKILL.md) | `@freezed` immutable entity standards. |
| **Domain UseCases** | [domain-usecases](../../domain/domain-usecases/SKILL.md) | SRP Use Case contracts and DI injection. |
| **Data Mappers & DTOs** | [data-dto-mappers](../../data/data-dto-mappers/SKILL.md) | `@JsonSerializable` DTOs with inline `toDomain()` mappers. |
| **Flavors Guide** | [native-flavors-environments](../../native/native-flavors-environments/SKILL.md) | Detailed native Gradle and Xcode flavor settings. |
| **Next Step** | [bootstrap-theme-uikit](../bootstrap-theme-uikit/SKILL.md) | Generating M3 theme and UiKit showcase page. |

---

## 3. Directory Hierarchy Scaffolding

Scaffold the standard directory structure with strict layer boundaries:

```text
lib/
├── core/                                   # Pure Dart (Zero Flutter SDK)
│   ├── constants/
│   ├── extensions/
│   └── utils/
│
├── domain/example/                         # Initial Pure Domain Feature
│   ├── entities/example_item.dart          # Freezed immutable entity
│   ├── failures/example_failure.dart       # Sealed Domain Failure hierarchy
│   ├── repositories/i_example_repository.dart # Abstract repository interface
│   └── usecases/get_example_items_usecase.dart # SRP @injectable UseCase
│
├── data/example/                           # Initial Data Layer Feature
│   ├── dto/example_item_dto.dart           # JsonSerializable DTO + toDomain()
│   ├── endpoints/example_endpoints.dart    # Centralized endpoint constants
│   ├── client/example_api_client.dart      # Retrofit @RestApi client
│   └── repositories/example_repository_impl.dart # @LazySingleton repository impl
│
├── infrastructure/                         # Framework & Core Modules
│   ├── config/                             # AppConfig, AppEnvironment
│   ├── di/                                 # Injectable & GetIt container
│   ├── network/                            # Dio singleton, interceptors
│   ├── storage/                            # SecureStorage & SharedPreferences
│   ├── services/                           # Firebase, DeepLink, Purchase
│   └── logging/                            # AppLogger
│
├── l10n/                                   # Localization
│   ├── intl_en.arb
│   └── intl_uk.arb
│
└── presentation/                           # Presentation Layer
    ├── navigation/                         # AutoRoute router & guards
    │   ├── app_router.dart
    │   └── guards/
    ├── state_management/example/           # Feature BLoC / Cubit
    │   ├── example_bloc.dart
    │   ├── example_event.dart
    │   └── example_state.dart
    ├── pages/                              # UI Screens & Pages
    │   ├── example/                        # Feature Page
    │   │   ├── example_page.dart
    │   │   └── widgets/
    │   └── uikit/                          # Design System Showcase Landing
    │       ├── uikit_page.dart
    │       └── widgets/
    ├── theme/                              # Material 3 Theme & Extensions
    ├── ui_kit/                             # Pure Reusable UI Kit Components
    └── ui_utils/                           # UI Extensions, Formatters, Helpers
        ├── extensions/
        ├── formatters/
        ├── forms/
        └── helpers/
```

> [!IMPORTANT]
> **Path Standards:**
> - UI screens and feature pages MUST strictly be placed in `lib/presentation/pages/<feature>/` (never `lib/presentation/ui/<feature>/`).
> - Reusable UI widgets belong in `lib/presentation/ui_kit/`.
> - State management belongs in `lib/presentation/state_management/<feature>/`.
> - UI utility extensions belong in `lib/presentation/ui_utils/extensions/`.

---

## 4. Git Hygiene & `.gitignore` Scaffolding

Scaffold root `.gitignore` from [resources/.gitignore](resources/.gitignore) containing all standard Flutter ignores, sensitive credentials, and generated code exclusions:

```gitignore
# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.build/
.buildlog/
.history
.svn/
.swiftpm/
migrate_working_dir/

# IntelliJ related
*.iml
*.ipr
*.iws
.idea/

# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins-dependencies
.pub-cache/
.pub/
/build/
/coverage/

# Symbolication & Obfuscation
app.*.symbols
app.*.map.json

# Android Studio build artifacts
/android/app/debug
/android/app/profile
/android/app/release

# Environment configurations (Protect secret credentials)
config/env_*.json
!config/env_template.json

# Generated files (build_runner, freezed, retrofit, injectable, auto_route, l10n, flutter_gen)
*.g.dart
*.gr.dart
*.freezed.dart
*.config.dart
lib/l10n/generated/
lib/presentation/ui_utils/assets/

# Local agent configuration & user overrides
.agents/rules/local_*.md
.agents/rules/*.local.md
.agents/local.json
.agents/local_*.json
```

---

## 5. Multi-Environment Flavors & Native Configuration (`config/`)

### 5.1 Create Environment JSON Files:

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

### 5.2 Native Platform Flavors Summary
Reference guides:
- [Android Flavors](https://docs.flutter.dev/deployment/flavors)
- [iOS Flavors](https://docs.flutter.dev/deployment/flavors-ios)
- [Linux Flavors](https://docs.flutter.dev/deployment/flavors-linux)
- [Windows Flavors](https://docs.flutter.dev/deployment/flavors-windows)
- For comprehensive multi-platform native configurations, consult [native-flavors-environments](../../native/native-flavors-environments/SKILL.md).

---

## 6. VS Code Configuration (`.vscode/`)

Place the standard multi-flavor launch configurations and IDE settings:

- **Launch Configurations:** Reference template: [resources/launch.json](resources/launch.json).
- **Workspace Settings (`.vscode/settings.json`):**
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
- **Recommended Extensions (`.vscode/extensions.json`):** Include `Dart-Code.dart-code`, `Dart-Code.flutter`, `localizely.flutter-intl`, `felangel.bloc`.

---

## 7. Initial Clean Architecture Domain & Data Example Scaffolding

Scaffold the initial example feature across `domain/` and `data/` using reference code from [examples/example_feature_bundle.dart](examples/example_feature_bundle.dart):

### 7.1 Domain Layer (`lib/domain/example/`)
1. **Entity (`entities/example_item.dart`):** Immutable Freezed model:
   ```dart
   import 'package:freezed_annotation/freezed_annotation.dart';

   part 'example_item.freezed.dart';

   @freezed
   class ExampleItem with _$ExampleItem {
     final String id;
     final String title;
     final String description;
     final bool isActive;

     const ExampleItem({
       required this.id,
       required this.title,
       required this.description,
       required this.isActive,
     });
   }
   ```
2. **Failure (`failures/example_failure.dart`):** Typed sealed error hierarchy:
   ```dart
   sealed class ExampleFailure {
     final String message;
     const ExampleFailure([this.message = 'An unexpected error occurred.']);
   }

   final class NetworkExampleFailure extends ExampleFailure {
     const NetworkExampleFailure([super.message = 'No internet connection.']);
   }

   final class ServerExampleFailure extends ExampleFailure {
     final int? statusCode;
     const ServerExampleFailure({String message = 'Server error.', this.statusCode}) : super(message);
   }

   final class UnknownExampleFailure extends ExampleFailure {
     final Object? error;
     final StackTrace? stackTrace;
     const UnknownExampleFailure({String message = 'Unexpected error.', this.error, this.stackTrace}) : super(message);
   }
   ```
3. **Repository Interface (`repositories/i_example_repository.dart`):** Pure abstract contract:
   ```dart
   import 'package:flutter_template/domain/example/entities/example_item.dart';

   abstract interface class IExampleRepository {
     Future<List<ExampleItem>> getExampleItems();
   }
   ```
4. **Use Case (`usecases/get_example_items_usecase.dart`):** Single-responsibility action:
   ```dart
   import 'package:injectable/injectable.dart';
   import 'package:flutter_template/domain/example/entities/example_item.dart';
   import 'package:flutter_template/domain/example/repositories/i_example_repository.dart';

   @injectable
   class GetExampleItemsUseCase {
     final IExampleRepository _repository;
     const GetExampleItemsUseCase(this._repository);

     Future<List<ExampleItem>> call() => _repository.getExampleItems();
   }
   ```

### 7.2 Data Layer (`lib/data/example/`)
1. **DTO & Inline Mapper (`dto/example_item_dto.dart`):**
   ```dart
   import 'package:json_annotation/json_annotation.dart';
   import 'package:flutter_template/domain/example/entities/example_item.dart';

   part 'example_item_dto.g.dart';

   @JsonSerializable()
   class ExampleItemDto {
     final String id;
     final String title;
     final String description;
     @JsonKey(name: 'is_active', defaultValue: true)
     final bool isActive;

     const ExampleItemDto({required this.id, required this.title, required this.description, required this.isActive});

     factory ExampleItemDto.fromJson(Map<String, dynamic> json) => _$ExampleItemDtoFromJson(json);
     Map<String, dynamic> toJson() => _$ExampleItemDtoToJson(this);

     ExampleItem toDomain() => ExampleItem(id: id, title: title, description: description, isActive: isActive);
   }
   ```
2. **Endpoints (`endpoints/example_endpoints.dart`):**
   ```dart
   abstract final class ExampleEndpoints {
     static const String items = '/v1/example-items';
   }
   ```
3. **API Client (`client/example_api_client.dart`):** Retrofit service:
   ```dart
   import 'package:dio/dio.dart';
   import 'package:retrofit/retrofit.dart';
   import 'package:flutter_template/data/example/dto/example_item_dto.dart';
   import 'package:flutter_template/data/example/endpoints/example_endpoints.dart';

   part 'example_api_client.g.dart';

   @RestApi()
   abstract class ExampleApiClient {
     factory ExampleApiClient(Dio dio, {String baseUrl}) = _ExampleApiClient;

     @GET(ExampleEndpoints.items)
     Future<List<ExampleItemDto>> getExampleItems();
   }
   ```
4. **Repository Implementation (`repositories/example_repository_impl.dart`):**
   ```dart
   import 'package:dio/dio.dart';
   import 'package:injectable/injectable.dart';
   import 'package:flutter_template/data/example/client/example_api_client.dart';
   import 'package:flutter_template/domain/example/entities/example_item.dart';
   import 'package:flutter_template/domain/example/failures/example_failure.dart';
   import 'package:flutter_template/domain/example/repositories/i_example_repository.dart';

   @LazySingleton(as: IExampleRepository)
   class ExampleRepositoryImpl implements IExampleRepository {
     final ExampleApiClient _apiClient;
     const ExampleRepositoryImpl(this._apiClient);

     @override
     Future<List<ExampleItem>> getExampleItems() async {
       try {
         final dtos = await _apiClient.getExampleItems();
         return dtos.map((dto) => dto.toDomain()).toList();
       } on DioException catch (dioError) {
         if (dioError.type == DioExceptionType.connectionTimeout ||
             dioError.type == DioExceptionType.receiveTimeout ||
             dioError.type == DioExceptionType.connectionError) {
           throw const NetworkExampleFailure();
         }
         throw ServerExampleFailure(message: dioError.message ?? 'Server error', statusCode: dioError.response?.statusCode);
       } catch (e, st) {
         throw UnknownExampleFailure(error: e, stackTrace: st);
       }
     }
   }
   ```

---

## 8. Quality & Linter Configuration (`analysis_options.yaml`)

Scaffold root `analysis_options.yaml` with strict BLoC rules and code generation exclusions.
- Full configuration file: [resources/analysis_options.yaml](resources/analysis_options.yaml).

---

## 9. Core Architecture Boilerplates & Entrypoints

Refer to production-ready boilerplate implementations in `examples/`:

1. **Centralized Configuration Model:** [examples/app_config.dart](examples/app_config.dart)
   - Strongly typed `AppEnvironment` (`dev`, `stage`, `prod`) using `String.fromEnvironment`.
2. **Main Bootstrap Entrypoint:** [examples/main.dart](examples/main.dart)
   - Wrapped in `runZonedGuarded` with `HydratedBloc.storage` and `configureDependencies()` initialization.
3. **Application Root Widget:** [examples/application.dart](examples/application.dart)
   - `MaterialApp.router` bound to `AppRouter`, `ThemeCubit` (with `AppThemeModeX`), and localization delegates.

---

## 10. Assets Hierarchy Scaffolding

Scaffold empty asset folders with `.gitkeep` files:
- `assets/fonts/.gitkeep`
- `assets/images/.gitkeep`
- `assets/icons/.gitkeep`
- `assets/svgs/.gitkeep`

---

## 11. Verification Checklist

- [ ] Clean Architecture layer folders created (`core/`, `domain/`, `data/`, `infrastructure/`, `presentation/pages/`, `presentation/state_management/`, `presentation/ui_kit/`, `presentation/ui_utils/`, `l10n/`).
- [ ] Initial example feature scaffolded in `domain/example/` and `data/example/`.
- [ ] Root `.gitignore` created from [resources/.gitignore](resources/.gitignore) protecting env configs, generated files, and agent overrides.
- [ ] `config/env_*.json` files generated and added to `.gitignore`.
- [ ] Native platform Flavors configured across Android, iOS, Linux, Windows, macOS.
- [ ] `.vscode/launch.json` created from [resources/launch.json](resources/launch.json).
- [ ] `analysis_options.yaml` created from [resources/analysis_options.yaml](resources/analysis_options.yaml).
- [ ] `lib/infrastructure/config/app_config.dart` authored based on [examples/app_config.dart](examples/app_config.dart).
- [ ] `lib/main.dart` authored based on [examples/main.dart](examples/main.dart).
- [ ] `lib/application.dart` authored based on [examples/application.dart](examples/application.dart).
- [ ] Asset folders initialized with `.gitkeep`.
- [ ] Ready to proceed to [bootstrap-theme-uikit](../bootstrap-theme-uikit/SKILL.md).
