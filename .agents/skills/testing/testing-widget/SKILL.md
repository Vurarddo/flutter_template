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

## 3. Shared `WidgetTestWrapper` Standard

Every widget test must wrap the target widget in a clean wrapper that provides Material 3 theme, localization delegates, and navigation context:

```dart
// test/test_utils/widget_test_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_template/l10n/generated/l10n.dart';
import 'package:flutter_template/presentation/theme/app_theme.dart';

class WidgetTestWrapper extends StatelessWidget {
  final Widget child;
  final Brightness brightness;
  final Locale locale;

  const WidgetTestWrapper({
    super.key,
    required this.child,
    this.brightness = Brightness.light,
    this.locale = const Locale('en'),
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
      locale: locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(body: child),
    );
  }
}
```

---

## 4. Async Frame Pumping & Spinner Safety

| Method | Behavior | When to Use |
| :--- | :--- | :--- |
| `await tester.pump()` | Advances time by 1 frame (1/60s). | Immediate state updates or microtasks. |
| `await tester.pump(Duration)` | Advances time by a fixed duration. | Animations, debounces, or **infinite loading spinners**. |
| `await tester.pumpAndSettle()` | Pumps until zero frames are scheduled. | Route navigation, page transitions, and animations that end. |

> [!CAUTION]
> **CRITICAL RULE:** NEVER call `pumpAndSettle()` when an infinite animation (e.g. `CircularProgressIndicator`, looping shimmer) is on screen. It will trigger a `TimeoutException`. Use `tester.pump(const Duration(milliseconds: 300))` instead!

---

## 5. Complete Widget Test with Mocked BLoC

```dart
// test/presentation/pages/item/widgets/item_card_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_template/domain/core/failures/domain_failure.dart';
import 'package:flutter_template/domain/item/entities/item_entity.dart';
import 'package:flutter_template/presentation/state_management/item/item_bloc.dart';
import 'package:flutter_template/presentation/pages/item/item_page.dart';
import '../../../test_utils/widget_test_wrapper.dart';

class MockItemBloc extends MockBloc<ItemEvent, ItemState> implements ItemBloc {}

void main() {
  late MockItemBloc mockItemBloc;

  const tItem = ItemEntity(
    id: 'item_123',
    title: 'Awesome Item',
    description: 'Detailed description',
    isActive: true,
  );

  setUp(() {
    mockItemBloc = MockItemBloc();
  });

  tearDown(() {
    mockItemBloc.close();
  });

  testWidgets('renders CircularProgressIndicator when state is loading', (tester) async {
    when(() => mockItemBloc.state).thenReturn(const ItemState.loading());

    await tester.pumpWidget(
      WidgetTestWrapper(
        child: BlocProvider<ItemBloc>.value(
          value: mockItemBloc,
          child: const ItemPage(itemId: 'item_123'),
        ),
      ),
    );

    // Pump a single frame without pumpAndSettle (spinner is infinite)
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders item content when state is success', (tester) async {
    when(() => mockItemBloc.state).thenReturn(const ItemState.success(tItem));

    await tester.pumpWidget(
      WidgetTestWrapper(
        child: BlocProvider<ItemBloc>.value(
          value: mockItemBloc,
          child: const ItemPage(itemId: 'item_123'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('item_title_text')), findsOneWidget);
    expect(find.text('Awesome Item'), findsOneWidget);
  });

  testWidgets('dispatches RetryRequested when retry button is tapped in error view', (tester) async {
    when(() => mockItemBloc.state).thenReturn(
      const ItemState.failure(NetworkFailure()),
    );

    await tester.pumpWidget(
      WidgetTestWrapper(
        child: BlocProvider<ItemBloc>.value(
          value: mockItemBloc,
          child: const ItemPage(itemId: 'item_123'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final retryButton = find.byKey(const ValueKey('retry_button'));
    expect(retryButton, findsOneWidget);

    await tester.tap(retryButton);
    await tester.pump();

    verify(() => mockItemBloc.add(const ItemDetailsRequested('item_123'))).called(1);
  });
}
```

---

## 6. Lazy Scrolling in Long Lists (`scrollUntilVisible`)

```dart
testWidgets('scrolls and finds offscreen item in long list', (tester) async {
  await tester.pumpWidget(WidgetTestWrapper(child: const LongItemListView()));
  await tester.pumpAndSettle();

  final targetItemKey = const ValueKey('item_row_50');

  await tester.scrollUntilVisible(
    find.byKey(targetItemKey),
    300.0, // scroll step in pixels
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();

  expect(find.byKey(targetItemKey), findsOneWidget);
});
```

---

## 7. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| `pumpAndSettle()` while `CircularProgressIndicator` is on screen | **CRITICAL** | Use `tester.pump(Duration(milliseconds: 300))`. |
| Finding target elements by raw text instead of `ValueKey` | **HIGH** | Add `key: const ValueKey('id')` to widgets. |
| Injecting real UseCases or APIs in widget tests | **HIGH** | Mock BLoC states via `MockBloc` or `Mocktail`. |

---

## 8. Verification Checklist

- [ ] All widget tests wrap target components in `WidgetTestWrapper`.
- [ ] Interactive elements are located using `ValueKey`.
- [ ] Spinners are pumped with fixed duration (no infinite timeouts).
- [ ] `flutter test test/presentation/` passes cleanly.
