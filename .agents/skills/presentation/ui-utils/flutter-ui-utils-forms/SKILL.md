---
name: flutter-ui-utils-forms
description: Standards for Reactive Forms UI adapters, custom ControlValueAccessor implementations, and form UI utilities in lib/presentation/ui_utils/forms/. Covers bidirectional type conversion between form controls and UI widgets.
---

# Flutter UI Forms & ControlValueAccessors

## 1. Overview & When to Apply

Use this skill whenever:
- Implementing custom `ControlValueAccessor<TModel, TView>` classes to adapt complex data types (e.g. `DateTime`, `Color`, `num`, `List<String>`) for standard or custom UI form widgets.
- Creating UI-level form helpers (e.g. auto-scrolling to first invalid form control, keyboard focus progression).
- Organizing reusable form accessors in `lib/presentation/ui_utils/forms/`.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [flutter-ui-utils-hub](../flutter-ui-utils-hub/SKILL.md) | UI Utils architecture and directory boundaries. |
| **Reactive Forms Core** | [flutter-ui-forms-reactive](../../ui/forms/flutter-ui-forms-reactive/SKILL.md) | FormGroup/FormControl structure and reactive state. |
| **Custom Form Controls** | [flutter-ui-forms-custom-controls](../../ui/forms/flutter-ui-forms-custom-controls/SKILL.md) | Custom `ReactiveFormField` widgets and UI Kit components. |

---

## 3. Directory Standard for Form Utilities

All reusable accessors and form UI helpers reside in `lib/presentation/ui_utils/forms/`:

```text
lib/presentation/ui_utils/forms/
├── date_time_value_accessor.dart
├── double_value_accessor.dart
├── color_hex_value_accessor.dart
├── string_list_chips_accessor.dart
└── form_scroll_to_error_helper.dart
```

---

## 4. Standard `ControlValueAccessor` Implementations

### 4.1 Strict `DateTime` to Formatted String Accessor

```dart
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';

class DateTimeValueAccessor extends ControlValueAccessor<DateTime, String> {
  final DateFormat format;

  DateTimeValueAccessor({DateFormat? format})
      : format = format ?? DateFormat('yyyy-MM-dd');

  @override
  String? modelToViewValue(DateTime? modelValue) {
    if (modelValue == null) return null;
    return format.format(modelValue);
  }

  @override
  DateTime? viewToModelValue(String? viewValue) {
    if (viewValue == null || viewValue.trim().isEmpty) return null;
    try {
      return format.parseStrict(viewValue.trim());
    } catch (_) {
      return null;
    }
  }
}
```

---

### 4.2 Safe `num` / `double` to Formatted String Accessor

```dart
import 'package:reactive_forms/reactive_forms.dart';

class SafeDoubleValueAccessor extends ControlValueAccessor<double, String> {
  final int decimalDigits;

  SafeDoubleValueAccessor({this.decimalDigits = 2});

  @override
  String? modelToViewValue(double? modelValue) {
    if (modelValue == null) return '';
    return modelValue.toStringAsFixed(decimalDigits);
  }

  @override
  double? viewToModelValue(String? viewValue) {
    if (viewValue == null || viewValue.trim().isEmpty) return null;
    final sanitized = viewValue.replaceAll(',', '.').trim();
    return double.tryParse(sanitized);
  }
}
```

---

### 4.3 `Color` to Hex String Accessor

```dart
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ColorHexValueAccessor extends ControlValueAccessor<Color, String> {
  const ColorHexValueAccessor();

  @override
  String? modelToViewValue(Color? modelValue) {
    if (modelValue == null) return null;
    final argbHex = modelValue.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();
    return '#$argbHex';
  }

  @override
  Color? viewToModelValue(String? viewValue) {
    if (viewValue == null || viewValue.trim().isEmpty) return null;
    final hexString = viewValue.replaceFirst('#', '').trim();
    if (hexString.length != 6 && hexString.length != 8) return null;
    final fullHex = hexString.length == 6 ? 'FF$hexString' : hexString;
    final colorInt = int.tryParse(fullHex, radix: 16);
    return colorInt != null ? Color(colorInt) : null;
  }
}
```

---

## 5. UI Form Focus & Scroll Helpers

```dart
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

abstract final class FormFocusHelper {
  /// Focuses the first invalid control in a FormGroup.
  static void focusFirstInvalid(FormGroup form, Map<String, FocusNode> focusNodes) {
    for (final entry in form.controls.entries) {
      if (entry.value.invalid) {
        final node = focusNodes[entry.key];
        if (node != null && node.canRequestFocus) {
          node.requestFocus();
          break;
        }
      }
    }
  }
}
```

---

## 6. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Throwing unhandled format exceptions inside `viewToModelValue` | **CRITICAL** | Catch parsing exceptions safely and return `null`. Let validators flag invalid state. |
| Inlining complex `ControlValueAccessor` logic inside widget build trees | **HIGH** | Extract into standalone classes inside `lib/presentation/ui_utils/forms/`. |
| Modifying the underlying `FormControl` directly inside accessor methods | **HIGH** | `ControlValueAccessor` must only transform `model <-> view` representations. |

---

## 7. Verification Checklist

- [ ] All accessors inherit from `ControlValueAccessor<TModel, TView>`.
- [ ] Safe fallback/null returns on invalid user input string (zero unhandled exceptions).
- [ ] Stored in `lib/presentation/ui_utils/forms/` with clean unit tests.
- [ ] Form focus/scroll helpers do not introduce memory leaks (properly manage `FocusNode`s).
