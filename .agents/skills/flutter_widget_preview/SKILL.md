---
name: flutter-widget-preview
description: Implements real-time widget previews using package:flutter/widget_previews.dart and @Preview annotation. Enforces zero side-effects (no native APIs, no network), mandatory Light/Dark dual testing, PreviewWrapper encapsulation, explicit viewport sizing, MultiPreview transformations, and state-matrix preview patterns. Use when creating UI Kit components, building isolated feature widgets, or setting up visual preview decorators.
---

# Flutter Widget Preview (@Preview) Expert Skill

## 1. Overview & When to Apply

Use this skill whenever:
- Creating new UI Kit components (`lib/presentation/ui_kit/`).
- Building isolated presentation widgets or feature components.
- Adding `@Preview` annotations and preview builder functions.
- Setting up component state matrices (Content, Loading, Error) for designer review.
- Running and debugging widget previews in IDE or CLI.

---

## 2. Technical Constraints & Web-Runner Limitations

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

## 3. Core Rules for Widget Previews

1. **100% UI Kit Coverage:**
   - Every reusable widget in `lib/presentation/ui_kit/` MUST have an accompanying `@Preview` definition.
2. **Mandatory Dual-Theme Rendering (Light & Dark):**
   - EVERY UI component MUST provide previews for both **Light** and **Dark** themes to verify text contrast and custom `ThemeExtension` tokens (`context.customColors`).
3. **Inherited Context Safety (`PreviewWrapper`):**
   - Preview functions MUST wrap target widgets in a standardized `PreviewWrapper` supplying `MaterialApp`, `Theme`, `Scaffold`, and text directionality.

---

## 4. Standard Preview Wrapper Component

```dart
import 'package:flutter/material.dart';

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

class CustomCard extends StatelessWidget {
  final String title;
  final bool isActive;

  const CustomCard({
    super.key,
    required this.title,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}

// =============================================================================
// PREVIEWS
// =============================================================================

@Preview(
  name: 'Custom Card - Light',
  size: Size(375, 120),
)
Widget previewCustomCardLight() {
  return const PreviewWrapper(
    brightness: Brightness.light,
    child: CustomCard(
      title: 'Active Subscription',
      isActive: true,
    ),
  );
}

@Preview(
  name: 'Custom Card - Dark',
  size: Size(375, 120),
)
Widget previewCustomCardDark() {
  return const PreviewWrapper(
    brightness: Brightness.dark,
    child: CustomCard(
      title: 'Active Subscription',
      isActive: true,
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
          FeatureCard(data: 'Mock Data Content'),
          SizedBox(height: 16),
          Text('LOADING STATE:', style: TextStyle(color: Colors.grey)),
          FeatureCardLoading(),
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

/// Creates light and dark mode previews automatically.
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

// Usage with a self-contained component:
@MultiBrightnessPreview(name: 'Primary Card')
Widget previewPrimaryCard() => const PreviewWrapper(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Content'),
        ),
      ),
    );
```

---

## 6. Workflows: Interacting with Previews

### 6.1 Launching Previews

- **Inside IDE (VS Code / Android Studio / IntelliJ with Flutter 3.38+):**
  1. Open the "Flutter Widget Preview" sidebar tab.
  2. The previewer launches automatically.
  3. Toggle "Filter previews by selected file" to focus on the active file.

- **Via Command Line:**
  1. In the project root, run:
     ```bash
     flutter widget-preview start
     ```
  2. Interact with the rendered widgets in the browser environment.

### 6.2 Hot Reload & Hot Restart Feedback Loop

1. Modify widget code or `@Preview` parameters.
2. Changes hot reload automatically in the preview canvas.
3. If global state/static initializers were altered: trigger **Global Hot Restart** (bottom right).
4. If only a single preview card needs resetting: click **Card Hot Restart** on that specific preview.

---

## 7. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Direct imports of `dart:io` or `dart:ffi` in previewed paths | **CRITICAL** | Abstract native calls behind interfaces; pass pure Dart mocks. |
| Initializing Dio/Retrofit/BLoCs inside preview builder | **CRITICAL** | Pass static data props or mock BLoC states directly. |
| Rendering `@Preview` without `PreviewWrapper` / `MaterialApp` | **HIGH** | Wrap widget in `PreviewWrapper` to supply Theme/Scaffold bounds. |
| Hardcoding hex colors (`Color(0xFF...)`) in preview code | **HIGH** | Test colors via `Theme.of(context)` / `context.colorScheme` tokens. |
| Unconstrained preview dimensions causing layout explosion | **MEDIUM** | Supply `size: Size(width, height)` parameter inside `@Preview`. |
| Missing Dark theme preview variant | **MEDIUM** | Provide dual light/dark preview functions or use `@MultiBrightnessPreview`. |

---

## 8. Agent Verification Checklist

When generating or auditing `@Preview` implementations:

- [ ] **Import Verification:** Ensure `import 'package:flutter/widget_previews.dart';` is present.
- [ ] **Top-Level Function:** Ensure `@Preview` is attached to a top-level, parameter-free builder function or valid static constructor.
- [ ] **Zero Native / Network Dependencies:** Verify zero references to `dart:io`, `dart:ffi`, Dio, or Retrofit in preview execution paths.
- [ ] **Dual-Theme Coverage:** Verify both `Brightness.light` and `Brightness.dark` preview cases exist.
- [ ] **PreviewWrapper Safety:** Ensure all previewed widgets are enclosed within `PreviewWrapper` (providing `MaterialApp`, `Scaffold`, and `AppTheme`).
- [ ] **Sizing Constraints:** Ensure fixed or bounded viewport size (`size: Size(w, h)`) is specified for unconstrained widgets.
