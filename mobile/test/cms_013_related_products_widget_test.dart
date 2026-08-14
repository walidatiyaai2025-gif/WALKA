import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/features/catalog/data/walka_bundled_catalog.dart';
import 'package:walka/features/catalog/domain/walka_catalog.dart';
import 'package:walka/features/products/presentation/widgets/walka_pdp_related_products.dart';

void main() {
  test('related resolver drops a product absent from the visible catalog snapshot', () {
    final WalkaCatalogSnapshot bundled = WalkaBundledCatalog.snapshot();
    final WalkaCatalogProduct drawer = bundled.productById('drawer-organizer')!;
    final WalkaCatalogSnapshot visibleDrawerOnly = WalkaCatalogSnapshot(
      config: bundled.config,
      products: <WalkaCatalogProduct>[drawer],
      source: WalkaCatalogSource.remote,
      fetchedAt: DateTime.utc(2026, 8, 14),
    );

    final List<WalkaCatalogProduct> resolved =
        walkaResolveVisibleRelatedProducts(
      catalog: visibleDrawerOnly,
      relatedProductIds: const <String>[
        'stainless-steel-bento-lunch-box',
      ],
    );

    expect(resolved, isEmpty);
  });

  test('related resolver preserves CMS order for visible product IDs', () {
    final WalkaCatalogSnapshot bundled = WalkaBundledCatalog.snapshot();

    final List<WalkaCatalogProduct> resolved =
        walkaResolveVisibleRelatedProducts(
      catalog: bundled,
      relatedProductIds: const <String>[
        'stainless-steel-bento-lunch-box',
        'drawer-organizer',
      ],
    );

    expect(
      resolved.map((WalkaCatalogProduct product) => product.id).toList(),
      <String>['stainless-steel-bento-lunch-box', 'drawer-organizer'],
    );
  });

  testWidgets('related product card opens only through compiled callback', (
    WidgetTester tester,
  ) async {
    final WalkaCatalogProduct lunch = WalkaBundledCatalog.snapshot()
        .productById('stainless-steel-bento-lunch-box')!;
    String? openedProductId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: WalkaPdpRelatedProducts(
              products: <WalkaCatalogProduct>[lunch],
              onOpen: (String productId) => openedProductId = productId,
            ),
          ),
        ),
      ),
    );

    expect(find.text('YOU MAY ALSO LIKE'), findsOneWidget);
    expect(find.text(lunch.name), findsOneWidget);
    expect(find.byKey(const ValueKey<String>(
      'related-product-stainless-steel-bento-lunch-box',
    )), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>(
      'related-product-stainless-steel-bento-lunch-box',
    )));
    await tester.pump();

    expect(openedProductId, 'stainless-steel-bento-lunch-box');
  });
}
