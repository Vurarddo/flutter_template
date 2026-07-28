---
name: flutter-android-native
description: Enforces Flutter Android platform integration standards using Kotlin, v2 embedding (configureFlutterEngine), Pigeon typed contracts, MethodChannel setups, Kotlin Coroutines, ViewBinding for PlatformViews, Android 12-15+ manifest hygiene (android:exported, foregroundServiceType), WorkManager, and ProGuard/R8 release safety. Use when editing android/ source code, MainActivity, platform channels, native UI, services, Gradle dependencies, or ProGuard rules.
---

# Flutter Android Native Integration Expert Skill

## When to Apply

Use this skill whenever writing or refactoring Kotlin code inside `android/app/src/main/kotlin/`, implementing `MethodChannel` or `Pigeon` interfaces, embedding native Android Views via `PlatformView` and `ViewBinding`, configuring runtime permissions, background services (`WorkManager`), ProGuard/R8 rules, or Android Manifest configurations.

---

## Naming Conventions

| Artifact                   | Standard                               | Example                                |
| :------------------------- | :------------------------------------- | :------------------------------------- |
| **Plugin / Bridge Class**  | `[Feature]Plugin` or `[Feature]Bridge` | `SensorNativePlugin`          |
| **Pigeon Definition File** | `[feature]_pigeon.dart`                | `pigeon/storage_pigeon.dart`  |
| **Platform View Factory**  | `[Feature]ViewFactory`                 | `NativeCameraViewFactory`     |
| **Platform View Class**    | `[Feature]PlatformView`                | `NativeCameraPlatformView`    |
| **Channel Name**           | `reverse-DNS / feature`                | `com.company.app.sensor/gyro` |

---

## Core Architectural Rules & Standards

1. **Capability & Transport Boundary:**
   - **CRITICAL:** Kotlin/Android native code MUST act purely as an adapter for OS capabilities, hardware APIs, or third-party native SDKs.
   - ALL business rules, domain logic, and validation MUST remain strictly in Dart (Domain/Use Cases).

2. **Mandatory v2 Embedding & Decoupled `MainActivity`:**
   - **CRITICAL:** Use Flutter v2 embedding (`FlutterActivity` / `FlutterEngine`) strictly. Never use legacy v1 APIs.
   - Do NOT dump channel handlers inside `MainActivity.kt`. Encapsulate features inside standalone `FlutterPlugin` implementations.

3. **Kotlin Coroutines & Threading Discipline:**
   - **CRITICAL:** NEVER block the main UI thread with disk, network, or heavy computational tasks.
   - Execute background tasks on `Dispatchers.IO` or `Dispatchers.Default`.
   - **Thread Synchronization:** All `MethodChannel.Result` completions and UI operations MUST occur on `Dispatchers.Main`.

4. **Pigeon First Policy:**
   - Prefer **Pigeon** for multi-method or evolving platform interfaces to enforce type-safety and avoid string-matching errors between Dart and Kotlin.

5. **Context Memory Leak Protection:**
   - NEVER retain an `Activity` instance in static fields or long-lived background singletons.
   - Use `applicationContext` for long-lived operations, background services, or database initializations.
   - Always cancel `CoroutineScope` jobs when the underlying plugin/view is detached or disposed.

6. **Manifest Hygiene & ProGuard/R8 Release Safety:**
   - Explicitly declare `android:exported="true|false"` on all `<activity>`, `<service>`, and `<receiver>` components (mandatory for API 31+).
   - Keep `<uses-permission>` minimal. For dangerous permissions, rely on runtime checks.
   - When `minifyEnabled true` is configured, provide minimal, justified `-keep` rules in `proguard-rules.pro` to prevent R8 from stripping JNI/reflection dependencies.

---

## 1. Type-Safe Communication with Pigeon

### A. Dart Contract Definition (`pigeon/storage_pigeon.dart`)

```dart
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/generated/storage_pigeon.g.dart',
    kotlinOut: 'android/app/src/main/kotlin/com/example/app/StoragePigeon.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.example.app'),
  ),
)
class NativeStorageInfo {
  final int totalBytes;
  final int freeBytes;

  NativeStorageInfo({required this.totalBytes, required this.freeBytes});
}

@HostApi()
abstract class StorageHostApi {
  @async
  NativeStorageInfo getStorageDetails();
}

```

### B. Kotlin Implementation (`StorageBridge.kt`)

```kotlin
package com.example.app

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class StorageBridge(
    private val scope: CoroutineScope
) : StorageHostApi {

    override fun getStorageDetails(callback: (Result<NativeStorageInfo>) -> Unit) {
        scope.launch(Dispatchers.IO) {
            try {
                // Perform heavy I/O off the main thread
                val total = 1000000000L
                val free = 500000000L
                val info = NativeStorageInfo(totalBytes = total, freeBytes = free)

                withContext(Dispatchers.Main) {
                    callback(Result.success(info))
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    callback(Result.failure(e))
                }
            }
        }
    }
}

```

---

## 2. Decoupled `FlutterPlugin` Implementation Pattern

Encapsulate custom `MethodChannel` endpoints in self-contained plugins.

```kotlin
package com.example.app.plugins

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*

class SensorPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private var channel: MethodChannel? = null
    private var applicationContext: Context? = null
    private val pluginScope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel?.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "readSensorData" -> handleReadSensorData(result)
            else -> result.notImplemented()
        }
    }

    private fun handleReadSensorData(result: MethodChannel.Result) {
        pluginScope.launch {
            try {
                val dataMap = withContext(Dispatchers.IO) {
                    // Simulate hardware sensor or file reading
                    mapOf("x" to 0.12, "y" to 9.81, "z" to 0.05)
                }
                // Result dispatched back on main thread
                result.success(dataMap)
            } catch (e: Exception) {
                result.error(
                    "SENSOR_ERROR",
                    "Failed to read hardware sensor",
                    e.localizedMessage
                )
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
        applicationContext = null
        pluginScope.cancel() // Prevent coroutine memory leaks
    }

    companion object {
        const val CHANNEL_NAME = "com.example.app/sensor"
    }
}

```

---

## 3. Clean `MainActivity.kt` Registration

Keep `MainActivity.kt` minimalist by attaching modular plugins inside `configureFlutterEngine`.

```kotlin
package com.example.app

import androidx.annotation.NonNull
import com.example.app.plugins.SensorPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register custom native plugins
        flutterEngine.plugins.add(SensorPlugin())
    }
}

```

---

## 4. Native `PlatformView` with `ViewBinding`

Embed custom Android UI using `ViewBinding` and attach to Flutter's PlatformView lifecycle.

### A. PlatformView & Factory Implementation

```kotlin
package com.example.app.views

import android.content.Context
import android.view.View
import com.example.app.databinding.NativeHeaderBinding
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class NativeHeaderFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as? Map<String, Any>
        return NativeHeaderPlatformView(context, viewId, creationParams)
    }
}

class NativeHeaderPlatformView(
    context: Context,
    id: Int,
    creationParams: Map<String, Any>?
) : PlatformView {

    private val binding: NativeHeaderBinding = NativeHeaderBinding.inflate(
        android.view.LayoutInflater.from(context)
    )

    init {
        val title = creationParams?.get("title") as? String ?: "Native View"
        binding.headerTitle.text = title
    }

    override fun getView(): View = binding.root

    override fun dispose() {
        // Clean up view listeners, animations, or bindings
    }
}

```

---

## 5. ProGuard / R8 Rules (`proguard-rules.pro`)

Protect Flutter Engine and JNI plugin bindings during release minimization.

```proguard
# Flutter Engine Protection
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep generated Pigeon models
-keep class com.example.app.StoragePigeon$** { *; }

# Protect custom FlutterPlugins registered dynamically
-keep class com.example.app.plugins.** { *; }

```

---

## Anti-Patterns (Strictly Prohibited)

| Anti-Pattern                                                         | Severity     | Corrective Action                                         |
| -------------------------------------------------------------------- | ------------ | --------------------------------------------------------- |
| Blocking the Main Thread with synchronous File/Network I/O in Kotlin | **CRITICAL** | Offload non-UI tasks using `withContext(Dispatchers.IO)`. |

|
| Retaining an `Activity` reference inside static properties or background singletons | **CRITICAL** | Use `applicationContext` or clean up references on activity detachment.

|
| Writing inline channel callbacks directly in `MainActivity.kt` | **HIGH** | Refactor code into dedicated `FlutterPlugin` modules.

|
| Invoking `MethodChannel.Result` callbacks from background threads | **HIGH** | Switch to `Dispatchers.Main` prior to calling `result.success()` or `result.error()`.

|
| Omitting explicit `android:exported` on API 31+ Manifest declarations | **HIGH** | Declare `android:exported="true |
| Blanket `-keep class \*` ProGuard rules in release builds | **MEDIUM** | Write targeted, minimal ProGuard keep rules for JNI/reflection dependencies.

|

---

## Agent Verification Checklist

When reviewing Android native code:

1. **Thread Safety:** Heavy work executes on `Dispatchers.IO`; channel results complete on `Dispatchers.Main`.

2. **Pigeon Integration:** Pigeon specs are single-sourced in Dart; generated Kotlin code is committed or generated in build pipelines.

3. **Clean MainActivity:** `MainActivity.kt` delegates logic to `FlutterPlugin` implementations registered in `configureFlutterEngine`.

4. **Context Safety:** No long-lived leaks of `Activity` or `View` references.

5. **Platform Views:** `PlatformView` implementations use `ViewBinding` and release resources in `dispose()`.

6. **Release Safety:** ProGuard/R8 configurations tested and validated on release builds.
