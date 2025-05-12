// lib/data/datasources/auth_local_data_source.dart
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile_model.dart';

class AuthLocalDataSource {
  final Isar _isar;

  AuthLocalDataSource({required Isar isar}): _isar = isar;

  // Cache current user ID
  Future<void> cacheUserId(String userId) async {
    // await sharedPreferences.setString('cached_user_id', userId);
  }

  // Get cached user ID
  Future<String?> getCachedUserId() async {
    // return sharedPreferences.getString('cached_user_id');
  }

  // Clear cached user ID
  Future<void> clearCachedUserId() async {
    // await sharedPreferences.remove('cached_user_id');
  }

  // Cache user profile
  Future<void> cacheUserProfile(UserProfileModel userProfile) async {
    await _isar.writeTxn(() async {
      await _isar.userProfileModels.put(userProfile);
    });
  }

  // Get cached user profile
  Future<UserProfileModel?> getCachedUserProfile(String userId) async {
    return _isar.userProfileModels.filter().idEqualTo(userId).findFirst();
  }

  // Stream cached user profile
  Stream<UserProfileModel?> watchUserProfile(String userId) {
    return _isar.userProfileModels
        .filter()
        .idEqualTo(userId)
        .watch(fireImmediately: true)
        .map((profiles) => profiles.isNotEmpty ? profiles.first : null);
  }

  // Clear all cached data
  Future<void> clearCache() async {
    await _isar.writeTxn(() async {
      await _isar.userProfileModels.clear();
    });
    await clearCachedUserId();
  }
}
