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
| **Theming System** | [flutter-ui-theme-hub](../../theme/flutter-ui-theme-hub/SKILL.md) | Light and Dark ThemeData providers. |

---

## 3. Technical Constraints & Web-Runner Limitations

Because Flutter Widget Previewer executes preview functions inside a constrained web-based compilation environment:

1. **Zero Native APIs (`dart:io` / `dart:ffi`):**
   - **STRICTLY PROHIBITED:** Invoking `dart:io` (`File`, `Directory`, `Platform`) or `dart:ffi` inside previewed code paths.
   - If a widget depends on native plugins, isolate them behind abstract interfaces and pass mock implementations.
2. **Zero Live Network Calls:**
   - Do NOT execute active Dio/Retrofit requests inside previews. Always supply static mock entities (`*.mock()`) or static DTOs.
3. **Asset Path Safety:**
   - Use package-based asset resolvers (`packages/<app_package_name>/assets/...` or `package:your_app/assets/...`) where local relative paths fail under mock web servers.
4. **Target Function Requirements:**
   - Apply `@Preview` only to top-level functions, static methods within a class, or public constructors/factories that have no required parameters and return a `Widget` or `WidgetBuilder`. All callback arguments in annotations must be public and `const`.
5. **Explicit Viewport Sizing:**
   - Always supply explicit constraints (`size: Size(width, height)`) in `@Preview` for unconstrained widgets to prevent viewport explosion.

---

## 4. Standard Preview Wrapper Component

```dart
import 'package:flutter/material.dart';
import 'package:flutter_template/presentation/theme/app_theme.dart';

/// Standard container providing MaterialApp context, theme, and scaffold for @Preview functions.
class PreviewWrapper extends StatelessWidget {
  final Widget child;
  final Brightness brightness;
  final String? title;

  const PreviewWrapper({
    super.key,
    required this.child,
    this.brightness = Brightness.light,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: brightness == Brightness.light ? AppTheme.light : AppTheme.dark,
      home: Scaffold(
        appBar: title != null ? AppBar(title: Text(title!)) : null,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    );
  }
}
```

---

## 5. Implementation Patterns

### 5.1 Atomic UI Kit Component Preview (Light & Dark)

```dart
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

// =============================================================================
// PREVIEWS
// =============================================================================

@Preview(
  name: 'Custom Badge - Light',
  size: Size(200, 80),
)
Widget previewCustomBadgeLight() {
  return const PreviewWrapper(
    brightness: Brightness.light,
    child: AppBadge(
      label: 'Active Plan',
      variant: AppBadgeVariant.success,
    ),
  );
}

@Preview(
  name: 'Custom Badge - Dark',
  size: Size(200, 80),
)
Widget previewCustomBadgeDark() {
  return const PreviewWrapper(
    brightness: Brightness.dark,
    child: AppBadge(
      label: 'Active Plan',
      variant: AppBadgeVariant.success,
    ),
  );
}
```

### 5.2 State-Variant Matrix Preview

When previewing complex widgets, display all operational states (Content, Loading, Error) side-by-side in a single scrollable matrix:

```dart
@Preview(
  name: 'Feature States Matrix',
  size: Size(400, 600),
)
Widget previewFeatureStatesMatrix() {
  return PreviewWrapper(
    brightness: Brightness.dark,
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          Text('CONTENT STATE:', style: TextStyle(color: Colors.grey)),
          FeatureCard(title: 'Active Card', description: 'Content loaded successfully'),
          SizedBox(height: 16),
          Text('LOADING STATE:', style: TextStyle(color: Colors.grey)),
          FeatureCardShimmer(),
          SizedBox(height: 16),
          Text('ERROR STATE:', style: TextStyle(color: Colors.grey)),
          FeatureCardError(message: 'Failed to sync data'),
        ],
      ),
    ),
  );
}
```

### 5.3 Advanced: Custom MultiPreview Annotations

To automatically generate multi-configuration previews (e.g. Light + Dark modes) in a single annotation, extend `MultiPreview`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

final class MultiBrightnessPreview extends MultiPreview {
  const MultiBrightnessPreview({required this.name});

  final String name;

  @override
  List<Preview> get previews => const [
        Preview(brightness: Brightness.light),
        Preview(brightness: Brightness.dark),
      ];

  @override
  List<Preview> transform() {
    final previews = super.transform();
    return previews.map((preview) {
      final builder = preview.toBuilder()
        ..group = 'Brightness'
        ..name = '$name - ${preview.brightness!.name}';
      return builder.toPreview();
    }).toList();
  }
}
```

---

## 6. Workflows: Interacting with Previews

### 6.1 Launching Previews
- **Inside IDE (VS Code / Android Studio / IntelliJ with Flutter 3.38+):**
  1. Open the "Flutter Widget Preview" sidebar tab.
  2. Toggle "Filter previews by selected file" to focus on the active file.
- **Via Command Line:**
  ```bash
  flutter widget-preview start
  ```

### 6.2 Hot Reload Feedback Loop
1. Modify widget code or `@Preview` parameters.
2. Changes hot reload automatically in the preview canvas.
3. If global state was altered: trigger **Global Hot Restart**.

---

## 7. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Direct imports of `dart:io` or `dart:ffi` in previewed paths | **CRITICAL** | Abstract native calls behind interfaces; pass pure Dart mocks. |
| Initializing Dio/Retrofit/BLoCs inside preview builder | **CRITICAL** | Pass static data props or mock BLoC states directly. |
| Rendering `@Preview` without `PreviewWrapper` / `MaterialApp` | **HIGH** | Wrap widget in `PreviewWrapper` to supply Theme/Scaffold bounds. |
| Hardcoding hex colors (`Color(0xFF...)`) in preview code | **HIGH** | Test colors via `context.colorScheme` / `context.customColors` tokens. |
| Missing Dark theme preview variant | **MEDIUM** | Provide dual light/dark preview functions or use `@MultiBrightnessPreview`. |

---

## 8. Verification Checklist

- [ ] Import `package:flutter/widget_previews.dart` is present.
- [ ] `@Preview` is attached to a top-level, parameter-free builder function.
- [ ] Zero references to `dart:io`, `dart:ffi`, Dio, or Retrofit in preview execution paths.
- [ ] Both `Brightness.light` and `Brightness.dark` preview cases exist.
- [ ] Previewed widgets are enclosed within `PreviewWrapper`.
- [ ] Explicit viewport size (`size: Size(w, h)`) is specified for unconstrained widgets.
