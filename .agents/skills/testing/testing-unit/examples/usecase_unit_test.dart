import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Sample entities and interfaces for test illustration
class ItemEntity {
  final String id;
  final String title;
  const ItemEntity({required this.id, required this.title});
}

abstract class IItemRepository {
  Future<ItemEntity> getItemDetails(String id);
}

class GetItemDetailsUseCase {
  final IItemRepository _repository;
  const GetItemDetailsUseCase(this._repository);

  Future<ItemEntity> call(String id) => _repository.getItemDetails(id);
}

class MockItemRepository extends Mock implements IItemRepository {}

void main() {
  late MockItemRepository mockRepository;
  late GetItemDetailsUseCase useCase;

  const tItemId = 'item_123';
  const tItem = ItemEntity(id: tItemId, title: 'Test Item');

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

    test('should propagate exception when repository throws', () async {
      // Arrange
      when(() => mockRepository.getItemDetails(tItemId))
          .thenThrow(Exception('Server error'));

      // Act & Assert
      expect(() => useCase(tItemId), throwsA(isA<Exception>()));
      verify(() => mockRepository.getItemDetails(tItemId)).called(1);
    });
  });
}
