---
name: data-dto-mappers
description: Standards and patterns for Data Transfer Objects (DTOs) and inline toDomain() mappers in lib/data/<feature>/dto/. Covers json_serializable configuration (@JsonSerializable, @JsonKey), safe parsing fallbacks, nested collection mapping, enum translations, and strict DTO encapsulation.
---

# DTOs & Inline `toDomain()` Mappers

## 1. Overview & When to Apply

Use this skill whenever:
- Defining Data Transfer Objects (DTOs) to serialize/deserialize API network payloads or database records (`lib/data/<feature>/dto/`).
- Configuring `json_serializable` (`@JsonSerializable`, `@JsonKey`).
- Writing inline `toDomain()` mapper methods or extension mappers to convert DTOs into clean Domain Entities.
- Writing `fromDomain()` / `toJson()` mappers for request payloads.
- Enforcing the rule that DTOs must NEVER cross into Domain or Presentation layers.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [data-hub](../data-hub/SKILL.md) | Data layer architecture and DTO encapsulation rules. |
| **Domain Entities** | [domain-entities-freezed](../../domain/domain-entities-freezed/SKILL.md) | Target Domain Entities constructed by `toDomain()`. |
| **Build Runner** | [flutter-build-runner](../../flutter_build_runner/SKILL.md) | Generating `*.g.dart` serialization files. |

---

## 3. Core DTO Design Rules

1. **Mirror Backend Contract 1-to-1:** DTO field names and types should mirror the backend JSON API (e.g. `snake_case` mapped via `@JsonKey(name: '...')`, nullable fields).
2. **Inline Mappers Standard:** Keep `toDomain()` mapping logic directly inside `<feature>_dto.dart` as a class method or extension. **Do NOT create separate `mappers/` folders** for simple 1-line mappings.
3. **Defensive Parsing & Fallbacks:** Always guard against missing or malformed fields (`null`, empty strings, unexpected types) when mapping to non-nullable Domain fields.
4. **Collection Immutability:** Wrap mapped lists in `List.unmodifiable()` or defensive copies when passing into Domain Entities.

---

## 4. Standard Implementation Patterns

### 4.1 Response DTO with Inline `toDomain()` Method

```dart
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_template/domain/items/entities/item_entity.dart';

part 'item_dto.g.dart';

@JsonSerializable(createToJson: false)
class ItemDto {
  final int id;
  final String? title;
  final String? description;
  @JsonKey(name: 'image_path')
  final String? imagePath;
  @JsonKey(name: 'rating_score')
  final num? ratingScore;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  final List<String>? tags;

  const ItemDto({
    required this.id,
    this.title,
    this.description,
    this.imagePath,
    this.ratingScore,
    this.createdAt,
    this.tags,
  });

  factory ItemDto.fromJson(Map<String, dynamic> json) => _$ItemDtoFromJson(json);

  /// Inline Mapper converting DTO to Domain Entity
  ItemEntity toDomain({String imageBaseUrl = 'https://api.example.com/images'}) {
    final path = imagePath;
    final fullImageUrl = (path != null && path.isNotEmpty)
        ? '$imageBaseUrl$path'
        : null;

    return ItemEntity(
      id: id.toString(),
      title: title ?? '',
      description: description ?? '',
      score: (ratingScore ?? 0.0).toDouble(),
      createdAt: DateTime.tryParse(createdAt ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      tags: List.unmodifiable(tags ?? const []),
      imageUrl: fullImageUrl,
    );
  }
}
```

---

### 4.2 Paginated List Response DTO

```dart
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_template/data/items/dto/item_dto.dart';
import 'package:flutter_template/domain/items/entities/item_entity.dart';

part 'item_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class ItemResponseDto {
  final int page;
  final List<ItemDto>? results;
  @JsonKey(name: 'total_pages')
  final int? totalPages;
  @JsonKey(name: 'total_results')
  final int? totalResults;

  const ItemResponseDto({
    required this.page,
    this.results,
    this.totalPages,
    this.totalResults,
  });

  factory ItemResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ItemResponseDtoFromJson(json);

  List<ItemEntity> toDomainList() {
    return results?.map((dto) => dto.toDomain()).toList(growable: false) ?? const [];
  }
}
```

---

### 4.3 Request Payload DTO (with `toJson()`)

For POST/PUT request bodies sent to API endpoints:

```dart
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_template/domain/items/entities/update_item_params.dart';

part 'update_item_request_dto.g.dart';

@JsonSerializable(createFactory: false)
class UpdateItemRequestDto {
  final double score;
  final String? comment;

  const UpdateItemRequestDto({
    required this.score,
    this.comment,
  });

  Map<String, dynamic> toJson() => _$UpdateItemRequestDtoToJson(this);

  /// Factory creating DTO from Domain parameters
  factory UpdateItemRequestDto.fromDomain(UpdateItemParams params) {
    return UpdateItemRequestDto(
      score: params.score,
      comment: params.comment,
    );
  }
}
```

---

### 4.4 Complex Enum Mapping Pattern

```dart
enum ApiItemStatus {
  @JsonValue('published')
  published,
  @JsonValue('in_draft')
  inDraft,
  @JsonValue('archived')
  archived;
}

// In DTO toDomain() mapping:
ItemStatus _mapStatus(ApiItemStatus? status) {
  return switch (status) {
    ApiItemStatus.published => ItemStatus.published,
    ApiItemStatus.inDraft => ItemStatus.inDraft,
    ApiItemStatus.archived => ItemStatus.archived,
    _ => ItemStatus.unknown,
  };
}
```

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Exposing DTO classes directly to Domain Entities or BLoCs | **CRITICAL** | Convert DTOs to Domain Entities via `toDomain()` inside Repository. |
| Creating redundant `lib/data/mappers/` folders with empty wrapper classes | **LOW** | Place `toDomain()` directly inside `<feature>_dto.dart`. |
| Ingesting raw JSON Maps directly inside Repositories without typed DTOs | **HIGH** | Always use typed `@JsonSerializable` DTOs with `fromJson`. |
| Crashing on unexpected `null` or type drift in JSON fields | **HIGH** | Provide safe default fallbacks in `toDomain()` (e.g. `voteAverage ?? 0.0`). |

---

## 6. Verification Checklist

- [ ] DTO file is placed in `lib/data/<feature>/dto/`.
- [ ] Contains `part '<name>.g.dart';` and generates cleanly via `build_runner`.
- [ ] Method `toDomain()` maps all technical fields safely to Domain Entity.
- [ ] Collections are made immutable (`List.unmodifiable`).
- [ ] DTO is never imported in `lib/domain/` or `lib/presentation/`.
