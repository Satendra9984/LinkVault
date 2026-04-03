import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link_vault/features/auth/domain/entities/auth_user.dart';
import 'package:link_vault/features/auth/presentation/providers/auth_providers.dart';

void main() {
  test('isGuestProvider is false when Supabase user present', () async {
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith(
          (ref) => Stream.value(
            const AuthUser(
              supabaseId: 'user-uuid',
              email: 'a@example.com',
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authStateProvider.future);
    expect(container.read(isGuestProvider), isFalse);
  });

  test('isGuestProvider is true when auth stream emits null user', () async {
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(null)),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authStateProvider.future);
    expect(container.read(isGuestProvider), isTrue);
  });
}
