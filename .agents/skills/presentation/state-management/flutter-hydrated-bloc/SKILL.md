---
name: flutter-hydrated-bloc
description: Best practices for local state persistence using HydratedBloc and HydratedCubit in Flutter. Use when implementing persistent UI states, caching filter preferences, separating serialization into mixin files, enforcing PII/token security constraints, and handling corrupted cache fallbacks.
---

# Flutter Hydrated BLoC Persistence Guide

## 1. Overview & When to Apply

Use this skill whenever:
- Persisting non-sensitive UI state across app restarts (e.g., active filter selections, sort order, user theme preference, cached dashboard overview).
- Implementing `HydratedBloc` or `HydratedCubit`.
- Extracting serialization boilerplate (`fromJson`, `toJson`, `storagePrefix`) into dedicated mixin files per `AGENTS.md`.
- Enforcing strict data security standards (preventing PII and auth token leaks in unencrypted storage).
- Testing Hydrated BLoCs with mock `HydratedStorage`.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [flutter-bloc-hub](../flutter-bloc-hub/SKILL.md) | Domain architecture and overall routing. |
| **Core BLoC Logic** | [flutter-bloc-core](../flutter-bloc-core/SKILL.md) | Designing base states, events, and lifecycle. |
| **Unit Testing** | [testing-unit](../../../testing/testing-unit/SKILL.md) | Testing state restoration and error fallbacks. |

---

## 3. Core Architectural Boundaries & Security Rules

1. **Strict Mixin Separation (Mandatory per `AGENTS.md`):**
   - ALL Hydrated BLoCs and Cubits MUST extract `fromJson`, `toJson`, and `storagePrefix` logic into a separate file:
     `hydrated_<feature_name>_bloc.mixin.dart`.
   - The main BLoC file must remain clean and focus solely on business logic orchestration.
2. **Strict Security & PII Protection:**
   - **STRICTLY PROHIBITED:** Storing access tokens, refresh tokens, passwords, credit card numbers, or Personal Identifiable Information (PII) inside `HydratedBloc`.
   - Sensitive credentials MUST be stored in `FlutterSecureStorage` strictly managed by the **Data Layer**.
   - `HydratedBloc` is reserved ONLY for non-sensitive presentation preferences and offline UI cache.
3. **Safe Fallback on Corrupted Cache:**
   - The `fromJson` implementation MUST be wrapped in a `try-catch` block and return `null` (or default initial state) when JSON structure changes or is corrupted.

---

## 4. Standard Hydrated Implementation Pattern

### 4.1 Mixin File (`hydrated_<feature_name>_bloc.mixin.dart`)

```dart
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:flutter_template/domain/feature/entities/feature_filter_entity.dart';
import 'package:flutter_template/presentation/state_management/<feature_name>/<feature_name>_bloc.dart';

mixin HydratedFeatureBlocMixin on HydratedMixin<FeatureState> {
  @override
  String get storagePrefix => 'FeatureBloc_v1'; // Explicit versioned prefix, never runtimeType

  @override
  FeatureState? fromJson(Map<String, dynamic> json) {
    try {
      final rawFilter = json['active_filter'] as Map<String, dynamic>?;
      if (rawFilter == null) return null;

      final filter = FeatureFilterEntity(
        categoryId: rawFilter['category_id'] as String? ?? 'all',
        sortBy: rawFilter['sort_by'] as String? ?? 'date',
      );

      return FeatureLoadSuccess(filter: filter);
    } catch (_) {
      // Return null on corrupted JSON or schema migration to safely fallback to Initial state
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(FeatureState state) {
    // Only persist stable success states containing persistent preferences
    if (state is FeatureLoadSuccess) {
      return {
        'active_filter': {
          'category_id': state.filter.categoryId,
          'sort_by': state.filter.sortBy,
        },
      };
    }
    // Do NOT persist transient lifecycle states (Loading, Failure)
    return null;
  }
}
```

### 4.2 Main BLoC File (`<feature_name>_bloc.dart`)

```dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_template/presentation/state_management/<feature_name>/hydrated_<feature_name>_bloc.mixin.dart';

part '<feature_name>_event.dart';
part '<feature_name>_state.dart';

@injectable
class FeatureBloc extends Bloc<FeatureEvent, FeatureState>
    with HydratedMixin<FeatureState>, HydratedFeatureBlocMixin {
  FeatureBloc() : super(FeatureInitial()) {
    hydrate(); // Initialize hydrated storage restoration

    on<FeatureFilterChanged>(_onFilterChanged);
    on<FeatureFilterReset>(_onFilterReset);
  }

  void _onFilterChanged(
    FeatureFilterChanged event,
    Emitter<FeatureState> emit,
  ) {
    emit(FeatureLoadSuccess(filter: event.filter));
  }

  void _onFilterReset(
    FeatureFilterReset event,
    Emitter<FeatureState> emit,
  ) {
    emit(const FeatureLoadSuccess(filter: FeatureFilterEntity.defaults()));
  }
}
```

---

## 5. Unit Testing Hydrated BLoC

When testing Hydrated BLoC instances, initialize mock `HydratedStorage` before tests:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockHydratedStorage extends Mock implements Storage {}

void main() {
  late Storage storage;

  setUp(() {
    storage = MockHydratedStorage();
    when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
    HydratedBloc.storage = storage;
  });

  test('restores cached state from fromJson correctly', () {
    when(() => storage.read('FeatureBloc_v1')).thenReturn({
      'active_filter': {'category_id': 'tech', 'sort_by': 'popular'},
    });

    final bloc = FeatureBloc();
    expect(bloc.state, isA<FeatureLoadSuccess>());
  });
}
```

---

## 6. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Storing auth tokens, passwords, or PII in `HydratedBloc` | **CRITICAL** | Store credentials strictly in `FlutterSecureStorage` via Data layer. |
| Inlining `fromJson` / `toJson` directly inside main BLoC file | **HIGH** | Extract serialization to `hydrated_<feature>_bloc.mixin.dart`. |
| Persisting transient states (`LoadInProgress`, `Failure`) | **HIGH** | Return `null` in `toJson` for transient states to avoid caching spinners/errors. |
| Using `runtimeType.toString()` as `storagePrefix` | **HIGH** | Provide explicit versioned string (e.g. `'FeatureBloc_v1'`) to avoid obfuscation bugs. |
| Crashing on unexpected JSON format | **MEDIUM** | Wrap `fromJson` body in `try-catch` and return fallback `null`. |

---

## 7. Verification Checklist

- [ ] All `fromJson`, `toJson`, and `storagePrefix` code is extracted into `hydrated_<feature>_bloc.mixin.dart`.
- [ ] No sensitive credentials or PII are written to `toJson`.
- [ ] Transient states (`Loading`, `Failure`) are excluded from persistence.
- [ ] Storage prefix is hardcoded and versioned (e.g. `FeatureBloc_v1`).
- [ ] Corrupted JSON fallback returns `null` or default state safely without crashing.
