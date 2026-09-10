---
name: flutter-ui-hub
description: Primary coordinator and architecture guide for Flutter UI development. Use when designing, creating, refactoring, or auditing UI widgets, pages, layouts, and animations. Serves as the central entry point and routes to specialized sub-skills for widgets, performance, theming, slivers, responsiveness, and motion design.
---

# Flutter UI Coordinator & Architecture Hub

## 1. Overview & Presentation Layer Laws

This skill serves as the central root coordinator for all UI development within the project. It enforces Clean Architecture presentation boundaries, component decomposition rules, and routes tasks to specialized UI sub-skills.

### Core Presentation Rules (per `AGENTS.md`):
1. **Strict Line Limits:** Keep widget and screen files strictly within **150–200 lines**.
2. **Zero Helper Builder Methods:** Strictly **DISALLOW** helper builder methods (e.g., `Widget _buildHeader()`). Always extract subtrees into standalone `StatelessWidget` classes inside `widgets/` or `parts/` to preserve element tree diffing efficiency.
3. **No Direct Hardcoded Values:** Strictly **NO** raw `Color(0x...)` or static `AppColors` directly in widgets. ALL colors must come from `context.colorScheme` or `context.customColors` (`ThemeExtension`).
4. **Clean Architecture Boundary:** UI Widgets MUST ONLY interact with BLoCs/Cubits via Events (`context.read<Bloc>().add(Event())`). UI must never call Repositories, Data Sources, or Analytics SDKs directly.
5. **Stateful vs Stateless:** Prefer `StatelessWidget` wherever possible. Use `StatefulWidget` strictly for local ephemeral UI state (e.g., `AnimationController`, `FocusNode`, `ScrollController`, `TextEditingController`).

---

## 2. UI Skill Tree & Routing Matrix

Use this matrix to navigate to the specialized sub-skill matching your specific UI task:

| **UI Kit Architecture** | [flutter-ui-kit-hub](../ui_kit/flutter-ui-kit-hub/SKILL.md) | Pure decoupled components in `lib/presentation/ui_kit/`, buttons, cards, modals, badges. |
| **Widget Previews** | [flutter-ui-kit-preview](../ui_kit/flutter-ui-kit-preview/SKILL.md) | `@Preview` decorators, `PreviewWrapper`, isolated component verification in IDE/web-runner. |
| **Reactive Forms Core** | [flutter-ui-forms-reactive](../forms/flutter-ui-forms-reactive/SKILL.md) | Strongly-typed `reactive_forms`, `FormGroup`, `FormControl`, cross-field validation, async debounce. |
| **Custom Form Controls** | [flutter-ui-forms-custom-controls](../forms/flutter-ui-forms-custom-controls/SKILL.md) | `ControlValueAccessor`, custom chips, date pickers, masks, and stylized reactive inputs. |
| **Theming System** | [flutter-ui-theme-hub](../theme/flutter-ui-theme-hub/SKILL.md) | Modular theme architecture (`app_theme.dart`, `app_color_scheme.dart`, `app_text_theme.dart`, `app_custom_colors.dart`). |
| **Material 3 Components** | [flutter-ui-material](../flutter-ui-material/SKILL.md) | Material 3 components (`FilledButton`, `Card`, `SegmentedButton`, `NavigationBar`, `InputDecoration`). |
| **Theme Generator** | [create-theme](../../create-theme/SKILL.md) | Scaffolding new themes and boilerplate via `/create-theme`. |
| **Widget Architecture** | [flutter-ui-stateless-stateful](../flutter-ui-stateless-stateful/SKILL.md) | Choosing between Stateless/Stateful, element tree diffing, local state vs BLoC, lifecycle (`initState`, `dispose`). |
| **Rendering Performance** | [flutter-ui-performance](../flutter-ui-performance/SKILL.md) | Optimizing 60/120 FPS, `const` constructors, `RepaintBoundary`, avoiding rebuild churn, `BlocSelector`. |
| **Responsive & Desktop** | [flutter-ui-responsive-adaptive](../flutter-ui-responsive-adaptive/SKILL.md) | Breakpoints (Mobile `<600`, Tablet `600-1024`, Desktop `>=1024`), `MediaQuery.sizeOf`, hover, keyboard shortcuts, scrollbars. |
| **iOS / Cupertino UX** | [flutter-ui-cupertino](../flutter-ui-cupertino/SKILL.md) | iOS design conventions, `CupertinoNavigationBar`, `CupertinoActionSheet`, haptics, swipe-to-dismiss, adaptive widgets. |
| **Slivers & Scrolling** | [flutter-ui-slivers](../flutter-ui-slivers/SKILL.md) | `CustomScrollView`, `SliverAppBar`, `SliverList.builder`, `SliverGrid`, lazy building, nested scrolling. |
| **Animations (Tiers 1 & 2)** | [flutter-ui-animations](../flutter-ui-animations/SKILL.md) | Implicit animations (`AnimatedContainer`, `AnimatedSwitcher`), explicit controllers (`CurvedAnimation`, staggered motion). |
| **Advanced Graphics (Tiers 3 & 4)** | [flutter-ui-advanced-graphics](../flutter-ui-advanced-graphics/SKILL.md) | `CustomPainter`, `Canvas`/`Path` drawing, shader masks, physics spring simulations, Rive/Lottie integration. |

---

## 3. Presentation Architecture Directory Standard

Structure feature UI directories strictly following this layout:

```text
lib/presentation/
├── pages/
│   └── <feature>/
│       ├── <feature>_page.dart         # Main entry page with Scaffold / BlocProvider (<200 lines)
│       └── widgets/                    # Decomposed sub-widgets (<150 lines each)
│           ├── <feature>_header.dart
│           ├── <feature>_content_body.dart
│           └── <feature>_action_bar.dart
├── ui_kit/                             # Pure, reusable design system components
│   ├── buttons/
│   ├── cards/
│   └── inputs/
└── ui_utils/
    ├── extensions/                     # UI BuildContext extensions (context.colorScheme, etc.)
    └── assets/                         # Generated assets via flutter_gen
```

---

## 4. UI Advisor Guidelines (`project-advisor` & `feature-enhancement-advisor`)

Every completed screen or widget must adhere to these product & completeness standards:

1. **Standard 4-State UI Contract:**
   - **Loading:** Skeleton shimmer or adaptive spinner.
   - **Empty:** Clear graphic, explanatory text, and primary CTA button.
   - **Error:** User-friendly message, no raw stack traces, and a retry button.
   - **Content:** Main populated data state with pull-to-refresh where applicable.
2. **Keyboard Ergonomics:** Forms must support automatic dismiss on tap outside (`unfocusWrapper()`) and submit via keyboard actions.
3. **Sensory & Visual Polish:** Trigger subtle haptics (`HapticFeedback.lightImpact()`) on primary user actions and provide smooth state transitions.

---

## 5. Master UI Verification Checklist

Before completing any UI task:
- [ ] File size is strictly under 150–200 lines.
- [ ] No private helper methods returning `Widget` exist (`Widget _buildX()`).
- [ ] Colors and styles are strictly retrieved via `context.colorScheme`, `context.textTheme`, or `context.customColors`.
- [ ] Component adapts cleanly across Mobile, Tablet, and Desktop breakpoints.
- [ ] Reusable UI Kit components are covered by `@Preview` annotations (Light & Dark).
- [ ] Animations cleanly dispose `AnimationController` resources without frame drops.
