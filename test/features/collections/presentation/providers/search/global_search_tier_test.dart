import 'package:flutter_test/flutter_test.dart';
import 'package:link_vault/features/collections/presentation/providers/search/global_search_tier.dart';
import 'package:link_vault/features/monetization/domain/usecases/check_ad_access_usecase.dart';

void main() {
  group('resolveGlobalSearchItemsDataMode', () {
    test('premium always uses active repository', () {
      expect(
        resolveGlobalSearchItemsDataMode(
          isPremium: true,
          dayPassStatus: DayPassStatus.expired,
        ),
        GlobalSearchItemsDataMode.activeRepository,
      );
    });

    test('non-premium expired uses local repository only', () {
      expect(
        resolveGlobalSearchItemsDataMode(
          isPremium: false,
          dayPassStatus: DayPassStatus.expired,
        ),
        GlobalSearchItemsDataMode.localRepositoryOnly,
      );
    });

    test('non-premium active trial uses active repository', () {
      for (final s in [
        DayPassStatus.freeTrial,
        DayPassStatus.active,
        DayPassStatus.grace,
      ]) {
        expect(
          resolveGlobalSearchItemsDataMode(
            isPremium: false,
            dayPassStatus: s,
          ),
          GlobalSearchItemsDataMode.activeRepository,
        );
      }
    });
  });
}
