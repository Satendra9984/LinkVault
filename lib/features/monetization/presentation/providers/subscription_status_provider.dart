import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Streams the **live** subscription active status from RevenueCat.
///
/// This is distinct from [isPremiumProvider] (which can be true from a DB
/// cache). This provider is the authoritative live signal directly from RC.
///
/// - `true`  → subscription is paid and currently active
/// - `false` → expired, cancelled, or never subscribed
final isSubscriptionActiveProvider = StreamProvider<bool>((ref) {
  final controller = StreamController<bool>.broadcast();

  // Emit initial state immediately
  Purchases.getCustomerInfo().then((info) {
    if (!controller.isClosed) {
      controller.add(info.entitlements.all['premium']?.isActive ?? false);
    }
  }).catchError((_) {
    if (!controller.isClosed) controller.add(false);
  });

  void listener(CustomerInfo info) {
    if (!controller.isClosed) {
      controller.add(info.entitlements.all['premium']?.isActive ?? false);
    }
  }

  Purchases.addCustomerInfoUpdateListener(listener);

  controller.onCancel = () {
    Purchases.removeCustomerInfoUpdateListener(listener);
    controller.close();
  };

  return controller.stream;
});
