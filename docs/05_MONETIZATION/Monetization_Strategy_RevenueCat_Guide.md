# LinkVault — Monetization Strategy & RevenueCat Guide

**Version:** 1.1  
**Last Updated:** March 24, 2026  
**Covers:** Revenue model · RevenueCat setup · AdMob Day Pass · Testing · Pitfalls

**Companion (canonical tier + quotas + unit economics):** [Monetization_Model_Free_Cloud_Quotas_and_Unit_Economics.md](Monetization_Model_Free_Cloud_Quotas_and_Unit_Economics.md) · **ADR:** [ADR_0002](../10_DECISIONS_AND_RISKS/ADR_0002_Free_Tier_Supabase_Quotas_and_Day_Pass.md).  
**Code-accurate architecture deep dive:** [RevenueCat_Setup_And_Architecture_LinkVault.md](RevenueCat_Setup_And_Architecture_LinkVault.md).

## Start Here (Choose by intent)

- **Concepts / system design:** [Subscription_Architecture_System_Design.md](Subscription_Architecture_System_Design.md)
- **Platform setup runbook (RC + Supabase + stores):** [Shared_Subscription_Setup_Runbook.md](Shared_Subscription_Setup_Runbook.md)
- **Implementation-oriented guide (this document):** Revenue model, key setup, paywall/testing pitfalls

---

## Part 0 — Tier model snapshot (2026-03-24)

- **Guest:** local ObjectBox only; Day Pass for app access.
- **Free account:** Supabase `lv_*` + **quotas** + Day Pass.
- **Premium:** Supabase + **high limits** + no ads (RevenueCat).

Implementation must follow [Data_Persistence_State_Machine.md](../04_DATA_AND_MIGRATION/Data_Persistence_State_Machine.md) v2+.

---

## Part 1 — Revenue Model

### Two Revenue Streams

| Stream | Mechanism | Target User |
|---|---|---|
| **Ad Revenue** | Rewarded video (AdMob) — 1 ad/day for 24hr access | Free users (Day 4+) |
| **Premium Subscriptions** | IAP managed by RevenueCat | Users who want **no ads + higher limits** + best sync (free account already has cloud within quotas) |

### Pricing

| Plan | Price | Billing |
|---|---|---|
| Monthly | $4.99 | Monthly |
| Annual | $39.99 | Yearly (save 33%) |
| Free (Ad Day Pass) | Watch 1 rewarded ad/day | Daily |

### Revenue Projection (Conservative)

| Month | Users | Premium Users (10%) | Ad Revenue | IAP Revenue | Total |
|---|---|---|---|---|---|
| 1 | 3,000 | 300 | $108 | $360 | $468 |
| 3 | 8,000 | 800 | $288 | $960 | $1,248 |
| 6 | 20,000 | 2,000 | $720 | $2,400 | $3,120 |
| 12 | 50,000 | 5,000 | $1,800 | $6,000 | $7,800 |

---

## Part 2 — RevenueCat Setup

### Architecture: Shared Project with Curate

> LinkVault and Curate share the **same RevenueCat project**. This means:
> - One unified user database (linked via `auth.uid()` as App User ID)
> - The `premium` entitlement is **project-scoped** — shared across both apps
> - A user who subscribes in either app gets premium in both

### App User ID Convention

```dart
// Always identify RevenueCat with the Supabase auth UID
// This links RC purchases to the Supabase user
await Purchases.logIn(supabase.auth.currentUser!.id);
```

### RevenueCat Project Structure

```
RevenueCat Project: "Vicharshala Apps"
├── Apps:
│   ├── Curate (Android) — goog_ key
│   ├── Curate (iOS) — appl_ key
│   ├── Curate Dev (Test Store) — test_ key
│   ├── LinkVault (Android) — goog_ key       ← NEW
│   ├── LinkVault (iOS) — appl_ key            ← NEW
│   └── LinkVault Dev (Test Store) — test_ key ← NEW
│
├── Entitlements:
│   └── premium ← shared across ALL apps in project
│
└── Offerings:
    └── default
        ├── $rc_monthly
        │   ├── curate_premium_monthly:monthly-base (Play Store)
        │   ├── curate_premium_monthly (Test Store)
        │   ├── lv_premium_monthly:monthly-base (Play Store)   ← NEW
        │   └── lv_premium_monthly (Test Store)                ← NEW
        └── $rc_annual
            ├── curate_premium_annual:annual-base (Play Store)
            ├── curate_premium_annual (Test Store)
            ├── lv_premium_annual:annual-base (Play Store)     ← NEW
            └── lv_premium_annual (Test Store)                 ← NEW
```

### Product IDs

| Platform | Product ID | Billing |
|---|---|---|
| Google Play | `lv_premium_monthly:monthly-base` | Monthly |
| Google Play | `lv_premium_annual:annual-base` | Yearly |
| App Store | `lv_premium_monthly` | Monthly |
| App Store | `lv_premium_annual` | Yearly |
| Test Store (Dev) | `lv_premium_monthly` | Monthly (simulated) |
| Test Store (Dev) | `lv_premium_annual` | Yearly (simulated) |

### API Key Prefixes

| Prefix | Platform | Environment |
|---|---|---|
| `test_` | Test Store | Dev only — never ship to production |
| `appl_` | iOS (Apple App Store) | Production |
| `goog_` | Android (Google Play) | Production |

> ⚠️ **Critical:** Never use a `goog_` key for iOS. RC routes to the wrong validation pipeline and purchases fail silently.

---

## Part 3 — Flutter Integration

### Environment Files

**`.env.dev`**
```
REVENUE_CAT_ANDROID_KEY=test_REPLACE_WITH_LV_DEV_ANDROID_KEY
REVENUE_CAT_IOS_KEY=test_REPLACE_WITH_LV_DEV_IOS_KEY
```

**`.env.production`**
```
REVENUE_CAT_ANDROID_KEY=goog_REPLACE_WITH_LV_PROD_ANDROID_KEY
REVENUE_CAT_IOS_KEY=appl_REPLACE_WITH_LV_PROD_IOS_KEY
```

### Initialization (bootstrap.dart)

```dart
// Always identify user BEFORE calling getCustomerInfo
final rcKey = Platform.isIOS
    ? AppConfig.revenueCatIosKey
    : AppConfig.revenueCatAndroidKey;

if (kDebugMode) await Purchases.setLogLevel(LogLevel.verbose);

await Purchases.configure(PurchasesConfiguration(rcKey));

// Link to Supabase user
final userId = Supabase.instance.client.auth.currentUser?.id;
if (userId != null) {
  await Purchases.logIn(userId);
}
```

### Purchase Flow (CORRECT Pattern)

```dart
@override
Future<Either<Failure, bool>> purchasePackage(String packageId) async {
  try {
    final offerings = await Purchases.getOfferings();
    final package = offerings.current?.availablePackages
        .firstWhere((p) => p.identifier == packageId);
    
    if (package == null) {
      return Left(PaymentFailure('Package not found: $packageId'));
    }

    // USE THE RETURN VALUE DIRECTLY — do not call getCustomerInfo() separately
    final result = await Purchases.purchase(PurchaseParams.package(package));
    final isPremium = result.customerInfo.entitlements.active.containsKey('premium');
    
    return Right(isPremium);
  } on PurchasesError catch (e) {
    if (e.code == PurchasesErrorCode.purchaseCancelledError) {
      return Left(PaymentFailure('Purchase cancelled'));
    }
    return Left(PaymentFailure(e.message));
  } catch (e, st) {
    return Left(UnexpectedFailure('Purchase failed', error: e, stackTrace: st));
  }
}
```

### Restore Purchases (CORRECT Pattern)

```dart
@override
Future<Either<Failure, bool>> restorePurchases() async {
  try {
    // USE RETURN VALUE DIRECTLY — same reason as purchase()
    final info = await Purchases.restorePurchases();
    return Right(info.entitlements.active.containsKey('premium'));
  } catch (e, st) {
    return Left(UnexpectedFailure('Restore failed', error: e, stackTrace: st));
  }
}
```

> ⚠️ **Never discard the return value of `purchase()` or `restorePurchases()` and call `getCustomerInfo()` separately.** The separate call may return stale cached data before RC's backend finishes processing — causing empty entitlements even after a successful purchase. This was the root cause bug in Curate's March 2026 debugging session.

---

## Part 4 — Ad Day Pass (AdMob)

### Logic

```dart
class AdDayPassService {
  Future<AdPassStatus> checkAccess() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 3-day free trial
    final firstInstall = prefs.getInt('lv_first_install_at') ?? DateTime.now().millisecondsSinceEpoch;
    final daysSinceInstall = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(firstInstall)
    ).inDays;
    if (daysSinceInstall < 3) return AdPassStatus.freeTrialActive;
    
    // Check last pass
    final lastAdWatch = prefs.getInt('lv_last_ad_watched_at');
    if (lastAdWatch != null) {
      final hoursSince = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(lastAdWatch)
      ).inHours;
      if (hoursSince < 24) return AdPassStatus.passActive;
    }
    
    // Check grace period
    final graceExpires = prefs.getInt('lv_grace_period_expires_at');
    if (graceExpires != null && DateTime.now().millisecondsSinceEpoch < graceExpires) {
      return AdPassStatus.graceActive;
    }
    
    return AdPassStatus.passExpired;
  }
  
  Future<void> recordAdWatched() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lv_last_ad_watched_at', DateTime.now().millisecondsSinceEpoch);
    await prefs.remove('lv_grace_period_expires_at');
    await prefs.setInt('lv_total_ads_watched', 
      (prefs.getInt('lv_total_ads_watched') ?? 0) + 1);
  }
  
  Future<void> activateGracePeriod() async {
    final prefs = await SharedPreferences.getInstance();
    final expires = DateTime.now().add(const Duration(hours: 24));
    await prefs.setInt('lv_grace_period_expires_at', expires.millisecondsSinceEpoch);
    await prefs.setBool('lv_grace_period_active', true);
  }
}

enum AdPassStatus { freeTrialActive, passActive, graceActive, passExpired }
```

### AdMob Unit IDs

**Development (always use test IDs in dev flavor):**
```
ADMOB_APP_ID_ANDROID=ca-app-pub-3940256099942544~3347511713
ADMOB_REWARDED_AD_UNIT_ID_ANDROID=ca-app-pub-3940256099942544/5224354917
```

**Production:**
```
ADMOB_APP_ID_ANDROID= [create in AdMob dashboard for link_vault]
ADMOB_REWARDED_AD_UNIT_ID_ANDROID= [create rewarded ad unit]
```

---

## Part 5 — Sandbox Testing Access (Critical)

> This was the root cause of empty entitlements in Curate. Do this before testing linkVault.

**RevenueCat Dashboard → Project Settings → General → Sandbox Testing Access → set to "Anybody"**

The setting "Allowed App User IDs only" with emails in the allowlist will cause:
- Purchase recorded correctly in RC dashboard
- Products appear as "Unattached" in customer profile
- Entitlements always empty after successful purchase

**Always use "Anybody" for dev.** The Test Store already isolates test transactions from production.

---

## Part 6 — Testing Checklist

### End-to-End Test Matrix (every release)

| Scenario | Expected | How to Test |
|---|---|---|
| Dev: purchase monthly | `premium` entitlement active | TestStore → Validate Purchase |
| Dev: purchase annual | `premium` entitlement active | TestStore → Validate Purchase |
| Dev: cancel | No entitlement, UI graceful | TestStore → Cancel |
| Dev: payment fail | Error message shown | TestStore → Failure |
| Dev: app restart after purchase | Entitlement persists | Kill app, reopen |
| Dev: restore purchases | Re-grants entitlement | Tap Restore in app |
| Prod: purchase (license tester) | Real Play billing, no charge | Google Play license tester account |

### Pre-Release Checklist

- [ ] `_env.dev` uses `test_` keys for RC
- [ ] `_env.production` uses `goog_` for Android, `appl_` for iOS  
- [ ] Sandbox Testing Access = "Anybody"
- [ ] Test Store products attached to `premium` entitlement
- [ ] `default` offering has both packages with both store products
- [ ] `purchasePackage()` uses `result.customerInfo` directly
- [ ] `restorePurchases()` uses return value directly
- [ ] AdMob uses test unit IDs in dev build

---

## Troubleshooting

| Symptom | Most Likely Cause | Fix |
|---|---|---|
| Empty entitlements after successful purchase | Sandbox Testing Access set to allowlist | Set to "Anybody" in RC Project Settings |
| TestStore dialog doesn't appear | Using `goog_` key in dev instead of `test_` | Fix `.env.dev` key |
| Paywall blank / no packages | No `default` offering or packages empty | Configure in RC Offerings dashboard |
| iOS production purchase fails | Using `goog_` key for iOS in prod | Change to `appl_` key in `.env.production` |
| Entitlements empty right after purchase | Discarding `purchase()` return value | Use `result.customerInfo` directly |
