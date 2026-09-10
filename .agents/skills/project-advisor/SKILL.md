---
name: project-advisor
description: >-
  Provides strategic, holistic advice and critical evaluation of completed agent work, identifying missing logical steps, architectural inconsistencies, and proposing next high-value actions.
  Use ONLY when the user explicitly triggers an advisor/audit review in any language, e.g. "порадь" / "advise" / "посоветуй", "проаналізуй роботу" / "analyze work", "чи чогось не вистачає" / "is anything missing" / "чего не хватает", "що ще додати" / "what else to add" / "что еще добавить", "оціни результат" / "evaluate result", "дай рекомендації" / "give recommendations".
---

# Project Advisor & Completeness Auditor

## 1. Overview & When to Apply

This skill operates as a **manual advisor & auditor**. It is triggered **strictly on-demand** when the user requests an expert second opinion, audit of completed work, or strategic recommendations for next steps.

### When to Activate:
Activate this skill **ONLY** when the user explicitly asks for advice, evaluation, completeness checks, or next steps in **any language**:
- **UK:** *"Проаналізуй зроблену роботу та порадь, чого не вистачає"*, *"Що ще варто додати?"*, *"Перевір, чи ми нічого не пропустили в логіці"*, *"Дай рекомендації щодо наступних кроків"*
- **EN:** *"Advise on the completed work and what is missing"*, *"What else should we add or consider?"*, *"Review if we missed any logical steps"*, *"Give recommendations for next steps"*
- **RU:** *"Проанализируй сделанную работу и посоветуй, чего не хватает"*, *"Что еще стоит добавить?"*, *"Проверь, не упустили ли мы логику"*, *"Дай рекомендации по следующим шагам"*

Do **NOT** activate this skill automatically during standard coding tasks, bug fixes, or code generation unless explicitly prompted.

---

## 2. Advisory & Evaluation Dimensions

When triggered, systematically analyze the recent work across these core dimensions:

### 2.1 Logical Completeness & Missing Links
- **Lifecycle & Edge Cases:** Are error, empty, loading, offline, and permission-denied states covered?
- **DI & Wiring:** Are newly created Use Cases, Repositories, BLoCs, and Data Sources registered in `injectable` / `GetIt` and properly imported?
- **State Synchronization:** Are cached/local data states invalidated or refreshed when remote mutations succeed?
- **Navigation & Deep Linking:** Are routes registered in `AppRouter` and handled in navigation flows?

### 2.2 Architectural Integrity & Project Rules
- **Clean Architecture Boundaries:** Did any DTO leak into the presentation layer? Is BLoC directly calling a repository instead of a Use Case?
- **Localization (i18n):** Are there hardcoded Ukrainian/English strings that should be in ARB files?
- **Theming & Design Tokens:** Are raw colors used instead of `context.colorScheme` / `context.customColors`?

### 2.3 Forward-Looking Improvements
- **Automated Testing:** Are unit/widget tests missing for critical state transitions or domain rules?
- **Analytics & Observability:** Should key user actions or business failures be logged to `AnalyticsRepository`?
- **Performance & DX:** Would debouncing, pagination, or caching improve scalability?

---

## 3. Mandatory Output Format

At the **end of your response**, append an isolated, structured advisor block using GitHub callout format (`> [!TIP]`):

```markdown
> [!TIP]
> ### 💡 Радник проекту / Рекомендації:
> 
> - 🔴 **Must (Критично / Необхідно):**
>   - **[Проблема/Пропуск]:** [Чіткий опис того, що обов'язково треба виправити або додати].
>   - *Чому це важливо:* [Обґрунтування впливу на стабільність/архітектуру].
> 
> - 🟡 **Should (Рекомендовано):**
>   - **[Покращення]:** [Опис логічного кроку, якого не вистачає для повноти фічі].
>   - *Потенційний ефект:* [Як це покращить UX або надійність].
> 
> - 🟢 **Could (На майбутнє / Опціонально):**
>   - **[Ідея/Оптимізація]:** [Додаткова ідея для подальшого масштабування].
```

> [!NOTE]
> If everything is complete and no additional changes are warranted, explicitly state that all requirements and architectural standards are fully satisfied.

---

## 4. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Auto-triggering advisory blocks without user request | **HIGH** | Activate ONLY upon explicit user request for review/advice. |
| Vague, generic advice (e.g. "Write more tests", "Improve code") | **HIGH** | Give concrete, actionable recommendations referencing specific files/classes. |
| Over-engineering trivial features | **MEDIUM** | Prioritize practical, high-value improvements rather than excessive abstractions. |
| Omitting priority levels (Must/Should/Could) | **MEDIUM** | Always categorize findings to help the user make informed decisions. |

---

## 5. Advisor Verification Checklist

Before finalizing the advice:
- [ ] Have I checked all layers (Domain, Data, Presentation, Core)?
- [ ] Are recommendations grounded in specific files, classes, and workflows?
- [ ] Are items prioritized by impact (Must / Should / Could)?
- [ ] Is the response formatted in Ukrainian as required by project rules?
