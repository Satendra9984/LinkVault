// lib/data/datasources/auth_local_data_source.dart
import 'package:isar/isar.dart';
import 'package:link_vault/core/errors/exceptions.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile_model.dart';

class AuthLocalDataSource {
  final Isar _isar;

  AuthLocalDataSource({required Isar isar}) : _isar = isar;

  // Stream cached user profile
  Stream<UserProfileModel?> watchUserProfile(String userId) {
    return _isar.userProfileModels
        .filter()
        .idEqualTo(userId)
        .watch(fireImmediately: true)
        .map((profiles) => profiles.isNotEmpty ? profiles.first : null);
  }

  // Cache user profile
  Future<void> cacheUserProfile(UserProfileModel userProfile) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.userProfileModels.put(userProfile);
      });
    } catch (e) {
      throw CacheException(
        message: 'Could Not add user in device.',
        statusCode: 500,
      );
    }
  }

  // Get cached user profile
  Future<UserProfileModel?> getCachedUserProfile(String userId) async {
    try {
      return _isar.userProfileModels.filter().idEqualTo(userId).findFirst();
    } catch (e) {
      throw CacheException(
        message: 'Could Not find user in device.',
        statusCode: 500,
      );
    }
  }

  // Clear all cached data
  Future<void> clearCache() async {
    try {
      await _isar.writeTxn(() async {
        await _isar.userProfileModels.clear();
      });
    } catch (e) {
      throw CacheException(
        message: 'Could not clear user-data in device.',
        statusCode: 500,
      );
    }
  }
}
