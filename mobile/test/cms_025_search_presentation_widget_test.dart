import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/catalog/catalog_state.dart';
import 'package:walka/features/content/content_state.dart';
import 'package:walka/features/content/data/walka_search_presentation_cache.dart';
import 'package:walka/features/content/data/walka_search_presentation_repository.dart';
import 'package:walka/features/content/domain/walka_search_presentation_content.dart';
import 'package:walka/features/storefront/discovery_reference_v123.dart';

class _MemorySearchCache implements WalkaSearchPresentationCache {
  WalkaSearchPresentationSnapshot? value;

  @override
  Future<WalkaSearchPresentationSnapshot?> read() async => value;

  @override
  Future<void> write(WalkaSearchPresentationSnapshot snapshot) async {
    value = snapshot;
  }
}

Future<WalkaContentController> _contentController() async {
  final WalkaSearchPresentationContent content =
      WalkaSearchPresentationContent.fromJson(<String, dynamic>{
    ...WalkaSearchPresentationContent.bundled.toJson(),
    'heading': 'Find your WALKA fit',
    'supporting_copy': 'CMS search copy from the published presentation.',
    'placeholder': 'Find an organizer…',
    'empty_title': 'Nothing matched',
    'empty_body': 'Try a different WALKA detail.',
    'featured_variant_ids': <String>[
      'lunch-box:green',
      'drawer-organizer:gray',
      'lunch-box:blue',
      'drawer-organizer:white',
      'lunch-box:pink',
    ],
    'filter_labels': <Map<String, dynamic>>[
      <String, dynamic>{'id': 'all', 'label': 'Everything'},
      <String, dynamic>{'id': 'drawer-organization', 'label': 'Drawer edit'},
      <String, dynamic>{'id': 'lunch', 'label': 'Lunch edit'},
    ],
  });
  final WalkaContentController controller = WalkaContentController(
    searchPresentationRepository: WalkaSearchPresentationRepository(
      cache: _MemorySearchCache(),
      remoteLoader: () async => WalkaSearchPresentationPayload(
        content: content,
        revision: 4,
        publishedAt: DateTime.utc(2026, 8, 13, 4),
      ),
    ),
  );
  await controller.load();
  return controller;
}

Widget _app({
  required WalkaContentController content,
  required WalkaCatalogController catalog,
}) {
  return WalkaContentScope(
    controller: content,
    child: WalkaCatalogScope(
      controller: catalog,
      child: MaterialApp(
        theme: buildWalkaTheme(),
        home: const Scaffold(body: WalkaSearchPremiumV123()),
      ),
    ),
  );
}

void main() {
  testWidgets('Search renders published CMS copy and filter labels',
      (WidgetTester tester) async {
    final WalkaContentController content = await _contentController();
    final WalkaCatalogController catalog = WalkaCatalogController();
    addTearDown(content.dispose);
    addTearDown(catalog.dispose);

    await tester.pumpWidget(_app(content: content, catalog: catalog));
    await tester.pumpAndSettle();

    expect(find.text('Find your WALKA fit'), findsOneWidget);
    expect(find.text('CMS search copy from the published presentation.'),
        findsOneWidget);
    expect(find.text('Everything'), findsOneWidget);
    expect(find.text('Drawer edit'), findsOneWidget);
    expect(find.text('Lunch edit'), findsOneWidget);
    final TextField field = tester.widget<TextField>(
      find.byKey(const ValueKey<String>('premium-discovery-search-field')),
    );
    expect(field.decoration?.hintText, 'Find an organizer…');
  });

  testWidgets('CMS Featured order changes default order without removing catalog',
      (WidgetTester tester) async {
    final WalkaContentController content = await _contentController();
    final WalkaCatalogController catalog = WalkaCatalogController();
    addTearDown(content.dispose);
    addTearDown(catalog.dispose);

    await tester.pumpWidget(_app(content: content, catalog: catalog));
    await tester.pumpAndSettle();

    expect(find.text('5 results'), findsOneWidget);
    final Finder green = find.byKey(
      const ValueKey<String>('discovery-search-lunch-box:green'),
    );
    final Finder white = find.byKey(
      const ValueKey<String>('discovery-search-drawer-organizer:white'),
    );
    expect(green, findsOneWidget);
    expect(white, findsOneWidget);
    expect(tester.getTopLeft(green).dy, lessThan(tester.getTopLeft(white).dy));
  });

  testWidgets('query matching remains complete and CMS cannot hide a match',
      (WidgetTester tester) async {
    final WalkaContentController content = await _contentController();
    final WalkaCatalogController catalog = WalkaCatalogController();
    addTearDown(content.dispose);
    addTearDown(catalog.dispose);

    await tester.pumpWidget(_app(content: content, catalog: catalog));
    await tester.enterText(
      find.byKey(const ValueKey<String>('premium-discovery-search-field')),
      'pink',
    );
    await tester.pump();

    expect(find.text('1 result'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('discovery-search-lunch-box:pink')),
      findsOneWidget,
    );
  });

  for (final double width in <double>[320, 390, 430, 1280]) {
    testWidgets('Search stays overflow-safe at ${width.toInt()}px and 1.3x text',
        (WidgetTester tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final WalkaContentController content = await _contentController();
      final WalkaCatalogController catalog = WalkaCatalogController();
      addTearDown(content.dispose);
      addTearDown(catalog.dispose);

      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            size: Size(width, 900),
            textScaler: const TextScaler.linear(1.3),
          ),
          child: _app(content: content, catalog: catalog),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Find your WALKA fit'), findsOneWidget);
    });
  }
}
