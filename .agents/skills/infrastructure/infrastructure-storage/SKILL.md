---
name: infrastructure-storage
description: Standards and patterns for storage interactors in lib/infrastructure/storage/ (or lib/infrastructure/utils/storage/). Covers SecureStoreInteractor (flutter_secure_storage) for tokens/PII, StoreInteractor (shared_preferences) for UI preferences, and reactive storage streams.
---

# Infrastructure Storage Interactors

## 1. Overview & When to Apply

Use this skill whenever:
- Storing sensitive credentials (auth tokens, refresh tokens, biometric keys) using `flutter_secure_storage`.
- Storing non-sensitive user preferences (active theme mode, locale, onboarding completion, filter settings) using `shared_preferences`.
- Implementing `SecureStoreInteractor` and `StoreInteractor` abstraction classes.
- Creating reactive storage streams for listening to local key changes.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [infrastructure-hub](../infrastructure-hub/SKILL.md) | Infrastructure layer architecture. |
| **DI Setup** | [infrastructure-di](../infrastructure-di/SKILL.md) | Registering storage interactors and `@preResolve` SharedPreferences. |
| **Network Interceptors** | [infrastructure-network-dio](../infrastructure-network-dio/SKILL.md) | Reading tokens for `AuthInterceptor`. |

---

## 3. Storage Division Standard

| Storage Type | Technology | Allowed Data | Banned Data |
| :--- | :--- | :--- | :--- |
| **Secure Storage** | `FlutterSecureStorage` (`Keychain` / `EncryptedSharedPreferences`) | Access tokens, Refresh tokens, PIN/biometrics, private session IDs. | Large JSON blobs, caching, image bytes. |
| **Shared Preferences** | `SharedPreferences` (`NSUserDefaults` / `XML prefs`) | Theme mode, language code, onboarding seen flag, active tab index. | Auth tokens, passwords, user PII, credit cards. |

---

## 4. Standard Implementation Patterns

### 4.1 Secure Store Interactor (`secure_store_interactor.dart`)

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SecureStoreInteractor {
  final FlutterSecureStorage _storage;

  static const _keyAccessToken = 'auth_access_token';
  static const _keyRefreshToken = 'auth_refresh_token';

  SecureStoreInteractor(this._storage);

  Future<String?> getAccessToken() => _storage.read(key: _keyAccessToken);
  Future<String?> getRefreshToken() => _storage.read(key: _keyRefreshToken);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
    ]);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
    ]);
  }

  Future<void> clearAll() => _storage.deleteAll();
}
```

---

### 4.2 Shared Preferences Store Interactor (`store_interactor.dart`)

```dart
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class StoreInteractor {
  final SharedPreferences _prefs;

  static const _keyThemeMode = 'app_theme_mode';
  static const _keyLocale = 'app_locale';
  static const _keyOnboardingSeen = 'app_onboarding_seen';

  StoreInteractor(this._prefs);

  String? getThemeMode() => _prefs.getString(_keyThemeMode);
  Future<bool> setThemeMode(String mode) => _prefs.setString(_keyThemeMode, mode);

  String? getLocale() => _prefs.getString(_keyLocale);
  Future<bool> setLocale(String localeCode) => _prefs.setString(_keyLocale, localeCode);

  bool isOnboardingSeen() => _prefs.getBool(_keyOnboardingSeen) ?? false;
  Future<bool> setOnboardingSeen({required bool seen}) =>
      _prefs.setBool(_keyOnboardingSeen, seen);

  Future<bool> clearAll() => _prefs.clear();
}
```

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Storing auth tokens or secrets in plain `SharedPreferences` | **CRITICAL** | Store exclusively in `SecureStoreInteractor` (`FlutterSecureStorage`). |
| Directly injecting raw `SharedPreferences` across multiple UI widgets | **HIGH** | Encapsulate access in `StoreInteractor` or feature Repositories. |
| Storing large database entities in `FlutterSecureStorage` | **MEDIUM** | Use SQLite / Drift / Isar for offline DB; store only encryption key in secure storage. |

---

## 6. Verification Checklist

- [ ] Tokens and secrets use `FlutterSecureStorage` with hardware encryption enabled.
- [ ] Non-sensitive UI preferences use `SharedPreferences`.
- [ ] Storage interactors are registered as `@lazySingleton` via `injectable`.
- [ ] `clearTokens()` and `clearAll()` methods exist for secure user logout flow.
