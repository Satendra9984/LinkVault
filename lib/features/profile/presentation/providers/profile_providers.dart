import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:link_vault/features/auth/presentation/providers/auth_providers.dart';
import 'package:link_vault/features/profile/domain/entities/user_profile.dart';
import 'package:link_vault/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:link_vault/features/profile/data/repositories/supabase_profile_repository.dart';
import 'package:link_vault/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:link_vault/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:link_vault/features/profile/domain/usecases/upload_avatar_usecase.dart';

// --- Repositories ---
final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  return SupabaseProfileRepository(sb.Supabase.instance.client);
});

// --- Use Cases ---
final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(ref.watch(profileRepositoryProvider));
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(ref.watch(profileRepositoryProvider));
});

final uploadAvatarUseCaseProvider = Provider<UploadAvatarUseCase>((ref) {
  return UploadAvatarUseCase(ref.watch(profileRepositoryProvider));
});

// --- State Management ---

class ProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final bool isUploading;
  final String? errorMessage;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.isUploading = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    bool? isUploading,
    String? errorMessage,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      errorMessage: errorMessage, // null overwrites to clear errors
    );
  }
}

class ProfileNotifier extends AsyncNotifier<ProfileState> {
  @override
  Future<ProfileState> build() async {
    final authUser = ref.watch(currentUserProvider);
    final userId = authUser?.supabaseId;

    if (userId == null) {
      // Guest mode - no profile to load
      return const ProfileState();
    }

    final getProfile = ref.read(getProfileUseCaseProvider);
    final result = await getProfile(userId);

    return result.fold(
      (failure) => ProfileState(errorMessage: failure.message),
      (profile) => ProfileState(profile: profile),
    );
  }

  Future<void> updateProfile(
      {String? displayName, String? bio, bool? activitySharingEnabled}) async {
    final userId = state.value?.profile?.userId;
    if (userId == null) return;

    state =
        AsyncData(state.value!.copyWith(isLoading: true, errorMessage: null));

    final updateProfileCase = ref.read(updateProfileUseCaseProvider);
    final result = await updateProfileCase(
      UpdateProfileParams(
        userId: userId,
        displayName: displayName,
        bio: bio,
        activitySharingEnabled: activitySharingEnabled,
      ),
    );

    result.fold(
      (failure) {
        state = AsyncData(state.value!.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ));
      },
      (updatedProfile) {
        state = AsyncData(state.value!.copyWith(
          isLoading: false,
          profile: updatedProfile,
        ));
      },
    );
  }

  Future<void> uploadAvatar(File file) async {
    final userId = state.value?.profile?.userId;
    if (userId == null) return;

    state =
        AsyncData(state.value!.copyWith(isUploading: true, errorMessage: null));

    final uploadAvatarCase = ref.read(uploadAvatarUseCaseProvider);
    final result = await uploadAvatarCase(
      UploadAvatarParams(userId: userId, avatarFile: file),
    );

    result.fold(
      (failure) {
        state = AsyncData(state.value!.copyWith(
          isUploading: false,
          errorMessage: failure.message,
        ));
      },
      (newAvatarUrl) {
        // Also update the local profile entity so UI refreshes immediately
        final currentProfile = state.value?.profile;
        if (currentProfile != null) {
          state = AsyncData(state.value!.copyWith(
            isUploading: false,
            profile: currentProfile.copyWith(avatarUrl: newAvatarUrl),
          ));
        } else {
          state = AsyncData(state.value!.copyWith(isUploading: false));
        }
      },
    );
  }
}

final profileNotifierProvider =
    AsyncNotifierProvider<ProfileNotifier, ProfileState>(
  () => ProfileNotifier(),
);
