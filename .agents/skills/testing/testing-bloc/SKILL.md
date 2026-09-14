---
name: testing-bloc
description: Standards and patterns for BLoC and Cubit State Transition Testing using package:bloc_test and package:mocktail. Covers mocking UseCases, testing async event-to-state sequences, verifying bloc_concurrency transformers (droppable, restartable), and asserting Failure state emissions.
---

# BLoC & Cubit State Transition Testing Standard

## 1. Overview & When to Apply

Use this skill whenever:
- Testing BLoC or Cubit classes (`test/presentation/state_management/<feature>/`).
- Writing isolated state sequence tests using `blocTest<B, S>()`.
- Mocking Domain UseCases and verifying call invocations using `mocktail`.
- Testing event concurrency transformers (`restartable()`, `droppable()`, `sequential()`).
- Asserting error states and `addError()` emissions without UI dependencies.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [testing-hub](../testing-hub/SKILL.md) | Testing strategy and pyramid overview. |
| **BLoC Core** | [flutter-bloc-core](../../presentation/state-management/flutter-bloc-core/SKILL.md) | Standard BLoC architecture, events, and states. |
| **Unit Testing** | [testing-unit](../testing-unit/SKILL.md) | Unit testing UseCases before mocking them in BLoCs. |
| **Widget Testing** | [testing-widget](../testing-widget/SKILL.md) | Testing UI integration with these BLoCs. |

---

## 3. Standard BLoC Test Implementation Pattern

```dart
// test/presentation/state_management/item/item_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_template/domain/core/failures/domain_failure.dart';
import 'package:flutter_template/domain/item/entities/item_entity.dart';
import 'package:flutter_template/domain/item/usecases/get_item_details_usecase.dart';
import 'package:flutter_template/presentation/state_management/item/item_bloc.dart';

class MockGetItemDetailsUseCase extends Mock implements GetItemDetailsUseCase {}

void main() {
  late MockGetItemDetailsUseCase mockGetItemDetails;
  late ItemBloc itemBloc;

  const tItemId = 'item_123';
  const tItem = ItemEntity(
    id: tItemId,
    title: 'Test Item',
    description: 'Test Description',
    isActive: true,
  );

  setUp(() {
    mockGetItemDetails = MockGetItemDetailsUseCase();
    itemBloc = ItemBloc(mockGetItemDetails);
  });

  tearDown(() {
    itemBloc.close();
  });

  group('ItemBloc', () {
    test('initial state should be ItemState.initial()', () {
      expect(itemBloc.state, equals(const ItemState.initial()));
    });

    blocTest<ItemBloc, ItemState>(
      'emits [loading, success] when ItemDetailsRequested succeeds',
      build: () {
        when(() => mockGetItemDetails(tItemId))
            .thenAnswer((_) async => tItem);
        return itemBloc;
      },
      act: (bloc) => bloc.add(const ItemDetailsRequested(tItemId)),
      expect: () => [
        const ItemState.loading(),
        const ItemState.success(tItem),
      ],
      verify: (_) {
        verify(() => mockGetItemDetails(tItemId)).called(1);
      },
    );

    blocTest<ItemBloc, ItemState>(
      'emits [loading, failure] when ItemDetailsRequested throws DomainFailure',
      build: () {
        when(() => mockGetItemDetails(tItemId))
            .thenThrow(const NotFoundFailure(code: 'NOT_FOUND'));
        return itemBloc;
      },
      act: (bloc) => bloc.add(const ItemDetailsRequested(tItemId)),
      expect: () => [
        const ItemState.loading(),
        const ItemState.failure(NotFoundFailure(code: 'NOT_FOUND')),
      ],
      errors: () => [
        isA<NotFoundFailure>(), // Verifies addError() captured the failure
      ],
      verify: (_) {
        verify(() => mockGetItemDetails(tItemId)).called(1);
      },
    );
  });
}
```

---

## 4. Testing Event Transformers (`bloc_concurrency`)

### Testing `restartable()` (Search / Autocomplete Debounce)

```dart
blocTest<SearchBloc, SearchState>(
  'emits state for only the latest query when rapid search events are dispatched',
  build: () {
    when(() => mockSearchItems('query2'))
        .thenAnswer((_) async => [tItem]);
    return searchBloc;
  },
  act: (bloc) {
    bloc.add(const SearchQueryChanged('query1'));
    bloc.add(const SearchQueryChanged('query2')); // Should cancel query1
  },
  wait: const Duration(milliseconds: 300), // Debounce duration
  expect: () => [
    const SearchState.loading(),
    SearchState.success([tItem]),
  ],
);
```

### Testing `droppable()` (Spam Button Click Prevention)

```dart
blocTest<SubmitBloc, SubmitState>(
  'ignores second submit event while first is still in progress',
  build: () {
    when(() => mockSubmitItem(any())).thenAnswer((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      return tItem;
    });
    return submitBloc;
  },
  act: (bloc) {
    bloc.add(const SubmitPressed(tItem));
    bloc.add(const SubmitPressed(tItem)); // Should be dropped
  },
  expect: () => [
    const SubmitState.inProgress(),
    const SubmitState.success(),
  ],
  verify: (_) {
    verify(() => mockSubmitItem(any())).called(1); // Verified only called once
  },
);
```

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Testing BLoC by calling methods directly (`bloc.fetch()`) | **CRITICAL** | Dispatch events via `bloc.add(Event())`. |
| Not verifying `addError()` in failure tests | **HIGH** | Add `errors: () => [isA<FailureType>()]` to verify observability. |
| Forgetting `bloc.close()` in `tearDown()` | **MEDIUM** | Always close BLoC instances after test execution. |

---

## 6. Verification Checklist

- [ ] All test cases use `blocTest<Bloc, State>()`.
- [ ] Initial state is verified via a standalone `test()`.
- [ ] Happy path and failure path transitions are tested.
- [ ] `verify()` ensures UseCase invocations match expectations.
