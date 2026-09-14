---
name: flutter-isolates
description: Enforces high-performance Isolate patterns in Dart/Flutter. Guarantees zero Main Thread blocking (60/120 FPS parity), strict Clean Architecture placement (Data/Infrastructure layers only), proper usage of Isolate.run for short tasks vs Isolate.spawn for long-running workers, zero-copy TransferableTypedData memory transfers, RootIsolateToken setup, and strict batching over loop spawns. Use when parsing large payloads, offloading heavy CPU computations, or handling binary/crypto/image processing.
---

# Flutter Isolates & Parallelism Expert Guide

## 1. Overview & When to Apply

Use this skill whenever:
- Parsing large network/database JSON payloads (> 100KB).
- Offloading CPU-heavy computations (image resizing/decoding, cryptography, complex matrix math).
- Managing long-running background tasks with continuous socket streams or worker queues.
- Initializing native background plugins via `RootIsolateToken`.

---

## 2. Core Architectural Rules

1. **Layer Boundary:** Isolates belong strictly in **Infrastructure** or **Data** layers. Never spawn isolates inside Presentation widgets or Domain UseCases.
2. **Strict Batching Rule:** Never call `Isolate.run()` inside a loop. Pass the entire list or batch into the isolate execution.
3. **Threshold Guard:** Do not spawn Isolates for tiny tasks (< 1-2ms) to avoid memory transfer overhead.

---

## 3. Reference Implementations (`examples/`)

- **Short-Lived Heavy Batch Parser (`Isolate.run`):** [examples/isolate_payload_parser.dart](examples/isolate_payload_parser.dart)
  - Batch decoding and mapping in background without UI stutter.
- **Long-Lived Background Worker (`Isolate.spawn`):** [examples/background_worker_service.dart](examples/background_worker_service.dart)
  - Bidirectional communication using `ReceivePort` / `SendPort` with proper `dispose()`.

---

## 4. Verification Checklist

- [ ] Isolates isolated inside Data / Infrastructure layers.
- [ ] No `Isolate.run()` spawned inside loops.
- [ ] Long-lived workers cleanly dispose of `ReceivePort` and kill isolate instances.
- [ ] Native channel workers initialized with `BackgroundIsolateBinaryMessenger.ensureInitialized(token)`.
