---
name: flutter-freezed-equatable-models
description: Implements immutable data structures, sealed unions, and value objects using freezed and equatable under strict build.yaml generation flags (copyWith, equality, hashCode, toString only). Enforces Dart 3 pattern matching, keeps JSON serialization separate from freezed models, enforces final fields, and ensures safe collection immutability. Use when creating DTOs, domain entities, value objects, BLoC states/events, or configuring build.yaml options.
---

# Flutter Freezed, Equatable & Immutability Expert Skill

## When to Apply

Use this skill whenever defining Domain Entities, Data Transfer Objects (DTOs), Value Objects, BLoC/Cubit States and Events, or complex immutable structures in Flutter.

---

## Core Architectural Rules & Standards

1. **Strict `build.yaml` Policy Alignment:**
   - Generation flags for `map`, `when`, `fromJson`, and `toJson` MUST remain disabled in `build.yaml`.
   - Generation is strictly limited to: `toString`, `==` / `hashCode`, and `copyWith`.
   - Pattern matching MUST be written using native Dart 3 `switch` expressions instead of generated `.when()` / `.map()` methods.

2. **Freezed vs Equatable vs Native Sealed Choice:**

| Structure                                       | Recommended Tool                                                          | Rationale                                                                                               |
| :---------------------------------------------- | :------------------------------------------------------------------------ | :------------------------------------------------------------------------------------------------------ |
| **DTOs & Complex Data Models**                  | **`@freezed`**                                                            | Requires `copyWith`, structural equality, and unmodifiable collection protection.              |
| **Simple Value Objects / Lightweight Entities** | **`Equatable`** or **`const` class**                                      | Eliminates code generation overhead for simple structures with low iteration churn.            |
| **BLoC States & Events**                        | **Dart 3 `sealed class`** (or `@freezed` if `copyWith` is heavily needed) | Native Dart 3 sealed hierarchies are zero-dependency, compile-time exhaustive, and ultra-fast. |

3. **Clean Architecture JSON Boundaries:**
   - Domain Entities MUST NOT import JSON annotations or handle transport formats.
   - Serialization lives strictly in the Data layer via explicit Mappers or DTO parsing outside Freezed-generated JSON logic.

4. **Private Constructor Rule for Custom Getters:**
   - Always define `const ClassName._();` if adding getters, computed properties, or custom methods to a Freezed class.

5. **Defensive Collection Immutability:**
   - All fields MUST be `final`.
   - Ensure nested collections cannot be mutated externally by using `List.unmodifiable` / `Map.unmodifiable` or `package:collection` discipline.

---

## 1. Optimized `build.yaml` Configuration

Place this file at the project root to restrict code generation scope.

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

---

## 2. Freezed Domain Entity (With Custom Getters)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';

@freezed
abstract class UserProfile with _$UserProfile {
  // Required private constructor to enable custom getters
  const UserProfile._();

  const factory UserProfile({
    required String id,
    required String firstName,
    required String lastName,
    required List<String> roles,
  }) = _UserProfile;

  /// Computed getter
  String get fullName => '$firstName$lastName';

  bool get isAdmin => roles.contains('admin');
}

```

---

## 3. BLoC State Management: Native `sealed class` vs `@freezed`

### Option A: Native Dart 3 Sealed Classes (Preferred for lightweight states)

```dart
import 'package:flutter/foundation.dart';
import 'package:my_app/domain/entities/user_profile.dart';

@immutable
sealed class ProfileState {
  const ProfileState();
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileSuccess extends ProfileState {
  final UserProfile user;
  const ProfileSuccess(this.user);
}

final class ProfileFailure extends ProfileState {
  final String message;
  const ProfileFailure(this.message);
}

```

### Option B: UI Pattern Matching (Native Dart 3 `switch`)

```dart
Widget buildState(BuildContext context, ProfileState state) {
  return switch (state) {
    ProfileInitial() => const SizedBox.shrink(),
    ProfileLoading() => const CircularProgressIndicator(),
    ProfileSuccess(:final user) => Text('Welcome, ${user.fullName}'),
    ProfileFailure(:final message) => Text('Error: $message'),
  };
}

```

---

## 4. DTO & Explicit JSON Mapping (Data Layer)

Keep JSON parsing separate from Freezed logic when `fromJson`/`toJson` generation is disabled.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_app/domain/entities/user_profile.dart';

part 'user_dto.freezed.dart';

@freezed
abstract class UserDto with _$UserDto {
  const factory UserDto({
    required String id,
    required String firstName,
    required String lastName,
    required List<String> roles,
  }) = _UserDto;

  /// Explicit manual factory constructor instead of generated code
  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      roles: List<String>.from(json['roles'] as List? ?? []),
    );
  }
}

/// Mapper extension to convert DTO to Domain Entity
extension UserDtoMapper on UserDto {
  UserProfile toDomain() {
    return UserProfile(
      id: id,
      firstName: firstName,
      lastName: lastName,
      roles: List.unmodifiable(roles),
    );
  }
}

```

---

## 5. Lightweight Value Objects via Equatable

Use `Equatable` for simple value types where Freezed code generation is overkill.

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

## Anti-Patterns (Strictly Prohibited)

| Anti-Pattern                                                   | Severity     | Corrective Action                            |
| -------------------------------------------------------------- | ------------ | -------------------------------------------- |
| Invoking `.when()`, `.maybeWhen()`, `.map()`, or `.maybeMap()` | **CRITICAL** | Use native Dart 3 `switch` pattern matching. |

|
| Expecting Freezed to generate `fromJson`/`toJson` when disabled in `build.yaml` | **CRITICAL** | Write explicit JSON factories or use separate data mappers.

|
| Adding getters/methods to Freezed models without `const Class._()` | **HIGH** | Include `const ClassName._();` empty constructor.

|
| Exposing mutable collections (`List`, `Map`) inside models | **HIGH** | Wrap collections in `List.unmodifiable` or defensive copies.

|
| Putting transport JSON logic directly into Domain Entities | **HIGH** | Restrict JSON serialization to Data Layer DTOs.

|

---

## Agent Verification Checklist

When reviewing data models or BLoC states:

1. **`build.yaml` Alignment:** Code does not rely on `when`, `map`, or generated `fromJson`/`toJson`.

2. **Dart 3 Switch Used:** All union state handling utilizes native `switch` expressions.

3. **Private Constructor Present:** Models with custom getters contain `const ClassName._();`.

4. **Clean Architecture Isolation:** Domain layer entities are clean and free of JSON parsing annotations.

5. **Tool Selection Accuracy:** `@freezed` is reserved for complex data models/DTOs; `Equatable` or native `sealed class` is used for lightweight value objects/states.
