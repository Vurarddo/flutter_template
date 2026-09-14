---
name: flutter-ui-forms-reactive
description: Enforces strict architecture, strong typing, custom validation, cross-field checks, dynamic FormArrays, and BLoC integration standards for reactive_forms in Flutter. Guarantees zero mixing of TextEditingController with FormControl, clear boundaries between Presentation forms and Domain DTOs, debounced async validation, and optimal UI rebuilds. Use when creating form controls, dynamic inputs, or complex field validation.
---

# Flutter Reactive Forms Core Architecture Guide

## 1. Overview & When to Apply

Use this skill whenever:
- Building data entry UI, registration forms, search filters, or multi-step form workflows.
- Creating strongly typed `FormGroup`, `FormControl<T>`, and dynamic `FormArray<T>` models.
- Implementing cross-field validation rules (e.g., password matching, start/end date range).
- Handling debounced asynchronous field validation with backend checks.
- Integrating `reactive_forms` with BLoC state management and mapping form state into DTOs.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Custom Controls** | [flutter-ui-forms-custom-controls](../flutter-ui-forms-custom-controls/SKILL.md) | Binding custom UI Kit widgets with `reactive_forms`. |
| **Parent UI Hub** | [flutter-ui-hub](../../flutter-ui-hub/SKILL.md) | Global presentation layer architecture. |
| **UI Kit Components** | [flutter-ui-kit-components](../../ui-kit/flutter-ui-kit-components/SKILL.md) | Base styled input components. |
| **BLoC UI Widgets** | [flutter-bloc-widgets](../../../state-management/flutter-bloc-widgets/SKILL.md) | Dispatching form events and handling submit states. |

---

## 3. Core Architectural Boundaries & Rules

1. **Clean Architecture Boundary:** `reactive_forms` belongs strictly to `Presentation`. Map form values to/from Domain DTOs/Entities before reaching UseCases.
2. **Single Source of Truth:** Never mix `TextEditingController` with `FormControl`.
3. **No Instantiation in `build()`:** Build `FormGroup` outside of render methods or use `ReactiveFormBuilder`.
4. **Always Strongly Typed:** Specify generic types (e.g. `FormControl<String>`) rather than untyped `dynamic`.

---

## 4. Reference Implementations (`examples/`)

- **Strongly Typed Form & Screen Bundle:** [examples/register_form_bundle.dart](examples/register_form_bundle.dart)
  - Full `FormGroup` factory, typed extension accessors (`RegisterFormX`), cross-field password matching, and `ReactiveFormBuilder` layout.

---

## 5. Verification Checklist

- [ ] `FormGroup` and `FormControl<T>` are strongly typed.
- [ ] No `TextEditingController` instances mixed with reactive controls.
- [ ] Forms mapped to typed DTOs before dispatching BLoC events.
- [ ] Async validators include explicit `asyncValidatorsDebounceTime`.
