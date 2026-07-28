---
name: flutter-build-runner
description: Manages code generation workflows using build_runner, cache clearing, watch mode execution, and CI/CD generated file verification. Use when executing code generators, clearing conflicting outputs, troubleshooting code gen failures, or validating generated files in CI.
---

# Flutter Build Runner & Code Generation Skill

## When to Apply

Use this skill whenever running code generation for `freezed`, `json_serializable`, `retrofit`, `injectable`, `auto_route`, or `flutter_gen`, resolving build runner cache conflicts, or setting up CI pipeline verification checks.

---

## 1. Local Code Generation Commands

### Standard Build (One-off)

Use to generate code for modified files with automatic deletion of conflicting outputs:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Clean & Rebuild (Cache Clearing)

If `build_runner` crashes due to corrupted cache or stale artifacts:

```bash
flutter pub run build_runner clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Watch Mode (Development)

For real-time code generation during active development:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

---

## 2. CI/CD Verification Workflow

To guarantee that all generated files (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `lib/l10n/generated/**`) are up-to-date in pull requests and zero uncommitted code generation changes exist:

### CI Pipeline Step Example (GitHub Actions / GitLab CI)

```yaml
- name: Install Dependencies
  run: flutter pub get

- name: Run Code Generation
  run: flutter pub run build_runner build --delete-conflicting-outputs

- name: Verify No Generated Files Changed
  run: |
    if [ -n "$(git status --porcelain)" ]; then
      echo "Error: Uncommitted generated code detected! Please run build_runner locally and commit changes."
      git status --porcelain
      exit 1
    fi
```

---

## 3. Best Practices & Troubleshooting

1. **Excluded Files:** Never manually edit generated files (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`).
2. **Conflict Resolution:** Always append `--delete-conflicting-outputs` to avoid manual prompt hangs in automated environments.
3. **Analysis Exclusions:** Ensure `analysis_options.yaml` excludes `lib/**.g.dart` and `lib/l10n/generated/**` so linter warnings don't block builds.
