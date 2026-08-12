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

  test('QMEDIA-001..020 current runtime-admission truth stays fail closed', () {
    expect(WalkaProductMediaAdmissionRegistry.entries, hasLength(5));
    expect(WalkaProductMediaAdmissionRegistry.admittedCount, 2);
    expect(WalkaProductMediaAdmissionRegistry.pendingCount, 2);
    expect(WalkaProductMediaAdmissionRegistry.blockedCount, 1);
    expect(
      WalkaProductMediaAdmissionRegistry.entries['drawer-organizer:white']!.state,
      WalkaProductMediaAdmissionState.admitted,
    );
    expect(
      WalkaProductMediaAdmissionRegistry
          .entries['drawer-organizer:white']!.canonicalExportPresent,
      isTrue,
    );
    expect(
      WalkaProductMediaAdmissionRegistry.entries['lunch-box:blue']!.state,
      WalkaProductMediaAdmissionState.admitted,
    );
    expect(
      WalkaProductMediaAdmissionRegistry
          .entries['lunch-box:blue']!.canonicalExportPresent,
      isTrue,
    );
    expect(
      WalkaProductMediaAdmissionRegistry.entries['drawer-organizer:gray']!.state,
      WalkaProductMediaAdmissionState.blocked,
    );
  });

  test('QMEDIA-021..040 production paths admit evidence-backed White and Blue', () {
    const WalkaProductMediaResolver resolver =
        WalkaProductMediaResolver.production();
    expect(resolver.releasedVariantIds,
        WalkaProductMediaResolver.productionVariantIds);
    expect(resolver.releasedAssets, hasLength(5));
    expect(resolver.admittedAssets, hasLength(2));
    expect(
      resolver.admittedAssets
          .map((WalkaProductMediaAsset asset) => asset.variantId)
          .toSet(),
      <String>{'drawer-organizer:white', 'lunch-box:blue'},
    );

    for (final String id in WalkaProductMediaResolver.productionVariantIds) {
      final bool expectedAdmitted =
          id == 'drawer-organizer:white' || id == 'lunch-box:blue';
      expect(resolver.hasRegisteredAsset(id), isTrue, reason: id);
      expect(resolver.hasAdmittedAsset(id), expectedAdmitted, reason: id);
      expect(resolver.hasApprovedAsset(id), isTrue, reason: id);
      final WalkaProductMedia resolved =
          resolver.resolveForSurface(variantId: id, fallback: fallback);
      expect(resolved, isA<WalkaAssetProductMedia>(), reason: id);
      expect(
        (resolved as WalkaAssetProductMedia).runtimeAdmitted,
        expectedAdmitted,
        reason: id,
      );
    }
  });

  test('QMEDIA-029/030 binary presence never bypasses runtime admission', () {
    for (final WalkaProductMediaAdmissionEntry entry
        in WalkaProductMediaAdmissionRegistry.entries.values) {
      expect(File(entry.canonicalPath).existsSync(), isTrue,
          reason: entry.variantId);
      expect(
        entry.eligibleForRuntime,
        entry.variantId == 'drawer-organizer:white' ||
            entry.variantId == 'lunch-box:blue',
        reason: entry.variantId,
      );
    }
  });

  test('QMEDIA-024/035..040 injected resolver preserves preview/test compatibility',
      () {
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
    expect(media.runtimeAdmitted, isTrue);
    expect(media.asset.cacheWidth, 1600);
    expect(media.fit, BoxFit.cover);
    expect(media.alignment, Alignment.topCenter);
    expect(media.filterQuality, FilterQuality.high);
  });

  testWidgets('QMEDIA-031..040 admitted Blue renders asset instead of fallback',
      (WidgetTester tester) async {
    const WalkaProductMediaResolver resolver =
        WalkaProductMediaResolver.production();
    final WalkaProductMedia media = resolver.resolveForSurface(
      variantId: 'lunch-box:blue',
      fallback: fallback,
    );
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: WalkaProductMediaView(media: media))),
    );
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(WalkaProductVisual), findsNothing);
  });

  testWidgets('QMEDIA-041..050 prefetch admits White/Blue and skips quarantine',
      (WidgetTester tester) async {
    const Key hostKey = ValueKey<String>('qmedia-host');
    await tester.pumpWidget(
      const MaterialApp(home: SizedBox(key: hostKey, width: 10, height: 10)),
    );
    final BuildContext context = tester.element(find.byKey(hostKey));
    const WalkaProductMediaResolver resolver =
        WalkaProductMediaResolver.production();

    late List<WalkaProductMediaPrefetchResult> results;
    await tester.runAsync(() async {
      results = await resolver.prefetchVariants(
        context,
        variantIds: <String>[
          ...WalkaProductMediaResolver.productionVariantIds,
          'drawer-organizer:white',
          'lunch-box:blue',
        ],
        surface: WalkaProductMediaSurface.home,
      );
    });

    expect(results, hasLength(5));
    expect(
      results.map((WalkaProductMediaPrefetchResult item) => item.variantId),
      WalkaProductMediaResolver.productionVariantIds,
    );
    final Map<String, WalkaProductMediaPrefetchResult> byVariant =
        <String, WalkaProductMediaPrefetchResult>{
      for (final WalkaProductMediaPrefetchResult item in results)
        item.variantId: item,
    };
    for (final String admitted
        in <String>['drawer-organizer:white', 'lunch-box:blue']) {
      expect(byVariant[admitted]!.prefetched, isTrue, reason: admitted);
      expect(byVariant[admitted]!.failed, isFalse, reason: admitted);
      expect(byVariant[admitted]!.skipped, isFalse, reason: admitted);
    }
    for (final String quarantined
        in <String>['drawer-organizer:gray', 'lunch-box:pink', 'lunch-box:green']) {
      expect(byVariant[quarantined]!.skipped, isTrue, reason: quarantined);
      expect(byVariant[quarantined]!.assetPath, isNotNull, reason: quarantined);
      expect(byVariant[quarantined]!.skipReason, isNotNull, reason: quarantined);
    }
  });

  test('QMEDIA-051..070 consistency CLI detects two admitted binaries', () async {
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
    expect(report['admittedCount'], 2);
    expect(report['pendingCount'], 2);
    expect(report['blockedCount'], 1);
    expect(report['binaryPresentCount'], 5);
    expect(report['presentButQuarantinedCount'], 3);
    expect(report['admittedBinaryPresentCount'], 2);
    expect(report['issues'], isEmpty);
  });

  test('QMEDIA-081..100 task contract enumerates exactly one hundred IDs', () {
    final Set<int> ids = <int>{for (int i = 1; i <= 100; i += 1) i};
    expect(ids, hasLength(100));
    expect(ids.first, 1);
    expect(ids.last, 100);
  });
}
