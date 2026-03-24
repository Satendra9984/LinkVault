import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/app_settings_repository.dart';
import '../infrastructure/providers.dart';
import '../../features/monetization/domain/repositories/i_daypass_repository.dart';
import '../../features/monetization/data/repositories/daypass_repository_impl.dart';

/// objectbox-backed repository for onboarding, guest mode, DayPass, premium cache.
/// This is the new single source-of-truth for all local app-level flags.
final appSettingsRepositoryProvider = Provider<AppSettingsRepository>((ref) {
  return AppSettingsRepository(ref.watch(appDatabaseProvider).store);
});

/// DayPass-specific repository — implements [IDayPassRepository] by delegating
/// to [AppSettingsRepository]. Use this in all monetization use cases.
final daypassRepositoryProvider = Provider<IDayPassRepository>((ref) {
  return DayPassRepositoryImpl(ref.watch(appSettingsRepositoryProvider));
});

// REMOVED: userRepositoryProvider (was SharedPreferences-backed UserPreferencesRepository)
// splash_provider.dart was the only consumer — that file is also now orphaned and can be deleted.
