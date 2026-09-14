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
| **Error Handling Hub** | [error-handling-hub](../../error-handling/error-handling-hub/SKILL.md) | End-to-end error lifecycle and resilience rules. |
| **Localization Mapping** | [l10n-presentation-integration](../../l10n/l10n-presentation-integration/SKILL.md) | Mapping Domain Failures to localized UI messages. |
| **BLoC Error Handling** | [flutter-bloc-core](../../presentation/state-management/flutter-bloc-core/SKILL.md) | Catching Domain Failures and emitting Failure states. |

---

## 3. Standard Failure Implementation Pattern

Use Dart 3 `sealed class` with `final class` variants extending `Equatable`:

```dart
import 'package:equatable/equatable.dart';

sealed class ItemFailure extends Equatable implements Exception {
  final String message;

  const ItemFailure(this.message);

  @override
  List<Object?> get props => [message];
}

final class ItemNotFoundFailure extends ItemFailure {
  const ItemNotFoundFailure({String message = 'The requested resource was not found.'})
      : super(message);
}

final class ItemQuotaExceededFailure extends ItemFailure {
  const ItemQuotaExceededFailure({String message = 'Action quota exceeded.'})
      : super(message);
}

final class ItemNetworkFailure extends ItemFailure {
  const ItemNetworkFailure({String message = 'Unable to reach the server. Please check connection.'})
      : super(message);
}

final class ItemUnknownFailure extends ItemFailure {
  final Object? error;
  final StackTrace? stackTrace;

  const ItemUnknownFailure({
    String message = 'An unexpected error occurred.',
    this.error,
    this.stackTrace,
  }) : super(message);

  @override
  List<Object?> get props => [message, error];
}
```

---

## 4. Pattern Matching in BLoCs & State Emission

Inside BLoC event handlers, always emit the typed `DomainFailure` directly in the state, and let the Presentation layer resolve user messages via `DomainFailureLocalizationX`:

```dart
Future<void> _onFetchItemDetails(
  FetchItemDetails event,
  Emitter<ItemState> emit,
) async {
  emit(const ItemState.inProgress());
  try {
    final item = await _getItemDetailsUseCase(event.id);
    if (emit.isDone) return;
    emit(ItemState.success(item));
  } catch (error, stackTrace) {
    // Preserve stack trace for observability
    addError(error, stackTrace);

    if (emit.isDone) return;

    final failure = error is ItemFailure
        ? error
        : const ItemUnknownFailure();

    emit(ItemState.failure(failure));
  }
}
```

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Using `dartz` or `fpdart` (`Either<Failure, T>`, `Left()`, `Right()`) | **CRITICAL** | **STRICTLY PROHIBITED.** Use native Dart 3 `sealed class` hierarchies or typed exceptions. |
| Exposing raw `DioException` or `HttpException` in Domain Failure fields | **CRITICAL** | Store only domain-level error codes or mapped domain concepts. |
| Using unstructured `String` error messages directly without typed failure classes | **HIGH** | Create a typed `sealed class` for the feature domain. |
| Hardcoding English or Ukrainian UI strings inside `DomainFailure` | **HIGH** | Domain failures contain error codes; UI resolves copy via `context.localization`. |

---

## 6. Verification Checklist

- [ ] Base failure class is declared as `sealed class <Feature>Failure` (or extends `DomainFailure`).
- [ ] Sub-failures use `final class` and extend base failure.
- [ ] Implements `Exception` and extends `Equatable` for value comparison in tests.
- [ ] Zero UI, transport (`Dio`), or functional library (`dartz`/`fpdart`) imports in failure files.
