import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/subscription_offering.dart';
import '../repositories/i_premium_repository.dart';

/// Fetches the current subscription [SubscriptionOffering] from the store.
///
/// Returns [Left(PaymentFailure)] if no offerings are configured or if a
/// network/billing error occurs.
class GetOfferingsUseCase {
  final IPremiumRepository _repository;

  const GetOfferingsUseCase(this._repository);

  Future<Either<Failure, SubscriptionOffering>> call() {
    return _repository.getOfferings();
  }
}
