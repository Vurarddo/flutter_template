---
name: infrastructure-network-dio
description: Standards and patterns for the Dio networking layer in lib/infrastructure/network/. Covers centralized BaseOptions, BackgroundTransformer (isolate JSON parsing), single-flight 401 QueuedInterceptor, SSL pinning, network logging, and mapping DioException to typed Domain Failures.
---

# Infrastructure Network & Dio Client Architecture

## 1. Overview & When to Apply

Use this skill whenever:
- Configuring the primary `Dio` instance, timeouts, base options, and headers.
- Implementing custom `Interceptor` or `QueuedInterceptor` classes (auth tokens, retry, network logging).
- Offloading heavy JSON serialization to background isolates via `BackgroundTransformer`.
- Mapping `DioException` to typed Domain Failures in `DioExceptionMapper`.
- Implementing SSL Pinning or Certificate pinning.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [infrastructure-hub](../infrastructure-hub/SKILL.md) | Infrastructure layer boundaries. |
| **Environment Config** | [infrastructure-config](../infrastructure-config/SKILL.md) | Base URLs and timeouts from `AppConfig`. |
| **DI Setup** | [infrastructure-di](../infrastructure-di/SKILL.md) | Registering `Dio` in `@module`. |
| **Data Layer Clients** | [flutter-clean-architecture](../../flutter-clean-architecture/SKILL.md) | Retrofit `@RestApi` client integration. |

---

## 3. Standard Implementation Patterns

### 3.1 Centralized `NetworkModule` with `BackgroundTransformer`

```dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_template/infrastructure/config/app_config.dart';
import 'package:flutter_template/infrastructure/network/interceptors/auth_interceptor.dart';
import 'package:flutter_template/infrastructure/network/interceptors/logging_interceptor.dart';

@module
abstract class NetworkModule {
  @Named('refreshDio')
  @lazySingleton
  Dio refreshDio() {
    return Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: Duration(seconds: AppConfig.connectTimeoutSeconds),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  @lazySingleton
  Dio dio(
    AuthInterceptor authInterceptor,
    LoggingInterceptor loggingInterceptor,
  ) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: Duration(seconds: AppConfig.connectTimeoutSeconds),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Offload heavy JSON parsing off the UI isolate
    dio.transformer = BackgroundTransformer();

    dio.interceptors.addAll([
      authInterceptor,
      if (AppConfig.enableLogging) loggingInterceptor,
    ]);

    return dio;
  }
}
```

---

### 3.2 Single-Flight 401 Token Refresh (`QueuedInterceptor`)

```dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_template/infrastructure/storage/secure_store_interactor.dart';

@lazySingleton
class AuthInterceptor extends QueuedInterceptor {
  final SecureStoreInteractor _secureStore;
  final Dio _refreshDio;

  AuthInterceptor(
    this._secureStore,
    @Named('refreshDio') this._refreshDio,
  );

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStore.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      try {
        final refreshToken = await _secureStore.getRefreshToken();
        if (refreshToken == null) {
          await _secureStore.clearTokens();
          return handler.next(err);
        }

        final response = await _refreshDio.post(
          '/auth/refresh',
          data: {'refresh_token': refreshToken},
        );

        final newAccessToken = response.data['access_token'] as String;
        final newRefreshToken = response.data['refresh_token'] as String?;

        await _secureStore.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken ?? refreshToken,
        );

        // Retry original request with new token
        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        final retryResponse = await _refreshDio.fetch(retryOptions);
        return handler.resolve(retryResponse);
      } catch (_) {
        await _secureStore.clearTokens();
      }
    }
    handler.next(err);
  }
}
```

---

### 3.3 Safe `DioException` to Domain Failure Mapper

```dart
import 'package:dio/dio.dart';
import 'package:flutter_template/domain/core/failures/domain_failure.dart';

abstract final class DioExceptionMapper {
  static DomainFailure mapToFailure(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const DomainFailure.network(
          message: 'Connection timed out. Please check your internet access.',
        );

      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode;
        final message = exception.response?.data?['message'] as String? ??
            'Server responded with error status $statusCode.';

        if (statusCode == 401) return const DomainFailure.unauthorized();
        if (statusCode == 403) return const DomainFailure.forbidden();
        if (statusCode == 404) return const DomainFailure.notFound();
        return DomainFailure.server(message: message, statusCode: statusCode);

      case DioExceptionType.cancel:
        return const DomainFailure.cancelled();

      default:
        return DomainFailure.unknown(message: exception.message ?? 'Unknown network error.');
    }
  }
}
```

---

## 4. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Standard `Interceptor` for 401 handling instead of `QueuedInterceptor` | **HIGH** | Use `QueuedInterceptor` to lock concurrent requests during refresh. |
| Using main intercepted `Dio` inside `AuthInterceptor` to refresh token | **CRITICAL** | Use an isolated `@Named('refreshDio')` to avoid infinite 401 recursion. |
| Importing `DioException` or `Dio` in Domain entities or UseCases | **CRITICAL** | Map to Domain `Failure` inside Data Repositories via `DioExceptionMapper`. |
| Printing full request/response bodies via `print()` in production | **HIGH** | Use configured `LoggingInterceptor` with PII masking and environment flags. |

---

## 5. Verification Checklist

- [ ] `BackgroundTransformer` is attached to `Dio`.
- [ ] 401 refresh uses `QueuedInterceptor` + isolated `refreshDio`.
- [ ] All network exceptions are transformed into typed Domain Failures via `DioExceptionMapper`.
- [ ] Request timeouts are explicitly configured in `BaseOptions`.
