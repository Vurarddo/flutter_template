---
name: data-hub
description: Primary coordinator and architecture guide for the Data layer (lib/data/). Enforces Clean Architecture data provider boundaries, DTO encapsulation, inline toDomain() mapping standards, Retrofit API clients, and repository implementations.
---

# Data Layer Coordinator & Architecture Hub

## 1. Overview & Data Layer Scope

The `lib/data/` directory serves as the **Execution Engine and Data Provider** of the application. It is responsible for fetching, persisting, serializing, deserializing, and mapping raw data into clean Domain Entities.

### Core Architectural Laws:
1. **DTO Encapsulation (Zero Leakage):**
   - Data Transfer Objects (DTOs) and raw JSON models MUST stay strictly inside `lib/data/`.
   - DTOs are **STRICTLY PROHIBITED** from crossing into the Domain (`lib/domain/`) or Presentation (`lib/presentation/`) layers.
2. **Inline Mappers Standard:**
   - Every DTO must contain an explicit `toDomain()` method (and helper mappers) directly inside `<feature>_dto.dart`.
   - Standalone `mappers/` folders with redundant boilerplate classes are prohibited.
3. **Implements Domain Contracts:**
   - Repositories in Data implement the abstract interfaces defined in Domain (`[Feature]RepositoryImpl implements I[Feature]Repository`).
4. **Error Transformation Boundary:**
   - Low-level network exceptions (`DioException`, socket errors) must be caught in Data and mapped into typed `DomainFailure` states before rethrowing.

---

## 2. Data Skill Tree & Routing Matrix

Use this matrix to navigate to the specialized sub-skill matching your task:

| Sub-Domain | Target Sub-Skill | Purpose |
| :--- | :--- | :--- |
| **DTOs & Inline Mappers** | [data-dto-mappers](../data-dto-mappers/SKILL.md) | `@JsonSerializable` DTOs, `@JsonKey`, `toDomain()` mapping, collections, enums, null safety. |
| **Retrofit API Clients** | [data-retrofit-clients](../data-retrofit-clients/SKILL.md) | Retrofit `@RestApi()` interfaces, `[Feature]Endpoints` route constants, `@CancelRequest()`. |
| **Repository Implementations** | [data-repositories](../data-repositories/SKILL.md) | `[Feature]RepositoryImpl`, data source orchestration, `DioExceptionMapper` error transformation. |
| **Local Data Sources & Cache** | [data-datasources-local](../data-datasources-local/SKILL.md) | Local caching, in-memory caches, SQLite/Drift DAOs, TTL cache invalidation. |
| **Domain Layer Hub** | [domain-hub](../../domain/domain-hub/SKILL.md) | Domain entities, use cases, repository interfaces, and failures. |
| **Infrastructure Layer Hub** | [infrastructure-hub](../../infrastructure/infrastructure-hub/SKILL.md) | Dio network configuration, storage interactors, external SDKs. |
| **Clean Architecture Hub** | [flutter-clean-architecture](../../flutter-clean-architecture/SKILL.md) | Global layer boundaries and DDD dependency flow. |

---

## 3. Directory Standard for `lib/data/<feature>/`

```text
lib/data/<feature>/
├── endpoints/                       # API route constants
│   └── <feature>_endpoints.dart
├── dto/                             # Data Transfer Objects with json_serializable & toDomain()
│   ├── <feature>_dto.dart
│   ├── <feature>_dto.g.dart
│   ├── <feature>_response_dto.dart
│   └── <feature>_response_dto.g.dart
├── client/                          # Retrofit @RestApi clients
│   ├── <feature>_api_client.dart
│   └── <feature>_api_client.g.dart
├── datasources/                     # Local or specialized data sources
│   ├── <feature>_local_datasource.dart
│   └── <feature>_remote_datasource.dart
└── repositories/                    # Repository implementations (implements I<Feature>Repository)
    └── <feature>_repository_impl.dart
```

---

## 4. Technical Constraints & Architecture Rules

1. **Package Imports:** ALWAYS use package imports (`import 'package:flutter_template/...';`).
2. **Dependency Direction:** Data depends on **Domain** (to implement interfaces and return Entities) and **Infrastructure** (for `Dio`, `Storage`). Domain NEVER depends on Data.
3. **No UI Imports:** Data layer must have zero imports from `package:flutter/material.dart` or UI widgets.
4. **No Business Rules:** Data layer handles extraction and mapping. Validation of business invariants belongs to Domain UseCases or Entities.

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Exposing DTO classes to BLoC or Domain UseCases | **CRITICAL** | Call `dto.toDomain()` inside Repository Implementation before returning. |
| Creating separate `mappers/` folders for 1-line mappings | **LOW** | Move `toDomain()` method directly into `<feature>_dto.dart`. |
| Hardcoding raw route strings directly in Retrofit `@GET('/api/v1/...')` | **HIGH** | Extract routes to `[Feature]Endpoints` static constants. |
| Letting unhandled `DioException` propagate to Presentation | **HIGH** | Map via `DioExceptionMapper.mapToFailure(e)` to typed Domain Failure. |

---

## 6. Master Data Verification Checklist

- [ ] All DTOs are located in `lib/data/<feature>/dto/` with `toDomain()` methods.
- [ ] Code generation (`build_runner`) generates `*.g.dart` without errors.
- [ ] Repository implementations are bound to Domain interfaces via `@LazySingleton(as: IRepository)`.
- [ ] All API client endpoints use static constants from `endpoints/`.
- [ ] DTOs are never imported outside `lib/data/`.
