import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link_vault/features/auth/domain/entities/auth_user.dart';
import 'package:link_vault/features/auth/presentation/providers/auth_providers.dart';
import 'package:link_vault/features/monetization/presentation/providers/premium_provider.dart';

void main() {
  test('isPremiumProvider is true when DB premium is true', () {
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith(
          (ref) => const AuthUser(
            supabaseId: 'u1',
            email: 'u1@test.dev',
            isPremium: true,
          ),
        ),
        revenueCatPremiumProvider.overrideWith((ref) => Stream.value(false)),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(isPremiumProvider), isTrue);
  });

  test('isPremiumProvider is true when RC premium is true', () async {
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith(
          (ref) => const AuthUser(
            supabaseId: 'u1',
            email: 'u1@test.dev',
            isPremium: false,
          ),
        ),
        revenueCatPremiumProvider.overrideWith((ref) => Stream.value(true)),
      ],
    );
    addTearDown(container.dispose);

    // Prime stream provider value before reading merged provider.
    await container.read(revenueCatPremiumProvider.future);
    expect(container.read(isPremiumProvider), isTrue);
  });

  test('isPremiumProvider is false when both DB and RC are false', () async {
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith(
          (ref) => const AuthUser(
            supabaseId: 'u1',
            email: 'u1@test.dev',
            isPremium: false,
          ),
        ),
        revenueCatPremiumProvider.overrideWith((ref) => Stream.value(false)),
      ],
    );
    addTearDown(container.dispose);

    await container.read(revenueCatPremiumProvider.future);
    expect(container.read(isPremiumProvider), isFalse);
  });
}
