---
name: flutter-isolates-expert
description: Enforces high-performance Isolate patterns in Dart/Flutter. Guarantees zero Main Thread blocking (60/120 FPS parity), strict Clean Architecture placement (Data/Infrastructure layers only), proper usage of Isolate.run for short tasks vs Isolate.spawn for long-running workers, zero-copy TransferableTypedData memory transfers, RootIsolateToken setup, and strict batching over loop spawns. Use when parsing large payloads, offloading heavy CPU computations, or handling binary/crypto/image processing.
---

# Flutter Isolates & Parallelism Expert Skill

## When to Apply

Use this skill whenever processing heavy payloads (JSON > 100KB), performing CPU-intensive computations (crypto, image decoding/manipulation, large matrix calculations), or running continuous background data processing channels.

---

## Core Architectural Rules & Standards

1. **Clean Architecture Boundary:**
   - **STRICTLY PROHIBITED:** Spawning Isolates or managing `ReceivePort` / `SendPort` directly inside `Presentation` widgets, BLoCs, or `Domain` UseCases.
   - Isolates belong EXCLUSIVELY to the **`Infrastructure`** or **`Data`** layers (e.g., inside dedicated Parser services, Repository implementations, or Local DataSource classes).

2. **Root Isolate Responsibility & Frame Budget:**
   - The **Root Isolate** exclusively owns widgets, GPU frame scheduling, and UI state. Keep it completely free of long synchronous CPU operations.
   - If execution time exceeds **8ms** (for 120 FPS) or **16ms** (for 60 FPS), it MUST be offloaded to a background Isolate.
   - **PROHIBITED:** Creating Isolates for trivial tasks (< 1-2ms). The memory copying overhead will degrade performance.

3. **Strict Batching Rule (No Iterative Spawning):**
   - **STRICTLY PROHIBITED:** Calling `Isolate.run()` or `compute()` inside a loop for individual items (e.g., iterating thousands of list elements).
   - Always batch data and execute a single Isolate call over the entire dataset or large chunks.

4. **Closure Capture Safety:**
   - Avoid capturing large non-transferable outer scope state inside `Isolate.run(() => ...)` closures. Pass explicit primitives or sendable parameters.

---

## 1. Short-Lived Heavy Tasks (`Isolate.run` & Batching)

Use `Isolate.run()` (Dart 3+) for single-shot tasks. Legacy `compute()` is supported for backwards compatibility, but `Isolate.run` is preferred.

```dart
import 'dart:convert';
import 'dart:isolate';

abstract final class LargePayloadParser {
  /// Offloads heavy JSON decoding and DTO mapping to a separate Isolate in ONE batch
  static Future<List<TransactionDto>> parseTransactions(String rawJson) async {
    return Isolate.run(() {
      // Executed entirely on a background Isolate
      final List<dynamic> decodedList = jsonDecode(rawJson) as List<dynamic>;

      // Batch mapping inside the isolate loop
      return decodedList
          .map((json) => TransactionDto.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }
}

```

---

## 2. Long-Lived Background Workers (`Isolate.spawn` + Ports)

Use `Isolate.spawn()` with a bidirectional `ReceivePort` / `SendPort` channel for continuous, repeated background execution (e.g., streaming socket transformations, chunked parsing).

```dart
import 'dart:async';
import 'dart:isolate';

abstract final class BackgroundWorkerService {
  Isolate? _isolate;
  SendPort? _sendPort;
  ReceivePort? _receivePort;

  final _responseController = StreamController<WorkerResponse>.broadcast();
  Stream<WorkerResponse> get results => _responseController.stream;

  Future<void> init() async {
    if (_isolate != null) return;

    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_workerEntryPoint, _receivePort!.sendPort);

    final events = _receivePort!.asBroadcastStream();
    _sendPort = await events.first as SendPort;

    events.listen((message) {
      if (message is WorkerResponse) {
        _responseController.add(message);
      }
    });
  }

  void sendTask(WorkerTask task) {
    final sendPort = _sendPort;
    if (sendPort == null) throw StateError('Worker is not initialized.');
    sendPort.send(task);
  }

  /// Entry point (Must be top-level or static)
  static void _workerEntryPoint(SendPort mainSendPort) {
    final workerReceivePort = ReceivePort();
    mainSendPort.send(workerReceivePort.sendPort);

    workerReceivePort.listen((message) {
      if (message is WorkerTask) {
        final result = _processHeavyTask(message);
        mainSendPort.send(result);
      }
    });
  }

  static WorkerResponse _processHeavyTask(WorkerTask task) {
    // Heavy CPU computation
    return WorkerResponse(data: task.payload * 2);
  }

  void dispose() {
    _receivePort?.close();
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _responseController.close();
  }
}

```

---

## 3. Platform Channels in Isolates (`RootIsolateToken`)

When background Isolates need native Flutter plugins (e.g., SQLite, `SharedPreferences`, `PathProvider`):

```dart
import 'dart:isolate';
import 'package:flutter/services.dart';

class NativeBackgroundWorker {
  Future<void> start() async {
    final RootIsolateToken token = RootIsolateToken.instance!;
    await Isolate.spawn(_entryPoint, token);
  }

  static void _entryPoint(RootIsolateToken token) async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    // Native channels are now safe to call here
  }
}

```

---

## 4. Zero-Copy Binary Memory Transfer (`TransferableTypedData`)

For high-throughput binary buffers (e.g. large images, byte streams), eliminate memory duplication overhead:

```dart
import 'dart:isolate';
import 'dart:typed_data';

Future<Uint8List> processBinaryBuffer(Uint8List rawBytes) async {
  final transferable = TransferableTypedData.fromList([rawBytes]);

  return Isolate.run(() {
    final Uint8List bytes = transferable.materialize().asUint8List();
    // Perform heavy image/crypto manipulation on zero-copy bytes...
    return bytes;
  });
}

```

---

## 5. Main Isolate & `build()` Allocation Hygiene

Keep `build()` methods cheap to preserve 60/120 FPS parity:

- **NO Heavy Operations:** Never allocate large lists, parse JSON, or format complex strings directly inside `build()`.

- **Widget Allocation:** Use `const` constructors aggressively to prevent unnecessary element re-instantiations.

- **Compositing Hygiene:** Avoid heavy compositing layers (like static `Opacity` or complex `ClipRRect`/`ClipPath`) inside animated hot paths.

---

## Anti-Patterns (Strictly Prohibited)

| Anti-Pattern                                                   | Severity     | Corrective Action                                          |
| -------------------------------------------------------------- | ------------ | ---------------------------------------------------------- |
| Calling `Isolate.run` / `compute` inside a loop per array item | **CRITICAL** | Batch the entire collection and run a single Isolate task. |

|
| Spawning Isolates inside BLoC, Cubit, or UI Widgets | **CRITICAL** | Move Isolate management to `Infrastructure` or `Data` layer services. |
| Forgetting to call `isolate.kill()` or `receivePort.close()` | **HIGH** | Always dispose ports and terminate workers when disposing services.

|
| Allocating large objects or parsing strings inside `build()` | **HIGH** | Move allocations outside `build()` or compute in an Isolate.

|
| Capturing large external state objects inside `Isolate.run` closure | **MEDIUM** | Pass explicit primitive arguments to avoid copying large object graphs.

|

---

## Agent Verification Checklist

When reviewing code utilizing Isolates or handling heavy workloads:

1. **Architectural Isolation:** Isolate code resides strictly inside `Infrastructure` / `Data` layers.
2. **No Iterative Spawning:** Confirm `Isolate.run` or `compute` is NOT executed inside a `for`/`forEach` loop.

3. **Resource Lifecycle:** Long-lived `Isolate.spawn` tasks have explicit `.kill()` and port `.close()` implementations.

4. **`build()` Cleanliness:** `build()` contains zero JSON parsing, heavy regex, or large collection allocations.

5. **Native Plugin Safety:** Native calls in background isolates use `RootIsolateToken` & `BackgroundIsolateBinaryMessenger`.
