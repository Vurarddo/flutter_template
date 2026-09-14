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
| **BLoC State Management** | [flutter-bloc-core](../../presentation/state_management/flutter-bloc-core/SKILL.md) | Invoking UseCases from BLoC event handlers. |

---

## 3. Standard Use Case Patterns

### 3.1 Standard Async Query Use Case

```dart
import 'package:injectable/injectable.dart';

import 'package:flutter_template/domain/movies/entities/movie_entity.dart';
import 'package:flutter_template/domain/movies/repositories/i_movie_repository.dart';

@injectable
class GetMovieDetailsUseCase {
  final IMovieRepository _repository;

  GetMovieDetailsUseCase(this._repository);

  Future<MovieEntity> call(String movieId) {
    return _repository.getMovieDetails(movieId);
  }
}
```

---

### 3.2 Command Use Case with Typed Parameter Object

When a UseCase requires more than 2 parameters, encapsulate them in a typed parameter class:

```dart
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_template/domain/movies/repositories/i_movie_repository.dart';

class RateMovieParams extends Equatable {
  final String movieId;
  final double score;
  final String? review;

  const RateMovieParams({
    required this.movieId,
    required this.score,
    this.review,
  });

  @override
  List<Object?> get props => [movieId, score, review];
}

@injectable
class RateMovieUseCase {
  final IMovieRepository _repository;

  RateMovieUseCase(this._repository);

  Future<void> call(RateMovieParams params) {
    return _repository.rateMovie(
      movieId: params.movieId,
      score: params.score,
      review: params.review,
    );
  }
}
```

---

### 3.3 Stream / Reactive Subscription Use Case

```dart
import 'package:injectable/injectable.dart';

import 'package:flutter_template/domain/movies/entities/movie_entity.dart';
import 'package:flutter_template/domain/movies/repositories/i_movie_repository.dart';

@injectable
class WatchFavoriteMoviesUseCase {
  final IMovieRepository _repository;

  WatchFavoriteMoviesUseCase(this._repository);

  Stream<List<MovieEntity>> call() {
    return _repository.watchFavoriteMovies();
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
