---
name: infrastructure-hub
description: Primary coordinator and architecture guide for the Infrastructure layer (lib/infrastructure/). Enforces Clean Architecture adapter boundaries, preventing utils junk drawers, and routing to specialized sub-skills for Dio networking, DI (injectable), storage interactors, Firebase, deep links, in-app purchases, environment configuration, and logging.
---

# Infrastructure Layer Coordinator & Architecture Hub

## 1. Overview & Infrastructure Scope

The `lib/infrastructure/` directory contains **technical adapters, external SDK integrations, network clients, storage interactors, and system platform services**.

### Core Architecture Responsibilities:
1. **External System Isolation:**
   - Isolates third-party libraries (`Dio`, `Firebase`, `RevenueCat`, `FlutterSecureStorage`, `SharedPreferences`) from polluting the Domain and Presentation layers.
   - Domain layer NEVER imports infrastructure classes directly; it interacts solely through abstract repository/service interfaces.
2. **Anti-Utils Discipline (No Junk Drawers):**
   - Strictly **PROHIBITED** to treat `infrastructure/utils/` as an arbitrary dump folder for SDKs, deep links, or purchases.
   - Specialized systems must live in dedicated directories (`config/`, `di/`, `network/`, `storage/`, `services/`, `logging/`).
3. **Dependency Inversion:**
   - Data and Infrastructure implement Domain interfaces. Domain defines the contract (`IRepository`), Data/Infrastructure provides the technical realization.

---

## 2. Infrastructure Skill Tree & Routing Matrix

Use this matrix to navigate to the specialized sub-skill matching your task:

| Sub-Domain | Target Sub-Skill | Purpose |
| :--- | :--- | :--- |
| **Environment Configuration** | [infrastructure-config](../infrastructure-config/SKILL.md) | `--dart-define`, `AppConfig`, `AppEnvironment` (`dev`, `staging`, `prod`), secrets hygiene. |
| **Dependency Injection** | [infrastructure-di](../infrastructure-di/SKILL.md) | `injectable` + `get_it`, `@module`, third-party registrations, `@preResolve`, environment switching. |
| **Dio & Network Architecture** | [infrastructure-network-dio](../infrastructure-network-dio/SKILL.md) | `Dio` singleton, `BaseOptions`, `BackgroundTransformer` (isolates), queued 401 refresh interceptors, SSL pinning. |
| **Storage Interactors** | [infrastructure-storage](../infrastructure-storage/SKILL.md) | `SecureStoreInteractor` (`flutter_secure_storage`), `StoreInteractor` (`shared_preferences`), reactive key-value storage. |
| **Firebase Services** | [infrastructure-services-firebase](../infrastructure-services-firebase/SKILL.md) | Modular Firebase architecture (`CrashlyticsService`, `FCMNotificationService`, `RemoteConfigService`). |
| **Deep Links & Universal Links** | [infrastructure-services-deep-link](../infrastructure-services-deep-link/SKILL.md) | App Links / Universal Links listeners, route parsing, integration with AutoRoute. |
| **In-App Purchases & Subscriptions** | [infrastructure-services-purchase](../infrastructure-services-purchase/SKILL.md) | In-App Purchases (RevenueCat, StoreKit, Google Play Billing) adapters and Domain boundary. |
| **Centralized Logging** | [infrastructure-logging](../infrastructure-logging/SKILL.md) | `AppLogger`, log levels, PII masking, Talker/Logger integration. |
| **Core Layer Hub** | [core-hub](../../core/core-hub/SKILL.md) | Pure Dart foundations, extensions, and utilities. |
| **Clean Architecture Hub** | [flutter-clean-architecture](../../flutter-clean-architecture/SKILL.md) | System-wide layer separation and DDD principles. |

---

## 3. Directory Standard for `lib/infrastructure/`

```text
lib/infrastructure/
├── config/                          # AppConfig, AppEnvironment, --dart-define
│   ├── app_config.dart
│   └── app_environment.dart
├── di/                              # Dependency Injection (GetIt + Injectable)
│   ├── injectable.dart
│   └── modules/                     # External library @modules (Dio, SharedPreferences)
├── network/                         # Dio client setup, interceptors, SSL pinning
│   ├── dio_client.dart
│   ├── interceptors/
│   └── error_handler/
├── storage/                         # Key-Value and Secure storage interactors
│   ├── secure_store_interactor.dart
│   ├── store_interactor.dart
│   └── storage_module.dart
├── services/                        # External SDK and OS platform services
│   ├── firebase/                    # Crashlytics, FCM, RemoteConfig
│   ├── deep_link/                   # Universal links / App Links listeners
│   ├── purchase/                    # RevenueCat / StoreKit billing adapters
│   └── connectivity/                # Network connectivity stream provider
└── logging/                         # Centralized logging and diagnostic sinks
    └── app_logger.dart
```

---

## 4. Technical Constraints & Architecture Rules

1. **Strict Composition Root:** `GetIt` lookup is allowed only at composition roots (`main.dart`, route guards). All internal infrastructure classes must use **Constructor Injection**.
2. **Domain Protection:** Third-party exception types (`DioException`, `FirebaseException`, `PlatformException`) must be mapped to typed Domain Failures before leaving Data/Infrastructure.
3. **No UI Imports in Infrastructure:** Infrastructure must not import `package:flutter/material.dart` (except platform channel / lifecycle bindings where required).
4. **Environment Isolation:** Never hardcode base URLs or secrets; use `AppConfig.fromEnvironment`.

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Dumping Firebase, DeepLinks, or IAP into a generic `utils/` folder | **HIGH** | Place inside dedicated `services/<name>/` modules under `infrastructure/`. |
| Directly calling `getIt<T>()` inside business methods or constructors | **CRITICAL** | Use constructor injection with `@injectable` or `@lazySingleton`. |
| Exposing raw SDK models (e.g. `UserCredential`, `CustomerInfo`) to Presentation | **HIGH** | Map SDK models to Domain Entities before returning. |
| Committing local `config/env_*.json` credential files to Git | **CRITICAL** | Keep credentials in `.gitignore`; provide `env_template.json`. |

---

## 6. Master Infrastructure Verification Checklist

- [ ] Every infrastructure service is registered via `injectable` (`@lazySingleton` or `@module`).
- [ ] No raw SDK types cross the boundary into Domain or UI.
- [ ] Configuration parameters are strongly typed via `AppConfig`.
- [ ] Loggers mask PII and tokens in production environments.
- [ ] Unit/Integration tests mock infrastructure services via abstract interfaces.
