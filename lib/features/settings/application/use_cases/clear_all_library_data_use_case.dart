import 'package:objectbox/objectbox.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'clear_local_library_use_case.dart';

/// Result of clearing local + optional cloud library content.
class ClearAllLibraryOutcome {
  /// Device library (ObjectBox) was wiped.
  final bool localCleared;

  /// User was signed in and cloud delete was attempted.
  final bool cloudAttempted;

  /// Cloud rows were removed successfully (URLs + collections + fresh Library root).
  final bool cloudCleared;

  final String? cloudErrorMessage;

  const ClearAllLibraryOutcome({
    required this.localCleared,
    required this.cloudAttempted,
    required this.cloudCleared,
    this.cloudErrorMessage,
  });
}

/// Clears all library data on device; optionally clears the user's cloud library
/// (collections + links only, not profile) when [userId] is set and [isOnline] is true.
class ClearAllLibraryDataUseCase {
  ClearAllLibraryDataUseCase(this._store, this._supabase);

  final Store _store;
  final SupabaseClient _supabase;

  /// When signed in but offline, returns failure and does not clear anything.
  Future<ClearAllLibraryOutcome> call({
    required String? userId,
    required bool isOnline,
  }) async {
    if (userId != null && !isOnline) {
      return const ClearAllLibraryOutcome(
        localCleared: false,
        cloudAttempted: false,
        cloudCleared: false,
        cloudErrorMessage:
            'You’re offline. Connect to the internet to clear your cloud library, or sign out to clear this device only.',
      );
    }

    var cloudAttempted = false;
    var cloudCleared = false;
    String? cloudErr;

    if (userId != null && isOnline) {
      cloudAttempted = true;
      try {
        await _supabase.from('lv_urls').delete().eq('owner_id', userId);
        await _supabase.from('lv_collections').delete().eq('owner_id', userId);
        await _supabase
            .rpc('ensure_library_root', params: {'p_owner_id': userId});
        cloudCleared = true;
      } catch (e) {
        cloudErr = e.toString();
      }
    }

    await ClearLocalLibraryUseCase(_store).call();

    return ClearAllLibraryOutcome(
      localCleared: true,
      cloudAttempted: cloudAttempted,
      cloudCleared: cloudCleared,
      cloudErrorMessage: cloudErr,
    );
  }
}
