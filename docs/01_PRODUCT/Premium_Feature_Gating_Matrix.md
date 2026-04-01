# LinkVault — Premium Feature Gating Matrix

**Version:** 1.1  
**Last Updated:** March 24, 2026

This document defines which features are available on each tier and exactly how each gate is enforced in code.

**Canonical monetization + persistence:** [Monetization_Model_Free_Cloud_Quotas_and_Unit_Economics.md](../05_MONETIZATION/Monetization_Model_Free_Cloud_Quotas_and_Unit_Economics.md) · [ADR-0002](../10_DECISIONS_AND_RISKS/ADR_0002_Free_Tier_Supabase_Quotas_and_Day_Pass.md).  
**Subscription architecture context:** [Subscription_Architecture_System_Design.md](../05_MONETIZATION/Subscription_Architecture_System_Design.md) · [Shared_Subscription_Setup_Runbook.md](../05_MONETIZATION/Shared_Subscription_Setup_Runbook.md)

---

## Tier Definitions

```dart
enum UserTier {
  guest,     // No account — ObjectBox only; Ad Day Pass (app access)
  free,      // Authenticated — Supabase lv_* + quotas; Ad Day Pass
  premium,   // Authenticated — Supabase lv_* + high limits; no ads
}
```

---

## Feature Gate Matrix

| Feature | Guest | Free account (Ad Pass Active) | Premium | Note |
|---|---|---|---|---|
| **Collections** | | | | |
| Create collection | ✅ | ✅ | ✅ | |
| Edit collection | ✅ | ✅ | ✅ | |
| Delete collection | ✅ | ✅ | ✅ | |
| Nested collections | ✅ | ✅ | ✅ | |
| Pin / archive | ✅ | ✅ | ✅ | |
| Reorder (drag) | ✅ | ✅ | ✅ | |
| Share collection | ❌ | ❌ | Phase 2 | Post-MVP |
| **URLs** | | | | |
| Add URL | ✅ | ✅ | ✅ | |
| Edit URL | ✅ | ✅ | ✅ | |
| Delete URL | ✅ | ✅ | ✅ | |
| Auto-metadata fetch | ✅ | ✅ | ✅ | |
| Tags & annotation | ✅ | ✅ | ✅ | |
| Pin / archive | ✅ | ✅ | ✅ | |
| Open in browser | ✅ | ✅ | ✅ | |
| Click count tracking | ✅ | ✅ | ✅ | |
| Move to collection | Phase 2 | Phase 2 | Phase 2 | Post-MVP |
| **Search** | | | | |
| Global search (local) | ✅ | ✅ | ✅ | |
| Filter by status/tag | ✅ | ✅ | ✅ | |
| Sort options | ✅ | ✅ | ✅ | |
| **Share Intent** | | | | |
| Receive link from other apps | ✅ | ✅ | ✅ | |
| **RSS Feeds** | | | | |
| Add RSS feeds | ✅ | ✅ | ✅ | |
| Browse feed articles | ✅ | ✅ | ✅ | |
| Save article to collection | ✅ | ✅ | ✅ | |
| **Cloud** | | | | |
| Cloud data (`lv_*` authority) | ❌ | ✅ (within quotas) | ✅ | Guest = local only |
| Cross-device (same account) | ❌ | ✅ | ✅ | |
| Automatic backup | ❌ | ✅ (bounded by quotas) | ✅ | Messaging: premium = best backup |
| Quota: max collections / URLs | n/a | ✅ enforced | ❌ (premium limits) | Server-side enforcement |
| **Data Management** | | | | |
| Export data (JSON) | ✅ | ✅ | ✅ | |
| Import data (JSON) | ✅ | ✅ | ✅ | |
| **Ads** | | | | |
| Ad Day Pass required | ✅ (Day 4+) | ✅ (Day 4+) | ❌ | Premium = no ads |
| Create blocked when over quota | n/a | ✅ | ❌ | Show upgrade / manage items |
| 3-day free trial | ✅ | ✅ | N/A | |
| **Social** (Phase 2) | | | | |
| Share collection link | ❌ | ❌ | Phase 2 | Premium only |

---

## Enforcement Pattern

### In Repository Layer

**Guest:** inject **local** repositories only — no `lv_*` writes.

**Free account:** inject **Supabase** repositories (same code path as premium for CRUD shape). **Quotas** are enforced via **server-side checks** (RPC / policy) and mirrored in the client for UX. Do **not** use “premium-only Supabase injection” for free accounts.

```dart
final collectionsRepositoryProvider = Provider<CollectionRepository>((ref) {
  final tier = ref.watch(userTierProvider).valueOrNull ?? UserTier.guest;
  if (tier == UserTier.guest) return ref.read(localCollectionsRepoProvider);
  return ref.read(supabaseCollectionsRepoProvider); // free + premium; quota + entitlement layered
});
```

### In UI Layer (Upgrade Prompts)

```dart
// Reusable premium gate widget
class PremiumGate extends ConsumerWidget {
  final Widget child;
  final String featureName;
  
  const PremiumGate({required this.child, required this.featureName, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tier = ref.watch(userTierProvider).valueOrNull;
    if (tier == UserTier.premium) return child;
    
    return GestureDetector(
      onTap: () => context.push('/paywall'),
      child: Stack(
        children: [
          IgnorePointer(child: Opacity(opacity: 0.4, child: child)),
          const Positioned.fill(child: PremiumBadgeOverlay()),
        ],
      ),
    );
  }
}

// Usage:
PremiumGate(
  featureName: 'Cloud Sync',
  child: SyncStatusTile(),
)
```

### Ad Gate Enforcement

Applied on every app launch and foreground resume for free/guest users:

```dart
// In main scaffold init:
final adStatus = await ref.read(adDayPassServiceProvider).checkAccess();
if (adStatus == AdPassStatus.passExpired && !isPremium) {
  context.go('/ad-gate');
}
```

### Curate-style parent-action gate + `/daypass` route

For **contextual** actions (create folder, add link, open collection hub, etc.), screens call `DayPassGate.check(context, ref)` **before** navigation or mutation. Behavior:

- `premium` / `freeTrial` / `active` / **`grace`** → returns `true` immediately (**grace is allowed**; no forced block).
- `expired` → pushes **`/daypass`** (full-screen `DayPassScreen`, not a bottom sheet), awaits `context.pop(true|false)`.

Implementation: `lib/core/presentation/widgets/day_pass_gate.dart`, `lib/features/monetization/presentation/screens/day_pass_screen.dart` (`DayPassScreenArgs.fromAccessGate`). **Router:** register `/collections/create` **before** `/collections/:id` in `lib/core/router/app_router.dart`, and treat `extra` on `:id` routes as `String` only when `extra is String` (avoid cast crashes).

---

## Paywall Content

**Title:** Upgrade to LinkVault Premium

**Benefits listed:**
1. No ads
2. Higher limits (or unlimited-style) — no quota wall for normal use
3. Best sync and backup story
4. Priority support

(Free account already has cloud backup within quotas; premium is **more headroom + no ads**.)

**Pricing display:**
- Monthly: **$4.99/month**
- Annual: **$39.99/year** *(Save 33% — most popular)*

**Footer:** "Restore purchases" link
