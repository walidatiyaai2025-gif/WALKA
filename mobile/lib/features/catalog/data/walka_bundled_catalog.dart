import '../domain/walka_catalog.dart';

/// Compatibility factory for callers that need an initial catalog state.
///
/// It intentionally contains no products, categories, colors, ASINs or other
/// catalog entities. Production catalog truth comes only from the remote API
/// or a previously validated last-known-good cache snapshot.
abstract final class WalkaBundledCatalog {
  static WalkaCatalogSnapshot snapshot({DateTime? fetchedAt}) {
    return WalkaCatalogSnapshot(
      config: const WalkaStorefrontConfig(
        brand: 'WALKA',
        release: 'unavailable',
        apiVersion: 'v1',
        purchaseMode: 'amazon_redirect',
      ),
      categories: const <WalkaCatalogCategory>[],
      products: const <WalkaCatalogProduct>[],
      source: WalkaCatalogSource.unavailable,
      fetchedAt: (fetchedAt ?? DateTime.now()).toUtc(),
    );
  }
}
