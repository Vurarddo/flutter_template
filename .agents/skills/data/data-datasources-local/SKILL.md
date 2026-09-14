---
name: data-datasources-local
description: Standards and patterns for Local Data Sources and caching in lib/data/<feature>/datasources/. Covers in-memory caching, local database DAOs (SQLite, Drift, Isar), Time-To-Live (TTL) cache invalidation, and offline persistence.
---

# Local Data Sources & Caching

## 1. Overview & When to Apply

Use this skill whenever:
- Implementing local database access or caching in `lib/data/<feature>/datasources/`.
- Building in-memory cache layers to prevent redundant network requests.
- Implementing Time-To-Live (TTL) cache invalidation policies.
- Storing offline DTO snapshots in local databases (SQLite, Drift, Isar, Hive).

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [data-hub](../data-hub/SKILL.md) | Data layer architecture and data source roles. |
| **Storage Interactors** | [infrastructure-storage](../../infrastructure/infrastructure-storage/SKILL.md) | Key-value storage for simple flags and settings. |
| **DTOs & Mappers** | [data-dto-mappers](../data-dto-mappers/SKILL.md) | Storing and restoring DTO records. |

---

## 3. Standard In-Memory TTL Cache Pattern

```dart
import 'package:injectable/injectable.dart';
import 'package:flutter_template/data/item/dto/item_dto.dart';

@lazySingleton
class ItemLocalDataSource {
  final Map<String, _CacheEntry<ItemDto>> _itemCache = {};
  static const Duration _cacheTtl = Duration(minutes: 15);

  Future<ItemDto?> getCachedItem(String itemId) async {
    final entry = _itemCache[itemId];
    if (entry == null) return null;

    if (DateTime.now().isAfter(entry.expiresAt)) {
      _itemCache.remove(itemId);
      return null;
    }

    return entry.data;
  }

  Future<void> cacheItem(ItemDto item) async {
    _itemCache[item.id.toString()] = _CacheEntry(
      data: item,
      expiresAt: DateTime.now().add(_cacheTtl),
    );
  }

  void clearCache() => _itemCache.clear();
}

class _CacheEntry<T> {
  final T data;
  final DateTime expiresAt;

  const _CacheEntry({
    required this.data,
    required this.expiresAt,
  });
}
```

---

## 4. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Allowing memory caches to grow unbounded without TTL or limit | **HIGH** | Set TTL expiration and size limit / eviction policy. |
| Injecting local data sources directly into Domain UseCases | **CRITICAL** | Data sources must only be accessed by Data Repositories. |
| Storing sensitive auth tokens in non-encrypted local cache | **CRITICAL** | Tokens must be stored in `SecureStoreInteractor`. |

---

## 5. Verification Checklist

- [ ] Data source is placed in `lib/data/<feature>/datasources/`.
- [ ] Annotated with `@lazySingleton` via `injectable`.
- [ ] TTL or cache eviction policy is implemented for memory caches.
- [ ] Exclusively consumed by Repository implementations in `lib/data/`.
