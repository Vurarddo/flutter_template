---
name: flutter-ui-cupertino
description: iOS Human Interface Guidelines & Cupertino widget implementation skill. Enforces native iOS design patterns, CupertinoActionSheet, CupertinoNavigationBar, CupertinoPicker, HapticFeedback integration, smooth modal presentation, swipe-to-back gestures, and adaptive platform widgets. Use when building iOS-specific or platform-adaptive UI features.
---

# iOS / Cupertino & Adaptive Platform UI Guide

## 1. Overview & When to Apply

Use this skill whenever:
- Designing iOS-centric or platform-adaptive user experiences adhering to Apple Human Interface Guidelines (HIG).
- Implementing Cupertino components (`CupertinoNavigationBar`, `CupertinoActionSheet`, `CupertinoPicker`, `CupertinoSegmentedControl`, `CupertinoSlidingSegmentedControl`).
- Integrating sensory touch feedback using `HapticFeedback` on iOS/Android user actions.
- Implementing native modal bottom sheets, swipe-to-dismiss, and iOS back swipe gestures (`CupertinoPageRoute`).
- Using Flutter's adaptive constructor patterns (`Switch.adaptive`, `CircularProgressIndicator.adaptive`, `Slider.adaptive`).

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [flutter-ui-hub](../flutter-ui-hub/SKILL.md) | Presentation laws and UI routing. |
| **Material 3** | [flutter-ui-material](../flutter-ui-material/SKILL.md) | Material 3 token counterpart. |
| **Responsive** | [flutter-ui-responsive-adaptive](../flutter-ui-responsive-adaptive/SKILL.md) | Adaptive multi-platform shells. |

---

## 3. Core iOS & Cupertino Patterns

### 3.1 Native iOS Action Sheet with Haptics

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

Future<void> showAppActionSheet(BuildContext context, {required VoidCallback onDelete}) async {
  await HapticFeedback.mediumImpact(); // Sensory feedback upon sheet opening

  if (!context.mounted) return;

  await showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      title: const Text('Manage Item'),
      message: const Text('Select an action for this item.'),
      actions: <CupertinoActionSheetAction>[
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            // Handle edit
          },
          child: const Text('Edit'),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
            HapticFeedback.heavyImpact();
            onDelete();
          },
          child: const Text('Delete'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        isDefaultAction: true,
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
    ),
  );
}
```

### 3.2 Adaptive Platform Widgets

Prefer standard `.adaptive()` constructors over manual `Platform.isIOS` `if/else` checks:

```dart
class AdaptiveSettingsTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const AdaptiveSettingsTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Switch.adaptive(
        value: value,
        onChanged: (val) {
          HapticFeedback.selectionClick();
          onChanged(val);
        },
      ),
    );
  }
}
```

---

## 4. Haptic Feedback Integration Standard

| Action Type | Recommended Haptic Method |
| :--- | :--- |
| Toggle switch / Segmented tab change | `HapticFeedback.selectionClick()` |
| Button tap / List item selection | `HapticFeedback.lightImpact()` |
| Dialog / Modal confirmation opening | `HapticFeedback.mediumImpact()` |
| Destructive action (Delete / Disconnect) | `HapticFeedback.heavyImpact()` |
| Failure / Validation error | `HapticFeedback.vibrate()` |

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Hardcoding Android-only `MaterialPageRoute` for iOS navigation | **HIGH** | Use `auto_route` adaptive route configuration or `CupertinoPageRoute`. |
| Missing haptics on destructive or significant modal actions | **MEDIUM** | Trigger `HapticFeedback.lightImpact()` or `heavyImpact()`. |
| Mixing Cupertino and Material styles haphazardly on the same screen | **MEDIUM** | Stick to a consistent theme or utilize `.adaptive()` constructors. |

---

## 6. Verification Checklist

- [ ] Interactive toggles and sliders utilize `.adaptive()` variants or appropriate haptics.
- [ ] Action sheets and modal popups include Cancel buttons and proper destructive action styling.
- [ ] Sensory touch feedback (`HapticFeedback`) is used purposefully on user actions.
- [ ] iOS swipe-to-back gesture works reliably in navigation stacks.
