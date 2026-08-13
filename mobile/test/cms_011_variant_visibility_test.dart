import 'package:flutter_test/flutter_test.dart';
import 'package:walka/features/catalog/catalog_presentation.dart';
import 'package:walka/features/catalog/data/walka_bundled_catalog.dart';
import 'package:walka/features/catalog/domain/walka_catalog.dart';

void main() {
  test('governed stable variant omission remains valid and is not resurrected', () {
    final WalkaCatalogSnapshot bundled = WalkaBundledCatalog.snapshot();
    final WalkaCatalogProduct lunch =
        bundled.productById('stainless-steel-bento-lunch-box')!;

    final WalkaCatalogProduct governedLunch = WalkaCatalogProduct(
      id: lunch.id,
      name: lunch.name,
      category: lunch.category,
      features: lunch.features,
      facts: lunch.facts,
      variants: lunch.variants
          .where((WalkaCatalogVariant variant) => variant.id != 'lunch-box:green')
          .toList(growable: false),
      shortDescription: lunch.shortDescription,
      highlights: lunch.highlights,
      featured: lunch.featured,
      presentationOrder: lunch.presentationOrder,
    );

    final WalkaCatalogSnapshot governed = WalkaCatalogSnapshot(
      config: bundled.config,
      products: <WalkaCatalogProduct>[governedLunch],
      source: WalkaCatalogSource.remote,
      fetchedAt: DateTime.utc(2026, 8, 13),
    );

    expect(() => WalkaCatalogContract.validate(governed), returnsNormally);

    final WalkaCatalogSnapshot presentation =
        walkaPresentationSnapshot(governed);
    expect(presentation.variantById('lunch-box:green'), isNull);
    expect(
      presentation.variants.map((WalkaCatalogVariant variant) => variant.id),
      <String>['lunch-box:blue', 'lunch-box:pink'],
    );
  });

  test('visible product with no visible variants fails closed', () {
    final WalkaCatalogSnapshot bundled = WalkaBundledCatalog.snapshot();
    final WalkaCatalogProduct drawer = bundled.productById('drawer-organizer')!;

    final WalkaCatalogSnapshot invalid = WalkaCatalogSnapshot(
      config: bundled.config,
      products: <WalkaCatalogProduct>[
        WalkaCatalogProduct(
          id: drawer.id,
          name: drawer.name,
          category: drawer.category,
          features: drawer.features,
          facts: drawer.facts,
          variants: const <WalkaCatalogVariant>[],
          presentationOrder: drawer.presentationOrder,
        ),
      ],
      source: WalkaCatalogSource.remote,
      fetchedAt: DateTime.utc(2026, 8, 13),
    );

    expect(
      () => WalkaCatalogContract.validate(invalid),
      throwsA(isA<FormatException>()),
    );
  });

  test('server-authored variant identity still fails closed', () {
    final WalkaCatalogSnapshot bundled = WalkaBundledCatalog.snapshot();
    final WalkaCatalogProduct drawer = bundled.productById('drawer-organizer')!;
    final WalkaCatalogVariant source = drawer.variants.first;

    final WalkaCatalogSnapshot invalid = WalkaCatalogSnapshot(
      config: bundled.config,
      products: <WalkaCatalogProduct>[
        WalkaCatalogProduct(
          id: drawer.id,
          name: drawer.name,
          category: drawer.category,
          features: drawer.features,
          facts: drawer.facts,
          variants: <WalkaCatalogVariant>[
            WalkaCatalogVariant(
              id: 'drawer-organizer:server-authored',
              color: source.color,
              asin: source.asin,
              purchaseUrl: source.purchaseUrl,
              presentationOrder: 0,
            ),
          ],
          presentationOrder: drawer.presentationOrder,
        ),
      ],
      source: WalkaCatalogSource.remote,
      fetchedAt: DateTime.utc(2026, 8, 13),
    );

    expect(
      () => WalkaCatalogContract.validate(invalid),
      throwsA(isA<FormatException>()),
    );
  });

  test('variant presentation order parses additively with legacy default', () {
    final WalkaCatalogVariant source =
        WalkaBundledCatalog.snapshot().variants.first;

    final Map<String, dynamic> governedJson = source.toJson()
      ..['presentation_order'] = 7;
    expect(
      WalkaCatalogVariant.fromJson(governedJson).presentationOrder,
      7,
    );

    final Map<String, dynamic> legacyJson = source.toJson()
      ..remove('presentation_order');
    expect(
      WalkaCatalogVariant.fromJson(legacyJson).presentationOrder,
      0,
    );
  });
}
