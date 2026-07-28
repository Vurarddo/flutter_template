---
name: flutter-error-handling-expert
description: Enforces type-safe, architecture-compliant error handling across all Flutter layers. Guarantees zero unhandled exceptions, strict separation between transport DioExceptions and Domain Failures/Exceptions, mandatory addError stacktrace tracking in BLoCs, absolute prohibition of e.toString() in UI, and global crash monitoring (Crashlytics/Sentry). Use when writing repositories, interceptors, try-catch blocks, BLoC handlers, or error UI components.
---

# Flutter Error Handling & Resilience Expert Skill

## When to Apply

Use this skill whenever catching exceptions, implementing network/database repositories, defining domain failures/exceptions, handling async operations in BLoCs/Cubits, or setting up global crash reporting.

---

## Core Architectural Rules & Standards

1. **Clean Architecture Error Boundaries:**
   - **`Data Layer`:** Captures low-level network/database transport exceptions (`DioException`, `SocketException`, `SqliteException`). Converts them immediately via a mapper before propagating upward.
   - **`Domain Layer`:** Pure Dart. Knows NOTHING about `package:dio`, HTTP status codes, or transport layers. Operates exclusively with sealed `Failure` classes or typed `ApiException` instances.
   - **`Presentation Layer`:** Operates on `Failure` objects or extracts localized user strings via `ApiException.message`. **STRICTLY PROHIBITED:** Calling `e.toString()` for UI displays or leaking `DioException` into BLoCs/Widgets.

2. **No Generic `catch (e)` & Stack Trace Preservation:**
   - Never swallow exceptions silently.
   - When catching unexpected errors inside BLoC handlers, always forward them to the observer via `addError(error, stackTrace)` to preserve stack traces for Crashlytics/Sentry.

3. **User-Facing Error Localisation Interface:**
   - All domain exceptions intended for UI display MUST implement an `ApiException` interface providing a clean `message` getter.

---

## 1. Domain Exceptions & Sealed Failures Contract

Define clean domain-level abstractions with localized messages.

```dart
import 'package:meta/meta.dart';

/// Base interface for domain exceptions that expose localized UI messages
abstract interface class ApiException implements Exception {
  String get message;
}

/// Sealed Failure hierarchy for pattern-matching in presentation
@immutable
sealed class Failure implements ApiException {
  @override
  final String message;
  final String? code;

  const Failure({required this.message, this.code});
}

final class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({required super.message, super.code, this.statusCode});
}

final class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Перевірте підключення до інтернету'});
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message = 'Сесія вичерпана. Авторизуйтесь знову'});
}

final class UnknownFailure extends Failure {
  final Object? error;
  final StackTrace? stackTrace;

  const UnknownFailure({
    super.message = 'Сталася несподівана помилка',
    this.error,
    this.stackTrace,
  });
}

```

---

## 2. Data Layer: Repository Exception Mapping

Repositories MUST capture transport errors and convert them into Domain Failures/Exceptions. Never let `DioException` escape the Data layer.

```dart
import 'dart:io';
import 'package:dio/dio.dart';

abstract final class DioExceptionMapper {
  static Failure mapToFailure(Object error, StackTrace stackTrace) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return const NetworkFailure();

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401 || statusCode == 403) {
            return const UnauthorizedFailure();
          }
          return ServerFailure(
            statusCode: statusCode,
            message: error.response?.data?['message']?.toString() ?? 'Помилка сервера',
            code: error.response?.data?['code']?.toString(),
          );

        case DioExceptionType.cancel:
          return const UnknownFailure(message: 'Запит було скасовано');

        default:
          return UnknownFailure(error: error, stackTrace: stackTrace);
      }
    }

    if (error is SocketException) {
      return const NetworkFailure();
    }

    if (error is Failure) return error;

    return UnknownFailure(error: error, stackTrace: stackTrace);
  }
}

// Example Repository Implementation
class UserRepositoryImpl implements UserRepository {
  final UserApiClient _apiClient;

  UserRepositoryImpl(this._apiClient);

  @override
  Future<UserData> getUserProfile() async {
    try {
      final response = await _apiClient.getProfile();
      return response.toDomain();
    } catch (error, stackTrace) {
      // Map transport exception to domain Failure before throwing/returning
      throw DioExceptionMapper.mapToFailure(error, stackTrace);
    }
  }
}

```

---

## 3. Safe BLoC Handling & Stack Trace Observability

BLoCs must safely extract localized messages and log stack traces using `addError()`.

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase _getUserProfile;

  ProfileBloc(this._getUserProfile) : super(const ProfileState.initial()) {
    on<ProfileFetchRequested>(_onFetchRequested);
  }

  Future<void> _onFetchRequested(
    ProfileFetchRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileState.loading());

    try {
      final user = await _getUserProfile();
      emit(ProfileState.success(user));
    } catch (error, stackTrace) {
      // 1. Preserve stack trace for observability tools (Crashlytics/Sentry)
      addError(error, stackTrace);

      // 2. Safe message extraction without e.toString()
      final uiMessage = error is ApiException
          ? error.message
          : const UnknownFailure().message;

      emit(ProfileState.failure(uiMessage));
    }
  }
}

```

---

## 4. Root Global Uncaught Exception Catching

Capture unhandled platform and asynchronous Flutter errors at the app root:

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Framework Widget Render Crashes
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _reportCrash(details.exception, details.stack);
    };

    // 2. Uncaught Async / Platform Dispatcher Errors
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      _reportCrash(error, stack);
      return true; // Prevents process crash
    };

    runApp(const MyApp());
  }, (Object error, StackTrace stack) {
    // 3. Fallback Zone Catch
    _reportCrash(error, stack);
  });
}

void _reportCrash(Object error, StackTrace? stack) {
  if (kDebugMode) {
    print('[CRASH LOG]: $error\n$stack');
  } else {
    // FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  }
}

```

---

## Anti-Patterns (Strictly Prohibited)

| Anti-Pattern                                          | Severity     | Corrective Action                                                  |
| ----------------------------------------------------- | ------------ | ------------------------------------------------------------------ |
| Calling `e.toString()` for SnackBar/Dialog UI display | **CRITICAL** | Extract `e.message` from `ApiException` or use localized fallback. |

|
| Importing `package:dio` or checking `DioException` in BLoCs/Widgets | **CRITICAL** | Keep transport details strictly inside Data layer Repositories/Mappers.

|
| Swallowing stack traces in `catch (e)` without calling `addError()` | **HIGH** | Pass `error` and `stackTrace` to `addError(error, stackTrace)` in BLoC handlers.

|
| Returning raw server stack traces (`500 Internal Server Error`) to users | **HIGH** | Map server errors to human-readable localized messages.

|
| Silent empty `catch (e) {}` blocks | **CRITICAL** | Always log or rethrow wrapped domain failures.

|

---

## Agent Verification Checklist

When building or auditing error handling logic:

1. **No Transport Leaks:** `package:dio` or HTTP status code logic is 100% contained within `lib/infrastructure/` or `lib/data/`.

2. **Safe UI Text:** Presentation layer uses `e.message` or `FailureLocalizationX`, NEVER `e.toString()`.

3. **Observability Guard:** BLoC `catch` blocks invoke `addError(error, stackTrace)` to preserve stack traces.

4. **Root Safety:** `main()` configures `FlutterError.onError`, `PlatformDispatcher.instance.onError`, and `runZonedGuarded`.

5. **Domain Interface:** All custom domain exceptions implement `ApiException` with explicit `message` implementations.
