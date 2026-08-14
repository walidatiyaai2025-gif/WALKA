import 'package:flutter_test/flutter_test.dart';
import 'package:walka/features/catalog/data/walka_bundled_catalog.dart';
import 'package:walka/features/catalog/domain/walka_catalog.dart';
import 'package:walka/features/commerce/amazon_purchase.dart';
import 'package:walka/features/content/domain/walka_related_products_content.dart';

void main() {
  tearDown(WalkaAmazonPurchaseRegistry.clearForTesting);

  test('CMS related-product fields cannot inject or mutate Amazon destinations', () {
    final WalkaCatalogSnapshot catalog = WalkaBundledCatalog.snapshot(
      fetchedAt: DateTime.utc(2026, 8, 14),
    );
    WalkaAmazonPurchaseRegistry.replaceFromSnapshot(catalog);

    final Map<String, Uri> before = <String, Uri>{
      'drawer-white': amazonDrawerOrganizerUri(gray: false),
      'drawer-gray': amazonDrawerOrganizerUri(gray: true),
      'lunch-blue': amazonLunchBoxUri(WalkaAmazonLunchVariant.blue),
      'lunch-pink': amazonLunchBoxUri(WalkaAmazonLunchVariant.pink),
      'lunch-green': amazonLunchBoxUri(WalkaAmazonLunchVariant.green),
    };

    final WalkaRelatedProductsPayload payload =
        WalkaRelatedProductsPayload.fromApiJson(<String, dynamic>{
      'data': <String, dynamic>{
        'key': 'pdp.related_products',
        'type': 'pdp.related_products',
        'schema_version': 1,
        'revision': 16,
        'published_at': '2026-08-14T03:00:00Z',
        'payload': <String, dynamic>{
          'relationships': <Object>[
            <String, dynamic>{
              'product_id': 'drawer-organizer',
              'related_product_ids': <String>[
                'stainless-steel-bento-lunch-box',
              ],
              'url': 'https://attacker.invalid/checkout',
              'asin': 'REMOTE-MUTATION-NOT-ALLOWED',
              'purchase_url': 'https://attacker.invalid/buy',
            },
            <String, dynamic>{
              'product_id': 'stainless-steel-bento-lunch-box',
              'related_product_ids': <String>[],
            },
          ],
        },
      },
      'meta': <String, dynamic>{'api_version': 'v1'},
    });

    final Map<String, dynamic> normalized = payload.content.toJson();
    final Map<String, dynamic> firstRelationship =
        Map<String, dynamic>.from(normalized['relationships'][0] as Map);
    expect(
      firstRelationship.keys,
      <String>['product_id', 'related_product_ids'],
    );
    expect(firstRelationship, isNot(contains('url')));
    expect(firstRelationship, isNot(contains('asin')));
    expect(firstRelationship, isNot(contains('purchase_url')));

    expect(amazonDrawerOrganizerUri(gray: false), before['drawer-white']);
    expect(amazonDrawerOrganizerUri(gray: true), before['drawer-gray']);
    expect(
      amazonLunchBoxUri(WalkaAmazonLunchVariant.blue),
      before['lunch-blue'],
    );
    expect(
      amazonLunchBoxUri(WalkaAmazonLunchVariant.pink),
      before['lunch-pink'],
    );
    expect(
      amazonLunchBoxUri(WalkaAmazonLunchVariant.green),
      before['lunch-green'],
    );
  });

  test('non-Amazon catalog override is filtered and official compiled fallback wins', () {
    final WalkaCatalogSnapshot bundled = WalkaBundledCatalog.snapshot(
      fetchedAt: DateTime.utc(2026, 8, 14),
    );

    final List<WalkaCatalogProduct> products = bundled.products
        .map((WalkaCatalogProduct product) {
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
            pantone: variant.pantone,
            presentationOrder: variant.presentationOrder,
            purchaseUrl: 'https://attacker.invalid/not-amazon',
          );
        }).toList(growable: false),
        shortDescription: product.shortDescription,
        highlights: product.highlights,
        featured: product.featured,
        presentationOrder: product.presentationOrder,
      );
    }).toList(growable: false);

    WalkaAmazonPurchaseRegistry.replaceFromSnapshot(
      WalkaCatalogSnapshot(
        config: bundled.config,
        products: products,
        source: WalkaCatalogSource.remote,
        fetchedAt: DateTime.utc(2026, 8, 14),
      ),
    );

    final Uri white = amazonDrawerOrganizerUri(gray: false);
    expect(white.scheme, 'https');
    expect(white.host, 'www.amazon.com');
    expect(white.path, '/dp/$walkaDrawerOrganizerWhiteAsin');
    expect(white.toString(), isNot(contains('attacker.invalid')));
  });
}
