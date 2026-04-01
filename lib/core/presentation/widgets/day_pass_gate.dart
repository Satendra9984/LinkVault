import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/monetization/presentation/providers/ad_gate_provider.dart';
import '../../../features/monetization/presentation/screens/day_pass_screen.dart'
    show DayPassScreenArgs;

/// Curate-style gate: parent actions call [DayPassGate.check] before navigation.
///
/// When access is [DayPassStatus.expired], pushes [DayPassScreen] at `/daypass`
/// and awaits a typed result (`true` = access granted, `false` = dismissed).
/// Premium, trial, active pass, and **grace** all return `true` immediately
/// (see [Premium_Feature_Gating_Matrix.md] — grace is allowed).
///
/// Usage:
/// ```dart
/// onTap: () async {
///   final ok = await DayPassGate.check(context, ref);
///   if (!ok || !context.mounted) return;
///   context.push('/somewhere');
/// }
/// ```
abstract class DayPassGate {
  /// Returns `true` when the caller may proceed.
  static Future<bool> check(BuildContext context, WidgetRef ref) async {
    // Read from the live AsyncNotifier — its state is updated immediately
    // after every ad watch, paywall purchase, or status refresh.
    // Do NOT use adGateStatusProvider here: it is a FutureProvider that
    // caches its result until explicitly invalidated, causing the gate to
    // keep showing even after the user has already earned access.
    final status = await ref.read(adGateProvider.future);

    if (status != DayPassStatus.expired) {
      return true;
    }

    if (!context.mounted) return false;

    final granted = await context.push<bool>(
          '/daypass',
          extra: const DayPassScreenArgs(fromAccessGate: true),
        ) ??
        false;

    if (granted) {
      // Invalidate the GoRouter status cache so redirect guards also
      // see the updated access level on the next route evaluation.
      ref.invalidate(adGateStatusProvider);
    }
    return granted;
  }
}
