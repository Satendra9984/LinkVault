import 'package:fpdart/fpdart.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/i_premium_repository.dart';

/// Business logic for initiating a subscription purchase.
///
/// Contains the **dev-mode intercept**: if the app is running in the
/// [AppEnvironment.dev] flavor and the native purchase completes (even though
/// RC Test Store never grants real entitlements), we treat the result as
/// premium active. This allows the full post-purchase flow to be tested
/// locally without uploading to the Play Store.
///
/// In production, the intercept is dead code — [AppEnvironment.production]
/// never equals [AppEnvironment.dev].
class PurchasePremiumUseCase {
  final IPremiumRepository _repository;

  const PurchasePremiumUseCase(this._repository);

  /// [packageId] — the [SubscriptionPackage.id] selected by the user.
  Future<Either<Failure, bool>> call(String packageId) async {
    final result = await _repository.purchasePackage(packageId);

    return result.map((isPremium) {
      // ── Dev-mode intercept ─────────────────────────────────────────────────
      // RC Test Store always returns empty entitlements by design. In dev mode,
      // any successful native purchase callback is treated as premium granted
      // so the full post-purchase UI flow (migration, gating, etc.) can be
      // tested with hot-reload. This line is dead in production.
      if (!isPremium && AppConfig.instance.environment == AppEnvironment.dev) {
        return true;
      }
      return isPremium;
    });
  }
}
