---
name: testing-integration
description: Standards and patterns for End-to-End Integration Testing across Mobile (Android, iOS), Web (Chrome), and Desktop (macOS, Windows, Linux) using package:integration_test. Covers platform driver setup, responsive viewport sizing, DI resets, complete user journeys, and CI/CD execution.
---

# Cross-Platform Integration Testing Standard (Mobile, Web, Desktop)

## 1. Overview & When to Apply

Use this skill whenever:
- Creating end-to-end integration tests (`integration_test/<feature>_flow_test.dart`).
- Testing full user journeys (Authentication -> Navigation -> Data Fetch -> Interaction -> Checkout).
- Executing tests across multiple target platforms: **Mobile (Android/iOS), Web (Chrome), Desktop (macOS, Windows, Linux)**.
- Configuring driver entrypoints (`test_driver/integration_test.dart`) for CI/CD test runners.
- Setting custom responsive viewports and window dimensions for Web and Desktop test runs.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [testing-hub](../testing-hub/SKILL.md) | Testing strategy and pyramid overview. |
| **Widget Testing** | [testing-widget](../testing-widget/SKILL.md) | Component level testing before full app integration. |
| **Navigation Hub** | [flutter-auto-route-hub](../../presentation/navigation/flutter-auto-route-hub/SKILL.md) | Deep links and route navigation verification. |
| **Dependency Injection** | [infrastructure-di](../../infrastructure/infrastructure-di/SKILL.md) | Overriding dependencies for test environments. |

---

## 3. Platform Driver Setup (`test_driver/integration_test.dart`)

For automated CI/CD runners and Web testing:

```dart
// test_driver/integration_test.dart
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
```

---

## 4. End-to-End Integration Test Implementation

```dart
// integration_test/item_journey_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_template/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Reset DI between tests to avoid container pollution
    await GetIt.I.reset();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('End-to-End Item User Journey', () {
    testWidgets('user can browse items, open details, and interact', (tester) async {
      // 1. Launch the actual application
      app.main();
      await tester.pumpAndSettle();

      // 2. Verify Home Screen is visible
      final homeView = find.byKey(const ValueKey('home_page_view'));
      expect(homeView, findsOneWidget);

      // 3. Scroll to target item if off-screen (works across Mobile, Web, Desktop)
      final targetItemKey = const ValueKey('item_card_item_1');
      await tester.scrollUntilVisible(
        find.byKey(targetItemKey),
        300.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // 4. Tap item card to navigate to Details
      await tester.tap(find.byKey(targetItemKey));
      await tester.pumpAndSettle();

      // 5. Verify Details Screen navigation
      final detailsView = find.byKey(const ValueKey('item_details_page_view'));
      expect(detailsView, findsOneWidget);

      // 6. Tap action button
      final actionButton = find.byKey(const ValueKey('item_action_button'));
      expect(actionButton, findsOneWidget);
      await tester.tap(actionButton);
      await tester.pumpAndSettle();

      // 7. Verify confirmation SnackBar
      expect(find.byKey(const ValueKey('action_success_snackbar')), findsOneWidget);
    });
  });
}
```

---

## 5. Cross-Platform Viewport Configuration

When testing Web and Desktop form factors, explicitly set the test surface size:

```dart
// Helper for responsive testing
Future<void> setTestViewport(
  WidgetTester tester, {
  required double width,
  required double height,
}) async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await binding.setSurfaceSize(Size(width, height));
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

// Usage in tests:
testWidgets('renders desktop side navigation on wide screens', (tester) async {
  await setTestViewport(tester, width: 1920, height: 1080); // Full HD Desktop / Web
  app.main();
  await tester.pumpAndSettle();

  expect(find.byKey(const ValueKey('desktop_side_nav_rail')), findsOneWidget);
});
```

---

## 6. CLI Execution Matrix Across Platforms

### 📱 Mobile (Android / iOS)
```bash
# Run on connected Android or iOS device / simulator
flutter test integration_test/item_journey_test.dart -d <device_id>
```

### 🌐 Web (Headless Chrome)
```bash
# Run integration test on Web with ChromeDriver
chromedriver --port=4444 &
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/item_journey_test.dart \
  -d chrome
```

### 💻 Desktop (macOS, Windows, Linux)
```bash
# macOS Desktop
flutter test integration_test/item_journey_test.dart -d macos

# Windows Desktop
flutter test integration_test/item_journey_test.dart -d windows

# Linux Desktop
flutter test integration_test/item_journey_test.dart -d linux
```

---

## 7. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Hardcoding platform-specific paths (e.g. `/sdcard/...`) | **CRITICAL** | Use `path_provider` or memory storage for cross-platform support. |
| Forgetting `GetIt.I.reset()` between test cases | **CRITICAL** | Call `GetIt.I.reset()` in `setUp()` and `tearDown()`. |
| Flaky timing using `Future.delayed(Duration(seconds: 5))` | **HIGH** | Always use `tester.pumpAndSettle()` with condition assertions. |
| Relying on fixed mobile screen dimensions in desktop tests | **MEDIUM** | Use `setTestViewport(tester, width: 1440, height: 900)` for desktop. |

---

## 8. Verification Checklist

- [ ] `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` is called at start of test.
- [ ] Test executes end-to-end user flow without mocking presentation layer.
- [ ] Targets are located via `ValueKey`.
- [ ] Tested on Mobile, Web, and Desktop targets.
- [ ] CI pipeline runs integration tests using `flutter drive` or `flutter test`.
