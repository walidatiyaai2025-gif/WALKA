import 'package:flutter_test/flutter_test.dart';
import 'package:walka/core/api/walka_api_client.dart';
import 'package:walka/features/catalog/data/walka_bundled_catalog.dart';
import 'package:walka/features/catalog/data/walka_catalog_cache.dart';
import 'package:walka/features/catalog/data/walka_catalog_repository.dart';
import 'package:walka/features/catalog/domain/walka_catalog.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 8, 16, 1, 0);

  test('compatibility initial snapshot contains no static catalog entities', () {
    final WalkaCatalogSnapshot snapshot = WalkaBundledCatalog.snapshot(
      fetchedAt: now,
    );

    expect(snapshot.source, WalkaCatalogSource.unavailable);
    expect(snapshot.products, isEmpty);
    expect(snapshot.categories, isEmpty);
    expect(snapshot.variants, isEmpty);
    expect(snapshot.isAvailable, isFalse);
  });

  test('arbitrary remote Dashboard catalog wins and becomes LKG cache', () async {
    final _MemoryCache cache = _MemoryCache();
    final WalkaCatalogSnapshot remoteSnapshot = _dynamicSnapshot(
      fetchedAt: now,
      productId: 'desk-kit',
      productName: 'Desk Kit Pro',
      categoryId: 'workspace',
      categoryName: 'Workspace Essentials',
      variantId: 'desk-kit:midnight',
      color: 'Midnight',
      swatchHex: '#102030',
      asin: 'B012345678',
    );
    final _FakeRemote remote = _FakeRemote.fromSnapshot(remoteSnapshot);
    final WalkaCatalogRepository repository = WalkaCatalogRepository(
      cache: cache,
      remote: remote,
      clock: () => now,
    );

    final WalkaCatalogSnapshot result = await repository.load();

    expect(result.source, WalkaCatalogSource.remote);
    expect(result.fetchedAt, now);
    expect(result.productById('desk-kit')?.name, 'Desk Kit Pro');
    expect(result.categoryById('workspace')?.name, 'Workspace Essentials');
    expect(result.variantById('desk-kit:midnight')?.color, 'Midnight');
    expect(result.variantById('desk-kit:midnight')?.swatchHex, '#102030');
    expect(result.variantById('desk-kit:midnight')?.asin, 'B012345678');
    expect(cache.written?.source, WalkaCatalogSource.remote);
    expect(remote.configCalls, 1);
    expect(remote.catalogCalls, 1);
  });

  test('remote failure falls back only to a valid last-known-good cache', () async {
    final WalkaCatalogSnapshot cached = _dynamicSnapshot(
      fetchedAt: now.subtract(const Duration(hours: 6)),
    ).asSource(WalkaCatalogSource.cache);
    final _MemoryCache cache = _MemoryCache()..stored = cached;
    final WalkaCatalogRepository repository = WalkaCatalogRepository(
      cache: cache,
      remote: _FakeRemote.failure(now),
      clock: () => now,
    );

    final WalkaCatalogSnapshot result = await repository.load();

    expect(result.source, WalkaCatalogSource.cache);
    expect(result.isStale, isTrue);
    expect(result.fetchedAt, cached.fetchedAt);
    expect(result.productById('dynamic-product'), isNotNull);
  });

  test('fresh-install offline failure does not invent a built-in catalog', () async {
    final WalkaCatalogRepository repository = WalkaCatalogRepository(
      cache: _MemoryCache(),
      remote: _FakeRemote.failure(now),
      clock: () => now,
    );

    await expectLater(
      repository.load(),
      throwsA(isA<WalkaCatalogUnavailableException>()),
    );
  });

  test('corrupted cache does not resurrect static products', () async {
    final WalkaCatalogRepository repository = WalkaCatalogRepository(
      cache: _ThrowingCache(),
      remote: _FakeRemote.failure(now),
      clock: () => now,
    );

    await expectLater(
      repository.load(),
      throwsA(isA<WalkaCatalogUnavailableException>()),
    );
  });

  test('remote metadata mismatch is rejected before replacing LKG cache', () async {
    final WalkaCatalogSnapshot cached = _dynamicSnapshot(
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

  test('remote product without a visible variant fails closed', () async {
    final WalkaCatalogSnapshot source = _dynamicSnapshot(fetchedAt: now);
    final WalkaCatalogProduct product = source.products.single;
    final WalkaCatalogProduct broken = WalkaCatalogProduct(
      id: product.id,
      name: product.name,
      category: product.category,
      features: product.features,
      facts: product.facts,
      variants: const <WalkaCatalogVariant>[],
    );
    final _FakeRemote remote = _FakeRemote(
      config: source.config,
      payload: WalkaCatalogPayload(
        products: <WalkaCatalogProduct>[broken],
        categories: source.categories,
        release: source.config.release,
        apiVersion: source.config.apiVersion,
        purchaseMode: source.config.purchaseMode,
      ),
    );
    final WalkaCatalogRepository repository = WalkaCatalogRepository(
      cache: _MemoryCache(),
      remote: remote,
      clock: () => now,
    );

    await expectLater(
      repository.load(),
      throwsA(isA<WalkaCatalogUnavailableException>()),
    );
  });
}

WalkaCatalogSnapshot _dynamicSnapshot({
  required DateTime fetchedAt,
  String productId = 'dynamic-product',
  String productName = 'Dynamic Product',
  String categoryId = 'dynamic-category',
  String categoryName = 'Dynamic Category',
  String variantId = 'dynamic-product:custom',
  String color = 'Custom Color',
  String swatchHex = '#445566',
  String asin = 'B000000001',
}) {
  final WalkaCatalogCategory category = WalkaCatalogCategory(
    id: categoryId,
    name: categoryName,
    sortOrder: 0,
  );
  return WalkaCatalogSnapshot(
    config: const WalkaStorefrontConfig(
      brand: 'WALKA',
      release: 'dynamic-test',
      apiVersion: 'v1',
      purchaseMode: 'amazon_redirect',
    ),
    categories: <WalkaCatalogCategory>[category],
    products: <WalkaCatalogProduct>[
      WalkaCatalogProduct(
        id: productId,
        name: productName,
        category: categoryId,
        features: const <String>['Dashboard managed'],
        facts: const <String, dynamic>{'source': 'dashboard'},
        variants: <WalkaCatalogVariant>[
          WalkaCatalogVariant(
            id: variantId,
            color: color,
            asin: asin,
            swatchHex: swatchHex,
            purchaseUrl: 'https://www.amazon.com/dp/$asin',
          ),
        ],
      ),
    ],
    source: WalkaCatalogSource.remote,
    fetchedAt: fetchedAt,
  );
}

class _FakeRemote implements WalkaCatalogRemoteDataSource {
  _FakeRemote({required this.config, required this.payload}) : shouldFail = false;

  factory _FakeRemote.fromSnapshot(WalkaCatalogSnapshot snapshot) {
    return _FakeRemote(
      config: snapshot.config,
      payload: WalkaCatalogPayload(
        products: snapshot.products,
        categories: snapshot.categories,
        release: snapshot.config.release,
        apiVersion: snapshot.config.apiVersion,
        purchaseMode: snapshot.config.purchaseMode,
      ),
    );
  }

  factory _FakeRemote.failure(DateTime now) {
    return _FakeRemote.fromSnapshot(_dynamicSnapshot(fetchedAt: now))
      ..shouldFail = true;
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
      categories: payload.categories,
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
