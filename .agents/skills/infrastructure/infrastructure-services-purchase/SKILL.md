---
name: infrastructure-services-purchase
description: Standards and patterns for In-App Purchases and subscription services in lib/infrastructure/services/purchase/. Covers RevenueCat / StoreKit / Google Play Billing adapters, mapping SDK customer info to Domain Entities, and isolating payment SDKs behind Domain repository interfaces.
---

# Infrastructure In-App Purchases & Subscriptions Architecture

## 1. Overview & When to Apply

Use this skill whenever:
- Integrating In-App Purchase and subscription management SDKs (e.g., `purchases_flutter` / RevenueCat, `in_app_purchase`, Adapty).
- Implementing payment gateway or store client wrappers in `lib/infrastructure/services/purchase/`.
- Mapping third-party store receipts, entitlements, and customer info to Domain Entities.
- Ensuring zero payment SDK leakages into UI widgets or Domain UseCases.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [infrastructure-hub](../infrastructure-hub/SKILL.md) | Infrastructure architecture and layer boundaries. |
| **Clean Architecture** | [flutter-clean-architecture](../../flutter-clean-architecture/SKILL.md) | Inverting dependencies via Domain `IPurchaseRepository`. |
| **DI Setup** | [infrastructure-di](../infrastructure-di/SKILL.md) | Binding `PurchaseRepositoryImpl` to `IPurchaseRepository`. |

---

## 3. Clean Architecture Layer Flow for Purchases

```text
UI (SubscriptionDialog/Paywall)
  └── BLoC (SubscriptionBloc)
        └── UseCase (PurchasePackageUseCase)
              └── Domain Interface (IPurchaseRepository)
                    └── Data (PurchaseRepositoryImpl)
                          └── Infrastructure Service (RevenueCatPurchaseService)
```

---

## 4. Standard Implementation Pattern

### 4.1 Infrastructure Purchase Service Wrapper (`revenue_cat_service.dart`)

```dart
import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

@lazySingleton
class RevenueCatPurchaseService {
  Future<void> initialize({required String apiKey, String? appUserId}) async {
    final configuration = PurchasesConfiguration(apiKey)..appUserID = appUserId;
    await Purchases.configure(configuration);
  }

  Future<CustomerInfo> getCustomerInfo() => Purchases.getCustomerInfo();

  Future<Offerings> getOfferings() => Purchases.getOfferings();

  Future<CustomerInfo> purchasePackage(Package package) =>
      Purchases.purchasePackage(package);

  Future<CustomerInfo> restorePurchases() => Purchases.restorePurchases();

  Future<void> logIn(String appUserId) => Purchases.logIn(appUserId);
  Future<void> logOut() => Purchases.logOut();
}
```

---

### 4.2 Data Repository Implementation with Domain Mapping

```dart
import 'package:injectable/injectable.dart';
import 'package:flutter_template/domain/purchase/entities/subscription_status.dart';
import 'package:flutter_template/domain/purchase/repositories/i_purchase_repository.dart';
import 'package:flutter_template/infrastructure/services/purchase/revenue_cat_service.dart';

@LazySingleton(as: IPurchaseRepository)
class PurchaseRepositoryImpl implements IPurchaseRepository {
  final RevenueCatPurchaseService _purchaseService;

  PurchaseRepositoryImpl(this._purchaseService);

  @override
  Future<SubscriptionStatus> checkSubscriptionStatus() async {
    try {
      final customerInfo = await _purchaseService.getCustomerInfo();
      final isPremium = customerInfo.entitlements.active.containsKey('premium');
      return SubscriptionStatus(isPremium: isPremium);
    } catch (e) {
      throw const PurchaseFailure(message: 'Failed to verify subscription status.');
    }
  }
}
```

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Calling `Purchases.purchasePackage()` directly inside a Flutter UI button callback | **CRITICAL** | Route purchases through BLoC -> UseCase -> `IPurchaseRepository`. |
| Exposing RevenueCat `CustomerInfo` or `Package` types to Domain or Presentation | **HIGH** | Map to pure Domain Entities (`SubscriptionStatus`, `PurchaseProduct`). |
| Placing subscription logic into `infrastructure/utils/` | **MEDIUM** | Place in `lib/infrastructure/services/purchase/`. |

---

## 6. Verification Checklist

- [ ] In-App purchase SDKs are encapsulated inside `infrastructure/services/purchase/`.
- [ ] Domain defines `IPurchaseRepository` with pure Dart entities.
- [ ] UI triggers purchase actions strictly via BLoC events.
