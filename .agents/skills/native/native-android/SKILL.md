---
name: native-android
description: Enforces Flutter Android platform integration standards using Kotlin, v2 embedding (configureFlutterEngine), Pigeon typed contracts, MethodChannel setups, Kotlin Coroutines, ViewBinding for PlatformViews, Android 12-15+ manifest hygiene (android:exported, foregroundServiceType), WorkManager, and ProGuard/R8 release safety. Use when editing android/ source code, MainActivity, platform channels, native UI, services, Gradle dependencies, or ProGuard rules.
---

# Flutter Android Native Integration Standard

## 1. Overview & When to Apply

Use this skill whenever:
- Writing or refactoring Kotlin code inside `android/app/src/main/kotlin/`.
- Implementing `MethodChannel` or `Pigeon` interfaces for native Android hardware/OS APIs.
- Embedding native Android Views via `PlatformView` and `ViewBinding`.
- Configuring runtime permissions and background services (`WorkManager`).
- Configuring ProGuard/R8 shrinking rules in `android/app/proguard-rules.pro`.
- Maintaining Android 12–15+ Manifest requirements (`android:exported`, `foregroundServiceType`).

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [native-hub](../native-hub/SKILL.md) | Native platform coordinator and rules. |
| **Flavors** | [native-flavors-environments](../native-flavors-environments/SKILL.md) | Gradle `productFlavors` and multi-environment builds. |
| **iOS Native** | [native-ios](../native-ios/SKILL.md) | Equivalent platform integration on iOS. |
| **Storage Interactor** | [infrastructure-storage](../../infrastructure/infrastructure-storage/SKILL.md) | Key-value storage in Dart before native bridging. |

---

## 3. Core Architectural Laws of Android Integration

1. **Capability Adapter Only (Zero Business Rules):**
   - Kotlin code MUST act purely as an adapter for OS capabilities, hardware APIs, or native SDKs.
   - Business validation and rules belong strictly in Dart (Domain UseCases).
2. **Mandatory v2 Embedding & Decoupled Plugins:**
   - Never dump channel handlers directly into `MainActivity.kt`.
   - Encapsulate native features inside standalone `FlutterPlugin` implementations.
3. **Coroutines & Threading Discipline:**
   - Disk IO, database calls, and heavy computations must execute on `Dispatchers.IO` or `Dispatchers.Default`.
   - All `MethodChannel.Result` completions must occur on `Dispatchers.Main`.
4. **Context Memory Leak Protection:**
   - Never retain an `Activity` instance in static fields. Use `applicationContext` for long-lived operations.
   - Cancel `CoroutineScope` jobs when the plugin or view is detached/disposed.
5. **Manifest Hygiene & ProGuard/R8 Safety:**
   - Include mandatory `<uses-permission android:name="android.permission.INTERNET" />` for all network/API communications.
   - Declare `android:exported="true|false"` explicitly on all activities, services, and receivers (API 31+).
   - Configure `-keep` rules for any native SDKs using reflection with R8.

---

## 4. Type-Safe Communication with Pigeon

### A. Dart Contract Definition (`pigeon/storage_pigeon.dart`)

```dart
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/infrastructure/native/generated/storage_pigeon.g.dart',
  kotlinOut: 'android/app/src/main/kotlin/com/example/app/pigeon/StoragePigeon.g.kt',
  kotlinOptions: KotlinOptions(package: 'com.example.app.pigeon'),
))
class StorageItemDto {
  final String key;
  final String value;

  const StorageItemDto({required this.key, required this.value});
}

@HostApi()
abstract class NativeStorageHostApi {
  @async
  void saveItem(StorageItemDto item);

  @async
  String? readItem(String key);
}
```

### B. Kotlin Host API Implementation

```kotlin
package com.example.app.plugins

import android.content.Context
import com.example.app.pigeon.NativeStorageHostApi
import com.example.app.pigeon.StorageItemDto
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class NativeStoragePlugin(private val context: Context) : NativeStorageHostApi {
    private val scope = CoroutineScope(Dispatchers.Main)

    override fun saveItem(item: StorageItemDto, callback: (Result<Unit>) -> Unit) {
        scope.launch {
            try {
                withContext(Dispatchers.IO) {
                    val prefs = context.getSharedPreferences("native_secure_vault", Context.MODE_PRIVATE)
                    prefs.edit().putString(item.key, item.value).apply()
                }
                callback(Result.success(Unit))
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    override fun readItem(key: String, callback: (Result<String?>) -> Unit) {
        scope.launch {
            try {
                val value = withContext(Dispatchers.IO) {
                    val prefs = context.getSharedPreferences("native_secure_vault", Context.MODE_PRIVATE)
                    prefs.getString(key, null)
                }
                callback(Result.success(value))
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }
}
```

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Writing all method calls directly in `MainActivity.kt` | **CRITICAL** | Extract to dedicated `FlutterPlugin` class. |
| Blocking the UI thread with synchronous database/network calls | **CRITICAL** | Use Kotlin Coroutines with `withContext(Dispatchers.IO)`. |
| Missing `android:exported` attribute in `AndroidManifest.xml` | **HIGH** | Explicitly declare `android:exported="true|false"` on all components. |
| Storing raw `Activity` reference in long-lived background singletons | **HIGH** | Use `applicationContext` to prevent Activity memory leaks. |

---

## 6. Verification Checklist

- [ ] Kotlin plugins register cleanly with `FlutterEngine`.
- [ ] IO operations use `Dispatchers.IO` and callback on `Dispatchers.Main`.
- [ ] Release APK builds with R8 without crashing due to stripped classes (`proguard-rules.pro`).
- [ ] Zero business logic exists in Android native source code.
