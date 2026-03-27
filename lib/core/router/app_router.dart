import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/repositories/i_auth_repository.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/auth_email_screen.dart';
import '../../features/auth/presentation/screens/auth_verify_screen.dart';
import '../../features/monetization/presentation/screens/paywall_screen.dart';
import '../../features/monetization/presentation/screens/migration_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/collections/domain/entities/collection.dart';
import '../../features/collections/presentation/screens/collections_branch_root_screen.dart';
import '../../features/collections/presentation/screens/search_collections_screen.dart';
import '../../features/home/presentation/screens/home_dashboard_screen.dart';
import '../../features/collections/presentation/screens/create_collection_screen.dart';
import '../../features/collections/presentation/screens/edit_collection_screen.dart';
import '../../features/items/presentation/screens/create_edit_item_screen.dart';
import '../../features/items/presentation/screens/item_detail_screen.dart';
import '../../features/items/presentation/screens/items_list_screen.dart';
import '../../features/monetization/presentation/screens/ad_gate_screen.dart';
import '../../features/monetization/presentation/screens/day_pass_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/app_settings_screen.dart';
import '../../features/profile/presentation/screens/about_screen.dart';
import '../../features/profile/presentation/screens/legal_policy_screen.dart';
import '../../features/debug/presentation/screens/debug_screen.dart';
import '../presentation/widgets/main_shell.dart';
import '../providers/core_providers.dart';

// Accessible regardless of auth state — excluded from redirect logic
const _openRoutes = ['/paywall', '/ad-gate', '/migration'];

// ── Router stream listener ────────────────────────────────────────────────────

/// Converts the [authStateProvider] stream into a [Listenable] so GoRouter
/// calls its redirect whenever auth state changes.
class _AuthStateListenable extends ChangeNotifier {
  late final ProviderSubscription _subscription;

  _AuthStateListenable(ProviderContainer container) {
    _subscription = container.listen(
      authStateProvider,
      (_, __) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

// ── Router factory ────────────────────────────────────────────────────────────

GoRouter createAppRouter(ProviderContainer container) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthStateListenable(container),
    redirect: (context, state) async {
      final loc = state.matchedLocation;

      // ── 1. Always allow splash, onboarding and open routes ─────────────
      if (loc == '/splash') return null;
      if (_openRoutes.contains(loc)) return null;

      // ── 2. Check onboarding ────────────────────────────────────────────
      final settingsRepo = container.read(appSettingsRepositoryProvider);
      final hasSeenOnboarding = await settingsRepo.hasSeenOnboarding();
      if (!hasSeenOnboarding) {
        return loc == '/onboarding' ? null : '/onboarding';
      }

      // ── 3. Check auth state ────────────────────────────────────────────
      final authAsync = container.read(authStateProvider);

      // While auth is loading, stay on current location
      if (authAsync.isLoading) return null;

      final user = authAsync.valueOrNull;
      final isGuestMode = await settingsRepo.isGuestMode();
      final normalizedGuestMode = (user != null) ? false : isGuestMode;
      if (user != null && isGuestMode) {
        // Authenticated session always wins over stale guest flag.
        await settingsRepo.setGuestMode(value: false);
      }
      final hasAccess = user != null || normalizedGuestMode;

      // ── 4. Authenticated/guest users must not revisit onboarding ───────
      if (hasAccess && loc == '/onboarding') return '/';

      // ── 5. If no access and not on an auth route, go to welcome ────────
      if (!hasAccess && !loc.startsWith('/auth')) {
        return '/auth/welcome';
      }

      // ── 6. If genuinely authenticated, prevent visiting auth welcome directly
      if (user != null &&
          (loc == '/auth/welcome' || loc.startsWith('/login-callback'))) {
        return '/';
      }

      // ── 7. Catch OAuth deep links to prevent 404s while loading
      if (loc.startsWith('/login-callback')) {
        return null; // Stay here while watchAuthState processes the session
      }

      // ── 8. Guest modes can freely visit auth routes or internal protected routes.
      // DayPass is enforced contextually in each screen via DayPassGate.check().

      return null; // No redirect needed
    },
    routes: [
      // ── Init routes ──────────────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ── Auth routes ──────────────────────────────────────────────────────
      GoRoute(
        path: '/auth/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/auth/email',
        builder: (context, state) {
          final type = state.extra as AppOtpType?;
          return AuthEmailScreen(
            params: AuthEmailScreenParams(
                initialType: type ?? AppOtpType.magiclink),
          );
        },
      ),
      GoRoute(
        path: '/auth/verify',
        builder: (context, state) {
          final params = state.extra as AuthVerifyScreenParams?;
          if (params == null) {
            return AuthEmailScreen(
              params: const AuthEmailScreenParams(
                initialType: AppOtpType.magiclink,
              ),
            );
          }
          return AuthVerifyScreen(params: params);
        },
      ),

      // ── Standalone screens (no bottom nav) ───────────────────────────────
      GoRoute(
        path: '/paywall',
        builder: (context, state) => const PaywallScreen(),
      ),
      GoRoute(
        path: '/ad-gate',
        builder: (context, state) => const AdGateScreen(),
      ),
      GoRoute(
        path: '/migration',
        builder: (context, state) => const MigrationScreen(),
      ),
      GoRoute(
        path: '/daypass',
        builder: (context, state) => const DayPassScreen(),
      ),

      // ── Collection push-routes (rendered on top of the shell / no bottom nav tab) ──
      // These are accessed from within the Collections tab or Home, but
      // they overlay the full screen (create/edit flow, item detail).
      GoRoute(
        path: '/collections/create',
        builder: (context, state) {
          final extra = state.extra;
          final parent = extra is Collection ? extra : null;
          return CreateCollectionScreen(
            parentId: state.uri.queryParameters['parent'] ?? parent?.id,
            parentCollection: parent,
          );
        },
      ),

      // ── Main app shell (persistent bottom nav for 4 tabs) ────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          // ── Branch 0: Home ──────────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeDashboardScreen(),
              ),
            ],
          ),

          // ── Branch 1: Collections ────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/collections',
                builder: (context, state) =>
                    const CollectionsBranchRootScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      final collectionName = state.extra as String?;
                      return ItemsListScreen(
                        collectionId: id,
                        collectionName: collectionName,
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return EditCollectionScreen(collectionId: id);
                        },
                      ),
                      GoRoute(
                        path: 'items/create',
                        builder: (context, state) {
                          final collectionId = state.pathParameters['id']!;
                          final collectionName = state.extra as String?;
                          return CreateEditItemScreen(
                            collectionId: collectionId,
                            collectionName: collectionName,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'items/:itemId',
                        builder: (context, state) {
                          final collectionId = state.pathParameters['id']!;
                          final itemId = state.pathParameters['itemId']!;
                          return ItemDetailScreen(
                            collectionId: collectionId,
                            itemId: itemId,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'items/:itemId/edit',
                        builder: (context, state) {
                          final collectionId = state.pathParameters['id']!;
                          final itemId = state.pathParameters['itemId']!;
                          final collectionName = state.extra as String?;
                          return CreateEditItemScreen(
                            collectionId: collectionId,
                            itemId: itemId,
                            collectionName: collectionName,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // ── Branch 2: Search ─────────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchCollectionsScreen(),
              ),
            ],
          ),

          // ── Branch 3: Profile ─────────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const AppSettingsScreen(),
                  ),
                  GoRoute(
                    path: 'about',
                    builder: (context, state) => const AboutScreen(),
                  ),
                  GoRoute(
                    path: 'legal',
                    builder: (context, state) => const LegalPolicyScreen(),
                  ),
                  GoRoute(
                    path: 'debug',
                    builder: (context, state) => const DebugScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Default router instance for [bootstrap.dart].
/// Replaced by [createAppRouter] when a [ProviderContainer] is available.
final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
  ],
);
