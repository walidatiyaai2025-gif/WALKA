import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/catalog/catalog_state.dart';
import 'package:walka/features/catalog/data/walka_bundled_catalog.dart';
import 'package:walka/features/catalog/data/walka_catalog_cache.dart';
import 'package:walka/features/catalog/domain/walka_catalog.dart';
import 'package:walka/features/commerce/amazon_purchase.dart';
import 'package:walka/features/products/product_experience_v100.dart';
import 'package:walka/features/storefront/storefront_catalog_v120.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    WalkaAmazonPurchaseRegistry.clearForTesting();
  });

  test('SharedPreferences cache round-trips the normalized catalog snapshot',
      () async {
    final SharedPreferencesWalkaCatalogCache cache =
        SharedPreferencesWalkaCatalogCache();
    final WalkaCatalogSnapshot bundled = WalkaBundledCatalog.snapshot(
      fetchedAt: DateTime.utc(2026, 8, 10),
    );

    await cache.write(bundled);
    final WalkaCatalogSnapshot? cached = await cache.read();

    expect(cached, isNotNull);
    expect(cached!.source, WalkaCatalogSource.cache);
    expect(cached.variants.length, 5);
    expect(cached.variantById('lunch-box:pink')?.asin, 'B0FQN3W4SF');
  });

  test('corrupted SharedPreferences cache is ignored', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      SharedPreferencesWalkaCatalogCache.storageKey: '{not-json',
    });

    final WalkaCatalogSnapshot? cached =
        await SharedPreferencesWalkaCatalogCache().read();

    expect(cached, isNull);
  });

  test('catalog controller registers validated selected-variant Amazon URLs', () {
    final WalkaCatalogSnapshot bundled = WalkaBundledCatalog.snapshot();
    final List<WalkaCatalogProduct> products = bundled.products.map(
      (WalkaCatalogProduct product) {
        if (product.id != 'drawer-organizer') return product;
        return WalkaCatalogProduct(
          id: product.id,
          name: product.name,
          category: product.category,
          features: product.features,
          facts: product.facts,
          variants: product.variants.map((WalkaCatalogVariant variant) {
            if (variant.id != 'drawer-organizer:white') return variant;
            return WalkaCatalogVariant(
              id: variant.id,
              color: variant.color,
              asin: variant.asin,
              purchaseUrl: 'https://www.amazon.com/dp/REMOTE-WHITE',
            );
          }).toList(growable: false),
        );
      },
    ).toList(growable: false);
    final WalkaCatalogSnapshot remote = WalkaCatalogSnapshot(
      config: bundled.config,
      products: products,
      source: WalkaCatalogSource.remote,
      fetchedAt: DateTime.utc(2026, 8, 10),
    );

    WalkaAmazonPurchaseRegistry.replaceFromSnapshot(remote);

    expect(
      amazonDrawerOrganizerUri(gray: false).toString(),
      'https://www.amazon.com/dp/REMOTE-WHITE',
    );
    expect(
      amazonDrawerOrganizerUri(gray: true).toString(),
      'https://www.amazon.com/dp/B0FQN4L2ZD',
    );
  });

  testWidgets('connected Search uses repository catalog and opens final PDP',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final WalkaCatalogController controller = WalkaCatalogController();
    await controller.load();

    await tester.pumpWidget(
      WalkaCatalogScope(
        controller: controller,
        child: MaterialApp(
          theme: buildWalkaTheme(),
          home: const Scaffold(body: WalkaSearchV120()),
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'green');
    await tester.pump();

    expect(find.text('1 result'), findsOneWidget);
    expect(find.text('Green'), findsOneWidget);
    expect(
      find.text('WALKA Large Stainless Steel Bento Lunch Box for Adults'),
      findsOneWidget,
    );

    await tester.tap(
      find.text('WALKA Large Stainless Steel Bento Lunch Box for Adults'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(WalkaLunchProductDetailV100), findsOneWidget);
    expect(find.textContaining('Green · PANTONE 6198 U'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('connected Categories exposes all five stable variants',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final WalkaCatalogController controller = WalkaCatalogController();
    await controller.load();
    final List<WalkaCatalogViewItem> items = walkaCatalogViewItems(
      controller.snapshot,
    );

    expect(
      items.map((WalkaCatalogViewItem item) => item.variantId).toSet(),
      WalkaCatalogContract.requiredVariantIds,
    );

    await tester.pumpWidget(
      WalkaCatalogScope(
        controller: controller,
        child: MaterialApp(
          theme: buildWalkaTheme(),
          home: const Scaffold(body: WalkaCategoriesV120()),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('5 current sellable variants'), findsOneWidget);
    final Finder scrollable = find.byType(Scrollable).first;

    await tester.scrollUntilVisible(
      find.text('White'),
      240,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
    expect(find.text('White'), findsOneWidget);
    expect(find.text('Gray'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Blue'),
      360,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
    expect(find.text('Blue'), findsOneWidget);
    expect(find.text('Pink'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Green'),
      260,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
    expect(find.text('Green'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
