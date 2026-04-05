import '../../../../monetization/domain/usecases/check_ad_access_usecase.dart';

/// Where global link search loads items from (tier / DayPass aware).
enum GlobalSearchItemsDataMode {
  /// Normal path: [itemsRepositoryProvider] (local or cloud per ADR-0002).
  activeRepository,

  /// DayPass expired: local ObjectBox only so results stay useful without full app access.
  localRepositoryOnly,
}

/// Pure tier resolution for tests and [globalSearchItemsDataModeProvider].
GlobalSearchItemsDataMode resolveGlobalSearchItemsDataMode({
  required bool isPremium,
  required DayPassStatus dayPassStatus,
}) {
  if (isPremium) {
    return GlobalSearchItemsDataMode.activeRepository;
  }
  if (dayPassStatus == DayPassStatus.expired) {
    return GlobalSearchItemsDataMode.localRepositoryOnly;
  }
  return GlobalSearchItemsDataMode.activeRepository;
}
