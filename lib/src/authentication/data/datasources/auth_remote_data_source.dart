// lib/data/datasources/auth_remote_data_source.dart
import 'package:link_vault/core/errors/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../models/user_profile_model.dart';

class AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSource({required this.supabaseClient});

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      return supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw AuthException(
        message: 'Something went wrong while sign-in.',
        statusCode: 500,
      );
    }
  }

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      return supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
    } catch (e) {
      throw AuthException(
        message: 'Something went wrong while sign-up.',
        statusCode: 500,
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw AuthException(
        message: 'Could not sign-out.',
        statusCode: 500,
      );
    }
  }

  // Get current user
  User? getCurrentUser() {
    return supabaseClient.auth.currentUser;
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await supabaseClient.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw AuthException(
        message: 'Something went wrong while sending password reset email.',
        statusCode: 500,
      );
    }
  }

  // Create user profile
  Future<UserProfileModel> createUserProfile({
    required Map<String, dynamic> userData,
  }) async {
    try {
      final response = await supabaseClient
          .from('user_profiles')
          .insert(userData)
          .select()
          .single();

      return UserProfileModel.fromSupabase(response);
    } catch (e) {
      throw ServerException(
        message: 'Failed to create user on server',
        statusCode: 500,
      );
    }
  }

  // Get user profile
  Future<UserProfileModel> getUserProfile(String userId) async {
    try {
      final response =
          await supabaseClient.from('users').select().eq('id', userId).single();

      return UserProfileModel.fromSupabase(response);
    } catch (e) {
      throw ServerException(
        message: 'Could Not Get User from Server.',
        statusCode: 500,
      );
    }
  }

  // Update user profile
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile) async {
    try {
      final response = await supabaseClient
          .from('user_profiles')
          .update(profile.toSupabase())
          .eq('id', profile.id)
          .select()
          .single();

      return UserProfileModel.fromSupabase(response);
    } catch (e) {
      throw ServerException(
        message: 'Could Not Get User from Server.',
        statusCode: 500,
      );
    }
  }

  // Stream auth state changes
  Stream<AuthState> authStateChanges() {
    return supabaseClient.auth.onAuthStateChange;
  }
}
