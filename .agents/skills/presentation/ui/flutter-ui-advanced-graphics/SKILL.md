---
name: flutter-ui-advanced-graphics
description: Advanced graphics, CustomPainter, Canvas drawing, ShaderMasks, physics-based motion (SpringSimulation), and Rive/Lottie runtime integration skill. Use when creating custom charts, procedural graphics, canvas particle effects, shader animations, or complex physics-driven gestures.
---

# Flutter Advanced Graphics, CustomPainter & Physics Motion Guide

## 1. Overview & When to Apply

Use this skill whenever:
- Implementing custom charts, procedural backgrounds, wave shapes, or circular gauges via `CustomPainter`.
- Drawing directly to the 2D Skia/Impeller pipeline using `Canvas`, `Path`, and `Paint`.
- Applying custom GPU fragment shaders or `ShaderMask` gradient effects.
- Implementing gesture-driven physical springs (`SpringSimulation`, `FrictionSimulation`).
- Integrating dynamic vector runtime assets via Rive (`rive`) or Lottie animations.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [flutter-ui-hub](../flutter-ui-hub/SKILL.md) | Presentation laws and UI routing. |
| **Basic Animations** | [flutter-ui-animations](../flutter-ui-animations/SKILL.md) | Standard animation controllers & curves. |
| **Performance** | [flutter-ui-performance](../flutter-ui-performance/SKILL.md) | Layer isolation using `RepaintBoundary`. |

---

## 3. High-Performance CustomPainter Architecture

1. **Always wrap in `RepaintBoundary`:** Prevents custom canvas draws from invalidating adjacent widget render layers.
2. **Implement `shouldRepaint` accurately:** Never return `true` blindly. Compare input fields to avoid repainting unchanged frames.
3. **Avoid object allocations inside `paint()`:** Allocate `Paint`, `Path`, and `TextStyle` objects outside or reuse fields.

---

## 4. Reference Implementations (`examples/`)

- **Custom Circular Gauge Painter:** [examples/circular_gauge_painter.dart](examples/circular_gauge_painter.dart)
  - Custom canvas drawing with `drawCircle`, `drawArc`, and `RepaintBoundary` encapsulation.
- **Physics Spring Simulation (`SpringSimulation`):** [examples/physics_spring_draggable.dart](examples/physics_spring_draggable.dart)
  - Natural gesture-driven spring motion using `SpringSimulation` and `AnimationController`.

---

## 5. Verification Checklist

- [ ] Canvas drawing wrapped inside `RepaintBoundary`.
- [ ] `shouldRepaint` accurately compares old and new delegate properties.
- [ ] Zero object allocations (`Paint()`, `Path()`) inside `paint()` loop.
- [ ] Gesture springs use `SpringSimulation` for natural velocity-based snapback.
