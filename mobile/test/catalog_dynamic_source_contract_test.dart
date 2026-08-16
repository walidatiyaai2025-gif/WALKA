import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production catalog source cannot regress to compiled product data', () {
    final String bundled = File(
      'lib/features/catalog/data/walka_bundled_catalog.dart',
    ).readAsStringSync();
    final String repository = File(
      'lib/features/catalog/data/walka_catalog_repository.dart',
    ).readAsStringSync();
    final String presentation = File(
      'lib/features/catalog/catalog_presentation.dart',
    ).readAsStringSync();
    final String commerce = File(
      'lib/features/commerce/amazon_purchase.dart',
    ).readAsStringSync();

    expect(bundled, isNot(contains('WalkaCatalogProduct(')));
    expect(bundled, isNot(contains('WalkaCatalogVariant(')));
    expect(bundled, isNot(contains('drawer-organizer')));
    expect(bundled, isNot(contains('lunch-box:')));
    expect(repository, isNot(contains('WalkaBundledCatalog')));
    expect(repository, contains('WalkaCatalogUnavailableException'));
    expect(presentation, isNot(contains('drawer-organizer')));
    expect(presentation, isNot(contains('lunch-box:')));
    expect(RegExp(r'B0[A-Z0-9]{8}').hasMatch(commerce), isFalse,
        reason: 'Production commerce must never embed an ASIN literal.');
  });

  test('production storefront is routed through Dashboard-driven generic catalog', () {
    final String storefront = File(
      'lib/features/storefront/storefront_resilient_v130.dart',
    ).readAsStringSync();
    final String shell = File(
      'lib/features/storefront/storefront_v102.dart',
    ).readAsStringSync();

    expect(storefront, contains('WalkaDynamicHomeV140'));
    expect(storefront, contains('WalkaDynamicSearchV140'));
    expect(storefront, contains('WalkaDynamicCategoriesV140'));
    expect(shell, contains('WalkaDynamicFavoritesV140'));
  });

  test('backend runtime repository does not read the bootstrap seed blueprint', () {
    final String backendRepository = File(
      '../backend/app/Repositories/EloquentCatalogRepository.php',
    ).readAsStringSync();
    final String publicController = File(
      '../backend/app/Http/Controllers/Api/V1/CatalogController.php',
    ).readAsStringSync();

    expect(backendRepository, isNot(contains('WalkaCatalogSeed')));
    expect(publicController, isNot(contains('WalkaCatalogSeed')));
    expect(backendRepository, contains("where('is_visible', true)"));
    expect(publicController, contains("where('is_visible', true)"));
  });
}
