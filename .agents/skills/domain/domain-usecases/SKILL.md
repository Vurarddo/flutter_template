---
name: domain-usecases
description: Standards and patterns for creating Single Responsibility UseCases (Interactors) in lib/domain/<feature>/usecases/. Covers callable class call() methods, typed input parameters, @injectable DI registration, error propagation, and enforcing the mandatory UseCase boundary between BLoC and Repositories.
---

# Domain Use Cases & Interactors

## 1. Overview & When to Apply

Use this skill whenever:
- Implementing business operations in `lib/domain/<feature>/usecases/`.
- Creating single-responsibility callable UseCase classes (`call()` method).
- Defining strongly typed parameter objects for complex use cases.
- Enforcing the rule that BLoCs/Cubits MUST ONLY interact with Use Cases, never Repositories directly.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [domain-hub](../domain-hub/SKILL.md) | Domain layer architecture and Pure Dart law. |
| **Repository Contracts** | [domain-repositories](../domain-repositories/SKILL.md) | Abstract `IRepository` interfaces consumed by UseCases. |
| **DI Setup** | [infrastructure-di](../../infrastructure/infrastructure-di/SKILL.md) | Registering UseCases as `@injectable` (Factory). |
| **BLoC State Management** | [flutter-bloc-core](../../presentation/state-management/flutter-bloc-core/SKILL.md) | Invoking UseCases from BLoC event handlers. |

---

## 3. Standard Use Case Patterns

### 3.1 Standard Async Query Use Case

```dart
import 'package:injectable/injectable.dart';

import 'package:flutter_template/domain/items/entities/item_entity.dart';
import 'package:flutter_template/domain/items/repositories/i_item_repository.dart';

@injectable
class GetItemDetailsUseCase {
  final IItemRepository _repository;

  GetItemDetailsUseCase(this._repository);

  Future<ItemEntity> call(String id) {
    return _repository.getItemDetails(id);
  }
}
```

---

### 3.2 Command Use Case with Typed Parameter Object

When a UseCase requires more than 2 parameters, encapsulate them in a typed parameter class:

```dart
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_template/domain/items/repositories/i_item_repository.dart';

class UpdateItemParams extends Equatable {
  final String id;
  final String title;
  final String? description;

  const UpdateItemParams({
    required this.id,
    required this.title,
    this.description,
  });

  @override
  List<Object?> get props => [id, title, description];
}

@injectable
class UpdateItemUseCase {
  final IItemRepository _repository;

  UpdateItemUseCase(this._repository);

  Future<void> call(UpdateItemParams params) {
    return _repository.updateItem(
      id: params.id,
      title: params.title,
      description: params.description,
    );
  }
}
```

---

### 3.3 Stream / Reactive Subscription Use Case

```dart
import 'package:injectable/injectable.dart';

import 'package:flutter_template/domain/items/entities/item_entity.dart';
import 'package:flutter_template/domain/items/repositories/i_item_repository.dart';

@injectable
class WatchFavoriteItemsUseCase {
  final IItemRepository _repository;

  WatchFavoriteItemsUseCase(this._repository);

  Stream<List<ItemEntity>> call() {
    return _repository.watchFavoriteItems();
  }
}
```

---

## 4. Mandatory Layer Boundaries

```text
❌ PROHIBITED:
UI -> BLoC -> Repository (Directly) -> Data Source

✅ MANDATORY:
UI -> BLoC -> UseCase -> IRepository (Domain) <- RepositoryImpl (Data)
```

1. **One Action Per UseCase:** Do not create monolithic "Manager" or "Service" classes in Domain. Each file contains exactly one business action.
2. **Factory Lifecycle:** Always annotate UseCases with `@injectable` (Factory) so each BLoC/Cubit gets a dedicated instance.

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| BLoC directly injecting and calling `IRepository` | **CRITICAL** | Extract logic into a single-purpose `UseCase` class. |
| Multi-action UseCase with multiple public methods (`get()`, `update()`, `delete()`) | **HIGH** | Split into `GetUseCase`, `UpdateUseCase`, `DeleteUseCase`. |
| Catching and swallowing exceptions inside UseCase without rethrowing typed Domain Failures | **HIGH** | Let typed failures propagate to BLoC or map them cleanly. |
| Annotating UseCases with `@singleton` or `@lazySingleton` | **MEDIUM** | Use `@injectable` (Factory) for stateless business interactors. |

---

## 6. Verification Checklist

- [ ] UseCase class contains exactly one public method: `call()`.
- [ ] Annotated with `@injectable` for DI registration.
- [ ] Depends strictly on Domain Repository interfaces (`IRepository`), not Data implementations.
- [ ] Zero Flutter SDK imports (`package:flutter/*`).
- [ ] Covered with unit tests mocking the `IRepository` dependency.
