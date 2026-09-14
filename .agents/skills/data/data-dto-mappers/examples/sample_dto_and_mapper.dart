import 'package:json_annotation/json_annotation.dart';

part 'sample_dto_and_mapper.g.dart';

// Sample Domain Entity representation
class ItemEntity {
  final String id;
  final String title;
  final String description;
  final double score;
  final DateTime createdAt;
  final List<String> tags;

  const ItemEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.score,
    required this.createdAt,
    required this.tags,
  });
}

@JsonSerializable(createToJson: false)
class ItemDto {
  final int id;
  final String? title;
  final String? description;
  @JsonKey(name: 'rating_score')
  final num? ratingScore;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  final List<String>? tags;

  const ItemDto({
    required this.id,
    this.title,
    this.description,
    this.ratingScore,
    this.createdAt,
    this.tags,
  });

  factory ItemDto.fromJson(Map<String, dynamic> json) => _$ItemDtoFromJson(json);

  /// Inline Mapper converting DTO to Domain Entity
  ItemEntity toDomain() {
    return ItemEntity(
      id: id.toString(),
      title: title ?? '',
      description: description ?? '',
      score: (ratingScore ?? 0.0).toDouble(),
      createdAt: DateTime.tryParse(createdAt ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      tags: List.unmodifiable(tags ?? const []),
    );
  }
}

@JsonSerializable(createToJson: false)
class ItemResponseDto {
  final int page;
  final List<ItemDto>? results;
  @JsonKey(name: 'total_pages')
  final int? totalPages;

  const ItemResponseDto({
    required this.page,
    this.results,
    this.totalPages,
  });

  factory ItemResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ItemResponseDtoFromJson(json);

  List<ItemEntity> toDomainList() {
    return results?.map((dto) => dto.toDomain()).toList(growable: false) ?? const [];
  }
}
