import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/catalog/catalog_state.dart';
import 'package:walka/features/catalog/data/walka_catalog_cache.dart';
import 'package:walka/features/catalog/data/walka_catalog_repository.dart';
import 'package:walka/features/catalog/domain/walka_catalog.dart';
import 'package:walka/features/commerce/amazon_purchase.dart';
import 'package:walka/features/storefront/dynamic_catalog_v140.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    WalkaAmazonPurchaseRegistry.clearForTesting();
  });

  test('SharedPreferences cache round-trips arbitrary Dashboard catalog', () async {
    final SharedPreferencesWalkaCatalogCache cache =
        SharedPreferencesWalkaCatalogCache();
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

    final WalkaCatalogSnapshot? cached =
        await SharedPreferencesWalkaCatalogCache().read();

    expect(cached, isNull);
  });

  test('purchase registry follows arbitrary selected Dashboard variants', () {
    final WalkaCatalogSnapshot remote = _dynamicCatalog();

    WalkaAmazonPurchaseRegistry.replaceFromSnapshot(remote);

    expect(
      WalkaAmazonPurchaseRegistry.requireUriForVariant('desk-kit:emerald'),
      Uri.parse('https://www.amazon.com/dp/B012345672'),
    );
    expect(
      WalkaAmazonPurchaseRegistry.requireUriForVariant('travel-mug:sand'),
      Uri.parse('https://www.amazon.com/dp/B012345673'),
    );
  });

  testWidgets('dynamic Search uses arbitrary catalog and opens generic PDP',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final WalkaCatalogController controller = await _loadedController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      WalkaCatalogScope(
        controller: controller,
        child: MaterialApp(
          theme: buildWalkaTheme(),
          home: const Scaffold(body: WalkaDynamicSearchV140()),
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'emerald');
    await tester.pump();

    expect(find.text('1 product'), findsOneWidget);
    expect(find.text('Desk Kit Pro'), findsOneWidget);

    await tester.tap(find.text('Desk Kit Pro'));
    await tester.pumpAndSettle();

    expect(find.byType(WalkaDynamicProductDetailV140), findsOneWidget);
    expect(find.text('Emerald'), findsWidgets);
    expect(find.text('ASIN B012345672'), findsOneWidget);
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

    await tester.pumpWidget(
      WalkaCatalogScope(
        controller: controller,
        child: MaterialApp(
          theme: buildWalkaTheme(),
          home: const Scaffold(body: WalkaDynamicCategoriesV140()),
        ),
      ),
    );
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

WalkaCatalogSnapshot _dynamicCatalog() {
  const WalkaStorefrontConfig config = WalkaStorefrontConfig(
    brand: 'WALKA',
    release: 'dynamic-test',
    apiVersion: 'v1',
    purchaseMode: 'amazon_redirect',
  );
  const List<WalkaCatalogCategory> categories = <WalkaCatalogCategory>[
    WalkaCatalogCategory(id: 'workspace', name: 'Workspace Essentials', sortOrder: 0),
    WalkaCatalogCategory(id: 'travel', name: 'Travel Gear', sortOrder: 1),
  ];

  return WalkaCatalogSnapshot(
    config: config,
    categories: categories,
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
}

class _MemoryCatalogCache implements WalkaCatalogCache {
  _MemoryCatalogCache({this.snapshot});

  WalkaCatalogSnapshot? snapshot;

  @override
  Future<void> clear() async {
    snapshot = null;
  }

  @override
  Future<WalkaCatalogSnapshot?> read() async => snapshot;

  @override
  Future<void> write(WalkaCatalogSnapshot value) async {
    snapshot = value.asSource(WalkaCatalogSource.cache);
  }
}
