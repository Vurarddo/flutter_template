---
name: l10n-generation-workflow
description: Code generation toolchain and CLI workflows for localization files in lib/l10n/generated/. Covers flutter_intl, intl_utils commands, build_runner integration, analysis_options exclusions, and CI/CD validation.
---

# Localization Code Generation Workflow

## 1. Overview & When to Apply

Use this skill whenever:
- Regenerating Dart localization classes (`S`, `AppLocalizations`) after adding or editing `.arb` files.
- Setting up or troubleshooting `intl_utils` / `flutter_intl` code generation in CLI or CI/CD pipelines.
- Verifying that generated files in `lib/l10n/generated/` are up-to-date and pass static analysis.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [l10n-hub](../l10n-hub/SKILL.md) | Localization architecture and Clean Architecture rules. |
| **ARB & ICU Syntax** | [l10n-arb-icu](../l10n-arb-icu/SKILL.md) | Syntax and rules for editing `.arb` files. |
| **Build Runner Hub** | [flutter-build-runner](../../flutter-build-runner/SKILL.md) | Code generation across the entire Flutter project. |

---

## 3. Code Generation Commands

### Standard CLI Generation Command
To regenerate localization classes from ARB files:

```bash
flutter pub run intl_utils:generate
```

### Full Project Code Generation Pipeline
When updating both localization, models (`freezed`), DTOs (`json_serializable`), and DI (`injectable`):

```bash
# 1. Generate localization classes
flutter pub run intl_utils:generate

# 2. Run build_runner for Freezed, Injectable, Retrofit
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 4. Generated Artifacts Architecture

The `intl_utils` generator produces the following files in `lib/l10n/generated/`:

```text
lib/l10n/generated/
├── l10n.dart                # Main S class: S.delegate, S.of(context), S.current
└── intl/
    ├── messages_all.dart    # Delegate message catalog initializer
    ├── messages_en.dart    # English message lookup table
    └── messages_uk.dart    # Ukrainian message lookup table
```

> [!WARNING]
> NEVER manually edit any file in `lib/l10n/generated/`. Any manual changes will be silently overwritten on the next code generation run.

---

## 5. Linter & Static Analysis Configuration

In `analysis_options.yaml`, generated localization files must be excluded from strict lint rules to prevent false positives:

```yaml
analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.gr.dart"
    - "lib/l10n/generated/**"
```

---

## 6. CI/CD Pipeline Verification

To ensure that pull requests do not contain uncommitted or stale localization files, run this check in CI:

```bash
# 1. Run localization generator
flutter pub run intl_utils:generate

# 2. Check for git diff
git diff --exit-code lib/l10n/generated/
```

If `git diff` exits with a non-zero code, it indicates that an ARB file was changed without committing the corresponding generated files.

---

## 7. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Committing ARB changes without regenerating `lib/l10n/generated/` | **CRITICAL** | Always run `flutter pub run intl_utils:generate` after editing ARB files. |
| Manually writing methods inside `lib/l10n/generated/l10n.dart` | **CRITICAL** | Define keys in `intl_en.arb` and let `intl_utils` generate the method. |
| Forgetting to run `flutter pub get` before running `intl_utils` | **MEDIUM** | Ensure all dependencies in `pubspec.yaml` are resolved first. |

---

## 8. Verification Checklist

- [ ] Command `flutter pub run intl_utils:generate` completes with exit code 0.
- [ ] File `lib/l10n/generated/l10n.dart` reflects all newly added ARB keys.
- [ ] `git status` shows no uncommitted discrepancies in generated files.
- [ ] `dart analyze` passes with zero warnings.
