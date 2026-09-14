---
name: testing-unit
description: Standards and patterns for Pure Dart Unit Tests in test/domain/, test/data/, and test/core/. Covers testing UseCases, Repository implementations with Mocktail, DTO toDomain() mappers, Core utilities/extensions, and edge-case error assertions.
---

# Pure Dart Unit Testing Standard

## 1. Overview & When to Apply

Use this skill whenever:
- Testing Domain UseCases (`test/domain/<feature>/usecases/`).
- Testing Data Repository implementations (`test/data/<feature>/repositories/`) using `mocktail`.
- Testing DTO JSON serialization and `toDomain()` mapping accuracy (`test/data/<feature>/dto/`).
- Testing Core layer utilities, formatters, and pure Dart extensions (`test/core/`).
- Writing fast, deterministic unit tests without Flutter SDK or UI rendering dependencies.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [testing-hub](../testing-hub/SKILL.md) | Testing strategy and pyramid overview. |
| **Domain UseCases** | [domain-usecases](../../domain/domain-usecases/SKILL.md) | UseCase contracts being tested. |
| **Data Mappers** | [data-dto-mappers](../../data/data-dto-mappers/SKILL.md) | DTO `toDomain()` conversion standards. |
| **BLoC Testing** | [testing-bloc](../testing-bloc/SKILL.md) | Testing state machines using these unit-tested UseCases. |

---

## 3. Testing UseCases (Domain Layer)

```dart
// test/domain/item/usecases/get_item_details_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_template/domain/core/failures/domain_failure.dart';
import 'package:flutter_template/domain/item/entities/item_entity.dart';
import 'package:flutter_template/domain/item/repositories/i_item_repository.dart';
import 'package:flutter_template/domain/item/usecases/get_item_details_usecase.dart';

class MockItemRepository extends Mock implements IItemRepository {}

void main() {
  late MockItemRepository mockRepository;
  late GetItemDetailsUseCase useCase;

  const tItemId = 'item_123';
  const tItem = ItemEntity(
    id: tItemId,
    title: 'Test Item',
    description: 'Test Description',
    isActive: true,
  );

  setUp(() {
    mockRepository = MockItemRepository();
    useCase = GetItemDetailsUseCase(mockRepository);
  });

  group('GetItemDetailsUseCase', () {
    test('should return ItemEntity when repository call is successful', () async {
      // Arrange
      when(() => mockRepository.getItemDetails(tItemId))
          .thenAnswer((_) async => tItem);

      // Act
      final result = await useCase(tItemId);

      // Assert
      expect(result, equals(tItem));
      verify(() => mockRepository.getItemDetails(tItemId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should rethrow DomainFailure when repository throws', () async {
      // Arrange
      when(() => mockRepository.getItemDetails(tItemId))
          .thenThrow(const NotFoundFailure(code: 'NOT_FOUND'));

      // Act & Assert
      expect(
        () => useCase(tItemId),
        throwsA(isA<NotFoundFailure>()),
      );
      verify(() => mockRepository.getItemDetails(tItemId)).called(1);
    });
  });
}
```

---

## 4. Testing DTO Mappers (Data Layer)

```dart
// test/data/item/dto/item_dto_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_template/data/item/dto/item_dto.dart';
import 'package:flutter_template/domain/item/entities/item_entity.dart';

void main() {
  group('ItemDto', () {
    const tJson = {
      'id': 'item_123',
      'title': 'Test Item',
      'description': 'Test Description',
      'is_active': true,
    };

    test('fromJson should parse JSON into typed DTO correctly', () {
      final dto = ItemDto.fromJson(tJson);

      expect(dto.id, 'item_123');
      expect(dto.title, 'Test Item');
      expect(dto.isActive, isTrue);
    });

    test('toDomain should convert DTO into pure Domain Entity safely', () {
      final dto = ItemDto.fromJson(tJson);
      final entity = dto.toDomain();

      expect(entity, isA<ItemEntity>());
      expect(entity.id, dto.id);
      expect(entity.title, dto.title);
    });

    test('toDomain should provide safe default fallbacks on missing nullable values', () {
      const incompleteJson = {'id': 'item_999'};
      final dto = ItemDto.fromJson(incompleteJson);
      final entity = dto.toDomain();

      expect(entity.title, '');
      expect(entity.isActive, isFalse);
    });
  });
}
```

---

## 5. Testing Repository Implementations (Data Layer)

```dart
// test/data/item/repositories/item_repository_impl_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_template/data/item/client/item_api_client.dart';
import 'package:flutter_template/data/item/dto/item_dto.dart';
import 'package:flutter_template/data/item/repositories/item_repository_impl.dart';
import 'package:flutter_template/domain/core/failures/domain_failure.dart';

class MockItemApiClient extends Mock implements ItemApiClient {}

void main() {
  late MockItemApiClient mockApiClient;
  late ItemRepositoryImpl repository;

  setUp(() {
    mockApiClient = MockItemApiClient();
    repository = ItemRepositoryImpl(mockApiClient);
  });

  group('ItemRepositoryImpl', () {
    test('should map DioException to typed DomainFailure', () async {
      // Arrange
      when(() => mockApiClient.getItemDetails('invalid_id')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/items/invalid_id'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      // Act & Assert
      expect(
        () => repository.getItemDetails('invalid_id'),
        throwsA(isA<TimeoutFailure>()),
      );
    });
  });
}
```

---

## 6. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Instantiating real Dio or HTTP clients in unit tests | **CRITICAL** | Mock `ApiClient` or `Dio` using `Mocktail`. |
| Testing UI rendering or widgets in pure unit test files | **HIGH** | Move widget tests to `test/presentation/` with `testWidgets`. |
| Ignoring edge-case null values in DTO `toDomain()` tests | **HIGH** | Write tests for incomplete JSON maps to verify fallbacks. |

---

## 7. Verification Checklist

- [ ] Unit tests execute with `flutter test test/domain/ test/data/ test/core/`.
- [ ] Mocks use `mocktail` (`when(() => ...).thenAnswer(...)`).
- [ ] `verifyNoMoreInteractions()` ensures no unverified side effects.
- [ ] 100% of happy path and error branch mappings are asserted.
