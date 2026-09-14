---
name: flutter-ui-utils-helpers
description: Standards for system UI and presentation helper utilities in lib/presentation/ui_utils/helpers/. Covers HapticFeedbackHelper, SystemUiOverlayHelper, soft keyboard dismissers, and clipboard helpers.
---

# Flutter UI & System Helpers

## 1. Overview & When to Apply

Use this skill whenever:
- Implementing UI platform helpers (e.g. `HapticFeedbackHelper`, `SystemUiOverlayHelper`, `KeyboardHelper`, `ClipboardHelper`).
- Managing Android/iOS status bar and navigation bar styles dynamically per route.
- Standardizing haptic feedback responses across buttons, selections, and error states.
- Organizing presentation utility classes in `lib/presentation/ui_utils/helpers/`.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [flutter-ui-utils-hub](../flutter-ui-utils-hub/SKILL.md) | UI Utils architecture and directory boundaries. |
| **Parent UI Coordinator** | [flutter-ui-hub](../../ui/flutter-ui-hub/SKILL.md) | Presentation layer architectural laws and sensory polish. |
| **Theming System** | [flutter-ui-theme-hub](../../theme/flutter-ui-theme-hub/SKILL.md) | Synchronizing system status bar brightness with active theme. |

---

## 3. Directory Standard for UI Helpers

All UI-level system and platform helpers reside in `lib/presentation/ui_utils/helpers/`:

```text
lib/presentation/ui_utils/helpers/
├── haptic_feedback_helper.dart
├── system_ui_overlay_helper.dart
├── keyboard_helper.dart
└── clipboard_helper.dart
```

---

## 4. Standard Implementation Patterns

### 4.1 Haptic Feedback Helper (`haptic_feedback_helper.dart`)

Centralize sensory feedback to ensure consistent tactile response across the application:

```dart
import 'package:flutter/services.dart';

abstract final class HapticFeedbackHelper {
  /// Subtle feedback on button tap, toggle switch, or chip selection.
  static Future<void> light() => HapticFeedback.lightImpact();

  /// Medium feedback on drawer open, tab switch, or pull-to-refresh trigger.
  static Future<void> medium() => HapticFeedback.mediumImpact();

  /// Strong feedback on destructive action confirmation or long-press.
  static Future<void> heavy() => HapticFeedback.heavyImpact();

  /// Feedback on form validation error or failed operation.
  static Future<void> error() => HapticFeedback.vibrate();

  /// Feedback on successful operation completion.
  static Future<void> success() => HapticFeedback.selectionClick();
}
```

---

### 4.2 System UI Overlay Helper (`system_ui_overlay_helper.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class SystemUiOverlayHelper {
  /// Sets transparent status and navigation bars with dynamic icon brightness.
  static void setSystemUiStyle({required bool isDark}) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  /// Sets full-screen immersive mode for media or onboarding.
  static void setImmersiveMode({required bool enabled}) {
    if (enabled) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    }
  }
}
```

---

### 4.3 Soft Keyboard Helper (`keyboard_helper.dart`)

```dart
import 'package:flutter/material.dart';

abstract final class KeyboardHelper {
  /// Safely unfocuses active input and hides the soft keyboard.
  static void hideKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }
}
```

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Hardcoding `HapticFeedback.vibrate()` haphazardly across random widgets | **MEDIUM** | Use typed methods via `HapticFeedbackHelper`. |
| Modifying system UI overlays inside build methods | **HIGH** | Set overlay styles in `initState`, route listeners, or theme bootstrap. |
| Placing device hardware interactions (e.g. camera, sensors) in `ui_utils` | **CRITICAL** | Device hardware services belong to the Infrastructure layer with Domain interfaces. |

---

## 6. Verification Checklist

- [ ] Helpers reside in `lib/presentation/ui_utils/helpers/`.
- [ ] Helpers only interact with Flutter UI framework or platform channel UI APIs (`HapticFeedback`, `SystemChrome`).
- [ ] No stateful memory leaks or unbound listeners.
- [ ] Classes use `abstract final` or private constructors to prevent unnecessary instantiation.
