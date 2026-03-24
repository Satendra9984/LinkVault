abstract class UserRepository {
  Future<bool> isFirstLaunch();
  Future<void> setFirstLaunchCompleted();
}
