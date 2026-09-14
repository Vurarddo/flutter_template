---
name: l10n-arb-icu
description: Standards and syntax for Application Resource Bundle (ARB) files and ICU message format in lib/l10n/. Covers camelCase naming conventions, typed placeholders, ICU plurals (zero, one, few, many, other for Slavic languages), ICU select formats, and metadata descriptors (@key).
---

# ARB & ICU Syntax Standard

## 1. Overview & When to Apply

Use this skill whenever:
- Adding or modifying localized strings in `lib/l10n/intl_en.arb` or `lib/l10n/intl_uk.arb`.
- Creating dynamic messages with variables, typed placeholders, and formatting.
- Implementing pluralized copy for English and Slavic languages (Ukrainian).
- Using ICU `select` expressions for gender, status, or enum values.
- Documenting strings with `@key` metadata and developer descriptions.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [l10n-hub](../l10n-hub/SKILL.md) | Overview and Clean Architecture boundaries. |
| **Code Generation** | [l10n-generation-workflow](../l10n-generation-workflow/SKILL.md) | Generating typed Dart classes from ARB files. |
| **Presentation Integration** | [l10n-presentation-integration](../l10n-presentation-integration/SKILL.md) | Consuming generated strings in Flutter widgets via `context.localization`. |

---

## 3. ARB Naming & Structure Conventions

1. **Key Naming:**
   - Always use **`camelCase`** (e.g., `appTitle`, `signInButtonLabel`, `itemsFoundCount`).
   - Group keys logically by feature prefix (e.g., `authLoginTitle`, `homeHeaderGreeting`, `settingsThemeDark`).
2. **Metadata Object (`@<key>`):**
   - Provide a `description` for translators and developers.
   - Specify `placeholders` with their Dart `type` (e.g., `String`, `num`, `int`, `double`, `DateTime`).
3. **Locale Header:**
   - Every file must start with `"@@locale": "en"` (or `"uk"`).

---

## 4. Standard ARB Templates

### Base Template: `lib/l10n/intl_en.arb`

```json
{
  "@@locale": "en",

  "appTitle": "Flutter Template",
  "@appTitle": {
    "description": "The application title displayed in app bar and task switcher"
  },

  "welcomeUser": "Welcome back, {userName}!",
  "@welcomeUser": {
    "description": "Greeting message on user home screen",
    "placeholders": {
      "userName": {
        "type": "String",
        "example": "Alex"
      }
    }
  },

  "itemsCount": "{count, plural, =0{No items} =1{1 item} other{{count} items}}",
  "@itemsCount": {
    "description": "Pluralized counter for items in list",
    "placeholders": {
      "count": {
        "type": "int",
        "example": "5"
      }
    }
  },

  "userStatus": "{gender, select, male{He is online} female{She is online} other{They are online}}",
  "@userStatus": {
    "description": "Gender-specific status indicator",
    "placeholders": {
      "gender": {
        "type": "String",
        "example": "female"
      }
    }
  },

  "priceFormatted": "Total price: {amount}",
  "@priceFormatted": {
    "description": "Formatted price label",
    "placeholders": {
      "amount": {
        "type": "String",
        "example": "$49.99"
      }
    }
  }
}
```

### Localized Template: `lib/l10n/intl_uk.arb` (Slavic Plurals)

> [!IMPORTANT]
> Ukrainian and other Slavic languages have three plural forms: `one` (1, 21, 31...), `few` (2-4, 22-24...), `many` (5-20, 25-30...). Always provide `few` and `many` in Ukrainian ARB files!

```json
{
  "@@locale": "uk",

  "appTitle": "Flutter Template",
  "welcomeUser": "З поверненням, {userName}!",
  "itemsCount": "{count, plural, =0{Немає елементів} =1{{count} елемент} few{{count} елементи} many{{count} елементів} other{{count} елемента}}",
  "userStatus": "{gender, select, male{Він онлайн} female{Вона онлайн} other{Користувач онлайн}}",
  "priceFormatted": "Загальна сума: {amount}"
}
```

---

## 5. ICU Plural Syntax Reference

| Form | English Usage | Ukrainian Usage |
| :--- | :--- | :--- |
| `=0` | Exact match for 0 (`"No items"`) | Exact match for 0 (`"Немає елементів"`) |
| `=1` / `one` | Ends in 1, not 11 (`1 item`) | Ends in 1, not 11 (`1 елемент`, `21 елемент`) |
| `few` | *(Not used in English)* | Ends in 2, 3, 4, not 12-14 (`2 елементи`, `24 елементи`) |
| `many` | *(Not used in English)* | Ends in 5-9, 0, 11-19 (`5 елементів`, `11 елементів`) |
| `other` | All other numbers (`2 items`, `100 items`) | Fractions / other (`1.5 елемента`) |

---

## 6. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| String concatenation across variables: `'$greeting $userName'` | **CRITICAL** | Use single ARB key with placeholder: `"welcomeUser": "Hello, {userName}!"`. |
| Missing `few` or `many` plural branches in Ukrainian ARB | **HIGH** | Always include `=0`, `=1`, `few`, `many`, `other` for Slavic languages. |
| Non-camelCase ARB keys (e.g. `WELCOME_USER`, `login-btn`) | **MEDIUM** | Use strict `camelCase` (e.g. `welcomeUser`, `loginButton`). |
| ARB keys without metadata descriptors in `intl_en.arb` | **LOW** | Add `@key` with `description` and typed `placeholders`. |

---

## 7. Verification Checklist

- [ ] Every new key in `intl_en.arb` has a corresponding translation in `intl_uk.arb`.
- [ ] Keys use `camelCase` syntax.
- [ ] Metadata `@key` describes the context and defines types for all placeholders.
- [ ] Plural messages include `few` and `many` for Ukrainian.
- [ ] ARB JSON is valid (no trailing commas in JSON object properties).
