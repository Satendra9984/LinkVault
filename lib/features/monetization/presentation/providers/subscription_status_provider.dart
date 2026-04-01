import 'premium_provider.dart';

/// Live RevenueCat entitlement `premium` — **same stream** as
/// [revenueCatPremiumProvider] so only one [CustomerInfo] listener is active.
///
/// Kept for call sites that historically watched subscription activity
/// separately from cached DB premium ([isPremiumProvider]).
final isSubscriptionActiveProvider = revenueCatPremiumProvider;
