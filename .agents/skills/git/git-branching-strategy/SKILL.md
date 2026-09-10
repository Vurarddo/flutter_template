---
name: git-branching-strategy
description: Implements strict GitFlow branching strategy, branch naming conventions, release preparation, hotfix workflows, and Semantic Versioning (SemVer) release tagging. Use when creating branches, preparing release candidates, creating hotfixes, or tagging releases.
---

# GitFlow Branching Strategy & Release Management

## 1. Overview & When to Apply

Use this skill whenever:
- Creating new branches for features, bugfixes, releases, or hotfixes.
- Following the standardized **GitFlow** branching model (`master`, `develop`, `feature/*`, `release/*`, `hotfix/*`).
- Enforcing consistent branch naming conventions.
- Preparing a production release candidate (`release/vX.Y.Z`) and syncing changes back to `develop`.
- Applying critical production hotfixes (`hotfix/vX.Y.Z`).
- Creating annotated Semantic Versioning tags (`git tag -a v1.2.0`).

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [git-workflow-hub](../git-workflow-hub/SKILL.md) | Central GitFlow workflow and rules. |
| **Commit Standards** | [git-commit-standards](../git-commit-standards/SKILL.md) | Writing Conventional Commits on feature branches. |
| **Rebase & Merge** | [git-rebase-conflict-resolution](../git-rebase-conflict-resolution/SKILL.md) | Rebasing feature branches prior to merge. |
| **Hygiene** | [git-hygiene-recovery](../git-hygiene-recovery/SKILL.md) | Cleaning up local merged branches. |

---

## 3. Branch Naming & Role Standards

| Branch Type | Base Branch | Merges Into | Naming Convention | Example |
| :--- | :--- | :--- | :--- | :--- |
| **Production** | — | — | `master` or `main` | `master` |
| **Development** | `master` | `master` | `develop` | `develop` |
| **Feature** | `develop` | `develop` | `feature/<name>` or `feature/<issue>-<name>` | `feature/PROJ-42-biometrics-auth` |
| **Bugfix** | `develop` | `develop` | `bugfix/<name>` or `fix/<name>` | `bugfix/PROJ-99-token-refresh` |
| **Release** | `develop` | `master` AND `develop` | `release/v<MAJOR>.<MINOR>.<PATCH>` | `release/v1.2.0` |
| **Hotfix** | `master` | `master` AND `develop` | `hotfix/v<MAJOR>.<MINOR>.<PATCH>` | `hotfix/v1.2.1` |

---

## 4. Workflows

### 4.1 Feature Development Workflow
```bash
# 1. Update local develop
git checkout develop
git pull origin develop

# 2. Create feature branch
git checkout -b feature/PROJ-12-wallet-balance

# 3. Work and commit
git commit -m "feat(wallet): add balance card widget"

# 4. Rebase on develop before opening PR
git fetch origin
git rebase origin/develop

# 5. Push branch
git push -u origin feature/PROJ-12-wallet-balance
```

### 4.2 Release Workflow (`release/vX.Y.Z`)
When features in `develop` are ready for production release:

```bash
# 1. Create release branch from develop
git checkout develop
git pull origin develop
git checkout -b release/v1.3.0

# 2. Perform release tasks (bump pubspec.yaml version, update CHANGELOG.md)
git commit -m "chore(release): prepare v1.3.0 release candidate"

# 3. Merge release into master and tag
git checkout master
git pull origin master
git merge --no-ff release/v1.3.0 -m "chore(release): merge release v1.3.0 into master"
git tag -a v1.3.0 -m "Release version 1.3.0"

# 4. Sync release back into develop
git checkout develop
git merge --no-ff release/v1.3.0 -m "chore(release): sync v1.3.0 back to develop"

# 5. Push branches and tags
git push origin master develop --tags

# 6. Delete release branch
git branch -d release/v1.3.0
```

### 4.3 Critical Hotfix Workflow (`hotfix/vX.Y.Z`)
When a critical bug is discovered in production (`master`):

```bash
# 1. Branch from master
git checkout master
git pull origin master
git checkout -b hotfix/v1.3.1

# 2. Fix bug and bump patch version in pubspec.yaml
git commit -m "fix(auth): prevent null crash during token expiration"

# 3. Merge hotfix into master and tag
git checkout master
git merge --no-ff hotfix/v1.3.1 -m "chore(hotfix): merge v1.3.1 into master"
git tag -a v1.3.1 -m "Hotfix version 1.3.1"

# 4. Merge hotfix back into develop
git checkout develop
git pull origin develop
git merge --no-ff hotfix/v1.3.1 -m "chore(hotfix): sync v1.3.1 to develop"

# 5. Push updates and tags
git push origin master develop --tags

# 6. Delete hotfix branch
git branch -d hotfix/v1.3.1
```

---

## 5. Semantic Versioning (SemVer) Rules

Follow `v<MAJOR>.<MINOR>.<PATCH>`:
- **MAJOR:** Incompatible API changes or complete architectural overhauls (e.g. `v2.0.0`).
- **MINOR:** Backward-compatible new features (e.g. `v1.1.0`).
- **PATCH:** Backward-compatible bug fixes and stability improvements (e.g. `v1.1.1`).

---

## 6. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Branching a feature directly from `master` | **CRITICAL** | Branch all features strictly from `develop`. |
| Branching a hotfix from `develop` | **CRITICAL** | Branch hotfixes strictly from `master`. |
| Forgetting to merge `release` or `hotfix` back into `develop` | **HIGH** | Always merge back into both `master` AND `develop`. |
| Unannotated lightweight tags (`git tag v1.0.0`) | **MEDIUM** | Use annotated tags: `git tag -a v1.0.0 -m "Release 1.0.0"`. |
| Non-standard branch names (e.g. `my-changes`, `fix1`) | **MEDIUM** | Use standard prefixes: `feature/`, `bugfix/`, `release/`, `hotfix/`. |

---

## 7. Branching Verification Checklist

- [ ] Feature branch was created from `develop`.
- [ ] Hotfix branch was created from `master`.
- [ ] Branch name uses valid prefix and kebab-case identifier.
- [ ] Release branch is merged into both `master` AND `develop`.
- [ ] Release is tagged with an annotated SemVer tag (`git tag -a vX.Y.Z`).
