---
name: flutter-clean-architecture
description: Enforces Clean Architecture, DDD, and SOLID with Layer-First packaging (domain, data, presentation, infrastructure), repository interfaces in Domain, single-responsibility UseCases, DTOs with inline toDomain() mappers in Data, Retrofit clients, sealed class failures, and BLoC state management. Use when creating new features, refactoring layers, reviewing PRs, or implementing architecture logic.
---

# Flutter Clean Architecture & DDD Skill

## When to Apply

Use this skill when creating features, refactoring code across layers, reviewing architecture, or generating UseCases, Repositories, BLoCs, and DTOs.

---

## Mandatory Dependency & Import Rules

```text
Presentation → Domain ← Data
                  ↑
            Infrastructure

```

- **Domain:** Pure Dart. Dependencies ALLOWED: `injectable` (for DI annotations), `@freezed` (immutable models). **PROHIBITED:** `package:flutter`, Dio, Retrofit, SharedPreferences, or `data/`/`presentation/` layers.
- **Data:** Implements Domain contracts. Depends on **Domain** (Imports Domain Entities for mapping). **PROHIBITED:** Dependencies on `presentation/` or UI widgets.
- **Presentation:** Depends ONLY on **Domain UseCases** and entities. **PROHIBITED:** Direct access to `Repositories`, Retrofit `ApiClient`s, or DTOs.
- **Infrastructure:** Centralizes DI setup, Dio base configuration, global environments, and core services.

---

## Layer Responsibilities & Contracts

### 1. Domain Layer (`lib/domain/<feature_name>/`)
- Consult [domain-hub](../domain/domain-hub/SKILL.md).
- **Entities:** Pure Dart immutable classes using `@freezed` (consult [domain-entities-freezed](../domain/domain-entities-freezed/SKILL.md)).
- _Strict Restriction (per `build.yaml`):_ DO NOT generate or use `map`, `when`, `fromJson`, or `toJson` on Freezed models.
- **Repository Contracts:** `abstract class I<Feature>Repository` (consult [domain-repositories](../domain/domain-repositories/SKILL.md)). Methods return Domain Entities or Streams.
- **Failures:** Model error states using Dart 3 `sealed class` hierarchies (consult [domain-failures](../domain/domain-failures/SKILL.md)). **NO `dartz` / `fpdart` (`Either`)**.
- **Use Cases (SRP):** Single responsibility business actions with `call()` method (consult [domain-usecases](../domain/domain-usecases/SKILL.md)). Must depend ONLY on Repository Interfaces. BLoCs/Cubits MUST ONLY interact with Use Cases.

### 2. Data Layer (`lib/data/<feature_name>/`)
- Consult [data-hub](../data/data-hub/SKILL.md).
- **DTOs & Inline Mappers (`lib/data/<feature_name>/dto/`):** API models with `@JsonSerializable` and explicit inline `toDomain()` mappers (consult [data-dto-mappers](../data/data-dto-mappers/SKILL.md)). DTOs must NEVER cross into Domain or UI layers.
- **Endpoints (`lib/data/<feature_name>/endpoints/`):** Centralized route constants (`static const String ...`).
- **API Clients (`lib/data/<feature_name>/client/`):** Retrofit interfaces (`@RestApi()`) using Dio (consult [data-retrofit-clients](../data/data-retrofit-clients/SKILL.md)).
- **Local Data Sources (`lib/data/<feature_name>/datasources/`):** Local caching, memory caches, DAOs (consult [data-datasources-local](../data/data-datasources-local/SKILL.md)).
- **Repository Implementations (`lib/data/<feature_name>/repositories/`):** Implement Domain `IRepository` contracts, orchestrate data sources, and map `DioException` via `DioExceptionMapper` to typed Domain Failures (consult [data-repositories](../data/data-repositories/SKILL.md)).

### 3. Presentation Layer (`lib/presentation/`)

- **State Management (`lib/presentation/state_management/<feature_name>/`):**
  - Consult [flutter-bloc-hub](../presentation/state-management/flutter-bloc-hub/SKILL.md) and [flutter-bloc-core](../presentation/state-management/flutter-bloc-core/SKILL.md).
  - Split into 3 files: `_event.dart`, `_state.dart`, `_bloc.dart` using `part`/`part of`.
  - States & Events: Defined using Dart 3 `sealed class` and `final class`. Extend `Equatable`.
  - BLoC Logic: Calls **UseCases ONLY**. Direct Repository/DataSource access is strictly prohibited.
  - Async Safety: ALWAYS add `if (emit.isDone) return;` after every `await`.
  - Event Concurrency: Use `bloc_concurrency` (`droppable()`, `restartable()`, `sequential()`).
  - Hydrated BLoC: Extract `fromJson`/`toJson` into `hydrated_<feature>_bloc.mixin.dart` (per [flutter-hydrated-bloc](../presentation/state-management/flutter-hydrated-bloc/SKILL.md)).
  - UI Scoping & Widgets: Follow [flutter-bloc-widgets](../presentation/state-management/flutter-bloc-widgets/SKILL.md) (`BlocProvider.value` for dialogs/modals).
  - Rules: Strictly NO `package:flutter/material.dart` imports in BLoC files.

- **Pages & Widgets (`lib/presentation/pages/<feature_name>/`):**
- Max file size: 150–200 lines.
- No helper builder methods (`_buildHeader()`). Extract UI into `widgets/<name>.dart`.
- Theme access: Use `context.colorScheme` or `context.customColors` (`ThemeExtension`). **NO hardcoded `Color(0x...)**`.

- **Global Presentation Modules:**
  - `navigation/`: `app_router.dart` (`auto_route`) & `guards/` (consult [flutter-auto-route-hub](../presentation/navigation/flutter-auto-route-hub/SKILL.md)).
  - `theme/`: Theme definitions & `ThemeExtension` implementations (consult [flutter-ui-theme-hub](../presentation/theme/flutter-ui-theme-hub/SKILL.md)).
  - `ui_kit/`: Pure, reusable, stateless widgets annotated with `@Preview` (consult [flutter-ui-kit-hub](../presentation/ui/ui-kit/flutter-ui-kit-hub/SKILL.md)).
  - `ui_utils/`: UI formatters, extensions, forms accessors, and helpers (consult [flutter-ui-utils-hub](../presentation/ui-utils/flutter-ui-utils-hub/SKILL.md)).

### 4. Core Layer (`lib/core/`)
- Consult [core-hub](../core/core-hub/SKILL.md).
- **Pure Dart Only:** 100% framework-agnostic, zero `package:flutter/*` imports.
- **`constants/`:** Global regex patterns, time durations, pagination limits (consult [core-constants](../core/core-constants/SKILL.md)).
- **`extensions/`:** Pure Dart extensions on `DateTime`, `String`, `num`, `Iterable` (consult [core-extensions](../core/core-extensions/SKILL.md)).
- **`utils/`:** Algorithmic helpers, currency precision math, pure debouncers (consult [core-utils](../core/core-utils/SKILL.md)).

### 5. Infrastructure Layer (`lib/infrastructure/`)
- Consult [infrastructure-hub](../infrastructure/infrastructure-hub/SKILL.md).
- **`config/`:** Environment settings via `--dart-define`, `AppConfig`, `AppEnvironment` (consult [infrastructure-config](../infrastructure/infrastructure-config/SKILL.md)).
- **`di/`:** Dependency Injection setup via `get_it` + `injectable` with `@module` (consult [infrastructure-di](../infrastructure/infrastructure-di/SKILL.md)).
- **`network/`:** Production `Dio` singleton, `BackgroundTransformer` (isolates), 401 `QueuedInterceptor` (consult [infrastructure-network-dio](../infrastructure/infrastructure-network-dio/SKILL.md)).
- **`storage/`:** `SecureStoreInteractor` for tokens & `StoreInteractor` for preferences (consult [infrastructure-storage](../infrastructure/infrastructure-storage/SKILL.md)).
- **`services/`:** External SDK wrappers and platform services:
  - `firebase/`: Crashlytics, FCM notifications, RemoteConfig (consult [infrastructure-services-firebase](../infrastructure/infrastructure-services-firebase/SKILL.md)).
  - `deep_link/`: App Links / Universal Links listeners (consult [infrastructure-services-deep-link](../infrastructure/infrastructure-services-deep-link/SKILL.md)).
  - `purchase/`: In-App Purchases & RevenueCat billing adapters (consult [infrastructure-services-purchase](../infrastructure/infrastructure-services-purchase/SKILL.md)).
- **`logging/`:** Centralized `AppLogger` with PII sanitization (consult [infrastructure-logging](../infrastructure/infrastructure-logging/SKILL.md)).

### 6. Localization Layer (`lib/l10n/`)
- Consult [l10n-hub](../l10n/l10n-hub/SKILL.md).
- **Single Source of Truth:** `intl_en.arb` and `intl_uk.arb` (consult [l10n-arb-icu](../l10n/l10n-arb-icu/SKILL.md)).
- **Code Generation:** `flutter pub run intl_utils:generate` outputs to `lib/l10n/generated/` (consult [l10n-generation-workflow](../l10n/l10n-generation-workflow/SKILL.md)).
- **Presentation Access:** UI widgets access copy via `context.localization.<key>`, and map `DomainFailure` via UI extensions (consult [l10n-presentation-integration](../l10n/l10n-presentation-integration/SKILL.md)).

### 7. Cross-Cutting: Error Handling & Resilience
- Consult [error-handling-hub](../error-handling/error-handling-hub/SKILL.md).
- **Transport Mapping:** Data layer catches `DioException` and converts via `DioExceptionMapper` (consult [error-handling-data-transport](../error-handling/error-handling-data-transport/SKILL.md)).
- **Domain Contracts:** Pure Dart sealed `DomainFailure` models (consult [domain-failures](../domain/domain-failures/SKILL.md)).
- **BLoC & UI Resolution:** BLoC `addError(error, stackTrace)` and `DomainFailureLocalizationX` (consult [error-handling-bloc-ui](../error-handling/error-handling-bloc-ui/SKILL.md)).
- **Global Crash Monitoring:** `runZonedGuarded`, `PlatformDispatcher.onError`, Crashlytics (consult [error-handling-global-crash](../error-handling/error-handling-global-crash/SKILL.md)).

### 8. Cross-Platform Testing Strategy
- Consult [testing-hub](../testing/testing-hub/SKILL.md).
- **Unit Testing (Pure Dart):** UseCases, DTO mappers, Core utils (consult [testing-unit](../testing/testing-unit/SKILL.md)).
- **BLoC Testing:** `bloc_test` state transitions and concurrency transformers (consult [testing-bloc](../testing/testing-bloc/SKILL.md)).
- **Widget Testing:** `WidgetTester`, `WidgetTestWrapper`, `ValueKey` finders (consult [testing-widget](../testing/testing-widget/SKILL.md)).
- **Integration Testing:** End-to-end user flows on **Mobile, Web, and Desktop** (consult [testing-integration](../testing/testing-integration/SKILL.md)).

### 9. Native Platform Integrations & Flavors
- Consult [native-hub](../native/native-hub/SKILL.md).
- **Multi-Environment Flavors:** Configuration management across `config/env_*.json`, Gradle `productFlavors`, and Xcode Build Configurations / Schemes (consult [native-flavors-environments](../native/native-flavors-environments/SKILL.md)).
- **Android Platform Channels & Native:** Kotlin v2 embedding, Coroutines, Pigeon, PlatformViews, and ProGuard rules (consult [native-android](../native/native-android/SKILL.md)).
- **iOS Platform Channels & Native:** Swift `@MainActor`, async/await, Pigeon, FlutterPlatformView, and Privacy Manifests (consult [native-ios](../native/native-ios/SKILL.md)).

---

## Complete Project Structure Matrix

```text
lib/
├── core/                               # Pure Dart (Zero Flutter SDK)
│   ├── constants/
│   ├── extensions/
│   └── utils/
│
├── domain/<feature>/
│   ├── entities/<feature>_entity.dart
│   ├── failures/<feature>_failure.dart
│   ├── repositories/i_<feature>_repository.dart
│   └── usecases/get_<feature>_usecase.dart
│
├── data/<feature>/
│   ├── dto/<feature>_dto.dart          # Contains JsonSerializable & toDomain() mapper
│   ├── client/<feature>_api_client.dart    # Retrofit @RestApi client
│   └── repositories/<feature>_repository_impl.dart
│
├── l10n/                               # Localization & ARB files
│   ├── generated/                      # Generated S classes (S.delegate, S.of(context))
│   ├── intl_en.arb                     # English base template
│   └── intl_uk.arb                     # Ukrainian translations (Slavic plurals)
│
├── presentation/
│   ├── state_management/<feature>/
│   │   ├── <feature>_event.dart
│   │   ├── <feature>_state.dart
│   │   ├── <feature>_bloc.dart
│   │   └── hydrated_<feature>_bloc.mixin.dart (if hydrated)
│   ├── pages/<feature>/
│   │   ├── <feature>_page.dart
│   │   └── widgets/
│   ├── navigation/
│   │   ├── app_router.dart
│   │   └── guards/
│   ├── theme/
│   ├── ui_kit/
│   └── ui_utils/                       # extensions (context.localization), formatters, forms, assets
│
└── infrastructure/
    ├── config/                         # AppConfig, AppEnvironment, --dart-define
    ├── di/                             # GetIt + Injectable modules
    ├── network/                        # Dio setup, BackgroundTransformer, QueuedInterceptor
    ├── storage/                        # SecureStoreInteractor, StoreInteractor
    ├── services/                       # Firebase, DeepLink, Purchase, Connectivity
    └── logging/                        # AppLogger, PII redaction
```

---

## Anti-Patterns (Strictly Prohibited)

| Violation                                         | Severity     | Corrective Action                                                           |
| ------------------------------------------------- | ------------ | --------------------------------------------------------------------------- |
| Import `package:flutter/*` in Domain or Data      | **CRITICAL** | Remove Flutter dependency. Domain/Data must be pure Dart.                   |
| Separate `mappers/` folder for 1-line mappings    | **LOW**      | Move `toDomain()` mapper directly inside `<feature>_dto.dart`.              |
| BLoC calling `Repository` or `ApiClient` directly | **HIGH**     | Create a single-action `UseCase` and inject it into BLoC.                   |
| `when` / `map` / `fromJson` on `@freezed` models  | **HIGH**     | Use explicit `sealed class` pattern matching (per `build.yaml`).            |
| DTOs crossing into BLoC or UI                     | **HIGH**     | Map DTO to Domain Entity via `toDomain()` inside Repository Implementation. |
| Hardcoded `Color()` in UI                         | **MEDIUM**   | Use `context.colorScheme` or `context.customColors`.                        |

---

## Agent Execution Checklist

When generating or refactoring code:

1. **Verify Imports:** Check that Domain contains zero Flutter UI imports and Data contains zero Presentation imports.
2. **Verify DTO & Mapping:** Ensure DTO is in `data/<feature>/dto/` and implements `toDomain()` for mapping to Domain Entity.
3. **Verify BLoC Async Safety:** Check if `if (emit.isDone) return;` exists after every `await` call in BLoC.
4. **Verify Granularity:** Ensure no UI file exceeds 200 lines and no helper methods like `_buildHeader()` exist.
