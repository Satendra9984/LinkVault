import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:link_vault/core/errors/failures.dart';
import 'package:link_vault/core/utils/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../mappers/user_profile_mapper.dart';

class SupabaseProfileRepository implements IProfileRepository {
  final SupabaseClient _supabase;

  SupabaseProfileRepository(this._supabase);

  @override
  Future<Either<Failure, void>> ensureProfileExists({
    required String userId,
    required String email,
    String? displayName,
  }) async {
    try {
      AppLogger.d('profile_bootstrap_attempt user=$userId');
      final existing = await _supabase
          .from('lv_user_profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();
      if (existing != null) {
        AppLogger.d('profile_bootstrap_success user=$userId created=false');
        return const Right(null);
      }

      final fallbackName =
          (displayName != null && displayName.trim().isNotEmpty)
              ? displayName.trim()
              : email.split('@').first;

      try {
        await _supabase.from('lv_user_profiles').insert({
          'id': userId,
          'display_name': fallbackName,
        });
      } on PostgrestException catch (e) {
        if (e.code == '23505') {
          // EC-02: row created concurrently by trigger/another client flow.
          AppLogger.d(
            'profile_bootstrap_success user=$userId created=false duplicate_race=true',
          );
          return const Right(null);
        }
        rethrow;
      }
      AppLogger.i('profile_bootstrap_success user=$userId created=true');
      return const Right(null);
    } on PostgrestException catch (e) {
      AppLogger.w('profile_bootstrap_failure user=$userId error=${e.message}');
      return Left(DatabaseFailure(e.message));
    } catch (e, st) {
      AppLogger.e('profile_bootstrap_failure_trace', e, st);
      return Left(
          UnexpectedFailure('Failed to ensure profile', error: e, stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> getProfile(String userId) async {
    try {
      final data = await _supabase
          .from('lv_user_profiles')
          .select()
          .eq('id', userId)
          .single();
      return Right(UserProfileMapper.fromJson(data));
    } on PostgrestException catch (e) {
      AppLogger.w(
        'profile_fetch_failure user=$userId code=${e.code} message=${e.message} details=${e.details} hint=${e.hint}',
      );
      return Left(DatabaseFailure(
        '[${e.code ?? 'postgrest'}] ${e.message}',
      ));
    } catch (e, st) {
      AppLogger.e('profile_fetch_unexpected user=$userId', e, st);
      return Left(UnexpectedFailure('Failed to load profile',
          error: e, stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile({
    required String userId,
    String? displayName,
    String? bio,
    bool? activitySharingEnabled,
  }) async {
    try {
      final updates = <String, dynamic>{
        if (displayName != null) 'display_name': displayName,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final data = await _supabase
          .from('lv_user_profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return Right(UserProfileMapper.fromJson(data));
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e, st) {
      return Left(UnexpectedFailure('Update failed', error: e, stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar({
    required String userId,
    required File avatarFile,
  }) async {
    try {
      final fileExt = avatarFile.path.split('.').last;
      final filePath = '$userId/avatar.$fileExt';
      AppLogger.d('avatar_upload_attempt user=$userId path=$filePath');

      await _supabase.storage.from('avatars').upload(
            filePath,
            avatarFile,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl =
          _supabase.storage.from('avatars').getPublicUrl(filePath);

      // Update lv_user_profiles with new avatar URL.
      await _supabase
          .from('lv_user_profiles')
          .update({'avatar_url': publicUrl}).eq('id', userId);

      AppLogger.i('avatar_upload_success user=$userId');
      return Right(publicUrl);
    } on StorageException catch (e) {
      AppLogger.w(
        'avatar_upload_failure user=$userId status=${e.statusCode} message=${e.message}',
      );
      final lower = e.message.toLowerCase();
      if (lower.contains('row-level security') ||
          lower.contains('not authorized') ||
          lower.contains('permission')) {
        return Left(UnexpectedFailure(
          'Avatar upload is currently unavailable due to storage permissions. Please try again later.',
        ));
      }
      return Left(UnexpectedFailure(e.message));
    } on PostgrestException catch (e) {
      AppLogger.w(
        'avatar_profile_update_failure user=$userId code=${e.code} message=${e.message}',
      );
      return Left(UnexpectedFailure(
        'Avatar uploaded, but profile update failed. Please retry.',
      ));
    } catch (e, st) {
      AppLogger.e('avatar_upload_unexpected user=$userId', e, st);
      return Left(
          UnexpectedFailure('Avatar upload failed', error: e, stackTrace: st));
    }
  }
}
