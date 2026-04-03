import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../data/repositories/app_settings_repository.dart';
import '../infrastructure/providers.dart';
import '../../features/monetization/domain/repositories/i_daypass_repository.dart';
import '../../features/monetization/data/repositories/daypass_repository_impl.dart';
import '../../features/profile/data/repositories/supabase_profile_repository.dart';
import '../../features/profile/domain/repositories/i_profile_repository.dart';

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

/// Supabase-backed user profile (shared across profile + monetization).
final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  return SupabaseProfileRepository(sb.Supabase.instance.client);
});

// REMOVED: userRepositoryProvider (was SharedPreferences-backed UserPreferencesRepository)
// splash_provider.dart was the only consumer — that file is also now orphaned and can be deleted.
