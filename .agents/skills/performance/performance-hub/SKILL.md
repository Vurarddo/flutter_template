---
name: performance-hub
description: Primary coordinator and master guide for Flutter performance profiling, diagnostics, and optimization. Covers Flutter DevTools (Performance View, Widget Rebuild Tracker, Highlight Repaints), CPU/GPU jank troubleshooting, Profile mode benchmarking, and routing to specialized sub-skills.
---

# Flutter Performance & Optimization Architecture Hub

## 1. Overview & Architectural Role

Achieving a constant **60 FPS (16.6ms/frame)** or **120 FPS (8.3ms/frame)** across Mobile, Web, and Desktop requires holistic optimization across all three stages of the Flutter render pipeline:

```mermaid
graph TD
    A["Flutter Frame Lifecycle"] --> B["1. UI Thread (Dart VM & Build Phase)"]
    A --> C["2. Engine Layout & Paint (RenderObject Tree)"]
    A --> D["3. Raster Thread (GPU Compositing & Drawing)"]

    B -->|Optimize Build Cost| S1["[performance-rendering-build](../performance-rendering-build/SKILL.md)"]
    B -->|Offload Heavy Compute| S2["[flutter-isolates](../../flutter-isolates/SKILL.md)"]
    C -->|Optimize Scroll & Viewports| S3["[performance-lists-slivers](../performance-lists-slivers/SKILL.md)"]
    D -->|Eliminate saveLayer() & GPU Jank| S4["[performance-expensive-operations](../performance-expensive-operations/SKILL.md)"]
    A -->|Web App Optimization| S5["[performance-web-optimization](../performance-web-optimization/SKILL.md)"]
```

---

## 2. Master Routing Matrix

| Performance Bottleneck / Objective | Target Skill | Key Techniques & Tools |
| :--- | :--- | :--- |
| **High `build()` Cost & Over-Rebuilding** | [performance-rendering-build](../performance-rendering-build/SKILL.md) | `const` constructors, `BlocSelector`, `StatelessWidget` decomposition, `AnimatedBuilder` child caching. |
| **GPU / Rasterizer Jank & Frame Drops** | [performance-expensive-operations](../performance-expensive-operations/SKILL.md) | Eliminating `saveLayer()`, replacing `Opacity` with `FadeTransition`/alpha colors, clipping optimizations, `RepaintBoundary`. |
| **Stuttering Lists & Scroll Jitter** | [performance-lists-slivers](../performance-lists-slivers/SKILL.md) | `ListView.builder`, `SliverList.builder`, `itemExtent`, `prototypeItem`, `findChildIndexCallback`, `AutomaticKeepAliveClientMixin`. |
| **Slow Web Loading & Large Bundle Size** | [performance-web-optimization](../performance-web-optimization/SKILL.md) | Deferred imports (`deferred as`), WebAssembly (Wasm), image precaching, font subsetting. |
| **Heavy JSON Parsing / Calculations** | [flutter-isolates](../../flutter-isolates/SKILL.md) | `Isolate.run()`, background isolate worker pools, heavy math offloading. |
| **Slivers-First Viewport Layout** | [flutter-ui-slivers](../../presentation/ui/flutter-ui-slivers/SKILL.md) | `CustomScrollView`, pinned headers, avoiding `shrinkWrap: true`. |
| **Motion & Animation Choreography** | [flutter-ui-animations](../../presentation/ui/flutter-ui-animations/SKILL.md) | Explicit vs implicit animation tiers, controller disposal. |

---

## 3. Profiling & Diagnostics with Flutter DevTools

> [!IMPORTANT]
> **Golden Rule of Performance Profiling:**
> NEVER measure performance in **Debug mode** (`flutter run`). Debug mode introduces JIT compilation, assertion overheads, and debugging hooks that distort frame times.
> ALWAYS profile in **Profile mode** on a physical device:
> ```bash
> flutter run --profile --flavor dev --dart-define-from-file=config/env_dev.json
> ```

### 3.1 Key DevTools Performance Tabs & Flags

1. **Performance View (Flame Chart):**
   - **UI Thread Time:** Measures widget construction, layout calculations, and paint command recording. If >16ms, optimize `build()` or offload to Isolates.
   - **Raster (GPU) Thread Time:** Measures actual GPU rendering and Skia/Impeller rasterization. If >16ms, check for `saveLayer()`, heavy clipping, or missing `RepaintBoundary`.

2. **Track Widget Rebuilds:**
   - Enable **"Track widget rebuilds"** in DevTools to identify which widgets are unexpectedly rebuilding when state changes.

3. **Highlight Repaints:**
   - Enable **"Highlight repaints"** to visualize with rainbow borders which sections of the screen are repainting on each frame. Static elements should NEVER flash borders during localized animations.

---

## 4. MCP Tooling & Accelerated Profiling Workflows

Antigravity IDE provides direct programmatic access to Dart runtime daemons and VM services via MCP tools:

| MCP Tool | Capability | Performance Diagnostic Flow |
| :--- | :--- | :--- |
| `vm_service` | Dart VM RPC integration | Inspect isolate memory allocations, garbage collection pauses, and CPU timeline events. |
| `widget_inspector` | Live widget tree introspection | Identify deep widget hierarchies, inspect constraints, and verify render object boundaries. |
| `hot_reload` | Sub-second code updates | Instantly test performance refactors (e.g. adding `RepaintBoundary` or `const`) without app reboots. |

For a complete guide on available IDE tools, refer to the [mcp-tooling-hub](../../tooling/mcp-tooling-hub/SKILL.md).

---

## 5. Performance Laws & Standards

1. **Zero Heavy Work in `build()`:** No sorting, filtering of large collections, JSON decoding, or async futures initiated inside `build()`.
2. **Mandatory `const` Usage:** Maximize `const` widget constructors to short-circuit subtree re-evaluation.
3. **Strict Widget Decomposition:** Break large widget trees into focused `StatelessWidget` classes. Helper methods (`Widget _buildX()`) are strictly forbidden.
4. **Targeted State Selection:** Use `BlocSelector` or `BlocBuilder(buildWhen:)` to constrain rebuilds to the smallest possible leaf widgets.
5. **No `Opacity` in Animations:** Animate opacity using `FadeTransition` or `AnimatedOpacity`, never the `Opacity` widget.
6. **Lazy Scrollable Views:** Use `itemExtent` or `prototypeItem` on all uniform lists to eliminate per-item layout measurements.

---

## 6. Performance Verification Checklist

- [ ] App tested on physical device in `--profile` mode.
- [ ] UI thread frame time remains under 16ms (60 FPS) / 8ms (120 FPS).
- [ ] Raster thread frame time remains under 16ms / 8ms without GPU spikes.
- [ ] "Highlight Repaints" verifies static screen areas do not repaint during animations.
- [ ] "Track Widget Rebuilds" confirms only targeted leaf widgets rebuild upon state events.
