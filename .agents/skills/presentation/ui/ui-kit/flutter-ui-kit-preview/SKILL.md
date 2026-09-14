---
name: flutter-ui-kit-preview
description: Implements real-time widget previews for UI Kit components using package:flutter/widget_previews.dart and @Preview annotation. Enforces zero side-effects (no native APIs, no network), mandatory Light/Dark dual testing, PreviewWrapper encapsulation, explicit viewport sizing, MultiPreview transformations, and state-matrix preview patterns. Use when creating UI Kit components, building isolated feature widgets, or setting up visual preview decorators.
---

# Flutter UI Kit Widget Preview (@Preview) Guide

## 1. Overview & When to Apply

Use this skill whenever:
- Creating new UI Kit components (`lib/presentation/ui_kit/`) and adding `@Preview` annotations.
- Designing feature widgets in isolation from full application state.
- Setting up component state matrices (Content, Loading, Error) for designer review.
- Encapsulating components in `PreviewWrapper` to supply `MaterialApp`, `ThemeData`, and `Scaffold`.
- Running and debugging widget previews in IDE sidebar or CLI (`flutter widget-preview start`).

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent UI Kit Hub** | [flutter-ui-kit-hub](../flutter-ui-kit-hub/SKILL.md) | UI Kit architecture and folder standards. |
| **UI Kit Components** | [flutter-ui-kit-components](../flutter-ui-kit-components/SKILL.md) | Component recipes to decorate with previews. |
| **Theming System** | [flutter-ui-theme-hub](../../../theme/flutter-ui-theme-hub/SKILL.md) | Light and Dark ThemeData providers. |

---

## 3. Technical Constraints & Web-Runner Limitations

1. **Zero Native APIs (`dart:io` / `dart:ffi`):** Preview runs in a mock environment; isolate native dependencies behind interfaces.
2. **Zero Live Network Calls:** Pass static mock entities (`*.mock()`) or static DTOs.
3. **Explicit Viewport Sizing:** Always supply `size: Size(width, height)` in `@Preview` to prevent unconstrained viewport explosion.
4. **Top-Level Function Requirement:** Apply `@Preview` only to top-level functions or public static methods with no required parameters returning a `Widget`.

---

## 4. Reference Implementations (`examples/`)

- **Standard `PreviewWrapper` Component:** [examples/preview_wrapper_sample.dart](examples/preview_wrapper_sample.dart)
  - Provides theme (`AppTheme.lightTheme` / `darkTheme`), scaffold, padding, and centered layout.
- **Dual Light/Dark Component Preview:** [examples/component_preview_sample.dart](examples/component_preview_sample.dart)
  - Demonstrates `@Preview(name: ..., size: ...)` decoration with `Brightness.light` and `Brightness.dark`.

---

## 5. Verification Checklist

- [ ] Every preview function is wrapped in `PreviewWrapper`.
- [ ] Explicit viewport `size:` is defined in `@Preview`.
- [ ] Dual previews created for both Light and Dark themes.
- [ ] Zero live network calls or unmocked native plugins in preview code paths.
