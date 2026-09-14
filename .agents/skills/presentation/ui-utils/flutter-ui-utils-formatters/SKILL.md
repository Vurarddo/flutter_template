---
name: flutter-ui-utils-formatters
description: Standards and implementation patterns for custom TextInputFormatter classes in lib/presentation/ui_utils/formatters/. Covers phone masking, payment card formatting, currency/number inputs, uppercase transforms, and text replacement filters.
---

# Flutter UI Input Formatters

## 1. Overview & When to Apply

Use this skill whenever:
- Implementing custom `TextInputFormatter` classes for text inputs (`TextField`, `TextFormField`, `ReactiveTextField`).
- Formatting card numbers (e.g. `XXXX XXXX XXXX XXXX`), expiration dates (`MM/YY`), or CVV.
- Masking phone numbers with international prefix rules (e.g. `+380 (XX) XXX-XX-XX`).
- Enforcing currency, decimal places, or thousand separator number formatting.
- Transforming user input on the fly (e.g. uppercase conversion, alphanumeric filtering, whitespace trimming).

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [flutter-ui-utils-hub](../flutter-ui-utils-hub/SKILL.md) | UI Utils architecture and directory boundaries. |
| **Reactive Forms Controls** | [flutter-ui-forms-custom-controls](../../ui/forms/flutter-ui-forms-custom-controls/SKILL.md) | Integrating formatters inside custom reactive inputs. |
| **Unit Testing** | [testing-unit](../../../testing/testing-unit/SKILL.md) | Writing unit tests for deterministic formatter algorithms. |

---

## 3. Directory Standard for Formatters

All custom input formatters must reside in `lib/presentation/ui_utils/formatters/`:

```text
lib/presentation/ui_utils/formatters/
├── card_number_formatter.dart
├── card_expiration_formatter.dart
├── phone_number_formatter.dart
├── currency_input_formatter.dart
└── upper_case_text_formatter.dart
```

---

## 4. Standard Formatter Implementations

### 4.1 Payment Card Number Formatter (4-4-4-4 Grouping)

```dart
import 'package:flutter/services.dart';

class CardNumberFormatter extends TextInputFormatter {
  final int maxDigits;
  final String separator;

  const CardNumberFormatter({
    this.maxDigits = 16,
    this.separator = ' ',
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Strip non-digit characters
    final cleanDigits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limitedDigits = cleanDigits.length > maxDigits
        ? cleanDigits.substring(0, maxDigits)
        : cleanDigits;

    final buffer = StringBuffer();
    for (int i = 0; i < limitedDigits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(separator);
      }
      buffer.write(limitedDigits[i]);
    }

    final formatted = buffer.toString();

    // Preserve and safely clamp selection index
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
```

---

### 4.2 Generic Mask Input Formatter (Phone / Dates)

```dart
import 'package:flutter/services.dart';

class MaskTextInputFormatter extends TextInputFormatter {
  final String mask;
  final String maskPlaceholder;

  MaskTextInputFormatter({
    required this.mask,
    this.maskPlaceholder = '#',
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final rawText = newValue.text.replaceAll(RegExp(r'[^\w\d]'), '');
    final result = StringBuffer();
    int rawIndex = 0;

    for (int i = 0; i < mask.length; i++) {
      if (rawIndex >= rawText.length) break;

      final maskChar = mask[i];
      if (maskChar == maskPlaceholder) {
        result.write(rawText[rawIndex]);
        rawIndex++;
      } else {
        result.write(maskChar);
      }
    }

    final formatted = result.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
```

---

### 4.3 UpperCase Transformation Formatter

```dart
import 'package:flutter/services.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  const UpperCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
```

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Placing formatters inside page or widget files | **HIGH** | Extract into dedicated files inside `lib/presentation/ui_utils/formatters/`. |
| Ignoring cursor/selection bounds causing out-of-range crashes | **CRITICAL** | Always clamp selection offset: `offset.clamp(0, formatted.length)`. |
| Mixing backend API validation logic inside `TextInputFormatter` | **HIGH** | Formatters format text strictly for UI; validation belongs to form validators. |
| Making stateful formatters with side effects | **MEDIUM** | Formatters must be pure functions with deterministic input -> output transformations. |

---

## 6. Verification Checklist

- [ ] Formatter is placed in `lib/presentation/ui_utils/formatters/`.
- [ ] Safe cursor selection offset handling prevents index out-of-bounds errors on backspace or paste.
- [ ] Class is immutable (`const` constructor where possible).
- [ ] Covered with unit tests verifying typing, backspacing, and multi-character paste operations.
