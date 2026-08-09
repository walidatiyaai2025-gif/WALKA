import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:walka/features/catalog/remote_catalog.dart';

void main() {
  group('WalkaCatalogRepository', () {
    test('uses a validated remote snapshot and writes cache', () async {
      final _MemoryCache cache = _MemoryCache();
      final _FakeTransport transport = _FakeTransport(_validResponses());
      final WalkaCatalogRepository repository = _repository(
        transport: transport,
        cache: cache,
      );

      final WalkaCatalogSnapshot snapshot = await repository.load();

      expect(snapshot.source, WalkaCatalogSource.remote);
      expect(snapshot.release, '1.1.0');
      expect(snapshot.variants.length, 5);
      expect(snapshot.variantById(walkaDrawerWhiteVariantId)?.color, 'White');
      expect(snapshot.variantById(walkaLunchGreenVariantId)?.pantone,
          'PANTONE 6198 U');
      expect(cache.written?.source, WalkaCatalogSource.remote);
      expect(transport.paths, containsAll(<String>['/api/v1/config', '/api/v1/catalog']));
    });

    test('falls back to validated cache when remote transport fails', () async {
      final WalkaCatalogSnapshot cached = WalkaCatalogSnapshot.bundled().withSource(
        WalkaCatalogSource.cache,
      );
      final _MemoryCache cache = _MemoryCache(initial: cached);
      final WalkaCatalogRepository repository = _repository(
        transport: _ThrowingTransport(),
        cache: cache,
      );

      final WalkaCatalogSnapshot snapshot = await repository.load();

      expect(snapshot.source, WalkaCatalogSource.cache);
      expect(snapshot.variants.length, 5);
      expect(snapshot.variantById(walkaLunchPinkVariantId)?.asin, 'B0FQN3W4SF');
    });

    test('falls back to immutable bundle when remote and cache are unavailable',
        () async {
      final WalkaCatalogRepository repository = _repository(
        transport: _ThrowingTransport(),
        cache: _MemoryCache(),
      );

      final WalkaCatalogSnapshot snapshot = await repository.load();

      expect(snapshot.source, WalkaCatalogSource.bundled);
      expect(snapshot.variants.map((variant) => variant.id).toSet(),
          walkaRequiredVariantIds);
      expect(snapshot.productById(walkaDrawerProductId)?.facts.containsKey('weight_lb'),
          isFalse);
    });

    test('rejects unsafe remote Drawer facts instead of displaying them', () async {
      final Map<String, Map<String, dynamic>> responses = _validResponses();
      final Map<String, dynamic> catalog = _deepCopy(responses['/api/v1/catalog']!);
      final List<dynamic> products = catalog['data'] as List<dynamic>;
      final Map<String, dynamic> drawer = products.first as Map<String, dynamic>;
      (drawer['facts'] as Map<String, dynamic>)['weight_lb'] = 1.72;
      responses['/api/v1/catalog'] = catalog;

      final WalkaCatalogRepository repository = _repository(
        transport: _FakeTransport(responses),
        cache: _MemoryCache(),
      );

      final WalkaCatalogSnapshot snapshot = await repository.load();

      expect(snapshot.source, WalkaCatalogSource.bundled);
      expect(snapshot.productById(walkaDrawerProductId)?.facts.containsKey('weight_lb'),
          isFalse);
    });

    test('rejects remote Lunch care drift and keeps approved bundled guidance',
        () async {
      final Map<String, Map<String, dynamic>> responses = _validResponses();
      final Map<String, dynamic> catalog = _deepCopy(responses['/api/v1/catalog']!);
      final List<dynamic> products = catalog['data'] as List<dynamic>;
      final Map<String, dynamic> lunch = products[1] as Map<String, dynamic>;
      final Map<String, dynamic> facts = lunch['facts'] as Map<String, dynamic>;
      final Map<String, dynamic> care = facts['care'] as Map<String, dynamic>;
      care['lid_and_gasket'] = 'Hand wash.';
      responses['/api/v1/catalog'] = catalog;

      final WalkaCatalogSnapshot snapshot = await _repository(
        transport: _FakeTransport(responses),
        cache: _MemoryCache(),
      ).load();

      expect(snapshot.source, WalkaCatalogSource.bundled);
      final Map<String, dynamic> approvedCare = snapshot
          .productById(walkaLunchProductId)!
          .facts['care'] as Map<String, dynamic>;
      expect(
        approvedCare['lid_and_gasket'],
        'Dishwasher safe on the top rack; not microwave safe.',
      );
    });

    test('rejects non-Amazon or mismatched purchase destinations', () async {
      final Map<String, Map<String, dynamic>> responses = _validResponses();
      final Map<String, dynamic> catalog = _deepCopy(responses['/api/v1/catalog']!);
      final List<dynamic> products = catalog['data'] as List<dynamic>;
      final Map<String, dynamic> drawer = products.first as Map<String, dynamic>;
      final List<dynamic> variants = drawer['variants'] as List<dynamic>;
      (variants.first as Map<String, dynamic>)['purchase_url'] =
          'https://example.com/dp/B0FQN4DCTG';
      responses['/api/v1/catalog'] = catalog;

      final WalkaCatalogSnapshot snapshot = await _repository(
        transport: _FakeTransport(responses),
        cache: _MemoryCache(),
      ).load();

      expect(snapshot.source, WalkaCatalogSource.bundled);
      expect(
        snapshot.variantById(walkaDrawerWhiteVariantId)?.purchaseUri.host,
        'www.amazon.com',
      );
    });

    test('disabled API still uses cache without attempting network', () async {
      final _FakeTransport transport = _FakeTransport(_validResponses());
      final WalkaCatalogRepository repository = WalkaCatalogRepository(
        api: WalkaApiClient(baseUri: null, transport: transport),
        cache: _MemoryCache(
          initial: WalkaCatalogSnapshot.bundled().withSource(WalkaCatalogSource.cache),
        ),
      );

      final WalkaCatalogSnapshot snapshot = await repository.load();

      expect(snapshot.source, WalkaCatalogSource.cache);
      expect(transport.paths, isEmpty);
    });
  });

  test('catalog controller starts usable and upgrades atomically on refresh', () async {
    final WalkaCatalogController controller = WalkaCatalogController(
      _repository(
        transport: _FakeTransport(_validResponses()),
        cache: _MemoryCache(),
      ),
    );

    expect(controller.snapshot.source, WalkaCatalogSource.bundled);
    expect(controller.isRefreshing, isFalse);

    await controller.refresh();

    expect(controller.isRefreshing, isFalse);
    expect(controller.snapshot.source, WalkaCatalogSource.remote);
    expect(
      controller.purchaseUri(
        walkaLunchBlueVariantId,
        fallback: Uri.parse('https://fallback.invalid'),
      ).toString(),
      'https://www.amazon.com/dp/B0FQN4L8MW',
    );
  });

  test('cache snapshot round-trip keeps typed ids, facts and destinations', () {
    final WalkaCatalogSnapshot source = WalkaCatalogSnapshot.bundled();
    final WalkaCatalogSnapshot decoded = WalkaCatalogSnapshot.fromCacheJson(
      jsonDecode(jsonEncode(source.toJson())) as Map<String, dynamic>,
    );

    const WalkaCatalogValidator().validate(decoded);
    expect(decoded.source, WalkaCatalogSource.cache);
    expect(decoded.variantById(walkaDrawerGrayVariantId)?.asin, 'B0FQN4L2ZD');
    expect(decoded.productById(walkaLunchProductId)?.facts['capacity_ml'], 1200);
  });
}

WalkaCatalogRepository _repository({
  required WalkaJsonTransport transport,
  required WalkaCatalogCache cache,
}) {
  return WalkaCatalogRepository(
    api: WalkaApiClient(
      baseUri: Uri.parse('https://api.walka.test'),
      transport: transport,
    ),
    cache: cache,
  );
}

Map<String, Map<String, dynamic>> _validResponses() {
  final WalkaCatalogSnapshot bundled = WalkaCatalogSnapshot.bundled();
  return <String, Map<String, dynamic>>{
    '/api/v1/config': <String, dynamic>{
      'data': <String, dynamic>{
        'brand': 'WALKA',
        'release': '1.1.0',
        'api_version': 'v1',
        'purchase_mode': 'amazon_redirect',
      },
    },
    '/api/v1/catalog': <String, dynamic>{
      'data': bundled.products.map((product) => product.toJson()).toList(),
      'meta': <String, dynamic>{
        'api_version': 'v1',
        'purchase_mode': 'amazon_redirect',
      },
    },
  };
}

Map<String, dynamic> _deepCopy(Map<String, dynamic> value) {
  return jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
}

class _FakeTransport implements WalkaJsonTransport {
  _FakeTransport(this.responses);

  final Map<String, Map<String, dynamic>> responses;
  final List<String> paths = <String>[];

  @override
  Future<Map<String, dynamic>> getJson(Uri uri) async {
    paths.add(uri.path);
    final Map<String, dynamic>? response = responses[uri.path];
    if (response == null) throw StateError('No fake response for ${uri.path}');
    return _deepCopy(response);
  }
}

class _ThrowingTransport implements WalkaJsonTransport {
  @override
  Future<Map<String, dynamic>> getJson(Uri uri) async {
    throw StateError('Network unavailable for ${uri.path}');
  }
}

class _MemoryCache implements WalkaCatalogCache {
  _MemoryCache({this.initial});

  final WalkaCatalogSnapshot? initial;
  WalkaCatalogSnapshot? written;

  @override
  Future<WalkaCatalogSnapshot?> read() async => written ?? initial;

  @override
  Future<void> write(WalkaCatalogSnapshot snapshot) async {
    written = snapshot;
  }
}
