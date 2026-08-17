import 'package:flutter_test/flutter_test.dart';
import 'package:walka/features/catalog/domain/walka_catalog.dart';

void main() {
  test('catalog product parses optional short description and dynamic swatch', () {
    final WalkaCatalogProduct product = WalkaCatalogProduct.fromJson(
      <String, dynamic>{
        'id': 'travel-mug',
        'name': 'WALKA Travel Mug',
        'category': 'travel',
        'short_description': '  Built for everyday travel.  ',
        'features': <String>['Insulated'],
        'facts': <String, dynamic>{'capacity_ml': 500},
        'variants': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'travel-mug:sand',
            'color': 'Sand',
            'swatch_hex': '#C9B79C',
            'pantone': null,
            'asin': 'B012345670',
            'purchase_url': 'https://www.amazon.com/dp/B012345670',
          },
        ],
      },
    );

    expect(product.shortDescription, 'Built for everyday travel.');
    expect(product.variants.single.swatchHex, '#C9B79C');
    expect(product.toJson()['short_description'], 'Built for everyday travel.');
  });

  test('older cached catalog without short description remains compatible', () {
    final WalkaCatalogProduct product = WalkaCatalogProduct.fromJson(
      <String, dynamic>{
        'id': 'legacy-product',
        'name': 'Legacy Product',
        'category': 'legacy',
        'features': <String>[],
        'facts': <String, dynamic>{},
        'variants': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'legacy-product:default',
            'color': 'Default',
            'swatch_hex': null,
            'pantone': null,
            'asin': 'B012345671',
            'purchase_url': 'https://www.amazon.com/dp/B012345671',
          },
        ],
      },
    );

    expect(product.shortDescription, isNull);
  });

  test('malformed short description fails closed', () {
    expect(
      () => WalkaCatalogProduct.fromJson(
        <String, dynamic>{
          'id': 'bad-product',
          'name': 'Bad Product',
          'category': 'bad',
          'short_description': <String>['not text'],
          'features': <String>[],
          'facts': <String, dynamic>{},
          'variants': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'bad-product:default',
              'color': 'Default',
              'swatch_hex': '#000000',
              'pantone': null,
              'asin': 'B012345672',
              'purchase_url': 'https://www.amazon.com/dp/B012345672',
            },
          ],
        },
      ),
      throwsFormatException,
    );
  });
}
