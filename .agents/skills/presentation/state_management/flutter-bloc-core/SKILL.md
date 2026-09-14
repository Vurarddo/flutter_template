---
name: flutter-bloc-core
description: Core architecture patterns and best practices for Flutter BLoC and Cubit. Use when creating BLoC or Cubit classes, designing sealed states and events, configuring event transformers (bloc_concurrency), handling async guards (emit.isDone), implementing error handling, or deciding between BLoC and Cubit.
---

# Flutter BLoC & Cubit Core Architecture Guide

## 1. Overview & When to Apply

Use this skill whenever:
- Designing or implementing new BLoC or Cubit classes in `lib/presentation/state_management/`.
- Deciding whether to use a **BLoC** or a **Cubit** for a given feature.
- Defining strongly-typed events and states using Dart 3 `sealed class` and `final class`.
- Applying event concurrency transformers (`restartable`, `droppable`, `sequential`) via `bloc_concurrency`.
- Enforcing asynchronous safety guards (`if (emit.isDone) return;`) and structured error logging.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [flutter-bloc-hub](../flutter-bloc-hub/SKILL.md) | Domain architecture, laws, and routing. |
| **UI Integration** | [flutter-bloc-widgets](../flutter-bloc-widgets/SKILL.md) | Connecting BLoC to widgets via Providers, Builders, and Listeners. |
| **Persistence** | [flutter-hydrated-bloc](../flutter-hydrated-bloc/SKILL.md) | State persistence and mixin extraction. |
| **Domain Layer** | [flutter-clean-architecture](../../../flutter_clean_architecture/SKILL.md) | Injecting Domain UseCases and Entities. |

---

## 3. BLoC vs Cubit Decision Matrix

| Criterion | Use **Cubit** | Use **BLoC** |
| :--- | :--- | :--- |
| **Complexity** | Simple, linear, synchronous or straightforward async transitions. | Complex workflows, multi-step operations, branchy async state machines. |
| **Trigger Mechanism** | Direct public method calls (e.g., `cubit.toggleTheme()`, `cubit.selectTab(2)`). | Explicit typed events dispatched via `bloc.add(Event())`. |
| **Concurrency Control** | Not supported natively (events execute as called without queue control). | **Mandatory** when requiring `restartable()`, `droppable()`, or `sequential()`. |
| **Event Auditing / Tracing** | States only in `BlocObserver`. No event stream logs. | Full event-to-state traceability in analytics, debug logs, and Sentry/Crashlytics. |
| **Use Case Examples** | Theme switch, bottom nav index, password visibility toggle, simple counter. | Search/autocomplete query, payment/form submission, paginated feed, multi-step wizard. |

---

## 4. File Structure & 3-File Pattern Standard

Feature BLoCs MUST be split into three separate files using `part` / `part of` directives:

```text
lib/presentation/state_management/<feature_name>/
├── <feature_name>_event.dart    # part of '<feature_name>_bloc.dart';
├── <feature_name>_state.dart    # part of '<feature_name>_bloc.dart';
└── <feature_name>_bloc.dart     # main bloc file with DI, dependencies, and event handlers
```

---

## 5. Standard Implementation Templates

### 5.1 Events (`<feature_name>_event.dart`)

```dart
part of '<feature_name>_bloc.dart';

sealed class FeatureEvent extends Equatable {
  const FeatureEvent();

  @override
  List<Object?> get props => [];
}

final class FeatureFetchRequested extends FeatureEvent {
  final String query;

  const FeatureFetchRequested({this.query = ''});

  @override
  List<Object?> get props => [query];
}

final class FeatureSubmitPressed extends FeatureEvent {
  final FeatureRequestEntity payload;

  const FeatureSubmitPressed(this.payload);

  @override
  List<Object?> get props => [payload];
}

final class FeatureRetryClicked extends FeatureEvent {
  const FeatureRetryClicked();
}
```

### 5.2 States (`<feature_name>_state.dart`)

```dart
part of '<feature_name>_bloc.dart';

sealed class FeatureState extends Equatable {
  const FeatureState();

  @override
  List<Object?> get props => [];
}

final class FeatureInitial extends FeatureState {}

final class FeatureLoadInProgress extends FeatureState {}

@CopyWith()
final class FeatureLoadSuccess extends FeatureState {
  final List<FeatureEntity> items;
  final bool hasMore;
  final bool isRefreshing;

  const FeatureLoadSuccess({
    required this.items,
    this.hasMore = false,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [items, hasMore, isRefreshing];
}

final class FeatureFailure extends FeatureState {
  final String message;

  const FeatureFailure(this.message);

  @override
  List<Object?> get props => [message];
}
```

### 5.3 BLoC Class (`<feature_name>_bloc.dart`)

```dart
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_template/domain/feature/entities/feature_entity.dart';
import 'package:flutter_template/domain/feature/entities/feature_request_entity.dart';
import 'package:flutter_template/domain/feature/usecases/get_features_usecase.dart';
import 'package:flutter_template/domain/feature/usecases/submit_feature_usecase.dart';

part '<feature_name>_event.dart';
part '<feature_name>_state.dart';
part '<feature_name>_bloc.g.dart';

@injectable
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  final GetFeaturesUseCase _getFeaturesUseCase;
  final SubmitFeatureUseCase _submitFeatureUseCase;

  FeatureBloc(
    this._getFeaturesUseCase,
    this._submitFeatureUseCase,
  ) : super(FeatureInitial()) {
    on<FeatureFetchRequested>(
      _onFetchRequested,
      transformer: restartable(), // Cancels previous in-flight search on new input
    );
    on<FeatureSubmitPressed>(
      _onSubmitPressed,
      transformer: droppable(), // Drops rapid duplicate clicks until submission completes
    );
    on<FeatureRetryClicked>(
      _onRetryClicked,
      transformer: droppable(),
    );
  }

  Future<void> _onFetchRequested(
    FeatureFetchRequested event,
    Emitter<FeatureState> emit,
  ) async {
    emit(FeatureLoadInProgress());

    try {
      final items = await _getFeaturesUseCase(event.query);

      // Mandatory Async Safety Guard Check
      if (emit.isDone) return;

      emit(FeatureLoadSuccess(items: items));
    } catch (error, stackTrace) {
      if (emit.isDone) return;

      // Pass error to global observer for logging/crashlytics
      addError(error, stackTrace);

      emit(FeatureFailure(error.toString()));
    }
  }

  Future<void> _onSubmitPressed(
    FeatureSubmitPressed event,
    Emitter<FeatureState> emit,
  ) async {
    try {
      await _submitFeatureUseCase(event.payload);

      if (emit.isDone) return;

      // Re-trigger fetch or emit success state
    } catch (error, stackTrace) {
      if (emit.isDone) return;

      addError(error, stackTrace);
      emit(FeatureFailure(error.toString()));
    }
  }

  Future<void> _onRetryClicked(
    FeatureRetryClicked event,
    Emitter<FeatureState> emit,
  ) async {
    add(const FeatureFetchRequested());
  }
}
```

---

## 6. Event Concurrency Transformers Reference

| Transformer | Mechanism | Best Use Cases |
| :--- | :--- | :--- |
| `restartable()` | Cancels any currently executing handler when a new event of the same type arrives. | Live search inputs, filter tabs switching, auto-complete queries. |
| `droppable()` | Ignores incoming events of the same type while the current event handler is executing. | Form submit buttons, checkout/payment CTA, manual pull-to-refresh. |
| `sequential()` | Queues incoming events and executes them one after another in order. | Transaction queues, message sending queue, sequential analytics processing. |
| `concurrent()` (default) | Executes each event handler concurrently without cancellation or queuing. | Independent read requests, independent widget heartbeats. |

---

## 7. Error Handling & State Stability Rules

1. **Emit Failure, Do Not Auto-Reset:**
   - NEVER emit `FeatureFailure` and immediately follow it with `FeatureInitial` within the same event handler. This causes severe UI flickering.
   - Failure states should be dismissed ONLY via explicit user retry actions (e.g. `FeatureRetryClicked`).
2. **Mandatory `addError` Logging:**
   - Always invoke `addError(error, stackTrace)` before emitting `FeatureFailure`. This ensures errors reach `BlocObserver` and remote telemetry (Crashlytics/Sentry).
3. **Async Guards (`emit.isDone`):**
   - After ANY `await` call, you MUST check `if (emit.isDone) return;`. This prevents unhandled exceptions when BLoC is closed or an event was cancelled by `restartable()`.

---

## 8. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Importing `package:flutter/material.dart` inside BLoC/Cubit | **CRITICAL** | Remove Flutter imports. Keep BLoC 100% pure Dart. |
| Calling `Repository` or `ApiClient` directly from BLoC | **CRITICAL** | Inject and call single-purpose **Domain UseCases** only. |
| Missing `if (emit.isDone) return;` after `await` | **HIGH** | Add safety guard check after every asynchronous operation. |
| Exposing public methods on BLoC (e.g., `bloc.loadData()`) | **HIGH** | Define typed `FeatureEvent` and trigger via `bloc.add()`. |
| Single monolithic state with 10+ nullable boolean flags | **HIGH** | Model explicit lifecycle states: `Initial`, `InProgress`, `Success`, `Failure`. |
| Manual `copyWith` implementation for complex state | **MEDIUM** | Annotate state class with `@CopyWith()` from `copy_with_extension`. |

---

## 9. Verification Checklist

- [ ] BLoC file is split into `_event.dart`, `_state.dart`, `_bloc.dart` using `part` / `part of`.
- [ ] Dependencies injected via constructor are Domain UseCases annotated with `@injectable`.
- [ ] Base event/state classes use `sealed class`; variants use `final class` and extend `Equatable`.
- [ ] Every asynchronous handler verifies `if (emit.isDone) return;` immediately after `await`.
- [ ] `restartable()` or `droppable()` transformers are configured where race conditions or double-taps may occur.
- [ ] Errors are captured with `addError(error, stackTrace)` and mapped to typed failure states.
