---
name: flutter-intl-localization
description: Enforces type-safe internationalization (i18n) and localization (l10n) using ARB files with official gen-l10n or flutter_intl/intl_utils (S.of context). Guarantees Clean Architecture boundaries, ICU plural/placeholder rules (zero manual string concatenation), context extensions, locale-aware DateFormat/NumberFormat, and dynamic locale switching.
---

# Flutter Internationalization & Localization Expert Skill

## When to Apply

Use this skill whenever adding user-facing UI copy, adding new locales, configuring ARB files, writing plurals/placeholders, formatting dates/currencies, or setting up dynamic language switching.

---

## Core Architectural Rules & Standards

1. **Single Source of Truth (ARB Files):**
   - ARB files are the **ONLY** source of translated strings. Modifying text requires editing ARB files first, then running code generation (`flutter gen-l10n` or `flutter pub run intl_utils:generate`).
   - Keys MUST use **`camelCase`** (e.g., `loginButtonLabel`, `itemsCount`). Keep key names stable; prefer adding new keys over silent renames.

2. **Clean Architecture Boundaries:**
   - **Domain Layer:** MUST NOT import `BuildContext` or `AppLocalizations` / `S`. Domain returns pure error codes, failure types, or enums.
   - **Presentation Layer:** Resolves domain codes/enums into localized strings via UI extensions or `context.l10n`.
   - **Context-Free Fallback (Use Sparingly):** If background services or logging require strings, use a dedicated lookup facade (e.g., `S.current`) ONLY after localization delegates are fully initialized.

3. **Strict ICU Syntax Rules (Zero Manual Concatenation):**
   - **STRICTLY PROHIBITED:** Constructing sentences via string concatenation like `'$greeting $userName'` or `'$a $b'` across localized parts.
   - Always use named placeholders (`{userName}`) and ICU plural/select formats in ARB.

---

## 1. Toolchain Parity Configuration

### Option A: Official `gen-l10n` (`l10n.yaml`)

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
nullable-getter: false
```

### Option B: `flutter_intl` / `intl_utils` (`pubspec.yaml`)

```yaml
flutter_intl:
  enabled: true
  class_name: S
  main_locale: en
  arb_dir: lib/l10n
  output_dir: lib/l10n/generated
```

---

## 2. ARB Formatting & Advanced ICU Syntax

Define messages with placeholders and plurals in `lib/l10n/app_en.arb` and `lib/l10n/app_uk.arb`.

### `app_en.arb`

```json
{
  "@@locale": "en",
  "welcomeUser": "Welcome back, {userName}!",
  "@welcomeUser": {
    "description": "User greeting on home screen",
    "placeholders": {
      "userName": {
        "type": "String",
        "example": "Vladyslav"
      }
    }
  },
  "itemCount": "{count, plural, =0{No items} =1{1 item} other{{count} items}}",
  "@itemCount": {
    "description": "Pluralized item counter",
    "placeholders": {
      "count": {
        "type": "num",
        "format": "compact"
      }
    }
  }
}
```

### `app_uk.arb` (Handling Slavic Plurals)

```json
{
  "@@locale": "uk",
  "welcomeUser": "З поверненням, {userName}!",
  "itemCount": "{count, plural, =0{Немає елементів} =1{1 елемент} few{{count} елементи} many{{count} елементів} other{{count} елементів}}"
}
```

---

## 3. Presentation Layer UI Access & Extensions

Simplify string access in widgets through context extensions.

```dart
// lib/core/extensions/build_context_l10n.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Or for intl_utils: import 'package:my_app/l10n/generated/l10n.dart';

extension LocalizedBuildContext on BuildContext {
  /// Unified shorthand getter for localized strings
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Alternative for intl_utils toolchain:
  /// S get l10n => S.of(this);
}

// Widget Example:
class CartBadge extends StatelessWidget {
  final int count;
  const CartBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.itemCount(count),
      style: context.textTheme.bodySmall,
    );
  }
}

```

---

## 4. Mapping Domain Failures & Context-Free Facades

### A. UI Failure Extension Mapping

```dart
extension FailureL10nX on Failure {
  String toLocalizedString(BuildContext context) {
    return switch (this) {
      NetworkFailure() => context.l10n.errorNoInternet,
      UnauthorizedFailure() => context.l10n.errorSessionExpired,
      ServerFailure() => context.l10n.errorGenericServer,
      UnknownFailure() => context.l10n.errorUnknown,
    };
  }
}

```

### B. Controlled Context-Free Access (Logging / Infrastructure)

```dart
/// Use ONLY when BuildContext is unavailable (e.g. system notification service)
abstract final class SystemNotificationMessages {
  static String get backgroundSyncFailed {
    // Falls back to static generated instance after init
    return S.current.errorBackgroundSync;
  }
}

```

---

## 5. Locale-Aware Date & Number Formatting

Always construct `DateFormat` and `NumberFormat` using the active locale.

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FinancialTile extends StatelessWidget {
  final DateTime timestamp;
  final double amount;

  const FinancialTile({
    super.key,
    required this.timestamp,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final String currentLocale = Localizations.localeOf(context).toString();

    final formattedDate = DateFormat.yMMMd(currentLocale).format(timestamp);
    final formattedAmount = NumberFormat.currency(
      locale: currentLocale,
      symbol: '\$',
    ).format(amount);

    return ListTile(
      title: Text(formattedAmount),
      subtitle: Text(formattedDate),
    );
  }
}

```

---

## Anti-Patterns (Strictly Prohibited)

| Anti-Pattern                                          | Severity     | Corrective Action                               |
| ----------------------------------------------------- | ------------ | ----------------------------------------------- |
| Hardcoded strings in `Text()`, `SnackBar`, or dialogs | **CRITICAL** | Extract string to template ARB and run codegen. |

|
| Concatenating translated string variables (`'$a $b'`) | **CRITICAL** | Combine into a single ARB string using ICU placeholders (`"{a} {b}"`).

|
| Importing `BuildContext` or `AppLocalizations`/`S` in `Domain` | **HIGH** | Pass domain enums/failures and resolve them in UI extensions.

|
| Missing `few`/`many` plural categories in Ukrainian/Polish ARBs | **HIGH** | Add proper ICU plural rules for non-English locales.

|
| Using `DateFormat` without passing current `Localizations.localeOf(context)` | **MEDIUM** | Pass current locale to `intl` formatters to support 12/24h and separators.

|

---

## Agent Verification Checklist

When building or auditing localization features:

1. **Zero Hardcoded Copy:** All user-visible strings originate from generated `AppLocalizations` or `S` lookups.

2. **Grammar Integrity:** No string concatenation across variables; placeholders are handled via ICU syntax in ARB.

3. **Architecture Check:** Domain contains zero localization imports; mapping occurs in Presentation layer.

4. **App Integration:** `MaterialApp` wires `localizationsDelegates` and `supportedLocales` correctly.

5. **Formatters Localized:** `DateFormat` and `NumberFormat` explicitly receive current active locale string.
