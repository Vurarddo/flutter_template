import 'package:flutter_test/flutter_test.dart';

// Sample DTO and Mapper logic for test illustration
class ItemEntity {
  final String id;
  final String title;
  const ItemEntity({required this.id, required this.title});
}

class ItemDto {
  final int id;
  final String? title;

  const ItemDto({required this.id, this.title});

  factory ItemDto.fromJson(Map<String, dynamic> json) {
    return ItemDto(
      id: json['id'] as int,
      title: json['title'] as String?,
    );
  }

  ItemEntity toDomain() {
    return ItemEntity(
      id: id.toString(),
      title: title ?? '',
    );
  }
}

void main() {
  group('ItemDto & toDomain mapper tests', () {
    test('fromJson should parse JSON into typed DTO correctly', () {
      final json = {'id': 123, 'title': 'Sample Product'};
      final dto = ItemDto.fromJson(json);

      expect(dto.id, 123);
      expect(dto.title, 'Sample Product');
    });

    test('toDomain should provide safe fallback for nullable title', () {
      final json = {'id': 456, 'title': null};
      final dto = ItemDto.fromJson(json);
      final entity = dto.toDomain();

      expect(entity.id, '456');
      expect(entity.title, '');
    });
  });
}
