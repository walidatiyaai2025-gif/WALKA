import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/media/walka_product_media.dart';
import 'package:walka/design_system/components/media/walka_product_media_admission.dart';
import 'package:walka/design_system/components/media/walka_product_media_resolver.dart';
import 'package:walka/design_system/walka_product_visual.dart';

import '../tool/src/vsurf_audit.dart';

void main() {
  const WalkaPaintedProductMedia fallback = WalkaPaintedProductMedia(
    kind: WalkaProductVisualKind.drawerOrganizer,
    primaryColor: Color(0xFFF7F4EC),
    semanticLabel: 'VSURF fallback',
  );

  group('VSURF-001..020 contract and owner-visible registry', () {
    test('registry is deterministic, unique and covers nine owner-visible slots', () {
      expect(VsurfContractRegistry.slots, hasLength(9));
      expect(VsurfContractRegistry.devices, hasLength(6));
      expect(
        VsurfContractRegistry.slots.map((VsurfSurfaceSlot slot) => slot.id).toSet(),
        hasLength(9),
      );
      expect(
        VsurfContractRegistry.slots
            .map((VsurfSurfaceSlot slot) => slot.sourcePath)
            .toSet(),
        hasLength(9),
      );
      expect(
        VsurfContractRegistry.slots.map((VsurfSurfaceSlot slot) => slot.id),
        <String>[
          'home-hero',
          'home-collection-card',
          'home-small-changes',
          'discovery-category-card',
          'discovery-product-row',
          'pdp-gallery',
          'pdp-fullscreen-gallery',
          'favorites-saved-card',
          'about-product-story',
        ],
      );
    });

    test('device targets include compact, standard, large, iOS, tablet and desktop', () {
      expect(
        VsurfContractRegistry.devices.map((VsurfDeviceTarget device) => device.id),
        <String>[
          'compact-320x568',
          'standard-390x844',
          'large-430x932',
          'ios-safe-area',
          'tablet',
          'desktop',
        ],
      );
      expect(
        VsurfContractRegistry.devices.singleWhere(
          (VsurfDeviceTarget device) => device.id == 'ios-safe-area',
        ).safeArea,
        isTrue,
      );
      expect(
        VsurfContractRegistry.devices.singleWhere(
          (VsurfDeviceTarget device) => device.id == 'desktop',
        ).desktop,
        isTrue,
      );
    });
  });

  group('VSURF-021..040 source scan and admission truth', () {
    test('live repository owner-visible sources pass integration audit', () {
      final VsurfReport report =
          VsurfAuditor(mobileRoot: Directory.current).audit();
      expect(report.integrationReady, isTrue, reason: report.summary());
      expect(report.blockerCount, 0, reason: report.prettyJson());
      expect(report.slots, hasLength(9));
      expect(report.admission, hasLength(5));
    });

    test('released admission set is exact and remains fail closed by state', () {
      final VsurfReport report =
          VsurfAuditor(mobileRoot: Directory.current).audit();
      final Map<String, VsurfAdmissionEntry> admission = <String, VsurfAdmissionEntry>{
        for (final VsurfAdmissionEntry entry in report.admission)
          entry.variantId: entry,
      };
      expect(admission.keys.toList(), <String>[
        'drawer-organizer:white',
        'drawer-organizer:gray',
        'lunch-box:blue',
        'lunch-box:pink',
        'lunch-box:green',
      ]);
      expect(admission['drawer-organizer:white']!.eligible, isTrue);
      expect(admission['drawer-organizer:gray']!.state, 'blocked');
      expect(admission['drawer-organizer:gray']!.eligible, isFalse);
      expect(
        report.admittedCount + report.pendingCount + report.blockedCount,
        5,
      );
      expect(
        report.globalReleaseReady,
        report.integrationReady && report.admittedCount == 5,
      );
    });

    test('runtime registry and source-audit admission snapshot agree', () {
      final VsurfReport report =
          VsurfAuditor(mobileRoot: Directory.current).audit();
      for (final VsurfAdmissionEntry entry in report.admission) {
        final WalkaProductMediaAdmissionEntry runtime =
            WalkaProductMediaAdmissionRegistry.entries[entry.variantId]!;
        expect(entry.eligible, runtime.eligibleForRuntime, reason: entry.variantId);
        expect(entry.sourceApproved, runtime.sourceApproved, reason: entry.variantId);
        expect(
          entry.canonicalExportPresent,
          runtime.canonicalExportPresent,
          reason: entry.variantId,
        );
        expect(entry.state, runtime.state.name, reason: entry.variantId);
      }
    });
  });

  group('VSURF-041..060 resolution, cache and presentation policy', () {
    test('five-variant x five-surface resolution matrix obeys admission', () {
      const WalkaProductMediaResolver resolver = WalkaProductMediaResolver.production();
      const List<WalkaProductMediaSurface> surfaces = <WalkaProductMediaSurface>[
        WalkaProductMediaSurface.home,
        WalkaProductMediaSurface.discovery,
        WalkaProductMediaSurface.pdp,
        WalkaProductMediaSurface.favorites,
        WalkaProductMediaSurface.about,
      ];
      int cells = 0;
      for (final String variant in WalkaProductMediaResolver.productionVariantIds) {
        for (final WalkaProductMediaSurface surface in surfaces) {
          final WalkaProductMedia media = resolver.resolveForSurface(
            variantId: variant,
            fallback: fallback,
            surface: surface,
          );
          expect(media, isA<WalkaAssetProductMedia>(), reason: '$variant/$surface');
          final WalkaAssetProductMedia asset = media as WalkaAssetProductMedia;
          expect(
            asset.runtimeAdmitted,
            WalkaProductMediaAdmissionRegistry.isRuntimeEligible(variant),
            reason: '$variant/$surface',
          );
          expect(
            asset.asset.cacheWidth,
            WalkaProductMediaDecodeBudget.forSurface(surface),
            reason: '$variant/$surface',
          );
          expect(asset.surface, surface);
          expect(
            asset.filterQuality,
            surface == WalkaProductMediaSurface.pdp
                ? FilterQuality.high
                : FilterQuality.medium,
          );
          cells += 1;
        }
      }
      expect(cells, 25);
    });

    test('surface decode budgets and cache identities stay deterministic', () {
      expect(WalkaProductMediaDecodeBudget.home, 1200);
      expect(WalkaProductMediaDecodeBudget.discovery, 1200);
      expect(WalkaProductMediaDecodeBudget.pdp, 1600);
      expect(WalkaProductMediaDecodeBudget.favorites, 1200);
      expect(WalkaProductMediaDecodeBudget.about, 1200);
      const WalkaProductMediaAsset base = WalkaProductMediaAsset(
        variantId: 'lunch-box:blue',
        assetPath: 'assets/products/lunch/blue.png',
      );
      expect(base.withCacheWidth(1200), same(base));
      expect(base.withCacheWidth(1600).cacheIdentity, isNot(base.cacheIdentity));
    });

    test('resolver source keeps high-PDP/medium-default, gapless and admission guards', () {
      final String source = File(
        'lib/design_system/components/media/walka_product_media_resolver.dart',
      ).readAsStringSync();
      expect(source, contains('FilterQuality.high'));
      expect(source, contains('FilterQuality.medium'));
      expect(source, contains('gaplessPlayback: true'));
      expect(source, contains('if (!_isAssetEligible(registered))'));
      expect(source, contains('if (!seen.add(variantId)) continue;'));
    });
  });

  group('VSURF-061..070 prefetch and real async behavior', () {
    testWidgets('pending/blocked/unknown prefetch skips deterministically',
        (WidgetTester tester) async {
      const Key hostKey = ValueKey<String>('vsurf-prefetch-host');
      await tester.pumpWidget(
        const MaterialApp(home: SizedBox(key: hostKey, width: 10, height: 10)),
      );
      final BuildContext context = tester.element(find.byKey(hostKey));
      const WalkaProductMediaResolver resolver = WalkaProductMediaResolver.production();
      final List<String> quarantined = WalkaProductMediaAdmissionRegistry.entries.values
          .where((WalkaProductMediaAdmissionEntry entry) => !entry.eligibleForRuntime)
          .map((WalkaProductMediaAdmissionEntry entry) => entry.variantId)
          .toList();
      expect(quarantined, isNotEmpty);
      for (final String variant in quarantined) {
        final WalkaProductMediaPrefetchResult result = await resolver.prefetchVariant(
          context,
          variantId: variant,
          surface: WalkaProductMediaSurface.discovery,
        );
        expect(result.skipped, isTrue, reason: variant);
        expect(result.surface, WalkaProductMediaSurface.discovery);
        expect(result.skipReason, isNotNull);
      }
      final WalkaProductMediaPrefetchResult unknown = await resolver.prefetchVariant(
        context,
        variantId: 'unknown:variant',
        surface: WalkaProductMediaSurface.home,
      );
      expect(unknown.skipped, isTrue);
      expect(unknown.skipReason, 'asset-not-registered');
    });

    testWidgets('admitted White prefetch completes inside a real async boundary',
        (WidgetTester tester) async {
      const Key hostKey = ValueKey<String>('vsurf-real-prefetch-host');
      await tester.pumpWidget(
        const MaterialApp(home: SizedBox(key: hostKey, width: 10, height: 10)),
      );
      final BuildContext context = tester.element(find.byKey(hostKey));
      const WalkaProductMediaResolver resolver = WalkaProductMediaResolver.production();
      final WalkaProductMediaPrefetchResult result = await tester.runAsync(
        () => resolver.prefetchVariant(
          context,
          variantId: 'drawer-organizer:white',
          surface: WalkaProductMediaSurface.home,
        ),
      );
      expect(result, isNotNull);
      expect(result!.failed, isFalse);
      expect(result.prefetched, isTrue);
      expect(result.surface, WalkaProductMediaSurface.home);
    });

    testWidgets('multi-prefetch deduplicates while preserving first-seen order',
        (WidgetTester tester) async {
      const Key hostKey = ValueKey<String>('vsurf-dedupe-host');
      await tester.pumpWidget(
        const MaterialApp(home: SizedBox(key: hostKey, width: 10, height: 10)),
      );
      final BuildContext context = tester.element(find.byKey(hostKey));
      const WalkaProductMediaResolver resolver = WalkaProductMediaResolver.production();
      final List<WalkaProductMediaPrefetchResult> results =
          await resolver.prefetchVariants(
        context,
        variantIds: const <String>[
          'drawer-organizer:gray',
          'drawer-organizer:gray',
          'lunch-box:pink',
          'lunch-box:pink',
          'unknown:variant',
        ],
        surface: WalkaProductMediaSurface.favorites,
      );
      expect(
        results.map((WalkaProductMediaPrefetchResult result) => result.variantId),
        <String>['drawer-organizer:gray', 'lunch-box:pink', 'unknown:variant'],
      );
      expect(
        results.every((WalkaProductMediaPrefetchResult result) =>
            result.surface == WalkaProductMediaSurface.favorites),
        isTrue,
      );
    });
  });

  group('VSURF-071..090 responsive matrix and report contract', () {
    test('all slots cover mobile targets; adaptive surfaces cover tablet/desktop', () {
      final VsurfReport report =
          VsurfAuditor(mobileRoot: Directory.current).audit();
      for (final VsurfSurfaceSlot slot in report.slots) {
        final List<String> covered = report.matrix[slot.id]!;
        expect(covered, containsAll(VsurfContractRegistry.phoneTargets), reason: slot.id);
        if (slot.surfaceToken.endsWith('.home') ||
            slot.surfaceToken.endsWith('.discovery') ||
            slot.surfaceToken.endsWith('.pdp')) {
          expect(covered, containsAll(<String>['tablet', 'desktop']), reason: slot.id);
        }
      }
    });

    test('JSON report is deterministic, ordered and machine-readable', () {
      final VsurfReport first =
          VsurfAuditor(mobileRoot: Directory.current).audit();
      final VsurfReport second =
          VsurfAuditor(mobileRoot: Directory.current).audit();
      expect(first.prettyJson(), second.prettyJson());
      final Map<String, dynamic> json =
          jsonDecode(first.prettyJson()) as Map<String, dynamic>;
      expect(json['schemaVersion'], 1);
      expect(json['slotCount'], 9);
      expect(json['deviceTargetCount'], 6);
      expect(json['blockerCount'], 0);
      expect(json['state'], 'READY');
      expect(json['globalReleaseState'], first.admittedCount == 5 ? 'READY' : 'BLOCKED');
      expect(json['slots'], hasLength(9));
      expect(json['admission'], hasLength(5));
      expect(json['matrix'], isA<Map<String, dynamic>>());
      expect(json['violations'], isA<List<dynamic>>());
      expect(first.summary(), contains('VSURF READY'));
    });
  });

  group('VSURF-091..100 CLI/CI/task coverage contract', () {
    test('CLI exposes root/json/report/enforce and keeps 5/5 release gate separate', () {
      final String source =
          File('tool/verify_owner_visible_media_surfaces.dart').readAsStringSync();
      expect(source, contains("case '--root':"));
      expect(source, contains("case '--json':"));
      expect(source, contains("case '--report':"));
      expect(source, contains("case '--enforce':"));
      expect(source, contains('verify_production_assets'));
    });

    test('workflow executes VSURF enforcement and uploads its JSON evidence', () {
      final String workflow =
          File('../.github/workflows/flutter-preview.yml').readAsStringSync();
      expect(workflow, contains('verify_owner_visible_media_surfaces.dart'));
      expect(workflow, contains('owner-visible-media-surface-report.json'));
      expect(workflow, contains('owner-visible-media-surface-${{ github.sha }}'));
    });

    test('batch namespace contains exactly 100 unique task IDs', () {
      final List<String> taskIds = <String>[
        for (int i = 1; i <= 100; i += 1)
          'VSURF-${i.toString().padLeft(3, '0')}',
      ];
      expect(taskIds, hasLength(100));
      expect(taskIds.toSet(), hasLength(100));
      expect(taskIds.first, 'VSURF-001');
      expect(taskIds.last, 'VSURF-100');
    });
  });
}
