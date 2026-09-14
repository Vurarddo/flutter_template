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

Production-ready reference implementations are available in `examples/`:

1. **Centralized `NetworkModule`:** [examples/network_module.dart](examples/network_module.dart)
   - Injects primary `Dio` with `BackgroundTransformer`, headers, and `@Named('refreshDio')` for token refresh.
2. **Single-Flight 401 Token Refresh (`QueuedInterceptor`):** [examples/auth_interceptor.dart](examples/auth_interceptor.dart)
   - Prevents concurrent 401 refresh races and retries original requests with the updated bearer token.
3. **Safe `DioException` to Domain Failure Mapper:** [examples/dio_exception_mapper.dart](examples/dio_exception_mapper.dart)
   - Converts raw Dio transport errors into clean, typed Domain Failures (`DomainFailure.network`, `unauthorized`, `server`, etc.).

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
