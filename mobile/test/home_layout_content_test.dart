import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/catalog/catalog_state.dart';
import 'package:walka/features/content/content_state.dart';
import 'package:walka/features/content/data/walka_home_layout_cache.dart';
import 'package:walka/features/content/data/walka_home_layout_repository.dart';
import 'package:walka/features/content/domain/walka_home_layout_content.dart';
import 'package:walka/features/content/domain/walka_mobile_content.dart';
import 'package:walka/features/storefront/home_premium_v122.dart';
import 'package:walka/features/storefront/presentation/widgets/home/walka_home_benefit_band.dart';
import 'package:walka/features/storefront/presentation/widgets/home/walka_home_trust_strip.dart';

void main() {
  test('Home layout parser accepts known ordered sections and typed safe copy', () {
    final WalkaHomeLayoutContent layout = WalkaHomeLayoutContent.fromJson(
      _layoutJson(
        order: <String>[
          'collection',
          'hero',
          'small_changes',
          'trust',
          'benefits',
        ],
        hidden: <String>{'trust', 'benefits'},
        collectionTitle: 'Dynamic Collection',
      ),
    );

    expect(
      layout.sections.map((WalkaHomeSectionConfig item) => item.id).toList(),
      <WalkaHomeSectionId>[
        WalkaHomeSectionId.collection,
        WalkaHomeSectionId.hero,
        WalkaHomeSectionId.smallChanges,
        WalkaHomeSectionId.trust,
        WalkaHomeSectionId.benefits,
      ],
    );
    expect(
      layout.section(WalkaHomeSectionId.collection).title,
      'Dynamic Collection',
    );
    expect(layout.section(WalkaHomeSectionId.trust).visible, isFalse);
  });

  test('Home layout parser rejects unknown, duplicate, or hidden core sections', () {
    final Map<String, dynamic> unknown = _layoutJson();
    unknown['sections'][1]['id'] = 'remote_arbitrary_widget';
    expect(
      () => WalkaHomeLayoutContent.fromJson(unknown),
      throwsFormatException,
    );

    final Map<String, dynamic> duplicate = _layoutJson();
    duplicate['sections'][1]['id'] = 'hero';
    expect(
      () => WalkaHomeLayoutContent.fromJson(duplicate),
      throwsFormatException,
    );

    final Map<String, dynamic> hiddenHero = _layoutJson(hidden: <String>{'hero'});
    expect(
      () => WalkaHomeLayoutContent.fromJson(hiddenHero),
      throwsFormatException,
    );
  });

  test('valid newer remote layout wins and becomes last-known-good', () async {
    final _MemoryLayoutCache cache = _MemoryLayoutCache();
    final WalkaHomeLayoutRepository repository = WalkaHomeLayoutRepository(
      cache: cache,
      remoteLoader: () async => _payload(
        revision: 7,
        content: WalkaHomeLayoutContent.fromJson(
          _layoutJson(collectionTitle: 'Remote Collection'),
        ),
      ),
    );

    final WalkaHomeLayoutSnapshot snapshot = await repository.load();

    expect(snapshot.source, WalkaContentSource.remote);
    expect(snapshot.revision, 7);
    expect(
      snapshot.content.section(WalkaHomeSectionId.collection).title,
      'Remote Collection',
    );
    expect(cache.value?.revision, 7);
  });

  test('offline uses cache and first run uses bundled layout', () async {
    final _MemoryLayoutCache cached = _MemoryLayoutCache(
      value: _snapshot(
        revision: 4,
        content: WalkaHomeLayoutContent.fromJson(
          _layoutJson(collectionTitle: 'Cached Collection'),
        ),
      ),
    );

    final WalkaHomeLayoutSnapshot cacheSnapshot =
        await WalkaHomeLayoutRepository(
      cache: cached,
      remoteLoader: () async => throw StateError('offline'),
    ).load();
    expect(cacheSnapshot.source, WalkaContentSource.cache);
    expect(
      cacheSnapshot.content.section(WalkaHomeSectionId.collection).title,
      'Cached Collection',
    );

    final WalkaHomeLayoutSnapshot bundled = await WalkaHomeLayoutRepository(
      cache: _MemoryLayoutCache(),
      remoteLoader: () async => throw StateError('offline'),
    ).load();
    expect(bundled.source, WalkaContentSource.bundled);
    expect(
      bundled.content.section(WalkaHomeSectionId.collection).title,
      'Everything in Its Place',
    );
  });

  test('older or divergent same-revision remote layout cannot replace LKG', () async {
    final WalkaHomeLayoutContent cachedContent = WalkaHomeLayoutContent.fromJson(
      _layoutJson(collectionTitle: 'Cached Newer'),
    );
    final _MemoryLayoutCache cache = _MemoryLayoutCache(
      value: _snapshot(revision: 9, content: cachedContent),
    );

    final WalkaHomeLayoutSnapshot older = await WalkaHomeLayoutRepository(
      cache: cache,
      remoteLoader: () async => _payload(
        revision: 8,
        content: WalkaHomeLayoutContent.fromJson(
          _layoutJson(collectionTitle: 'Remote Older'),
        ),
      ),
    ).load();
    expect(older.source, WalkaContentSource.cache);
    expect(cache.writeCount, 0);

    final WalkaHomeLayoutSnapshot divergent = await WalkaHomeLayoutRepository(
      cache: cache,
      remoteLoader: () async => _payload(
        revision: 9,
        content: WalkaHomeLayoutContent.fromJson(
          _layoutJson(collectionTitle: 'Mutated Same Revision'),
        ),
      ),
    ).load();
    expect(divergent.source, WalkaContentSource.cache);
    expect(
      divergent.content.section(WalkaHomeSectionId.collection).title,
      'Cached Newer',
    );
    expect(cache.writeCount, 0);
  });

  testWidgets('Home honors approved section order, visibility and safe copy',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final WalkaCatalogController catalog = WalkaCatalogController();
    await catalog.load();
    final WalkaContentController content = WalkaContentController(
      homeLayoutRepository: WalkaHomeLayoutRepository(
        cache: _MemoryLayoutCache(),
        remoteLoader: () async => _payload(
          revision: 12,
          content: WalkaHomeLayoutContent.fromJson(
            _layoutJson(
              order: <String>[
                'collection',
                'hero',
                'small_changes',
                'trust',
                'benefits',
              ],
              hidden: <String>{'trust', 'benefits'},
              collectionTitle: 'Backend Ordered Collection',
              editorialTitle: 'Backend Editorial',
            ),
          ),
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

    expect(find.text('Backend Ordered Collection'), findsOneWidget);
    expect(find.text('Backend Editorial'), findsOneWidget);
    expect(find.byType(WalkaHomeBenefitBand), findsNothing);
    expect(find.byType(WalkaHomeTrustStrip), findsNothing);

    final double collectionY =
        tester.getTopLeft(find.text('Backend Ordered Collection')).dy;
    final double heroY =
        tester.getTopLeft(find.text('Organize Better.\nLive Better.')).dy;
    expect(collectionY, lessThan(heroY));
    expect(tester.takeException(), isNull);
  });
}

class _MemoryLayoutCache implements WalkaHomeLayoutCache {
  _MemoryLayoutCache({this.value});

  WalkaHomeLayoutSnapshot? value;
  int writeCount = 0;

  @override
  Future<void> clear() async {
    value = null;
  }

  @override
  Future<WalkaHomeLayoutSnapshot?> read() async => value;

  @override
  Future<void> write(WalkaHomeLayoutSnapshot snapshot) async {
    writeCount += 1;
    value = snapshot;
  }
}

WalkaHomeLayoutPayload _payload({
  required int revision,
  required WalkaHomeLayoutContent content,
}) {
  return WalkaHomeLayoutPayload(
    content: content,
    revision: revision,
    publishedAt: DateTime.utc(2026, 8, 12, 1, revision),
  );
}

WalkaHomeLayoutSnapshot _snapshot({
  required int revision,
  required WalkaHomeLayoutContent content,
}) {
  return WalkaHomeLayoutSnapshot(
    content: content,
    revision: revision,
    publishedAt: DateTime.utc(2026, 8, 12, 1, revision),
    fetchedAt: DateTime.utc(2026, 8, 12, 2),
    source: WalkaContentSource.cache,
  );
}

Map<String, dynamic> _layoutJson({
  List<String>? order,
  Set<String> hidden = const <String>{},
  String collectionTitle = 'Everything in Its Place',
  String editorialTitle = 'Small Changes,\nBetter Living',
}) {
  final List<String> resolvedOrder = order ?? <String>[
    'hero',
    'benefits',
    'collection',
    'small_changes',
    'trust',
  ];

  Map<String, dynamic> section(String id) {
    final Map<String, dynamic> value = <String, dynamic>{
      'id': id,
      'visible': !hidden.contains(id),
    };
    if (id == 'collection') {
      value['eyebrow'] = 'OUR COLLECTION';
      value['title'] = collectionTitle;
    }
    if (id == 'small_changes') {
      value['title'] = editorialTitle;
      value['body'] =
          'Simple solutions that bring order, beauty and peace of mind.';
    }
    return value;
  }

  return <String, dynamic>{
    'sections': resolvedOrder.map(section).toList(growable: false),
  };
}
