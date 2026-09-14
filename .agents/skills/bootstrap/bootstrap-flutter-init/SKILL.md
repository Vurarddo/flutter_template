---
name: bootstrap-flutter-init
description: Handles the first phase of project creation. Prompts user to upgrade Flutter SDK to latest stable, gathers project parameters (name, organization, platforms), and executes `flutter create` with strict arguments. Use when initializing a new Flutter project from scratch.
---

# Flutter Initialization & Environment Setup

## 1. Overview & When to Apply

Use this skill to execute the foundational step of creating a new Flutter project:
- Verifying and optionally upgrading the Flutter SDK to the latest stable release.
- Gathering project metadata: project name, reverse-domain organization identifier, and target deployment platforms (Android, iOS, Web, macOS, Windows, Linux).
- Executing `flutter create` with clean, non-conflicting arguments.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [project-bootstrap-hub](../project-bootstrap-hub/SKILL.md) | Master coordinator for project bootstrapping. |
| **Next Step** | [bootstrap-dependencies-sync](../bootstrap-dependencies-sync/SKILL.md) | Injecting standard template packages into `pubspec.yaml`. |

---

## 3. Step-by-Step Initialization Workflow

### Step 1: Flutter SDK Version Verification & Upgrade

1. Check current Flutter and Dart versions:
   ```bash
   flutter --version
   ```
2. Prompt the user if they wish to upgrade to the latest stable release:
   - If **Yes**:
     ```bash
     flutter channel stable
     flutter upgrade
     ```
   - If **No**: Proceed with the existing installed version.

---

### Step 2: Project Parameters Discovery

Collect the following parameters before executing project generation:

| Parameter | Example | Flag in `flutter create` | Description |
| :--- | :--- | :--- | :--- |
| **Project Name** | `my_app` | `<project_name>` | Lowercase with underscores (snake_case), valid Dart identifier. |
| **Organization** | `com.example` | `--org <org>` | Reverse domain name for bundle ID & applicationId. |
| **Domain Purpose / Description** | `"Production Flutter Application."` | `--description "<desc>"` | Domain summary for `pubspec.yaml` and initial architecture context. |
| **Platforms** | `android,ios,web,macos` | `--platforms android,ios,web,macos` | Comma-separated list of target platforms. |
| **Project Template** | `app` | `-t app` | Standard Flutter application template. |

---

### Step 3: Executing `flutter create`

Run the generation command:

```bash
flutter create \
  --org com.example \
  --project-name my_app \
  --description "Production Flutter Application." \
  --platforms android,ios,web,macos,windows,linux \
  --empty \
  .
```

> [!TIP]
> Using `--empty` or creating within the current target directory prevents boilerplate counter sample clutter while retaining necessary native project files (`android/`, `ios/`, `web/`, etc.).

---

## 4. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Creating project without explicit `--org` | **HIGH** | Always specify `--org` to prevent default `com.example` collisions in production store releases. |
| Omitting target `--platforms` | **MEDIUM** | Explicitly define required platforms to avoid generating unnecessary desktop/web directories if targeting mobile only. |
| Using dashes or uppercase in project name | **CRITICAL** | Dart package names must strictly be lowercase snake_case (`my_app`, not `my-app` or `MyApp`). |

---

## 5. Verification Checklist

- [ ] Flutter SDK version checked and confirmed.
- [ ] Project name is valid lowercase snake_case.
- [ ] Native platform folders (`android/`, `ios/`, etc.) generated with proper package identifier.
- [ ] Ready to proceed to [bootstrap-dependencies-sync](../bootstrap-dependencies-sync/SKILL.md).
