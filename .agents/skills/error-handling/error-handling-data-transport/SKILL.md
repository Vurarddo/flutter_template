---
name: error-handling-data-transport
description: Standards and patterns for Data layer exception handling and transport error transformation. Covers DioExceptionMapper, HTTP status code mapping (401, 403, 404, 500), timeout types, SocketException, server error JSON DTO extraction, and repository try-catch patterns.
---

# Data Layer Transport Error Transformation

## 1. Overview & When to Apply

Use this skill whenever:
- Catching network, database, or third-party SDK exceptions inside Data layer repositories.
- Implementing `DioExceptionMapper` in `lib/infrastructure/network/error_handler/`.
- Mapping HTTP status codes (`401 Unauthorized`, `403 Forbidden`, `404 Not Found`, `500 Internal Server Error`) to `DomainFailure`.
- Extracting technical server error response bodies (`{"code": "USER_NOT_FOUND", "message": "..."}`).
- Guaranteeing that zero `DioException` or `SocketException` instances escape into Domain or Presentation layers.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [error-handling-hub](../error-handling-hub/SKILL.md) | End-to-end error lifecycle. |
| **Domain Failures** | [domain-failures](../../domain/domain-failures/SKILL.md) | Target `DomainFailure` contracts being produced. |
| **Network Dio** | [infrastructure-network-dio](../../infrastructure/infrastructure-network-dio/SKILL.md) | Production Dio client and interceptor setup. |
| **Data Repositories** | [data-repositories](../../data/data-repositories/SKILL.md) | Repository implementation patterns consuming this mapper. |

---

## 3. Production `DioExceptionMapper` Implementation

```dart
// lib/infrastructure/network/error_handler/dio_exception_mapper.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_template/domain/core/failures/domain_failure.dart';

abstract final class DioExceptionMapper {
  /// Transforms any low-level exception into a strongly-typed DomainFailure
  static DomainFailure mapToFailure(Object error, [StackTrace? stackTrace]) {
    if (error is DomainFailure) {
      return error;
    }

    if (error is SocketException) {
      return const NetworkFailure(
        code: 'NO_INTERNET',
        technicalMessage: 'SocketException: No network connection available',
      );
    }

    if (error is DioException) {
      return _mapDioException(error);
    }

    return UnknownFailure(
      message: error.toString(),
      stackTrace: stackTrace,
    );
  }

  static DomainFailure _mapDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutFailure(
          code: 'TIMEOUT',
          technicalMessage: exception.message,
        );

      case DioExceptionType.connectionError:
        return NetworkFailure(
          code: 'CONNECTION_ERROR',
          technicalMessage: exception.message,
        );

      case DioExceptionType.badResponse:
        return _mapBadResponse(exception);

      case DioExceptionType.cancel:
        return const DomainFailure.unknown(
          message: 'Request was cancelled by the client',
        );

      case DioExceptionType.badCertificate:
        return const NetworkFailure(
          code: 'SSL_ERROR',
          technicalMessage: 'Bad SSL certificate',
        );

      case DioExceptionType.unknown:
      default:
        if (exception.error is SocketException) {
          return const NetworkFailure(code: 'NO_INTERNET');
        }
        return UnknownFailure(
          message: exception.message ?? exception.toString(),
        );
    }
  }

  static DomainFailure _mapBadResponse(DioException exception) {
    final response = exception.response;
    final statusCode = response?.statusCode;
    final dynamic data = response?.data;

    String? serverCode;
    String? serverMessage;

    if (data is Map<String, dynamic>) {
      serverCode = data['code']?.toString() ?? data['error_code']?.toString();
      serverMessage = data['message']?.toString() ?? data['error']?.toString();
    }

    return switch (statusCode) {
      401 || 403 => UnauthorizedFailure(
          code: serverCode ?? 'UNAUTHORIZED',
          technicalMessage: serverMessage ?? exception.message,
        ),
      404 => NotFoundFailure(
          code: serverCode ?? 'NOT_FOUND',
          technicalMessage: serverMessage ?? exception.message,
        ),
      _ => ServerFailure(
          statusCode: statusCode,
          code: serverCode ?? 'SERVER_ERROR',
          technicalMessage: serverMessage ?? exception.message,
        ),
    };
  }
}
```

---

## 4. Usage Inside Repository Implementations

```dart
// lib/data/item/repositories/item_repository_impl.dart
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
  Future<ItemEntity> getItemDetails(String itemId) async {
    try {
      final dto = await _apiClient.getItemDetails(itemId);
      return dto.toDomain();
    } on DioException catch (e, st) {
      throw DioExceptionMapper.mapToFailure(e, st);
    } catch (e, st) {
      throw DomainFailure.unknown(message: e.toString(), stackTrace: st);
    }
  }
}
```

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Allowing raw `DioException` to escape from Repository methods | **CRITICAL** | Wrap with `try-catch` and throw `DioExceptionMapper.mapToFailure(e)`. |
| Parsing raw JSON error Maps directly inside UI widgets | **CRITICAL** | Extract server codes in `DioExceptionMapper` into `DomainFailure.code`. |
| Ignoring `SocketException` wrapped inside `DioExceptionType.unknown` | **HIGH** | Check `exception.error is SocketException` and map to `NetworkFailure`. |

---

## 6. Verification Checklist

- [ ] All repository methods catch `DioException` and map via `DioExceptionMapper`.
- [ ] Mapped exceptions result in pure `DomainFailure` instances.
- [ ] HTTP status codes (`401`, `403`, `404`, `500`) are mapped deterministically.
- [ ] Unit tests verify mapping for timeouts, connection errors, and status codes.
