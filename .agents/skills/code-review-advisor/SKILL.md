---
name: code-review-advisor
description: >-
  Performs an in-depth senior technical code review focusing on Clean Architecture enforcement, Flutter/BLoC best practices, memory leaks, performance traps, and error resilience.
  Use ONLY when the user explicitly requests code review or technical critique in any language, e.g. "зроби код рев'ю" / "code review" / "сделай код ревью", "перевір код" / "review code" / "проверь код", "оціни якість коду" / "evaluate code quality", "знайди баги/вразливості" / "find bugs/vulnerabilities" / "найди баги".
---

# Code Review & Technical Quality Advisor

## 1. Overview & When to Apply

This skill acts as a **strict Senior Mobile Architect code reviewer**. It audits modified or newly created code against project standards, architectural boundaries, performance metrics, and safety guarantees.

### When to Activate:
Activate this skill **ONLY** upon explicit user request in **any language**:
- **UK:** *"Зроби код-рев'ю останніх змін"*, *"Перевір код на баги, витоки пам'яті та помилки архітектури"*, *"Оціни якість та надійність написаного BLoC / репозиторію"*, *"Зроби технічний аудит реалізації"*
- **EN:** *"Do a code review of recent changes"*, *"Review code for bugs, memory leaks, and architecture violations"*, *"Audit BLoC and repository implementation"*, *"Evaluate code quality and performance"*
- **RU:** *"Сделай код-ревью последних изменений"*, *"Проверь код на баги, утечки памяти и архитектурные ошибки"*, *"Оцени качество и надежность BLoC / репозитория"*, *"Сделай технический аудит реализации"*

Do **NOT** activate this skill automatically during regular code generation or editing tasks unless explicitly asked to review.

---

## 2. Technical Audit Checklist & Standards

When reviewing, rigorously check each of the following areas:

### 2.1 Clean Architecture & Imports
- **Layer Isolation:** Does Domain contain ANY Flutter / UI / Retrofit imports? (Must be strictly 0).
- **Use Case Enforcement:** Does BLoC/Cubit communicate with repositories directly? (Must ONLY use UseCases).
- **DTO Encapsulation:** Are DTOs exposed outside Data layer? (Must map to Domain entities via `.toDomain()`).
- **Package Imports:** Are all imports absolute package imports (`import 'package:flutter_template/...'`)? (Relative imports forbidden except `part`/`part of`).

### 2.2 Flutter UI & Theme Rules
- **Hardcoded Colors:** Are there `Color(0x...)` or static color classes in UI? (Must use `context.colorScheme` or `context.customColors`).
- **File Length & Decomposition:** Are widget files within 150–200 lines? Are helper builder methods (`_buildHeader()`) used instead of extracted `StatelessWidget` classes?
- **Text & Extensions:** Are `context.textTheme` and `context.theme` used instead of `Theme.of(context)`?

### 2.3 BLoC & State Management Robustness
- **Dart 3 Hierarchy:** Is state/event base class `sealed` and variants `final`?
- **Emitter Safety:** Is `if (emit.isDone) return;` present after every `await` in BLoC event handlers?
- **Failure Resilience:** Are errors logged via `addError(error, stackTrace)` and mapped to typed Domain failures?
- **Event Concurrency:** Are `restartable()`, `droppable()`, or `sequential()` transformers used appropriately?
- **Hydrated BLoC:** Is serialization isolated in `hydrated_<feature>_bloc.mixin.dart`?

### 2.4 Performance & Memory Management
- **Resource Cleanup:** Are `TextEditingController`, `AnimationController`, `StreamSubscription`, and `FocusNode` properly disposed of in `StatefulWidget.dispose()`?
- **Rebuild Optimization:** Are `const` constructors used where possible? Are `BlocSelector` or granular widgets used to avoid rebuilding entire trees?
- **Unbounded Constraints & Overflow:** Are scrollable areas properly bounded (`Expanded`, `SliverList`)?

---

## 3. Mandatory Output Format

At the **end of your review**, provide an isolated, structured callout block (`> [!TIP]`):

```markdown
> [!TIP]
> ### 🛡️ Code Review & Technical Audit:
> 
> - 🔴 **CRITICAL (Виправити негайно):**
>   - **[Файл / Метод]:** [Опис проблеми, що порушує роботу або архітектуру].
>   - *Порушення:* [Порушення Clean Architecture, витік пам'яті, crash/unhandled exception].
>   - *Рекомендований фікс:* [Конкретна інструкція/код для виправлення].
> 
> - 🟠 **HIGH (Важливі технічні зауваження):**
>   - **[Файл / Метод]:** [Опис неоптимального патерну або ризику].
>   - *Рекомендований фікс:* [Конкретне рішення].
> 
> - 🟡 **MEDIUM / LOW (Стиль та оптимізація):**
>   - **[Файл / Метод]:** [Дрібні зауваження: const, найменування, декомпозиція віджетів].
```

> [!NOTE]
> If the code satisfies all Senior Architect standards without any remarks, output a concise confirmation that the code is production-ready and fully complies with Clean Architecture.

---

## 4. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Nitpicking without rationale | **MEDIUM** | Always explain *why* a pattern is problematic and provide the exact solution. |
| Overlooking layer violations | **CRITICAL** | Never pass code that breaks Clean Architecture boundaries (DTO in UI, Flutter in Domain). |
| Ignoring missing disposal | **HIGH** | Always flag controllers and stream subscriptions that lack disposal logic. |

---

## 5. Review Verification Checklist

- [ ] All Domain imports checked (100% pure Dart).
- [ ] BLoC emitter safety checked after all `await` points.
- [ ] No hardcoded colors or missing ThemeExtensions.
- [ ] Controller disposal verified in all UI components.
- [ ] Output formatted in Ukrainian as required.
