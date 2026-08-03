---
name: flutter-reactive-forms
description: Enforces strict architecture, strong typing, custom validation, cross-field checks, dynamic FormArrays, and BLoC integration standards for reactive_forms in Flutter. Guarantees zero mixing of TextEditingController with FormControl, clear boundaries between Presentation forms and Domain DTOs, debounced async validation, and optimal UI rebuilds. Use when creating form controls, dynamic inputs, or complex field validation.
---

# Flutter Reactive Forms Expert Skill

## When to Apply

Use this skill whenever building data entry UI, custom selections, dynamic collection fields (`FormArray`), cross-field validation rules, or integrating `reactive_forms` with BLoC state management.

---

## Core Architectural Boundaries & Rules

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

## 1. Strongly Typed Form & Cross-Field Validation Standard

Use typed getters on `FormGroup` extensions and declare cross-field validators at the `FormGroup` level.

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
      // Cross-Field Validator for Password Matching
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

## 2. Async Validation & Debouncing Standard

Async validators MUST have a debounce duration configured on the control to prevent backend spamming, and the UI MUST handle the `pending` validation state.

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

## 3. Dynamic Collections (`FormArray`)

Use `FormArray` for dynamic lists of inputs (e.g., adding multiple phone numbers). Centralize item creation in helper factories.

```dart
abstract class DynamicListForm {
  static const String itemsArray = 'items';

  static FormGroup build() {
    return FormGroup({
      itemsArray: FormArray<String>([]),
    });
  }

  static void addItem(FormGroup form, [String value = '']) {
    final array = form.control(itemsArray) as FormArray<String>;
    array.add(FormControl<String>(value: value, validators: [Validators.required]));
  }

  static void removeItem(FormGroup form, int index) {
    final array = form.control(itemsArray) as FormArray<String>;
    array.removeAt(index);
  }
}

```

---

## 4. UI Binding, Keyboard UX & BLoC Integration

Ensure narrow rebuilds, proper keyboard navigation (`TextInputAction.next`/`done`), and submission guards.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';

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
                // 1. Email Field with Next Action
                ReactiveTextField<String>(
                  formControlName: RegisterForm.emailControl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 16),

                // 2. Password Field with Next Action
                ReactiveTextField<String>(
                  formControlName: RegisterForm.passwordControl,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 16),

                // 3. Confirm Password Field with Done Action
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

                // 4. Submit Button guarded by ReactiveFormConsumer
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
      // Map form values to strongly-typed DTO
      final dto = RegisterRequestDto(
        email: form.emailControl.value!,
        password: form.passwordControl.value!,
      );
      context.read<AuthBloc>().add(AuthEvent.registerRequested(dto));
    } else {
      form.markAllAsTouched(); // Force display errors if submitted directly
    }
  }
}

```

---

## Anti-Patterns (Strictly Prohibited)

| Anti-Pattern                                      | Severity     | Corrective Action                              |
| ------------------------------------------------- | ------------ | ---------------------------------------------- |
| Mixing `TextEditingController` with `FormControl` | **CRITICAL** | Use `FormControl` as the sole source of truth. |

|
| Re-instantiating `FormGroup` inside `build()` | **CRITICAL** | Use `ReactiveFormBuilder` or manage state in controller/State.

|
| Async validators without `asyncValidatorsDebounceTime` | **HIGH** | Set explicit debounce delay to prevent spamming backend APIs.

|
| Sending raw `form.value` map directly to Domain UseCases | **HIGH** | Map form output into a strongly-typed DTO/Model first.

|
| Rebuilding full screen on single field keystroke | **MEDIUM** | Isolate rebuilds with `ReactiveFormConsumer` or `ReactiveValueListenableBuilder`.

|

---

## Agent Verification Checklist

When building or updating forms:

1. **Type Safety:** All controls use explicit generic parameters (`FormControl<T>`).

2. **Architecture Boundary:** `reactive_forms` imports are strictly inside `lib/presentation/`.

3. **Rebuild Scope:** `ReactiveFormConsumer` wraps ONLY widgets depending on dynamic form state (like submit buttons).

4. **Keyboard Actions:** Fields configure `textInputAction: TextInputAction.next` or `.done`.

5. **Debounced Async Rules:** Async validators specify a debounce time and UI accounts for pending status.

6. **Submit Guards:** Submissions check `form.valid` and call `form.markAllAsTouched()` when invalid.
