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
| **UI Utils Hub** | [flutter-ui-utils-hub](../../presentation/ui_utils/flutter-ui-utils-hub/SKILL.md) | UI context extensions and presentation helpers. |
| **State Management** | [flutter-state-management-hub](../../presentation/state_management/flutter-state-management-hub/SKILL.md) | BLoC/Cubit state management for runtime settings. |
| **Storage** | [infrastructure-storage](../../infrastructure/infrastructure-storage/SKILL.md) | Persisting user's selected locale to disk. |

---

## 3. `MaterialApp.router` Setup (`lib/application.dart`)

Configure `localizationsDelegates` and `supportedLocales` in `Application`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_template/infrastructure/di/injection.dart';
import 'package:flutter_template/l10n/generated/l10n.dart';
import 'package:flutter_template/presentation/navigation/app_router.dart';
import 'package:flutter_template/presentation/state_management/locale/locale_cubit.dart';
import 'package:flutter_template/presentation/state_management/locale/locale_state.dart';
import 'package:flutter_template/presentation/theme/app_theme.dart';

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();

    return BlocProvider(
      create: (context) => getIt<LocaleCubit>(),
      child: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Flutter Template',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.system,
            routerConfig: appRouter.config(),
            locale: state.locale,
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
          );
        },
      ),
    );
  }
}
```

---

## 4. `BuildContext` Extension (`context.localization`)

To avoid verbose `S.of(context)` calls across widgets, use a dedicated extension:

```dart
// lib/presentation/ui_utils/extensions/build_context_localization_extension.dart
import 'package:flutter/material.dart';
import 'package:flutter_template/l10n/generated/l10n.dart';

extension BuildContextLocalizationX on BuildContext {
  /// Shorthand accessor for generated localization strings
  S get localization => S.of(this);
}
```

### Usage in UI Widgets:

```dart
class WelcomeHeader extends StatelessWidget {
  final String userName;
  final int unreadCount;

  const WelcomeHeader({
    super.key,
    required this.userName,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.localization.welcomeUser(userName),
          style: context.textTheme.titleLarge,
        ),
        Text(
          context.localization.itemsCount(unreadCount),
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
```

---

## 5. Domain Failure to Localized String Mapping

Domain layers return typed `DomainFailure` sealed classes. Presentation layer resolves them to user-friendly copy via an extension:

```dart
// lib/presentation/ui_utils/extensions/domain_failure_localization_extension.dart
import 'package:flutter/material.dart';
import 'package:flutter_template/domain/core/failures/domain_failure.dart';
import 'package:flutter_template/presentation/ui_utils/extensions/build_context_localization_extension.dart';

extension DomainFailureLocalizationX on DomainFailure {
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

## 6. Dynamic Runtime Locale Switching

```dart
// lib/presentation/state_management/locale/locale_cubit.dart
import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_template/infrastructure/storage/local_store_interactor.dart';

part 'locale_state.dart';

@injectable
class LocaleCubit extends Cubit<LocaleState> {
  final LocalStoreInteractor _store;
  static const String _localeKey = 'app_locale';

  LocaleCubit(this._store) : super(const LocaleState(Locale('en'))) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final languageCode = await _store.getString(_localeKey);
    if (languageCode != null) {
      emit(LocaleState(Locale(languageCode)));
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    await _store.setString(_localeKey, newLocale.languageCode);
    emit(LocaleState(newLocale));
  }
}
```

---

## 7. Locale-Aware Date & Number Formatting

Always pass the active locale to `intl` formatters:

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderSummaryTile extends StatelessWidget {
  final DateTime orderDate;
  final double totalPrice;

  const OrderSummaryTile({
    super.key,
    required this.orderDate,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    final String currentLocale = Localizations.localeOf(context).toString();

    final formattedDate = DateFormat.yMMMMd(currentLocale).format(orderDate);
    final formattedPrice = NumberFormat.simpleCurrency(
      locale: currentLocale,
    ).format(totalPrice);

    return ListTile(
      title: Text(formattedPrice),
      subtitle: Text(formattedDate),
    );
  }
}
```

---

## 8. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Hardcoding text in widgets (`Text('Save Changes')`) | **CRITICAL** | Use `Text(context.localization.saveButtonLabel)`. |
| Importing `package:flutter_template/l10n/...` in Domain or Data | **CRITICAL** | Keep Domain/Data 100% agnostic of localization. |
| Constructing formatters without `locale: Localizations.localeOf(context)` | **MEDIUM** | Always pass active locale to `DateFormat` and `NumberFormat`. |
| Calling `S.current` inside build methods when `context` is available | **HIGH** | Use `context.localization` so widget rebuilds when locale changes. |

---

## 9. Verification Checklist

- [ ] `MaterialApp.router` delegates include `S.delegate` and supported locales.
- [ ] `context.localization` extension is used across UI widgets.
- [ ] UI failures are mapped via `DomainFailureLocalizationX`.
- [ ] Language switching triggers dynamic UI rebuilds without restarting the app.
- [ ] Date and currency formats adapt cleanly when switching from `en` to `uk`.
