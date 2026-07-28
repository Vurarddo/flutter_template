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

- **Entities:** Pure Dart immutable classes using `@freezed`.
- _Strict Restriction (per `build.yaml`):_ DO NOT generate or use `map`, `when`, `fromJson`, or `toJson` on Freezed models.

- **Repository Contracts:** `abstract class I<Feature>Repository`. Methods return Domain Entities or throw typed `DomainFailure` states.
- **Failures:** Model error states using Dart 3 `sealed class` hierarchies (e.g., `sealed class AuthFailure`). **NO `dartz` / `fpdart` (`Either`)**.
- **Use Cases (SRP):** Single responsibility business actions (e.g., `GetAccountDetailsUseCase`). Must implement `call()` method and accept typed params. Must depend ONLY on Repository Interfaces.

### 2. Data Layer (`lib/data/<feature_name>/`)

- **DTOs (`lib/data/<feature_name>/dto/`):** API models annotated with `@JsonSerializable(createToJson: false/true)`.
- _Inline Mappers:_ DTOs must contain an explicit `toDomain()` method (and internal private helper extensions) converting the DTO into a Domain Entity.

- **API Clients (`lib/data/<feature_name>/client/`):** Retrofit interfaces (`@RestApi()`) using Dio.
- **Repository Implementations:** Implement Domain contracts. Catch network/storage exceptions, log them, and map them into typed `DomainFailure` exceptions before throwing/returning. **NO business rules here.**

### 3. Presentation Layer (`lib/presentation/`)

- **State Management (`lib/presentation/state_management/<feature_name>/`):**
- Split into 3 files: `_event.dart`, `_state.dart`, `_bloc.dart` using `part`/`part of`.
- States & Events: Defined using Dart 3 `sealed class` and `final class`. Extend `Equatable`.
- BLoC Logic: Calls **UseCases ONLY**.
- Async Safety: ALWAYS add `if (emit.isDone) return;` after every `await`.
- Event Concurrency: Use `bloc_concurrency` (`droppable()`, `restartable()`, `sequential()`).
- Hydrated BLoC: Extract `fromJson`/`toJson` into `hydrated_<feature>_bloc.mixin.dart`.
- Rules: Strictly NO `package:flutter/material.dart` imports in BLoC files.

- **Pages & Widgets (`lib/presentation/pages/<feature_name>/`):**
- Max file size: 150–200 lines.
- No helper builder methods (`_buildHeader()`). Extract UI into `widgets/<name>.dart`.
- Theme access: Use `context.colorScheme` or `context.customColors` (`ThemeExtension`). **NO hardcoded `Color(0x...)**`.

- **Global Presentation Modules:**
- `navigation/`: `app_router.dart` (`auto_route`) & `guards/`.
- `theme/`: Theme definitions & `ThemeExtension` implementations.
- `ui_kit/`: Pure, reusable, stateless widgets annotated with `@Preview`.
- `ui_utils/`: UI formatters, extensions (`BuildContext` wrappers).

### 4. Infrastructure Layer (`lib/infrastructure/`)

- **`config/`:** Environment settings, feature flags, API base URLs.
- **`di/`:** GetIt + Injectable setup.
- **`network/`:** Dio client setup, base interceptors, client headers.
- **`utils/`:** System utilities (Loggers, SecureStorage, SharedPreferences wrappers).

---

## Complete Project Structure Matrix

```text
lib/
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
│   └── ui_utils/ # Formatters, UI extensions
│
└── infrastructure/
    ├── config/
    ├── di/
    ├── network/ # Dio setup & interceptors
    └── utils/ # Loggers, SecureStorage, etc.
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
