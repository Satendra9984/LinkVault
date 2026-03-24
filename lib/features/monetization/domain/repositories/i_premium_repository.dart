import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/subscription_offering.dart';

/// Contract for all premium subscription operations.
///
/// All methods return [Either] so callers must handle both success [Right]
/// and failure [Left] paths explicitly, matching the project's functional
/// error-handling convention (`fpdart`).
///
/// The domain layer is kept completely pure — no RevenueCat or billing SDK
/// types appear anywhere in this interface.
abstract class IPremiumRepository {
  /// Returns true if the current user has an active 'premium' entitlement.
  Future<bool> checkPremiumStatus();

  /// Emits the real-time premium status. Useful for reactive UI gates.
  Stream<bool> watchPremiumStatus();

  /// Fetches the current [SubscriptionOffering] from the store.
  /// Returns [Left(PaymentFailure)] if no offerings are configured or
  /// network is unavailable.
  Future<Either<Failure, SubscriptionOffering>> getOfferings();

  /// Initiates a native purchase for the package with [packageId].
  /// Returns [Right(true)] on success (entitlement active).
  /// Returns [Left(PaymentFailure)] on any billing error.
  Future<Either<Failure, bool>> purchasePackage(String packageId);

  /// Restores prior purchases for the current user.
  /// Returns [Right(true)] if an active 'premium' entitlement was found.
  Future<Either<Failure, bool>> restorePurchases();
}
