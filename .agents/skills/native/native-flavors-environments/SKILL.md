---
name: native-flavors-environments
description: Complete guide for setting up and managing Flutter Multi-Environment Flavors (dev, stage, prod) across Android, iOS, and Dart. Covers --dart-define-from-file with config/*.json, Android productFlavors in Gradle, iOS Xcode Schemes/Configurations/xcconfig, per-flavor app icons with flutter_launcher_icons, and release build commands.
---

# Flutter Multi-Environment Flavors & Configurations

## 1. Overview & Architectural Role

Flavors allow running and building distinct environments (**Development, Staging, Production**) with independent:
- **Backend API Base URLs & Keys** (injected via `config/*.json` and `--dart-define-from-file`).
- **Application IDs / Bundle Identifiers** (`com.example.app.dev` vs `com.example.app`).
- **App Names / Display Labels** ("App Dev" vs "App").
- **Launcher Icons & Branding** (e.g. dev badge on app icon).

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [native-hub](../native-hub/SKILL.md) | Native platform coordinator and rules. |
| **App Config** | [infrastructure-config](../../infrastructure/infrastructure-config/SKILL.md) | Strongly-typed Dart `AppConfig` accessing `--dart-define` values. |
| **Android Native** | [native-android](../native-android/SKILL.md) | Gradle scripts and Kotlin implementations. |
| **iOS Native** | [native-ios](../native-ios/SKILL.md) | Xcode project configurations and Swift bridging. |

---

## 3. Step 1: Dart-Side Environment JSON Files (`config/`)

Create environment definition files in `config/`:

### `config/env_dev.json`
```json
{
  "APP_ENV": "dev",
  "BASE_URL": "https://api-dev.example.com/v1",
  "API_KEY": "dev_mock_key_123"
}
```

### `config/env_stage.json`
```json
{
  "APP_ENV": "stage",
  "BASE_URL": "https://api-stage.example.com/v1",
  "API_KEY": "stage_qa_key_456"
}
```

### `config/env_prod.json`
```json
{
  "APP_ENV": "prod",
  "BASE_URL": "https://api.example.com/v1",
  "API_KEY": "prod_live_key_789"
}
```

### `config/env_template.json` (Committed to Git)
```json
{
  "APP_ENV": "dev",
  "BASE_URL": "https://api-dev.example.com/v1",
  "API_KEY": "YOUR_API_KEY_HERE"
}
```

> [!CAUTION]
> **Git Hygiene Rule:** Local JSON files with real keys (`config/env_dev.json`, `config/env_prod.json`) MUST be listed in `.gitignore` and NEVER committed. Commit ONLY `config/env_template.json`.

---

## 4. Step 2: Android Gradle `productFlavors` Setup
Official Documentation: [Flutter Android Flavors](https://docs.flutter.dev/deployment/flavors)

### In `android/app/build.gradle.kts` (Kotlin DSL):

```kotlin
android {
    ...
    flavorDimensions += "default"

    productFlavors {
        create("dev") {
            dimension = "default"
            applicationIdSuffix = ".dev"
            manifestPlaceholders["appName"] = "App Dev"
            manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher_dev"
        }
        create("stage") {
            dimension = "default"
            applicationIdSuffix = ".stage"
            manifestPlaceholders["appName"] = "App Staging"
            manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher_stage"
        }
        create("prod") {
            dimension = "default"
            manifestPlaceholders["appName"] = "App"
            manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher"
        }
    }
}
```

### Or in `android/app/build.gradle` (Groovy DSL):

```groovy
android {
    ...
    flavorDimensions "default"

    productFlavors {
        dev {
            dimension "default"
            applicationIdSuffix ".dev"
            manifestPlaceholders = [appName: "App Dev", appIcon: "@mipmap/ic_launcher_dev"]
        }
        stage {
            dimension "default"
            applicationIdSuffix ".stage"
            manifestPlaceholders = [appName: "App Staging", appIcon: "@mipmap/ic_launcher_stage"]
        }
        prod {
            dimension "default"
            manifestPlaceholders = [appName: "App", appIcon: "@mipmap/ic_launcher"]
        }
    }
}
```

In `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="${appName}"
    android:icon="${appIcon}">
    ...
</application>
```

---

## 5. Step 3: iOS & macOS Xcode Schemes & Build Configurations Setup
Official Documentation: [Flutter iOS Flavors](https://docs.flutter.dev/deployment/flavors-ios)

iOS and macOS require configuring Xcode Build Configurations and Schemes:

### A. Build Configurations
In Xcode (`Runner.xcodeproj` -> `Project` -> `Info` -> `Configurations`):
Duplicate `Debug`, `Profile`, and `Release` for each flavor:
- `Debug-dev`, `Profile-dev`, `Release-dev`
- `Debug-stage`, `Profile-stage`, `Release-stage`
- `Debug-prod`, `Profile-prod`, `Release-prod`

### B. Xcode Schemes
Create 3 shared Schemes in Xcode (`Product` -> `Scheme` -> `Manage Schemes...`):
1. **`dev` Scheme:**
   - Build / Run / Test -> Uses `Debug-dev`
   - Archive -> Uses `Release-dev`
2. **`stage` Scheme:**
   - Build / Run / Test -> Uses `Debug-stage`
   - Archive -> Uses `Release-stage`
3. **`prod` Scheme:**
   - Build / Run / Test -> Uses `Debug-prod`
   - Archive -> Uses `Release-prod`

### C. `xcconfig` Linking
In `ios/Flutter/` (and `macos/Flutter/`):
```text
Debug-dev.xcconfig:
#include "Generated.xcconfig"
#include "Pods/Target Support Files/Pods-Runner/Pods-Runner.debug-dev.xcconfig"
PRODUCT_BUNDLE_IDENTIFIER = com.example.app.dev
APP_DISPLAY_NAME = App Dev

Release-prod.xcconfig:
#include "Generated.xcconfig"
#include "Pods/Target Support Files/Pods-Runner/Pods-Runner.release-prod.xcconfig"
PRODUCT_BUNDLE_IDENTIFIER = com.example.app
APP_DISPLAY_NAME = App
```

In `ios/Runner/Info.plist`:
```xml
<key>CFBundleDisplayName</key>
<string>$(APP_DISPLAY_NAME)</string>
```

---

## 6. Step 4: Linux Desktop Flavors Setup
Official Documentation: [Flutter Linux Flavors](https://docs.flutter.dev/deployment/flavors-linux)

In `linux/CMakeLists.txt`, read the flavor passed by Flutter tool and configure binary definitions:

```cmake
# Add flavor definition support
if(DEFINED FLUTTER_FLAVOR)
  add_definitions(-DFLUTTER_FLAVOR="${FLUTTER_FLAVOR}")
endif()
```

In `linux/my_application.cc`:
```cpp
// Set application title dynamically based on FLUTTER_FLAVOR
#ifdef FLUTTER_FLAVOR
  std::string flavor = FLUTTER_FLAVOR;
  if (flavor == "dev") {
    gtk_window_set_title(window, "App Dev");
  } else if (flavor == "stage") {
    gtk_window_set_title(window, "App Staging");
  } else {
    gtk_window_set_title(window, "App");
  }
#else
  gtk_window_set_title(window, "App");
#endif
```

---

## 7. Step 5: Windows Desktop Flavors Setup
Official Documentation: [Flutter Windows Flavors](https://docs.flutter.dev/deployment/flavors-windows)

In `windows/CMakeLists.txt`:
```cmake
if(DEFINED FLUTTER_FLAVOR)
  add_definitions(-DFLUTTER_FLAVOR="${FLUTTER_FLAVOR}")
endif()
```

In `windows/runner/main.cpp`:
```cpp
#ifdef FLUTTER_FLAVOR
  std::string flavor = FLUTTER_FLAVOR;
  std::wstring title = L"App";
  if (flavor == "dev") {
    title = L"App Dev";
  } else if (flavor == "stage") {
    title = L"App Staging";
  }
  if (!window.Create(title, origin, size)) {
    return EXIT_FAILURE;
  }
#else
  if (!window.Create(L"App", origin, size)) {
    return EXIT_FAILURE;
  }
#endif
```

---

## 8. Step 6: Flavor App Icons with `flutter_launcher_icons`

Create per-flavor icon configurations in root:

### `flutter_launcher_icons-dev.yaml`
```yaml
flutter_launcher_icons:
  android: "ic_launcher_dev"
  ios: "AppIcon-dev"
  image_path: "assets/icons/icon_dev.png"
```

### `flutter_launcher_icons-prod.yaml`
```yaml
flutter_launcher_icons:
  android: "ic_launcher"
  ios: "AppIcon"
  image_path: "assets/icons/icon_prod.png"
```

### Generate Icons Command:
```bash
flutter pub run flutter_launcher_icons -f flutter_launcher_icons-dev.yaml
flutter pub run flutter_launcher_icons -f flutter_launcher_icons-prod.yaml
```

---

## 9. CLI Execution & Release Commands

### Running Locally
```bash
# Run Development Flavor (Mobile, Desktop, Web)
flutter run --flavor dev --dart-define-from-file=config/env_dev.json

# Run Staging Flavor
flutter run --flavor stage --dart-define-from-file=config/env_stage.json

# Run Production Flavor
flutter run --flavor prod --dart-define-from-file=config/env_prod.json
```

### Building Release Artifacts

#### Android (APK & App Bundle)
```bash
# Build Prod APK
flutter build apk --flavor prod --dart-define-from-file=config/env_prod.json

# Build Prod AppBundle (Google Play Release)
flutter build appbundle --flavor prod --dart-define-from-file=config/env_prod.json
```

#### iOS (IPA for App Store)
```bash
# Build Prod IPA
flutter build ipa --flavor prod --dart-define-from-file=config/env_prod.json
```

#### Desktop Release Builds
```bash
# macOS
flutter build macos --flavor prod --dart-define-from-file=config/env_prod.json

# Windows
flutter build windows --flavor prod --dart-define-from-file=config/env_prod.json

# Linux
flutter build linux --flavor prod --dart-define-from-file=config/env_prod.json
```

---

## 10. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Committing local `env_dev.json` or `env_prod.json` with real secret keys | **CRITICAL** | Keep real configs in `.gitignore`; commit only `env_template.json`. |
| Running `flutter run` without passing `--flavor` and `--dart-define-from-file` | **HIGH** | Always specify both flavor and config file flags. |
| Hardcoding `com.example.app` without applicationIdSuffix on dev builds | **HIGH** | Use `.dev` suffix so developer and prod builds coexist on same test device. |
| Forgetting to run `pod install` after adding new Xcode Configurations | **HIGH** | Run `cd ios && pod install` after modifying Build Configurations. |
| Omitting Linux/Windows flavor CMake definitions | **MEDIUM** | Configure CMakeLists.txt to pass `FLUTTER_FLAVOR`. |

---

## 11. Verification Checklist

- [ ] `flutter run --flavor dev --dart-define-from-file=config/env_dev.json` starts cleanly.
- [ ] Android installs as `com.example.app.dev` with "App Dev" label.
- [ ] iOS runs under `dev` scheme with `Debug-dev` configuration.
- [ ] Desktop platforms (macOS, Windows, Linux) display appropriate flavor window titles.
- [ ] App launcher icons reflect the selected flavor.
- [ ] `config/env_template.json` is committed while real configs are git-ignored.
