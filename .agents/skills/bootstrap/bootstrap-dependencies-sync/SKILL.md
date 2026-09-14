---
name: bootstrap-dependencies-sync
description: Injects standard production packages into pubspec.yaml, executes flutter pub get, resolves version locks, and upgrades packages to the latest compatible versions. Use when configuring or synchronizing dependencies for a new or updated Flutter project.
---

# Dependencies Injection & Synchronization

## 1. Overview & When to Apply

Use this skill during the second phase of project bootstrapping:
- Injecting the standard Clean Architecture stack dependencies into `pubspec.yaml`.
- Executing `flutter pub get` and verifying dependency graph validity.
- Performing safe package upgrades using caret syntax and `--tighten`.
- Resolving package conflicts via surgical lockfile repair (integrated with [dart-resolve-package-conflicts](../../dart-resolve-package-conflicts/SKILL.md)).

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [project-bootstrap-hub](../project-bootstrap-hub/SKILL.md) | Master bootstrapping coordinator. |
| **Previous Step** | [bootstrap-flutter-init](../bootstrap-flutter-init/SKILL.md) | Project directory and platform initialization. |
| **Conflict Resolution** | [dart-resolve-package-conflicts](../../dart-resolve-package-conflicts/SKILL.md) | In-depth guide for fixing `pubspec.lock` version locks. |
| **Next Step** | [bootstrap-package-auditor](../bootstrap-package-auditor/SKILL.md) | Auditing package breaking changes and skill signatures. |

---

## 3. Standard Production Dependencies Matrix

Configure `pubspec.yaml` with the standard template dependencies:

```yaml
name: my_app
description: "Production Flutter Application."
publish_to: "none"

version: 1.0.0+1

environment:
  sdk: ^3.12.2

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # UI Tools & Styling
  cupertino_icons: ^1.0.8
  reactive_forms: ^18.2.2
  flutter_svg: ^2.3.0
  blur: ^4.0.2

  # Localization
  intl: ^0.20.2
  intl_utils: ^2.8.14

  # Networking & HTTP
  dio: ^5.11.0
  retrofit: ^4.9.2

  # Code Generation Annotations
  json_annotation: ^4.12.0
  freezed_annotation: ^3.1.0
  copy_with_extension: ^17.0.0

  # State Management & Concurrency
  bloc: ^9.2.0
  flutter_bloc: ^9.1.1
  hydrated_bloc: ^11.0.0
  bloc_concurrency: ^0.3.0
  equatable: ^2.1.0

  # Routing & Navigation
  auto_route: ^11.1.0

  # Dependency Injection
  get_it: ^9.2.1
  injectable: ^3.0.0

  # Persistence & Secure Storage
  shared_preferences: ^2.5.5
  flutter_secure_storage: ^10.3.1
  path_provider: ^2.1.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter

  flutter_lints: ^6.0.0
  import_sorter: ^4.6.0

  # Code Generators
  build_runner: ^2.13.1
  freezed: ^3.2.5
  json_serializable: ^6.13.0
  retrofit_generator: ^10.2.3
  auto_route_generator: ^10.5.0
  injectable_generator: ^3.0.2
  copy_with_extension_gen: ^17.0.0
  flutter_gen_runner: ^5.13.0+1
  flutter_launcher_icons: ^0.14.4

  # Testing Mocks
  mocktail: ^1.0.4
  bloc_test: ^10.0.0

# Assets & SVG Generator configuration (Strictly NO lib/gen)
flutter_gen:
  output: lib/presentation/ui_utils/assets
  integrations:
    flutter_svg: true

# Continuous import sorting configuration
import_sorter:
  comments: false

# Localization configuration
flutter_intl:
  enabled: true
  main_locale: en
  output_dir: lib/l10n/generated
  arb_dir: lib/l10n

flutter:
  uses-material-design: true
  generate: true

  # Assets template (Uncomment and populate as needed)
  # assets:
  #   - assets/images/
  #   - assets/icons/
  #   - assets/svgs/

  # Fonts template (Uncomment and populate as needed)
  # fonts:
  #   - family: "AppFont"
  #     fonts:
  #       - asset: assets/fonts/app_font_regular.ttf
  #         weight: 400
  #       - asset: assets/fonts/app_font_bold.ttf
  #         weight: 700
```

---

## 4. Synchronization & Upgrade Workflow

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Audit for Outdated Packages
Check if dependencies have newer non-breaking minor/patch versions:
```bash
dart pub outdated
```

### Step 3: Upgrade & Tighten Constraints
Upgrade packages to their latest resolvable versions and update lower bounds in `pubspec.yaml`:
```bash
dart pub upgrade --tighten
```

### Step 4: Handle Version Conflicts (If Any Occur)
If `pub get` or `pub upgrade` fails due to conflicting constraints:
1. Consult [dart-resolve-package-conflicts](../../dart-resolve-package-conflicts/SKILL.md).
2. Inspect `pubspec.lock` and remove ONLY the conflicting package block.
3. Rerun `flutter pub get`.

---

## 5. Verification Checklist

- [ ] All standard production dependencies added to `pubspec.yaml`.
- [ ] `flutter pub get` completed with exit code 0.
- [ ] Dependencies audited via `dart pub outdated` and tightened.
- [ ] No unresolved version lock errors in `pubspec.lock`.
- [ ] Ready to proceed to [bootstrap-package-auditor](../bootstrap-package-auditor/SKILL.md).
