import 'package:flutter_test/flutter_test.dart';
import 'package:link_vault/features/monetization/domain/repositories/i_daypass_repository.dart';
import 'package:link_vault/features/monetization/domain/usecases/check_ad_access_usecase.dart';

class _FakeDayPassRepo implements IDayPassRepository {
  _FakeDayPassRepo({
    this.cachedPremium = false,
    this.installDate,
    this.dayPassExpiresAt,
    DateTime? lastAdWatchedAt,
    this.adFailed = false,
  }) : _lastAdWatchedAt = lastAdWatchedAt;

  bool cachedPremium;
  DateTime? installDate;
  DateTime? dayPassExpiresAt;
  final DateTime? _lastAdWatchedAt;
  bool adFailed;
  int setInstallDateIfNotSetCalls = 0;

  @override
  Future<void> cachePremiumStatus({required bool isPremium}) async {
    cachedPremium = isPremium;
  }

  @override
  Future<DateTime?> getDayPassExpiresAt() async => dayPassExpiresAt;

  @override
  Future<bool> getCachedPremiumStatus() async => cachedPremium;

  @override
  Future<DateTime?> getInstallDate() async => installDate;

  @override
  Future<Duration> getDayPassRemainingDuration() async => Duration.zero;

  @override
  Future<DateTime?> getLastAdWatchedAt() async => _lastAdWatchedAt;

  @override
  Future<bool> lastAdFailed() async => adFailed;

  @override
  Future<void> markAdFailed() async {}

  @override
  Future<void> markAdWatched() async {}

  @override
  Future<void> setInstallDateIfNotSet() async {
    setInstallDateIfNotSetCalls++;
  }
}

void main() {
  test('returns premium when cached premium', () async {
    final repo = _FakeDayPassRepo(cachedPremium: true);
    final status = await CheckAdAccessUseCase(repo).call();
    expect(status, DayPassStatus.premium);
  });

  test('returns freeTrial when install within 3 days', () async {
    final repo = _FakeDayPassRepo(
      installDate: DateTime.now().subtract(const Duration(days: 1)),
    );
    final status = await CheckAdAccessUseCase(repo).call();
    expect(status, DayPassStatus.freeTrial);
  });

  test('returns active when day pass expires in future', () async {
    final repo = _FakeDayPassRepo(
      installDate: DateTime.now().subtract(const Duration(days: 10)),
      dayPassExpiresAt: DateTime.now().add(const Duration(hours: 5)),
    );
    final status = await CheckAdAccessUseCase(repo).call();
    expect(status, DayPassStatus.active);
  });

  test('returns grace when ad failed and pass expired', () async {
    final repo = _FakeDayPassRepo(
      installDate: DateTime.now().subtract(const Duration(days: 10)),
      dayPassExpiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      adFailed: true,
    );
    final status = await CheckAdAccessUseCase(repo).call();
    expect(status, DayPassStatus.grace);
  });

  test('returns expired when past trial and no pass', () async {
    final repo = _FakeDayPassRepo(
      installDate: DateTime.now().subtract(const Duration(days: 10)),
      dayPassExpiresAt: DateTime.now().subtract(const Duration(hours: 2)),
      adFailed: false,
    );
    final status = await CheckAdAccessUseCase(repo).call();
    expect(status, DayPassStatus.expired);
  });

  test('returns active from legacy fallback when ad watched <24h ago', () async {
    final repo = _FakeDayPassRepo(
      installDate: DateTime.now().subtract(const Duration(days: 10)),
      lastAdWatchedAt: DateTime.now().subtract(const Duration(hours: 23)),
    );
    final status = await CheckAdAccessUseCase(repo).call();
    expect(status, DayPassStatus.active);
  });

  test('returns expired when exactly 3 days since install', () async {
    final repo = _FakeDayPassRepo(
      installDate: DateTime.now().subtract(const Duration(hours: 72)),
    );
    final status = await CheckAdAccessUseCase(repo).call();
    expect(status, DayPassStatus.expired);
  });

  test('stamps install date check every evaluation', () async {
    final repo = _FakeDayPassRepo(
      installDate: DateTime.now().subtract(const Duration(days: 1)),
    );
    await CheckAdAccessUseCase(repo).call();
    expect(repo.setInstallDateIfNotSetCalls, 1);
  });
}
