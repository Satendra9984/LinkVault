import 'package:fpdart/fpdart.dart';

import '../errors/failures.dart';
import '../../features/auth/domain/entities/auth_user.dart';
import '../../features/collections/domain/repositories/i_collections_repository.dart';
import '../../features/items/domain/repositories/i_items_repository.dart';

/// Build-time caps for non-premium users (guest + free authenticated).
///
/// Product tuning: see
/// [docs/05_MONETIZATION/Monetization_Model_Free_Cloud_Quotas_and_Unit_Economics.md].
/// Premium bypasses these checks entirely.
class TierQuotaLimits {
  TierQuotaLimits._();

  static const int guestMaxCollections = 50;
  static const int guestMaxUrls = 1200;

  static const int freeAuthenticatedMaxCollections = 150;
  static const int freeAuthenticatedMaxUrls = 5000;
}

/// Client-side pre-checks before create. Server policies remain authoritative.
class TierQuotaGuard {
  TierQuotaGuard._();

  static int _maxCollections(AuthUser? user) {
    if (user == null || user.isGuest) {
      return TierQuotaLimits.guestMaxCollections;
    }
    return TierQuotaLimits.freeAuthenticatedMaxCollections;
  }

  static int _maxUrls(AuthUser? user) {
    if (user == null || user.isGuest) {
      return TierQuotaLimits.guestMaxUrls;
    }
    return TierQuotaLimits.freeAuthenticatedMaxUrls;
  }

  static Future<Either<Failure, void>> ensureCanCreateCollection({
    required bool isPremium,
    required AuthUser? user,
    required ICollectionsRepository collectionsRepo,
  }) async {
    if (isPremium) return const Right(null);

    final max = _maxCollections(user);
    final result = await collectionsRepo.getAllCollections();
    return result.fold(Left.new, (list) {
      final n = list.where((c) => !c.isDeleted).length;
      if (n >= max) {
        return Left(
          ValidationFailure(
            "You've reached your plan limit of $max collections. "
            'Upgrade to Premium for higher limits.',
          ),
        );
      }
      return const Right(null);
    });
  }

  static Future<Either<Failure, void>> ensureCanCreateItem({
    required bool isPremium,
    required AuthUser? user,
    required IItemsRepository itemsRepo,
  }) async {
    if (isPremium) return const Right(null);

    final max = _maxUrls(user);
    final result = await itemsRepo.getAllItems();
    return result.fold(Left.new, (list) {
      if (list.length >= max) {
        return Left(
          ValidationFailure(
            "You've reached your plan limit of $max saved links. "
            'Upgrade to Premium for higher limits.',
          ),
        );
      }
      return const Right(null);
    });
  }
}
