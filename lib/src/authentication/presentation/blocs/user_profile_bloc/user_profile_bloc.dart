import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:link_vault/src/authentication/domain/entities/user_profile.dart';
import 'package:link_vault/src/authentication/domain/repository/user_repository.dart';

part 'user_profile_event.dart';
part 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final UserRepository userRepository;
  late StreamSubscription<UserProfile?> _profileSubscription;

  UserProfileBloc({required this.userRepository}) : super(UserProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<UpdateUserDisplayName>(_onUpdateUserDisplayName);
    on<UpdateUserBio>(_onUpdateUserBio);
    on<UpdateUserProfilePicture>(_onUpdateUserProfilePicture);
    on<UpdateUserSettings>(_onUpdateUserSettings);

    // Subscribe to user profile changes
    _profileSubscription = userRepository.userProfileStream().listen((profile) {
      if (profile != null) {
        add(UpdateUserProfile(profile));
      }
    });
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());
    
    final result = await userRepository.getUserProfile();
    result.fold(
      (failure) => emit(UserProfileError(failure.message)),
      (profile) => emit(UserProfileLoaded(profile)),
    );
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is UserProfileLoaded) {
      emit(UserProfileLoaded(event.userProfile));
    }
  }

  Future<void> _onUpdateUserDisplayName(
    UpdateUserDisplayName event,
    Emitter<UserProfileState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is UserProfileLoaded) {
      emit(UserProfileUpdating());
      
      final updatedProfile = currentState.userProfile.copyWith(
        displayName: event.displayName,
      );
      
      final result = await userRepository.updateUserProfile(updatedProfile);
      result.fold(
        (failure) => emit(UserProfileUpdateError(failure.message)),
        (profile) => emit(UserProfileUpdateSuccess(profile)),
      );
    }
  }

  Future<void> _onUpdateUserBio(
    UpdateUserBio event,
    Emitter<UserProfileState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is UserProfileLoaded) {
      emit(UserProfileUpdating());
      
      final updatedProfile = currentState.userProfile.copyWith(
        bio: event.bio,
      );
      
      final result = await userRepository.updateUserProfile(updatedProfile);
      result.fold(
        (failure) => emit(UserProfileUpdateError(failure.message)),
        (profile) => emit(UserProfileUpdateSuccess(profile)),
      );
    }
  }

  Future<void> _onUpdateUserProfilePicture(
    UpdateUserProfilePicture event,
    Emitter<UserProfileState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is UserProfileLoaded) {
      emit(UserProfileUpdating());
      
      final updatedProfile = currentState.userProfile.copyWith(
        profilePictureUrl: event.profilePictureUrl,
      );
      
      final result = await userRepository.updateUserProfile(updatedProfile);
      result.fold(
        (failure) => emit(UserProfileUpdateError(failure.message)),
        (profile) => emit(UserProfileUpdateSuccess(profile)),
      );
    }
  }

  Future<void> _onUpdateUserSettings(
    UpdateUserSettings event,
    Emitter<UserProfileState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is UserProfileLoaded) {
      emit(UserProfileUpdating());
      
      // Merge existing settings with new settings
      final mergedSettings = {
        ...currentState.userProfile.settings,
        ...event.settings,
      };
      
      final updatedProfile = currentState.userProfile.copyWith(
        settings: mergedSettings,
      );
      
      final result = await userRepository.updateUserProfile(updatedProfile);
      result.fold(
        (failure) => emit(UserProfileUpdateError(failure.message)),
        (profile) => emit(UserProfileUpdateSuccess(profile)),
      );
    }
  }

  @override
  Future<void> close() {
    _profileSubscription.cancel();
    return super.close();
  }
}
