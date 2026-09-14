---
name: domain-repositories
description: Standards and patterns for defining abstract Repository Interfaces in lib/domain/<feature>/repositories/. Covers pure Dart interface contracts, method signatures, Stream contracts, and enforcing Dependency Inversion between Domain and Data.
---

# Domain Repository Interfaces & Contracts

## 1. Overview & When to Apply

Use this skill whenever:
- Designing new repository interface contracts in `lib/domain/<feature>/repositories/`.
- Declaring abstract data access methods returning Domain Entities or reactive Streams.
- Enforcing the Dependency Inversion Principle (Domain owns the contract; Data provides the implementation).

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [domain-hub](../domain-hub/SKILL.md) | Domain layer architecture and Pure Dart law. |
| **Domain Entities** | [domain-entities-freezed](../domain-entities-freezed/SKILL.md) | Models returned by repository methods. |
| **Data Implementations** | [flutter-clean-architecture](../../flutter-clean-architecture/SKILL.md) | Implementing `IRepository` in `lib/data/<feature>/repositories/`. |

---

## 3. Standard Interface Contract Pattern

Repository interfaces must be named with an `I` prefix (e.g. `IItemRepository`, `IAuthRepository`) and defined as an `abstract interface class` or `abstract class`:

```dart
import 'package:flutter_template/domain/items/entities/item_entity.dart';

abstract interface class IItemRepository {
  /// Fetches a paginated list of items.
  Future<List<ItemEntity>> getItems({
    required int page,
    int? limit,
    String? category,
  });

  /// Fetches details for a specific item.
  Future<ItemEntity> getItemDetails(String id);

  /// Searches items by query string.
  Future<List<ItemEntity>> searchItems(String query);

  /// Subscribes to real-time updates for favorite items.
  Stream<List<ItemEntity>> watchFavoriteItems();

  /// Toggles favorite status for an item.
  Future<void> toggleFavorite({
    required String id,
    required bool isFavorite,
  });

  /// Updates or saves an item.
  Future<void> updateItem({
    required String id,
    required String title,
    String? description,
  });
}
```

---

## 4. Contract Rules & Constraints

1. **Pure Domain Types:** Method parameters and return types must be pure Dart primitives (`String`, `int`, `DateTime`) or Domain Entities (`ItemEntity`). NEVER use DTOs or API response models in repository contracts.
2. **Asynchronous & Reactive:** Use `Future<T>` for one-shot requests and `Stream<T>` for real-time/cached observations.
3. **No Transport Exceptions in Signatures:** Do not throw raw `DioException` or `SqliteException` across this boundary. The Data layer implementation is responsible for catching technical exceptions and throwing typed Domain Failures.
4. **No Either / fpdart / dartz:** Method signatures should return pure `Future<T>` and throw typed `DomainFailure` states instead of using `Either<Failure, T>` wrappers.

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Returning Data DTOs from Repository Interface methods | **CRITICAL** | Return Domain Entities mapped via `toDomain()`. |
| Importing `package:dio` or `package:retrofit` in `lib/domain/` | **CRITICAL** | Remove transport dependencies; contracts must be pure Dart. |
| Leaking implementation details (e.g. `isCacheOnly`, `sqlQuery`) in contract | **HIGH** | Design contracts around business needs, not technical mechanisms. |
| Using `dartz` `Either` for return types | **MEDIUM** | Return `Future<Entity>` and let typed `DomainFailure` propagate. |

---

## 6. Verification Checklist

- [ ] Interface is defined in `lib/domain/<feature>/repositories/i_<feature>_repository.dart`.
- [ ] Name starts with `I` (e.g. `IItemRepository`).
- [ ] Returns pure Domain Entities or Dart primitives.
- [ ] Zero imports from `data/`, `presentation/`, or external networking packages.
