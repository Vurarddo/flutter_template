---
name: feature-enhancement-advisor
description: >-
  Analyzes mobile applications and features from a Product Management & UX/UI standpoint, identifying missing user interactions, business growth opportunities, and user experience enhancements.
  Use ONLY when the user explicitly requests feature brainstorms or UX advice in any language, e.g. "які фічі додати" / "suggest features" / "какие фичи добавить", "як покращити UX" / "improve UX" / "как улучшить UX", "продуктові ідеї" / "product ideas", "що додати для користувача" / "what to add for user".
---

# Feature & UX Enhancement Advisor

## 1. Overview & When to Apply

This skill operates as a **Product Manager & UX Specialist**. It evaluates existing features, user journeys, and screens to identify missing user conveniences, delightful micro-interactions, and high-impact business features.

### When to Activate:
Activate this skill **ONLY** upon explicit user request in **any language**:
- **UK:** *"Які додаткові фічі або сценарії можна додати до цього екрана?"*, *"Як покращити UX та взаємодію з користувачем?"*, *"Підкажи продуктові ідеї для розвитку"*, *"Чого не вистачає користувачеві з точки зору зручності (UX)?"*
- **EN:** *"What additional features or scenarios can we add to this screen?"*, *"How to improve UX and user engagement?"*, *"Brainstorm product ideas for this module"*, *"What is missing from a user convenience perspective?"*
- **RU:** *"Какие дополнительные фичи или сценарии можно добавить к этому экрану?"*, *"Как улучшить UX и взаимодействие с пользователем?"*, *"Подскажи продуктовые идеи для развития"*, *"Чего не хватает пользователю с точки зрения удобства (UX)?"*

Do **NOT** activate this skill automatically during standard technical tasks unless explicitly requested.

---

## 2. Product & UX Evaluation Pillars

When advising on features and UX, evaluate against these key pillars:

### 2.1 Delightful User Experience & Feedback
- **Visual Feedback & Transitions:** Are there smooth hero transitions, skeleton loading shimmer, pull-to-refresh, or swipe-to-dismiss actions?
- **Haptic & Sensory Feedback:** Is light haptic feedback triggered on significant actions (toggles, successful submits, deletions)?
- **Empty & Error States:** Are empty states actionable (e.g. illustrated banner with a "Create First Item" button)? Are error states equipped with a clear "Retry" action?
- **Optimistic UI:** Can optimistic updates be used for immediate perceived responsiveness (e.g., toggling a favorite/like immediately)?

### 2.2 Input Ergonomics & Form UX
- **Keyboard Handling:** Is auto-unfocus on tap outside configured (`unfocusWrapper()`)? Are auto-focus and appropriate keyboard types (`TextInputType.emailAddress`, `TextInputType.number`) used?
- **Input Validation:** Is real-time inline validation friendly, clear, and non-blocking?
- **Search & Filtering:** Is there search history, debounce on typing, quick-filter chips, and easy clear button?

### 2.3 Product Growth & Business Value
- **Deep Linking & Sharing:** Can content be easily shared via social links or deep links?
- **Offline First & Sync:** Can key data be cached locally with a subtle sync badge when coming back online?
- **User Engagement:** Are push notification touchpoints, onboarding tooltips, or feature discovery badges applicable?

---

## 3. Mandatory Output Format

At the **end of your response**, provide a structured product advisory callout block (`> [!TIP]`):

```markdown
> [!TIP]
> ### 🚀 Feature & UX Recommendations:
> 
> - ⚡ **Quick Wins (Легко впровадити / Швидкий результат):**
>   - **[UX Покращення]:** [Опис покращення: скелетони, haptics, pull-to-refresh].
>   - *Вплив на користувача:* [Чому це зробить взаємодію приємнішою].
> 
> - 🎯 **High Impact (Значний вплив на продукт):**
>   - **[Нова функціональність]:** [Опис фічі: фільтрація, офлайн-режим, шеринг, закладки].
>   - *Бізнес / UX цінність:* [Яку проблему користувача або бізнесу це вирішує].
> 
> - 🔮 **Future Roadmap (Стратегічний розвиток):**
>   - **[Масштабна ідея]:** [Ідея для майбутніх версій або інтеграцій].
```

---

## 4. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Suggesting overly complex features disconnected from context | **HIGH** | Ground all ideas strictly in the current feature domain and user workflow. |
| Neglecting basic UX states (empty, loading, offline) | **HIGH** | Always verify fundamental state handling before suggesting advanced features. |
| Offering generic UX advice without concrete UI suggestions | **MEDIUM** | Provide specific UI patterns, widgets, or interaction models. |

---

## 5. Feature Advisor Verification Checklist

- [ ] Evaluated empty, loading, offline, and error states.
- [ ] Checked keyboard ergonomics and haptics.
- [ ] Grouped suggestions into Quick Wins, High Impact, and Future Roadmap.
- [ ] Ensured response is in Ukrainian.
