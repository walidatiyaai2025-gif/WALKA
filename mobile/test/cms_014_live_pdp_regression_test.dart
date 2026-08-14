import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/catalog/catalog_state.dart';
import 'package:walka/features/catalog/data/walka_bundled_catalog.dart';
import 'package:walka/features/catalog/domain/walka_catalog.dart';
import 'package:walka/features/content/content_state.dart';
import 'package:walka/features/content/data/walka_pdp_layout_cache.dart';
import 'package:walka/features/content/data/walka_pdp_layout_repository.dart';
import 'package:walka/features/content/data/walka_related_products_cache.dart';
import 'package:walka/features/content/data/walka_related_products_repository.dart';
import 'package:walka/features/content/domain/walka_pdp_layout_content.dart';
import 'package:walka/features/content/domain/walka_related_products_content.dart';
import 'package:walka/features/favorites/favorites_state.dart';
import 'package:walka/features/products/presentation/widgets/walka_pdp_details.dart';
import 'package:walka/features/products/product_experience_v112.dart';

void main() {
  testWidgets('CMS-014 published layout and related products reach the live V112 PDP',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final WalkaContentController content = await _loadedContent();
    final _SnapshotCatalogController catalog = _SnapshotCatalogController(
      WalkaBundledCatalog.snapshot(fetchedAt: DateTime.utc(2026, 8, 14)),
    );
    final WalkaFavoritesController favorites = _favorites();
    await favorites.load();
    addTearDown(content.dispose);
    addTearDown(catalog.dispose);
    addTearDown(favorites.dispose);

    await tester.pumpWidget(
      WalkaCatalogScope(
        controller: catalog,
        child: WalkaContentScope(
          controller: content,
          child: WalkaFavoritesScope(
            controller: favorites,
            child: MaterialApp(
              theme: buildWalkaTheme(),
              home: const WalkaDrawerProductDetailV112(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('BUY ON AMAZON'), findsOneWidget);
    expect(find.byType(WalkaPdpUsagePanel), findsNothing);
    expect(find.text('YOU MAY ALSO LIKE'), findsOneWidget);
    final Finder lunchCard = find.byKey(
      const ValueKey<String>(
        'related-product-stainless-steel-bento-lunch-box',
      ),
    );
    expect(lunchCard, findsOneWidget);

    await tester.ensureVisible(lunchCard);
    await tester.tap(lunchCard);
    await tester.pumpAndSettle();

    expect(find.byType(WalkaLunchProductDetailV112), findsOneWidget);
    expect(find.text('BUY ON AMAZON'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('CMS relationship cannot surface a product absent from visible catalog',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final WalkaCatalogSnapshot bundled = WalkaBundledCatalog.snapshot(
      fetchedAt: DateTime.utc(2026, 8, 14),
    );
    final WalkaCatalogProduct drawer = bundled.productById('drawer-organizer')!;
    final WalkaCatalogSnapshot drawerOnly = WalkaCatalogSnapshot(
      config: bundled.config,
      products: <WalkaCatalogProduct>[drawer],
      source: WalkaCatalogSource.remote,
      fetchedAt: DateTime.utc(2026, 8, 14),
    );

    final WalkaContentController content = await _loadedContent();
    final _SnapshotCatalogController catalog =
        _SnapshotCatalogController(drawerOnly);
    final WalkaFavoritesController favorites = _favorites();
    await favorites.load();
    addTearDown(content.dispose);
    addTearDown(catalog.dispose);
    addTearDown(favorites.dispose);

    await tester.pumpWidget(
      WalkaCatalogScope(
        controller: catalog,
        child: WalkaContentScope(
          controller: content,
          child: WalkaFavoritesScope(
            controller: favorites,
            child: MaterialApp(
              theme: buildWalkaTheme(),
              home: const WalkaDrawerProductDetailV112(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('BUY ON AMAZON'), findsOneWidget);
    expect(find.text('YOU MAY ALSO LIKE'), findsNothing);
    expect(
      find.byKey(const ValueKey<String>(
        'related-product-stainless-steel-bento-lunch-box',
      )),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}

Future<WalkaContentController> _loadedContent() async {
  const WalkaPdpLayoutContent layout = WalkaPdpLayoutContent(
    sections: <WalkaPdpSectionConfig>[
      WalkaPdpSectionConfig(id: WalkaPdpSectionId.variants, visible: true),
      WalkaPdpSectionConfig(id: WalkaPdpSectionId.gallery, visible: true),
      WalkaPdpSectionConfig(id: WalkaPdpSectionId.identity, visible: true),
      WalkaPdpSectionConfig(id: WalkaPdpSectionId.facts, visible: true),
      WalkaPdpSectionConfig(
        id: WalkaPdpSectionId.specifications,
        visible: true,
      ),
      WalkaPdpSectionConfig(id: WalkaPdpSectionId.amazonTrust, visible: true),
      WalkaPdpSectionConfig(id: WalkaPdpSectionId.editorial, visible: true),
      WalkaPdpSectionConfig(id: WalkaPdpSectionId.usage, visible: false),
    ],
  );
  const WalkaRelatedProductsContent related = WalkaRelatedProductsContent(
    relationships: <WalkaRelatedProductRelationship>[
      WalkaRelatedProductRelationship(
        productId: 'drawer-organizer',
        relatedProductIds: <String>['stainless-steel-bento-lunch-box'],
      ),
      WalkaRelatedProductRelationship(
        productId: 'stainless-steel-bento-lunch-box',
        relatedProductIds: <String>[],
      ),
    ],
  );

  final WalkaContentController controller = WalkaContentController(
    pdpLayoutRepository: WalkaPdpLayoutRepository(
      cache: _MemoryPdpLayoutCache(),
      remoteLoader: () async => WalkaPdpLayoutPayload(
        content: layout,
        revision: 14,
        publishedAt: DateTime.utc(2026, 8, 14, 2, 45),
      ),
    ),
    relatedProductsRepository: WalkaRelatedProductsRepository(
      cache: _MemoryRelatedProductsCache(),
      remoteLoader: () async => WalkaRelatedProductsPayload(
        content: related,
        revision: 15,
        publishedAt: DateTime.utc(2026, 8, 14, 2, 46),
      ),
    ),
  );
  await controller.load();
  return controller;
}

class _SnapshotCatalogController extends WalkaCatalogController {
  _SnapshotCatalogController(this.current) : super.presentationProxy();

  final WalkaCatalogSnapshot current;

  @override
  WalkaCatalogSnapshot get snapshot => current;

  @override
  bool get isLoading => false;
}

class _MemoryPdpLayoutCache implements WalkaPdpLayoutCache {
  WalkaPdpLayoutSnapshot? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<WalkaPdpLayoutSnapshot?> read() async => value;

  @override
  Future<void> write(WalkaPdpLayoutSnapshot snapshot) async => value = snapshot;
}

class _MemoryRelatedProductsCache implements WalkaRelatedProductsCache {
  WalkaRelatedProductsSnapshot? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<WalkaRelatedProductsSnapshot?> read() async => value;

  @override
  Future<void> write(WalkaRelatedProductsSnapshot snapshot) async =>
      value = snapshot;
}

WalkaFavoritesController _favorites() =>
    WalkaFavoritesController(_MemoryFavoritesStore());

class _MemoryFavoritesStore implements WalkaFavoritesStore {
  Set<String> ids = <String>{};

  @override
  Future<Set<String>> readFavoriteIds() async => Set<String>.from(ids);

  @override
  Future<void> writeFavoriteIds(Set<String> favoriteIds) async {
    ids = Set<String>.from(favoriteIds);
  }
}
