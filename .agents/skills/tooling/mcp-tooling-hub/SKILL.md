---
name: mcp-tooling-hub
description: Master catalog and guide for Model Context Protocol (MCP) tooling in Antigravity IDE. Covers dart-mcp-server (hot_reload, hot_restart, widget_inspector, get_runtime_errors, analyze_files, lsp, pub_dev_search, rip_grep_packages, vm_service), firebase-mcp-server, and android-management-api. Use when choosing between MCP-accelerated IDE actions and CLI commands.
---

# MCP Tooling Hub: Accelerated IDE & Runtime Automation

## 1. Overview & Tooling Architecture

Antigravity IDE integrates native **Model Context Protocol (MCP)** servers that provide direct, high-speed programmatic access to runtime daemons, IDE services, analysis servers, and cloud providers.

Using MCP tools instead of traditional shell commands yields significant benefits:
- **Zero Process Overhead:** Instant execution without spawning cold CLI processes.
- **Structured JSON Payloads:** Type-safe programmatic responses without fragile text parsing.
- **Stateful Introspection:** Live connection to running Flutter VMs, render trees, and Dart Tooling Daemons (DTD).

```mermaid
graph TD
    Agent["Antigravity Agent"]
    
    subgraph "Dart & Flutter MCP Server (dart-mcp-server)"
        Agent -->|Hot reload / restart| HR["hot_reload / hot_restart"]
        Agent -->|Widget tree & constraints| WI["widget_inspector"]
        Agent -->|Active stack traces| RE["get_runtime_errors"]
        Agent -->|Symbols & diagnostics| LSP["lsp / analyze_files"]
        Agent -->|Package & dependency lookup| PUB["pub_dev_search / rip_grep_packages"]
        Agent -->|VM metrics & timeline| VM["vm_service / dtd"]
    end
    
    subgraph "Firebase MCP Server (firebase-mcp-server)"
        Agent -->|Project & SDK config| FB_CFG["firebase_get_sdk_config / firebase_init"]
        Agent -->|Security rules & deploy| FB_DEP["firebase_get_security_rules / firebase_deploy"]
    end

    subgraph "Android Management API"
        Agent -->|Device & policy inspection| AND["get_device / list_devices / get_policy"]
    end
```

---

## 2. Connected MCP Servers & Capabilities Catalog

### 2.1 `dart-mcp-server` (Dart & Flutter SDK Core)

| Tool Name | Scope & Purpose | Recommended Use Cases |
| :--- | :--- | :--- |
| `hot_reload` | Triggers sub-second hot reload on running Flutter app. | Instant visual feedback after UI, style, or method body changes. |
| `hot_restart` | Reinitializes app state without rebuilding native binary. | Resetting stateful services, BLoCs, or top-level initializers. |
| `widget_inspector` | Inspects widget tree, render objects, layout bounds, and flex constraints. | Diagnosing layout overflows, unbounded heights, and tree depth. |
| `get_runtime_errors` | Fetches active exceptions, FlutterError details, and stack traces. | Real-time bug investigation during live debugging sessions. |
| `analyze_files` | Runs fast in-memory static analysis across specified file URIs. | Verifying single or multi-file changes before full workspace builds. |
| `lsp` | Language Server Protocol integration for symbol navigation and definitions. | Finding symbol references, definitions, and code completion context. |
| `pub_dev_search` | Queries pub.dev repository for package metadata, scores, and versions. | Researching verified packages and resolving version constraints. |
| `rip_grep_packages` | Greps directly inside cached third-party dependencies and Flutter SDK. | Inspecting external package source code and method signatures. |
| `read_package_uris` | Reads resolved source contents for `package:...` URIs. | Reading underlying third-party source files without manual file path resolution. |
| `vm_service` | Direct RPC communication with Dart VM Service. | Frame timing, memory allocation profiling, and isolate inspection. |
| `flutter_driver_command`| Dispatches programmatic driver commands to running integration tests. | End-to-end user interaction simulation and widget verification. |
| `dtd` | Interfaces with Dart Tooling Daemon. | Workspace-level tool coordination and editor synchronization. |

### 2.2 `firebase-mcp-server` (Firebase Cloud Ecosystem)

| Tool Name | Scope & Purpose |
| :--- | :--- |
| `firebase_get_sdk_config` | Retrieves platform SDK configuration (`google-services.json`, `GoogleService-Info.plist`). |
| `firebase_get_security_rules` | Audits and inspects Firestore and Storage security rules. |
| `firebase_deploy` | Deploys rules, functions, or hosting configurations. |
| `developerknowledge_*` | Queries official Firebase documentation and architectural patterns. |

### 2.3 `android-management-api` (Device & Enterprise)

| Tool Name | Scope & Purpose |
| :--- | :--- |
| `get_device` / `list_devices` | Inspects connected Android test devices, OS levels, and state. |
| `get_policy` / `list_policies` | Audits Android security policies and application permissions. |

---

## 3. Decision Matrix: MCP vs Terminal CLI

```mermaid
graph TD
    Start["Task Requirement"] --> Q1{"Is the Flutter app currently running?"}
    
    Q1 -->|Yes| Q2{"What is the goal?"}
    Q2 -->|Update UI / State| M1["Call MCP: hot_reload / hot_restart"]
    Q2 -->|Investigate Crash / Overflow| M2["Call MCP: get_runtime_errors / widget_inspector"]
    Q2 -->|Profile Performance / FPS| M3["Call MCP: vm_service"]
    
    Q1 -->|No| Q3{"What is the action?"}
    Q3 -->|Verify Single File Syntax| M4["Call MCP: analyze_files / lsp"]
    Q3 -->|Find New Package on pub.dev| M5["Call MCP: pub_dev_search"]
    Q3 -->|Inspect External Library Source| M6["Call MCP: rip_grep_packages / read_package_uris"]
    Q3 -->|Full Workspace CI Validation| C1["Run CLI: dart analyze . && flutter test"]
    Q3 -->|Code Generation| C2["Run CLI: flutter pub run build_runner build"]
```

---

## 4. MCP Accelerated Workflows

### 4.1 Accelerated UI Debugging & Layout Fixes
1. **Detect Error:** Call `get_runtime_errors` to extract active exception stack trace.
2. **Inspect Tree:** Call `widget_inspector` on the offending widget to check render bounds and constraints.
3. **Apply Code Edit:** Fix layout using `replace_file_content` (e.g. wrap in `Expanded` or use `CustomScrollView`).
4. **Instant Verification:** Call `hot_reload` to verify fix without restarting app.

### 4.2 Dependency Resolution & SDK Investigation
1. **Search Package:** Call `pub_dev_search` with target query to get official version and popularity.
2. **Inspect Implementation:** Call `rip_grep_packages` to review actual Dart source code inside the dependency.
3. **Add Dependency:** Update `pubspec.yaml` and verify compatibility.

---

## 5. Related Skills & Hubs

| Hub / Skill | Focus Area |
| :--- | :--- |
| [dart-fix-runtime-errors](../../dart-fix-runtime-errors/SKILL.md) | Runtime error resolution via `get_runtime_errors` & `hot_reload`. |
| [flutter-fix-layout-issues](../../flutter-fix-layout-issues/SKILL.md) | Layout constraint debugging via `widget_inspector`. |
| [dart-run-static-analysis](../../dart-run-static-analysis/SKILL.md) | Code quality validation with `analyze_files` and `lsp`. |
| [dart-resolve-package-conflicts](../../dart-resolve-package-conflicts/SKILL.md) | Package exploration with `pub_dev_search` and `rip_grep_packages`. |
| [performance-hub](../../performance/performance-hub/SKILL.md) | Frame rate and memory analysis with `vm_service`. |
