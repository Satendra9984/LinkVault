import 'package:flutter_test/flutter_test.dart';
import 'package:link_vault/core/infrastructure/storage/local_vault_storage_summary.dart';

void main() {
  test('formatVaultStorageBytes', () {
    expect(formatVaultStorageBytes(0), '0 B');
    expect(formatVaultStorageBytes(500), '500 B');
    expect(formatVaultStorageBytes(1024), contains('KB'));
    expect(formatVaultStorageBytes(5 * 1024 * 1024), contains('MB'));
  });

  test('vaultStorageTier labels and ordered progress', () {
    final light = vaultStorageTier(1 * 1024 * 1024);
    final mod = vaultStorageTier(10 * 1024 * 1024);
    final large = vaultStorageTier(50 * 1024 * 1024);
    final very = vaultStorageTier(200 * 1024 * 1024);
    expect(light.$2, 'Light');
    expect(mod.$2, 'Moderate');
    expect(large.$2, 'Large');
    expect(very.$2, 'Very large');
    expect(light.$1, lessThan(mod.$1));
    expect(mod.$1, lessThan(large.$1));
    expect(large.$1, lessThanOrEqualTo(very.$1));
  });
}
