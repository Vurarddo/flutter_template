---
name: flutter-testing
description: Complete testing framework standard for Flutter Widget and Integration tests. Enforces deterministic async frame pumping, Mocktail/bloc_test isolation, GetIt registry lifecycle management, Key-first finders, lazy scroll handling (scrollUntilVisible), and integration driver configuration. Use when creating widget/integration tests or debugging test runner timeouts.
---

# Flutter Widget & Integration Testing Expert Skill

## When to Apply

Use this skill whenever creating or maintaining Widget Tests (`test/presentation/...`), Integration Tests (`integration_test/...`), setting up `WidgetTester` pipelines, mocking BLoCs/Repositories, or resolving flaky async test timeouts.

---

## 1. Core Testing Hierarchy & Boundaries

- **Unit Tests:** Verify UseCases, Repositories, and BLoCs in isolation (pure Dart).
- **Widget Tests:** Verify UI component rendering, state-driven visual variations, and user event dispatching.
- **Integration Tests:** Verify full user flows, navigation routing, and DI wiring on real emulators/devices.

> **Rule:** Never test pure business logic inside Widget Tests. Restrict Widget Tests to layout verification and interaction triggering.

---

## 2. Element Finder Strategy & Lazy Scrolling

1. **Key-First Finders:**
   - Always find widgets using explicit `ValueKey` / `Key` identifiers:
     ```dart
     final button = find.byKey(const ValueKey('submit_button'));
     ```
   - **PROHIBITED:** Searching primary action elements by localized strings (`find.text('Submit')`) as dynamic translations break test suites.

2. **Lazy Scroll Handling (`scrollUntilVisible`):**
   - When target widgets are unmounted inside lazy viewports (`SliverList`, `ListView.builder`), scroll to them before interaction:
     ```dart
     await tester.scrollUntilVisible(
       find.byKey(const ValueKey('item_99')),
       500.0, // delta scroll step
       scrollable: find.byType(Scrollable).first,
     );
     await tester.pumpAndSettle();
     ```

---

## 3. Async Frame Pumping Mechanics

| Method                             | Execution Behavior                                       | Correct Use Case                                                            |
| :--------------------------------- | :------------------------------------------------------- | :-------------------------------------------------------------------------- |
| **`await tester.pump()`**          | Advances time by a single frame (1/60s).                 | Immediate state update verification or stepping through explicit ticks.     |
| **`await tester.pump(Duration)`**  | Advances clock by a fixed duration.                      | Stepping through timed animations or infinite spinners without timeout.     |
| **`await tester.pumpAndSettle()`** | Pumps frames repeatedly until zero frames are scheduled. | Waiting for route transitions, fade animations, or network mock resolution. |

> **CRITICAL WARNING:** NEVER call `pumpAndSettle()` when an active infinite animation (`CircularProgressIndicator`, looping shimmer) is rendering. It WILL trigger a `TimeoutException`. Use `tester.pump(const Duration(milliseconds: 300))` instead.

---

## 4. Widget Testing Architecture

### A. Context Provider Wrapper (`WidgetTestWrapper`)

Always wrap the target widget in a clean wrapper providing `MaterialApp`, `Theme`, `Scaffold`, and `BlocProvider`:

```dart
class WidgetTestWrapper extends StatelessWidget {
  final Widget child;
  final Brightness brightness;

  const WidgetTestWrapper({
    super.key,
    required this.child,
    this.brightness = Brightness.dark,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(body: child),
    );
  }
}

```

### B. Dependency Injection & BLoC Mocking Standard

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}
class MockBotRepository extends Mock implements BotRepository {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockBotRepository mockBotRepository;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockBotRepository = MockBotRepository();

    // Register DI Singleton overrides if GetIt is used
    if (GetIt.I.isRegistered<BotRepository>()) {
      GetIt.I.unregister<BotRepository>();
    }
    GetIt.I.registerSingleton<BotRepository>(mockBotRepository);
  });

  tearDown(() {
    mockAuthBloc.close();
    GetIt.I.reset(); // Crucial: Reset DI container to prevent test state pollution
  });

  testWidgets('Renders dashboard when authenticated', (WidgetTester tester) async {
    when(() => mockAuthBloc.state).thenReturn(const AuthState.authenticated());

    await tester.pumpWidget(
      WidgetTestWrapper(
        child: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const DashboardScreen(),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('dashboard_content_view')), findsOneWidget);
  });
}

```

---

## 5. Integration Testing Standard (`package:integration_test`)

### A. Driver Setup (`test_driver/integration_test.dart`)

For CI/CD execution, create `test_driver/integration_test.dart`:

```dart
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();

```

### B. Integration Test Implementation (`integration_test/app_flow_test.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await GetIt.I.reset();
    // Inject mock HTTP client or environment overrides
  });

  testWidgets('Complete End-to-End User Login Flow', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 1. Enter email
    final emailField = find.byKey(const ValueKey('login_email_field'));
    expect(emailField, findsOneWidget);
    await tester.enterText(emailField, 'user@domain.com');

    // 2. Tap Submit
    final submitButton = find.byKey(const ValueKey('login_submit_button'));
    await tester.tap(submitButton);

    // 3. Settle navigation transition
    await tester.pumpAndSettle();

    // 4. Verify Home View
    expect(find.byKey(const ValueKey('home_screen_view')), findsOneWidget);
  });
}

```

---

## Anti-Patterns (Strictly Prohibited)

| Anti-Pattern                                              | Severity     | Corrective Action                                                   |
| --------------------------------------------------------- | ------------ | ------------------------------------------------------------------- |
| `pumpAndSettle()` during infinite loading spinners        | **CRITICAL** | Advance frame using `tester.pump(const Duration(ms: 300))`.         |
| Real network requests or database IO during tests         | **CRITICAL** | Inject Mock HTTP clients or Repository mocks in DI.                 |
| Not calling `GetIt.I.reset()` in `tearDown()`             | **HIGH**     | Reset `GetIt` registry after EVERY test to prevent leaks.           |
| Using `Future.delayed()` / `Thread.sleep()` in test loops | **HIGH**     | Use `tester.pump()` or `tester.pumpAndSettle()`.                    |
| Locating action targets strictly via dynamic text strings | **MEDIUM**   | Use explicit `ValueKey('identifier')` attributes on target widgets. |

---

## Agent Verification Checklist

When creating or updating Widget / Integration tests:

1. **File Location:** Widget tests inside `test/**/*_test.dart`, Integration tests inside `integration_test/*_test.dart`.
2. **Key Usage:** Interaction targets (`tester.tap`, `tester.enterText`) locate widgets via `ValueKey`.
3. **DI Safety:** `GetIt.I.reset()` is called in `tearDown()`.
4. **Lazy Elements:** `tester.scrollUntilVisible` is used for off-screen items in long lists/slivers.
5. **No Infinite Hangs:** Screen regions with spinners use `tester.pump(Duration)` instead of `pumpAndSettle()`.
