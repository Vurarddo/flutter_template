---
name: bootstrap-architecture-scaffold
description: Scaffolds the complete Clean Architecture directory hierarchy, multi-environment Flavors (dev, stage, prod), configuration models, DI container, and core entrypoints (main.dart, application.dart). Use when establishing the architecture backbone for a new Flutter project.
---

# Clean Architecture & Flavors Scaffolding

## 1. Overview & When to Apply

Use this skill to scaffold the architectural backbone of a new Flutter application:
- Generating the Clean Architecture layer folders (`core/`, `domain/`, `data/`, `infrastructure/`, `presentation/`, `l10n/`).
- Setting up multi-environment Flavors (`config/env_dev.json`, `config/env_stage.json`, `config/env_prod.json`, `config/env_template.json`).
- Configuring Android `productFlavors` and iOS Build Configurations / Schemes.
- Authoring production-ready entrypoints: `lib/main.dart` and `lib/application.dart`.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [project-bootstrap-hub](../project-bootstrap-hub/SKILL.md) | Master bootstrapping coordinator. |
| **Architecture Guide** | [flutter-clean-architecture](../../flutter-clean-architecture/SKILL.md) | Layer-First rules, boundaries, and DDD contracts. |
| **Flavors Guide** | [native-flavors-environments](../../native/native-flavors-environments/SKILL.md) | Detailed native Gradle and Xcode flavor settings. |
| **Next Step** | [bootstrap-theme-uikit](../bootstrap-theme-uikit/SKILL.md) | Generating M3 theme and UiKit showcase page. |

---

## 3. Directory Hierarchy Scaffolding

Scaffold the standard directory structure:

```text
lib/
├── core/
│   ├── constants/
│   ├── extensions/
│   └── utils/
├── domain/
├── data/
├── infrastructure/
│   ├── config/
│   ├── di/
│   ├── network/
│   ├── storage/
│   ├── services/
│   └── logging/
├── l10n/
│   ├── intl_en.arb
│   └── intl_uk.arb
└── presentation/
    ├── navigation/
    ├── state-management/
    ├── theme/
    ├── ui/
    │   └── ui-kit/
    └── ui-utils/
        ├── extensions/
        ├── formatters/
        ├── forms/
        └── helpers/
```

---

## 4. Multi-Environment Flavors & Native Configuration (`config/`)

### 4.1 Create Environment JSON Files (Added to `.gitignore`):

#### `config/env_dev.json`
```json
{
  "APP_ENV": "dev",
  "BASE_URL": "https://api-dev.example.com",
  "APP_NAME": "App Dev"
}
```

#### `config/env_stage.json`
```json
{
  "APP_ENV": "stage",
  "BASE_URL": "https://api-stage.example.com",
  "APP_NAME": "App Stage"
}
```

#### `config/env_prod.json`
```json
{
  "APP_ENV": "prod",
  "BASE_URL": "https://api.example.com",
  "APP_NAME": "App"
}
```

#### `config/env_template.json` (Committed to Git)
```json
{
  "APP_ENV": "dev",
  "BASE_URL": "https://api-dev.example.com",
  "APP_NAME": "App Dev"
}
```

---

### 4.2 Native Platform Flavors Summary
Reference guides:
- [Android Flavors](https://docs.flutter.dev/deployment/flavors)
- [iOS Flavors](https://docs.flutter.dev/deployment/flavors-ios)
- [Linux Flavors](https://docs.flutter.dev/deployment/flavors-linux)
- [Windows Flavors](https://docs.flutter.dev/deployment/flavors-windows)
- For comprehensive multi-platform native configurations, consult [native-flavors-environments](../../native/native-flavors-environments/SKILL.md).

---

## 5. VS Code Configuration (`.vscode/`)

Place the standard multi-flavor launch configurations and IDE settings:

- **Launch Configurations:** Reference template: [resources/launch.json](resources/launch.json).
- **Workspace Settings (`.vscode/settings.json`):**
  ```json
  {
      "java.configuration.updateBuildConfiguration": "disabled",
      "[dart]": {
          "editor.formatOnSave": true,
          "editor.formatOnType": true,
          "editor.defaultFormatter": "Dart-Code.dart-code"
      }
  }
  ```
- **Recommended Extensions (`.vscode/extensions.json`):** Include `Dart-Code.dart-code`, `Dart-Code.flutter`, `localizely.flutter-intl`, `felangel.bloc`.

---

## 6. Quality & Linter Configuration (`analysis_options.yaml`)

Scaffold root `analysis_options.yaml` with strict BLoC rules and code generation exclusions.
- Full configuration file: [resources/analysis_options.yaml](resources/analysis_options.yaml).

---

## 7. Core Architecture Boilerplates & Entrypoints

Refer to production-ready boilerplate implementations in `examples/`:

1. **Centralized Configuration Model:** [examples/app_config.dart](examples/app_config.dart)
   - Strongly typed `AppEnvironment` (`dev`, `stage`, `prod`) using `String.fromEnvironment`.
2. **Main Bootstrap Entrypoint:** [examples/main.dart](examples/main.dart)
   - Wrapped in `runZonedGuarded` with `HydratedBloc.storage` and `configureDependencies()` initialization.
3. **Application Root Widget:** [examples/application.dart](examples/application.dart)
   - `MaterialApp.router` bound to `AppRouter`, `ThemeCubit` (with `AppThemeModeX`), and localization delegates.

---

## 8. Assets Hierarchy Scaffolding

Scaffold empty asset folders with `.gitkeep` files:
- `assets/fonts/.gitkeep`
- `assets/images/.gitkeep`
- `assets/icons/.gitkeep`
- `assets/svgs/.gitkeep`

---

## 9. Verification Checklist

- [ ] Clean Architecture layer folders created.
- [ ] `config/env_*.json` files generated and added to `.gitignore`.
- [ ] Native platform Flavors configured across Android, iOS, Linux, Windows, macOS.
- [ ] `.vscode/launch.json` created from [resources/launch.json](resources/launch.json).
- [ ] `analysis_options.yaml` created from [resources/analysis_options.yaml](resources/analysis_options.yaml).
- [ ] `lib/infrastructure/config/app_config.dart` authored based on [examples/app_config.dart](examples/app_config.dart).
- [ ] `lib/main.dart` authored based on [examples/main.dart](examples/main.dart).
- [ ] `lib/application.dart` authored based on [examples/application.dart](examples/application.dart).
- [ ] Asset folders initialized with `.gitkeep`.
- [ ] Ready to proceed to [bootstrap-theme-uikit](../bootstrap-theme-uikit/SKILL.md).
