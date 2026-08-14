import 'package:flutter_test/flutter_test.dart';
import 'package:walka/features/catalog/data/walka_bundled_catalog.dart';
import 'package:walka/features/catalog/domain/walka_catalog.dart';
import 'package:walka/features/products/presentation/walka_pdp_model.dart';

void main() {
  test('product presentation fields parse additively with safe defaults', () {
    final WalkaCatalogSnapshot bundled = WalkaBundledCatalog.snapshot();
    final WalkaCatalogProduct source = bundled.products.first;

    final Map<String, dynamic> json = source.toJson()
      ..addAll(<String, dynamic>{
        'short_description': 'Remote governed description',
        'highlights': <String>['First highlight', 'Second highlight'],
        'featured': true,
        'presentation_order': 7,
      });

    final WalkaCatalogProduct parsed = WalkaCatalogProduct.fromJson(json);
    expect(parsed.shortDescription, 'Remote governed description');
    expect(parsed.highlights, <String>['First highlight', 'Second highlight']);
    expect(parsed.featured, isTrue);
    expect(parsed.presentationOrder, 7);

    final Map<String, dynamic> legacy = source.toJson()
      ..remove('short_description')
      ..remove('highlights')
      ..remove('featured')
      ..remove('presentation_order');
    final WalkaCatalogProduct legacyParsed = WalkaCatalogProduct.fromJson(legacy);
    expect(legacyParsed.shortDescription, isNull);
    expect(legacyParsed.highlights, isEmpty);
    expect(legacyParsed.featured, isFalse);
    expect(legacyParsed.presentationOrder, 0);
  });

  test('PDP editorial copy reuses CMS-010 product presentation source', () {
    final WalkaCatalogProduct source =
        WalkaBundledCatalog.snapshot().products.first;
    final WalkaCatalogProduct governed = WalkaCatalogProduct(
      id: source.id,
      name: source.name,
      category: source.category,
      features: source.features,
      shortDescription: 'Owner-authored Product Detail supporting copy.',
      highlights: const <String>[
        'Owner-authored Product Detail headline',
        'Additional catalog highlight',
      ],
      facts: source.facts,
      variants: source.variants,
    );

    final WalkaPdpEditorialCopy copy =
        WalkaPdpEditorialCopy.fromCatalogProduct(
      governed,
      fallbackTitle: 'Bundled title',
      fallbackBody: 'Bundled body',
    );

    expect(copy.title, 'Owner-authored Product Detail headline');
    expect(copy.body, 'Owner-authored Product Detail supporting copy.');

    final WalkaPdpEditorialCopy legacy =
        WalkaPdpEditorialCopy.fromCatalogProduct(
      source,
      fallbackTitle: 'Bundled title',
      fallbackBody: 'Bundled body',
    );
    expect(legacy.title, 'Bundled title');
    expect(legacy.body, 'Bundled body');
  });

  test('a hidden product may be absent while visible product identity remains strict', () {
    final WalkaCatalogSnapshot bundled = WalkaBundledCatalog.snapshot();
    final WalkaCatalogProduct drawer = bundled.productById('drawer-organizer')!;

    final WalkaCatalogSnapshot hiddenLunch = WalkaCatalogSnapshot(
      config: bundled.config,
      products: <WalkaCatalogProduct>[drawer],
      source: WalkaCatalogSource.remote,
      fetchedAt: DateTime.utc(2026, 8, 13),
    );

    expect(() => WalkaCatalogContract.validate(hiddenLunch), returnsNormally);
  });

  test('unknown product identities still fail closed', () {
    final WalkaCatalogSnapshot bundled = WalkaBundledCatalog.snapshot();
    final WalkaCatalogProduct source = bundled.products.first;
    final WalkaCatalogProduct unknown = WalkaCatalogProduct(
      id: 'server-authored-product',
      name: source.name,
      category: source.category,
      features: source.features,
      facts: source.facts,
      variants: source.variants,
    );

    final WalkaCatalogSnapshot snapshot = WalkaCatalogSnapshot(
      config: bundled.config,
      products: <WalkaCatalogProduct>[unknown],
      source: WalkaCatalogSource.remote,
      fetchedAt: DateTime.utc(2026, 8, 13),
    );

    expect(
      () => WalkaCatalogContract.validate(snapshot),
      throwsA(isA<FormatException>()),
    );
  });
}
