---
name: flutter-bloc
description: Implements expert-level flutter_bloc patterns with unidirectional data flow, immutable states, strict file layout (part/part of), UseCase isolation, Emitter safety after async, addError for failure tracking, UI split between BlocListener and BlocBuilder, HydratedBloc mixin separation, and bloc_concurrency transformers. Use when creating, refactoring, or reviewing BLoCs/Cubits.
---

# Flutter BLoC — Expert Implementation Skill

## When to Apply

Use this skill for creating new BLoCs/Cubits, refactoring presentation state management, implementing async state flows, configuring Hydrated persistence, or reviewing PRs for state management anti-patterns.

---

## Architecture Rules & Import Constraints

- **Zero UI Dependencies:** BLoCs/Cubits MUST NOT import `package:flutter/material.dart` or any UI-related packages. Pure Dart only.
- **UseCase Isolation:** BLoCs orchestrate **Domain UseCases** only. Direct references to `Repositories`, `DataSources`, or `ApiClients` are strictly prohibited.
- **Dart 3 Modifiers:** Base Events and States MUST be `sealed class`. Concrete implementations MUST be `final class`.
- **No Public Imperative API:** Do NOT write public methods like `bloc.fetchData()`. All state changes MUST be triggered strictly via `context.read<FeatureBloc>().add(FeatureEvent())`.

---

## Bloc vs Cubit Decision Matrix

| Type      | When to Use                                                                                                                                                        |
| :-------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Cubit** | Simple, linear state switches (e.g., toggle theme, show/hide password, pure synchronous/simple async).                                                             |
| **Bloc**  | Event-driven logic, multiple actions affecting the same state, event buffering/concurrency needs (`droppable`, `restartable`), or when event auditing is required. |

---

## File Structure & File Layout

All BLoC files MUST use the `part` / `part of` directive:

```text
lib/presentation/state_management/<feature_name>/
├── <feature_name>_event.dart                   # part of '<feature_name>_bloc.dart';
├── <feature_name>_state.dart                   # part of '<feature_name>_bloc.dart';
├── <feature_name>_bloc.dart                    # main bloc file with imports & handlers
└── hydrated_<feature_name>_bloc.mixin.dart    # ONLY if HydratedBloc persistence is required

```

---

## Standard Code Implementation Templates

### 1. Events (`<feature_name>_event.dart`)

```dart
part of '<feature_name>_bloc.dart';

sealed class FeatureEvent extends Equatable {
  const FeatureEvent();

  @override
  List<Object?> get props => [];
}

final class FeatureFetchRequested extends FeatureEvent {
  final String id;

  const FeatureFetchRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

final class FeatureSubmitPressed extends FeatureEvent {
  final String payload;

  const FeatureSubmitPressed(this.payload);

  @override
  List<Object?> get props => [payload];
}

```

### 2. States (`<feature_name>_state.dart`)

```dart
part of '<feature_name>_bloc.dart';

sealed class FeatureState extends Equatable {
  const FeatureState();

  @override
  List<Object?> get props => [];
}

final class FeatureInitial extends FeatureState {}

final class FeatureLoadInProgress extends FeatureState {}

final class FeatureLoadSuccess extends FeatureState {
  final FeatureEntity data;

  const FeatureLoadSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

final class FeatureFailure extends FeatureState {
  final String message;

  const FeatureFailure(this.message);

  @override
  List<Object?> get props => [message];
}

```

### 3. BLoC Class (`<feature_name>_bloc.dart`)

```dart
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'package:your_app/domain/feature/entities/feature_entity.dart';
import 'package:your_app/domain/feature/usecases/get_feature_usecase.dart';

part '<feature_name>_event.dart';
part '<feature_name>_state.dart';

@injectable
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  final GetFeatureUseCase _getFeatureUseCase;

  FeatureBloc(
    this._getFeatureUseCase,
  ) : super(FeatureInitial()) {
    on<FeatureFetchRequested>(
      _onFetchRequested,
      transformer: restartable(), // Cancel previous request if a new event arrives
    );
    on<FeatureSubmitPressed>(
      _onSubmitPressed,
      transformer: droppable(), // Ignore new clicks until current submission finishes
    );
  }

  Future<void> _onFetchRequested(
    FeatureFetchRequested event,
    Emitter<FeatureState> emit,
  ) async {
    emit(FeatureLoadInProgress());

    try {
      final result = await _getFeatureUseCase(event.id);

      // Mandatory Async Guard Safety Check
      if (emit.isDone) return;

      emit(FeatureLoadSuccess(result));
    } catch (error, stackTrace) {
      if (emit.isDone) return;

      // Pass error to global BlocObserver / Crashlytics
      addError(error, stackTrace);

      emit(FeatureFailure(error.toString()));
    }
  }

  Future<void> _onSubmitPressed(
    FeatureSubmitPressed event,
    Emitter<FeatureState> emit,
  ) async {
    // Handler implementation...
  }
}

```

### 4. Hydrated Persistence Mixin (`hydrated_<feature_name>_bloc.mixin.dart`)

```dart
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:your_app/presentation/state_management/<feature_name>/<feature_name>_bloc.dart';

mixin HydratedFeatureBlocMixin on HydratedMixin<FeatureState> {
  @override
  String get storagePrefix => 'FeatureBloc_v1'; // Stable prefix, never runtimeType

  @override
  FeatureState? fromJson(Map<String, dynamic> json) {
    try {
      final rawData = json['cached_data'] as Map<String, dynamic>?;
      if (rawData == null) return null;
      // Parse safe fields and return restored state
      return FeatureInitial();
    } catch (_) {
      return null; // Return null on corrupted json to safely fallback to Initial state
    }
  }

  @override
  Map<String, dynamic>? toJson(FeatureState state) {
    if (state is FeatureLoadSuccess) {
      return {
        'cached_data': state.data.toCacheJson(),
      };
    }
    return null; // Do not persist transient states (Loading, Error)
  }
}

```

---

## Event Concurrency Reference (`bloc_concurrency`)

| Transformer     | Behavioral Mechanism                                               | Recommended Use Case                                       |
| --------------- | ------------------------------------------------------------------ | ---------------------------------------------------------- |
| `restartable()` | Cancels running handler and starts new execution immediately.      | Search input, Tab/Filter changes, Auto-complete.           |
| `droppable()`   | Ignores incoming events while current handler execution is active. | Submit form buttons, Payment triggers, Refresh CTA.        |
| `sequential()`  | Queues incoming events and processes them one after another.       | Audio playlist, Sequential queue tasks, Step-by-step logs. |

---

## UI Component Responsibility Matrix

| Widget             | Primary Responsibility                                             | Anti-Pattern Warning                                                    |
| ------------------ | ------------------------------------------------------------------ | ----------------------------------------------------------------------- |
| **`BlocListener`** | One-off side effects: Navigation, Showing Dialogs / SnackBars.     | DO NOT render UI widgets or layouts inside `listener`.                  |
| **`BlocBuilder`**  | Building and rebuilding UI widgets based on state.                 | DO NOT call `Navigator.push()` or `showBottomSheet()` inside `builder`. |
| **`BlocSelector`** | Rebuilding UI ONLY when a specific sub-field changes (`selector`). | Use to prevent unnecessary screen rebuilds on large state trees.        |
| **`BlocConsumer`** | Combined `BlocListener` and `BlocBuilder` in a single tree node.   | Avoid using if listener and builder logic are far apart.                |

---

## Anti-Patterns (Strictly Prohibited)

| Violation                                            | Severity     | Corrective Action                                               |
| ---------------------------------------------------- | ------------ | --------------------------------------------------------------- |
| `import 'package:flutter/*'` inside BLoC             | **CRITICAL** | Remove Flutter imports. BLoC must remain pure Dart.             |
| Missing `if (emit.isDone) return;` after `await`     | **HIGH**     | Add safety check immediately after every asynchronous `await`.  |
| Exposing public methods (`bloc.refresh()`)           | **HIGH**     | Define a new `FeatureEvent` and trigger via `add()`.            |
| Storing sensitive tokens/passwords in `HydratedBloc` | **HIGH**     | Store tokens strictly in `FlutterSecureStorage` via Data layer. |
| Mutating state fields directly without `emit`        | **HIGH**     | Always pass a new state instance into `emit()`.                 |

---

## Testing Guidelines (`bloc_test`)

When writing unit tests for BLoCs:

1. Use `blocTest<FeatureBloc, FeatureState>()`.
2. Mock all injected **UseCases** (using `mocktail` or `mockito`).
3. Standard structure:

- `build:` Instantiate BLoC with mock UseCases.
- `act:` Dispatch event via `bloc.add(Event())`.
- `expect:` Assert exact emitted state array sequence `() => [FeatureLoadInProgress(), FeatureLoadSuccess(...)]`.

4. Test `fromJson`/`toJson` round-trips and verify fallback to default state on corrupted JSON for Hydrated BLoCs.
