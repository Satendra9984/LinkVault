import 'package:flutter_test/flutter_test.dart';
import 'package:link_vault/features/debug/domain/services/mock_dataset_profile.dart';

void main() {
  test('profile dimensions match spec', () {
    expect(MockDatasetProfile.small.nonRootCollectionCount, 8);
    expect(MockDatasetProfile.small.urlCount, 40);

    expect(MockDatasetProfile.medium.nonRootCollectionCount, 24);
    expect(MockDatasetProfile.medium.urlCount, 240);

    expect(MockDatasetProfile.large.nonRootCollectionCount, 60);
    expect(MockDatasetProfile.large.urlCount, 1200);

    expect(MockDatasetProfile.quotaBoundaryGuest.nonRootCollectionCount, 50);
    expect(MockDatasetProfile.quotaBoundaryGuest.urlCount, 1200);

    expect(MockDatasetProfile.cleanupOnly.nonRootCollectionCount, 0);
    expect(MockDatasetProfile.cleanupOnly.urlCount, 0);
  });
}
