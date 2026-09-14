# Antigravity IDE Rules — Flutter Project Configuration

## 1. General Communication & Language Configuration Protocol

- **Language Resolution Hierarchy:**
  1. **Local Override (Git-Ignored):** If a local rule file exists at `.agents/rules/local_language.md` (or `.agents/local.json`), use the language defined there.
  2. **Workspace Rule:** If **Configured Communication Language** below is explicitly defined (and not `[NOT_CONFIGURED]`), use that language.
  3. **First-Run Protocol (Template Default):** If set to `[NOT_CONFIGURED]` and no local override exists:
     - Agent defaults to English on the initial turn.
     - Agent asks the user for their preferred communication language.
     - Upon confirmation, agent creates `.agents/rules/local_language.md` (which is listed in `.gitignore`) containing `- **Configured Communication Language:** <Chosen Language>`. This preserves `[NOT_CONFIGURED]` in `.agents/AGENTS.md` for clean version control in template repositories.
- **Configured Communication Language:** [NOT_CONFIGURED]
- **Language Separation Guidelines:**
  - **User Chat & Direct Responses:** ALWAYS communicate with the user in the resolved **Configured Communication Language** (e.g., Ukrainian).
  - **Internal Reasoning & Artifacts:** Internal reasoning, system drafts, implementation plans (`implementation_plan.md`), and technical walkthroughs are written in **English** for maximum technical precision and model reasoning performance.
  - **Source Code & Identifiers:** All code, filenames, architecture layers, variables, tests, inline doc-comments (`///`), and git commits MUST strictly remain in **English**.
- **Senior Mobile Architect Role:** Write clean, maintainable, testable, and production-ready code. Avoid over-engineering, "magic" code, and redundant abstractions. Prioritize efficiency, high performance, and long-term support.
- **Concise Architectural Rationale:** Do NOT write lengthy explanations for standard boilerplate code. Provide brief, highly concentrated architectural rationales ONLY for complex, non-obvious design choices or critical state management patterns.

---

## 2. Project Architecture & Layer Separation (Strict Clean Architecture)

Strictly adhere to the following layer boundaries and dependency rules without exceptions:

- **Domain Layer:** Contains pure business entities, repository interfaces, and Use Cases. Must be 100% framework-agnostic (pure Dart only; strictly NO Flutter, Dio, Retrofit, SharedPreferences, or UI imports).
- **Data Layer:** Contains repository implementations, data sources (Retrofit API, local storage), DTOs (Data Transfer Objects with `json_serializable`), and explicit Mappers (converting DTOs <-> Domain Entities).
- **Presentation Layer:** UI Screens, modular Widgets, UI Kit, Theme, and State Management (BLoC/Cubit). Must ONLY depend on Domain Entities and Use Cases.
- **Core / Infrastructure Layer:** Dependency Injection setup (`injectable`), network configurations (`Dio`), loggers, global extensions, and constants/utilities.

### Workspace Action & Skill Routing Guide (Intent & Code Navigator)

Use this quick-routing index to locate target codebase paths and activate relevant skills based on user intent:

- **API Endpoints & Network (REST calls, Retrofit clients, DTOs, Mappers):**
  - **Target Paths:** `lib/data/datasources/`, `lib/data/models/`, `lib/data/mappers/`, `lib/core/network/`
  - **Skills to Activate:** [`infrastructure-network-dio`](skills/infrastructure/infrastructure-network-dio/SKILL.md), [`data-retrofit-clients`](skills/data/data-retrofit-clients/SKILL.md), [`data-dto-mappers`](skills/data/data-dto-mappers/SKILL.md)

- **Business Logic & Domain (New features, Use Cases, Entities, Repository contracts):**
  - **Target Paths:** `lib/domain/entities/`, `lib/domain/repositories/`, `lib/domain/usecases/`, `lib/domain/failures/`
  - **Skills to Activate:** [`domain-usecases`](skills/domain/domain-usecases/SKILL.md), [`domain-entities-freezed`](skills/domain/domain-entities-freezed/SKILL.md), [`domain-repositories`](skills/domain/domain-repositories/SKILL.md), [`domain-failures`](skills/domain/domain-failures/SKILL.md)

- **State Management (BLoC/Cubit, Events, States, HydratedBLoC persistence):**
  - **Target Paths:** `lib/presentation/state_management/<feature>/`
  - **Skills to Activate:** [`flutter-bloc-core`](skills/presentation/state-management/flutter-bloc-core/SKILL.md), [`flutter-hydrated-bloc`](skills/presentation/state-management/flutter-hydrated-bloc/SKILL.md)

- **UI Screens & UI Kit (Feature pages, widgets, design tokens, context extensions):**
  - **Target Paths:** `lib/presentation/pages/<feature>/`, `lib/presentation/ui_kit/`, `lib/presentation/theme/`, `lib/presentation/ui_utils/extensions/`
  - **Skills to Activate:** [`flutter-bloc-widgets`](skills/presentation/state-management/flutter-bloc-widgets/SKILL.md), [`flutter-ui-kit-components`](skills/presentation/ui/ui-kit/flutter-ui-kit-components/SKILL.md), [`flutter-ui-utils-extensions`](skills/presentation/ui-utils/flutter-ui-utils-extensions/SKILL.md), [`flutter-ui-theme-extensions`](skills/presentation/theme/flutter-ui-theme-extensions/SKILL.md)

- **Project Scaffolding & Bootstrap (Initial setup, new project creation, architecture backbone):**
  - **Target Paths:** `lib/`, `config/`, `android/`, `ios/`, `.vscode/`
  - **Skills to Activate:** [`project-bootstrap-hub`](skills/bootstrap/project-bootstrap-hub/SKILL.md), [`bootstrap-architecture-scaffold`](skills/bootstrap/bootstrap-architecture-scaffold/SKILL.md)

- **Flavors & Environments (Env configs, Android Gradle, iOS xcconfig, AppConfig):**
  - **Target Paths:** `config/env_*.json`, `lib/core/config/`, `android/app/`, `ios/Runner/`
  - **Skills to Activate:** [`native-flavors-environments`](skills/native/native-flavors-environments/SKILL.md), [`bootstrap-architecture-scaffold`](skills/bootstrap/bootstrap-architecture-scaffold/SKILL.md)

- **Localization & Translations (ARB files, ICU plurals, failure string mappers):**
  - **Target Paths:** `lib/l10n/intl_*.arb`, `lib/l10n/generated/`
  - **Skills to Activate:** [`l10n-arb-icu`](skills/l10n/l10n-arb-icu/SKILL.md), [`l10n-presentation-integration`](skills/l10n/l10n-presentation-integration/SKILL.md)

- **Automated Testing (Unit, Widget, BLoC, and E2E Integration tests):**
  - **Target Paths:** `test/`, `integration_test/`
  - **Skills to Activate:** [`testing-unit`](skills/testing/testing-unit/SKILL.md), [`testing-bloc`](skills/testing/testing-bloc/SKILL.md), [`testing-widget`](skills/testing/testing-widget/SKILL.md), [`testing-integration`](skills/testing/testing-integration/SKILL.md)

### Strict Inter-Layer Interaction Rules:

1. **Mandatory Use Cases:** BLoCs/Cubits MUST ONLY interact with **Use Cases**. Direct interaction between BLoC/Cubit and Repositories or Data Sources is STRICTLY PROHIBITED.
2. **Data Model Encapsulation:** DTOs and raw API responses must NEVER cross into the Presentation layer. All data must be mapped to Domain Entities before reaching BLoC/Cubit or UI.
3. **Strict One-Way Dependency Flow:**
   `UI -> BLoC/Cubit -> UseCase -> Repository Interface (Domain) <- Repository Implementation (Data) -> Data Source`.

---

## 3. Tech Stack & Environment

- **Framework:** Flutter (SDK ^3.12.2)
- **State Management:** BLoC / Cubit (`bloc`, `flutter_bloc`, `hydrated_bloc`, `bloc_concurrency`)
- **Dependency Injection:** `injectable` + `get_it`
- **Routing:** `auto_route`
- **Networking:** `dio` + `retrofit`
- **Forms:** `reactive_forms`
- **Data Models & Immutability:** `freezed` + `json_annotation` / `equatable`
- **Storage:** `shared_preferences`, `flutter_secure_storage`, `path_provider`

---

## 4. UI Guidelines, Extensions, Theme & UI Kit Standards

- **Max File Size:** Keep screen/widget files strictly within **150–200 lines**.
- **Widget Decomposition:**
  - DO NOT write large, deeply nested widget trees in a single file.
  - Split the UI into small, focused sub-widgets inside `lib/presentation/pages/<feature>/widgets/`.
  - Strictly DISALLOW helper builder methods (e.g., `Widget _buildHeader()`) inside widget classes. Always extract them into separate `StatelessWidget` classes to optimize render tree performance.
- **Theme & Color Management Standards:**
  - Strictly PROHIBIT hardcoding raw `Color(0x...)` values or utilizing static color classes (e.g., `AppColors.call`) directly inside UI widgets.
  - ALL UI colors MUST be accessed strictly through `context.colorScheme` (Material 3 standard) or custom `ThemeExtension` classes.
  - The application MUST fully support both **Light** and **Dark** themes. `ThemeData` setup must be dynamic and driven by `ColorScheme` (Light vs Dark).
  - Domain-specific or custom design tokens (e.g., trading `call`/`put`, status badges, custom gradients) MUST be defined via `ThemeExtension` (e.g., `AppCustomColors`), maintaining distinct values for Light and Dark modes.
- **Extensions Usage & Naming Standard:**
  - **Naming Convention (Strict):** ALL public Dart extensions MUST be suffixed with `X` (e.g., `BuildContextX`, `StringX`, `DateTimeX`, `AppThemeModeX`). Never use verbose `...Extension` suffixes (e.g. BAD: `BuildContextExtension`, GOOD: `BuildContextX`).
  - ALWAYS use `context.theme`, `context.textTheme`, `context.colorScheme`, and `context.customColors` instead of verbose `Theme.of(context)` calls.
  - **Extensions Location Strategy:**
    - Flutter & UI-specific extensions (`BuildContext`, UI string formatting, UI context wrappers): `lib/presentation/ui_utils/extensions/`.
    - Pure Dart extensions (`DateTime`, `num`, `String` logic without Flutter SDK dependencies): `lib/core/extensions/`.
- **UI Kit Standards (`lib/presentation/ui_kit/`):**
  - All reusable UI Kit widgets MUST be stateless, pure, and completely decoupled from BLoC/domain logic.
  - EVERY UI Kit component MUST include a `@Preview` decorator and a preview function for isolated IDE rendering.
  - Every project must include an interactive showcase page `UiKitPage` displaying all design system components and verified by automated integration tests (`integration_test/uikit_page_test.dart`).
- **Fluent UI Composition:** Chained extension wrappers (e.g., `child.unfocusWrapper()`) are allowed ONLY if the corresponding extension functions exist in `lib/presentation/ui_utils/extensions/`. Otherwise, use standard Flutter widget wrappers.
- **Sliver Architecture:** Use a sliver-first approach (`CustomScrollView` + `SliverAppBar` + `SliverList`/`SliverGrid`) for complex scrollable screens.
- **Animations:** Isolate animation logic from business logic and layout. Always properly dispose of `AnimationController` resources.

---

## 5. State Management Standards (BLoC / Cubit)

- **File Structure:** Feature BLoCs must be split into three files using `part` and `part of`:

```
lib/presentation/state_management/<feature>/
├── <feature>_event.dart
├── <feature>_state.dart
└── <feature>_bloc.dart (or <feature>_cubit.dart)
```

- **Framework Isolation & Zero Flutter Imports (Strict `avoid_flutter_imports`):**
  - BLoCs and Cubits must NEVER import `package:flutter/material.dart`, `package:flutter/widgets.dart`, or any UI layer framework packages.
  - If a BLoC/Cubit manages concepts such as theme modes, navigation intents, or UI states, it MUST use a pure Dart enum in domain/state (e.g. `enum AppThemeMode { system, light, dark }`).
  - Mapping from domain/state enums to Flutter SDK types (e.g., `ThemeMode`) MUST happen in the Presentation layer via an extension:
    ```dart
    extension AppThemeModeX on AppThemeMode {
      ThemeMode toFlutter() => switch (this) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      };
    }
    ```
- **State & Event Modeling:**
  - Use `sealed class` for the base state/event and `final class` for concrete variants (Dart 3+ pattern).
  - Avoid a single state class with multiple nullable flags. Model explicit lifecycle states instead: `Initial`, `InProgress`, `Success`, `Failure`.
  - Extend `Equatable` for state comparison. To generate `copyWith` automatically for state classes that require state modifications, annotate the target state class with `@CopyWith()` from `package:copy_with_extension/copy_with_extension.dart` instead of writing `copyWith` manually.
- **Dependency Injection:** Annotate all Blocs/Cubits with `@injectable` for DI registration via `injectable` + `get_it`.
- **UI & BLoC Interaction:**
  - UI MUST ONLY send events via dispatching: `context.read<FeatureBloc>().add(Event())`. Never expose or call public methods on BLoC classes.
  - Use `BlocListener` for one-off side-effects (navigation, dialogs, SnackBars) and `BlocBuilder`/`BlocSelector` for visual rendering.
- **Asynchrony & Safety:**
  - After ANY `await` operation inside a BLoC event handler, ALWAYS check the emitter status: `if (emit.isDone) return;`.
- **Error Handling in BLoC:**
  - Catch exceptions, log them via `addError(error, stackTrace)`, and map them to typed Domain failure states.
  - DO NOT automatically clear or reset a `Failure` state back to `Initial` within the same event handler to prevent UI flickering. Reset states ONLY via explicit user retry actions.
- **Hydrated BLoC (Strict Local Persistence Standard):**
  - Use `hydrated_bloc` strictly for non-sensitive UI preferences (e.g., filters, active tab index). NEVER persist tokens, passwords, or PII.
  - **Mandatory Serialization Separation:** ALL Hydrated BLoCs MUST extract `fromJson`/`toJson` and `storagePrefix` logic into a separate mixin file: `hydrated_<feature>_bloc.mixin.dart` implementing `mixin Hydrated<Feature>BlocMixin on HydratedMixin<FeatureState>`. This keeps the main BLoC file clean of serialization boilerplate.
  - Always handle parsing failures safely by returning a fallback default state in `fromJson`.

---

## 6. Network, Data & Event Concurrency

- Implement API clients using Retrofit (`@RestApi`) and Dio in the Data layer.
- Handle network errors at the Data Source / Repository level, mapping raw Dio exceptions to typed Domain exceptions (`ApiException`).
- Apply explicit BLoC Event Transformers using `bloc_concurrency` to control execution flow:
  - `restartable()` for search, filtering, and autocomplete inputs.
  - `droppable()` for action buttons (e.g., submit/payment clicks) to prevent double-submit spam.
  - `sequential()` for ordered queue operations.

---

## 7. Code Generation & Data Models Constraints

- **Build Runner:** Code generation is executed via `flutter pub run build_runner build --delete-conflicting-outputs`.
- **Freezed Constraints & Syntax (per `build.yaml` & Freezed 3+):**
  - **Syntax Standard:** Freezed classes MUST be declared as regular classes with field definitions in the class body and a `const ClassName({required this.field, ...});` constructor with `with _$ClassName`.

    ```dart
    @freezed
    class ExampleItem with _$ExampleItem {
      final String id;
      final String title;
      final String description;
      final bool isActive;
      final List<String> tags;

      const ExampleItem({
        required this.id,
        required this.title,
        required this.description,
        required this.isActive,
        required this.tags,
      });
    }
    ```

  - Custom build configuration disables `map`, `when`, `fromJson`, and `toJson` code generation.
  - Do NOT generate, call, or expect `map`, `when`, `fromJson`, or `toJson` methods on `@freezed` models.
  - Use `@freezed` strictly for immutable data classes, `copyWith`, `toString`, `equals`, and `hashCode`.
  - For JSON serialization, use explicit DTOs with `json_serializable` in the Data layer.

- **Retrofit Constraints:** API services must be defined as abstract classes annotated with `@RestApi()` and use a `Dio` instance injected via `GetIt`.

---

## 8. Linting, Formatting, Imports & BLoC Strict Rules (per `analysis_options.yaml`)

- **Imports Standard & Sorting (`import_sorter`):**
  - ALWAYS use package imports (`import 'package:flutter_template/...';`) for all project files across all layers.
  - Relative imports (e.g. `import '../...';` or `import 'movie.dart';`) are strictly prohibited. The only exception is `part` / `part of` compiler directives.
  - **Continuous Import Sorting:** ALWAYS execute `flutter pub run import_sorter:main` (or `dart run import_sorter:main`) whenever Dart files are created, refactored, or have import modifications.
  - Configuration in `pubspec.yaml` MUST specify `import_sorter: comments: false`.
- **Formatting:**
  - Page width: 100 characters.
  - Trailing commas: MUST be preserved.
- **Linter Rules Overrides:**
  - `prefer_const_constructors`: true
  - `annotate_overrides`: false
  - `constant_identifier_names`: false
  - `no_leading_underscores_for_library_prefixes`: false
- **Strict BLoC Rules:**
  - `avoid_flutter_imports`: true (BLoCs/Cubits must NEVER import `package:flutter/material.dart` or any UI-related imports)
  - `avoid_public_bloc_methods`: true (BLoC methods must be private; state changes must be triggered strictly via Events)
  - `avoid_public_fields`: true (Keep all fields in BLoC/Cubit private)
  - `prefer_void_public_cubit_methods`: true (Cubit public methods must return `void`)

---

## 9. Resources & Asset Management

- **Localization:** Managed via `flutter_intl` / `intl`. Output directory: `lib/l10n/generated`.
- **Assets & `flutter_gen` Configuration:**
  - Output path MUST strictly be configured to `lib/presentation/ui_utils/assets` in `pubspec.yaml`:
    ```yaml
    flutter_gen:
      output: lib/presentation/ui_utils/assets
      integrations:
        flutter_svg: true
    ```
  - Generating assets into `lib/gen` is STRICTLY PROHIBITED.
  - Standard directory structure for assets: `assets/`, `assets/fonts/`, `assets/images/`, `assets/icons/`, `assets/svgs/` with `.gitkeep`.
  - Provide commented-out templates for `assets:` and `fonts:` in `pubspec.yaml`.
- **Excluded Files from AI Edits:** Do NOT manually modify or review generated files (`*.g.dart`, `*.gr.dart`, `*.freezed.dart`, `lib/l10n/generated/**`, `build/**`).

---

## 10. Environment Configuration & Secrets Management

- **Multi-Environment Flavors Across All Platforms:**
  - Multi-flavor environments (`dev`, `stage`, `prod`) MUST be configured across all targeted native platforms:
    - **Android:** `android/app/build.gradle.kts` (or `build.gradle`) with `flavorDimensions += "default"`, `productFlavors` (`applicationIdSuffix`, `manifestPlaceholders`), and `AndroidManifest.xml` (`${appName}`, `${appIcon}`, and mandatory `<uses-permission android:name="android.permission.INTERNET" />`). Official guide: https://docs.flutter.dev/deployment/flavors
    - **iOS:** Xcode Build Configurations (`Debug-dev`, `Release-dev`), shared Schemes (`dev`, `stage`, `prod`), `xcconfig` files, and `Info.plist`. Official guide: https://docs.flutter.dev/deployment/flavors-ios
    - **Linux:** `linux/CMakeLists.txt` build definitions and `my_application.cc`. Official guide: https://docs.flutter.dev/deployment/flavors-linux
    - **Windows:** `windows/CMakeLists.txt`, `windows/runner/Runner.rc`, and `windows/runner/main.cpp`. Official guide: https://docs.flutter.dev/deployment/flavors-windows
    - **macOS:** Xcode Build Configurations and shared Schemes matching iOS.
- **Configuration Injection:** Environment settings (e.g. `BASE_URL`, `API_KEY`, `APP_ENV`) MUST be passed using `--dart-define-from-file=config/env_dev.json` or `--dart-define`.
- **Git Hygiene:** Local configuration files containing real environment credentials (`config/env_*.json`) MUST be listed in `.gitignore` and NEVER committed to repository. Provide `config/env_template.json` as a template.
- **Environment Abstraction:** Access values via a centralized, strongly-typed `AppConfig` class in `lib/core/config/app_config.dart` using `String.fromEnvironment`.
- **Client Security Rule:** Never store true private server keys (e.g., payment secret keys, private backend signing tokens) inside the mobile client code. All sensitive actions must be authorized via backend APIs.

---

## 11. Analytics & Event Tracking Architecture (AnalyticsRepository)

- **Domain Abstraction:** All analytics and event tracking MUST be abstracted through an `AnalyticsRepository` interface in `lib/domain/repositories/analytics_repository.dart`.
- **Clean Architecture Boundaries:** UI Widgets MUST NEVER invoke analytics SDKs (Firebase Analytics, Mixpanel, Amplitude, AppsFlyer) directly.
- **Tracking Invocation:** Analytics events MUST be triggered strictly via UseCases or inside BLoC/Cubit event handlers (or specialized `BlocListener` wrappers for UI session tracking).
- **Multiple Providers Composite:** Implement `AnalyticsRepositoryImpl` in `lib/data/repositories/` using a composite pattern if multiple analytics services are used simultaneously.
- **Typed Events & PII Redaction:** Event names and parameters MUST use strongly-typed enums or value objects. NEVER pass PII (user passwords, auth tokens, full credit card numbers) in analytics payloads.

---

## 12. Workspace Setup & AI Execution Guidelines

- **VS Code Workspace (`.vscode/`):**
  - Scaffolding MUST include `.vscode/launch.json` configured for multi-environment Flavors (Debug, Profile, Release for dev, stage, prod) AND automated test runners (All tests, unit, widget, bloc, integration tests).
  - Include `.vscode/settings.json` and `.vscode/extensions.json` recommending standard Flutter tools.
- **Router Maintenance & Stale Pointer Policy:**
  - When a file moves, an architecture folder is reorganized, or a new module is introduced, the agent MUST update the corresponding router (in `AGENTS.md`, Skill Hubs, or feature index) within the **same turn**.
  - *A stale pointer is worse than no pointer.* Always maintain 100% path accuracy and valid relative links.
- **Git Push Policy (Strict):** AI agents MUST NEVER automatically execute `git push` to remote repositories unless the user gives direct, explicit instruction (e.g., "запуш", "push", "запуш зміни"). Staging and creating local commits (`git add`, `git commit`) can be done as requested, but pushing to the remote repository is strictly forbidden without explicit permission.
- Do NOT introduce any unrequested third-party packages or alternative state management solutions (e.g., Riverpod, Provider).
- Always ensure generated code strictly complies with `injectable`, `auto_route`, and `reactive_forms` patterns used in the project.
- Maintain trailing commas in all Dart code snippets to prevent formatting churn.
