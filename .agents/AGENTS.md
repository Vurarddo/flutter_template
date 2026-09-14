# Antigravity IDE Rules — Flutter Project Configuration

## 1. General Communication & Language Configuration Protocol

- **Configured Communication Language:** Ukrainian
  *(Template default: if set to `[NOT_CONFIGURED]`, agent defaults to English for the initial turn, asks the user for their preferred communication language, and updates this field in `.agents/AGENTS.md` upon confirmation).*
- **Language Separation Guidelines:**
  - **User Chat & Direct Responses:** ALWAYS communicate with the user in the **Configured Communication Language** (e.g., Ukrainian).
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
- **Extensions Usage Standard:**
  - ALWAYS use `context.theme`, `context.textTheme`, `context.colorScheme`, and `context.customColors` instead of verbose `Theme.of(context)` calls.
  - **Extensions Location Strategy:**
    - Flutter & UI-specific extensions (`BuildContext`, UI string formatting, UI context wrappers): `lib/presentation/ui_utils/extensions/`.
    - Pure Dart extensions (`DateTime`, `num`, `String` logic without Flutter SDK dependencies): `lib/core/extensions/`.
- **UI Kit Standards (`lib/presentation/ui_kit/`):**
  - All reusable UI Kit widgets MUST be stateless, pure, and completely decoupled from BLoC/domain logic.
  - EVERY UI Kit component MUST include a `@Preview` decorator and a preview function for isolated IDE rendering.
- **Fluent UI Composition:** Chained extension wrappers (e.g., `child.unfocusWrapper()`) are allowed ONLY if the corresponding extension functions exist in `lib/presentation/ui_utils/extensions/`. Otherwise, use standard Flutter widget wrappers.
- **Sliver Architecture:** Use a sliver-first approach (`CustomScrollView` + `SliverAppBar` + `SliverList`/`SliverGrid`) for complex scrollable screens.
- **Animations:** Isolate animation logic from business logic and layout. Always properly dispose of `AnimationController` resources.

---

## 5. State Management Standards (BLoC / Cubit)

- **File Structure:** Feature BLoCs must be split into three files using `part` and `part of`:

```
lib/presentation/state_management//
_event.dart
_state.dart
_bloc.dart (or _cubit.dart)
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

- **Imports Standard:**
  - ALWAYS use package imports (`import 'package:flutter_template/...';`) for all project files across all layers.
  - Relative imports (e.g. `import '../...';` or `import 'movie.dart';`) are strictly prohibited. The only exception is `part` / `part of` compiler directives.
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
- **Assets:** Assets and SVGs managed via `flutter_gen`. Generated path: `lib/presentation/ui_utils/assets`.
- **Excluded Files from AI Edits:** Do NOT manually modify or review generated files (`*.g.dart`, `*.gr.dart`, `*.freezed.dart`, `lib/l10n/generated/**`, `build/**`).

---

## 10. Environment Configuration & Secrets Management

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

## 12. AI Execution Guidelines

- **Git Push Policy (Strict):** AI agents MUST NEVER automatically execute `git push` to remote repositories unless the user gives direct, explicit instruction (e.g., "запуш", "push", "запуш зміни"). Staging and creating local commits (`git add`, `git commit`) can be done as requested, but pushing to the remote repository is strictly forbidden without explicit permission.
- Do NOT introduce any unrequested third-party packages or alternative state management solutions (e.g., Riverpod, Provider).
- Always ensure generated code strictly complies with `injectable`, `auto_route`, and `reactive_forms` patterns used in the project.
- Maintain trailing commas in all Dart code snippets to prevent formatting churn.
