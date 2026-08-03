---
name: flutter-injectable-get-it
description: Enforces production-grade Dependency Injection (DI) using get_it and injectable code generation. Covers annotation lifecycles (@injectable, @singleton, @lazySingleton, @factoryMethod), single composition root, abstract interface binding, third-party @module integration, async @preResolve, environment isolation, testing overrides, and zero direct service locator abuse in UI/Domain layers. Use when registering dependencies, refactoring constructors, or configuring DI code generation.
---

# GetIt + Injectable Dependency Injection Expert Skill

## When to Apply

Use this skill whenever wiring classes across layers (`data/`, `domain/`, `presentation/`), adding `@injectable` annotations, configuring `configureDependencies()` / `@InjectableInit()`, creating `@module` definitions, or setting up dependency overrides for tests.

---

## Core Architectural Rules & Standards

1. **Single Composition Root & Anti-Locator Boundary:**
   - Maintain a single `GetIt` instance (e.g. `final getIt = GetIt.instance;` or `GetIt.I`) and a single `configureDependencies()` entry point called before `runApp()`.
   - **STRICTLY PROHIBITED:** Calling `getIt<T>()` or `GetIt.I<T>()` directly inside Domain UseCases, Repositories, or UI `Widget.build()` methods.
   - `getIt` lookups are permitted ONLY at composition edges: `main.dart`, top-level `MultiBlocProvider` setup, route guards, or test setup routines. All internal dependencies MUST be passed via **Constructor Injection**.

2. **Annotation Choice & Cold Start Discipline:**
   - Prefer **`@lazySingleton`** over **`@singleton`** for heavy services to keep application cold startup fast. Use **`@singleton`** only when eager readiness at application boot is strictly required.
   - **`@injectable` (Factory):** MUST be used for short-lived or stateful business objects like BLoCs, Cubits, UseCases, and Mappers to ensure a fresh instance per resolution.

3. **Interface Segregation & Abstract Bindings:**
   - Always bind implementations in `data` or `infrastructure` to abstract interfaces in `domain` using `@LazySingleton(as: InterfaceName)` or `@Injectable(as: InterfaceName)`.
   - The `domain` layer MUST remain pure Dart and free of `package:get_it` or `package:injectable` imports.

4. **Zero Ad-Hoc Globals:**
   - Never create `static late final` instances or custom singleton "Manager" classes. All app-wide process state must be managed via GetIt + code generation.

---

## 1. Annotation Reference & Lifecycles

| Annotation           | Behavior & Use Case                                                                                                                  | Architectural Scope                                        |
| :------------------- | :----------------------------------------------------------------------------------------------------------------------------------- | :--------------------------------------------------------- |
| **`@injectable`**    | Creates a **new instance** every time `getIt<T>()` is resolved.                                                             | BLoCs, Cubits, UseCases, Mappers.                 |
| **`@lazySingleton`** | Instantiates on **first access** and preserves the instance for the app session. Keeps cold start fast.            | Repositories, Data Sources, ApiClients, Loggers.  |
| **`@singleton`**     | Instantiates **eagerly** during initial `configureDependencies()` execution.                                                | Critical core services requiring immediate setup. |
| **`@factoryMethod`** | Marks named constructors or static factory methods required for object creation (e.g., Retrofit `factory Client(Dio dio)`). | Retrofit Clients, Complex Builder patterns.       |

---

## 2. Composition Root & Async Setup (`@preResolve`)

Initialize dependency injection in `lib/core/di/injection.dart` before calling `runApp()`.

```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies({String? environment}) async {
  // Await initialization if registrations contain @preResolve async tasks
  await getIt.init(environment: environment);
}

```

---

## 3. Modules (`@module`) & Factory Methods (`@factoryMethod`)

Use `@module` for third-party classes (`Dio`, `SharedPreferences`) that cannot be annotated directly.

```dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  Dio dio() {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
  }

  /// Async pre-resolution awaited in configureDependencies()
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}

// Example Retrofit REST Client with @factoryMethod
@lazySingleton
class UserApiClient {
  @factoryMethod
  static UserApiClient create(Dio dio) => UserApiClient(dio);

  UserApiClient(Dio dio);
}

```

---

## 4. Pure Layered Constructor Injection

### A. Data Layer Implementation Binding

```dart
import 'package:injectable/injectable.dart';
import 'package:my_app/domain/repositories/user_repository.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;

  UserRepositoryImpl(this._remoteDataSource);

  @override
  Future<User> getUser(String id) => _remoteDataSource.fetchUser(id);
}

```

### B. Domain Layer Use Case (Factory)

```dart
import 'package:injectable/injectable.dart';
import 'package:my_app/domain/repositories/user_repository.dart';

@injectable
class GetUserUseCase {
  final UserRepository _repository;

  GetUserUseCase(this._repository);

  Future<User> call(String id) => _repository.getUser(id);
}

```

---

## 5. Environment Swapping & Test Overrides

Swap implementations seamlessly between environments (`dev`, `prod`, `test`).

```dart
// Mock implementation for development
@Environment('dev')
@LazySingleton(as: PaymentService)
class MockPaymentService implements PaymentService {
  @override
  Future<bool> processPayment(double amount) async => true;
}

// Live implementation for production
@Environment('prod')
@LazySingleton(as: PaymentService)
class StripePaymentService implements PaymentService {
  final Dio _dio;
  StripePaymentService(this._dio);

  @override
  Future<bool> processPayment(double amount) async {
    // Production API execution...
    return true;
  }
}

```

### Unit & Widget Testing Cleanups

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  final sl = GetIt.instance;

  setUp(() async {
    // Reset container before each test case to prevent state leak
    await sl.reset();
  });

  tearDown(() async {
    await sl.reset();
  });
}

```

---

## Anti-Patterns (Strictly Prohibited)

| Anti-Pattern                                                   | Severity     | Corrective Action                                                     |
| -------------------------------------------------------------- | ------------ | --------------------------------------------------------------------- |
| Direct `getIt<T>()` calls inside Domain UseCases or UI Widgets | **CRITICAL** | Pass dependencies via constructor; inject BLoCs using `BlocProvider`. |

|
| Ad-hoc global singletons (`static late final instance`) | **CRITICAL** | Manage shared dependencies exclusively through `GetIt` and `@lazySingleton`.

|
| Annotating BLoCs or Cubits with `@lazySingleton` or `@singleton` | **CRITICAL** | Use `@injectable` (Factory) for BLoCs/Cubits to guarantee fresh state.

|
| Hiding dependencies by resolving `getIt<T>()` inside methods | **HIGH** | Explicitly declare all required dependencies in class constructors.

|
| Overusing `@singleton` over `@lazySingleton` for non-critical services | **MEDIUM** | Use `@lazySingleton` to defer initialization and preserve cold start speed.

|

---

## Agent Verification Checklist

When reviewing or building DI configuration:

1. **Zero Locator Leakage:** Domain and Presentation files do not contain `getIt<T>()` or `GetIt.I` references.

2. **Correct Lifecycles:** BLoCs/UseCases are `@injectable`, Repositories/DataSources are `@lazySingleton`, async third-party getters use `@preResolve`.

3. **Abstract Bindings:** Implementation classes use `@LazySingleton(as: InterfaceName)`.

4. **Code Generation Executed:** Running `build_runner` generates `injection.config.dart` without resolution errors.

5. **Deterministic Testing:** Test suites invoke `await getIt.reset()` during setup/teardown.
