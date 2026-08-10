import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/media/walka_product_media_resolver.dart';

void main() {
  test('surface decode budgets are explicit and current default stays within them', () {
    expect(WalkaProductMediaDecodeBudget.home, 1200);
    expect(WalkaProductMediaDecodeBudget.discovery, 1200);
    expect(WalkaProductMediaDecodeBudget.pdp, 1600);
    expect(WalkaProductMediaDecodeBudget.favorites, 1200);
    expect(WalkaProductMediaResolver.defaultCacheWidth, 1200);

    expect(
      WalkaProductMediaResolver.defaultCacheWidth,
      lessThanOrEqualTo(WalkaProductMediaDecodeBudget.home),
    );
    expect(
      WalkaProductMediaResolver.defaultCacheWidth,
      lessThanOrEqualTo(WalkaProductMediaDecodeBudget.discovery),
    );
    expect(
      WalkaProductMediaResolver.defaultCacheWidth,
      lessThanOrEqualTo(WalkaProductMediaDecodeBudget.pdp),
    );
    expect(
      WalkaProductMediaResolver.defaultCacheWidth,
      lessThanOrEqualTo(WalkaProductMediaDecodeBudget.favorites),
    );
  });

  test('cache identity is stable and variant/path/decode-width based', () {
    const WalkaProductMediaAsset asset = WalkaProductMediaAsset(
      variantId: 'drawer-organizer:white',
      assetPath: 'assets/products/drawer/white.png',
      cacheWidth: 1200,
    );
    expect(
      asset.cacheIdentity,
      'drawer-organizer:white::assets/products/drawer/white.png@1200',
    );
    expect(
      WalkaProductMediaResolver.productionAssets.values
          .map((WalkaProductMediaAsset value) => value.cacheIdentity)
          .toSet()
          .length,
      5,
    );
  });

  test('performance audit passes current empty canonical folders and reports verified APK', () async {
    final ProcessResult result = await Process.run(
      'bash',
      <String>['tool/audit_product_media_performance.sh'],
    );
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    expect(result.stdout, contains('Canonical PNG count: 0'));
    expect(result.stdout, contains('Duplicate PNG checksums: 0'));
    expect(result.stdout, contains('Verified APK bytes:'));
  });

  test('runtime audit rejects source/master extensions and defines hard budgets', () {
    final String source = File('tool/audit_product_media_performance.sh').readAsStringSync();
    for (final String extension in <String>['*.jpg', '*.jpeg', '*.psd', '*.tif', '*.tiff', '*.raw', '*.heic']) {
      expect(source, contains(extension));
    }
    expect(source, contains('6 * 1024 * 1024'));
    expect(source, contains('60 * 1024 * 1024'));
    expect(source, contains('95 * 1024 * 1024'));
    expect(source, contains('sha256sum'));
    expect(source, contains('uniq -d'));
  });
}
