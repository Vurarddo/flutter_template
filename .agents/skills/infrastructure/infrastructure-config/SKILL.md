---
name: infrastructure-config
description: Standards for environment configuration and secrets management in lib/infrastructure/config/. Covers --dart-define-from-file, strongly-typed AppConfig, AppEnvironment enum (dev, staging, prod), and Git security hygiene.
---

# Infrastructure Environment Configuration & Secrets

## 1. Overview & When to Apply

Use this skill whenever:
- Defining or reading environment variables (`BASE_URL`, `API_KEY`, `APP_ENV`, `SENTRY_DSN`).
- Adding new flavors / environments (`dev`, `staging`, `prod`) to `AppEnvironment`.
- Structuring `AppConfig` using `String.fromEnvironment` / `bool.fromEnvironment`.
- Managing `.env` / `config/env_*.json` files securely per project rules.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [infrastructure-hub](../infrastructure-hub/SKILL.md) | Infrastructure architecture and layer rules. |
| **Dio Networking** | [infrastructure-network-dio](../infrastructure-network-dio/SKILL.md) | Consuming `AppConfig.baseUrl` in `BaseOptions`. |

---

## 3. Standard Implementation Patterns

### 3.1 `AppEnvironment` Enum (`app_environment.dart`)

```dart
enum AppEnvironment {
  dev('dev'),
  staging('staging'),
  prod('prod');

  final String value;
  const AppEnvironment(this.value);

  static AppEnvironment fromString(String env) {
    return AppEnvironment.values.firstWhere(
      (e) => e.value.toLowerCase() == env.toLowerCase(),
      orElse: () => AppEnvironment.dev,
    );
  }

  bool get isDev => this == AppEnvironment.dev;
  bool get isStaging => this == AppEnvironment.staging;
  bool get isProd => this == AppEnvironment.prod;
}
```

---

### 3.2 Strongly-Typed `AppConfig` (`app_config.dart`)

```dart
import 'package:flutter_template/infrastructure/config/app_environment.dart';

abstract final class AppConfig {
  static final AppEnvironment environment = AppEnvironment.fromString(
    const String.fromEnvironment('APP_ENV', defaultValue: 'dev'),
  );

  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api-dev.example.com',
  );

  static const String apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: '',
  );

  static const bool enableLogging = bool.fromEnvironment(
    'ENABLE_LOGGING',
    defaultValue: true,
  );

  static const int connectTimeoutSeconds = int.fromEnvironment(
    'CONNECT_TIMEOUT_SECONDS',
    defaultValue: 15,
  );
}
```

---

### 3.3 Configuration Template (`config/env_template.json`)

Always provide a sanitized template in the repository:

```json
{
  "APP_ENV": "dev",
  "BASE_URL": "https://api-dev.example.com",
  "API_KEY": "YOUR_DEV_API_KEY_HERE",
  "ENABLE_LOGGING": true
}
```

Execution command:
```bash
flutter run --dart-define-from-file=config/env_dev.json
```

---

## 4. Git Security & Client Key Hygiene

- **Rule 1:** Real environment files (`config/env_dev.json`, `config/env_prod.json`) MUST be in `.gitignore`.
- **Rule 2:** NEVER store true private server secrets (e.g. Stripe private keys, database passwords, backend signing keys) in client code.
- **Rule 3:** All environment fields in Dart must use `const String.fromEnvironment` / `const bool.fromEnvironment`.

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Hardcoding API endpoints or keys directly in Dart files | **CRITICAL** | Extract to `AppConfig` and supply via `--dart-define-from-file`. |
| Committing real credentials to Git | **CRITICAL** | Add `config/env_*.json` to `.gitignore`. |
| Reading environment variables at runtime with non-const methods | **MEDIUM** | Use `const String.fromEnvironment` to allow tree-shaking. |

---

## 6. Verification Checklist

- [ ] `AppConfig` uses strongly-typed getters and `const fromEnvironment`.
- [ ] `.gitignore` contains `config/env_*.json` (excluding `env_template.json`).
- [ ] `AppEnvironment` has unit tests verifying fallback to `dev`.
