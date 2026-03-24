import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/user_repository.dart';

class UserPreferencesRepository implements UserRepository {
  static const String _keyFirstLaunch = 'is_first_launch';

  /// Returns true if this is the first time the app is launched.
  @override
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to true if key doesn't exist
    return prefs.getBool(_keyFirstLaunch) ?? true;
  }

  /// Marks the onboarding as completed.
  @override
  Future<void> setFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstLaunch, false);
  }
}
