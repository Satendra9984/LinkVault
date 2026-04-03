import 'package:flutter_test/flutter_test.dart';
import 'package:link_vault/features/auth/presentation/providers/auth_notifier.dart';

void main() {
  test('AuthState copyWith clearError clears errorMessage', () {
    const s = AuthState(errorMessage: 'failed');
    final cleared = s.copyWith(clearError: true);
    expect(cleared.errorMessage, isNull);
    expect(cleared.isLoading, false);
  });

  test('AuthState copyWith preserves otpSent when not specified', () {
    const s = AuthState(otpSent: true);
    final next = s.copyWith(isLoading: true);
    expect(next.otpSent, isTrue);
  });
}
