---
name: domain-failures
description: Standards and patterns for modeling typed domain error states in lib/domain/<feature>/failures/ using Dart 3 sealed class hierarchies. Covers compile-time exhaustive pattern matching in BLoCs, value equality with Equatable, and mapping technical exceptions to user-facing domain failures.
---

# Domain Failures & Error Modeling

## 1. Overview & When to Apply

Use this skill whenever:
- Modeling business and domain failure states (`lib/domain/<feature>/failures/`).
- Replacing generic `Exception` objects with strongly typed Dart 3 `sealed class` hierarchies.
- Implementing compile-time exhaustive error handling in BLoCs using `switch` pattern matching.
- Mapping technical data errors (`DioException`, `SocketException`, `PlatformException`) to meaningful domain failures.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [domain-hub](../domain-hub/SKILL.md) | Domain layer architecture and Pure Dart law. |
| **Dio Network Mapper** | [infrastructure-network-dio](../../infrastructure/infrastructure-network-dio/SKILL.md) | Mapping HTTP network errors to Domain Failures. |
| **BLoC Error Handling** | [flutter-bloc-core](../../presentation/state_management/flutter-bloc-core/SKILL.md) | Catching Domain Failures and emitting Failure states. |

---

## 3. Standard Failure Implementation Pattern

Use Dart 3 `sealed class` with `final class` variants extending `Equatable`:

```dart
import 'package:equatable/equatable.dart';

sealed class MovieFailure extends Equatable implements Exception {
  final String message;

  const MovieFailure(this.message);

  @override
  List<Object?> get props => [message];
}

final class MovieNotFoundFailure extends MovieFailure {
  const MovieNotFoundFailure({String message = 'The requested movie was not found.'})
      : super(message);
}

final class MovieQuotaExceededFailure extends MovieFailure {
  const MovieQuotaExceededFailure({String message = 'Daily movie watch limit exceeded.'})
      : super(message);
}

final class MovieNetworkFailure extends MovieFailure {
  const MovieNetworkFailure({String message = 'Unable to reach the movie server. Please check connection.'})
      : super(message);
}

final class MovieUnknownFailure extends MovieFailure {
  final Object? error;
  final StackTrace? stackTrace;

  const MovieUnknownFailure({
    String message = 'An unexpected error occurred.',
    this.error,
    this.stackTrace,
  }) : super(message);

  @override
  List<Object?> get props => [message, error];
}
```

---

## 4. Pattern Matching in BLoCs (Dart 3 `switch`)

Inside BLoC event handlers:

```dart
void _onFetchMovieDetails(FetchMovieDetails event, Emitter<MovieState> emit) async {
  emit(const MovieState.inProgress());
  try {
    final movie = await _getMovieDetailsUseCase(event.movieId);
    if (emit.isDone) return;
    emit(MovieState.success(movie));
  } on MovieFailure catch (failure) {
    if (emit.isDone) return;
    final userMessage = switch (failure) {
      MovieNotFoundFailure(:final message) => message,
      MovieQuotaExceededFailure(:final message) => message,
      MovieNetworkFailure(:final message) => message,
      MovieUnknownFailure(:final message) => message,
    };
    emit(MovieState.failure(userMessage));
  }
}
```

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Exposing raw `DioException` or `HttpException` in Domain Failure fields | **CRITICAL** | Store only generic error objects or mapped string messages. |
| Using `String` error messages directly without typed failure classes | **HIGH** | Create a typed `sealed class` for the feature domain. |
| Using `dartz` `Left(Failure)` instead of throwing/returning typed failures | **MEDIUM** | Throw typed `DomainFailure` or return a sealed Result object. |

---

## 6. Verification Checklist

- [ ] Base failure class is declared as `sealed class <Feature>Failure`.
- [ ] Sub-failures use `final class` and extend base failure.
- [ ] Implements `Exception` and extends `Equatable` for value comparison in tests.
- [ ] Zero UI or transport imports in failure files.
