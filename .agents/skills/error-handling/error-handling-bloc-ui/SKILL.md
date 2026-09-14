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
| **BLoC Core** | [flutter-bloc-core](../../presentation/state-management/flutter-bloc-core/SKILL.md) | Standard BLoC architecture, events, and states. |
| **Localization Integration** | [l10n-presentation-integration](../../l10n/l10n-presentation-integration/SKILL.md) | `context.localization` and ARB string access. |

---

## 3. Core Error Handling Rules

1. **Mandatory Stack Trace Forwarding:** Always call `addError(error, stackTrace)` in catch blocks.
2. **Typed Failure States:** Wrap errors into `DomainFailure` variants before emitting UI states.
3. **No Auto-Reset:** Never reset a `Failure` state back to `Initial` in the same handler. Reset only via explicit user retry actions.
4. **Localize in UI Layer:** Map `DomainFailure` via `toLocalizedString(context)` in Presentation.

---

## 4. Reference Implementations (`examples/`)

- **BLoC Try-Catch Handler:** [examples/error_bloc_handler_sample.dart](examples/error_bloc_handler_sample.dart)
  - Full event handler showing `addError(error, stackTrace)`, async checks, and typed `DomainFailure` state emission.
- **Full-Screen Error View with Retry:** [examples/error_view_with_retry_sample.dart](examples/error_view_with_retry_sample.dart)
  - UI component consuming `failure.toLocalizedString(context)` and triggering user retry.

---

## 5. Verification Checklist

- [ ] `addError(error, stackTrace)` called in all BLoC catch blocks.
- [ ] Failure states emit typed `DomainFailure` objects.
- [ ] No automatic state reset back to `Initial` without user action.
- [ ] UI errors localized via `DomainFailureLocalizationX`.
