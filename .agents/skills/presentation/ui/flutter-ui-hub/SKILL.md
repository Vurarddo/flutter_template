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

| **Core Hub** | [core-hub](../../../core/core-hub/SKILL.md) | Central coordinator for pure Dart foundations, extensions, and utilities. |
| **Domain Hub** | [domain-hub](../../../domain/domain-hub/SKILL.md) | Central coordinator for business entities, UseCases, repository contracts, and failures. |
| **Data Hub** | [data-hub](../../../data/data-hub/SKILL.md) | Central coordinator for DTOs, inline toDomain() mappers, Retrofit clients, and repositories. |
| **Infrastructure Hub** | [infrastructure-hub](../../../infrastructure/infrastructure-hub/SKILL.md) | Central coordinator for external SDKs, network, storage, DI, and platform services. |
| **Navigation Hub** | [flutter-auto-route-hub](../../navigation/flutter-auto-route-hub/SKILL.md) | Central coordinator for AutoRoute type-safe navigation and deep links. |
| **AutoRoute Core** | [flutter-auto-route-core](../../navigation/flutter-auto-route-core/SKILL.md) | `@AutoRouterConfig`, `@RoutePage`, `push`/`replace`/`pop`, `@pathParam`, parameters. |
| **Nested Tabs & Shells** | [flutter-auto-route-nested-tabs](../../navigation/flutter-auto-route-nested-tabs/SKILL.md) | `AutoTabsRouter`, `AutoTabsScaffold`, persistent tabs, `popUntilRoot`. |
| **State Management Hub** | [flutter-bloc-hub](../../state-management/flutter-bloc-hub/SKILL.md) | Central coordinator for BLoC/Cubit state management architecture. |
| **BLoC UI Widgets & Scoping** | [flutter-bloc-widgets](../../state-management/flutter-bloc-widgets/SKILL.md) | `BlocBuilder`, `BlocListener`, `BlocConsumer`, `BlocSelector`, `BlocProvider` vs `BlocProvider.value`. |
| **BLoC & Cubit Core Logic** | [flutter-bloc-core](../../state-management/flutter-bloc-core/SKILL.md) | BLoC vs Cubit decision, sealed events/states, `bloc_concurrency`, async safety. |
| **UI Utils Hub** | [flutter-ui-utils-hub](../../ui-utils/flutter-ui-utils-hub/SKILL.md) | Central coordinator for UI extensions, formatters, reactive form accessors, and helpers in `lib/presentation/ui_utils/`. |
| **UI Context Extensions** | [flutter-ui-utils-extensions](../../ui-utils/flutter-ui-utils-extensions/SKILL.md) | `BuildContext` helpers (`context.colorScheme`, `context.textTheme`, `context.customColors`, `isDark`, media queries). |
| **Input Formatters** | [flutter-ui-utils-formatters](../../ui-utils/flutter-ui-utils-formatters/SKILL.md) | `TextInputFormatter` classes (card numbers, phone masks, currency, uppercase transform). |
| **Reactive Form Accessors** | [flutter-ui-utils-forms](../../ui-utils/flutter-ui-utils-forms/SKILL.md) | `ControlValueAccessor` implementations and UI form scroll/focus helpers. |
| **System UI Helpers** | [flutter-ui-utils-helpers](../../ui-utils/flutter-ui-utils-helpers/SKILL.md) | `HapticFeedbackHelper`, `SystemUiOverlayHelper`, keyboard unfocusing, and clipboard tools. |
| **UI Kit Architecture** | [flutter-ui-kit-hub](../ui-kit/flutter-ui-kit-hub/SKILL.md) | Pure decoupled components in `lib/presentation/ui_kit/`, buttons, cards, modals, badges. |
| **Widget Previews** | [flutter-ui-kit-preview](../ui-kit/flutter-ui-kit-preview/SKILL.md) | `@Preview` decorators, `PreviewWrapper`, isolated component verification in IDE/web-runner. |
| **Reactive Forms Core** | [flutter-ui-forms-reactive](../forms/flutter-ui-forms-reactive/SKILL.md) | Strongly-typed `reactive_forms`, `FormGroup`, `FormControl`, cross-field validation, async debounce. |
| **Custom Form Controls** | [flutter-ui-forms-custom-controls](../forms/flutter-ui-forms-custom-controls/SKILL.md) | `ControlValueAccessor`, custom chips, date pickers, masks, and stylized reactive inputs. |
| **Theming System** | [flutter-ui-theme-hub](../../theme/flutter-ui-theme-hub/SKILL.md) | Modular theme architecture (`app_theme.dart`, `app_color_scheme.dart`, `app_text_theme.dart`, `app_custom_colors.dart`). |
| **Material 3 Components** | [flutter-ui-material](../flutter-ui-material/SKILL.md) | Material 3 components (`FilledButton`, `Card`, `SegmentedButton`, `NavigationBar`, `InputDecoration`). |
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
    ├── assets/                         # Generated assets via flutter_gen
    ├── extensions/                     # UI BuildContext & Widget extensions (context.colorScheme, unfocusWrapper, etc.)
    ├── formatters/                     # TextInputFormatters (card, phone, currency)
    ├── forms/                          # Reactive Forms UI adapters & ControlValueAccessors
    └── helpers/                        # System UI helpers (haptics, overlays, keyboard)
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

## 5. MCP Tooling & Accelerated UI Iteration

Leverage IDE-integrated MCP tools during UI development cycles:
- **Instant Visual Updates (`hot_reload`):** Call MCP `hot_reload` immediately after tweaking styling, padding, or theme attributes.
- **Layout & Render Object Verification (`widget_inspector`):** Call MCP `widget_inspector` to inspect parent constraints, flex factors, and verify element hierarchy.
- **App Restart (`hot_restart`):** Call MCP `hot_restart` when introducing new top-level providers, state initializers, or routing definitions.
- **Tooling Reference:** See [mcp-tooling-hub](../../tooling/mcp-tooling-hub/SKILL.md).

---

## 6. Master UI Verification Checklist

Before completing any UI task:
- [ ] File size is strictly under 150–200 lines.
- [ ] No private helper methods returning `Widget` exist (`Widget _buildX()`).
- [ ] Colors and styles are strictly retrieved via `context.colorScheme`, `context.textTheme`, or `context.customColors`.
- [ ] Component adapts cleanly across Mobile, Tablet, and Desktop breakpoints.
- [ ] Reusable UI Kit components are covered by `@Preview` annotations (Light & Dark).
- [ ] Animations cleanly dispose `AnimationController` resources without frame drops.
