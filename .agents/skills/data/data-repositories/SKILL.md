---
name: data-repositories
description: Standards and patterns for Repository Implementations in lib/data/<feature>/repositories/. Covers implementing Domain repository contracts (implements I<Feature>Repository), orchestrating remote API clients and local caches, converting DTOs via toDomain(), mapping DioException to typed Domain Failures, and DI registration via @LazySingleton(as: IRepository).
---

# Data Repository Implementations

## 1. Overview & When to Apply

Use this skill whenever:
- Implementing Domain repository interface contracts (`lib/data/<feature>/repositories/`).
- Coordinating remote API clients (`Retrofit`), local caches (`Storage`), and in-memory caches.
- Mapping response DTOs into Domain Entities via `toDomain()` before returning data upward.
- Catching transport exceptions (`DioException`) and mapping them into typed `DomainFailure` states.
- Registering repository implementations in GetIt using `@LazySingleton(as: I<Feature>Repository)`.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [data-hub](../data-hub/SKILL.md) | Data layer architecture and implementation rules. |
| **Domain Contracts** | [domain-repositories](../../domain/domain-repositories/SKILL.md) | Domain `I<Feature>Repository` interface being implemented. |
| **DTOs & Mappers** | [data-dto-mappers](../data-dto-mappers/SKILL.md) | Converting DTOs into Domain Entities via `toDomain()`. |
| **Error Mapping** | [infrastructure-network-dio](../../infrastructure/infrastructure-network-dio/SKILL.md) | Mapping `DioException` via `DioExceptionMapper`. |

---

## 3. Standard Repository Implementation Pattern

```dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_template/data/item/client/item_api_client.dart';
import 'package:flutter_template/domain/core/failures/domain_failure.dart';
import 'package:flutter_template/domain/item/entities/item_entity.dart';
import 'package:flutter_template/domain/item/repositories/i_item_repository.dart';
import 'package:flutter_template/infrastructure/network/error_handler/dio_exception_mapper.dart';

@LazySingleton(as: IItemRepository)
class ItemRepositoryImpl implements IItemRepository {
  final ItemApiClient _apiClient;

  ItemRepositoryImpl(this._apiClient);

  @override
  Future<List<ItemEntity>> getItems({
    required int page,
    int? limit,
    String? category,
  }) async {
    try {
      final responseDto = await _apiClient.getItems(page: page);
      return responseDto.toDomainList();
    } on DioException catch (e) {
      throw DioExceptionMapper.mapToFailure(e);
    } catch (e, st) {
      throw DomainFailure.unknown(message: e.toString(), stackTrace: st);
    }
  }

  @override
  Future<ItemEntity> getItemDetails(String itemId) async {
    try {
      final dto = await _apiClient.getItemDetails(itemId);
      return dto.toDomain();
    } on DioException catch (e) {
      throw DioExceptionMapper.mapToFailure(e);
    } catch (e, st) {
      throw DomainFailure.unknown(message: e.toString(), stackTrace: st);
    }
  }

  @override
  Future<List<ItemEntity>> searchItems(String query) async {
    try {
      final responseDto = await _apiClient.searchItems(query);
      return responseDto.toDomainList();
    } on DioException catch (e) {
      throw DioExceptionMapper.mapToFailure(e);
    } catch (e, st) {
      throw DomainFailure.unknown(message: e.toString(), stackTrace: st);
    }
  }

  @override
  Stream<List<ItemEntity>> watchFavoriteItems() {
    // Local stream observation
    throw UnimplementedError();
  }

  @override
  Future<void> toggleFavorite({
    required String itemId,
    required bool isFavorite,
  }) async {
    // Local cache/remote toggle
  }

  @override
  Future<void> updateItemRating({
    required String itemId,
    required double score,
    String? review,
  }) async {
    // Remote API execution
  }
}
```

---

## 4. Cache-First Repository Strategy

When implementing offline-first or caching repositories:

```dart
@override
Future<List<ItemEntity>> getItems({required int page}) async {
  // 1. Read from local cache first if page == 1
  if (page == 1) {
    final cached = await _localDataSource.getCachedItems();
    if (cached.isNotEmpty) {
      // Background sync without blocking immediate cache return
      _syncRemoteItems(page);
      return cached.map((e) => e.toDomain()).toList();
    }
  }

  // 2. Fetch from remote API
  try {
    final response = await _apiClient.getItems(page: page);
    final entities = response.toDomainList();

    // 3. Save to local cache
    await _localDataSource.saveItems(response.results ?? []);
    return entities;
  } on DioException catch (e) {
    throw DioExceptionMapper.mapToFailure(e);
  }
}
```

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Returning raw DTO objects from Repository implementation | **CRITICAL** | Call `dto.toDomain()` before returning data to UseCases. |
| Letting raw `DioException` escape without domain mapping | **HIGH** | Catch `DioException` and throw `DioExceptionMapper.mapToFailure(e)`. |
| Injecting UI `BuildContext` into a Repository | **CRITICAL** | Repositories must remain 100% decoupled from UI. |
| Placing domain business rules inside Repository methods | **HIGH** | Validation rules belong in UseCases or Domain Entities. |

---

## 6. Verification Checklist

- [ ] Repository implements the abstract Domain interface (`implements I<Feature>Repository`).
- [ ] Annotated with `@LazySingleton(as: I<Feature>Repository)` for DI.
- [ ] Returns pure Domain Entities (zero DTOs leak out).
- [ ] All `DioException` instances are caught and mapped to typed Domain Failures.
- [ ] Unit tests verify happy path, network error mapping, and cache fallbacks.
