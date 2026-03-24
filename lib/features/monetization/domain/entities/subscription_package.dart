import 'package:equatable/equatable.dart';

/// Pure Dart domain entity representing a purchasable subscription plan.
///
/// This is the domain-layer representation — it is completely independent
/// of RevenueCat or any other billing SDK. The [RevenueCatPremiumRepository]
/// maps native RC [Package] objects to this entity.
class SubscriptionPackage extends Equatable {
  /// The RevenueCat package identifier (e.g. `'$rc_annual'`).
  final String id;

  /// Human-readable plan name (e.g. `'Annual Plan'`).
  final String title;

  /// Localised formatted price string (e.g. `'₹999.00/yr'`).
  final String priceString;

  /// Raw price in the store's currency for comparison/analytics.
  final double price;

  /// ISO-4217 currency code (e.g. `'INR'`, `'USD'`).
  final String currencyCode;

  /// Billing period: `'monthly'`, `'annual'`, or `'unknown'`.
  final String billingPeriod;

  const SubscriptionPackage({
    required this.id,
    required this.title,
    required this.priceString,
    required this.price,
    required this.currencyCode,
    required this.billingPeriod,
  });

  @override
  List<Object?> get props =>
      [id, title, priceString, price, currencyCode, billingPeriod];
}
