---
name: flutter-dio-retrofit
description: Builds a production-grade Dio plus Retrofit networking layer with centralized BaseOptions, BackgroundTransformer for isolate JSON parsing, queued single-flight 401 token refresh interceptors, Retrofit @RestApi clients with Endpoint constants, safe DioException mapping to typed Domain Failures, and CancelToken lifecycle management. Use when creating API clients, writing repositories, configuring network interceptors, or handling HTTP error mapping.
---

# Flutter Dio & Retrofit Expert Skill

## When to Apply

Use this skill whenever setting up network infrastructure, creating or modifying HTTP API endpoints, writing custom Dio interceptors (authentication, logging, retry), configuring `Retrofit` REST clients, or mapping network exceptions to Domain Failures.

---

## Naming Conventions

| Artifact            | Standard                                         | Example                              |
| :------------------ | :----------------------------------------------- | :----------------------------------- |
| **Retrofit Client** | `[Feature]ServiceClient` or `[Feature]ApiClient` | `AuthServiceClient`, `UserApiClient` |
| **Data DTO**        | `[Name]Dto`                                      | `UserProfileDto`                     |
| **Endpoints Class** | `[Feature]Endpoints`                             | `AuthEndpoints`, `UserEndpoints`     |

---

## Core Architectural Rules & Standards

1. **Network Layer Isolation:**
   - **STRICT BOUNDARY:** `Dio`, `@RestApi()` Retrofit clients, endpoints, and `DioException` MUST stay strictly within `data/datasources/` or `infrastructure/network/`.
   - The `domain` layer MUST NOT import `dio`, `retrofit`, or HTTP status codes. Repositories in the `data` layer must execute API calls, map DTOs to Domain Entities, and transform `DioException` via a single mapper into typed Domain `Failure` instances.

2. **Isolate Offloading for Large Payloads:**
   - Attach `BackgroundTransformer()` (or project standard compute wrapper) to `Dio` so heavy JSON decoding/encoding does not block the UI frame budget.

3. **No Magic Endpoint Strings:**
   - Define API routes inside dedicated `[Feature]Endpoints` classes using `static const` fields. Never hardcode path strings directly across multiple interface methods.

4. **Single-Flight Token Refresh Interceptor:**
   - 401 Unauthorized handling MUST use `QueuedInterceptor` with a dedicated, non-intercepted refresh Dio instance to pause concurrent requests and prevent refresh loops.
   - Interceptors MUST NOT invoke UI, dialogs, or navigation directly — signal auth state changes upward to domain/application services.

5. **Request Cancellation Lifecycle:**
   - Methods supporting search-as-you-type, pagination, or cancellable background requests MUST accept an optional `@CancelRequest() CancelToken? cancelToken` parameter and invoke `cancel()` upon disposal/closure.

---

## 1. Centralized Dio Provider & Isolate Transformer Configuration

Register `Dio` as a singleton inside a DI `@module` with explicit timeouts and `BackgroundTransformer`.

```dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(
    AuthInterceptor authInterceptor,
    LoggingInterceptor loggingInterceptor,
  ) {
    final dio = Dio(
      BaseOptions(
        baseUrl: '[https://api.example.com/v1](https://api.example.com/v1)',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Offload heavy JSON parsing off the main UI isolate
    dio.transformer = BackgroundTransformer();

    dio.interceptors.addAll([
      authInterceptor,
      loggingInterceptor,
    ]);

    return dio;
  }
}

```

---

## 2. Thread-Safe Single-Flight Token Refresh (`QueuedInterceptor`)

```dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AuthInterceptor extends QueuedInterceptor {
  final TokenRepository _tokenRepository;
  final Dio _refreshDio; // Isolated Dio instance without auth interceptor to prevent infinite loops

  AuthInterceptor(this._tokenRepository, @Named('refreshDio') this._refreshDio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenRepository.getAccessToken();
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
        final newToken = await _refreshToken();
        if (newToken != null) {
          // Clone and retry original request with new token
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newToken';

          final response = await _refreshDio.fetch(options);
          return handler.resolve(response);
        }
      } catch (_) {
        await _tokenRepository.clearTokens();
        // Signal session expiration upward (do NOT call Navigator/UI here)
      }
    }
    handler.next(err);
  }

  Future<String?> _refreshToken() async {
    final refreshToken = await _tokenRepository.getRefreshToken();
    if (refreshToken == null) return null;

    final response = await _refreshDio.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );

    final newAccessToken = response.data['access_token'] as String;
    await _tokenRepository.saveAccessToken(newAccessToken);
    return newAccessToken;
  }
}

```

---

## 3. Endpoints Class & Retrofit `@RestApi` Definition

### A. Endpoint Constants Definition

```dart
abstract class UserEndpoints {
  static const String getUser = '/users/{id}';
  static const String users = '/users';
  static const String uploadAvatar = '/users/{id}/avatar';
}

```

### B. Retrofit Client Interface

```dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:my_app/data/dtos/user_dto.dart';
import 'package:my_app/data/endpoints/user_endpoints.dart';

part 'user_service_client.g.dart';

@lazySingleton
@RestApi()
abstract class UserServiceClient {
  @factoryMethod
  factory UserServiceClient(Dio dio) = _UserServiceClient;

  @GET(UserEndpoints.getUser)
  Future<UserDto> getUser(
    @Path('id') String id, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @POST(UserEndpoints.users)
  Future<UserDto> createUser(
    @Body() UserDto user,
  );

  @GET(UserEndpoints.users)
  Future<List<UserDto>> getUsers(
    @Queries() Map<String, dynamic> queryParams,
  );
}

```

---

## 4. Centralized Error Transformer (`DioExceptionMapper`)

Centralize all `DioException` handling in a single place rather than duplicating try-catch blocks across repositories.

```dart
import 'package:dio/dio.dart';
import 'package:my_app/domain/failures/failure.dart';

class DioExceptionMapper {
  static Failure mapToFailure(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure(message: 'Connection timed out. Please check internet access.');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final serverMessage = e.response?.data?['message'] as String? ?? 'An unexpected server error occurred.';

        if (statusCode == 401) return const UnauthorizedFailure();
        if (statusCode == 403) return const ForbiddenFailure();
        if (statusCode == 404) return const NotFoundFailure();

        return ServerFailure(message: serverMessage, statusCode: statusCode);

      case DioExceptionType.cancel:
        return const RequestCancelledFailure();

      default:
        return UnknownFailure(message: e.message ?? 'Unexpected network exception');
    }
  }
}

```

---

## 5. Repository Implementation with `CancelToken`

```dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/data/mappers/dio_exception_mapper.dart';
import 'package:my_app/domain/entities/user.dart';
import 'package:my_app/domain/repositories/user_repository.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final UserServiceClient _client;

  UserRepositoryImpl(this._client);

  @override
  Future<User> getUser(String id, {CancelToken? cancelToken}) async {
    try {
      final dto = await _client.getUser(id, cancelToken: cancelToken);
      return dto.toDomain();
    } on DioException catch (e) {
      throw DioExceptionMapper.mapToFailure(e);
    } catch (e, st) {
      throw UnknownFailure(message: e.toString(), stackTrace: st);
    }
  }
}

```

---

## Anti-Patterns (Strictly Prohibited)

| Anti-Pattern                                               | Severity     | Corrective Action                                                |
| ---------------------------------------------------------- | ------------ | ---------------------------------------------------------------- |
| Using `print()` or `debugPrint()` for HTTP network logging | **CRITICAL** | Use a dedicated logging interceptor with redaction capabilities. |

|
| Importing `dio` or Retrofit annotations inside `domain/` or `presentation/` | **CRITICAL** | Restrict network types strictly to `data/` and `infrastructure/`.

|
| Hardcoding raw route strings directly in `@GET('/api/v1/users')` | **HIGH** | Extract routes into `[Feature]Endpoints` classes.

|
| Invoking UI/Navigation directly from inside an Interceptor | **HIGH** | Signal state changes upward to domain/app handlers.

|
| Standard `Interceptor` for 401 handling instead of `QueuedInterceptor` | **HIGH** | Use `QueuedInterceptor` to lock concurrent network requests during token refresh.

|
| Skipping timeouts (`connectTimeout`, `receiveTimeout`) in `BaseOptions` | **MEDIUM** | Set explicit timeouts on the shared `Dio` instance.

|

---

## Agent Verification Checklist

When reviewing network code:

1. **Strict Layer Isolation:** `Dio` and Retrofit dependencies are contained in `data/` or `infrastructure/`.

2. **Endpoints Centralized:** Endpoint paths use static fields from `[Feature]Endpoints`.

3. **Queued Refresh Interceptor:** 401 refresh utilizes `QueuedInterceptor` with an isolated refresh `Dio` instance.

4. **Single Mapper Used:** `DioExceptionMapper` handles all HTTP error transformation.

5. **No `print()` Logging:** Production logging relies on configured logging interceptors.

6. **CancelToken Supported:** Long-running/cancellable requests accept optional `CancelToken`.
