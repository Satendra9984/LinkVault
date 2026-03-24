import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/revenuecat_premium_repository.dart';
import '../../domain/repositories/i_premium_repository.dart';
import '../../domain/usecases/get_offerings_usecase.dart';
import '../../domain/usecases/purchase_premium_usecase.dart';
import '../../domain/usecases/restore_purchases_usecase.dart';

// ── Repository ─────────────────────────────────────────────────────────────

/// Provides the [IPremiumRepository] implementation.
final premiumRepositoryProvider = Provider<IPremiumRepository>((ref) {
  return RevenueCatPremiumRepository();
});

// ── Use Cases ──────────────────────────────────────────────────────────────

final getOfferingsUseCaseProvider = Provider<GetOfferingsUseCase>((ref) {
  return GetOfferingsUseCase(ref.watch(premiumRepositoryProvider));
});

final purchasePremiumUseCaseProvider = Provider<PurchasePremiumUseCase>((ref) {
  return PurchasePremiumUseCase(ref.watch(premiumRepositoryProvider));
});

final restorePurchasesUseCaseProvider =
    Provider<RestorePurchasesUseCase>((ref) {
  return RestorePurchasesUseCase(ref.watch(premiumRepositoryProvider));
});

// ── Premium Status Stream ──────────────────────────────────────────────────

/// Streams the real-time premium status from RC.
/// Returns true when the 'premium' entitlement is active.
final revenueCatPremiumProvider = StreamProvider<bool>((ref) {
  final repo = ref.watch(premiumRepositoryProvider);
  return repo.watchPremiumStatus();
});
