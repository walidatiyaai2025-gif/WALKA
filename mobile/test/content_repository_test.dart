import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/catalog/catalog_state.dart';
import 'package:walka/features/content/content_state.dart';
import 'package:walka/features/content/data/walka_home_hero_cache.dart';
import 'package:walka/features/content/data/walka_home_hero_repository.dart';
import 'package:walka/features/content/domain/walka_mobile_content.dart';
import 'package:walka/features/storefront/home_premium_v122.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('valid remote Home content wins and becomes last-known-good cache', () async {
    final _MemoryHomeCache cache = _MemoryHomeCache();
    final WalkaHomeHeroRepository repository = WalkaHomeHeroRepository(
      cache: cache,
      clock: () => DateTime.utc(2026, 8, 12, 1),
      remoteLoader: () async => _payload(revision: 7, title: 'Remote Hero'),
    );

    final WalkaHomeHeroSnapshot snapshot = await repository.load();

    expect(snapshot.source, WalkaContentSource.remote);
    expect(snapshot.revision, 7);
    expect(snapshot.content.title, 'Remote Hero');
    expect(cache.value?.revision, 7);
  });

  test('remote failure uses last-known-good cached Home content', () async {
    final _MemoryHomeCache cache = _MemoryHomeCache(
      value: _snapshot(revision: 5, title: 'Cached Hero'),
    );
    final WalkaHomeHeroRepository repository = WalkaHomeHeroRepository(
      cache: cache,
      remoteLoader: () async => throw StateError('offline'),
    );

    final WalkaHomeHeroSnapshot snapshot = await repository.load();

    expect(snapshot.source, WalkaContentSource.cache);
    expect(snapshot.revision, 5);
    expect(snapshot.content.title, 'Cached Hero');
  });

  test('first-run failure falls back to bundled safe Home content', () async {
    final WalkaHomeHeroRepository repository = WalkaHomeHeroRepository(
      cache: _MemoryHomeCache(),
      remoteLoader: () async => throw StateError('offline'),
    );

    final WalkaHomeHeroSnapshot snapshot = await repository.load();

    expect(snapshot.source, WalkaContentSource.bundled);
    expect(snapshot.revision, 0);
    expect(snapshot.content.title, 'Organize Better.\nLive Better.');
  });

  test('older remote revision cannot replace newer last-known-good cache', () async {
    final _MemoryHomeCache cache = _MemoryHomeCache(
      value: _snapshot(revision: 9, title: 'Newer Cached Hero'),
    );
    final WalkaHomeHeroRepository repository = WalkaHomeHeroRepository(
      cache: cache,
      remoteLoader: () async => _payload(revision: 8, title: 'Older Remote Hero'),
    );

    final WalkaHomeHeroSnapshot snapshot = await repository.load();

    expect(snapshot.source, WalkaContentSource.cache);
    expect(snapshot.revision, 9);
    expect(snapshot.content.title, 'Newer Cached Hero');
    expect(cache.writeCount, 0);
  });

  test('same revision with divergent payload is rejected as non-immutable', () async {
    final _MemoryHomeCache cache = _MemoryHomeCache(
      value: _snapshot(revision: 4, title: 'Immutable Cached Hero'),
    );
    final WalkaHomeHeroRepository repository = WalkaHomeHeroRepository(
      cache: cache,
      remoteLoader: () async => _payload(revision: 4, title: 'Mutated Remote Hero'),
    );

    final WalkaHomeHeroSnapshot snapshot = await repository.load();

    expect(snapshot.source, WalkaContentSource.cache);
    expect(snapshot.content.title, 'Immutable Cached Hero');
    expect(cache.writeCount, 0);
  });

  test('API payload parser rejects incompatible schema and malformed copy', () {
    expect(
      () => WalkaHomeHeroPayload.fromApiJson(
        _apiJson(revision: 2, title: 'Valid')
          ..['data']['schema_version'] = 2,
      ),
      throwsFormatException,
    );

    expect(
      () => WalkaHomeHeroPayload.fromApiJson(
        _apiJson(revision: 2, title: '   '),
      ),
      throwsFormatException,
    );
  });

  test('SharedPreferences Home cache round-trips and ignores corruption', () async {
    final SharedPreferencesWalkaHomeHeroCache cache =
        SharedPreferencesWalkaHomeHeroCache();
    await cache.write(_snapshot(revision: 3, title: 'Stored Hero'));

    final WalkaHomeHeroSnapshot? cached = await cache.read();
    expect(cached, isNotNull);
    expect(cached!.source, WalkaContentSource.cache);
    expect(cached.revision, 3);
    expect(cached.content.title, 'Stored Hero');

    SharedPreferences.setMockInitialValues(<String, Object>{
      SharedPreferencesWalkaHomeHeroCache.storageKey: '{not-json',
    });
    expect(await SharedPreferencesWalkaHomeHeroCache().read(), isNull);
  });

  testWidgets('Home renders published remote copy from content scope',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final WalkaCatalogController catalog = WalkaCatalogController();
    await catalog.load();
    final WalkaContentController content = WalkaContentController(
      homeRepository: WalkaHomeHeroRepository(
        cache: _MemoryHomeCache(),
        remoteLoader: () async => _payload(
          revision: 12,
          title: 'Backend Controlled Hero',
          shopLabel: 'BROWSE WALKA',
        ),
      ),
    );
    await content.load();

    await tester.pumpWidget(
      WalkaContentScope(
        controller: content,
        child: WalkaCatalogScope(
          controller: catalog,
          child: MaterialApp(
            theme: buildWalkaTheme(),
            home: Scaffold(
              body: WalkaHomePremiumV122(
                onShopAll: () {},
                onSearch: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Backend Controlled Hero'), findsOneWidget);
    expect(find.text('BROWSE WALKA'), findsOneWidget);
    expect(find.text('Organize Better.\nLive Better.'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

class _MemoryHomeCache implements WalkaHomeHeroCache {
  _MemoryHomeCache({this.value});

  WalkaHomeHeroSnapshot? value;
  int writeCount = 0;

  @override
  Future<void> clear() async {
    value = null;
  }

  @override
  Future<WalkaHomeHeroSnapshot?> read() async => value;

  @override
  Future<void> write(WalkaHomeHeroSnapshot snapshot) async {
    writeCount += 1;
    value = snapshot;
  }
}

WalkaHomeHeroPayload _payload({
  required int revision,
  required String title,
  String shopLabel = 'SHOP PRODUCTS',
}) {
  return WalkaHomeHeroPayload(
    content: WalkaHomeHeroContent(
      eyebrow: 'REMOTE WALKA',
      title: title,
      body: 'Remote body copy that remains safe and structured.',
      shopLabel: shopLabel,
      searchLabel: 'SEARCH COLLECTION',
    ),
    revision: revision,
    publishedAt: DateTime.utc(2026, 8, 12, 0, revision),
  );
}

WalkaHomeHeroSnapshot _snapshot({
  required int revision,
  required String title,
}) {
  final WalkaHomeHeroPayload payload = _payload(
    revision: revision,
    title: title,
  );
  return WalkaHomeHeroSnapshot(
    content: payload.content,
    revision: payload.revision,
    publishedAt: payload.publishedAt,
    fetchedAt: DateTime.utc(2026, 8, 12, 1),
    source: WalkaContentSource.cache,
  );
}

Map<String, dynamic> _apiJson({
  required int revision,
  required String title,
}) {
  return <String, dynamic>{
    'data': <String, dynamic>{
      'key': 'home.hero',
      'type': 'home.hero',
      'schema_version': 1,
      'revision': revision,
      'published_at': '2026-08-12T00:00:00Z',
      'payload': <String, dynamic>{
        'eyebrow': 'REMOTE WALKA',
        'title': title,
        'body': 'Remote body',
        'shop_label': 'SHOP PRODUCTS',
        'search_label': 'SEARCH COLLECTION',
      },
    },
    'meta': <String, dynamic>{'api_version': 'v1'},
  };
}
