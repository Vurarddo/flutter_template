---
name: native-ios
description: Develops Flutter iOS platform integrations using Swift, @MainActor, async/await concurrency, Pigeon typed contracts, and FlutterPlatformView. Enforces Swift API Design Guidelines, structured FlutterError codes, Info.plist hygiene, and iOS 17+ Privacy Manifests (PrivacyInfo.xcprivacy). Use when writing Swift code in ios/Runner, creating platform channels, embedding native UIKit views, configuring CocoaPods/SPM, or adding iOS capabilities.
---

# Flutter iOS Native Integration Standard

## 1. Overview & When to Apply

Use this skill whenever:
- Writing or refactoring Swift code inside `ios/Runner/`.
- Adding `MethodChannel` or `Pigeon` interfaces for native iOS APIs.
- Embedding native UIKit views via `FlutterPlatformView`.
- Managing iOS permissions in `Info.plist` and Privacy Manifests (`PrivacyInfo.xcprivacy`).
- Configuring CocoaPods dependencies or Swift Package Manager (SPM).
- Handling iOS background tasks and app delegate lifecycles.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [native-hub](../native-hub/SKILL.md) | Native platform coordinator and rules. |
| **Flavors** | [native-flavors-environments](../native-flavors-environments/SKILL.md) | Xcode Schemes, Build Configurations, and xcconfig files. |
| **Android Native** | [native-android](../native-android/SKILL.md) | Equivalent platform integration on Android. |
| **Storage Interactor** | [infrastructure-storage](../../infrastructure/infrastructure-storage/SKILL.md) | Key-value storage in Dart before native bridging. |

---

## 3. Core Architectural Laws of iOS Integration

1. **Capability Adapter Only (Zero Business Rules):**
   - Swift native code MUST act purely as an adapter for OS capabilities, hardware sensors, or native SDKs.
   - Business validation and rules belong strictly in Dart (Domain UseCases).
2. **Swift Concurrency & Main Actor Discipline:**
   - ALL UI mutations and `FlutterResult` completions that affect the view hierarchy MUST execute on the Main Actor (`@MainActor` / `DispatchQueue.main`).
   - Heavy tasks (crypto, disk IO, image processing) MUST be offloaded to background tasks via `async/await` or `Task.detached(priority: .background)`.
3. **Structured Error Handling (`FlutterError`):**
   - Return structured `FlutterError(code:message:details:)` with stable string error codes.
   - Catch and translate all internal Swift/`NSError` exceptions into predictable `FlutterError` structures before replying to Flutter.
4. **Decoupled `AppDelegate` Architecture:**
   - Never clutter `AppDelegate.swift` with inline channel handlers.
   - Create self-contained `FlutterPlugin` classes and register them via `registrar.addMethodCallDelegate(...)`.
5. **Privacy & Permission Discipline:**
   - Provide an iOS 17+ Privacy Manifest (`PrivacyInfo.xcprivacy`) declaring required reason APIs to ensure App Store submission compliance.

---

## 4. Type-Safe Communication with Pigeon

### Swift Host API Implementation

```swift
import Flutter
import UIKit

class NativeStoragePlugin: NSObject, NativeStorageHostApi {
    func saveItem(item: StorageItemDto, completion: @escaping (Result<Void, Error>) -> Void) {
        Task.detached(priority: .userInitiated) {
            do {
                let key = item.key
                let value = item.value
                UserDefaults.standard.set(value, forKey: "native_vault_\(key)")
                
                await MainActor.run {
                    completion(.success(()))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }

    func readItem(key: String, completion: @escaping (Result<String?, Error>) -> Void) {
        Task.detached(priority: .userInitiated) {
            let value = UserDefaults.standard.string(forKey: "native_vault_\(key)")
            
            await MainActor.run {
                completion(.success(value))
            }
        }
    }
}
```

---

## 5. iOS 17+ Privacy Manifest (`PrivacyInfo.xcprivacy`)

Place `PrivacyInfo.xcprivacy` inside `ios/Runner/` declaring required reason APIs:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyCollectedDataTypes</key>
    <array/>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryFileTimestamp</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>C617.1</string>
            </array>
        </dict>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>CA92.1</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

---

## 6. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Dumping inline `MethodChannel` blocks into `AppDelegate.swift` | **CRITICAL** | Encapsulate into dedicated Swift plugin classes. |
| Blocking the main UI thread with synchronous file/network operations | **CRITICAL** | Use Swift concurrency (`Task.detached`) and resolve on `@MainActor`. |
| Missing `PrivacyInfo.xcprivacy` file (rejected by App Store) | **HIGH** | Add privacy manifest in `ios/Runner/PrivacyInfo.xcprivacy`. |
| Hardcoding English permission descriptions in `Info.plist` without localization | **MEDIUM** | Provide localized `InfoPlist.strings` for non-English locales. |

---

## 7. Verification Checklist

- [ ] Swift plugins compile cleanly in Xcode.
- [ ] UI operations and Flutter completions execute on `@MainActor` / Main thread.
- [ ] `PrivacyInfo.xcprivacy` declares all accessed system APIs.
- [ ] Zero business validation logic exists in Swift source code.
