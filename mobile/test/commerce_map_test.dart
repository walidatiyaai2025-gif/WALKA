import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:walka/core/api/walka_api_client.dart';
import 'package:walka/features/commerce/walka_commerce_api_client.dart';
import 'package:walka/features/commerce/walka_commerce_cache.dart';
import 'package:walka/features/commerce/walka_commerce_map.dart';
import 'package:walka/features/commerce/walka_commerce_repository.dart';

void main() {
  group('governed commerce contract', () {
    test('parses canonical verified Amazon mapping without changing protected ASIN', () {
      final WalkaCommerceSnapshot snapshot = WalkaCommerceSnapshot.fromApiJson(
        _apiSnapshot(
          revision: 7,
          digest: _digest('a'),
          market: 'CA',
          destination: 'https://www.amazon.ca/dp/B0FQN4L8MW',
        ),
      );

      expect(snapshot.revision, 7);
      expect(snapshot.verificationDigest, _digest('a'));
      expect(snapshot.mappings.single.variantId, 'lunch-box:blue');
      expect(snapshot.mappings.single.asin, 'B0FQN4L8MW');
      expect(snapshot.mappings.single.regionMarket, 'CA');
      expect(
        snapshot.mappings.single.destinationUri.toString(),
        'https://www.amazon.ca/dp/B0FQN4L8MW',
      );
    });

    test('rejects ASIN mutation before a destination can reach runtime', () {
      final Map<String, dynamic> json = _apiSnapshot(
        revision: 7,
        digest: _digest('a'),
      );
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        json['data'] as Map,
      );
      final List<dynamic> mappings = List<dynamic>.from(data['mappings'] as List);
      final Map<String, dynamic> mapping = Map<String, dynamic>.from(
        mappings.first as Map,
      );
      mapping['asin'] = 'B000000000';
      mapping['destination_url'] = 'https://www.amazon.com/dp/B000000000';
      data['mappings'] = <Map<String, dynamic>>[mapping];
      json['data'] = data;

      expect(
        () => WalkaCommerceSnapshot.fromApiJson(json),
        throwsFormatException,
      );
    });

    test('rejects non-Amazon and non-canonical destination URLs', () {
      expect(
        () => WalkaCommerceSnapshot.fromApiJson(
          _apiSnapshot(
            revision: 7,
            digest: _digest('a'),
            destination: 'https://example.invalid/dp/B0FQN4L8MW',
          ),
        ),
        throwsFormatException,
      );
      expect(
        () => WalkaCommerceSnapshot.fromApiJson(
          _apiSnapshot(
            revision: 7,
            digest: _digest('a'),
            destination: 'https://www.amazon.com/dp/B0FQN4L8MW?tag=unsafe',
          ),
        ),
        throwsFormatException,
      );
    });
  });

  group('revision-aware last-known-good repository', () {
    test('blocks a lower remote revision and keeps cached last-known-good', () async {
      final WalkaCommerceSnapshot cached = WalkaCommerceSnapshot.fromApiJson(
        _apiSnapshot(revision: 5, digest: _digest('b')),
      );
      final _MemoryCommerceCache cache = _MemoryCommerceCache(cached);
      final WalkaCommerceRepository repository = WalkaCommerceRepository(
        cache: cache,
        remoteLoader: () async => WalkaCommerceSnapshot.fromApiJson(
          _apiSnapshot(revision: 4, digest: _digest('c')),
        ),
      );

      final WalkaCommerceSnapshot result = await repository.load();

      expect(result.revision, 5);
      expect(result.verificationDigest, _digest('b'));
      expect(result.source, WalkaCommerceSource.cache);
      expect(cache.writeCount, 0);
    });

    test('blocks same-revision digest conflicts', () async {
      final WalkaCommerceSnapshot cached = WalkaCommerceSnapshot.fromApiJson(
        _apiSnapshot(revision: 5, digest: _digest('b')),
      );
      final _MemoryCommerceCache cache = _MemoryCommerceCache(cached);
      final WalkaCommerceRepository repository = WalkaCommerceRepository(
        cache: cache,
        remoteLoader: () async => WalkaCommerceSnapshot.fromApiJson(
          _apiSnapshot(revision: 5, digest: _digest('c')),
        ),
      );

      final WalkaCommerceSnapshot result = await repository.load();

      expect(result.revision, 5);
      expect(result.verificationDigest, _digest('b'));
      expect(result.source, WalkaCommerceSource.cache);
      expect(cache.writeCount, 0);
    });

    test('persists a newer verified remote snapshot', () async {
      final _MemoryCommerceCache cache = _MemoryCommerceCache(
        WalkaCommerceSnapshot.fromApiJson(
          _apiSnapshot(revision: 5, digest: _digest('b')),
        ),
      );
      final WalkaCommerceRepository repository = WalkaCommerceRepository(
        cache: cache,
        remoteLoader: () async => WalkaCommerceSnapshot.fromApiJson(
          _apiSnapshot(revision: 6, digest: _digest('d')),
        ),
      );

      final WalkaCommerceSnapshot result = await repository.load();

      expect(result.revision, 6);
      expect(result.source, WalkaCommerceSource.remote);
      expect(cache.writeCount, 1);
      expect(cache.current?.revision, 6);
    });

    test('falls back to bundled Product Master mode when remote and cache fail', () async {
      final WalkaCommerceRepository repository = WalkaCommerceRepository(
        cache: _MemoryCommerceCache(null),
        remoteLoader: () async => throw StateError('offline'),
      );

      final WalkaCommerceSnapshot result = await repository.load();

      expect(result.revision, 0);
      expect(result.source, WalkaCommerceSource.bundled);
      expect(result.mappings, isEmpty);
    });
  });

  test('commerce API client uses backward-compatible public v1 endpoint', () async {
    final MockClient httpClient = MockClient((http.Request request) async {
      expect(request.url.path, '/api/v1/commerce/amazon');
      return http.Response(
        jsonEncode(_apiSnapshot(revision: 9, digest: _digest('e'))),
        200,
        headers: const <String, String>{'content-type': 'application/json'},
      );
    });
    final WalkaCommerceApiClient client = WalkaCommerceApiClient(
      settings: const WalkaApiSettings(baseUrl: 'https://api.walkastore.test'),
      client: httpClient,
    );

    final WalkaCommerceSnapshot snapshot = await client.fetchCommerceMap();

    expect(snapshot.revision, 9);
    expect(snapshot.mappings.single.variantId, 'lunch-box:blue');
  });
}

Map<String, dynamic> _apiSnapshot({
  required int revision,
  required String digest,
  String market = 'US',
  String destination = 'https://www.amazon.com/dp/B0FQN4L8MW',
}) {
  return <String, dynamic>{
    'data': <String, dynamic>{
      'schema_version': 1,
      'mappings': <Map<String, dynamic>>[
        <String, dynamic>{
          'variant_id': 'lunch-box:blue',
          'variant_revision': 1,
          'region_market': market,
          'asin': 'B0FQN4L8MW',
          'destination_url': destination,
          'cta_key': 'commerce.amazon.buy',
          'disclosure_key': 'commerce.amazon.disclosure',
          'entitlements': <String>['amazon.redirect'],
          'active': true,
          'trace': <String, dynamic>{
            'source': 'cms.verified',
            'reference': '#375',
          },
        },
      ],
      'verification': <String, dynamic>{
        'algorithm': 'sha256',
        'digest': digest,
        'schema_version': 1,
        'published_revision': revision,
        'active_mapping_count': 1,
        'markets': <String>[market],
      },
    },
  };
}

String _digest(String character) => List<String>.filled(64, character).join();

class _MemoryCommerceCache implements WalkaCommerceCache {
  _MemoryCommerceCache(this.current);

  WalkaCommerceSnapshot? current;
  int writeCount = 0;

  @override
  Future<WalkaCommerceSnapshot?> read() async => current;

  @override
  Future<void> write(WalkaCommerceSnapshot snapshot) async {
    current = snapshot;
    writeCount += 1;
  }
}
