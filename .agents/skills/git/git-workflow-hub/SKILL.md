---
name: git-workflow-hub
description: Primary coordinator and architecture guide for Git version control in the project. Enforces GitFlow lifecycle (master, develop, feature, release, hotfix), Conventional Commits, branch protection rules, and pre-commit/pre-push quality gates. Use when starting a new task, preparing branches, committing code, rebasing, or opening Pull Requests.
---

# Git Workflow & GitFlow Master Coordinator

## 1. Overview & Golden Git Laws

This skill acts as the central coordinator for all version control, branching, and commit operations in the repository. It enforces the **GitFlow** branching methodology, **Conventional Commits**, and safe repository hygiene.

### 🛡️ Golden Repository Safety Rules:
1. **No Automatic `git push` by AI Agents:** AI agents are **STRICTLY PROHIBITED** from executing `git push` unless the user gives direct, explicit instruction (e.g. "запуш", "push", "запуш зміни"). Local commits (`git commit`) are allowed when finishing work, but remote pushes require explicit user confirmation.
2. **Never Force-Push to Protected Branches:** `git push --force` or `--force-with-lease` is **STRICTLY PROHIBITED** on `master`, `main`, and `develop`.
3. **Zero Secrets in Commits:** Local environment credentials (`config/env_*.json`), signing keystores (`*.jks`, `*.keystore`), and private tokens must NEVER be committed (enforce via `.gitignore`).
4. **Clean Working Tree Before Switching:** Always `git stash` or commit work before switching branches to prevent unstaged file pollution.
5. **Pre-Commit Quality Gate:** Code must pass `dart format`, `dart analyze`, and unit tests before committing and opening PRs.
6. **Linear & Clean History:** Feature branches must be rebased on top of the latest `origin/develop` before merging.

---

## 2. Git Skill Mesh & Routing Matrix

Use this matrix to navigate to the specialized sub-skill matching your Git operation:

| Task / Operation | Target Sub-Skill | When to Activate |
| :--- | :--- | :--- |
| **Writing Commits** | [git-commit-standards](../git-commit-standards/SKILL.md) | Structuring Conventional Commits (`feat`, `fix`, `refactor`), atomic commits, breaking change notation. |
| **Branching & Releases** | [git-branching-strategy](../git-branching-strategy/SKILL.md) | GitFlow lifecycle (`feature/*`, `release/*`, `hotfix/*`), branch naming, semantic version tags (`vX.Y.Z`). |
| **Rebase & Conflicts** | [git-rebase-conflict-resolution](../git-rebase-conflict-resolution/SKILL.md) | Interactive rebase (`git rebase -i`), squashing WIP commits, resolving merge conflicts cleanly. |
| **Hygiene & Recovery** | [git-hygiene-recovery](../git-hygiene-recovery/SKILL.md) | `.gitignore` rules, `git stash`, recovering lost work with `git reflog`, `git clean`, `cherry-pick`. |

---

## 3. GitFlow Lifecycle Overview

```mermaid
gitGraph
    commit id: "v1.0.0 (initial)"
    branch develop
    checkout develop
    commit id: "dev setup"
    
    branch feature/auth-flow
    checkout feature/auth-flow
    commit id: "feat(auth): add login bloc"
    commit id: "feat(auth): add login form UI"
    checkout develop
    merge feature/auth-flow id: "Merge feature/auth-flow"
    
    branch release/v1.1.0
    checkout release/v1.1.0
    commit id: "chore(release): bump version to 1.1.0"
    checkout master
    merge release/v1.1.0 id: "Merge release/v1.1.0 (v1.1.0 tag)"
    tag: "v1.1.0"
    checkout develop
    merge release/v1.1.0 id: "Sync release back to develop"
    
    checkout master
    branch hotfix/v1.1.1
    commit id: "fix(auth): resolve session token crash"
    checkout master
    merge hotfix/v1.1.1 id: "Merge hotfix/v1.1.1 (v1.1.1 tag)"
    tag: "v1.1.1"
    checkout develop
    merge hotfix/v1.1.1 id: "Sync hotfix back to develop"
```

### Standard Branch Roles:
- **`master` / `main`:** Production-ready code. Each merge is tagged with a semantic version (e.g. `v1.2.0`).
- **`develop`:** Integration branch for upcoming releases. All feature branches branch off and merge back here.
- **`feature/<name>`:** Temporary branch for building a specific feature or task.
- **`release/vX.Y.Z`:** Stabilization branch for finalizing a release, metadata updates, and version bumping.
- **`hotfix/vX.Y.Z`:** Critical production bug fixes branched directly from `master` and merged back into both `master` and `develop`.

---

## 4. End-to-End Feature Workflow

### Step 1: Start from Latest `develop`
```bash
git checkout develop
git pull origin develop
git checkout -b feature/user-profile-screen
```

### Step 2: Implement, Format & Stage
```bash
# Verify code quality before staging
dart format .
dart analyze

git add lib/presentation/pages/profile/
```

### Step 3: Commit Using Conventional Commits
```bash
git commit -m "feat(profile): implement user profile view and avatar selector"
```

### Step 4: Rebase onto Updated `develop` Before PR
```bash
git fetch origin
git rebase origin/develop

# If conflicts arise, resolve them and run:
# git add <resolved-files>
# git rebase --continue
```

### Step 5: Push and Open Pull Request
```bash
git push -u origin feature/user-profile-screen
```

---

## 5. Quality & Review Verification Checklist

Before pushing code or requesting a PR review:
- [ ] Working branch was created from the latest `origin/develop`.
- [ ] Code adheres to [code-review-advisor](../../code-review-advisor/SKILL.md) and Clean Architecture rules.
- [ ] Static analysis passes cleanly ([dart-run-static-analysis](../../dart-run-static-analysis/SKILL.md)): `dart analyze`.
- [ ] Unit & widget tests pass ([testing-hub](../../testing/testing-hub/SKILL.md)): `flutter test`.
- [ ] Code generation is up to date: `flutter pub run build_runner build --delete-conflicting-outputs`.
- [ ] Commit messages follow [git-commit-standards](../git-commit-standards/SKILL.md).
- [ ] History is clean of intermediate "wip" or "fix typo" commits via [git-rebase-conflict-resolution](../git-rebase-conflict-resolution/SKILL.md).
