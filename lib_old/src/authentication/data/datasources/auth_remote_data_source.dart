// lib/data/datasources/auth_remote_data_source.dart
import 'package:link_vault/core/constants/database_constants.dart';
import 'package:link_vault/core/errors/exceptions.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/shared/data/models/user_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

// ignore: public_member_api_docs
class AuthRemoteDataSource {
  AuthRemoteDataSource({required this.supabaseClient});

  final SupabaseClient supabaseClient;

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      Logger.printLog('[SignIn] Attempting sign-in for email: $email');

      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException(
          message: 'Sign-in failed: No user returned',
          statusCode: 401,
        );
      }

      Logger.printLog(
        '[SignIn] Sign-in successful for user: ${response.user!.id}',
      );

      return response;
    } on AuthException catch (e) {
      Logger.printLog('[SignIn][AuthException] ${e.message}');
      switch (e.message.toLowerCase()) {
        case 'invalid login credentials':
          throw AuthException(
            message: 'Invalid email or password',
            statusCode: 401,
          );
        case 'email not confirmed':
          throw AuthException(
            message: 'Please verify your email before signing in',
            statusCode: 403,
          );
        case 'too many requests':
          throw AuthException(
            message: 'Too many login attempts. Please try again later',
            statusCode: 429,
          );
        default:
          throw AuthException(
            message: e.message,
            statusCode: e.statusCode,
          );
      }
    } on PostgrestException catch (e) {
      Logger.printLog('[SignIn][PostgrestException] ${e.message}');
      throw ServerException(
        message: 'Database error during sign-in: ${e.message}',
        statusCode: e.code != null ? int.tryParse(e.code!) ?? 500 : 500,
      );
    } catch (e) {
      Logger.printLog('[SignIn][UnexpectedError] $e');
      throw AuthException(
        message: 'An unexpected error occurred during sign-in',
        statusCode: 500,
      );
    }
  }

  Future<void> resendEmailVerification(String email) async {
    try {
      final response = await supabaseClient.auth.resend(
        type: OtpType.signup,
        email: email,
      );

      // Check if the response indicates success
      if (response.messageId == null || response.messageId!.isEmpty == true) {
        throw ServerException(
          message: 'Failed to send verification email. Please try again.',
          statusCode: 500,
        );
      }
    } on AuthException catch (e) {
      throw _handleSupabaseAuthException(e, 'resend verification email');
    } catch (e) {
      throw ServerException(
        message:
            'An unexpected error occurred while resending verification email: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  Future<void> verifyEmailToken({
    required String authCode,
  }) async {
    try {
      // Input validation
      if (authCode.isEmpty) {
        throw ValidationException(
          message: 'Verification token cannot be empty.',
          statusCode: 400,
        );
      }

      await supabaseClient.auth.exchangeCodeForSession(authCode);
    } on AuthException catch (e) {
      throw _handleSupabaseAuthException(e, 'verify email');
    } on FormatException catch (_) {
      throw ValidationException(
        message: 'Invalid verification token format.',
        statusCode: 400,
      );
    } catch (e) {
      throw ServerException(
        message: 'An unexpected error occurred during email verification: $e',
        statusCode: 500,
      );
    }
  }

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
    Map<String, dynamic>? metaData,
  ) async {
    try {
      Logger.printLog('[SignUp] Attempting sign-up for email: $email');

      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: metaData,
      );

      Logger.printLog('[SignUp] Sign-up response received');
      return response;
    } on AuthException catch (e) {
      Logger.printLog('[SignUp][AuthException] ${e.message}');
      switch (e.message.toLowerCase()) {
        case 'user already registered':
          throw AuthException(
            message: 'An account with this email already exists',
            statusCode: 409,
          );
        case 'password should be at least 6 characters':
          throw AuthException(
            message: 'Password must be at least 6 characters long',
            statusCode: 422,
          );
        case 'signup is disabled':
          throw AuthException(
            message: 'Account registration is currently disabled',
            statusCode: 403,
          );
        default:
          throw AuthException(
            message: e.message,
            statusCode: e.statusCode,
          );
      }
    } on PostgrestException catch (e) {
      Logger.printLog('[SignUp][PostgrestException] ${e.message}');
      throw ServerException(
        message: 'Database error during sign-up: ${e.message}',
        statusCode: e.code != null ? int.tryParse(e.code!) ?? 500 : 500,
      );
    } catch (e) {
      Logger.printLog('[SignUp][UnexpectedError] $e');
      throw AuthException(
        message: 'An unexpected error occurred during sign-up',
        statusCode: 500,
      );
    }
  }

  // Add method to call ensure_user_profile function
  Future<UserProfileModel> ensureUserProfile(String userId) async {
    try {
      final response = await supabaseClient.rpc<Map<String, dynamic>>(
        'ensure_user_profile',
        params: {'user_id': userId},
      );

      return UserProfileModel.fromSupabase(response);
    } catch (e) {
      throw ServerException(
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      Logger.printLog('[SignOut] Attempting sign-out');
      await supabaseClient.auth.signOut();
      Logger.printLog('[SignOut] Sign-out successful');
    } on AuthException catch (e) {
      Logger.printLog('[SignOut][AuthException] ${e.message}');
      throw AuthException(
        message: 'Failed to sign out: ${e.message}',
        statusCode: e.statusCode,
      );
    } catch (e) {
      Logger.printLog('[SignOut][UnexpectedError] $e');
      throw AuthException(
        message: 'An unexpected error occurred during sign-out',
        statusCode: 500,
      );
    }
  }

  /// Get current user
  User? getCurrentUser() {
    try {
      final user = supabaseClient.auth.currentUser;
      Logger.printLog('[GetCurrentUser] Current user: ${user?.id ?? 'None'}');
      return user;
    } catch (e) {
      Logger.printLog('[GetCurrentUser][Error] $e');

      /// Return null for current user errors instead of throwing
      return null;
    }
  }

  /// Send password reset email

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      Logger.printLog('[PasswordReset] Sending reset email to: $email');
      await supabaseClient.auth.resetPasswordForEmail(email);
      Logger.printLog('[PasswordReset] Reset email sent successfully');
    } on AuthException catch (e) {
      Logger.printLog('[PasswordReset][AuthException] ${e.message}');
      switch (e.message.toLowerCase()) {
        case 'user not found':
          throw AuthException(
            message: 'No account found with this email address',
            statusCode: 404,
          );
        case 'email rate limit exceeded':
          throw AuthException(
            message: 'Too many reset attempts. Please wait before trying again',
            statusCode: 429,
          );
        default:
          throw AuthException(
            message: e.message,
            statusCode: e.statusCode,
          );
      }
    } catch (e) {
      Logger.printLog('[PasswordReset][UnexpectedError] $e');
      throw AuthException(
        message: 'Failed to send password reset email',
        statusCode: 500,
      );
    }
  }

  /// Create user profile
  Future<UserProfileModel> createUserProfile({
    required Map<String, dynamic> userData,
  }) async {
    try {
      Logger.printLog(
        '[CreateProfile] Creating profile for user: ${userData['id']}',
      );

      Logger.printLog(
        '[CreateProfile][IsAuthenticated]: ${supabaseClient.auth.currentUser}',
      );

      final response = await supabaseClient
          .from(SupabaseDatabaseConstants.userProfilesTable)
          .insert(userData)
          .select()
          .single();

      Logger.printLog('[CreateProfile] Profile created successfully');
      return UserProfileModel.fromSupabase(response);
    } on PostgrestException catch (e) {
      Logger.printLog('[CreateProfile][PostgrestException] ${e.message}');
      switch (e.code) {
        case '23505':

          /// Unique violation
          throw ServerException(
            message: 'User profile already exists',
            statusCode: 409,
          );
        case '23503':

          /// Foreign key violation
          throw ServerException(
            message: 'Invalid user reference',
            statusCode: 400,
          );
        case '42501':

          /// Insufficient privilege
          throw ServerException(
            message: 'Insufficient permissions to create profile',
            statusCode: 403,
          );
        default:
          throw ServerException(
            message: 'Database error: ${e.message}',
            statusCode: e.code != null ? int.tryParse(e.code!) ?? 500 : 500,
          );
      }
    } catch (e) {
      Logger.printLog('[CreateProfile][UnexpectedError] $e');
      throw ServerException(
        message: 'Failed to create user profile',
        statusCode: 500,
      );
    }
  }

  /// Get user profile
  Future<UserProfileModel> getUserProfile(String userId) async {
    try {
      Logger.printLog('[GetProfile] Fetching profile for user: $userId');

      final response = await supabaseClient
          .from(SupabaseDatabaseConstants.userProfilesTable)

          /// Fixed table name consistency
          .select()
          .eq('id', userId)
          .single();

      Logger.printLog('[GetProfile] Profile fetched successfully');
      return UserProfileModel.fromSupabase(response);
    } on PostgrestException catch (e) {
      Logger.printLog('[GetProfile][PostgrestException] ${e.message}');
      switch (e.code) {
        case 'PGRST116':

          /// No rows returned
          throw ServerException(
            message: 'User profile not found',
            statusCode: 404,
          );
        case '42501':

          /// Insufficient privilege
          throw ServerException(
            message: 'Insufficient permissions to access profile',
            statusCode: 403,
          );
        default:
          throw ServerException(
            message: 'Database error: ${e.message}',
            statusCode: e.code != null ? int.tryParse(e.code!) ?? 500 : 500,
          );
      }
    } catch (e) {
      Logger.printLog('[GetProfile][UnexpectedError] $e');
      throw ServerException(
        message: 'Failed to fetch user profile',
        statusCode: 500,
      );
    }
  }

  /// Update user profile
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile) async {
    try {
      Logger.printLog(
          '[UpdateProfile] Updating profile for user: ${profile.id}');

      final response = await supabaseClient
          .from(SupabaseDatabaseConstants.userProfilesTable)
          .update(profile.toSupabase())
          .eq('id', profile.id)
          .select()
          .single();

      Logger.printLog('[UpdateProfile] Profile updated successfully');
      return UserProfileModel.fromSupabase(response);
    } on PostgrestException catch (e) {
      Logger.printLog('[UpdateProfile][PostgrestException] ${e.message}');
      switch (e.code) {
        case 'PGRST116':

          /// No rows returned
          throw ServerException(
            message: 'User profile not found',
            statusCode: 404,
          );
        case '23505':

          /// Unique violation
          throw ServerException(
            message: 'Profile data conflicts with existing record',
            statusCode: 409,
          );
        case '42501':

          /// Insufficient privilege
          throw ServerException(
            message: 'Insufficient permissions to update profile',
            statusCode: 403,
          );
        default:
          throw ServerException(
            message: 'Database error: ${e.message}',
            statusCode: e.code != null ? int.tryParse(e.code!) ?? 500 : 500,
          );
      }
    } catch (e) {
      Logger.printLog('[UpdateProfile][UnexpectedError] $e');
      throw ServerException(
        message: 'Failed to update user profile',
        statusCode: 500,
      );
    }
  }

  /// Delete failed user with enhanced error handling
  Future<Map<String, dynamic>> deleteFailedUser({
    required String userIdentifier,
    String identifierType = 'email',
    String reason = 'Signup failure cleanup',
  }) async {
    try {
      Logger.printLog(
          '[DeleteFailedUser] Deleting user: $userIdentifier ($identifierType)');

      final response = await supabaseClient.rpc<Map<String, dynamic>>(
        'delete_failed_user',
        params: {
          'user_identifier': userIdentifier,
          'identifier_type': identifierType,
          'deletion_reason': reason,
        },
      ).single();

      Logger.printLog(
        '[DeleteFailedUser] Operation completed: ${response['success']}',
      );
      return response;
    } on PostgrestException catch (e) {
      Logger.printLog('[DeleteFailedUser][PostgrestException] ${e.message}');
      return {
        'success': false,
        'error': 'Database operation failed',
        'error_code': e.code,
        'details': e.message,
      };
    } on FunctionException catch (e) {
      Logger.printLog(
        '[DeleteFailedUser][FunctionException] ${e.reasonPhrase}',
      );
      return {
        'success': false,
        'error': 'Database function error',
        'details': e.reasonPhrase,
      };
    } catch (e) {
      Logger.printLog('[DeleteFailedUser][UnexpectedError] $e');
      return {
        'success': false,
        'error': 'Network or unexpected error',
        'details': e.toString(),
      };
    }
  }

  /// Helper function to delete by email
  Future<Map<String, dynamic>> deleteUserByEmail(String email) async {
    try {
      Logger.printLog('[DeleteUserByEmail] Deleting user with email: $email');

      final response = await supabaseClient.rpc<Map<String, dynamic>>(
        'delete_user_by_email',
        params: {
          'user_email': email,
        },
      ).single();

      Logger.printLog(
        '[DeleteUserByEmail] Operation completed: ${response['success']}',
      );
      return response;
    } on PostgrestException catch (e) {
      Logger.printLog('[DeleteUserByEmail][PostgrestException] ${e.message}');
      return {
        'success': false,
        'error': 'Database operation failed',
        'error_code': e.code,
        'details': e.message,
      };
    } on FunctionException catch (e) {
      Logger.printLog(
        '[DeleteUserByEmail][FunctionException] ${e.reasonPhrase}',
      );
      return {
        'success': false,
        'error': 'Database function error',
        'details': e.reasonPhrase,
      };
    } catch (e) {
      Logger.printLog('[DeleteUserByEmail][UnexpectedError] $e');
      return {
        'success': false,
        'error': 'Network or unexpected error',
        'details': e.toString(),
      };
    }
  }

  /// Helper function to delete by user ID
  Future<Map<String, dynamic>> deleteUserById(String userId) async {
    try {
      Logger.printLog('[DeleteUserById] Deleting user with ID: $userId');

      final response = await supabaseClient.rpc<Map<String, dynamic>>(
        'delete_user_by_id',
        params: {
          'user_id': userId,
        },
      ).single();

      Logger.printLog(
          '[DeleteUserById] Operation completed: ${response['success']}');
      return response;
    } on PostgrestException catch (e) {
      Logger.printLog('[DeleteUserById][PostgrestException] ${e.message}');
      return {
        'success': false,
        'error': 'Database operation failed',
        'error_code': e.code,
        'details': e.message,
      };
    } on FunctionException catch (e) {
      Logger.printLog('[DeleteUserById][FunctionException] ${e.reasonPhrase}');
      return {
        'success': false,
        'error': 'Database function error',
        'details': e.reasonPhrase,
      };
    } catch (e) {
      Logger.printLog('[DeleteUserById][UnexpectedError] $e');
      return {
        'success': false,
        'error': 'Network or unexpected error',
        'details': e.toString(),
      };
    }
  }

  /// Stream auth state changes with error handling
  Stream<AuthState> authStateChanges() {
    try {
      Logger.printLog('[AuthStateChanges] Setting up auth state stream');
      return supabaseClient.auth.onAuthStateChange;
    } catch (e) {
      Logger.printLog('[AuthStateChanges][Error] Failed to setup stream: $e');

      /// Return empty stream in case of error
      return const Stream.empty();
    }
  }

  // Helper method to handle Supabase AuthException specifically
  Exception _handleSupabaseAuthException(AuthException e, String operation) {
    switch (e.statusCode) {
      case 400:
        return ValidationException(
          message: 'Bad request: ${e.message}',
          statusCode: 400,
        );
      case 401:
        return AuthException(
          message: 'Unauthorized: ${e.message}',
          statusCode: 401,
        );
      case 403:
        return AuthException(
          message: 'Forbidden: ${e.message}',
          statusCode: 403,
        );
      case 404:
        return AuthException(
          message: 'Not found: ${e.message}',
          statusCode: 404,
        );
      case 422:
        return ValidationException(
          message: 'Validation error: ${e.message}',
          statusCode: 422,
        );
      case 429:
        return AuthException(
          message: 'Too many requests: ${e.message}',
          statusCode: 429,
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(
          message: 'Server error: ${e.message}',
          statusCode: e.statusCode,
        );
      default:
        return ServerException(
          message: 'Failed to $operation: ${e.message}',
          statusCode: e.statusCode,
        );
    }
  }
}
