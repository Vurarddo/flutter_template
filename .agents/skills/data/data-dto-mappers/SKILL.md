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
| **Build Runner** | [flutter-build-runner](../../flutter-build-runner/SKILL.md) | Generating `*.g.dart` serialization files. |

---

## 3. Core DTO Design Rules

1. **Mirror Backend Contract 1-to-1:** Map JSON keys directly via `@JsonKey(name: '...')`.
2. **Inline Mappers Standard:** Keep `toDomain()` mapping logic directly inside `<feature>_dto.dart` as a class method or extension.
3. **Defensive Parsing & Fallbacks:** Always guard against missing or malformed fields with safe default fallbacks.
4. **Strict Encapsulation:** DTOs must never be imported or returned in Domain or Presentation layers.

---

## 4. Reference Implementation (`examples/`)

- **DTO with Inline `toDomain()` Mapper:** [examples/sample_dto_and_mapper.dart](examples/sample_dto_and_mapper.dart)
  - Demonstrates `@JsonSerializable(createToJson: false)`, nullable parsing fallbacks, immutable list wrapping, and list transformation (`toDomainList()`).

---

## 5. Verification Checklist

- [ ] DTO annotated with `@JsonSerializable`.
- [ ] Inline `toDomain()` mapper converts DTO to pure Domain Entity.
- [ ] Defensive fallbacks provided for nullable API fields.
- [ ] No DTO imports exist in Domain or Presentation layers.
