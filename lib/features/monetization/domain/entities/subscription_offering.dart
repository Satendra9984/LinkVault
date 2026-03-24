import 'package:equatable/equatable.dart';
import 'subscription_package.dart';

/// Pure Dart domain entity representing the current store offering.
///
/// Maps to RevenueCat's `Offering` concept but is completely decoupled
/// from the SDK. Contains the list of available [SubscriptionPackage]s.
class SubscriptionOffering extends Equatable {
  /// The RevenueCat offering identifier (e.g. `'default'`).
  final String id;

  /// All purchasable packages within this offering.
  final List<SubscriptionPackage> packages;

  const SubscriptionOffering({
    required this.id,
    required this.packages,
  });

  /// Returns the annual package if available.
  SubscriptionPackage? get annual =>
      packages.where((p) => p.billingPeriod == 'annual').firstOrNull;

  /// Returns the monthly package if available.
  SubscriptionPackage? get monthly =>
      packages.where((p) => p.billingPeriod == 'monthly').firstOrNull;

  @override
  List<Object?> get props => [id, packages];
}
