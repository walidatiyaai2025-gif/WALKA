import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/catalog/catalog_state.dart';
import 'package:walka/features/catalog/data/walka_catalog_cache.dart';
import 'package:walka/features/catalog/data/walka_catalog_repository.dart';
import 'package:walka/features/catalog/domain/walka_catalog.dart';
import 'package:walka/features/commerce/amazon_purchase.dart';
import 'package:walka/features/favorites/favorites_state.dart';
import 'package:walka/features/storefront/dynamic_catalog_v140.dart';
import 'package:walka/features/storefront/dynamic_favorites_v140.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    WalkaAmazonPurchaseRegistry.clearForTesting();
  });

  test('SharedPreferences cache round-trips arbitrary Dashboard catalog', () async {
    final SharedPreferencesWalkaCatalogCache cache = SharedPreferencesWalkaCatalogCache();
    final WalkaCatalogSnapshot source = _dynamicCatalog();
    await cache.write(source);
    final WalkaCatalogSnapshot? cached = await cache.read();
    expect(cached, isNotNull);
    expect(cached!.source, WalkaCatalogSource.cache);
    expect(cached.categories.map((item) => item.id), <String>['workspace', 'travel']);
    expect(cached.productById('desk-kit')?.name, 'Desk Kit Pro');
    expect(cached.variantById('desk-kit:emerald')?.asin, 'B012345672');
    expect(cached.variantById('desk-kit:emerald')?.swatchHex, '#228855');
  });

  test('corrupted SharedPreferences cache is ignored', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      SharedPreferencesWalkaCatalogCache.storageKey: '{not-json',
    });
    expect(await SharedPreferencesWalkaCatalogCache().read(), isNull);
  });

  test('purchase registry follows arbitrary selected Dashboard variants', () {
    WalkaAmazonPurchaseRegistry.replaceFromSnapshot(_dynamicCatalog());
    expect(
      WalkaAmazonPurchaseRegistry.requireUriForVariant('desk-kit:emerald'),
      Uri.parse('https://www.amazon.com/dp/B012345672'),
    );
    expect(
      WalkaAmazonPurchaseRegistry.requireUriForVariant('travel-mug:sand'),
      Uri.parse('https://www.amazon.com/dp/B012345673'),
    );
  });

  testWidgets('dynamic Search opens PDP but does not compile a layout fallback',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final WalkaCatalogController controller = await _loadedController();
    final WalkaFavoritesController favorites =
        WalkaFavoritesController(_MemoryFavoritesStore());
    await favorites.load();
    addTearDown(controller.dispose);
    addTearDown(favorites.dispose);

    await tester.pumpWidget(WalkaFavoritesScope(
      controller: favorites,
      child: WalkaCatalogScope(
        controller: controller,
        child: MaterialApp(
          theme: buildWalkaTheme(),
          home: const Scaffold(body: WalkaDynamicSearchV140()),
        ),
      ),
    ));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'emerald');
    await tester.pump();
    expect(find.text('Desk Kit Pro'), findsOneWidget);
    expect(find.text('Travel Mug'), findsNothing);

    await tester.tap(find.text('Desk Kit Pro'));
    await tester.pumpAndSettle();

    expect(find.byType(WalkaDynamicProductDetailV140), findsOneWidget);
    expect(find.text('Desk Kit Pro'), findsOneWidget);
    expect(find.text('Emerald'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dynamic Favorites hides stale IDs and uses unavailable media fallback',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final WalkaCatalogController controller = await _loadedController();
    final WalkaFavoritesController favorites = WalkaFavoritesController(
      _MemoryFavoritesStore(
        initial: <String>{'desk-kit:emerald', 'removed-product:legacy'},
      ),
    );
    await favorites.load();
    addTearDown(controller.dispose);
    addTearDown(favorites.dispose);

    await tester.pumpWidget(WalkaFavoritesScope(
      controller: favorites,
      child: WalkaCatalogScope(
        controller: controller,
        child: MaterialApp(
          theme: buildWalkaTheme(),
          home: Scaffold(
            body: WalkaDynamicFavoritesV140(onExplore: () {}),
          ),
        ),
      ),
    ));
    await tester.pump();

    expect(favorites.favoriteIds, contains('removed-product:legacy'));
    expect(find.text('Desk Kit Pro'), findsOneWidget);
    expect(find.text('Emerald'), findsOneWidget);
    expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('favorite-remove-desk-kit:emerald')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('favorite-remove-desk-kit:emerald')),
    );
    await tester.pump();
    expect(favorites.isFavorite('desk-kit:emerald'), isFalse);
    expect(favorites.favoriteIds, contains('removed-product:legacy'));
    expect(find.text('Desk Kit Pro'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dynamic Categories renders Dashboard categories and products',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final WalkaCatalogController controller = await _loadedController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(WalkaCatalogScope(
      controller: controller,
      child: MaterialApp(
        theme: buildWalkaTheme(),
        home: const Scaffold(body: WalkaDynamicCategoriesV140()),
      ),
    ));
    await tester.pump();
    expect(find.text('Workspace Essentials'), findsOneWidget);
    expect(find.text('Travel Gear'), findsOneWidget);
    expect(find.text('Desk Kit Pro'), findsOneWidget);
    expect(find.text('Travel Mug'), findsOneWidget);
    expect(find.text('Blue'), findsNothing);
    expect(find.text('Pink'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Future<WalkaCatalogController> _loadedController() async {
  final WalkaCatalogController controller = WalkaCatalogController(
    repository: WalkaCatalogRepository(
      cache: _MemoryCatalogCache(
        snapshot: _dynamicCatalog().asSource(WalkaCatalogSource.cache),
      ),
    ),
  );
  await controller.load();
  return controller;
}

WalkaCatalogSnapshot _dynamicCatalog() => WalkaCatalogSnapshot(
  config: const WalkaStorefrontConfig(
    brand: 'WALKA',
    release: 'dynamic-test',
    apiVersion: 'v1',
    purchaseMode: 'amazon_redirect',
  ),
  categories: const <WalkaCatalogCategory>[
    WalkaCatalogCategory(id: 'workspace', name: 'Workspace Essentials', sortOrder: 0),
    WalkaCatalogCategory(id: 'travel', name: 'Travel Gear', sortOrder: 1),
  ],
  products: const <WalkaCatalogProduct>[
    WalkaCatalogProduct(
      id: 'desk-kit',
      name: 'Desk Kit Pro',
      category: 'workspace',
      features: <String>['Modular organization'],
      facts: <String, dynamic>{'material': 'Dashboard value'},
      variants: <WalkaCatalogVariant>[
        WalkaCatalogVariant(
          id: 'desk-kit:midnight',
          color: 'Midnight',
          asin: 'B012345671',
          swatchHex: '#102030',
          purchaseUrl: 'https://www.amazon.com/dp/B012345671',
        ),
        WalkaCatalogVariant(
          id: 'desk-kit:emerald',
          color: 'Emerald',
          asin: 'B012345672',
          swatchHex: '#228855',
          purchaseUrl: 'https://www.amazon.com/dp/B012345672',
        ),
      ],
    ),
    WalkaCatalogProduct(
      id: 'travel-mug',
      name: 'Travel Mug',
      category: 'travel',
      features: <String>['Insulated'],
      facts: <String, dynamic>{'capacity_ml': 500},
      variants: <WalkaCatalogVariant>[
        WalkaCatalogVariant(
          id: 'travel-mug:sand',
          color: 'Sand',
          asin: 'B012345673',
          swatchHex: '#C9B79C',
          purchaseUrl: 'https://www.amazon.com/dp/B012345673',
        ),
      ],
    ),
  ],
  source: WalkaCatalogSource.remote,
  fetchedAt: DateTime.utc(2026, 8, 16),
);

class _MemoryCatalogCache implements WalkaCatalogCache {
  _MemoryCatalogCache({this.snapshot});
  WalkaCatalogSnapshot? snapshot;
  @override
  Future<void> clear() async => snapshot = null;
  @override
  Future<WalkaCatalogSnapshot?> read() async => snapshot;
  @override
  Future<void> write(WalkaCatalogSnapshot value) async {
    snapshot = value.asSource(WalkaCatalogSource.cache);
  }
}

class _MemoryFavoritesStore implements WalkaFavoritesStore {
  _MemoryFavoritesStore({Set<String>? initial})
      : _ids = Set<String>.from(initial ?? const <String>{});

  Set<String> _ids;

  @override
  Future<Set<String>> readFavoriteIds() async => Set<String>.from(_ids);

  @override
  Future<void> writeFavoriteIds(Set<String> ids) async {
    _ids = Set<String>.from(ids);
  }
}
