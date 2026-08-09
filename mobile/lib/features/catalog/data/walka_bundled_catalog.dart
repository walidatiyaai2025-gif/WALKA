import '../domain/walka_catalog.dart';

abstract final class WalkaBundledCatalog {
  static WalkaCatalogSnapshot snapshot({DateTime? fetchedAt}) {
    final WalkaCatalogSnapshot snapshot = WalkaCatalogSnapshot(
      config: const WalkaStorefrontConfig(
        brand: 'WALKA',
        release: '1.1.0',
        apiVersion: 'v1',
        purchaseMode: 'amazon_redirect',
      ),
      products: <WalkaCatalogProduct>[
        WalkaCatalogProduct(
          id: 'drawer-organizer',
          name: 'WALKA Drawer Organizer',
          category: 'drawer-organization',
          features: const <String>[
            '8 compartments',
            'Expandable to 22.4 in',
            'Non-slip base',
          ],
          facts: const <String, dynamic>{
            'material': 'Plastic',
            'compartments': 8,
            'closed_size_in': <double>[13, 15, 2],
            'expandable_width_in': 22.4,
            'non_slip_base': true,
          },
          variants: const <WalkaCatalogVariant>[
            WalkaCatalogVariant(
              id: 'drawer-organizer:white',
              color: 'White',
              asin: 'B0FQN4DCTG',
              purchaseUrl: 'https://www.amazon.com/dp/B0FQN4DCTG',
            ),
            WalkaCatalogVariant(
              id: 'drawer-organizer:gray',
              color: 'Gray',
              asin: 'B0FQN4L2ZD',
              purchaseUrl: 'https://www.amazon.com/dp/B0FQN4L2ZD',
            ),
          ],
        ),
        WalkaCatalogProduct(
          id: 'stainless-steel-bento-lunch-box',
          name: 'WALKA Large Stainless Steel Bento Lunch Box for Adults',
          category: 'lunch',
          features: const <String>[
            '1200 ml',
            '4 compartments',
            'SUS304 stainless steel food tray',
            'Food-grade PP outer body',
            'Best suited for dry meals & snacks.',
          ],
          facts: const <String, dynamic>{
            'capacity_ml': 1200,
            'food_tray': 'SUS304 stainless steel',
            'compartments': 4,
            'outer_body': 'Food-grade PP',
            'lid': '4 clips with silicone gasket',
            'included': <String>[
              'Insulated carry bag',
              'Stainless sauce cup with lid',
              'Spoon',
              'Fork',
            ],
            'lunch_box_size_in': <double>[11.42, 8.66, 3.15],
            'with_bag_size_in': <double>[11.81, 8.86, 3.54],
            'bag_size_in': <double>[10.63, 7.48, 2.76],
            'weight_with_bag_lb': 1.84,
            'care': <String, String>{
              'sus304_tray': 'Dishwasher safe; not microwave safe.',
              'lid_and_gasket':
                  'Dishwasher safe on the top rack; not microwave safe.',
              'pp_outer_body':
                  'Microwave safe only after removing the stainless tray, lid, and silicone gasket.',
            },
            'usage_language': <String>[
              'Secure Lock | Helps Prevent Spills',
              'SPILL-RESISTANT DESIGN',
              'Best suited for dry meals & snacks.',
              'Not intended for liquids. Best for dry & semi-wet foods.',
              'Carry upright.',
            ],
          },
          variants: const <WalkaCatalogVariant>[
            WalkaCatalogVariant(
              id: 'lunch-box:blue',
              color: 'Blue',
              asin: 'B0FQN4L8MW',
              pantone: 'PANTONE 4155 U',
              purchaseUrl: 'https://www.amazon.com/dp/B0FQN4L8MW',
            ),
            WalkaCatalogVariant(
              id: 'lunch-box:pink',
              color: 'Pink',
              asin: 'B0FQN3W4SF',
              pantone: 'PANTONE 9242 U',
              purchaseUrl: 'https://www.amazon.com/dp/B0FQN3W4SF',
            ),
            WalkaCatalogVariant(
              id: 'lunch-box:green',
              color: 'Green',
              asin: 'B0GPZNKF9F',
              pantone: 'PANTONE 6198 U',
              purchaseUrl: 'https://www.amazon.com/dp/B0GPZNKF9F',
            ),
          ],
        ),
      ],
      source: WalkaCatalogSource.bundled,
      fetchedAt: (fetchedAt ?? DateTime.now()).toUtc(),
    );

    WalkaCatalogContract.validate(snapshot);
    return snapshot;
  }
}
