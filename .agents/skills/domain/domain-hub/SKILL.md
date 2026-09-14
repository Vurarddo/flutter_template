---
name: domain-hub
description: Primary coordinator and architecture guide for the Domain layer (lib/domain/). Enforces Clean Architecture DDD principles, 100% pure Dart boundaries (zero Flutter/Dio/Storage imports), Single Responsibility UseCases, Freezed 3+ immutable entities, abstract repository interfaces, and Dart 3 sealed failures.
---

# Domain Layer Coordinator & Architecture Hub

## 1. Overview & Domain Layer Core Laws

The `lib/domain/` directory is the **architectural heart and core business engine** of the application. It models business concepts, domain entities, use cases, repository contracts, and failure states.

### Non-Negotiable Domain Laws:
1. **100% Pure Dart (Strict Framework Independence):**
   - Strictly **PROHIBITED** to import `package:flutter/...`, `dart:ui`, `dio`, `retrofit`, `shared_preferences`, `flutter_secure_storage`, or `firebase_*`.
   - Domain logic must be 100% decoupled from transport protocols, databases, and UI frameworks.
2. **Strict Layer Boundary & Dependency Inversion:**
   - Domain is the innermost layer. It depends **ONLY** on `lib/core/`.
   - Outer layers (`lib/data/`, `lib/presentation/`, `lib/infrastructure/`) depend on Domain. Domain NEVER imports outer layers.
3. **Single Responsibility UseCases (SRP):**
   - Every business scenario is represented by a dedicated UseCase class implementing a single `call()` method.
4. **Clean Domain Entities (Freezed 3+ per `build.yaml`):**
   - Domain models use `@freezed` (or `Equatable`) without JSON serialization (`fromJson`/`toJson`) or union methods (`when`/`map`).

---

## 2. Domain Skill Tree & Routing Matrix

Use this matrix to navigate to the specialized sub-skill matching your task:

| Sub-Domain | Target Sub-Skill | Purpose |
| :--- | :--- | :--- |
| **Entities & Freezed 3+** | [domain-entities-freezed](../domain-entities-freezed/SKILL.md) | Immutable Domain Entities, `@freezed` 3+ syntax, `Equatable` value objects, collection immutability. |
| **Use Cases & Interactors** | [domain-usecases](../domain-usecases/SKILL.md) | SRP UseCases, `call()` method signature, typed parameters, error handling, BLoC interaction rules. |
| **Repository Contracts** | [domain-repositories](../domain-repositories/SKILL.md) | `abstract class I<Feature>Repository` contracts, method signatures, stream contracts. |
| **Domain Failures** | [domain-failures](../domain-failures/SKILL.md) | Dart 3 `sealed class` failure hierarchies, business error modeling, pattern matching. |
| **Core Layer Hub** | [core-hub](../../core/core-hub/SKILL.md) | Pure Dart primitives, extensions, and utilities. |
| **Clean Architecture Hub** | [flutter-clean-architecture](../../flutter-clean-architecture/SKILL.md) | Global architectural boundaries and DDD rules. |

---

## 3. Directory Standard for `lib/domain/<feature>/`

```text
lib/domain/<feature>/
├── entities/                        # Pure business entities (Freezed 3+ / Equatable)
│   ├── <feature>_entity.dart
│   └── value_objects/
├── usecases/                        # Single-responsibility business actions (callable classes)
│   ├── get_<feature>_usecase.dart
│   ├── create_<feature>_usecase.dart
│   └── watch_<feature>_stream_usecase.dart
├── repositories/                    # Abstract interface contracts
│   └── i_<feature>_repository.dart
└── failures/                        # Dart 3 sealed class failure hierarchies
    └── <feature>_failure.dart
```

---

## 4. Layer Interaction Contract

```text
UI (Widgets)
  └── BLoC / Cubit
        └── UseCase (Domain)
              └── Repository Interface (Domain)
                    ▲
                    │ (Implements)
              Repository Implementation (Data)
                    └── Data Source / API Client (Data / Infrastructure)
```

- BLoCs interact **ONLY** with UseCases.
- UseCases interact **ONLY** with Repository Interfaces (`IRepository`).
- DTOs never enter Domain; all transport models are converted via `toDomain()` in the Data layer.

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Importing `package:flutter/*` or `dio` in `lib/domain/` | **CRITICAL** | Keep Domain pure Dart; move UI/network code to appropriate outer layers. |
| Generating or calling `fromJson`, `toJson`, `when`, `map` on Freezed Domain Entities | **CRITICAL** | DTOs in Data handle JSON; use native Dart 3 `switch` for pattern matching. |
| BLoC directly calling `IRepository` bypassing UseCases | **HIGH** | Create a dedicated single-action `UseCase` and inject it into BLoC. |
| Using `dartz` / `fpdart` `Either` for failure handling | **HIGH** | Use typed Dart 3 `sealed class` failure models or typed exceptions. |

---

## 6. Master Domain Verification Checklist

- [ ] Zero Flutter SDK or external transport imports in `lib/domain/`.
- [ ] Entities use Freezed 3+ body syntax without `fromJson`/`toJson`/`when`/`map`.
- [ ] UseCases have a single responsibility with a typed `call()` method.
- [ ] Repositories are defined as abstract classes prefixed with `I` (e.g. `IAuthRepository`).
- [ ] Failures are modeled via Dart 3 `sealed class` hierarchies.
