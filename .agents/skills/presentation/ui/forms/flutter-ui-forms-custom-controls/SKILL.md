---
name: flutter-ui-forms-custom-controls
description: Standards and patterns for creating custom reactive form components using ControlValueAccessor, ReactiveFormField, custom chip selectors, date pickers, range sliders, and stylized validation messages in Flutter. Use when building custom UI Kit inputs or binding non-standard widgets to reactive_forms.
---

# Flutter Custom Reactive Form Controls & Accessors

## 1. Overview & When to Apply

Use this skill whenever:
- Binding custom UI Kit widgets (e.g., choice chips, segmented controls, rating stars, custom toggle switches) to `reactive_forms`.
- Implementing the `ControlValueAccessor<TModel, TView>` interface to convert model data types to view representations.
- Creating reusable `ReactiveFormField<T, V>` wrapper widgets.
- Building custom validation feedback, animated error labels, and field focus indicators.
- Formatting input masks for phone numbers, currency, or credit cards inside reactive fields.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Reactive Forms Core** | [flutter-ui-forms-reactive](../flutter-ui-forms-reactive/SKILL.md) | FormGroup/FormControl models & validation rules. |
| **UI Forms & Accessors** | [flutter-ui-utils-forms](../../../ui-utils/flutter-ui-utils-forms/SKILL.md) | Centralized `ControlValueAccessor` implementations in `lib/presentation/ui_utils/forms/`. |
| **Input Formatters** | [flutter-ui-utils-formatters](../../../ui-utils/flutter-ui-utils-formatters/SKILL.md) | `TextInputFormatter` classes for phone/card/currency formatting. |
| **UI Kit Components** | [flutter-ui-kit-components](../../ui-kit/flutter-ui-kit-components/SKILL.md) | Base visual widgets and badges. |
| **Theming System** | [flutter-ui-theme-hub](../../../theme/flutter-ui-theme-hub/SKILL.md) | Error colors and input decoration styles. |

---

## 3. Creating Custom Reactive Controls via `ReactiveFormField`

### 3.1 Custom Reactive Segmented Choice Chips Example
```dart
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:flutter_template/presentation/ui_utils/extensions/context_extensions.dart';

class ReactiveChoiceChips<T> extends ReactiveFormField<T, T> {
  ReactiveChoiceChips({
    super.key,
    super.formControlName,
    super.formControl,
    required List<T> options,
    required String Function(T) labelBuilder,
    super.validationMessages,
    super.showErrors,
  }) : super(
          builder: (ReactiveFormFieldState<T, T> field) {
            final colorScheme = field.context.colorScheme;
            final textTheme = field.context.textTheme;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: options.map((option) {
                    final isSelected = field.value == option;
                    return ChoiceChip(
                      label: Text(labelBuilder(option)),
                      selected: isSelected,
                      onSelected: field.control.enabled
                          ? (selected) {
                              field.didChange(selected ? option : null);
                            }
                          : null,
                    );
                  }).toList(),
                ),
                if (field.errorText != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    field.errorText!,
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
                  ),
                ],
              ],
            );
          },
        );
}
```

---

## 4. Converting Complex Values via `ControlValueAccessor`

When the model value differs in type or shape from what the UI widget requires, use a `ControlValueAccessor`:

### 4.1 DateTime to Formatted String Accessor
```dart
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';

class DateTimeValueAccessor extends ControlValueAccessor<DateTime, String> {
  final DateFormat format;

  DateTimeValueAccessor({DateFormat? format})
      : format = format ?? DateFormat('yyyy-MM-dd');

  @override
  String? modelToViewValue(DateTime? modelValue) {
    return modelValue == null ? null : format.format(modelValue);
  }

  @override
  DateTime? viewToModelValue(String? viewValue) {
    if (viewValue == null || viewValue.trim().isEmpty) return null;
    try {
      return format.parseStrict(viewValue);
    } catch (_) {
      return null;
    }
  }
}

// Usage in ReactiveTextField:
ReactiveTextField<DateTime>(
  formControlName: 'birthDate',
  valueAccessor: DateTimeValueAccessor(),
  decoration: const InputDecoration(labelText: 'Birth Date (YYYY-MM-DD)'),
)
```

---

## 5. Custom Validation Error Messages Standard

Centralize error message formatters matching project localization:

```dart
Map<String, ValidationMessageFunction> customValidationMessages = {
  ValidationMessage.required: (error) => 'This field is required',
  ValidationMessage.email: (error) => 'Please enter a valid email address',
  ValidationMessage.minLength: (error) =>
      'Must be at least ${(error as Map)['requiredLength']} characters',
  'usernameTaken': (error) => 'This username is already registered',
};
```

---

## 6. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Directly mutating `field.control.value` bypassing `field.didChange` | **HIGH** | Always call `field.didChange(value)` to trigger form validation. |
| Hardcoding error text colors instead of `colorScheme.error` | **HIGH** | Use `context.colorScheme.error`. |
| Omitting disabled state handling when `field.control.enabled` is false | **MEDIUM** | Disable chip/button interactions when the form control is disabled. |

---

## 7. Custom Controls Verification Checklist

- [ ] Custom widget extends `ReactiveFormField<TModel, TView>`.
- [ ] UI changes call `field.didChange(...)` properly.
- [ ] Disabled states (`field.control.enabled == false`) are visually reflected and non-interactive.
- [ ] Validation errors are displayed using `field.errorText` and `colorScheme.error`.
- [ ] `ControlValueAccessor` is used for type transformations (e.g. String <-> DateTime / num).
