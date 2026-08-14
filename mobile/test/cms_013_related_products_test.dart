import 'package:flutter_test/flutter_test.dart';
import 'package:walka/features/content/data/walka_related_products_cache.dart';
import 'package:walka/features/content/data/walka_related_products_repository.dart';
import 'package:walka/features/content/domain/walka_mobile_content.dart';
import 'package:walka/features/content/domain/walka_related_products_content.dart';

void main() {
  test('bundled related products preserve safe reciprocal product families', () {
    expect(
      WalkaRelatedProductsContent.bundled.relatedIdsFor('drawer-organizer'),
      <String>['stainless-steel-bento-lunch-box'],
    );
    expect(
      WalkaRelatedProductsContent.bundled
          .relatedIdsFor('stainless-steel-bento-lunch-box'),
      <String>['drawer-organizer'],
    );
  });

  test('API parser rejects unknown target, self-reference and duplicate target', () {
    Map<String, dynamic> envelope(Map<String, dynamic> payload) =>
        <String, dynamic>{
          'data': <String, dynamic>{
            'key': 'pdp.related_products',
            'type': 'pdp.related_products',
            'schema_version': 1,
            'revision': 7,
            'published_at': '2026-08-14T02:00:00Z',
            'payload': payload,
          },
          'meta': <String, dynamic>{'api_version': 'v1'},
        };

    expect(
      () => WalkaRelatedProductsPayload.fromApiJson(
        envelope(<String, dynamic>{
          'relationships': <Object>[
            <String, dynamic>{
              'product_id': 'drawer-organizer',
              'related_product_ids': <String>['server-authored-product'],
            },
          ],
        }),
      ),
      throwsA(isA<FormatException>()),
    );

    expect(
      () => WalkaRelatedProductsPayload.fromApiJson(
        envelope(<String, dynamic>{
          'relationships': <Object>[
            <String, dynamic>{
              'product_id': 'drawer-organizer',
              'related_product_ids': <String>['drawer-organizer'],
            },
          ],
        }),
      ),
      throwsA(isA<FormatException>()),
    );

    expect(
      () => WalkaRelatedProductsPayload.fromApiJson(
        envelope(<String, dynamic>{
          'relationships': <Object>[
            <String, dynamic>{
              'product_id': 'drawer-organizer',
              'related_product_ids': <String>[
                'stainless-steel-bento-lunch-box',
                'stainless-steel-bento-lunch-box',
              ],
            },
          ],
        }),
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('repository accepts newer remote snapshot and persists LKG', () async {
    final _MemoryRelatedProductsCache cache = _MemoryRelatedProductsCache();
    final WalkaRelatedProductsRepository repository = WalkaRelatedProductsRepository(
      cache: cache,
      clock: () => DateTime.utc(2026, 8, 14, 2, 30),
      remoteLoader: () async => WalkaRelatedProductsPayload(
        content: const WalkaRelatedProductsContent(
          relationships: <WalkaRelatedProductRelationship>[
            WalkaRelatedProductRelationship(
              productId: 'drawer-organizer',
              relatedProductIds: <String>['stainless-steel-bento-lunch-box'],
            ),
          ],
        ),
        revision: 8,
        publishedAt: DateTime.utc(2026, 8, 14, 2),
      ),
    );

    final WalkaRelatedProductsSnapshot snapshot = await repository.load();

    expect(snapshot.source, WalkaContentSource.remote);
    expect(snapshot.revision, 8);
    expect(cache.snapshot?.revision, 8);
  });

  test('repository keeps newer cached LKG when remote revision is older', () async {
    final _MemoryRelatedProductsCache cache = _MemoryRelatedProductsCache(
      WalkaRelatedProductsSnapshot(
        content: WalkaRelatedProductsContent.bundled,
        revision: 9,
        publishedAt: DateTime.utc(2026, 8, 14, 2),
        fetchedAt: DateTime.utc(2026, 8, 14, 2, 5),
        source: WalkaContentSource.cache,
      ),
    );
    final WalkaRelatedProductsRepository repository = WalkaRelatedProductsRepository(
      cache: cache,
      remoteLoader: () async => WalkaRelatedProductsPayload(
        content: WalkaRelatedProductsContent.bundled,
        revision: 8,
        publishedAt: DateTime.utc(2026, 8, 14, 1),
      ),
    );

    final WalkaRelatedProductsSnapshot snapshot = await repository.load();

    expect(snapshot.source, WalkaContentSource.cache);
    expect(snapshot.revision, 9);
  });

  test('repository rejects divergent same-revision remote and keeps LKG', () async {
    final _MemoryRelatedProductsCache cache = _MemoryRelatedProductsCache(
      WalkaRelatedProductsSnapshot(
        content: WalkaRelatedProductsContent.bundled,
        revision: 9,
        publishedAt: DateTime.utc(2026, 8, 14, 2),
        fetchedAt: DateTime.utc(2026, 8, 14, 2, 5),
        source: WalkaContentSource.cache,
      ),
    );
    final WalkaRelatedProductsRepository repository = WalkaRelatedProductsRepository(
      cache: cache,
      remoteLoader: () async => WalkaRelatedProductsPayload(
        content: const WalkaRelatedProductsContent(
          relationships: <WalkaRelatedProductRelationship>[],
        ),
        revision: 9,
        publishedAt: DateTime.utc(2026, 8, 14, 2, 10),
      ),
    );

    final WalkaRelatedProductsSnapshot snapshot = await repository.load();

    expect(snapshot.source, WalkaContentSource.cache);
    expect(snapshot.content.toJson(), WalkaRelatedProductsContent.bundled.toJson());
  });

  test('repository uses bundled relationships when remote and cache fail', () async {
    final WalkaRelatedProductsRepository repository = WalkaRelatedProductsRepository(
      cache: _ThrowingRelatedProductsCache(),
      remoteLoader: () async => throw StateError('offline'),
      clock: () => DateTime.utc(2026, 8, 14, 3),
    );

    final WalkaRelatedProductsSnapshot snapshot = await repository.load();

    expect(snapshot.source, WalkaContentSource.bundled);
    expect(snapshot.revision, 0);
    expect(
      snapshot.content.relatedIdsFor('drawer-organizer'),
      <String>['stainless-steel-bento-lunch-box'],
    );
  });
}

class _MemoryRelatedProductsCache implements WalkaRelatedProductsCache {
  _MemoryRelatedProductsCache([this.snapshot]);

  WalkaRelatedProductsSnapshot? snapshot;

  @override
  Future<void> clear() async => snapshot = null;

  @override
  Future<WalkaRelatedProductsSnapshot?> read() async => snapshot;

  @override
  Future<void> write(WalkaRelatedProductsSnapshot value) async {
    snapshot = value;
  }
}

class _ThrowingRelatedProductsCache implements WalkaRelatedProductsCache {
  @override
  Future<void> clear() async => throw StateError('cache unavailable');

  @override
  Future<WalkaRelatedProductsSnapshot?> read() async =>
      throw StateError('cache unavailable');

  @override
  Future<void> write(WalkaRelatedProductsSnapshot snapshot) async =>
      throw StateError('cache unavailable');
}
