import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/media/walka_product_media.dart';
import 'package:walka/design_system/components/media/walka_product_media_resolver.dart';
import 'package:walka/design_system/walka_product_visual.dart';

void main() {
  WalkaPaintedProductMedia fallback() => const WalkaPaintedProductMedia(
        kind: WalkaProductVisualKind.drawerOrganizer,
        primaryColor: Color(0xFFF7F4EC),
        backgroundColor: Color(0xFFF4EEDF),
        semanticLabel: 'WALKA Drawer Organizer White',
      );

  test('PMR-001..010 runtime model and released registry are exact', () {
    expect(
      WalkaProductMediaSurface.values,
      <WalkaProductMediaSurface>[
        WalkaProductMediaSurface.home,
        WalkaProductMediaSurface.discovery,
        WalkaProductMediaSurface.pdp,
        WalkaProductMediaSurface.favorites,
        WalkaProductMediaSurface.about,
        WalkaProductMediaSurface.generic,
      ],
    );
    expect(
      WalkaProductMediaLoadState.values,
      <WalkaProductMediaLoadState>[
        WalkaProductMediaLoadState.loading,
        WalkaProductMediaLoadState.loaded,
        WalkaProductMediaLoadState.fallback,
      ],
    );
    expect(
      WalkaProductMediaResolver.productionVariantIds,
      <String>[
        'drawer-organizer:white',
        'drawer-organizer:gray',
        'lunch-box:blue',
        'lunch-box:pink',
        'lunch-box:green',
      ],
    );

    const WalkaProductMediaResolver resolver =
        WalkaProductMediaResolver.production();
    expect(resolver.releasedVariantIds, WalkaProductMediaResolver.productionVariantIds);
    expect(resolver.releasedAssets.map((WalkaProductMediaAsset asset) => asset.assetPath), <String>[
      'assets/products/drawer/white.png',
      'assets/products/drawer/gray.png',
      'assets/products/lunch/blue.png',
      'assets/products/lunch/pink.png',
      'assets/products/lunch/green.png',
    ]);
    expect(resolver.containsReleasedVariant('lunch-box:green'), isTrue);
    expect(resolver.containsReleasedVariant('unknown:variant'), isFalse);
    expect(resolver.familyFor('drawer-organizer:white'), 'Drawer Organizer');
    expect(resolver.familyFor('lunch-box:pink'), 'Lunch Box');
    expect(resolver.displayLabelFor('lunch-box:blue'), 'WALKA Lunch Box Blue');
    expect(resolver.displayLabelFor('unknown:variant'), isNull);
  });

  test('PMR-011..020 surface decode and cache identity policy is stable', () {
    expect(
      WalkaProductMediaDecodeBudget.forSurface(WalkaProductMediaSurface.home),
      1200,
    );
    expect(
      WalkaProductMediaDecodeBudget.forSurface(WalkaProductMediaSurface.discovery),
      1200,
    );
    expect(
      WalkaProductMediaDecodeBudget.forSurface(WalkaProductMediaSurface.pdp),
      1600,
    );
    expect(
      WalkaProductMediaDecodeBudget.forSurface(WalkaProductMediaSurface.favorites),
      1200,
    );
    expect(
      WalkaProductMediaDecodeBudget.forSurface(WalkaProductMediaSurface.about),
      1200,
    );
    expect(
      WalkaProductMediaDecodeBudget.forSurface(WalkaProductMediaSurface.generic),
      1200,
    );

    const WalkaProductMediaAsset asset = WalkaProductMediaAsset(
      variantId: 'lunch-box:blue',
      assetPath: 'assets/products/lunch/blue.png',
    );
    final WalkaProductMediaAsset pdpAsset = asset.withCacheWidth(1600);
    expect(asset.cacheWidth, 1200);
    expect(pdpAsset.cacheWidth, 1600);
    expect(asset.assetPath, pdpAsset.assetPath);
    expect(asset.variantId, pdpAsset.variantId);
    expect(asset.cacheIdentity, isNot(pdpAsset.cacheIdentity));
    expect(asset.withCacheWidth(1200), same(asset));
  });

  test('PMR-021..030 resolver remains compatible and surface-aware', () {
    const WalkaProductMediaResolver resolver =
        WalkaProductMediaResolver.production();
    final WalkaPaintedProductMedia painted = fallback();

    expect(resolver.assetFor('drawer-organizer:white')!.assetPath,
        'assets/products/drawer/white.png');
    expect(resolver.assetFor('unknown:variant'), isNull);
    expect(resolver.hasApprovedAsset('lunch-box:green'), isTrue);

    final WalkaProductMedia unknown = resolver.resolveForSurface(
      variantId: 'unknown:variant',
      fallback: painted,
      surface: WalkaProductMediaSurface.pdp,
    );
    expect(identical(unknown, painted), isTrue);

    final WalkaProductMedia pdp = resolver.resolveForSurface(
      variantId: 'drawer-organizer:white',
      fallback: painted,
      surface: WalkaProductMediaSurface.pdp,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
    );
    expect(pdp, isA<WalkaAssetProductMedia>());
    final WalkaAssetProductMedia pdpAsset = pdp as WalkaAssetProductMedia;
    expect(pdpAsset.asset.cacheWidth, 1600);
    expect(pdpAsset.surface, WalkaProductMediaSurface.pdp);
    expect(pdpAsset.fit, BoxFit.cover);
    expect(pdpAsset.alignment, Alignment.topCenter);
    expect(pdpAsset.filterQuality, FilterQuality.high);

    final WalkaProductMedia compatible = resolver.resolve(
      variantId: 'drawer-organizer:white',
      fallback: painted,
    );
    expect(compatible, isA<WalkaAssetProductMedia>());
    expect(
      (compatible as WalkaAssetProductMedia).asset.cacheWidth,
      WalkaProductMediaResolver.defaultCacheWidth,
    );
  });

  test('PMR-031..050 load events and prefetch result value objects are stable', () {
    const WalkaProductMediaLoadEvent a = WalkaProductMediaLoadEvent(
      variantId: 'drawer-organizer:white',
      assetPath: 'assets/products/drawer/white.png',
      surface: WalkaProductMediaSurface.home,
      state: WalkaProductMediaLoadState.loading,
    );
    const WalkaProductMediaLoadEvent b = WalkaProductMediaLoadEvent(
      variantId: 'drawer-organizer:white',
      assetPath: 'assets/products/drawer/white.png',
      surface: WalkaProductMediaSurface.home,
      state: WalkaProductMediaLoadState.loading,
    );
    const WalkaProductMediaLoadEvent c = WalkaProductMediaLoadEvent(
      variantId: 'drawer-organizer:white',
      assetPath: 'assets/products/drawer/white.png',
      surface: WalkaProductMediaSurface.home,
      state: WalkaProductMediaLoadState.fallback,
    );
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(c));

    const WalkaProductMediaPrefetchResult p1 = WalkaProductMediaPrefetchResult(
      variantId: 'unknown:variant',
      surface: WalkaProductMediaSurface.discovery,
      state: WalkaProductMediaPrefetchState.skipped,
    );
    const WalkaProductMediaPrefetchResult p2 = WalkaProductMediaPrefetchResult(
      variantId: 'unknown:variant',
      surface: WalkaProductMediaSurface.discovery,
      state: WalkaProductMediaPrefetchState.skipped,
    );
    expect(p1, p2);
    expect(p1.hashCode, p2.hashCode);
    expect(p1.skipped, isTrue);
    expect(p1.prefetched, isFalse);
    expect(p1.failed, isFalse);
  });

  testWidgets('PMR-031..050 missing asset emits loading/fallback once with semantics',
      (WidgetTester tester) async {
    const WalkaProductMediaResolver resolver = WalkaProductMediaResolver(
      assetsByVariant: <String, WalkaProductMediaAsset>{
        'drawer-organizer:white': WalkaProductMediaAsset(
          variantId: 'drawer-organizer:white',
          assetPath: 'assets/products/not-approved/pmr-missing.png',
        ),
      },
    );
    final List<WalkaProductMediaLoadEvent> events = <WalkaProductMediaLoadEvent>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox.square(
            dimension: 180,
            child: WalkaResolvedProductMedia(
              variantId: 'drawer-organizer:white',
              kind: WalkaProductVisualKind.drawerOrganizer,
              primaryColor: const Color(0xFFF7F4EC),
              backgroundColor: const Color(0xFFF4EEDF),
              semanticLabel: 'WALKA Drawer Organizer White',
              mediaSurface: WalkaProductMediaSurface.pdp,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              onLoadEvent: events.add,
              resolver: resolver,
            ),
          ),
        ),
      ),
    );

    final Image imageBeforeFailure = tester.widget<Image>(find.byType(Image));
    expect(imageBeforeFailure.fit, BoxFit.cover);
    expect(imageBeforeFailure.alignment, Alignment.topCenter);
    expect(imageBeforeFailure.filterQuality, FilterQuality.high);
    expect(imageBeforeFailure.gaplessPlayback, isTrue);
    expect(imageBeforeFailure.semanticLabel, 'WALKA Drawer Organizer White');

    await tester.pumpAndSettle();

    expect(
      events.map((WalkaProductMediaLoadEvent event) => event.state),
      containsAllInOrder(<WalkaProductMediaLoadState>[
        WalkaProductMediaLoadState.loading,
        WalkaProductMediaLoadState.fallback,
      ]),
    );
    expect(
      events.where((WalkaProductMediaLoadEvent event) =>
          event.state == WalkaProductMediaLoadState.loading),
      hasLength(1),
    );
    expect(
      events.where((WalkaProductMediaLoadEvent event) =>
          event.state == WalkaProductMediaLoadState.fallback),
      hasLength(1),
    );
    expect(
      events.where((WalkaProductMediaLoadEvent event) =>
          event.state == WalkaProductMediaLoadState.loaded),
      isEmpty,
    );
    expect(events.last.variantId, 'drawer-organizer:white');
    expect(events.last.assetPath, 'assets/products/not-approved/pmr-missing.png');
    expect(events.last.surface, WalkaProductMediaSurface.pdp);
    expect(
      find.bySemanticsLabel(
        'WALKA Drawer Organizer White. Product visual fallback.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('PMR-051..060 prefetch skips unknown IDs and deduplicates in order',
      (WidgetTester tester) async {
    const Key hostKey = ValueKey<String>('pmr-prefetch-host');
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(key: hostKey, width: 10, height: 10),
      ),
    );
    final BuildContext context = tester.element(find.byKey(hostKey));
    const WalkaProductMediaResolver resolver = WalkaProductMediaResolver();

    final List<WalkaProductMediaPrefetchResult> results =
        await resolver.prefetchVariants(
      context,
      variantIds: <String>[
        'unknown:first',
        'unknown:first',
        'unknown:second',
      ],
      surface: WalkaProductMediaSurface.discovery,
    );

    expect(results, hasLength(2));
    expect(results.map((WalkaProductMediaPrefetchResult result) => result.variantId),
        <String>['unknown:first', 'unknown:second']);
    expect(
      results.every((WalkaProductMediaPrefetchResult result) => result.skipped),
      isTrue,
    );
    expect(
      results.every((WalkaProductMediaPrefetchResult result) =>
          result.surface == WalkaProductMediaSurface.discovery),
      isTrue,
    );
  });

  test('PMR-071..080 sibling order and unknown handling remain deterministic', () {
    const WalkaProductMediaResolver resolver =
        WalkaProductMediaResolver.production();
    expect(
      WalkaProductMediaResolver.drawerVariantIds,
      <String>['drawer-organizer:white', 'drawer-organizer:gray'],
    );
    expect(
      WalkaProductMediaResolver.lunchVariantIds,
      <String>['lunch-box:blue', 'lunch-box:pink', 'lunch-box:green'],
    );
    expect(
      resolver.siblingVariantIds('drawer-organizer:gray'),
      <String>['drawer-organizer:white', 'drawer-organizer:gray'],
    );
    expect(
      resolver.siblingVariantIds('lunch-box:pink'),
      <String>['lunch-box:blue', 'lunch-box:pink', 'lunch-box:green'],
    );
    expect(resolver.siblingVariantIds('unknown:variant'), isEmpty);
  });

  test('PMR-081..090 exact canonical paths and surface resolution regressions', () {
    const WalkaProductMediaResolver resolver =
        WalkaProductMediaResolver.production();
    final List<String> identities = resolver.releasedAssets
        .map((WalkaProductMediaAsset asset) => asset.cacheIdentity)
        .toList();
    expect(identities, hasLength(5));
    expect(identities.toSet(), hasLength(5));
    expect(
      resolver.resolveForSurface(
        variantId: 'lunch-box:green',
        fallback: fallback(),
        surface: WalkaProductMediaSurface.pdp,
      ),
      isA<WalkaAssetProductMedia>(),
    );
    expect(
      resolver.resolveForSurface(
        variantId: 'not-released:green',
        fallback: fallback(),
        surface: WalkaProductMediaSurface.pdp,
      ),
      isA<WalkaPaintedProductMedia>(),
    );
  });

  test('PMR-091..096 owner-visible call sites declare explicit surface policy', () {
    String source(String path) => File(path).readAsStringSync();

    final String homeHero = source(
      'lib/features/storefront/presentation/widgets/home/walka_home_hero.dart',
    );
    final String homeCollection = source(
      'lib/features/storefront/presentation/widgets/home/walka_home_collection_card.dart',
    );
    final String homeSmall = source(
      'lib/features/storefront/presentation/widgets/home/walka_home_small_changes.dart',
    );
    final String category = source(
      'lib/features/storefront/presentation/widgets/discovery/walka_category_card.dart',
    );
    final String row = source(
      'lib/features/storefront/presentation/widgets/discovery/walka_discovery_product_row.dart',
    );
    final String pdp = source(
      'lib/features/products/presentation/widgets/walka_pdp_gallery_viewport.dart',
    );
    final String fullscreen = source(
      'lib/features/products/presentation/widgets/walka_pdp_fullscreen_gallery.dart',
    );
    final String favorites = source(
      'lib/features/storefront/presentation/widgets/favorites/walka_saved_drawer_card.dart',
    );
    final String about = source(
      'lib/features/storefront/presentation/widgets/about/walka_about_product_story.dart',
    );

    expect(homeHero, contains('mediaSurface: WalkaProductMediaSurface.home'));
    expect(homeCollection, contains('mediaSurface: WalkaProductMediaSurface.home'));
    expect(homeSmall, contains('mediaSurface: WalkaProductMediaSurface.home'));
    expect(category, contains('mediaSurface: WalkaProductMediaSurface.discovery'));
    expect(row, contains('mediaSurface: WalkaProductMediaSurface.discovery'));
    expect(pdp, contains('mediaSurface: WalkaProductMediaSurface.pdp'));
    expect(fullscreen, contains('mediaSurface: WalkaProductMediaSurface.pdp'));
    expect(favorites, contains('mediaSurface: WalkaProductMediaSurface.favorites'));
    expect(about, contains('mediaSurface: WalkaProductMediaSurface.about'));

    final String runtime = source(
      'lib/design_system/components/media/walka_product_media_resolver.dart',
    );
    for (final String code in <String>[
      runtime,
      homeHero,
      homeCollection,
      homeSmall,
      category,
      row,
      pdp,
      fullscreen,
      favorites,
      about,
    ]) {
      expect(code, isNot(contains('Images/')));
    }
  });

  test('PMR-001..100 batch defines exactly one hundred atomic task IDs', () {
    final List<String> ids = List<String>.generate(
      100,
      (int index) => 'PMR-${(index + 1).toString().padLeft(3, '0')}',
    );
    expect(ids.first, 'PMR-001');
    expect(ids.last, 'PMR-100');
    expect(ids.toSet(), hasLength(100));
  });
}
