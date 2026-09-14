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
                ),
                const SizedBox(height: 24),
                ReactiveFormConsumer(
                  builder: (context, form, child) {
                    return FilledButton(
                      onPressed: form.valid
                          ? () {
                              final email = form.emailControl.value;
                              final password = form.passwordControl.value;
                              debugPrint('Submit: $email, $password');
                            }
                          : null,
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
}
