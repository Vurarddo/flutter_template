---
name: flutter-widget-preview
description: Implements real-time widget previews using package:flutter/widget_previews.dart and @Preview annotation. Enforces zero side-effects (no native APIs, no network), mandatory Light/Dark dual testing, explicit viewport sizing, ThemeExtension support, and state-matrix preview patterns. Use when creating UI Kit components, building isolated feature widgets, or setting up visual preview decorators.
---

# Flutter Widget Preview (@Preview) Expert Skill

## When to Apply

Use this skill whenever creating new UI Kit components (`lib/presentation/ui_kit/`), designing feature widgets, adding `@Preview` annotations, or setting up component matrices for visual regression and designer review.

---

## Technical Constraints & Web-Runner Limitations

Because Flutter Widget Previewer executes preview functions inside a constrained web-based compilation environment:

1. **Zero Native APIs (`dart:io` / `dart:ffi`):**
   - **STRICTLY PROHIBITED:** Invoking `dart:io` (File, Directory, Platform) or `dart:ffi` inside previewed code paths.
   - If a widget depends on native plugins, isolate them behind abstract interfaces and pass mock implementations.
2. **Zero Live Network Calls:**
   - Do NOT execute active Dio/Retrofit requests inside previews. Always supply static mock entities (`*.mock()`) or DTOs.
3. **Asset Path Safety:**
   - Use package-based asset resolvers (`package:your_app/assets/...`) where local relative paths fail under mock web servers.

---

## Core Rules for Widget Previews

1. **Mandatory Dual-Theme Rendering (Light & Dark):**
   - EVERY UI component MUST provide previews for both **Light** and **Dark** themes to verify text contrast and custom `ThemeExtension` tokens (`context.customColors`).
2. **Inherited Context Safety (`PreviewWrapper`):**
   - Preview functions MUST wrap target widgets in a standardized `PreviewWrapper` supplying `MaterialApp`, `Theme`, `Scaffold`, and text directionality.
3. **100% UI Kit Coverage:**
   - Every reusable widget in `lib/presentation/ui_kit/` MUST have an accompanying `@Preview` definition.

---

## Standard Preview Wrapper Component

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

## Standard Implementation Patterns

### 1. Atomic UI Kit Component Preview (Light & Dark)

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

### 2. State-Variant Matrix Preview

When previewing complex widgets, display all operational states (Content, Loading, Error) side-by-side:

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

---

## Anti-Patterns (Strictly Prohibited)

| Anti-Pattern                                                  | Severity     | Corrective Action                                                     |
| ------------------------------------------------------------- | ------------ | --------------------------------------------------------------------- |
| Direct imports of `dart:io` or `dart:ffi` in previewed paths  | **CRITICAL** | Abstract native calls behind interfaces; pass pure Dart mocks.        |
| Initializing Dio/Retrofit/BLoCs inside preview builder        | **CRITICAL** | Pass static data props or mock BLoC states directly.                  |
| Rendering `@Preview` without `PreviewWrapper` / `MaterialApp` | **HIGH**     | Wrap widget in `PreviewWrapper` to supply Theme/Scaffold bounds.      |
| Hardcoding hex colors (`Color(0xFF...)`) in preview code      | **HIGH**     | Test colors via `Theme.of(context)` tokens to verify theme switching. |
| Unconstrained preview dimensions causing layout explosion     | **MEDIUM**   | Supply `size: Size(width, height)` parameter inside `@Preview`.       |

---

## Agent Verification Checklist

When generating or auditing `@Preview` implementations:

1. **Import Verification:** Ensure `import 'package:flutter/widget_previews.dart';` is present.

2. **Parameter-Free Builder:** Ensure `@Preview` is attached to top-level, parameter-free builder functions.

3. **No Native Dependencies:** Verify zero references to `dart:io` or `dart:ffi` in preview execution paths.

4. **Dual Theme Test:** Verify both `Brightness.light` and `Brightness.dark` preview cases exist.
5. **Wrapper Protection:** Ensure all previewed widgets are enclosed within `PreviewWrapper` or `MaterialApp`.
