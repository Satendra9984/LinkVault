# LinkVault — Premium Feature Gating Matrix

**Version:** 1.0  
**Last Updated:** March 20, 2026

This document defines which features are available on each tier and exactly how each gate is enforced in code.

---

## Tier Definitions

```dart
enum UserTier {
  guest,     // No account, local ObjectBox only, Ad Day Pass required
  free,      // Authenticated, local ObjectBox, Ad Day Pass required
  premium,   // Authenticated, Supabase cloud, no ads
}
```

---

## Feature Gate Matrix

| Feature | Guest | Free (Ad Pass Active) | Premium | Note |
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
| **Cloud Sync** | | | | |
| Cloud sync (Supabase) | ❌ | ❌ | ✅ | Premium core feature |
| Cross-device access | ❌ | ❌ | ✅ | |
| Automatic backup | ❌ | ❌ | ✅ | |
| **Data Management** | | | | |
| Export data (JSON) | ✅ | ✅ | ✅ | |
| Import data (JSON) | ✅ | ✅ | ✅ | |
| **Ads** | | | | |
| Ad Day Pass required | ✅ (Day 4+) | ✅ (Day 4+) | ❌ | Premium = no ads |
| 3-day free trial | ✅ | ✅ | N/A | |
| **Social** (Phase 2) | | | | |
| Share collection link | ❌ | ❌ | Phase 2 | Premium only |

---

## Enforcement Pattern

### In Repository Layer

The tier-based repository injection is the **primary enforcement mechanism**. Free/guest users physically cannot write to Supabase because a Supabase repository is never injected.

```dart
final collectionsRepositoryProvider = Provider<CollectionRepository>((ref) {
  final tier = ref.watch(userTierProvider).valueOrNull ?? UserTier.guest;
  return tier == UserTier.premium
    ? ref.read(supabaseCollectionsRepoProvider)
    : ref.read(localCollectionsRepoProvider);
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

---

## Paywall Content

**Title:** Upgrade to LinkVault Premium

**Benefits listed:**
1. 🚫 No ads — ever
2. ☁️ Cloud sync across all your devices
3. 🔒 Automatic backup — your links are always safe
4. ⚡ Priority support

**Pricing display:**
- Monthly: **$4.99/month**
- Annual: **$39.99/year** *(Save 33% — most popular)*

**Footer:** "Restore purchases" link
