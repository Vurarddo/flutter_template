---
name: infrastructure-di
description: Standards for Dependency Injection (DI) in lib/infrastructure/di/ using injectable and get_it. Covers @module for external SDKs, lifecycle annotations (@lazySingleton, @injectable, @singleton), async @preResolve, environment switching, test isolation, and anti-service-locator boundaries.
---

# Infrastructure Dependency Injection (GetIt + Injectable)

## 1. Overview & When to Apply

Use this skill whenever:
- Wiring dependencies across `infrastructure/`, `data/`, `domain/`, and `presentation/`.
- Adding `@injectable`, `@lazySingleton`, `@singleton`, or `@factoryMethod` annotations.
- Creating `@module` classes to register third-party libraries (`Dio`, `SharedPreferences`, `FlutterSecureStorage`).
- Configuring `configureDependencies()` / `@InjectableInit()` and executing `build_runner`.
- Setting up test overrides and resetting `GetIt` state.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [infrastructure-hub](../infrastructure-hub/SKILL.md) | Infrastructure layer boundaries and composition root. |
| **Build Runner** | [flutter-build-runner](../../flutter-build-runner/SKILL.md) | Running code generation for `injectable.config.dart`. |
| **Testing** | [testing-hub](../../testing/testing-hub/SKILL.md) | Resetting and mocking DI container in tests. |

---

## 3. Core DI Lifecycle Matrix

| Annotation | Lifecycle Behavior | Standard Scope |
| :--- | :--- | :--- |
| **`@injectable`** | Creates a **new instance** every resolution. | BLoCs, Cubits, UseCases, Mappers. |
| **`@lazySingleton`** | Instantiated on **first access** and retained. Keeps cold start fast. | Repositories, Data Sources, ApiClients, Loggers. |
| **`@singleton`** | Instantiated **eagerly** during initial DI setup. | Critical bootstrap services only. |
| **`@factoryMethod`** | Marks a custom static factory or constructor. | Retrofit clients, complex builders. |
| **`@preResolve`** | Awaits `Future<T>` resolution inside `configureDependencies()`. | `SharedPreferences.getInstance()`, async SDK init. |

---

## 4. Standard Implementation Patterns

### 4.1 Composition Root (`lib/infrastructure/di/injectable.dart`)

```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_template/infrastructure/di/injectable.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies({String? environment}) async {
  await getIt.init(environment: environment);
}
```

---

### 4.2 External Libraries Module (`lib/infrastructure/di/modules/external_module.dart`)

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class ExternalModule {
  @preResolve
  Future<SharedPreferences> get sharedPreferences => SharedPreferences.getInstance();

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      );
}
```

---

### 4.3 Abstract Interface Binding in Data Layer

```dart
import 'package:injectable/injectable.dart';
import 'package:flutter_template/domain/auth/repositories/i_auth_repository.dart';

@LazySingleton(as: IAuthRepository)
class AuthRepositoryImpl implements IAuthRepository {
  final AuthApiClient _apiClient;
  final SecureStoreInteractor _secureStore;

  AuthRepositoryImpl(this._apiClient, this._secureStore);
}
```

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Direct `getIt<T>()` calls inside Domain UseCases, Repositories, or UI `build()` | **CRITICAL** | Pass dependencies via Constructor Injection. |
| Annotating BLoCs/Cubits with `@singleton` or `@lazySingleton` | **CRITICAL** | Always annotate BLoCs with `@injectable` (Factory). |
| Creating ad-hoc global `static late final instance` singletons | **CRITICAL** | Register via `GetIt` and `@lazySingleton`. |
| Excessive `@singleton` causing slow app cold start | **HIGH** | Use `@lazySingleton` to defer initialization until first use. |

---

## 6. Verification Checklist

- [ ] Domain layer contains zero `package:get_it` or `package:injectable` imports.
- [ ] No `getIt<T>()` calls in `Widget.build()` or UseCases.
- [ ] Code generation runs cleanly: `flutter pub run build_runner build --delete-conflicting-outputs`.
- [ ] Unit tests invoke `await getIt.reset()` in `setUp()` / `tearDown()`.
