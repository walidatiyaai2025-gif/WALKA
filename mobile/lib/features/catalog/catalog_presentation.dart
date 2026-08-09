import 'domain/walka_catalog.dart';

const List<String> _releasedVariantOrder = <String>[
  'drawer-organizer:white',
  'drawer-organizer:gray',
  'lunch-box:blue',
  'lunch-box:pink',
  'lunch-box:green',
];

/// Adapts API/domain catalog data into the released Flutter 1.0 presentation
/// contract without binding widgets to server-controlled display copy/order.
WalkaCatalogSnapshot walkaPresentationSnapshot(WalkaCatalogSnapshot source) {
  final Map<String, WalkaCatalogProduct> productsById = <String, WalkaCatalogProduct>{
    for (final WalkaCatalogProduct product in source.products) product.id: product,
  };
  final Map<String, WalkaCatalogVariant> variantsById = <String, WalkaCatalogVariant>{
    for (final WalkaCatalogVariant variant in source.variants) variant.id: variant,
  };

  final WalkaCatalogProduct drawer = productsById['drawer-organizer']!;
  final WalkaCatalogProduct lunch =
      productsById['stainless-steel-bento-lunch-box']!;

  final List<WalkaCatalogVariant> drawerVariants = _releasedVariantOrder
      .where((String id) => id.startsWith('drawer-organizer:'))
      .map((String id) => variantsById[id]!)
      .toList(growable: false);
  final List<WalkaCatalogVariant> lunchVariants = _releasedVariantOrder
      .where((String id) => id.startsWith('lunch-box:'))
      .map((String id) => variantsById[id]!)
      .toList(growable: false);

  return WalkaCatalogSnapshot(
    config: source.config,
    products: <WalkaCatalogProduct>[
      WalkaCatalogProduct(
        id: drawer.id,
        name: 'Expandable Drawer Organizer',
        category: drawer.category,
        features: drawer.features,
        facts: drawer.facts,
        variants: drawerVariants,
      ),
      WalkaCatalogProduct(
        id: lunch.id,
        name: 'Large Stainless Steel Bento Lunch Box',
        category: lunch.category,
        features: lunch.features,
        facts: lunch.facts,
        variants: lunchVariants,
      ),
    ],
    source: source.source,
    fetchedAt: source.fetchedAt,
  );
}
