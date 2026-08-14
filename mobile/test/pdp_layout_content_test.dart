import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/content/content_state.dart';
import 'package:walka/features/content/data/walka_pdp_layout_cache.dart';
import 'package:walka/features/content/data/walka_pdp_layout_repository.dart';
import 'package:walka/features/content/domain/walka_mobile_content.dart';
import 'package:walka/features/content/domain/walka_pdp_layout_content.dart';
import 'package:walka/features/lunch/lunch_box_v6.dart';
import 'package:walka/features/products/presentation/walka_pdp_model.dart';
import 'package:walka/features/products/presentation/widgets/walka_pdp_body.dart';
import 'package:walka/features/products/presentation/widgets/walka_pdp_details.dart';

void main() {
  test('PDP layout accepts deterministic known section ordering', () {
    final WalkaPdpLayoutContent layout = WalkaPdpLayoutContent.fromJson(
      _layoutJson(
        order: <String>[
          'variants',
          'gallery',
          'identity',
          'facts',
          'specifications',
          'amazon_trust',
          'editorial',
          'usage',
        ],
        hidden: <String>{'editorial', 'usage'},
      ),
    );

    expect(
      layout.sections.map((WalkaPdpSectionConfig item) => item.id).toList(),
      <WalkaPdpSectionId>[
        WalkaPdpSectionId.variants,
        WalkaPdpSectionId.gallery,
        WalkaPdpSectionId.identity,
        WalkaPdpSectionId.facts,
        WalkaPdpSectionId.specifications,
        WalkaPdpSectionId.amazonTrust,
        WalkaPdpSectionId.editorial,
        WalkaPdpSectionId.usage,
      ],
    );
    expect(
      layout.visibleSections.map((WalkaPdpSectionConfig item) => item.id),
      isNot(contains(WalkaPdpSectionId.editorial)),
    );
  });

  test('PDP layout fails closed for unknown, duplicate, or hidden protected sections', () {
    final Map<String, dynamic> unknown = _layoutJson();
    unknown['sections'][1]['id'] = 'remote_arbitrary_widget';
    expect(
      () => WalkaPdpLayoutContent.fromJson(unknown),
      throwsFormatException,
    );

    final Map<String, dynamic> duplicate = _layoutJson();
    duplicate['sections'][1]['id'] = 'gallery';
    expect(
      () => WalkaPdpLayoutContent.fromJson(duplicate),
      throwsFormatException,
    );

    for (final String id in <String>[
      'gallery',
      'identity',
      'variants',
      'facts',
      'specifications',
      'amazon_trust',
    ]) {
      expect(
        () => WalkaPdpLayoutContent.fromJson(_layoutJson(hidden: <String>{id})),
        throwsFormatException,
        reason: '$id must remain visible',
      );
    }
  });

  test('newer remote PDP layout wins and persists as last-known-good', () async {
    final _MemoryPdpLayoutCache cache = _MemoryPdpLayoutCache();
    final WalkaPdpLayoutRepository repository = WalkaPdpLayoutRepository(
      cache: cache,
      remoteLoader: () async => _payload(
        revision: 7,
        content: WalkaPdpLayoutContent.fromJson(
          _layoutJson(hidden: <String>{'editorial'}),
        ),
      ),
    );

    final WalkaPdpLayoutSnapshot snapshot = await repository.load();

    expect(snapshot.source, WalkaContentSource.remote);
    expect(snapshot.revision, 7);
    expect(cache.value?.revision, 7);
    expect(
      snapshot.content.visibleSections
          .map((WalkaPdpSectionConfig item) => item.id),
      isNot(contains(WalkaPdpSectionId.editorial)),
    );
  });

  test('offline PDP layout uses cache and first run uses bundled manifest', () async {
    final _MemoryPdpLayoutCache cached = _MemoryPdpLayoutCache(
      value: _snapshot(
        revision: 4,
        content: WalkaPdpLayoutContent.fromJson(
          _layoutJson(hidden: <String>{'usage'}),
        ),
      ),
    );

    final WalkaPdpLayoutSnapshot cacheSnapshot = await WalkaPdpLayoutRepository(
      cache: cached,
      remoteLoader: () async => throw StateError('offline'),
    ).load();
    expect(cacheSnapshot.source, WalkaContentSource.cache);
    expect(
      cacheSnapshot.content.visibleSections
          .map((WalkaPdpSectionConfig item) => item.id),
      isNot(contains(WalkaPdpSectionId.usage)),
    );

    final WalkaPdpLayoutSnapshot bundled = await WalkaPdpLayoutRepository(
      cache: _MemoryPdpLayoutCache(),
      remoteLoader: () async => throw StateError('offline'),
    ).load();
    expect(bundled.source, WalkaContentSource.bundled);
    expect(bundled.content.sections.length, 8);
    expect(bundled.content.sections.every((item) => item.visible), isTrue);
  });

  test('older or divergent same-revision remote cannot replace PDP LKG', () async {
    final WalkaPdpLayoutContent cachedContent = WalkaPdpLayoutContent.fromJson(
      _layoutJson(hidden: <String>{'editorial'}),
    );
    final _MemoryPdpLayoutCache cache = _MemoryPdpLayoutCache(
      value: _snapshot(revision: 9, content: cachedContent),
    );

    final WalkaPdpLayoutSnapshot older = await WalkaPdpLayoutRepository(
      cache: cache,
      remoteLoader: () async => _payload(
        revision: 8,
        content: WalkaPdpLayoutContent.bundled,
      ),
    ).load();
    expect(older.source, WalkaContentSource.cache);
    expect(cache.writeCount, 0);

    final WalkaPdpLayoutSnapshot divergent = await WalkaPdpLayoutRepository(
      cache: cache,
      remoteLoader: () async => _payload(
        revision: 9,
        content: WalkaPdpLayoutContent.bundled,
      ),
    ).load();
    expect(divergent.source, WalkaContentSource.cache);
    expect(
      divergent.content.visibleSections
          .map((WalkaPdpSectionConfig item) => item.id),
      isNot(contains(WalkaPdpSectionId.editorial)),
    );
    expect(cache.writeCount, 0);
  });

  testWidgets('PDP applies remote order and optional visibility without hiding commerce truth',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final WalkaContentController content = WalkaContentController(
      pdpLayoutRepository: WalkaPdpLayoutRepository(
        cache: _MemoryPdpLayoutCache(),
        remoteLoader: () async => _payload(
          revision: 12,
          content: WalkaPdpLayoutContent.fromJson(
            _layoutJson(
              order: <String>[
                'variants',
                'gallery',
                'identity',
                'facts',
                'specifications',
                'amazon_trust',
                'editorial',
                'usage',
              ],
              hidden: <String>{'editorial', 'usage'},
            ),
          ),
        ),
      ),
    );
    await content.load();

    await tester.pumpWidget(
      WalkaContentScope(
        controller: content,
        child: MaterialApp(
          theme: buildWalkaTheme(),
          home: Scaffold(
            body: WalkaPdpBody(
              scrollKey: const ValueKey<String>('cms-012-pdp-scroll'),
              model: WalkaPdpPresentationModel.lunch(WalkaLunchVariant.blue),
              gallery: const Text('GALLERY TEST'),
              variantSelector: const Text('VARIANT SELECTOR TEST'),
              editorialTitle: 'EDITORIAL TEST',
              editorialBody: 'This optional editorial block should be hidden.',
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('EDITORIAL TEST'), findsNothing);
    expect(find.byType(WalkaPdpUsagePanel), findsNothing);
    expect(find.text('GALLERY TEST'), findsOneWidget);
    expect(find.text('VARIANT SELECTOR TEST'), findsOneWidget);

    final double variantY =
        tester.getTopLeft(find.text('VARIANT SELECTOR TEST')).dy;
    final double galleryY = tester.getTopLeft(find.text('GALLERY TEST')).dy;
    expect(variantY, lessThan(galleryY));
    expect(find.textContaining('Official Amazon'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

class _MemoryPdpLayoutCache implements WalkaPdpLayoutCache {
  _MemoryPdpLayoutCache({this.value});

  WalkaPdpLayoutSnapshot? value;
  int writeCount = 0;

  @override
  Future<void> clear() async {
    value = null;
  }

  @override
  Future<WalkaPdpLayoutSnapshot?> read() async => value;

  @override
  Future<void> write(WalkaPdpLayoutSnapshot snapshot) async {
    writeCount += 1;
    value = snapshot;
  }
}

WalkaPdpLayoutPayload _payload({
  required int revision,
  required WalkaPdpLayoutContent content,
}) {
  return WalkaPdpLayoutPayload(
    content: content,
    revision: revision,
    publishedAt: DateTime.utc(2026, 8, 14, 1, revision),
  );
}

WalkaPdpLayoutSnapshot _snapshot({
  required int revision,
  required WalkaPdpLayoutContent content,
}) {
  return WalkaPdpLayoutSnapshot(
    content: content,
    revision: revision,
    publishedAt: DateTime.utc(2026, 8, 14, 1, revision),
    fetchedAt: DateTime.utc(2026, 8, 14, 2),
    source: WalkaContentSource.cache,
  );
}

Map<String, dynamic> _layoutJson({
  List<String>? order,
  Set<String> hidden = const <String>{},
}) {
  final List<String> resolvedOrder = order ?? <String>[
    'gallery',
    'identity',
    'variants',
    'usage',
    'facts',
    'editorial',
    'specifications',
    'amazon_trust',
  ];

  return <String, dynamic>{
    'sections': resolvedOrder
        .map(
          (String id) => <String, dynamic>{
            'id': id,
            'visible': !hidden.contains(id),
          },
        )
        .toList(growable: false),
  };
}
