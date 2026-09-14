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

```dart
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
```

---

## 4. Reference Implementations (`examples/`)

- **UiKit Showcase Smoke Test:** [examples/uikit_integration_test.dart](examples/uikit_integration_test.dart)
  - Full smoke test verifying page rendering, theme toggle (Light/Dark), and scrolling.
- **End-to-End User Journey:** [examples/item_journey_integration_test.dart](examples/item_journey_integration_test.dart)
  - Full flow with `app.main()`, DI reset in `setUp`/`tearDown`, and `tester.scrollUntilVisible`.

---

## 5. Execution Commands Across Platforms

```bash
# Mobile (Android / iOS)
flutter test integration_test/uikit_page_test.dart -d emulator-5554

# Web (Headless Chrome)
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/uikit_page_test.dart -d chrome

# Desktop (macOS, Windows, Linux)
flutter test integration_test/uikit_page_test.dart -d macos
```

---

## 6. Verification Checklist

- [ ] `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` called in `main()`.
- [ ] `GetIt.I.reset()` called in `setUp()` and `tearDown()` to prevent state bleed.
- [ ] Target elements located via unique `ValueKey` identifiers.
- [ ] Tests execute cleanly on targeted platform drivers.
