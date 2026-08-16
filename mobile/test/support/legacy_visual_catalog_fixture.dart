import 'package:walka/features/catalog/domain/walka_catalog.dart';

/// Test-only fixture for legacy visual/reference suites.
///
/// This file lives outside `lib/` and is never compiled into the production
/// APK. Runtime catalog truth remains Dashboard/DB/API -> LKG cache only.
WalkaCatalogSnapshot legacyVisualCatalogFixture() {
  const WalkaStorefrontConfig config = WalkaStorefrontConfig(
    brand: 'WALKA',
    release: '1.4.0-test-fixture',
    apiVersion: 'v1',
    purchaseMode: 'amazon_redirect',
  );
  const List<WalkaCatalogCategory> categories = <WalkaCatalogCategory>[
    WalkaCatalogCategory(
      id: 'drawer-organization',
      name: 'Drawer Organization',
      sortOrder: 0,
    ),
    WalkaCatalogCategory(id: 'lunch', name: 'Lunch', sortOrder: 1),
  ];

  return WalkaCatalogSnapshot(
    config: config,
    categories: categories,
    products: const <WalkaCatalogProduct>[
      WalkaCatalogProduct(
        id: 'drawer-organizer',
        name: 'WALKA Drawer Organizer',
        category: 'drawer-organization',
        features: <String>[
          '8 compartments',
          'Expandable to 22.4 in',
          'Non-slip base',
        ],
        facts: <String, dynamic>{
          'material': 'Plastic',
          'compartments': 8,
          'expandable_width_in': 22.4,
        },
        variants: <WalkaCatalogVariant>[
          WalkaCatalogVariant(
            id: 'drawer-organizer:white',
            color: 'White',
            asin: 'B0FQN4DCTG',
            swatchHex: '#F6F3EC',
            purchaseUrl: 'https://www.amazon.com/dp/B0FQN4DCTG',
          ),
          WalkaCatalogVariant(
            id: 'drawer-organizer:gray',
            color: 'Gray',
            asin: 'B0FQN4L2ZD',
            swatchHex: '#E1E4E7',
            purchaseUrl: 'https://www.amazon.com/dp/B0FQN4L2ZD',
          ),
        ],
      ),
      WalkaCatalogProduct(
        id: 'stainless-steel-bento-lunch-box',
        name: 'WALKA Large Stainless Steel Bento Lunch Box for Adults',
        category: 'lunch',
        features: <String>[
          '1200 ml',
          '4 compartments',
          'SUS304 stainless steel food tray',
          'Food-grade PP outer body',
        ],
        facts: <String, dynamic>{
          'capacity_ml': 1200,
          'food_tray': 'SUS304 stainless steel',
          'compartments': 4,
          'outer_body': 'Food-grade PP',
        },
        variants: <WalkaCatalogVariant>[
          WalkaCatalogVariant(
            id: 'lunch-box:blue',
            color: 'Blue',
            asin: 'B0FQN4L8MW',
            pantone: 'PANTONE 4155 U',
            swatchHex: '#436B73',
            purchaseUrl: 'https://www.amazon.com/dp/B0FQN4L8MW',
          ),
          WalkaCatalogVariant(
            id: 'lunch-box:pink',
            color: 'Pink',
            asin: 'B0FQN3W4SF',
            pantone: 'PANTONE 9242 U',
            swatchHex: '#E7C2C7',
            purchaseUrl: 'https://www.amazon.com/dp/B0FQN3W4SF',
          ),
          WalkaCatalogVariant(
            id: 'lunch-box:green',
            color: 'Green',
            asin: 'B0GPZNKF9F',
            pantone: 'PANTONE 6198 U',
            swatchHex: '#B9B995',
            purchaseUrl: 'https://www.amazon.com/dp/B0GPZNKF9F',
          ),
        ],
      ),
    ],
    source: WalkaCatalogSource.remote,
    fetchedAt: DateTime.utc(2026, 8, 16),
  );
}
