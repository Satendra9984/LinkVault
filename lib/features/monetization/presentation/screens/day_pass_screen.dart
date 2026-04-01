import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/day_pass_provider.dart';

// ── Brand accent — same in both modes (orange gradient) ──────────────────────
const _kCardStart = Color(0xFFFF6B4A);
const _kCardEnd = Color(0xFFFF4016);

/// Route [extra] for `/daypass` when opened from [DayPassGate] —
/// enables `context.pop(true|false)` contract for [DayPassGate.check].
class DayPassScreenArgs {
  final bool fromAccessGate;
  const DayPassScreenArgs({this.fromAccessGate = false});
}

/// DayPass management screen — reads [dayPassProvider] ViewModel.
///
/// When [fromAccessGate] is true (access gate flow), back/cancel returns
/// `false`; when the user earns access (watch ad, premium, or grace), returns
/// `true` via `context.pop(true)`.
class DayPassScreen extends ConsumerStatefulWidget {
  const DayPassScreen({super.key, this.fromAccessGate = false});

  /// When true, this route was pushed by [DayPassGate] to resolve expired access.
  final bool fromAccessGate;

  @override
  ConsumerState<DayPassScreen> createState() => _DayPassScreenState();
}

class _DayPassScreenState extends ConsumerState<DayPassScreen> {
  bool _didPopGateResult = false;

  @override
  Widget build(BuildContext context) {
    if (widget.fromAccessGate) {
      // Premium / trial / active / grace → allow proceeding (matrix: grace allowed).
      ref.listen<AsyncValue<DayPassState>>(dayPassProvider, (prev, next) {
        next.whenData((s) {
          if (_didPopGateResult || !context.mounted) return;
          if (s.status != DayPassStatus.expired) {
            _didPopGateResult = true;
            context.pop(true);
          }
        });
      });
    }

    final stateAsync = ref.watch(dayPassProvider);
    final cs = Theme.of(context).colorScheme;

    void handleBack() {
      if (widget.fromAccessGate) {
        context.pop(false);
      } else {
        context.pop();
      }
    }

    return PopScope(
      canPop: !widget.fromAccessGate,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && widget.fromAccessGate && context.mounted) {
          context.pop(false);
        }
      },
      child: Scaffold(
        // Let scaffold bg come from theme (dark=#0F0F0F, light=#F8F9FA)
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: cs.onSurface, size: 20),
            onPressed: handleBack,
          ),
          title: Text(
            'Daily Access Pass',
            style: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: stateAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: cs.primary),
          ),
          error: (e, _) => Center(
            child: Text('Something went wrong',
                style: TextStyle(color: cs.onSurfaceVariant)),
          ),
          data: (s) => _DayPassBody(state: s),
        ),
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _DayPassBody extends ConsumerWidget {
  final DayPassState state;
  const _DayPassBody({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final notifier = ref.read(dayPassProvider.notifier);
    final size = MediaQuery.sizeOf(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Hero gradient card — always vibrant, not theme-dependent ─────
          SizedBox(
            height: size.height * 0.46,
            child: _HeroCard(state: state, cs: cs),
          ),

          // ── Content area (adapts to theme) ───────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Session stack chip
                if (state.adsWatchedThisSession > 0) ...[
                  _InfoChip(
                    icon: Icons.layers_rounded,
                    label:
                        '+${state.adsWatchedThisSession * 24}h stacked this session',
                    tint: cs.primary,
                  ),
                  const SizedBox(height: 16),
                ],

                // Error chip
                if (state.errorMessage != null) ...[
                  _InfoChip(
                    icon: Icons.error_outline_rounded,
                    label: state.errorMessage!,
                    tint: cs.error,
                  ),
                  const SizedBox(height: 16),
                ],

                // Primary CTA
                if (_showWatchButton(state.status))
                  _WatchAdButton(
                    isActive: state.status == DayPassStatus.active,
                    isLoading: state.isWatchingAd,
                    cs: cs,
                    onTap: () async {
                      final earned = await notifier.watchAd();
                      if (!earned && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                'Ad unavailable — grace period active'),
                            backgroundColor: cs.surfaceContainerLow,
                          ),
                        );
                      }
                    },
                  ),

                const SizedBox(height: 12),

                // Premium CTA
                if (state.status != DayPassStatus.premium)
                  _PremiumButton(
                    cs: cs,
                    onTap: state.isWatchingAd
                        ? null
                        : () async {
                            final upgraded =
                                await context.push<bool>('/paywall') ?? false;
                            if (upgraded && context.mounted) {
                              await notifier.refresh();
                            }
                          },
                  ),

                const SizedBox(height: 36),

                // How it works
                _HowItWorks(cs: cs),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _showWatchButton(DayPassStatus status) =>
      status == DayPassStatus.expired ||
      status == DayPassStatus.grace ||
      status == DayPassStatus.active;
}

// ── Hero gradient card ────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final DayPassState state;
  final ColorScheme cs;

  const _HeroCard({required this.state, required this.cs});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    final (label, isPassing) = switch (state.status) {
      DayPassStatus.premium => ('✦  Premium Active', true),
      DayPassStatus.freeTrial => ('✔  Free Trial Active', true),
      DayPassStatus.active => ('✔  Access Active', true),
      DayPassStatus.grace => ('⏳  Grace Period', false),
      DayPassStatus.expired => ('✕  Access Expired', false),
    };

    final showCountdown = (state.status == DayPassStatus.active ||
            state.status == DayPassStatus.freeTrial ||
            state.status == DayPassStatus.grace) &&
        state.remaining > Duration.zero;

    final progress = (state.remaining.inSeconds / (24 * 3600)).clamp(0.0, 1.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient hero — brand orange always, lighter gradient on light mode
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [_kCardStart, _kCardEnd]
                  : [_kCardStart, const Color(0xFFE84520)],
            ),
          ),
        ),

        // Decorative orbs
        Positioned(
          top: -40,
          right: -40,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.14),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: -30,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: isDark ? 0.06 : 0.10),
            ),
          ),
        ),

        // Content
        Padding(
          padding:
              EdgeInsets.only(top: top + 70, left: 24, right: 24, bottom: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status pill — glassmorphism
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1),
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),

              // Countdown or static icon
              if (showCountdown)
                _SegmentedCountdown(remaining: state.remaining)
              else
                Column(
                  children: [
                    Icon(
                      isPassing
                          ? Icons.workspace_premium_rounded
                          : Icons.timer_off_rounded,
                      size: 60,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isPassing ? 'Active' : 'Expired',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

              // Progress bar + label
              if (showCountdown)
                Column(
                  children: [
                    _ProgressBar(progress: progress),
                    const SizedBox(height: 6),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}% of 24h remaining',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Segmented countdown ───────────────────────────────────────────────────────

class _SegmentedCountdown extends StatelessWidget {
  final Duration remaining;
  const _SegmentedCountdown({required this.remaining});

  @override
  Widget build(BuildContext context) {
    final h = remaining.inHours.toString().padLeft(2, '0');
    final m = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _TimeSegment(value: h, label: 'HR'),
        _ColonSep(),
        _TimeSegment(value: m, label: 'MIN'),
        _ColonSep(),
        _TimeSegment(value: s, label: 'SEC'),
      ],
    );
  }
}

class _TimeSegment extends StatelessWidget {
  final String value;
  final String label;
  const _TimeSegment({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 58,
            fontWeight: FontWeight.w800,
            height: 1,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}

class _ColonSep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22, left: 6, right: 6),
      child: Text(':',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 44,
            fontWeight: FontWeight.w300,
            height: 1,
          )),
    );
  }
}

// ── Progress bar ──────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final double progress;
  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 4,
        color: Colors.white.withValues(alpha: 0.25),
        child: FractionallySizedBox(
          widthFactor: progress,
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.white.withValues(alpha: 0.8), blurRadius: 6)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Primary CTA ───────────────────────────────────────────────────────────────

class _WatchAdButton extends StatelessWidget {
  final bool isActive;
  final bool isLoading;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _WatchAdButton({
    required this.isActive,
    required this.isLoading,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: isLoading
              ? null
              : const LinearGradient(
                  colors: [_kCardStart, _kCardEnd],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          color: isLoading ? cs.surfaceContainerLow : null,
          borderRadius: BorderRadius.circular(16),
          // boxShadow: isLoading
          //     ? []
          //     : [
          //         BoxShadow(
          //           color: cs.primary.withValues(alpha: 0.40),
          //           blurRadius: 18,
          //           offset: const Offset(0, 6),
          //         )
          //       ],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: cs.primary))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_circle_filled_rounded,
                        color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      isActive ? 'Extend Pass  +24h' : 'Watch Ad — Get Access',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Premium CTA ───────────────────────────────────────────────────────────────

class _PremiumButton extends StatelessWidget {
  final ColorScheme cs;
  final VoidCallback? onTap;
  const _PremiumButton({required this.cs, this.onTap});

  @override
  Widget build(BuildContext context) {
    final orange = cs.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          border: Border.all(color: orange.withValues(alpha: 0.7), width: 1.5),
          borderRadius: BorderRadius.circular(16),
          color: orange.withValues(alpha: 0.06),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.workspace_premium_rounded, color: orange, size: 20),
            const SizedBox(width: 10),
            Text(
              'Go Premium — No Ads Forever',
              style: TextStyle(
                color: orange,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info chip (stack / error) ─────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color tint;
  const _InfoChip(
      {required this.icon, required this.label, required this.tint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tint.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: tint),
          const SizedBox(width: 8),
          Flexible(
            child: Text(label,
                style: TextStyle(
                    color: tint, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ── How it works ──────────────────────────────────────────────────────────────

class _HowItWorks extends StatelessWidget {
  final ColorScheme cs;
  const _HowItWorks({required this.cs});

  static const _steps = [
    (Icons.hourglass_top_rounded, '3-day free trial — no ads at all'),
    (
      Icons.play_circle_outline_rounded,
      'After trial, watch one ad for 24h full access'
    ),
    (Icons.layers_rounded, 'Stack extra days by watching more ads anytime'),
    (Icons.workspace_premium_rounded, 'Go Premium to remove ads permanently'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How It Works',
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        ..._steps.map(
          (step) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(step.$1, size: 18, color: cs.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    step.$2,
                    style: TextStyle(
                        color: cs.onSurfaceVariant, fontSize: 14, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Why ads? — dev cost note
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.5), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.favorite_rounded, size: 17, color: cs.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Curate is built by a small indie team. Ads help cover '
                  'server & development costs so the app stays free to use.',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
