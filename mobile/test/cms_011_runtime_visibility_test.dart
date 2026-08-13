import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/catalog/catalog_state.dart';
import 'package:walka/features/catalog/data/walka_bundled_catalog.dart';
import 'package:walka/features/catalog/domain/walka_catalog.dart';
import 'package:walka/features/lunch/lunch_box_v6.dart';
import 'package:walka/features/products/product_experience_v100.dart';
import 'package:walka/features/storefront/home_premium_v122.dart';

void main() {
  WalkaCatalogSnapshot snapshotWithOnlyGrayAndGreen() {
    final WalkaCatalogSnapshot bundled = WalkaBundledCatalog.snapshot(
      fetchedAt: DateTime.utc(2026, 8, 13),
    );

    final List<WalkaCatalogProduct> products = bundled.products.map(
      (WalkaCatalogProduct product) {
        final Set<String> visibleIds = product.id == 'drawer-organizer'
            ? <String>{'drawer-organizer:gray'}
            : <String>{'lunch-box:green'};
        return WalkaCatalogProduct(
          id: product.id,
          name: product.name,
          category: product.category,
          features: product.features,
          facts: product.facts,
          variants: product.variants
              .where((WalkaCatalogVariant variant) => visibleIds.contains(variant.id))
              .toList(growable: false),
          shortDescription: product.shortDescription,
          highlights: product.highlights,
          featured: product.featured,
          presentationOrder: product.presentationOrder,
        );
      },
    ).toList(growable: false);

    final WalkaCatalogSnapshot snapshot = WalkaCatalogSnapshot(
      config: bundled.config,
      products: products,
      source: WalkaCatalogSource.remote,
      fetchedAt: DateTime.utc(2026, 8, 13),
    );
    WalkaCatalogContract.validate(snapshot);
    return snapshot;
  }

  testWidgets('Home resolves family anchors from visible variants',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final _SnapshotCatalogController controller =
        _SnapshotCatalogController(snapshotWithOnlyGrayAndGreen());
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      WalkaCatalogScope(
        controller: controller,
        child: MaterialApp(
          theme: buildWalkaTheme(),
          home: Scaffold(
            body: WalkaHomePremiumV122(
              onShopAll: () {},
              onSearch: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('home-reference-hero')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Lunch PDP exposes only currently visible catalog variants',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final _SnapshotCatalogController controller =
        _SnapshotCatalogController(snapshotWithOnlyGrayAndGreen());
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      WalkaCatalogScope(
        controller: controller,
        child: MaterialApp(
          theme: buildWalkaTheme(),
          home: const WalkaLunchProductDetailV100(
            initialVariant: WalkaLunchVariant.blue,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('premium-lunch-green')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('premium-lunch-blue')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('premium-lunch-pink')),
      findsNothing,
    );
    expect(find.textContaining('PANTONE 6198 U'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _SnapshotCatalogController extends WalkaCatalogController {
  _SnapshotCatalogController(this.current) : super.presentationProxy();

  final WalkaCatalogSnapshot current;

  @override
  WalkaCatalogSnapshot get snapshot => current;

  @override
  bool get isLoading => false;

  @override
  bool get isOffline => false;

  @override
  bool get isUsingCache => false;

  @override
  bool get isUsingBundledFallback => false;
}
