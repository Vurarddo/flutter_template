---
name: native-hub
description: Primary coordinator and architecture guide for Native Platform Integrations and Flavors across Android, iOS, and Desktop. Enforces clean platform adapter boundaries (pure OS adapters in Kotlin/Swift, zero business rules), Pigeon type-safe contracts, and multi-environment Flavors (dev, stage, prod).
---

# Native Platform Integrations & Flavors Architecture Hub

## 1. Overview & Platform Boundary Philosophy

The `android/`, `ios/`, and native platform folders provide the direct bridge between Flutter and host operating systems. 

### Core Laws of Native Integrations:
1. **Pure Platform Adapters (Zero Business Rules):**
   - Kotlin/Swift native code must act strictly as **hardware/OS adapters** (camera, sensors, biometrics, background workers, platform-specific SDKs).
   - ALL business logic, domain validation, and state machines MUST reside purely in Dart (`lib/domain/`, `lib/presentation/`).
2. **Type-Safe Platform Contracts (Pigeon First):**
   - Use **Pigeon** code generation for multi-method interfaces instead of manual, stringly-typed `MethodChannel` invocations to eliminate runtime serialization bugs.
3. **Threading Discipline:**
   - Disk IO, database access, and cryptographic computations must run in background threads (`Dispatchers.IO` in Kotlin, background actors/queues in Swift).
   - All Flutter callback completions and UI interactions must resolve on the Main UI thread (`Dispatchers.Main` / `@MainActor`).
4. **Environment Isolation (Flavors):**
   - Keep environments (`dev`, `stage`, `prod`) strictly isolated using `--dart-define-from-file=config/env_<flavor>.json`, Gradle `productFlavors`, and Xcode Schemes.

---

## 2. Native Skill Tree & Routing Matrix

| Focus Area | Target Skill | Purpose |
| :--- | :--- | :--- |
| **Flavors & Environments** | [native-flavors-environments](../native-flavors-environments/SKILL.md) | Multi-environment flavors (`dev`, `stage`, `prod`), `--dart-define-from-file`, Gradle `productFlavors`, Xcode Schemes, flavor icons. |
| **Android Native** | [native-android](../native-android/SKILL.md) | Kotlin, Flutter v2 embedding, Coroutines, PlatformViews, Android 12-15+ Manifest hygiene, ProGuard/R8. |
| **iOS Native** | [native-ios](../native-ios/SKILL.md) | Swift, `@MainActor`, async/await, Pigeon, FlutterPlatformView, iOS Privacy Manifests (`PrivacyInfo.xcprivacy`), Info.plist. |
| **App Configuration** | [infrastructure-config](../../infrastructure/infrastructure-config/SKILL.md) | Dart-side `AppConfig` and `AppEnvironment` models. |
| **Clean Architecture Hub** | [flutter-clean-architecture](../../flutter-clean-architecture/SKILL.md) | Layer-First architecture and dependency inversion rules. |

---

## 3. Directory Standard for Native & Config

```text
config/
├── env_dev.json                 # Development environment settings (local API, mock keys)
├── env_stage.json               # Staging environment settings (QA backend)
├── env_prod.json                # Production environment settings (release endpoints)
└── env_template.json            # Safe template for version control (no real credentials)

android/
├── app/
│   ├── build.gradle.kts         # productFlavors: dev, stage, prod
│   └── src/
│       ├── main/kotlin/...      # Kotlin source files, plugins, platform views
│       ├── dev/res/...          # Dev flavor app icons and resources
│       └── prod/res/...         # Prod flavor app icons and resources

ios/
├── Runner/
│   ├── AppDelegate.swift        # Flutter plugin registrations
│   ├── Info.plist               # Permissions and dynamic CFBundleDisplayName
│   └── PrivacyInfo.xcprivacy    # iOS 17+ Privacy Manifest
├── Flutter/
│   ├── Debug-dev.xcconfig       # Xcode configuration per flavor
│   └── Release-prod.xcconfig
└── Runner.xcodeproj/xcshareddata/xcschemes/
    ├── dev.xcscheme             # Xcode Scheme for Dev flavor
    ├── stage.xcscheme           # Xcode Scheme for Staging flavor
    └── prod.xcscheme            # Xcode Scheme for Production flavor
```

---

## 4. Master Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Writing domain business logic in Kotlin/Swift | **CRITICAL** | Keep native code strictly as an OS adapter; business rules belong in Dart. |
| Blocking the native Main UI thread with synchronous IO/crypto | **CRITICAL** | Offload to `Dispatchers.IO` (Kotlin) or background task (Swift). |
| Hardcoding server secrets or real credentials in committed JSON files | **CRITICAL** | Add `config/env_*.json` to `.gitignore`; commit only `config/env_template.json`. |
| Putting all channel methods directly into `MainActivity` or `AppDelegate` | **HIGH** | Encapsulate into dedicated `[Feature]Plugin` or `[Feature]Bridge` classes. |

---

## 5. Master Verification Checklist

- [ ] Multi-environment builds succeed via `flutter run --flavor dev --dart-define-from-file=config/env_dev.json`.
- [ ] Kotlin and Swift source files contain zero business logic or validation rules.
- [ ] Platform channels use Pigeon typed contracts where applicable.
- [ ] Memory leaks are guarded (no static Activity/ViewController retention).
- [ ] Android Manifest and iOS Privacy Manifest comply with store submission guidelines.
