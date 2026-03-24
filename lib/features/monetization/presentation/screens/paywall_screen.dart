// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/color_palette.dart';
import '../../domain/entities/subscription_package.dart';
import '../providers/paywall_view_model.dart';

/// The **View** in the MVVM pattern for the Paywall feature.
///
/// Responsibilities (View-only):
/// - Observes [paywallViewModelProvider] and rebuilds reactively
/// - Calls [PaywallViewModel] methods on user interactions
/// - Handles navigation side-effects on [PaywallStatus.success]
/// - Never imports repositories, use cases, or billing SDK types
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Invalidate on every entry so the VM reloads offerings fresh
    // and discards any stale error message from a previous visit.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(paywallViewModelProvider);
    });
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ── Theme helpers ──────────────────────────────────────────────────────────

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => _isDark ? AppColors.premiumDark : AppColors.background;
  Color get _text => _isDark ? AppColors.premiumTextLight : AppColors.premiumDark;
  Color get _accent => AppColors.premiumGold;
  Color get _cardBg => _isDark ? Colors.transparent : Colors.white;
  Color get _border => _isDark
      ? AppColors.premiumTextLight.withOpacity(0.15)
      : AppColors.premiumDark.withOpacity(0.15);

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Listen for purchase success → navigate to migration.
    ref.listen<AsyncValue<PaywallState>>(paywallViewModelProvider,
        (_, next) {
      next.whenData((state) {
        if (state.status == PaywallStatus.success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Welcome to Curate Premium! 🎉')),
          );
          context.go('/migration');
        }
      });
    });

    final vmAsync = ref.watch(paywallViewModelProvider);

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          SafeArea(
            child: vmAsync.when(
              data: (state) => _buildContent(state),
              loading: () => Center(child: CircularProgressIndicator(color: _accent)),
              error: (err, _) => Center(
                child: Text('Error: $err', style: TextStyle(color: _text)),
              ),
            ),
          ),
          // Full-screen overlay while purchasing.
          if (vmAsync.value?.isPurchasing == true)
            Container(
              color: _bg.withOpacity(0.8),
              child: Center(child: CircularProgressIndicator(color: _accent)),
            ),
        ],
      ),
    );
  }

  // ── Content ────────────────────────────────────────────────────────────────

  Widget _buildContent(PaywallState state) {
    if (state.status == PaywallStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            state.errorMessage ?? 'Packages currently unavailable.\nPlease check back later.',
            style: TextStyle(color: _text),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final offering = state.offering;
    if (offering == null) {
      return Center(child: CircularProgressIndicator(color: _accent));
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildHeader(context, state),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  _buildHeroSection(),
                  const SizedBox(height: 48),
                  _buildFeatureList(),
                  const SizedBox(height: 56),
                  if (offering.annual != null)
                    _buildPackageCard(
                      package: offering.annual!,
                      title: 'Annual Plan',
                      subtitle: 'Billed yearly',
                      badgeText: 'Save 33%',
                      isSelected: state.selectedPackage == offering.annual,
                    ),
                  const SizedBox(height: 16),
                  if (offering.monthly != null)
                    _buildPackageCard(
                      package: offering.monthly!,
                      title: 'Monthly Plan',
                      subtitle: 'Billed monthly',
                      isSelected: state.selectedPackage == offering.monthly,
                    ),
                  if (state.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildBottomAction(state),
        ],
      ),
    );
  }

  // ── Sub-Widgets ────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, PaywallState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.close, color: _text),
            onPressed: () => context.pop(),
          ),
          TextButton(
            onPressed: state.isPurchasing ? null : _onRestoreTapped,
            child: Text(
              'Restore',
              style: TextStyle(
                color: _text.withOpacity(0.6),
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CURATE',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 4.0,
            fontWeight: FontWeight.w600,
            color: _accent,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Curate your life,\nwithout limits.',
          style: TextStyle(
            fontSize: 40,
            fontFamily: 'Fraunces',
            color: _text,
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureList() {
    const features = [
      'No ads forever',
      'Unlimited collections & items',
      'Cloud sync across devices',
      'Share collections with friends',
      'Priority customer support',
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Row(
            children: [
              Icon(Icons.check, color: _accent, size: 18),
              const SizedBox(width: 24),
              Expanded(
                child: Text(
                  feature,
                  style: TextStyle(
                    fontSize: 16,
                    color: _text.withOpacity(0.85),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPackageCard({
    required SubscriptionPackage package,
    required String title,
    required String subtitle,
    String? badgeText,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => ref.read(paywallViewModelProvider.notifier).selectPackage(package),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _accent : _border,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected && !_isDark
              ? [
                  BoxShadow(
                    color: _accent.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Fraunces',
                          fontWeight: FontWeight.w600,
                          color: isSelected ? _accent : _text,
                        ),
                      ),
                      if (badgeText != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            border: Border.all(color: _accent),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badgeText.toUpperCase(),
                            style: TextStyle(
                              color: _accent,
                              fontSize: 10,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      letterSpacing: 0.5,
                      color: _text.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              package.priceString,
              style: TextStyle(
                fontSize: 22,
                fontFamily: 'Fraunces',
                fontWeight: FontWeight.bold,
                color: isSelected ? _text : _text.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction(PaywallState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: BoxDecoration(
        color: _isDark ? AppColors.premiumDark : Colors.white,
        border: Border(top: BorderSide(color: _border, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: (state.selectedPackage == null || state.isPurchasing)
                  ? null
                  : _onPurchaseTapped,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: AppColors.premiumDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: const Text(
                'UNLOCK PREMIUM',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Cancel anytime in your device settings. By continuing, you agree to our Terms of Service and Privacy Policy.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                height: 1.5,
                color: _text.withOpacity(0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Event Handlers ─────────────────────────────────────────────────────────

  Future<void> _onPurchaseTapped() async {
    await ref.read(paywallViewModelProvider.notifier).purchasePackage();
    // Navigation is handled via ref.listen above on PaywallStatus.success.
  }

  Future<void> _onRestoreTapped() async {
    final success =
        await ref.read(paywallViewModelProvider.notifier).restorePurchases();
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchases successfully restored! 🎉')),
      );
      context.go('/migration');
    } else {
      final msg = ref.read(paywallViewModelProvider).value?.errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg ?? 'No active subscriptions found.')),
      );
    }
  }
}
