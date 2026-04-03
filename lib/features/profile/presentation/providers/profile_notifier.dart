import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../monetization/presentation/providers/ad_gate_provider.dart';
import '../../../monetization/presentation/providers/day_pass_provider.dart';
import '../../../sync/data/sync_metadata_store.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_profile_use_case.dart';
import '../../domain/usecases/update_profile_use_case.dart';
import '../../domain/usecases/upload_avatar_use_case.dart';

// Provides Use Cases
final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(ref.watch(profileRepositoryProvider));
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(ref.watch(profileRepositoryProvider));
});

final uploadAvatarUseCaseProvider = Provider<UploadAvatarUseCase>((ref) {
  return UploadAvatarUseCase(ref.watch(profileRepositoryProvider));
});

// Profiles State Object
class ProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final bool isUploading;
  final bool isSettingUpProfile;
  final String? errorMessage;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.isUploading = false,
    this.isSettingUpProfile = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    bool? isUploading,
    bool? isSettingUpProfile,
    String? errorMessage,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      isSettingUpProfile: isSettingUpProfile ?? this.isSettingUpProfile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Global Notifier for Async Logic
class ProfileNotifier extends AsyncNotifier<ProfileState> {
  @override
  Future<ProfileState> build() async {
    final authUser = ref.watch(currentUserProvider);
    final userId = authUser?.supabaseId;
    if (userId == null) {
      return const ProfileState();
    }

    return _loadProfileWithSelfHealing(
      userId: userId,
      email: authUser?.email ?? '',
      displayName: authUser?.displayName,
    );
  }

  Future<ProfileState> _loadProfileWithSelfHealing({
    required String userId,
    required String email,
    String? displayName,
  }) async {
    final getProfile = ref.read(getProfileUseCaseProvider);
    final firstLoad = await getProfile.call(userId);
    return await firstLoad.fold((failure) async {
      final errorText = failure.message.toLowerCase();
      final isMissingProfile = errorText.contains('0 rows') ||
          errorText.contains('no rows') ||
          errorText.contains('not found') ||
          errorText.contains('single json object') ||
          errorText.contains('coerce') ||
          errorText.contains('pgrst116');
      AppLogger.w(
        'profile_self_heal_decision user=$userId missing=$isMissingProfile error=${failure.message}',
      );
      if (!isMissingProfile) {
        return ProfileState(errorMessage: failure.message);
      }

      final ensureResult =
          await ref.read(profileRepositoryProvider).ensureProfileExists(
                userId: userId,
                email: email,
                displayName: displayName,
              );
      return await ensureResult.fold((ensureFailure) async {
        AppLogger.w(
          'profile_self_heal_failed user=$userId error=${ensureFailure.message}',
        );
        return ProfileState(
          errorMessage: ensureFailure.message,
          isSettingUpProfile: false,
        );
      }, (_) async {
        AppLogger.i('profile_self_heal_retry user=$userId');
        final secondLoad = await getProfile.call(userId);
        return await secondLoad.fold(
          (secondFailure) async => ProfileState(errorMessage: secondFailure.message),
          (profileObj) async {
            await _mirrorInstallTrialToLocal(profileObj);
            return ProfileState(profile: profileObj);
          },
        );
      });
    }, (profileObj) async {
      await _mirrorInstallTrialToLocal(profileObj);
      return ProfileState(profile: profileObj);
    });
  }

  Future<void> _mirrorInstallTrialToLocal(UserProfile profile) async {
    try {
      await ref.read(appSettingsRepositoryProvider).setInstallTrialConsumedRemote(
            value: profile.installTrialConsumed,
          );
      ref.invalidate(adGateProvider);
      ref.invalidate(dayPassProvider);
    } catch (e, st) {
      AppLogger.w('install_trial_mirror_failed $e');
      AppLogger.e('install_trial_mirror_trace', e, st);
    }
  }

  Future<void> retryLoadProfile() async {
    final authUser = ref.read(currentUserProvider);
    final userId = authUser?.supabaseId;
    if (userId == null) return;
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _loadProfileWithSelfHealing(
      userId: userId,
      email: authUser?.email ?? '',
      displayName: authUser?.displayName,
    ));
  }

  Future<void> updateProfile(
      {String? displayName, String? bio, bool? activitySharing}) async {
    state = const AsyncValue.loading();

    final userId = ref.read(currentUserProvider)?.supabaseId;
    if (userId == null) return;

    final result = await ref.read(updateProfileUseCaseProvider).call(
          userId: userId,
          displayName: displayName,
          bio: bio,
          activitySharingEnabled: activitySharing,
        );

    await result.match(
      (f) async {
        state = AsyncValue.data(ProfileState(errorMessage: f.message));
      },
      (updatedProfile) async {
        await _mirrorInstallTrialToLocal(updatedProfile);
        state = AsyncValue.data(ProfileState(profile: updatedProfile));
      },
    );
  }

  Future<void> uploadAvatar(File file) async {
    final currentObj = state.value;
    state = AsyncValue.data(currentObj?.copyWith(isUploading: true) ??
        const ProfileState(isUploading: true));

    final userId = ref.read(currentUserProvider)?.supabaseId;
    if (userId == null) return;

    final uploadResult = await ref.read(uploadAvatarUseCaseProvider).call(
          userId: userId,
          avatarFile: file,
        );

    uploadResult.fold((f) {
      state = AsyncValue.data(
          currentObj?.copyWith(isUploading: false, errorMessage: f.message) ??
              ProfileState(isUploading: false, errorMessage: f.message));
    }, (newUrl) {
      if (currentObj?.profile != null) {
        final updatedProfile = currentObj!.profile!.copyWith(avatarUrl: newUrl);
        state = AsyncValue.data(ProfileState(profile: updatedProfile));
      } else {
        state = AsyncValue.data(const ProfileState(isUploading: false));
      }
    });
  }

  Future<void> deleteAccount() async {
    final currentObj = state.value;
    state = AsyncValue.data(currentObj?.copyWith(isLoading: true) ??
        const ProfileState(isLoading: true));

    final syncUid = ref.read(currentUserProvider)?.supabaseId;
    final authRepo = ref.read(authRepositoryProvider);
    final result = await authRepo.deleteAccount();

    await result.fold(
      (f) async {
        state = AsyncValue.data(
            currentObj?.copyWith(isLoading: false, errorMessage: f.message) ??
                ProfileState(isLoading: false, errorMessage: f.message));
      },
      (_) async {
        try {
          await ref.read(appSettingsRepositoryProvider).clearSessionData();
          if (syncUid != null) {
            await SyncMetadataStore().clearForUser(syncUid);
          }
          await Purchases.logOut();
        } catch (e, st) {
          AppLogger.w('post_delete_account_cleanup_failed $e');
          AppLogger.e('post_delete_account_cleanup_trace', e, st);
        }
        state = AsyncValue.data(const ProfileState(isLoading: false));
      },
    );
  }
}

final profileNotifierProvider =
    AsyncNotifierProvider<ProfileNotifier, ProfileState>(() {
  return ProfileNotifier();
});
