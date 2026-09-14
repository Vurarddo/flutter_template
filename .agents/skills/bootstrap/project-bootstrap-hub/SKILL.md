---
name: project-bootstrap-hub
description: Primary coordinator and master orchestrator for scaffolding and bootstrapping a brand new production Flutter project from scratch. Coordinates Flutter initialization, dependency injection & conflict resolution, package compatibility auditing, Clean Architecture & Flavors scaffolding, initial domain/data example feature, .gitignore protection, Material 3 (#FFDE3F) theme & interactive UiKit showcase generation, Hydrated ThemeCubit, and test verification with runbook documentation.
---

# Project Bootstrap & Scaffolding Coordinator

## 1. Overview & Two-Phase Lifecycle

This skill coordinates the end-to-end initialization and scaffolding of a brand new, production-ready Flutter application adhering strictly to Clean Architecture, Material 3, multi-environment Flavors, and full testability.

To prevent misconfigurations and ensure 100% alignment, the bootstrapping process operates in **two strict phases**:

```mermaid
graph TD
    subgraph "Phase 1: Mandatory Interactive Grill-Me Interview & Planning"
        Q1["1. SDK Upgrade & Version Check"] --> Q2["2. Project Name & Org Identifier"]
        Q2 --> Q3["3. Project Purpose & Domain Description"]
        Q3 --> Q4["4. Target Platforms"]
        Q4 --> Q5["5. Domain & Data Layers Selection"]
        Q5 --> Q6["6. Theme Brand Color (#FFDE3F / Custom)"]
        Q6 --> Q7["7. Flavors & Environment Endpoints"]
        Q7 --> Q8["8. Additional Wishes & Custom Requirements"]
        Q8 --> Plan["9. Generate Detailed implementation_plan.md<br/>(Request User Approval)"]
    end

    subgraph "Phase 2: Approved Autonomous Execution"
        Plan -->|User Approves| Exec1["1. flutter create<br/>(bootstrap-flutter-init)"]
        Exec1 --> Exec2["2. Dependencies & Conflicts<br/>(bootstrap-dependencies-sync)"]
        Exec2 --> Exec3["3. Package & Signature Audit<br/>(bootstrap-package-auditor)"]
        Exec3 --> Exec4["4. Clean Architecture, Flavors & Initial Feature<br/>(bootstrap-architecture-scaffold)"]
        Exec4 --> Exec5["5. M3 Theme & UiKit Showcase<br/>(bootstrap-theme-uikit)"]
        Exec5 --> Exec6["6. Verification & Runbook Docs<br/>(bootstrap-verification-docs)"]
    end
```

---

## 2. Phase 1: Mandatory Interactive Discovery Interview (`grill-me` Protocol)

When the user asks to create/bootstrap a new project (e.g. *"створи новий проект"*, *"bootstrap new flutter app"*, *"ініціалізуй проект з шаблону"*, *"виконай bootstrap"*):

> [!CRITICAL]
> **MANDATORY INTERVIEW RULE:**
> The agent **MUST NOT** immediately run modifying commands or jump into scaffolding. The agent **MUST UNCONDITIONALLY** invoke the `ask_question` tool presenting **ALL 8 DISCOVERY QUESTIONS** to the user in a single interactive prompt. Do NOT skip or omit any question.

### The 8 Mandatory Discovery Questions:

1. **Flutter SDK Upgrade:**
   - *Question:* "Чи бажаєте оновити Flutter SDK до останньої стабільної версії (`flutter channel stable && flutter upgrade`)?"
   - *Options:*
     - "Так, оновити Flutter SDK до latest stable"
     - "Ні, продовжити з поточною встановленою версією SDK"
2. **Project Name & Organization:**
   - *Question:* "Вкажіть назву проєкту (snake_case) та Organization reverse-domain identifier (`--org`):"
   - *Options:*
     - "my_app (org: com.example)"
     - "Вказати власну назву та org"
3. **Project Purpose & Domain Description:**
   - *Question:* "Опишіть призначення проєкту (про що проєкт, який основний функціонал / домен?):"
   - *Options:*
     - "Універсальний стартовий шаблон (Production Flutter Template)"
     - "Вказати опис проєкту (наприклад: інтернет-магазин, фінансовий трекер, соцмережа тощо)"
4. **Target Deployment Platforms:**
   - *Question:* "Оберіть цільові платформи для розгортання проєкту (multi-select):"
   - *IsMultiSelect:* `true`
   - *Options:*
     - "Android та iOS (Mobile Only)"
     - "Web (Браузер)"
     - "macOS, Windows, Linux (Desktop)"
     - "Усі платформи (Android, iOS, Web, macOS, Windows, Linux)"
5. **Domain & Data Layers Selection:**
   - *Question:* "Чи створювати початкові шари Domain та Data з робочим прикладом Clean Architecture фічі?"
   - *Options:*
     - "Так, створити повну Clean Architecture структуру (Domain + Data + Presentation) з прикладом сутності, UseCase, DTO, Retrofit клієнта та репозиторію"
     - "Ні, створити тільки легкий каркас (Presentation + Core/Infrastructure)"
6. **Primary Brand Theme Color:**
   - *Question:* "Оберіть основний колір бренду / теми Material 3:"
   - *Options:*
     - "Стандартний #FFDE3F (Warm Gold / Vibrant Yellow) з темною та світлою темами"
     - "Вказати власний primary seed HEX-колір"
7. **Flavors & API Endpoints:**
   - *Question:* "Підтвердіть конфігурацію Multi-Environment Flavors (dev, stage, prod):"
   - *Options:*
     - "Стандартні 3 оточення (dev, stage, prod) з шаблонами config/env_*.json"
     - "Вказати власні базові URL-адреси для API"
8. **Additional Wishes & Custom Requirements:**
   - *Question:* "Чи є у вас додаткові побажання перед початком генерації (додаткові пакети, Firebase/Supabase, специфічні налаштування)?:"
   - *Options:*
     - "Немає додаткових побажань, генерувати за стандартом"
     - "Вказати додаткові побажання / пакети"

---

### Concrete `ask_question` Tool Invocation Pattern

```json
{
  "questions": [
    {
      "question": "Чи бажаєте оновити Flutter SDK до останньої стабільної версії?",
      "options": [
        "Так, оновити Flutter SDK до latest stable",
        "Ні, продовжити з поточною встановленою версією SDK"
      ]
    },
    {
      "question": "Вкажіть назву проєкту (snake_case) та Organization reverse-domain identifier (--org):",
      "options": [
        "my_app (org: com.example)",
        "Вказати власну назву та org"
      ]
    },
    {
      "question": "Опишіть призначення проєкту (про що проєкт, який основний функціонал / домен?):",
      "options": [
        "Універсальний стартовий шаблон (Production Flutter Template)",
        "Вказати опис проєкту (наприклад: інтернет-магазин, фінансовий трекер, соцмережа тощо)"
      ]
    },
    {
      "question": "Оберіть цільові платформи для розгортання проєкту:",
      "is_multi_select": true,
      "options": [
        "Android та iOS (Mobile Only)",
        "Web (Браузер)",
        "macOS, Windows, Linux (Desktop)",
        "Усі платформи (Android, iOS, Web, macOS, Windows, Linux)"
      ]
    },
    {
      "question": "Чи створювати початкові шари Domain та Data з робочим прикладом Clean Architecture фічі?",
      "options": [
        "Так, створити повну Clean Architecture структуру (Domain + Data + Presentation) з прикладом сутності, UseCase, DTO, Retrofit клієнта та репозиторію",
        "Ні, створити тільки легкий каркас (Presentation + Core/Infrastructure)"
      ]
    },
    {
      "question": "Оберіть основний колір бренду / теми Material 3:",
      "options": [
        "Стандартний #FFDE3F (Warm Gold / Vibrant Yellow) з темною та світлою темами",
        "Вказати власний primary seed HEX-колір"
      ]
    },
    {
      "question": "Підтвердіть конфігурацію Multi-Environment Flavors (dev, stage, prod):",
      "options": [
        "Стандартні 3 оточення (dev, stage, prod) з шаблонами config/env_*.json",
        "Вказати власні базові URL-адреси для API"
      ]
    },
    {
      "question": "Чи є у вас додаткові побажання перед початком генерації (додаткові пакети, Firebase/Supabase, специфічні налаштування)?:",
      "options": [
        "Немає додаткових побажань, генерувати за стандартом",
        "Вказати додаткові побажання / пакети"
      ]
    }
  ],
  "toolSummary": "Bootstrap discovery interview",
  "toolAction": "Conducting project discovery interview"
}
```

---

### Bootstrap Manifest & Implementation Plan Generation
Once all 8 questions are answered, the agent compiles a comprehensive `implementation_plan.md` artifact containing:
- Selected project metadata, domain purpose, and exact CLI command to be executed.
- Dependencies list with version locks (including any user-requested extra packages).
- Layer directory map reflecting the chosen architecture configuration (with explicit `lib/presentation/pages/`, `lib/presentation/state_management/`, `lib/presentation/ui_kit/`, `lib/presentation/ui_utils/`).
- Initial domain/data feature plan (if enabled, tailored to project domain purpose).
- Complete `.gitignore` template protecting secret environment credentials and ignoring generated code.
- ColorScheme tokens and `UiKitPage` showcase outline.
- Test and verification plan.

> [!IMPORTANT]
> The agent sets `RequestFeedback: true` on the artifact and **STOPS to wait for explicit user approval** before executing Phase 2.

---

## 3. Phase 2: Execution Sub-Skill Tree & Routing Matrix

Once the user approves the plan, execute the following sub-skills sequentially:

| Step | Target Skill | Purpose & Output |
| :--- | :--- | :--- |
| **1. Flutter Initialization** | [bootstrap-flutter-init](../bootstrap-flutter-init/SKILL.md) | Executing `flutter create` with approved org, name, description, and platforms. |
| **2. Dependencies & Conflicts** | [bootstrap-dependencies-sync](../bootstrap-dependencies-sync/SKILL.md) | Injecting `pubspec.yaml` packages (plus extra requested packages), running `flutter pub get`, upgrading & tightening constraints. |
| **3. Package Compatibility Audit** | [bootstrap-package-auditor](../bootstrap-package-auditor/SKILL.md) | Running `dart analyze`, applying `dart fix --apply`, checking breaking changes. |
| **4. Architecture, Flavors & Initial Feature** | [bootstrap-architecture-scaffold](../bootstrap-architecture-scaffold/SKILL.md) | Scaffolding layer folders, native flavors, `.gitignore`, initial feature (if chosen in Phase 1), `.vscode/` configs, `config/env_*.json`, `AppConfig`, `main.dart`, and `application.dart`. |
| **5. Theme & UiKit Showcase** | [bootstrap-theme-uikit](../bootstrap-theme-uikit/SKILL.md) | Generating M3 theme `#FFDE3F` (or custom seed), pure Dart `AppThemeMode` with `AppThemeModeX`, injectable `HydratedThemeCubit`, and adaptive `UiKitPage` (`lib/presentation/pages/uikit/`). |
| **6. Verification & Runbooks** | [bootstrap-verification-docs](../bootstrap-verification-docs/SKILL.md) | Running `build_runner`, `import_sorter`, unit/widget tests, `uikit_page` integration test, and generating `README.md` & `RUNBOOK.md`. |

---

## 4. Global Bootstrapping Laws

1. **Mandatory 8-Question Discovery:** The agent MUST strictly present all 8 discovery questions via `ask_question` and incorporate all user responses into `implementation_plan.md`.
2. **Initial Domain & Data Feature:** When Domain & Data layers are requested, scaffold a clean initial sample feature (`domain/<feature>/` and `data/<feature>/`) tailored to the project purpose (or generic `example/`) with an Entity (`@freezed`), Failure hierarchy, Repository contract, UseCase (`@injectable`), DTO (`@JsonSerializable` + `toDomain()`), Retrofit client, and Repository Implementation (`@LazySingleton`).
3. **Strict Clean Architecture:** Domain contains pure Dart only. Data maps DTOs to Entities. BLoC/Cubit communicates exclusively with Use Cases.
4. **Strict Presentation Paths:** Pages and screens MUST reside in `lib/presentation/pages/<feature>/` (never `lib/presentation/ui/<feature>/`). State management in `lib/presentation/state_management/`, UI Kit in `lib/presentation/ui_kit/`, UI utilities in `lib/presentation/ui_utils/`.
5. **Complete `.gitignore` Scaffolding:** Root `.gitignore` MUST protect all `config/env_*.json` credentials and ignore all generated files (`*.g.dart`, `*.freezed.dart`, `*.config.dart`, `lib/l10n/generated/`, `lib/presentation/ui_utils/assets/`) and local agent overrides.
6. **Zero Flutter Imports in State Management:** BLoCs/Cubits must NEVER import `flutter/material.dart` (`avoid_flutter_imports`). State enums map to Flutter types via `AppThemeModeX.toFlutter()` in Presentation.
7. **Flavors First-Class & Multi-Platform:** Every project must support distinct environments (`dev`, `stage`, `prod`) driven by `config/env_*.json` and `--dart-define-from-file`, with native flavor settings across Android, iOS, Windows, Linux, and macOS.
8. **Continuous Import Sorting:** `import_sorter` must be configured (`comments: false`) and executed across all files.
9. **Theme Resilience:** Theme primary seed color must be dynamically applied with Light & Dark ColorSchemes, TextTheme, and `AppCustomColors` ThemeExtension.
10. **Asset Structure Hygiene:** Assets must reside in `assets/` subfolders (`fonts/`, `images/`, `icons/`, `svgs/`) with `flutter_gen` output strictly set to `lib/presentation/ui_utils/assets` (never `lib/gen`).
11. **Automated Integration Testing:** Bootstrapping must generate and verify an end-to-end integration test (`integration_test/uikit_page_test.dart`) exercising the `UiKitPage`.

---

## 5. Master Bootstrapping Checklist

- [ ] Interactive Grill-Me interview conducted with user (all 8 discovery questions presented via `ask_question`).
- [ ] `implementation_plan.md` created with project purpose, selected layers, and custom requirements, and approved by user.
- [ ] Flutter SDK upgraded to latest stable (if requested).
- [ ] `flutter create` executed with explicit `--org`, `--project-name`, `--description`, and `--platforms`.
- [ ] Dependencies injected and synchronized in `pubspec.yaml` (including requested custom packages, `import_sorter` and `flutter_gen`).
- [ ] Root `.gitignore` scaffolded from [resources/.gitignore](../bootstrap-architecture-scaffold/resources/.gitignore).
- [ ] Asset folders initialized (`assets/images/`, `fonts/`, `icons/`, `svgs/`).
- [ ] Clean Architecture directory structure created with all layer hubs.
- [ ] Initial domain/data feature scaffolded (if requested in Phase 1).
- [ ] Flavors configured natively for Android, iOS, Windows, Linux, macOS, and Dart (`AppConfig`).
- [ ] `.vscode/launch.json` created with flavor configs and test runners.
- [ ] Primary theme generated with Light/Dark support and framework-isolated `ThemeCubit`.
- [ ] Interactive `UiKitPage` created in `lib/presentation/pages/uikit/` showcasing all design system components.
- [ ] `build_runner` and `intl_utils` code generators executed successfully.
- [ ] `import_sorter:main` executed workspace-wide.
- [ ] Unit, widget, and `uikit_page` integration tests passed 100%.
- [ ] Comprehensive `README.md` and `RUNBOOK.md` documentation generated.
