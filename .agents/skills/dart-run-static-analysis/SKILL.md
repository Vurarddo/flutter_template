---
name: dart-run-static-analysis
description: Execute `dart analyze` to identify warnings and errors, and use `dart fix --apply` to automatically resolve mechanical lint issues. Use during development to ensure code quality and before committing changes.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Fri, 24 Apr 2026 15:09:34 GMT
---
# Analyzing and Fixing Dart Code

## Contents
- [Analysis Configuration](#analysis-configuration)
- [Diagnostic Suppression](#diagnostic-suppression)
- [Workflow: Executing Static Analysis](#workflow-executing-static-analysis)
- [Workflow: Applying Automated Fixes](#workflow-applying-automated-fixes)
- [Examples](#examples)

## Analysis Configuration

Configure the Dart analyzer using the `analysis_options.yaml` file located at the package root.

- **Base Configuration:** Always include a standard rule set (e.g., `package:lints/recommended.yaml` or `package:flutter_lints/flutter.yaml`) using the `include:` directive.
- **Strict Type Checks:** Enable strict type checks under the `analyzer: language:` node to prevent implicit downcasts and dynamic inferences. Set `strict-casts: true`, `strict-inference: true`, and `strict-raw-types: true`.
- **Linter Rules:** Explicitly enable or disable specific rules under the `linter: rules:` node. Use a key-value map (`rule_name: true/false`) when overriding included rules, or a list (`- rule_name`) when defining a fresh set. Do not mix list and map syntax in the same `rules` block.
- **Formatter Configuration:** Configure `dart format` behavior under the `formatter:` node. Set `page_width` (default 80) and `trailing_commas` (`automate` or `preserve`).
- **Analyzer Plugins:** Enable custom diagnostics by adding plugins under the `analyzer: plugins:` node. Ensure the plugin package is added as a `dev_dependency` in `pubspec.yaml`.

## Diagnostic Suppression

When a diagnostic (lint or warning) yields a false positive or applies to generated code, suppress it explicitly.

- **File-level Exclusion:** Use the `analyzer: exclude:` node in `analysis_options.yaml` to exclude entire files or directories (e.g., `**/*.g.dart`) using glob patterns.
- **File-level Suppression:** Add `// ignore_for_file: <diagnostic_code>` at the top of a Dart file to suppress specific diagnostics for the entire file. Use `// ignore_for_file: type=lint` to suppress all linter rules.
- **Line-level Suppression:** Add `// ignore: <diagnostic_code>` on the line directly above the offending code, or appended to the end of the offending line.
- **Pubspec Suppression:** Add `# ignore: <diagnostic_code>` above the offending line in `pubspec.yaml` files (e.g., `# ignore: sort_pub_dependencies`).
- **Plugin Diagnostics:** Prefix the diagnostic code with the plugin name when suppressing plugin-specific issues (e.g., `// ignore: some_plugin/some_code`).

## Workflow: Executing Static Analysis

Use this workflow to identify type-related bugs, style violations, and potential runtime errors.

### MCP Tooling & Accelerated Analysis

Antigravity IDE integrates Dart analyzer daemons directly:
- **Fast In-Memory Analysis (`analyze_files`):** Call MCP `analyze_files` with specific file URIs to validate single-file edits instantly without waiting for a full workspace CLI scan.
- **Language Server Diagnostics (`lsp`):** Use MCP `lsp` to query live compilation errors, symbol definitions, and completions.
- **Master Reference:** See [mcp-tooling-hub](../tooling/mcp-tooling-hub/SKILL.md) for full MCP server details.

**Task Progress:**
- [ ] 1. Verify `analysis_options.yaml` exists at the project root.
- [ ] 2. Run in-memory analysis via MCP `analyze_files` for modified files, or run full CLI validation: `dart analyze .`.
- [ ] 3. Review diagnostic output and resolve critical errors.
- [ ] 4. If info-level issues must be treated as failures in CI, append `--fatal-infos`.
- [ ] 5. Run `flutter pub run import_sorter:main` to enforce import ordering.
- [ ] 6. Resolve reported errors manually or proceed to the Automated Fixes workflow.

## Workflow: Applying Automated Fixes

Use this workflow to resolve outdated API usages, apply quick fixes, and migrate code (e.g., Dart 3 migrations).

**Task Progress:**
- [ ] 1. Execute a dry run to preview proposed changes using the `dart_fix` MCP tool or CLI command `dart fix --dry-run`.
- [ ] 2. Review the proposed fixes to ensure they align with the intended architecture.
- [ ] 3. If additional fixes are required, verify that the corresponding linter rules are enabled in `analysis_options.yaml`.
- [ ] 4. Apply the fixes using the `dart_fix` MCP tool or CLI command `dart fix --apply`.
- [ ] 5. Format the modified code using the `dart_format` MCP tool or CLI command `dart format .`.
- [ ] 6. Run the static analysis workflow to verify all diagnostics are resolved.

## Examples

### Production `analysis_options.yaml` (Template Standard)

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - build/**
    - lib/**.g.dart
    - lib/l10n/generated/**
    - android/**
    - ios/**
    - web/**
    - windows/**
    - macos/**
    - linux/**
  errors:
    invalid_annotation_target: ignore

linter:
  rules:
    annotate_overrides: false
    constant_identifier_names: false
    no_leading_underscores_for_library_prefixes: false
    prefer_const_constructors: true

bloc:
  rules:
    avoid_flutter_imports: true
    avoid_public_bloc_methods: true
    avoid_public_fields: true
    prefer_void_public_cubit_methods: true

formatter:
  trailing_commas: preserve
  page_width: 100
```

### Inline Diagnostic Suppression

```dart
// Suppress for the entire file
// ignore_for_file: unused_local_variable, dead_code

void processData() {
  // Suppress for a specific line
  // ignore: invalid_assignment
  int x = '';
  
  const y = 10; // ignore: constant_identifier_names
}
```
