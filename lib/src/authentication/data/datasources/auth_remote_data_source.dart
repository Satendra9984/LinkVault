


// lib/data/datasources/auth_remote_data_source.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile_model.dart';

class AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSource({required this.supabaseClient});

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmailPassword(String email, String password) async {
    return await supabaseClient.auth.signUp(
      email: email,
      password: password,
    );
  }

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailPassword(String email, String password) async {
    return await supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await supabaseClient.auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return supabaseClient.auth.currentUser;
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await supabaseClient.auth.resetPasswordForEmail(email);
  }

  // Create user profile
  Future<UserProfileModel> createUserProfile({
    required String userId,
    String? displayName,
    String? profilePictureUrl,
    String? bio,
    Map<String, dynamic>? settings,
  }) async {
    final response = await supabaseClient.from('user_profiles').insert({
      'id': userId,
      'display_name': displayName,
      'profile_picture_url': profilePictureUrl,
      'bio': bio,
      'settings': settings ?? {},
    }).select().single();
    
    return UserProfileModel.fromSupabase(response);
  }

  // Get user profile
  Future<UserProfileModel> getUserProfile(String userId) async {
    final response = await supabaseClient
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .single();
    
    return UserProfileModel.fromSupabase(response);
  }

  // Update user profile
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile) async {
    final response = await supabaseClient
        .from('user_profiles')
        .update(profile.toSupabase())
        .eq('id', profile.id)
        .select()
        .single();
    
    return UserProfileModel.fromSupabase(response);
  }

  // Stream auth state changes
  Stream<AuthState> authStateChanges() {
    return supabaseClient.auth.onAuthStateChange;
  }
}