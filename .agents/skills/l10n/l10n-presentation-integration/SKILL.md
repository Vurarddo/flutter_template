---
name: l10n-presentation-integration
description: Integration patterns for localized copy in the Presentation layer. Covers MaterialApp.router setup (localizationsDelegates, supportedLocales), BuildContext extensions (context.localization), DomainFailure to localized string mappers, dynamic locale switching via Cubit, and locale-aware DateFormat/NumberFormat.
---

# Presentation Layer Localization Integration

## 1. Overview & When to Apply

Use this skill whenever:
- Wiring localization delegates in `MaterialApp.router` (`lib/application.dart`).
- Accessing localized strings in UI widgets using `context.localization.<key>`.
- Mapping pure `DomainFailure` states to localized error messages via UI extensions.
- Implementing dynamic runtime language switching (e.g., English <-> Ukrainian) using a `LocaleCubit` or `HydratedCubit`.
- Formatting dates, times, and currencies using `DateFormat` and `NumberFormat` with the active locale.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [l10n-hub](../l10n-hub/SKILL.md) | Architectural rules and layer separation. |
| **UI Utils Hub** | [flutter-ui-utils-hub](../../presentation/ui-utils/flutter-ui-utils-hub/SKILL.md) | UI context extensions and presentation helpers. |
| **State Management** | [flutter-bloc-hub](../../presentation/state-management/flutter-bloc-hub/SKILL.md) | BLoC/Cubit state management for runtime settings. |

---

## 3. Core Localization Architecture Rules

1. **Pure Presentation Layer Resolution:** Never pass `BuildContext` into Domain UseCases or Data layer models.
2. **Access via Extension:** Always use `context.localization` rather than verbose `S.of(context)`.
3. **Map Failures in UI:** Map typed `DomainFailure` variants to localized error strings via `DomainFailureLocalizationX.toLocalizedString(context)`.

---

## 4. Reference Implementations (`examples/`)

- **Context Localization Shorthand (`BuildContextLocalizationX`):** [examples/l10n_context_extension.dart](examples/l10n_context_extension.dart)
  - Clean accessor `context.localization` for all generated strings.
- **Domain Failure Localization Mapper:** [examples/failure_localization_extension.dart](examples/failure_localization_extension.dart)
  - Maps `NetworkFailure`, `UnauthorizedFailure`, `ServerFailure`, etc., to localized strings.

---

## 5. Verification Checklist

- [ ] `localizationsDelegates` and `supportedLocales` configured in `MaterialApp.router`.
- [ ] UI widgets consume strings strictly via `context.localization`.
- [ ] Failures mapped to user copy in Presentation via extension.
- [ ] Date, number, and currency formatters consume active `Locale`.
