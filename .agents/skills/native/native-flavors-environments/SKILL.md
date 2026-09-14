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

- `config/env_dev.json` (`APP_ENV: "dev"`, `BASE_URL`, `API_KEY`)
- `config/env_stage.json` (`APP_ENV: "stage"`, `BASE_URL`, `API_KEY`)
- `config/env_prod.json` (`APP_ENV: "prod"`, `BASE_URL`, `API_KEY`)
- `config/env_template.json` (Template committed to Git)

> [!CAUTION]
> **Git Hygiene Rule:** Local JSON files with real keys (`config/env_dev.json`, `config/env_prod.json`) MUST be listed in `.gitignore` and NEVER committed. Commit ONLY `config/env_template.json`.

---

## 4. Step 2: Android Gradle `productFlavors` Setup
Official Documentation: [Flutter Android Flavors](https://docs.flutter.dev/deployment/flavors)

- **Gradle Template:** See [examples/android_build.gradle.kts](examples/android_build.gradle.kts).
- **Manifest Configuration:** In `android/app/src/main/AndroidManifest.xml`:
  ```xml
  <manifest xmlns:android="http://schemas.android.com/apk/res/android">
      <!-- Mandatory Internet Permission -->
      <uses-permission android:name="android.permission.INTERNET" />

      <application
          android:label="${appName}"
          android:icon="${appIcon}">
          ...
      </application>
  </manifest>
  ```

---

## 5. Step 3: iOS & macOS Xcode Schemes & Build Configurations
Official Documentation: [Flutter iOS Flavors](https://docs.flutter.dev/deployment/flavors-ios)

1. **Build Configurations:** In Xcode duplicate `Debug`, `Profile`, `Release` into:
   - `Debug-dev`, `Profile-dev`, `Release-dev`
   - `Debug-stage`, `Profile-stage`, `Release-stage`
   - `Debug-prod`, `Profile-prod`, `Release-prod`
2. **Shared Schemes:** Create `dev`, `stage`, `prod` schemes mapped to corresponding build configurations.
3. **xcconfig Linking:** See [examples/xcconfig_sample.xcconfig](examples/xcconfig_sample.xcconfig).

---

## 6. Step 4: Desktop Flavors Setup (Linux & Windows)

For desktop CMakeLists and window title configuration:
- See full implementation guide: [examples/desktop_flavor_setup.md](examples/desktop_flavor_setup.md).

---

## 7. Step 5: Flavor App Icons with `flutter_launcher_icons`

Create per-flavor icon configurations (`flutter_launcher_icons-dev.yaml`, `flutter_launcher_icons-prod.yaml`):

```bash
flutter pub run flutter_launcher_icons -f flutter_launcher_icons-dev.yaml
flutter pub run flutter_launcher_icons -f flutter_launcher_icons-prod.yaml
```

---

## 8. CLI Execution & Release Commands

### Running Locally
```bash
# Run Development Flavor
flutter run --flavor dev --dart-define-from-file=config/env_dev.json

# Run Staging Flavor
flutter run --flavor stage --dart-define-from-file=config/env_stage.json

# Run Production Flavor
flutter run --flavor prod --dart-define-from-file=config/env_prod.json
```

### Building Release Artifacts
```bash
# Android AppBundle & APK
flutter build appbundle --flavor prod --dart-define-from-file=config/env_prod.json
flutter build apk --flavor prod --dart-define-from-file=config/env_prod.json

# iOS IPA
flutter build ipa --flavor prod --dart-define-from-file=config/env_prod.json
```

---

## 9. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Committing local `env_dev.json` or `env_prod.json` with real secret keys | **CRITICAL** | Keep real configs in `.gitignore`; commit only `env_template.json`. |
| Running `flutter run` without passing `--flavor` and `--dart-define-from-file` | **HIGH** | Always specify both flavor and config file flags. |
| Hardcoding `com.example.app` without applicationIdSuffix on dev builds | **HIGH** | Use `.dev` suffix so developer and prod builds coexist on same test device. |
| Forgetting to run `pod install` after adding new Xcode Configurations | **HIGH** | Run `cd ios && pod install` after modifying Build Configurations. |

---

## 10. Verification Checklist

- [ ] `flutter run --flavor dev --dart-define-from-file=config/env_dev.json` starts cleanly.
- [ ] Android installs as `com.example.app.dev` with "App Dev" label.
- [ ] iOS runs under `dev` scheme with `Debug-dev` configuration.
- [ ] Desktop platforms display appropriate flavor window titles.
- [ ] App launcher icons reflect the selected flavor.
- [ ] `config/env_template.json` is committed while real configs are git-ignored.
