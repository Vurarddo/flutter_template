---
name: domain-entities-freezed
description: Standards and patterns for creating immutable Domain Entities using Freezed 3+ and Equatable under strict build.yaml generation flags (copyWith, equals, hashCode, toString only). Enforces field definitions in class body, const constructors with _$ClassName, zero fromJson/toJson/when/map generation, and defensive collection immutability.
---

# Domain Entities (Freezed 3+ & Equatable)

## 1. Overview & When to Apply

Use this skill whenever:
- Creating or refactoring immutable Domain Entities (`lib/domain/<feature>/entities/`).
- Implementing Value Objects using `Equatable` or `const` classes.
- Enforcing the strict project `build.yaml` and Freezed 3+ syntax rules.
- Ensuring zero JSON annotations (`@JsonSerializable`, `fromJson`, `toJson`) pollute the Domain layer.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [domain-hub](../domain-hub/SKILL.md) | Domain layer architecture and Pure Dart law. |
| **Build Runner** | [flutter-build-runner](../../flutter-build-runner/SKILL.md) | Executing code generation for `*.freezed.dart`. |
| **Data Mappers (DTOs)** | [flutter-clean-architecture](../../flutter-clean-architecture/SKILL.md) | Converting Data layer DTOs into Domain Entities via `toDomain()`. |

---

## 3. Strict `build.yaml` Generation Policy

The project enforces minimal code generation to optimize compilation speed and prevent bloated generated files:

```yaml
targets:
  $default:
    builders:
      freezed:
        options:
          map: false
          when: false
          fromJson: false
          toJson: false
          toString: true
          equals: true
          hashCode: true
          copyWith: true
```

> [!IMPORTANT]
> **Do NOT generate, call, or expect `map`, `when`, `maybeWhen`, `fromJson`, or `toJson` methods on `@freezed` models.**
> Use native Dart 3 `switch` expressions for pattern matching and DTOs in the Data layer for JSON parsing.

---

## 4. Freezed 3+ Standard Syntax Pattern

In accordance with project standards and Freezed 3+, Domain Entities must declare fields inside the class body with standard `const` constructors:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_entity.freezed.dart';

@freezed
class ItemEntity with _$ItemEntity {
  final String id;
  final String title;
  final String description;
  final double score;
  final DateTime createdAt;
  final List<String> tags;
  final bool isFavorite;

  const ItemEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.score,
    required this.createdAt,
    required this.tags,
    this.isFavorite = false,
  });

  /// Custom computed domain getters
  bool get isHighPriority => score >= 8.0;
  bool get isPast => createdAt.isBefore(DateTime.now());
}
```

---

## 5. Lightweight Value Objects via `Equatable`

For simple, atomic domain objects (e.g. `Money`, `Coordinates`, `EmailAddress`), use `Equatable` to eliminate code generation overhead:

```dart
import 'package:equatable/equatable.dart';

class Money extends Equatable {
  final double amount;
  final String currency;

  const Money({
    required this.amount,
    required this.currency,
  });

  @override
  List<Object?> get props => [amount, currency];
}
```

---

## 6. Defensive Collection Immutability

Always protect domain entity collections against external mutation:

```dart
// In Data layer DTO toDomain() mapper:
extension ItemDtoMapper on ItemDto {
  ItemEntity toDomain() {
    return ItemEntity(
      id: id,
      title: title,
      description: description,
      score: score,
      createdAt: DateTime.parse(createdAt),
      tags: List.unmodifiable(tags), // Defensive copy
      isFavorite: isFavorite ?? false,
    );
  }
}
```

---

## 7. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Adding `fromJson` / `toJson` to Domain `@freezed` classes | **CRITICAL** | Keep Domain pure; handle JSON in Data layer DTOs with `@JsonSerializable`. |
| Calling `.when()`, `.maybeWhen()`, `.map()` on Freezed models | **CRITICAL** | Use native Dart 3 `switch (model) { ... }` pattern matching. |
| Using legacy factory-constructor syntax instead of class body fields | **HIGH** | Declare fields in the class body with `const ClassName({required this.field})`. |
| Mutable collections inside Domain Entities | **HIGH** | Wrap lists with `List.unmodifiable()` during mapping. |

---

## 8. Verification Checklist

- [ ] Entity uses Freezed 3+ syntax (fields in body, `const` constructor with `this.field`).
- [ ] No JSON serialization annotations in `lib/domain/`.
- [ ] `part '<name>.freezed.dart';` is present and generates cleanly with `build_runner`.
- [ ] Collections are immutable (`List.unmodifiable`).
