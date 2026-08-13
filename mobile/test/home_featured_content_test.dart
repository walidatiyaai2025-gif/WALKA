import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/media/walka_product_media_resolver.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/catalog/catalog_state.dart';
import 'package:walka/features/content/content_state.dart';
import 'package:walka/features/content/data/walka_home_featured_cache.dart';
import 'package:walka/features/content/data/walka_home_featured_repository.dart';
import 'package:walka/features/content/domain/walka_home_featured_content.dart';
import 'package:walka/features/content/domain/walka_mobile_content.dart';
import 'package:walka/features/storefront/home_premium_v122.dart';
import 'package:walka/features/storefront/presentation/widgets/home/walka_home_small_changes.dart';

void main() {
  test('featured parser accepts ordered approved-family variant identities', () {
    final WalkaHomeFeaturedContent content = WalkaHomeFeaturedContent.fromJson(
      <String, dynamic>{
        'collection_variant_ids': <String>[
          'drawer-organizer:gray',
          'lunch-box:green',
        ],
        'editorial_variant_id': 'lunch-box:pink',
      },
    );

    expect(
      content.collectionVariantIds,
      <String>['drawer-organizer:gray', 'lunch-box:green'],
    );
    expect(content.editorialVariantId, 'lunch-box:pink');
  });

  test('featured parser rejects duplicate and same-family collection slots', () {
    expect(
      () => WalkaHomeFeaturedContent.fromJson(<String, dynamic>{
        'collection_variant_ids': <String>[
          'lunch-box:blue',
          'lunch-box:blue',
        ],
        'editorial_variant_id': 'drawer-organizer:white',
      }),
      throwsFormatException,
    );

    expect(
      () => WalkaHomeFeaturedContent.fromJson(<String, dynamic>{
        'collection_variant_ids': <String>[
          'lunch-box:blue',
          'lunch-box:green',
        ],
        'editorial_variant_id': 'drawer-organizer:white',
      }),
      throwsFormatException,
    );
  });

  test('newer remote featured merchandising wins and becomes LKG', () async {
    final _MemoryFeaturedCache cache = _MemoryFeaturedCache();
    final WalkaHomeFeaturedRepository repository = WalkaHomeFeaturedRepository(
      cache: cache,
      remoteLoader: () async => _payload(
        revision: 7,
        content: const WalkaHomeFeaturedContent(
          collectionVariantIds: <String>[
            'drawer-organizer:gray',
            'lunch-box:green',
          ],
          editorialVariantId: 'lunch-box:pink',
        ),
      ),
    );

    final WalkaHomeFeaturedSnapshot snapshot = await repository.load();

    expect(snapshot.source, WalkaContentSource.remote);
    expect(snapshot.revision, 7);
    expect(snapshot.content.editorialVariantId, 'lunch-box:pink');
    expect(cache.value?.revision, 7);
  });

  test('offline uses cache and first run uses bundled merchandising', () async {
    final _MemoryFeaturedCache cached = _MemoryFeaturedCache(
      value: _snapshot(
        revision: 4,
        content: const WalkaHomeFeaturedContent(
          collectionVariantIds: <String>[
            'drawer-organizer:gray',
            'lunch-box:green',
          ],
          editorialVariantId: 'lunch-box:pink',
        ),
      ),
    );

    final WalkaHomeFeaturedSnapshot cacheSnapshot =
        await WalkaHomeFeaturedRepository(
      cache: cached,
      remoteLoader: () async => throw StateError('offline'),
    ).load();
    expect(cacheSnapshot.source, WalkaContentSource.cache);
    expect(cacheSnapshot.content.editorialVariantId, 'lunch-box:pink');

    final WalkaHomeFeaturedSnapshot bundled = await WalkaHomeFeaturedRepository(
      cache: _MemoryFeaturedCache(),
      remoteLoader: () async => throw StateError('offline'),
    ).load();
    expect(bundled.source, WalkaContentSource.bundled);
    expect(
      bundled.content.collectionVariantIds,
      <String>['lunch-box:blue', 'drawer-organizer:white'],
    );
  });

  test('older or divergent same-revision remote cannot replace LKG', () async {
    final _MemoryFeaturedCache cache = _MemoryFeaturedCache(
      value: _snapshot(
        revision: 9,
        content: const WalkaHomeFeaturedContent(
          collectionVariantIds: <String>[
            'drawer-organizer:gray',
            'lunch-box:green',
          ],
          editorialVariantId: 'lunch-box:pink',
        ),
      ),
    );

    final WalkaHomeFeaturedSnapshot older = await WalkaHomeFeaturedRepository(
      cache: cache,
      remoteLoader: () async => _payload(
        revision: 8,
        content: WalkaHomeFeaturedContent.bundled,
      ),
    ).load();
    expect(older.source, WalkaContentSource.cache);
    expect(cache.writeCount, 0);

    final WalkaHomeFeaturedSnapshot divergent =
        await WalkaHomeFeaturedRepository(
      cache: cache,
      remoteLoader: () async => _payload(
        revision: 9,
        content: WalkaHomeFeaturedContent.bundled,
      ),
    ).load();
    expect(divergent.source, WalkaContentSource.cache);
    expect(divergent.content.editorialVariantId, 'lunch-box:pink');
    expect(cache.writeCount, 0);
  });

  testWidgets('Home renders backend-selected collection order and editorial item',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final WalkaCatalogController catalog = WalkaCatalogController();
    await catalog.load();
    final WalkaContentController content = WalkaContentController(
      homeFeaturedRepository: WalkaHomeFeaturedRepository(
        cache: _MemoryFeaturedCache(),
        remoteLoader: () async => _payload(
          revision: 12,
          content: const WalkaHomeFeaturedContent(
            collectionVariantIds: <String>[
              'drawer-organizer:gray',
              'lunch-box:green',
            ],
            editorialVariantId: 'lunch-box:pink',
          ),
        ),
      ),
    );
    await content.load();

    await tester.pumpWidget(_homeApp(catalog: catalog, content: content));
    await tester.pump();

    final Finder first =
        find.byKey(const ValueKey<String>('home-reference-drawer-organizer:gray-card'));
    final Finder second =
        find.byKey(const ValueKey<String>('home-reference-lunch-box:green-card'));
    expect(first, findsOneWidget);
    expect(second, findsOneWidget);
    expect(tester.getTopLeft(first).dx, lessThan(tester.getTopLeft(second).dx));

    final Finder editorialMedia = find.descendant(
      of: find.byType(WalkaHomeSmallChanges),
      matching: find.byType(WalkaResolvedProductMedia),
    );
    final WalkaResolvedProductMedia editorial = tester.widget(editorialMedia);
    expect(editorial.variantId, 'lunch-box:pink');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home falls back to bundled membership when runtime catalog rejects IDs',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final WalkaCatalogController catalog = WalkaCatalogController();
    await catalog.load();
    final WalkaContentController content = WalkaContentController(
      homeFeaturedRepository: WalkaHomeFeaturedRepository(
        cache: _MemoryFeaturedCache(),
        remoteLoader: () async => _payload(
          revision: 13,
          content: const WalkaHomeFeaturedContent(
            collectionVariantIds: <String>[
              'unknown-family:unknown-variant',
              'lunch-box:green',
            ],
            editorialVariantId: 'unknown-family:editorial',
          ),
        ),
      ),
    );
    await content.load();

    await tester.pumpWidget(_homeApp(catalog: catalog, content: content));
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('home-reference-lunch-box:blue-card')),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey<String>('home-reference-drawer-organizer:white-card'),
      ),
      findsOneWidget,
    );

    final Finder editorialMedia = find.descendant(
      of: find.byType(WalkaHomeSmallChanges),
      matching: find.byType(WalkaResolvedProductMedia),
    );
    final WalkaResolvedProductMedia editorial = tester.widget(editorialMedia);
    expect(editorial.variantId, 'drawer-organizer:white');
    expect(tester.takeException(), isNull);
  });
}

Widget _homeApp({
  required WalkaCatalogController catalog,
  required WalkaContentController content,
}) {
  return WalkaContentScope(
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
  );
}

class _MemoryFeaturedCache implements WalkaHomeFeaturedCache {
  _MemoryFeaturedCache({this.value});

  WalkaHomeFeaturedSnapshot? value;
  int writeCount = 0;

  @override
  Future<WalkaHomeFeaturedSnapshot?> read() async => value;

  @override
  Future<void> write(WalkaHomeFeaturedSnapshot snapshot) async {
    writeCount += 1;
    value = snapshot;
  }
}

WalkaHomeFeaturedPayload _payload({
  required int revision,
  required WalkaHomeFeaturedContent content,
}) {
  return WalkaHomeFeaturedPayload(
    content: content,
    revision: revision,
    publishedAt: DateTime.utc(2026, 8, 13, 1, revision),
  );
}

WalkaHomeFeaturedSnapshot _snapshot({
  required int revision,
  required WalkaHomeFeaturedContent content,
}) {
  return WalkaHomeFeaturedSnapshot(
    content: content,
    revision: revision,
    publishedAt: DateTime.utc(2026, 8, 13, 1, revision),
    fetchedAt: DateTime.utc(2026, 8, 13, 2),
    source: WalkaContentSource.cache,
  );
}
