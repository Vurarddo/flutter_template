---
name: flutter-ios-native
description: Develops Flutter iOS platform integrations using MethodChannels, Pigeon typed contracts, and FlutterPlatformView. Enforces Swift API Design Guidelines, modern Swift concurrency (@MainActor / async/await), structured FlutterError codes, Info.plist hygiene, and iOS Privacy Manifests (PrivacyInfo.xcprivacy). Use when writing Swift/Obj-C code in ios/Runner, creating platform channels, embedding native UIKit views, configuring SPM/CocoaPods, or adding iOS capabilities.
---

# Flutter iOS Native Integration Expert Skill

## When to Apply

Use this skill whenever editing Swift/Obj-C code inside `ios/Runner`, adding `MethodChannel` or `Pigeon` interfaces, embedding native `UIKit` views via `FlutterPlatformView`, managing iOS capabilities, permissions (`Info.plist`), Privacy Manifests (`PrivacyInfo.xcprivacy`), or configuring CocoaPods / Swift Package Manager (SPM).

---

## Naming Conventions

| Artifact                   | Standard                               | Example                        |
| :------------------------- | :------------------------------------- | :----------------------------- |
| **Plugin / Bridge Class**  | `[Feature]Plugin` or `[Feature]Bridge` | `CameraNativeBridge`           |
| **Pigeon Definition File** | `[feature]_pigeon.dart`                | `pigeon/battery_pigeon.dart`   |
| **Platform View Factory**  | `[Feature]ViewFactory`                 | `NativeMapHeaderFactory`       |
| **Platform View Class**    | `[Feature]PlatformView`                | `NativeMapPlatformView`        |
| **Channel Name**           | `reverse-DNS / feature`                | `com.company.app.sensors/gyro` |

---

## Core Architectural Rules & Standards

1. **Capability & Transport Boundary:**
   - **CRITICAL:** Swift/iOS native code MUST act purely as an adapter for OS capabilities, hardware sensors, or native SDKs.
   - ALL business rules, data validation, and application logic MUST remain strictly in Dart (Domain/Use Cases).

2. **Pigeon First Policy:**
   - Prefer **Pigeon** code generation for complex, multi-method, or evolving APIs over raw stringly-typed `MethodChannel` calls to avoid runtime serialization errors.
   - Re-run Pigeon code generation immediately when Dart interface models change.

3. **Swift Concurrency & Main Thread Discipline:**
   - **CRITICAL:** ALL UI mutations and `FlutterResult` completions that affect the view hierarchy MUST execute on the Main Actor (`@MainActor` / `DispatchQueue.main`).
   - Heavy tasks (crypto, disk I/O, image processing) MUST be offloaded to background tasks via `async/await` or `DispatchQueue.global(qos:)`. Never block the main thread.

4. **Structured Error Handling (`FlutterError`):**
   - Return structured `FlutterError(code:message:details:)` with stable string error codes.
   - Catch and translate all internal Swift/`NSError` exceptions into predictable `FlutterError` structures before replying to Flutter.

5. **Decoupled Architecture (`AppDelegate` Hygiene):**
   - NEVER clutter `AppDelegate.swift` with inline channel handlers.
   - Create self-contained `FlutterPlugin` classes and register them via `registrar.addMethodCallDelegate(...)` or custom extension modules.

6. **Privacy & Permission Discipline:**
   - Declare minimal `Info.plist` usage strings with accurate, user-facing descriptions.
   - Provide an iOS 17+ Privacy Manifest (`PrivacyInfo.xcprivacy`) declaring required reason APIs (e.g., File timestamp APIs, System boot time) to ensure App Store compliance.

---

## 1. Type-Safe Communication with Pigeon (Preferred)

### A. Dart Contract Definition (`pigeon/device_info_pigeon.dart`)

```dart
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/generated/device_info_pigeon.g.dart',
    swiftOut: 'ios/Runner/Generated/DeviceInfoPigeon.g.swift',
    swiftOptions: SwiftOptions(),
  ),
)
class NativeBatteryStatus {
  final int level;
  final bool isCharging;

  NativeBatteryStatus({required this.level, required this.isCharging});
}

@HostApi()
abstract class DeviceInfoHostApi {
  NativeBatteryStatus getBatteryStatus();

  @async
  String getSystemVersion();
}

```

### B. Swift Implementation (`ios/Runner/Bridges/DeviceInfoBridge.swift`)

```swift
import Flutter
import UIKit

class DeviceInfoBridge: DeviceInfoHostApi {
    func getBatteryStatus() throws -> NativeBatteryStatus {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let level = Int64(UIDevice.current.batteryLevel * 100)
        let isCharging = UIDevice.current.batteryState == .charging || UIDevice.current.batteryState == .full

        return NativeBatteryStatus(level: level, isCharging: isCharging)
    }

    func getSystemVersion(completion: @escaping (Result<String, Error>) -> Void) {
        // Offload to background if needed, then reply
        Task {
            let version = await UIDevice.current.systemVersion
            completion(.success(version))
        }
    }
}

```

---

## 2. Decoupled `MethodChannel` Registration Pattern

Avoid bloated `AppDelegate.swift` files by encapsulating channel handling in modular Swift plugins.

### A. Modular Swift Plugin (`ios/Runner/Plugins/SensorPlugin.swift`)

```swift
import Flutter
import UIKit

public class SensorPlugin: NSObject, FlutterPlugin {
    private static const channelName = "com.company.app/sensors"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: registrar.messenger()
        )
        let instance = SensorPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getGyroscopeData":
            fetchGyroscopeData(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func fetchGyroscopeData(result: @escaping FlutterResult) {
        Task {
            do {
                let data = try await PerformanceSensorManager.shared.readData()
                // Return result on main thread
                await MainActor.run {
                    result(["x": data.x, "y": data.y, "z": data.z])
                }
            } catch {
                await MainActor.run {
                    result(FlutterError(
                        code: "SENSOR_UNAVAILABLE",
                        message: "Gyroscope sensor could not be initialized",
                        details: error.localizedDescription
                    ))
                }
            }
        }
    }
}

```

### B. Clean `AppDelegate.swift`

```swift
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        // Register custom native bridges
        if let registrar = self.registrar(forPlugin: "SensorPlugin") {
            SensorPlugin.register(with: registrar)
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

```

---

## 3. Native UIKit View Embedding (`FlutterPlatformView`)

Embed native UIKit elements securely in the Flutter widget tree.

### Swift Platform View Factory & View

```swift
import Flutter
import UIKit

class NativeHeaderViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return NativeHeaderPlatformView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger
        )
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class NativeHeaderPlatformView: NSObject, FlutterPlatformView {
    private var _view: UIView

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        _view = UIView(frame: frame)
        super.init()
        createNativeView(arguments: args)
    }

    func view() -> UIView {
        return _view
    }

    private func createNativeView(arguments args: Any?) {
        _view.backgroundColor = .systemBlue
        let label = UILabel()
        let params = args as? [String: Any]
        label.text = params?["title"] as? String ?? "Native UIKit View"
        label.textColor = .white
        label.textAlignment = .center
        label.frame = _view.bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _view.addSubview(label)
    }
}

```

---

## 4. Modern Swift Concurrency & Main Thread Rules

Guarding thread safety when working with Flutter engine callbacks.

```swift
// WRONG: Blocking main thread with sync I/O or background network
func handleSyncWork(result: @escaping FlutterResult) {
    let data = try? Data(contentsOf: bigFileURL) // BLOCKS MAIN THREAD!
    result(data)
}

// CORRECT: Offload heavy processing, execute result callback on MainActor
func handleAsyncWork(result: @escaping FlutterResult) {
    Task.detached(priority: .userInitiated) {
        do {
            let data = try Data(contentsOf: bigFileURL)
            let processed = try self.processData(data)

            await MainActor.run {
                result(processed)
            }
        } catch {
            await MainActor.run {
                result(FlutterError(
                    code: "FILE_READ_ERROR",
                    message: "Failed to parse local payload",
                    details: error.localizedDescription
                ))
            }
        }
    }
}

```

---

## Anti-Patterns (Strictly Prohibited)

| Anti-Pattern                                                    | Severity     | Corrective Action                                                                |
| --------------------------------------------------------------- | ------------ | -------------------------------------------------------------------------------- |
| Performing synchronous file/network I/O on `DispatchQueue.main` | **CRITICAL** | Offload heavy work to background tasks; return `FlutterResult` via `@MainActor`. |

|
| Hardcoding team IDs, credentials, or API keys in Swift source | **CRITICAL** | Inject configurations via `.xcconfig` or CI build arguments.

|
| Writing inline method channel handlers directly in `AppDelegate.swift` | **HIGH** | Encapsulate logic in dedicated `FlutterPlugin` classes.

|
| Hand-editing `GeneratedPluginRegistrant.m` or generated Pigeon files | **HIGH** | Use official plugin registration hooks and run Pigeon code generation.

|
| Duplicating business rules or domain models in Swift | **HIGH** | Keep native code restricted to hardware/OS API bridging.

|
| Omitting user-facing descriptions in `Info.plist` permission keys | **MEDIUM** | Provide clear, meaningful usage strings for camera, location, micro, etc.

|

---

## Agent Verification Checklist

When reviewing iOS native code:

1. **Thread Safety:** All UIKit mutations and `FlutterResult` invocations happen on `@MainActor` / Main thread.

2. **Pigeon Integration:** Pigeon specs are single-sourced in Dart; `swiftOut` code is generated automatically.

3. **Clean AppDelegate:** `AppDelegate.swift` contains no inline business or channel handling code.

4. **Error Mapping:** Internal Swift/`NSError` exceptions are wrapped in structured `FlutterError` instances.

5. **Plist & Privacy:** `Info.plist` usage descriptions are complete; `PrivacyInfo.xcprivacy` is present for iOS 17+.

6. **No Duplicated Logic:** Domain decisions remain strictly on the Flutter/Dart side.
