---
name: error-handling-bloc-ui
description: Standards and patterns for BLoC error handling and Presentation layer UI error resolution. Covers BLoC try-catch, addError stacktrace tracking, Failure state modeling, DomainFailureLocalizationX mapping via context.localization, error SnackBars, and retry flows.
---

# BLoC Error Handling & Presentation UI Resolution

## 1. Overview & When to Apply

Use this skill whenever:
- Catching exceptions inside BLoC/Cubit event handlers (`lib/presentation/state_management/`).
- Emitting typed failure states (`FeatureState.failure(DomainFailure)`).
- Preserving stack traces for crash reporting via `addError(error, stackTrace)`.
- Mapping `DomainFailure` to user-facing localized strings via `context.localization`.
- Implementing UI error presentation: full-screen `ErrorStateView`, bottom `SnackBar`, or modal dialogs.
- Designing user retry flows without UI flickering or auto-resetting failure states.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [error-handling-hub](../error-handling-hub/SKILL.md) | End-to-end error lifecycle. |
| **BLoC Core** | [flutter-bloc-core](../../presentation/state_management/flutter-bloc-core/SKILL.md) | Standard BLoC architecture, events, and states. |
| **Localization Integration** | [l10n-presentation-integration](../../l10n/l10n-presentation-integration/SKILL.md) | `context.localization` and ARB string access. |
| **UI Utils Hub** | [flutter-ui-utils-hub](../../presentation/ui_utils/flutter-ui-utils-hub/SKILL.md) | UI context extensions and helpers. |

---

## 3. Standard BLoC Event Handler Pattern

```dart
// lib/presentation/state_management/item/item_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_template/domain/core/failures/domain_failure.dart';
import 'package:flutter_template/domain/item/entities/item_entity.dart';
import 'package:flutter_template/domain/item/usecases/get_item_details_usecase.dart';

part 'item_event.dart';
part 'item_state.dart';

@injectable
class ItemBloc extends Bloc<ItemEvent, ItemState> {
  final GetItemDetailsUseCase _getItemDetails;

  ItemBloc(this._getItemDetails) : super(const ItemState.initial()) {
    on<ItemDetailsRequested>(_onDetailsRequested);
  }

  Future<void> _onDetailsRequested(
    ItemDetailsRequested event,
    Emitter<ItemState> emit,
  ) async {
    emit(const ItemState.loading());

    try {
      final item = await _getItemDetails(event.itemId);
      if (emit.isDone) return;
      emit(ItemState.success(item));
    } catch (error, stackTrace) {
      // 1. Mandatory stack trace forwarding for Crashlytics / Sentry
      addError(error, stackTrace);

      if (emit.isDone) return;

      // 2. Wrap into typed DomainFailure if not already typed
      final failure = error is DomainFailure
          ? error
          : DomainFailure.unknown(
              message: error.toString(),
              stackTrace: stackTrace,
            );

      // 3. Emit explicit Failure state
      emit(ItemState.failure(failure));
    }
  }
}
```

> [!IMPORTANT]
> **No Auto-Reset Rule:** DO NOT automatically clear or reset a `Failure` state back to `Initial` in the same handler. A Failure state must persist until the user explicitly triggers a retry action!

---

## 4. UI Localization Extension (`DomainFailureLocalizationX`)

```dart
// lib/presentation/ui_utils/extensions/domain_failure_localization_extension.dart
import 'package:flutter/material.dart';
import 'package:flutter_template/domain/core/failures/domain_failure.dart';
import 'package:flutter_template/presentation/ui_utils/extensions/build_context_localization_extension.dart';

extension DomainFailureLocalizationX on DomainFailure {
  /// Converts a pure DomainFailure into a user-friendly localized string
  String toLocalizedString(BuildContext context) {
    return switch (this) {
      NetworkFailure() => context.localization.errorNoInternet,
      UnauthorizedFailure() => context.localization.errorSessionExpired,
      NotFoundFailure() => context.localization.errorResourceNotFound,
      ServerFailure() => context.localization.errorGenericServer,
      TimeoutFailure() => context.localization.errorConnectionTimeout,
      UnknownFailure() => context.localization.errorUnknown,
    };
  }
}
```

---

## 5. UI Presentation Patterns

### A. Full-Screen Error State with Retry

```dart
class ItemErrorView extends StatelessWidget {
  final DomainFailure failure;
  final VoidCallback onRetry;

  const ItemErrorView({
    super.key,
    required this.failure,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: context.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              failure.toLocalizedString(context),
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: onRetry,
              child: Text(context.localization.retryButtonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
```

### B. One-Off Side-Effect Error via `BlocListener`

```dart
BlocListener<ItemBloc, ItemState>(
  listenWhen: (previous, current) => current is ItemFailureState,
  listener: (context, state) {
    if (state is ItemFailureState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.failure.toLocalizedString(context)),
          backgroundColor: context.colorScheme.error,
          action: SnackBarAction(
            label: context.localization.retryButtonLabel,
            textColor: context.colorScheme.onError,
            onPressed: () => context.read<ItemBloc>().add(const ItemRetryRequested()),
          ),
        ),
      );
    }
  },
  child: const ItemContentView(),
)
```

---

## 6. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Displaying `error.toString()` in UI | **CRITICAL** | Use `failure.toLocalizedString(context)` with `context.localization`. |
| Omitting `addError(error, stackTrace)` in BLoC `catch` | **HIGH** | Always call `addError()` before emitting failure state. |
| Catching errors without checking `if (emit.isDone) return;` | **HIGH** | Always guard against emitter cancellation after async calls. |
| Auto-resetting Failure to Initial immediately | **MEDIUM** | Let the UI stay in Failure state until user explicitly retries. |

---

## 7. Verification Checklist

- [ ] BLoC catches errors and calls `addError(error, stackTrace)`.
- [ ] Checked `if (emit.isDone) return;` after `await` and inside `catch`.
- [ ] States use typed `DomainFailure` objects.
- [ ] UI resolves copy via `failure.toLocalizedString(context)`.
- [ ] Zero `e.toString()` calls exist in UI layer.
