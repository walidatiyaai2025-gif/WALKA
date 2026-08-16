import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/catalog/catalog_state.dart';
import 'package:walka/features/content/content_state.dart';
import 'package:walka/features/content/data/walka_category_presentation_cache.dart';
import 'package:walka/features/content/data/walka_category_presentation_repository.dart';
import 'package:walka/features/content/domain/walka_category_presentation_content.dart';
import 'package:walka/features/content/domain/walka_mobile_content.dart';
import 'package:walka/features/storefront/categories_cms_v124.dart';
import 'package:walka/features/storefront/discovery_reference_v123.dart';

void main() {
  test('category parser accepts arbitrary safe overlay identities and copy', () {
    final WalkaCategoryPresentationContent content =
        WalkaCategoryPresentationContent.fromJson(<String, dynamic>{
      'categories': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'workspace',
          'display_name': 'Workspace Edit',
          'description': 'Calm workspace organization.',
          'visible': true,
        },
        <String, dynamic>{
          'id': 'travel',
          'display_name': 'Travel Edit',
          'description': 'Refined travel organization.',
          'visible': false,
        },
      ],
    });

    expect(content.categories.first.id, 'workspace');
    expect(content.categories.first.displayName, 'Workspace Edit');
    expect(content.visibleCategories.single.id, 'workspace');
  });

  test('category parser rejects malformed, duplicate and all-hidden identities', () {
    Map<String, dynamic> entry(String id, {bool visible = true}) =>
        <String, dynamic>{
          'id': id,
          'display_name': id,
          'description': 'Valid description for $id.',
          'visible': visible,
        };

    expect(
      () => WalkaCategoryPresentationContent.fromJson(<String, dynamic>{
        'categories': <Map<String, dynamic>>[],
      }),
      throwsFormatException,
    );
    expect(
      () => WalkaCategoryPresentationContent.fromJson(<String, dynamic>{
        'categories': <Map<String, dynamic>>[
          entry('invalid category id'),
        ],
      }),
      throwsFormatException,
    );
    expect(
      () => WalkaCategoryPresentationContent.fromJson(<String, dynamic>{
        'categories': <Map<String, dynamic>>[
          entry('travel'),
          entry('travel'),
        ],
      }),
      throwsFormatException,
    );
    expect(
      () => WalkaCategoryPresentationContent.fromJson(<String, dynamic>{
        'categories': <Map<String, dynamic>>[
          entry('travel', visible: false),
          entry('workspace', visible: false),
        ],
      }),
      throwsFormatException,
    );
  });

  test('newer remote category presentation wins and becomes last-known-good', () async {
    final _MemoryCategoryCache cache = _MemoryCategoryCache();
    final WalkaCategoryPresentationRepository repository =
        WalkaCategoryPresentationRepository(
      cache: cache,
      remoteLoader: () async => _payload(
        revision: 7,
        content: _customPresentation(),
      ),
    );

    final WalkaCategoryPresentationSnapshot snapshot = await repository.load();
    expect(snapshot.source, WalkaContentSource.remote);
    expect(snapshot.revision, 7);
    expect(snapshot.content.categories.first.id, 'drawer-organization');
    expect(cache.value?.revision, 7);
  });

  test('offline uses category cache and first run has no compiled overlay identities', () async {
    final _MemoryCategoryCache cache = _MemoryCategoryCache(
      value: _snapshot(revision: 4, content: _customPresentation()),
    );

    final WalkaCategoryPresentationSnapshot offline =
        await WalkaCategoryPresentationRepository(
      cache: cache,
      remoteLoader: () async => throw StateError('offline'),
    ).load();
    expect(offline.source, WalkaContentSource.cache);
    expect(offline.content.visibleCategories.single.id, 'drawer-organization');

    final WalkaCategoryPresentationSnapshot bundled =
        await WalkaCategoryPresentationRepository(
      cache: _MemoryCategoryCache(),
      remoteLoader: () async => throw StateError('offline'),
    ).load();
    expect(bundled.source, WalkaContentSource.bundled);
    expect(bundled.content.categories, isEmpty);
    expect(bundled.content.visibleCategories, isEmpty);
  });

  test('older or divergent same-revision category payload cannot replace LKG', () async {
    final _MemoryCategoryCache cache = _MemoryCategoryCache(
      value: _snapshot(revision: 9, content: _customPresentation()),
    );

    final WalkaCategoryPresentationSnapshot older =
        await WalkaCategoryPresentationRepository(
      cache: cache,
      remoteLoader: () async => _payload(
        revision: 8,
        content: WalkaCategoryPresentationContent.bundled,
      ),
    ).load();
    expect(older.source, WalkaContentSource.cache);
    expect(cache.writeCount, 0);

    final WalkaCategoryPresentationSnapshot divergent =
        await WalkaCategoryPresentationRepository(
      cache: cache,
      remoteLoader: () async => _payload(
        revision: 9,
        content: WalkaCategoryPresentationContent.bundled,
      ),
    ).load();
    expect(divergent.source, WalkaContentSource.cache);
    expect(divergent.content.categories.first.id, 'drawer-organization');
    expect(cache.writeCount, 0);
  });

  testWidgets('Categories renders CMS order/copy and hides category plus its discovery rows',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final WalkaCatalogController catalog = WalkaCatalogController();
    await catalog.load();
    final WalkaContentController content = WalkaContentController(
      categoryPresentationRepository: WalkaCategoryPresentationRepository(
        cache: _MemoryCategoryCache(),
        remoteLoader: () async => _payload(
          revision: 10,
          content: _customPresentation(),
        ),
      ),
    );
    await content.load();

    await tester.pumpWidget(
      _scopedApp(
        catalog: catalog,
        content: content,
        child: const WalkaCategoriesCmsV124(),
      ),
    );
    await tester.pump();

    expect(find.text('Drawer Studio'), findsOneWidget);
    expect(find.text('Lunch Hidden'), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('reference-category-drawer-organization')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('reference-category-lunch')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('reference-category-drawer-organizer:white')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('reference-category-lunch-box:blue')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Search remains complete even when a category is hidden by CMS-024',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final WalkaCatalogController catalog = WalkaCatalogController();
    await catalog.load();
    final WalkaContentController content = WalkaContentController(
      categoryPresentationRepository: WalkaCategoryPresentationRepository(
        cache: _MemoryCategoryCache(),
        remoteLoader: () async => _payload(
          revision: 11,
          content: _customPresentation(),
        ),
      ),
    );
    await content.load();

    await tester.pumpWidget(
      _scopedApp(
        catalog: catalog,
        content: content,
        child: const WalkaSearchPremiumV123(),
      ),
    );
    await tester.pump();

    expect(find.text('5 results'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _scopedApp({
  required WalkaCatalogController catalog,
  required WalkaContentController content,
  required Widget child,
}) {
  return WalkaContentScope(
    controller: content,
    child: WalkaCatalogScope(
      controller: catalog,
      child: MaterialApp(
        theme: buildWalkaTheme(),
        home: Scaffold(body: child),
      ),
    ),
  );
}

WalkaCategoryPresentationContent _customPresentation() {
  return const WalkaCategoryPresentationContent(
    categories: <WalkaCategoryPresentationItem>[
      WalkaCategoryPresentationItem(
        id: 'drawer-organization',
        displayName: 'Drawer Studio',
        description: 'A calm edit for drawer organization.',
        visible: true,
      ),
      WalkaCategoryPresentationItem(
        id: 'lunch',
        displayName: 'Lunch Hidden',
        description: 'Hidden from Categories while Search stays complete.',
        visible: false,
      ),
    ],
  );
}

class _MemoryCategoryCache implements WalkaCategoryPresentationCache {
  _MemoryCategoryCache({this.value});

  WalkaCategoryPresentationSnapshot? value;
  int writeCount = 0;

  @override
  Future<WalkaCategoryPresentationSnapshot?> read() async => value;

  @override
  Future<void> write(WalkaCategoryPresentationSnapshot snapshot) async {
    writeCount += 1;
    value = snapshot;
  }
}

WalkaCategoryPresentationPayload _payload({
  required int revision,
  required WalkaCategoryPresentationContent content,
}) {
  return WalkaCategoryPresentationPayload(
    content: content,
    revision: revision,
    publishedAt: DateTime.utc(2026, 8, 13, 3),
  );
}

WalkaCategoryPresentationSnapshot _snapshot({
  required int revision,
  required WalkaCategoryPresentationContent content,
}) {
  return WalkaCategoryPresentationSnapshot(
    content: content,
    revision: revision,
    publishedAt: DateTime.utc(2026, 8, 13, 3),
    fetchedAt: DateTime.utc(2026, 8, 13, 3, 5),
    source: WalkaContentSource.cache,
  );
}
