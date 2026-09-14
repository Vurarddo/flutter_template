---
name: flutter-ui-forms-reactive
description: Enforces strict architecture, strong typing, custom validation, cross-field checks, dynamic FormArrays, and BLoC integration standards for reactive_forms in Flutter. Guarantees zero mixing of TextEditingController with FormControl, clear boundaries between Presentation forms and Domain DTOs, debounced async validation, and optimal UI rebuilds. Use when creating form controls, dynamic inputs, or complex field validation.
---

# Flutter Reactive Forms Core Architecture Guide

## 1. Overview & When to Apply

Use this skill whenever:
- Building data entry UI, registration forms, search filters, or multi-step form workflows.
- Creating strongly typed `FormGroup`, `FormControl<T>`, and dynamic `FormArray<T>` models.
- Implementing cross-field validation rules (e.g., password matching, start/end date range).
- Handling debounced asynchronous field validation with backend checks.
- Integrating `reactive_forms` with BLoC state management and mapping form state into DTOs.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Custom Controls** | [flutter-ui-forms-custom-controls](../flutter-ui-forms-custom-controls/SKILL.md) | Binding custom UI Kit widgets with `reactive_forms`. |
| **Parent UI Hub** | [flutter-ui-hub](../../flutter-ui-hub/SKILL.md) | Global presentation layer architecture. |
| **UI Kit Components** | [flutter-ui-kit-components](../../ui_kit/flutter-ui-kit-components/SKILL.md) | Base styled input components. |
| **BLoC UI Widgets** | [flutter-bloc-widgets](../../../state_management/flutter-bloc-widgets/SKILL.md) | Dispatching form events (`context.read<Bloc>().add`) and handling submit states. |

---

## 3. Core Architectural Boundaries & Rules

1. **Clean Architecture Boundary (Strict Separation):**
   - **PROHIBITED:** Importing `reactive_forms` inside `Domain` or `Data` layers.
   - `FormGroup`, `FormControl`, and `FormArray` belong EXCLUSIVELY to `Presentation`.
   - Forms map to/from strongly-typed DTOs before communicating with BLoCs or UseCases.
2. **Single Source of Truth:**
   - **STRICTLY PROHIBITED:** Mixing `TextEditingController` state and `FormControl` state.
   - NEVER instantiate a new `FormGroup` directly inside a `build()` method. Store it in state, view controller, or manage it via `ReactiveFormBuilder`.
3. **Strong Typing Mandatory:**
   - Always specify explicit generic types (e.g. `FormControl<String>`, `FormControl<int>`, `FormArray<FormGroup>`). Avoid untyped `FormControl<dynamic>`.

---

## 4. Strongly Typed Form & Cross-Field Validation Standard

```dart
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

abstract class RegisterForm {
  static const String emailControl = 'email';
  static const String passwordControl = 'password';
  static const String confirmPasswordControl = 'confirmPassword';

  static FormGroup build() {
    return FormGroup(
      {
        emailControl: FormControl<String>(
          validators: [Validators.required, Validators.email],
        ),
        passwordControl: FormControl<String>(
          validators: [Validators.required, Validators.minLength(8)],
        ),
        confirmPasswordControl: FormControl<String>(
          validators: [Validators.required],
        ),
      },
      validators: [Validators.mustMatch(passwordControl, confirmPasswordControl)],
    );
  }
}

extension RegisterFormX on FormGroup {
  FormControl<String> get emailControl =>
      control(RegisterForm.emailControl) as FormControl<String>;

  FormControl<String> get passwordControl =>
      control(RegisterForm.passwordControl) as FormControl<String>;

  FormControl<String> get confirmPasswordControl =>
      control(RegisterForm.confirmPasswordControl) as FormControl<String>;
}
```

---

## 5. Async Validation & Debouncing Standard

Async validators MUST have a debounce duration configured on the control to prevent backend spamming:

```dart
class UsernameAsyncValidator extends AsyncValidator<String> {
  final CheckUsernameUseCase _useCase;

  UsernameAsyncValidator(this._useCase);

  @override
  Future<Map<String, dynamic>?> validate(AbstractControl<String> control) async {
    final username = control.value;
    if (username == null || username.isEmpty) return null;

    final isAvailable = await _useCase(username);
    return isAvailable ? null : {'usernameTaken': true};
  }
}

// Control definition with Debounce
final usernameControl = FormControl<String>(
  asyncValidators: [UsernameAsyncValidator(getIt())],
  asyncValidatorsDebounceTime: 500, // 500ms debounce
);
```

---

## 6. UI Binding, Keyboard UX & BLoC Integration

```dart
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: ReactiveFormBuilder(
        form: () => RegisterForm.build(),
        builder: (context, form, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ReactiveTextField<String>(
                  formControlName: RegisterForm.emailControl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 16),
                ReactiveTextField<String>(
                  formControlName: RegisterForm.passwordControl,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 16),
                ReactiveTextField<String>(
                  formControlName: RegisterForm.confirmPasswordControl,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(labelText: 'Confirm Password'),
                  validationMessages: {
                    ValidationMessage.mustMatch: (error) => 'Passwords do not match',
                  },
                ),
                const SizedBox(height: 24),
                ReactiveFormConsumer(
                  builder: (context, form, child) {
                    return ElevatedButton(
                      onPressed: form.valid ? () => _onSubmit(context, form) : null,
                      child: const Text('Submit'),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onSubmit(BuildContext context, FormGroup form) {
    if (form.valid) {
      final dto = RegisterRequestDto(
        email: form.emailControl.value!,
        password: form.passwordControl.value!,
      );
      context.read<AuthBloc>().add(AuthEvent.registerRequested(dto));
    } else {
      form.markAllAsTouched();
    }
  }
}
```

---

## 7. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Mixing `TextEditingController` with `FormControl` | **CRITICAL** | Use `FormControl` as the sole source of truth. |
| Re-instantiating `FormGroup` inside `build()` | **CRITICAL** | Use `ReactiveFormBuilder` or manage state in controller/State. |
| Async validators without `asyncValidatorsDebounceTime` | **HIGH** | Set explicit debounce delay to prevent spamming backend APIs. |
| Sending raw `form.value` map directly to Domain UseCases | **HIGH** | Map form output into a strongly-typed DTO/Model first. |
| Rebuilding full screen on single field keystroke | **MEDIUM** | Isolate rebuilds with `ReactiveFormConsumer` or `ReactiveValueListenableBuilder`. |

---

## 8. Verification Checklist

- [ ] All controls use explicit generic parameters (`FormControl<T>`).
- [ ] `reactive_forms` imports are strictly inside `lib/presentation/`.
- [ ] `ReactiveFormConsumer` wraps ONLY widgets depending on dynamic form state (like submit buttons).
- [ ] Fields configure `textInputAction: TextInputAction.next` or `.done`.
- [ ] Async validators specify a debounce time and UI accounts for pending status.
- [ ] Submissions check `form.valid` and call `form.markAllAsTouched()` when invalid.
