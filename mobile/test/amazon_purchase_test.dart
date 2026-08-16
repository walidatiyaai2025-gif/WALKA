import 'package:flutter_test/flutter_test.dart';
import 'package:walka/features/catalog/domain/walka_catalog.dart';
import 'package:walka/features/commerce/amazon_purchase.dart';

void main() {
  setUp(WalkaAmazonPurchaseRegistry.clearForTesting);

  test('purchase registry fails closed before a Dashboard catalog is loaded', () {
    expect(
      () => WalkaAmazonPurchaseRegistry.requireUriForVariant('desk-kit:midnight'),
      throwsStateError,
    );
  });

  test('purchase URL comes from an arbitrary Dashboard variant', () {
    WalkaAmazonPurchaseRegistry.replaceFromSnapshot(_snapshot(
      variantId: 'desk-kit:midnight',
      asin: 'B012345678',
    ));

    final Uri uri = WalkaAmazonPurchaseRegistry.requireUriForVariant(
      'desk-kit:midnight',
    );

    expect(uri, Uri.parse('https://www.amazon.com/dp/B012345678'));
  });

  test('replacing Dashboard snapshot removes stale variant purchase routes', () {
    WalkaAmazonPurchaseRegistry.replaceFromSnapshot(_snapshot(
      variantId: 'desk-kit:midnight',
      asin: 'B012345678',
    ));
    WalkaAmazonPurchaseRegistry.replaceFromSnapshot(_snapshot(
      variantId: 'travel-mug:sand',
      asin: 'B087654321',
    ));

    expect(
      WalkaAmazonPurchaseRegistry.uriForVariant('desk-kit:midnight'),
      isNull,
    );
    expect(
      WalkaAmazonPurchaseRegistry.requireUriForVariant('travel-mug:sand'),
      Uri.parse('https://www.amazon.com/dp/B087654321'),
    );
  });
}

WalkaCatalogSnapshot _snapshot({
  required String variantId,
  required String asin,
}) {
  const WalkaCatalogCategory category = WalkaCatalogCategory(
    id: 'workspace',
    name: 'Workspace',
    sortOrder: 0,
  );
  final String productId = variantId.split(':').first;

  return WalkaCatalogSnapshot(
    config: const WalkaStorefrontConfig(
      brand: 'WALKA',
      release: 'dynamic-test',
      apiVersion: 'v1',
      purchaseMode: 'amazon_redirect',
    ),
    categories: const <WalkaCatalogCategory>[category],
    products: <WalkaCatalogProduct>[
      WalkaCatalogProduct(
        id: productId,
        name: 'Dashboard Product',
        category: category.id,
        features: const <String>['Dashboard managed'],
        facts: const <String, dynamic>{'source': 'dashboard'},
        variants: <WalkaCatalogVariant>[
          WalkaCatalogVariant(
            id: variantId,
            color: 'Dynamic Color',
            asin: asin,
            swatchHex: '#123456',
            purchaseUrl: 'https://www.amazon.com/dp/$asin',
          ),
        ],
      ),
    ],
    source: WalkaCatalogSource.remote,
    fetchedAt: DateTime.utc(2026, 8, 16),
  );
}
