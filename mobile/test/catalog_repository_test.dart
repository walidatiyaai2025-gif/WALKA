import 'package:flutter_test/flutter_test.dart';
import 'package:walka/core/api/walka_api_client.dart';
import 'package:walka/features/catalog/data/walka_bundled_catalog.dart';
import 'package:walka/features/catalog/data/walka_catalog_cache.dart';
import 'package:walka/features/catalog/data/walka_catalog_repository.dart';
import 'package:walka/features/catalog/domain/walka_catalog.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 8, 10, 1, 0);

  test('bundled fallback mirrors the current Product Master contract', () {
    final WalkaCatalogSnapshot snapshot = WalkaBundledCatalog.snapshot(
      fetchedAt: now,
    );

    expect(snapshot.source, WalkaCatalogSource.bundled);
    expect(snapshot.variants.length, 5);
    expect(
      snapshot.variants.map((WalkaCatalogVariant item) => item.id).toSet(),
      WalkaCatalogContract.requiredVariantIds,
    );

    final WalkaCatalogProduct drawer = snapshot.productById('drawer-organizer')!;
    expect(drawer.facts['material'], 'Plastic');
    expect(drawer.facts['expandable_width_in'], 22.4);
    expect(drawer.facts.containsKey('product_weight_lb'), isFalse);
    expect(drawer.facts.containsKey('packaging_in'), isFalse);

    final WalkaCatalogProduct lunch =
        snapshot.productById('stainless-steel-bento-lunch-box')!;
    expect(lunch.facts['outer_body'], 'Food-grade PP');
    expect(
      (lunch.facts['care'] as Map<String, String>)['lid_and_gasket'],
      'Dishwasher safe on the top rack; not microwave safe.',
    );
    expect(
      lunch.variants.map((WalkaCatalogVariant item) => item.pantone).toList(),
      <String?>['PANTONE 4155 U', 'PANTONE 9242 U', 'PANTONE 6198 U'],
    );
  });

  test('valid remote catalog wins and becomes last-known-good cache', () async {
    final _MemoryCache cache = _MemoryCache();
    final WalkaCatalogSnapshot bundled = WalkaBundledCatalog.snapshot(
      fetchedAt: now,
    );
    final _FakeRemote remote = _FakeRemote.fromSnapshot(bundled);
    final WalkaCatalogRepository repository = WalkaCatalogRepository(
      cache: cache,
      remote: remote,
      clock: () => now,
    );

    final WalkaCatalogSnapshot result = await repository.load();

    expect(result.source, WalkaCatalogSource.remote);
    expect(result.fetchedAt, now);
    expect(result.variantById('lunch-box:green')?.asin, 'B0GPZNKF9F');
    expect(cache.written?.source, WalkaCatalogSource.remote);
    expect(remote.configCalls, 1);
    expect(remote.catalogCalls, 1);
  });

  test('remote failure falls back to a valid last-known-good cache', () async {
    final WalkaCatalogSnapshot cached = WalkaBundledCatalog.snapshot(
      fetchedAt: now.subtract(const Duration(hours: 6)),
    ).asSource(WalkaCatalogSource.cache);
    final _MemoryCache cache = _MemoryCache()..stored = cached;
    final WalkaCatalogRepository repository = WalkaCatalogRepository(
      cache: cache,
      remote: _FakeRemote.failure(),
      clock: () => now,
    );

    final WalkaCatalogSnapshot result = await repository.load();

    expect(result.source, WalkaCatalogSource.cache);
    expect(result.isStale, isTrue);
    expect(result.fetchedAt, cached.fetchedAt);
    expect(result.variants.length, 5);
  });

  test('fresh-install offline failure uses bundled catalog', () async {
    final WalkaCatalogRepository repository = WalkaCatalogRepository(
      cache: _MemoryCache(),
      remote: _FakeRemote.failure(),
      clock: () => now,
    );

    final WalkaCatalogSnapshot result = await repository.load();

    expect(result.source, WalkaCatalogSource.bundled);
    expect(result.fetchedAt, now);
    expect(result.variants.length, 5);
  });

  test('corrupted cache safely falls back to bundled catalog', () async {
    final WalkaCatalogRepository repository = WalkaCatalogRepository(
      cache: _ThrowingCache(),
      remote: _FakeRemote.failure(),
      clock: () => now,
    );

    final WalkaCatalogSnapshot result = await repository.load();

    expect(result.source, WalkaCatalogSource.bundled);
    expect(result.variantById('drawer-organizer:white')?.asin, 'B0FQN4DCTG');
  });

  test('remote metadata mismatch is rejected before replacing cache', () async {
    final WalkaCatalogSnapshot cached = WalkaBundledCatalog.snapshot(
      fetchedAt: now.subtract(const Duration(days: 1)),
    ).asSource(WalkaCatalogSource.cache);
    final _MemoryCache cache = _MemoryCache()..stored = cached;
    final _FakeRemote remote = _FakeRemote.fromSnapshot(cached)
      ..catalogReleaseOverride = '9.9.9';
    final WalkaCatalogRepository repository = WalkaCatalogRepository(
      cache: cache,
      remote: remote,
      clock: () => now,
    );

    final WalkaCatalogSnapshot result = await repository.load();

    expect(result.source, WalkaCatalogSource.cache);
    expect(cache.writeCount, 0);
  });

  test('remote catalog may omit a governed stable variant as hidden', () async {
    final WalkaCatalogSnapshot bundled = WalkaBundledCatalog.snapshot(
      fetchedAt: now,
    );
    final List<WalkaCatalogProduct> governedProducts = bundled.products.map(
      (WalkaCatalogProduct product) {
        if (product.id != 'stainless-steel-bento-lunch-box') return product;
        return WalkaCatalogProduct(
          id: product.id,
          name: product.name,
          category: product.category,
          features: product.features,
          facts: product.facts,
          variants: product.variants
              .where((WalkaCatalogVariant variant) => variant.id != 'lunch-box:green')
              .toList(growable: false),
          shortDescription: product.shortDescription,
          highlights: product.highlights,
          featured: product.featured,
          presentationOrder: product.presentationOrder,
        );
      },
    ).toList(growable: false);

    final _MemoryCache cache = _MemoryCache();
    final _FakeRemote remote = _FakeRemote(
      config: bundled.config,
      payload: WalkaCatalogPayload(
        products: governedProducts,
        release: bundled.config.release,
        apiVersion: bundled.config.apiVersion,
        purchaseMode: bundled.config.purchaseMode,
      ),
    );
    final WalkaCatalogRepository repository = WalkaCatalogRepository(
      cache: cache,
      remote: remote,
      clock: () => now,
    );

    final WalkaCatalogSnapshot result = await repository.load();

    expect(result.source, WalkaCatalogSource.remote);
    expect(result.variantById('lunch-box:green'), isNull);
    expect(result.variantById('lunch-box:blue'), isNotNull);
    expect(cache.writeCount, 1);
  });
}

class _FakeRemote implements WalkaCatalogRemoteDataSource {
  _FakeRemote({required this.config, required this.payload}) : shouldFail = false;

  factory _FakeRemote.fromSnapshot(WalkaCatalogSnapshot snapshot) {
    return _FakeRemote(
      config: snapshot.config,
      payload: WalkaCatalogPayload(
        products: snapshot.products,
        release: snapshot.config.release,
        apiVersion: snapshot.config.apiVersion,
        purchaseMode: snapshot.config.purchaseMode,
      ),
    );
  }

  factory _FakeRemote.failure() {
    final WalkaCatalogSnapshot snapshot = WalkaBundledCatalog.snapshot();
    return _FakeRemote.fromSnapshot(snapshot)..shouldFail = true;
  }

  final WalkaStorefrontConfig config;
  final WalkaCatalogPayload payload;
  bool shouldFail;
  String? catalogReleaseOverride;
  int configCalls = 0;
  int catalogCalls = 0;

  @override
  Future<WalkaStorefrontConfig> fetchConfig() async {
    configCalls++;
    if (shouldFail) throw const WalkaApiException('offline');
    return config;
  }

  @override
  Future<WalkaCatalogPayload> fetchCatalog() async {
    catalogCalls++;
    if (shouldFail) throw const WalkaApiException('offline');
    return WalkaCatalogPayload(
      products: payload.products,
      release: catalogReleaseOverride ?? payload.release,
      apiVersion: payload.apiVersion,
      purchaseMode: payload.purchaseMode,
    );
  }
}

class _MemoryCache implements WalkaCatalogCache {
  WalkaCatalogSnapshot? stored;
  WalkaCatalogSnapshot? written;
  int writeCount = 0;

  @override
  Future<WalkaCatalogSnapshot?> read() async => stored;

  @override
  Future<void> write(WalkaCatalogSnapshot snapshot) async {
    writeCount++;
    written = snapshot;
    stored = snapshot.asSource(WalkaCatalogSource.cache);
  }

  @override
  Future<void> clear() async {
    stored = null;
  }
}

class _ThrowingCache implements WalkaCatalogCache {
  @override
  Future<WalkaCatalogSnapshot?> read() async {
    throw const FormatException('corrupt cache');
  }

  @override
  Future<void> write(WalkaCatalogSnapshot snapshot) async {
    throw StateError('cache unavailable');
  }

  @override
  Future<void> clear() async {}
}
