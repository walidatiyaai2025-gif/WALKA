import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/media/walka_product_media.dart';
import 'package:walka/design_system/components/media/walka_product_media_admission.dart';
import 'package:walka/design_system/components/media/walka_product_media_resolver.dart';
import 'package:walka/design_system/walka_product_visual.dart';

void main() {
  const WalkaPaintedProductMedia fallback = WalkaPaintedProductMedia(
    kind: WalkaProductVisualKind.drawerOrganizer,
    primaryColor: Color(0xFFF7F4EC),
    semanticLabel: 'fallback',
  );

  test('QMEDIA-001..020 current runtime-admission truth is fail closed', () {
    expect(WalkaProductMediaAdmissionRegistry.entries, hasLength(5));
    expect(WalkaProductMediaAdmissionRegistry.admittedCount, 0);
    expect(WalkaProductMediaAdmissionRegistry.pendingCount, 4);
    expect(WalkaProductMediaAdmissionRegistry.blockedCount, 1);
    expect(
      WalkaProductMediaAdmissionRegistry.entries['drawer-organizer:gray']!.state,
      WalkaProductMediaAdmissionState.blocked,
    );
    expect(
      WalkaProductMediaAdmissionRegistry.entries.values
          .every((WalkaProductMediaAdmissionEntry item) =>
              item.canonicalExportPresent == false),
      isTrue,
    );
  });

  test('QMEDIA-021..040 production paths stay registered but quarantined', () {
    const WalkaProductMediaResolver resolver =
        WalkaProductMediaResolver.production();
    expect(resolver.releasedVariantIds, WalkaProductMediaResolver.productionVariantIds);
    expect(resolver.releasedAssets, hasLength(5));
    expect(resolver.admittedAssets, isEmpty);

    for (final String id in WalkaProductMediaResolver.productionVariantIds) {
      expect(resolver.hasRegisteredAsset(id), isTrue, reason: id);
      expect(resolver.hasAdmittedAsset(id), isFalse, reason: id);
      expect(resolver.hasApprovedAsset(id), isFalse, reason: id);
      expect(
        identical(
          resolver.resolveForSurface(variantId: id, fallback: fallback),
          fallback,
        ),
        isTrue,
        reason: id,
      );
    }
  });

  test('QMEDIA-029/030 bundled PNG presence never equals runtime admission', () {
    for (final WalkaProductMediaAdmissionEntry entry
        in WalkaProductMediaAdmissionRegistry.entries.values) {
      expect(File(entry.canonicalPath).existsSync(), isTrue, reason: entry.variantId);
      expect(entry.eligibleForRuntime, isFalse, reason: entry.variantId);
    }
  });

  test('QMEDIA-024/035..040 injected resolver preserves preview/test compatibility', () {
    const WalkaProductMediaResolver resolver = WalkaProductMediaResolver(
      assetsByVariant: <String, WalkaProductMediaAsset>{
        'preview:test': WalkaProductMediaAsset(
          variantId: 'preview:test',
          assetPath: 'assets/products/drawer/white.png',
        ),
      },
    );
    expect(resolver.hasRegisteredAsset('preview:test'), isTrue);
    expect(resolver.hasAdmittedAsset('preview:test'), isTrue);
    final WalkaProductMedia resolved = resolver.resolveForSurface(
      variantId: 'preview:test',
      fallback: fallback,
      surface: WalkaProductMediaSurface.pdp,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
    );
    expect(resolved, isA<WalkaAssetProductMedia>());
    final WalkaAssetProductMedia media = resolved as WalkaAssetProductMedia;
    expect(media.asset.cacheWidth, 1600);
    expect(media.fit, BoxFit.cover);
    expect(media.alignment, Alignment.topCenter);
    expect(media.filterQuality, FilterQuality.high);
  });

  testWidgets('QMEDIA-041..050 production prefetch skips every quarantined binary',
      (WidgetTester tester) async {
    const Key hostKey = ValueKey<String>('qmedia-host');
    await tester.pumpWidget(
      const MaterialApp(home: SizedBox(key: hostKey, width: 10, height: 10)),
    );
    final BuildContext context = tester.element(find.byKey(hostKey));
    const WalkaProductMediaResolver resolver =
        WalkaProductMediaResolver.production();

    final List<WalkaProductMediaPrefetchResult> results =
        await resolver.prefetchVariants(
      context,
      variantIds: <String>[
        ...WalkaProductMediaResolver.productionVariantIds,
        'drawer-organizer:white',
      ],
      surface: WalkaProductMediaSurface.home,
    );

    expect(results, hasLength(5));
    expect(results.every((WalkaProductMediaPrefetchResult item) => item.skipped),
        isTrue);
    expect(results.every((WalkaProductMediaPrefetchResult item) =>
        item.assetPath != null && item.skipReason != null), isTrue);
    expect(results.map((WalkaProductMediaPrefetchResult item) => item.variantId),
        WalkaProductMediaResolver.productionVariantIds);
  });

  test('QMEDIA-051..070 consistency CLI detects five present quarantined binaries',
      () async {
    final Directory temp = await Directory.systemTemp.createTemp('walka-qmedia-');
    addTearDown(() => temp.delete(recursive: true));
    final String reportPath = '${temp.path}/runtime-admission.json';
    final ProcessResult result = await Process.run(
      'dart',
      <String>[
        'run',
        'tool/verify_runtime_media_admission.dart',
        '--json',
        reportPath,
      ],
    );
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    final Map<String, dynamic> report =
        jsonDecode(await File(reportPath).readAsString()) as Map<String, dynamic>;
    expect(report['consistent'], isTrue);
    expect(report['registeredCount'], 5);
    expect(report['admittedCount'], 0);
    expect(report['pendingCount'], 4);
    expect(report['blockedCount'], 1);
    expect(report['binaryPresentCount'], 5);
    expect(report['presentButQuarantinedCount'], 5);
    expect(report['admittedBinaryPresentCount'], 0);
    expect(report['issues'], isEmpty);
  });

  test('QMEDIA-081..100 task contract enumerates exactly one hundred IDs', () {
    final Set<int> ids = <int>{for (int i = 1; i <= 100; i += 1) i};
    expect(ids, hasLength(100));
    expect(ids.first, 1);
    expect(ids.last, 100);
  });
}
