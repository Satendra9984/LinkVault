// ignore_for_file: deprecated_member_use
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/subscription_offering.dart';
import '../../domain/entities/subscription_package.dart';
import '../../domain/usecases/get_offerings_usecase.dart';
import '../../domain/usecases/purchase_premium_usecase.dart';
import '../../domain/usecases/restore_purchases_usecase.dart';
import 'premium_provider.dart';

// ── View State ────────────────────────────────────────────────────────────────

enum PaywallStatus { idle, purchasing, success, error }

/// Immutable state for the [PaywallViewModel].
///
/// Follows the MVVM pattern — the View observes this state and rebuilds
/// reactively. The ViewModel mutates it via [AsyncNotifier.state].
class PaywallState {
  final PaywallStatus status;
  final String? errorMessage;
  final SubscriptionOffering? offering;
  final SubscriptionPackage? selectedPackage;
  final bool isPurchasing;

  const PaywallState({
    this.status = PaywallStatus.idle,
    this.errorMessage,
    this.offering,
    this.selectedPackage,
    this.isPurchasing = false,
  });

  PaywallState copyWith({
    PaywallStatus? status,
    String? errorMessage,
    bool clearError = false,
    SubscriptionOffering? offering,
    SubscriptionPackage? selectedPackage,
    bool? isPurchasing,
  }) =>
      PaywallState(
        status: status ?? this.status,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        offering: offering ?? this.offering,
        selectedPackage: selectedPackage ?? this.selectedPackage,
        isPurchasing: isPurchasing ?? this.isPurchasing,
      );
}

// ── Provider ──────────────────────────────────────────────────────────────────

final paywallViewModelProvider =
    AsyncNotifierProvider<PaywallViewModel, PaywallState>(
        () => PaywallViewModel());

// ── ViewModel ─────────────────────────────────────────────────────────────────

/// The **ViewModel** in the MVVM pattern for the Paywall feature.
///
/// Responsibilities:
/// - Orchestrates [GetOfferingsUseCase], [PurchasePremiumUseCase], [RestorePurchasesUseCase]
/// - Manages [PaywallState] — the View only reads this state and calls methods
/// - Calls [_onPremiumGranted] on success to write cache + refresh auth stream
/// - Never imports Flutter UI classes (no BuildContext, no widgets)
class PaywallViewModel extends AsyncNotifier<PaywallState> {
  final Logger _logger = Logger();

  @override
  Future<PaywallState> build() async {
    return _loadOfferings();
  }

  // ── Load Offerings ─────────────────────────────────────────────────────────

  Future<PaywallState> _loadOfferings() async {
    _logger.d('[PaywallVM] Loading offerings...');
    final useCase = ref.read(getOfferingsUseCaseProvider);
    final result = await useCase();

    return result.fold(
      (failure) {
        _logger.w('[PaywallVM] Offerings failed: ${failure.message}');
        return PaywallState(
          status: PaywallStatus.error,
          errorMessage: failure.message,
        );
      },
      (offering) {
        _logger.i('[PaywallVM] Offerings loaded: ${offering.id}');
        // Default select annual if available, otherwise monthly.
        final defaultPackage = offering.annual ?? offering.monthly;
        return PaywallState(
          status: PaywallStatus.idle,
          offering: offering,
          selectedPackage: defaultPackage,
        );
      },
    );
  }

  // ── Select Package ─────────────────────────────────────────────────────────

  void selectPackage(SubscriptionPackage package) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(selectedPackage: package));
  }

  // ── Purchase ───────────────────────────────────────────────────────────────

  /// Initiates a native purchase. Returns true on success.
  Future<bool> purchasePackage() async {
    final current = state.value;
    if (current?.selectedPackage == null) return false;

    final packageId = current!.selectedPackage!.id;
    _logger.i('[PaywallVM] Purchase START: $packageId');
    state = AsyncData(current.copyWith(isPurchasing: true, clearError: true));

    final useCase = ref.read(purchasePremiumUseCaseProvider);
    final result = await useCase(packageId);

    return result.fold(
      (failure) {
        _logger.e('[PaywallVM] Purchase FAILED: ${failure.message}');
        // Don't show error for user cancellation.
        final isCancellation = failure.message.contains('cancelled');
        state = AsyncData(state.value!.copyWith(
          isPurchasing: false,
          errorMessage: isCancellation ? null : failure.message,
        ));
        return false;
      },
      (isPremium) async {
        if (isPremium) {
          _logger.i('[PaywallVM] Purchase SUCCESS — granting premium.');
          await _onPremiumGranted();
          state = AsyncData(state.value!.copyWith(
            isPurchasing: false,
            status: PaywallStatus.success,
          ));
          return true;
        } else {
          state = AsyncData(state.value!.copyWith(
            isPurchasing: false,
            errorMessage: 'Purchase completed but premium was not activated.',
          ));
          return false;
        }
      },
    );
  }

  // ── Restore ────────────────────────────────────────────────────────────────

  /// Restores prior purchases. Returns true if premium found.
  Future<bool> restorePurchases() async {
    _logger.i('[PaywallVM] Restore START');
    state = AsyncData(state.value!.copyWith(isPurchasing: true, clearError: true));

    final useCase = ref.read(restorePurchasesUseCaseProvider);
    final result = await useCase();

    return result.fold(
      (failure) {
        _logger.e('[PaywallVM] Restore FAILED: ${failure.message}');
        state = AsyncData(state.value!.copyWith(
          isPurchasing: false,
          errorMessage: failure.message,
        ));
        return false;
      },
      (isPremium) async {
        _logger.i('[PaywallVM] Restore RESULT: isPremium=$isPremium');
        if (isPremium) await _onPremiumGranted();
        state = AsyncData(state.value!.copyWith(
          isPurchasing: false,
          status: isPremium ? PaywallStatus.success : PaywallStatus.idle,
          errorMessage: isPremium ? null : 'No previous purchases found.',
        ));
        return isPremium;
      },
    );
  }

  // ── Internal Helpers ───────────────────────────────────────────────────────

  /// Writes premium status to local cache and invalidates the auth stream
  /// so [isPremiumProvider] and [adGateProvider] immediately reflect the
  /// new state across all widgets.
  Future<void> _onPremiumGranted() async {
    final settings = ref.read(appSettingsRepositoryProvider);
    await settings.cachePremiumStatus(isPremium: true);
    ref.invalidate(authStateProvider);
    _logger.i('[PaywallVM] Premium granted and auth stream refreshed.');
  }
}
