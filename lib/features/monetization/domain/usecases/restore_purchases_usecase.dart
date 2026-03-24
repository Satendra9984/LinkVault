import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/i_premium_repository.dart';

/// Business logic for restoring prior subscription purchases.
///
/// Returns [Right(true)] if an active 'premium' entitlement is found after
/// the restore, [Right(false)] if no active subscription exists, and
/// [Left(PaymentFailure)] if the restore operation itself fails.
class RestorePurchasesUseCase {
  final IPremiumRepository _repository;

  const RestorePurchasesUseCase(this._repository);

  Future<Either<Failure, bool>> call() {
    return _repository.restorePurchases();
  }
}
