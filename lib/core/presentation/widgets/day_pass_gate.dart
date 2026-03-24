import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/monetization/presentation/providers/ad_gate_provider.dart';

/// Shows a DayPass gate bottom sheet when the user's free trial has expired
/// and no valid DayPass is active.
///
/// Usage:
/// ```dart
/// onTap: () async {
///   final ok = await DayPassGate.check(context, ref);
///   if (!ok || !context.mounted) return;
///   context.push('/somewhere');
/// }
/// ```
///
/// Returns `true` if access is already granted (premium / trial / active),
/// or if the user just earned a reward by watching an ad.
/// Returns `false` if the user dismissed without watching, or if they cancelled.
abstract class DayPassGate {
  /// Checks DayPass status and, if expired, shows the gate bottom sheet.
  /// Returns `true` when the caller may proceed.
  static Future<bool> check(BuildContext context, WidgetRef ref) async {
    // Read from the live AsyncNotifier — its state is updated immediately
    // after every ad watch, paywall purchase, or status refresh.
    // Do NOT use adGateStatusProvider here: it is a FutureProvider that
    // caches its result until explicitly invalidated, causing the gate to
    // keep showing even after the user has already earned access.
    final status = await ref.read(adGateProvider.future);

    // Any status other than expired → allow through immediately
    if (status != DayPassStatus.expired && status != DayPassStatus.grace) {
      return true;
    }

    if (!context.mounted) return false;

    final granted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DayPassBottomSheet(ref: ref),
    );

    final didGrant = granted ?? false;
    if (didGrant) {
      // Invalidate the GoRouter status cache so redirect guards also
      // see the updated access level on the next route evaluation.
      ref.invalidate(adGateStatusProvider);
    }
    return didGrant;
  }
}

// ── Bottom sheet widget ───────────────────────────────────────────────────────

class _DayPassBottomSheet extends StatefulWidget {
  final WidgetRef ref;

  const _DayPassBottomSheet({required this.ref});

  @override
  State<_DayPassBottomSheet> createState() => _DayPassBottomSheetState();
}

class _DayPassBottomSheetState extends State<_DayPassBottomSheet> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white30 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.confirmation_num_rounded,
                  size: 38,
                  color: cs.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Get Today\'s Access',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Your free trial has ended. Watch a short ad to unlock '
                'full access for the next 24 hours — it helps us cover '
                'server & development costs.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Watch Ad button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _watchAd,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_circle_outline_rounded),
                  label: Text(
                    _isLoading ? 'Loading ad…' : 'Watch Ad – Free Daily Access',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Go Premium button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.of(context).pop(false);
                          context.push('/paywall');
                        },
                  icon: const Icon(Icons.workspace_premium_rounded),
                  label: const Text(
                    'Go Premium – No Ads Forever',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Dismiss
              TextButton(
                onPressed:
                    _isLoading ? null : () => Navigator.of(context).pop(false),
                child: Text(
                  'Maybe later',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ),
              Text(
                '♥  Built by a small indie team — thank you for your support',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.55),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _watchAd() async {
    setState(() => _isLoading = true);
    final earned =
        await widget.ref.read(adGateProvider.notifier).watchAdForAccess();
    if (!mounted) return;
    // Pop sheet with result: true if user earned access
    Navigator.of(context).pop(earned);
  }
}
