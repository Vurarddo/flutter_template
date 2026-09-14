---
name: testing-unit
description: Standards and patterns for Pure Dart Unit Tests in test/domain/, test/data/, and test/core/. Covers testing UseCases, Repository implementations with Mocktail, DTO toDomain() mappers, Core utilities/extensions, and edge-case error assertions.
---

# Pure Dart Unit Testing Standard

## 1. Overview & When to Apply

Use this skill whenever:
- Testing Domain UseCases (`test/domain/<feature>/usecases/`).
- Testing Data Repository implementations (`test/data/<feature>/repositories/`) using `mocktail`.
- Testing DTO JSON serialization and `toDomain()` mapping accuracy (`test/data/<feature>/dto/`).
- Testing Core layer utilities, formatters, and pure Dart extensions (`test/core/`).
- Writing fast, deterministic unit tests without Flutter SDK or UI rendering dependencies.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [testing-hub](../testing-hub/SKILL.md) | Testing strategy and pyramid overview. |
| **Domain UseCases** | [domain-usecases](../../domain/domain-usecases/SKILL.md) | UseCase contracts being tested. |
| **Data Mappers** | [data-dto-mappers](../../data/data-dto-mappers/SKILL.md) | DTO `toDomain()` conversion standards. |
| **BLoC Testing** | [testing-bloc](../testing-bloc/SKILL.md) | Testing state machines using these unit-tested UseCases. |

---

## 3. Pure Dart Testing Philosophy

1. **Zero UI Framework Dependencies:** Run tests with pure `flutter_test` (or `test`) without rendering widgets.
2. **Mocktail for External Dependencies:** Mock interfaces cleanly with `when(() => ...).thenAnswer(...)`.
3. **Verify Contract Invariants:** Test both the happy path (returning Entity) and failure path (throwing typed Failure).

---

## 4. Reference Implementations (`examples/`)

- **Domain UseCase Unit Test:** [examples/usecase_unit_test.dart](examples/usecase_unit_test.dart)
  - Unit test verifying repository invocation and exception propagation using Mocktail.
- **DTO JSON & Mapper Unit Test:** [examples/dto_mapper_unit_test.dart](examples/dto_mapper_unit_test.dart)
  - Testing `fromJson()` deserialization and defensive fallback mapping in `toDomain()`.

---

## 5. Verification Checklist

- [ ] Tests execute under `flutter test test/domain/` and `flutter test test/data/`.
- [ ] Mocks implement clean domain repository interfaces.
- [ ] `verify(() => ...).called(1)` and `verifyNoMoreInteractions(...)` are asserted.
- [ ] Safe fallback values tested for missing/null API keys.
