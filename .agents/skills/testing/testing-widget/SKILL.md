---
name: testing-widget
description: Standards and patterns for Flutter Widget Testing using WidgetTester and WidgetTestWrapper. Covers Key-first finders, lazy list scrolling (scrollUntilVisible), async frame pumping (avoiding pumpAndSettle timeouts on spinners), mocking BLoCs via Mocktail, and testing responsive/theme variations.
---

# Flutter Widget Testing Standard

## 1. Overview & When to Apply

Use this skill whenever:
- Testing UI widget rendering, component composition, and user interaction (`test/presentation/`).
- Validating state-driven UI variations (loading, success, error views) using mocked BLoCs.
- Finding interactive widgets using `ValueKey` identifiers.
- Testing gestures (tapping, entering text, dragging) and lazy scrolling (`scrollUntilVisible`).
- Avoiding frame timeout crashes when testing views with infinite spinners.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [testing-hub](../testing-hub/SKILL.md) | Testing strategy and pyramid overview. |
| **UI Kit** | [flutter-ui-kit-hub](../../presentation/ui/ui-kit/flutter-ui-kit-hub/SKILL.md) | Reusable visual components being tested. |
| **BLoC Testing** | [testing-bloc](../testing-bloc/SKILL.md) | Unit testing BLoC logic before mocking in widgets. |
| **Localization Integration** | [l10n-presentation-integration](../../l10n/l10n-presentation-integration/SKILL.md) | Supplying localization delegates to test wrapper. |

---

## 3. Async Frame Pumping & Spinner Safety

| Method | Behavior | When to Use |
| :--- | :--- | :--- |
| `await tester.pump()` | Advances time by 1 frame (1/60s). | Immediate state updates or microtasks. |
| `await tester.pump(Duration)` | Advances time by a fixed duration. | Animations, debounces, or **infinite loading spinners**. |
| `await tester.pumpAndSettle()` | Pumps until zero frames are scheduled. | Route navigation, page transitions, and animations that end. |

> [!CAUTION]
> **CRITICAL RULE:** NEVER call `pumpAndSettle()` when an infinite animation (e.g. `CircularProgressIndicator`, looping shimmer) is on screen. Use `tester.pump(const Duration(milliseconds: 100))` instead.

---

## 4. Reference Implementations (`examples/`)

- **Standard `WidgetTestWrapper`:** [examples/widget_test_wrapper_sample.dart](examples/widget_test_wrapper_sample.dart)
  - Encapsulates `MaterialApp`, `ThemeData`, `Scaffold`, and localization delegates (`S.delegate`).
- **Widget Test with Mocked BLoC:** [examples/widget_test_with_mock_bloc.dart](examples/widget_test_with_mock_bloc.dart)
  - Mocktail BLoC mocking, state stubbing (`when(() => bloc.state)`), and spinner verification.

---

## 5. Verification Checklist

- [ ] Target widget wrapped in `WidgetTestWrapper`.
- [ ] No `pumpAndSettle()` called on infinite spinners.
- [ ] Finders target explicit `ValueKey` or typed widgets.
- [ ] Mocked BLoCs properly closed in `tearDown()`.
