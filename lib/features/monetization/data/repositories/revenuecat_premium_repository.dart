import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/subscription_offering.dart';
import '../../domain/entities/subscription_package.dart';
import '../../domain/repositories/i_premium_repository.dart';

/// Production implementation of [IPremiumRepository] using RevenueCat.
///
/// Responsibilities:
/// - Maps RC `Offerings` / `Package` → pure [SubscriptionOffering] / [SubscriptionPackage] entities
/// - Maps RC `CustomerInfo` entitlement status → `bool`
/// - Wraps all errors in [Left(PaymentFailure)] / [Left(UnexpectedFailure)]
/// - Manages the real-time customer info listener lifecycle
class RevenueCatPremiumRepository implements IPremiumRepository {
  final Logger _logger = Logger();

  // Cache the current offerings so purchasePackage() can look up the
  // native Package object by identifier without an extra network call.
  Offerings? _cachedOfferings;

  // ── Premium Status ─────────────────────────────────────────────────────────

  @override
  Future<bool> checkPremiumStatus() async {
    try {
      _logger.d('[RC] Checking premium status...');
      final customerInfo = await Purchases.getCustomerInfo();
      final isPremium = customerInfo.entitlements.all['premium']?.isActive ?? false;
      _logger.i('[RC] Active entitlements: ${customerInfo.entitlements.active.keys.toList()} | Premium: $isPremium');
      return isPremium;
    } catch (e) {
      _logger.e('[RC] Error checking premium status: $e');
      return false;
    }
  }

  void Function(CustomerInfo)? _premiumListener;

  @override
  Stream<bool> watchPremiumStatus() {
    final controller = StreamController<bool>.broadcast();

    // Emit initial state immediately.
    checkPremiumStatus().then((status) {
      if (!controller.isClosed) controller.add(status);
    });

    _premiumListener = (customerInfo) {
      if (!controller.isClosed) {
        final isPremium = customerInfo.entitlements.all['premium']?.isActive ?? false;
        _logger.i('[RC Listener] CustomerInfo updated → premium: $isPremium');
        controller.add(isPremium);
      }
    };
    Purchases.addCustomerInfoUpdateListener(_premiumListener!);

    controller.onCancel = () {
      if (_premiumListener != null) {
        Purchases.removeCustomerInfoUpdateListener(_premiumListener!);
        _premiumListener = null;
      }
      controller.close();
    };

    return controller.stream;
  }

  // ── Offerings ──────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, SubscriptionOffering>> getOfferings() async {
    try {
      _logger.d('[RC] Fetching offerings...');
      _cachedOfferings = await Purchases.getOfferings();
      final current = _cachedOfferings?.current;

      if (current == null || current.availablePackages.isEmpty) {
        _logger.w('[RC] No current offering found.');
        return Left(const PaymentFailure('No subscription plans are currently available.'));
      }

      final entity = SubscriptionOffering(
        id: current.identifier,
        packages: current.availablePackages.map(_mapPackage).toList(),
      );
      _logger.i('[RC] Offerings fetched: ${entity.id} (${entity.packages.length} packages)');
      return Right(entity);
    } catch (e) {
      _logger.e('[RC] Error fetching offerings: $e');
      return Left(PaymentFailure('Could not load subscription plans.', error: e));
    }
  }

  // ── Purchase ───────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, bool>> purchasePackage(String packageId) async {
    try {
      _logger.i('[RC] Starting purchase for packageId: $packageId');

      // Resolve the native Package from cached offerings.
      final nativePackage = _resolveNativePackage(packageId);
      if (nativePackage == null) {
        // If no cache, try fetching offerings first.
        _cachedOfferings = await Purchases.getOfferings();
        final resolved = _resolveNativePackage(packageId);
        if (resolved == null) {
          return Left(PaymentFailure('Package "$packageId" not found in current offering.'));
        }
      }

      final package = _resolveNativePackage(packageId)!;
      final info = await Purchases.purchase(PurchaseParams.package(package));

      // _logger.d('[RC] Purchase completed. Invalidating cache...');
      // await Purchases.invalidateCustomerInfoCache();

      // final info = await Purchases.getCustomerInfo();
      final isPremium = info.customerInfo.entitlements.active.containsKey('premium');
      _logger.i('[RC] Post-purchase entitlements: ${info.customerInfo.entitlements.active.keys.toList()}');

      return Right(isPremium);
    } on PurchasesError catch (e) {
      if (e.code == PurchasesErrorCode.purchaseCancelledError) {
        _logger.w('[RC] Purchase cancelled by user.');
        return Left(PaymentFailure('Purchase was cancelled.', error: e));
      }
      _logger.e('[RC] PurchasesError: ${e.message}');
      return Left(PaymentFailure(e.message, error: e));
    } catch (e, st) {
      _logger.e('[RC] Unexpected error during purchase: $e');
      return Left(UnexpectedFailure('Purchase failed unexpectedly.', error: e, stackTrace: st));
    }
  }

  // ── Restore ────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, bool>> restorePurchases() async {
    try {
      _logger.i('[RC] Starting restore purchases...');
      final info = await Purchases.restorePurchases();

      // await Purchases.invalidateCustomerInfoCache();
      // final info = await Purchases.getCustomerInfo();
      final isPremium = info.entitlements.active.containsKey('premium');
      _logger.i('[RC] Post-restore entitlements: ${info.entitlements.active.keys.toList()}');

      return Right(isPremium);
    } catch (e, st) {
      _logger.e('[RC] Error restoring purchases: $e');
      return Left(UnexpectedFailure('Restore failed. Please try again.', error: e, stackTrace: st));
    }
  }

  // ── Mappers ────────────────────────────────────────────────────────────────

  SubscriptionPackage _mapPackage(Package p) {
    final period = _resolvePeriod(p.packageType);
    return SubscriptionPackage(
      id: p.identifier,
      title: p.storeProduct.title.isNotEmpty ? p.storeProduct.title : period,
      priceString: p.storeProduct.priceString,
      price: p.storeProduct.price,
      currencyCode: p.storeProduct.currencyCode,
      billingPeriod: period,
    );
  }

  String _resolvePeriod(PackageType type) {
    switch (type) {
      case PackageType.annual:
        return 'annual';
      case PackageType.monthly:
        return 'monthly';
      case PackageType.weekly:
        return 'weekly';
      case PackageType.twoMonth:
      case PackageType.threeMonth:
      case PackageType.sixMonth:
        return 'multi_month';
      default:
        return 'unknown';
    }
  }

  Package? _resolveNativePackage(String id) {
    final packages = _cachedOfferings?.current?.availablePackages ?? [];
    try {
      return packages.firstWhere((p) => p.identifier == id);
    } catch (_) {
      return null;
    }
  }
}
