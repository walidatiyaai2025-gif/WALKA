import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/catalog/catalog_state.dart';
import 'package:walka/features/favorites/favorites_state.dart';
import 'package:walka/features/storefront/discovery_reference_v123.dart';
import 'package:walka/features/storefront/favorites_reference_v131.dart';
import 'package:walka/features/storefront/home_premium_v122.dart';

class _MemoryFavoritesStore implements WalkaFavoritesStore {
  _MemoryFavoritesStore([Set<String>? ids])
      : ids = Set<String>.from(ids ?? const <String>{});

  Set<String> ids;

  @override
  Future<Set<String>> readFavoriteIds() async => Set<String>.from(ids);

  @override
  Future<void> writeFavoriteIds(Set<String> favoriteIds) async {
    ids = Set<String>.from(favoriteIds);
  }
}

void _setView(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

MaterialApp _app({
  required Widget home,
  double textScale = 1,
  TargetPlatform platform = TargetPlatform.android,
  EdgeInsets padding = EdgeInsets.zero,
}) {
  return MaterialApp(
    theme: buildWalkaTheme().copyWith(platform: platform),
    builder: (BuildContext context, Widget? child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          padding: padding,
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      );
    },
    home: home,
  );
}

void main() {
  testWidgets('HOME-011 keeps iOS safe-area and 1.3x layout stable',
      (WidgetTester tester) async {
    _setView(tester, const Size(390, 844));
    final WalkaCatalogController catalog = WalkaCatalogController();
    addTearDown(catalog.dispose);

    await tester.pumpWidget(
      WalkaCatalogScope(
        controller: catalog,
        child: _app(
          platform: TargetPlatform.iOS,
          padding: const EdgeInsets.fromLTRB(0, 47, 0, 34),
          textScale: 1.3,
          home: Scaffold(
            body: WalkaHomePremiumV122(onShopAll: () {}, onSearch: () {}),
          ),
        ),
      ),
    );
    await tester.pump();

    final Rect header = tester.getRect(
      find.byKey(const ValueKey<String>('home-reference-header')),
    );
    expect(header.top, greaterThanOrEqualTo(47));
    expect(find.text('Organize Better.\nLive Better.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final double width in <double>[1280, 1440]) {
    testWidgets('HOME-012 uses wide composition at ${width.toInt()}px',
        (WidgetTester tester) async {
      _setView(tester, Size(width, 1000));
      final WalkaCatalogController catalog = WalkaCatalogController();
      addTearDown(catalog.dispose);

      await tester.pumpWidget(
        WalkaCatalogScope(
          controller: catalog,
          child: _app(
            home: Scaffold(
              body: WalkaHomePremiumV122(onShopAll: () {}, onSearch: () {}),
            ),
          ),
        ),
      );
      await tester.pump();

      final Size frame = tester.getSize(
        find.byKey(const ValueKey<String>('walka-home-responsive-frame')),
      );
      expect(frame.width, greaterThan(560));
      expect(frame.width, lessThanOrEqualTo(1200));
      expect(find.text('Organize Better.\nLive Better.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('HOME-013 keeps compact actions and catalog truth',
      (WidgetTester tester) async {
    _setView(tester, const Size(320, 568));
    final WalkaCatalogController catalog = WalkaCatalogController();
    addTearDown(catalog.dispose);
    var browse = 0;
    var search = 0;

    await tester.pumpWidget(
      WalkaCatalogScope(
        controller: catalog,
        child: _app(
          textScale: 1.3,
          home: Scaffold(
            body: WalkaHomePremiumV122(
              onShopAll: () => browse += 1,
              onSearch: () => search += 1,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final IconButton browseButton = tester.widget<IconButton>(
      find.byKey(const ValueKey<String>('home-reference-browse')),
    );
    final IconButton searchButton = tester.widget<IconButton>(
      find.byKey(const ValueKey<String>('home-reference-search')),
    );
    browseButton.onPressed!();
    searchButton.onPressed!();
    expect(browse, 1);
    expect(search, 1);
    expect(find.textContaining('10K'), findsNothing);
    expect(find.textContaining('4.8/5'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('CAT-013 keeps iOS safe-area and all released catalog behavior',
      (WidgetTester tester) async {
    _setView(tester, const Size(390, 844));
    final WalkaCatalogController catalog = WalkaCatalogController();
    addTearDown(catalog.dispose);
    var searches = 0;

    await tester.pumpWidget(
      WalkaCatalogScope(
        controller: catalog,
        child: _app(
          platform: TargetPlatform.iOS,
          padding: const EdgeInsets.fromLTRB(0, 47, 0, 34),
          textScale: 1.3,
          home: Scaffold(
            body: WalkaCategoriesPremiumV123(
              onSearch: () => searches += 1,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final Rect header = tester.getRect(
      find.byKey(const ValueKey<String>('reference-discovery-header')),
    );
    expect(header.top, greaterThanOrEqualTo(47));
    final IconButton searchButton = tester.widget<IconButton>(
      find.byKey(const ValueKey<String>('reference-discovery-trailing')),
    );
    searchButton.onPressed!();
    expect(searches, 1);
    expect(find.text('Categories'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final Size size in <Size>[Size(320, 568), Size(430, 900)]) {
    testWidgets('CAT-015 categories regression ${size.width.toInt()}px',
        (WidgetTester tester) async {
      _setView(tester, size);
      final WalkaCatalogController catalog = WalkaCatalogController();
      addTearDown(catalog.dispose);

      await tester.pumpWidget(
        WalkaCatalogScope(
          controller: catalog,
          child: _app(
            textScale: size.width == 320 ? 1.3 : 1,
            home: const Scaffold(body: WalkaCategoriesPremiumV123()),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Lunch Boxes'), findsOneWidget);
      expect(find.text('Drawer Organizers'), findsOneWidget);
      expect(find.textContaining(r'$'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('FAV-009 respects iOS notch/home-indicator with saved variants',
      (WidgetTester tester) async {
    _setView(tester, const Size(390, 844));
    final _MemoryFavoritesStore store = _MemoryFavoritesStore(<String>{
      WalkaFavoritesController.drawerWhiteId,
      WalkaFavoritesController.drawerGrayId,
    });
    final WalkaFavoritesController favorites = WalkaFavoritesController(store);
    await favorites.load();
    addTearDown(favorites.dispose);

    await tester.pumpWidget(
      WalkaFavoritesScope(
        controller: favorites,
        child: _app(
          platform: TargetPlatform.iOS,
          padding: const EdgeInsets.fromLTRB(0, 47, 0, 34),
          textScale: 1.3,
          home: WalkaFavoritesReferenceV131(onExplore: () {}),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('2 items saved'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('reference-favorite-white')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('reference-favorite-gray')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  for (final double width in <double>[1280, 1440]) {
    testWidgets('FAV-010 uses PC-width two-card composition at ${width.toInt()}px',
        (WidgetTester tester) async {
      _setView(tester, Size(width, 900));
      final _MemoryFavoritesStore store = _MemoryFavoritesStore(<String>{
        WalkaFavoritesController.drawerWhiteId,
        WalkaFavoritesController.drawerGrayId,
      });
      final WalkaFavoritesController favorites = WalkaFavoritesController(store);
      await favorites.load();
      addTearDown(favorites.dispose);

      await tester.pumpWidget(
        WalkaFavoritesScope(
          controller: favorites,
          child: _app(
            home: WalkaFavoritesReferenceV131(onExplore: () {}),
          ),
        ),
      );
      await tester.pump();

      final Size frame = tester.getSize(
        find.byKey(const ValueKey<String>('walka-favorites-responsive-frame')),
      );
      expect(frame.width, greaterThan(560));
      expect(frame.width, lessThanOrEqualTo(1200));
      expect(
        find.byKey(const ValueKey<String>('walka-favorites-card-grid')),
        findsOneWidget,
      );
      expect(find.text('2 items saved'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('FAV-011 keeps local persistence and truthful empty flow',
      (WidgetTester tester) async {
    _setView(tester, const Size(320, 568));
    final _MemoryFavoritesStore store = _MemoryFavoritesStore(
      <String>{WalkaFavoritesController.drawerGrayId},
    );
    final WalkaFavoritesController favorites = WalkaFavoritesController(store);
    await favorites.load();
    addTearDown(favorites.dispose);

    await tester.pumpWidget(
      WalkaFavoritesScope(
        controller: favorites,
        child: _app(
          textScale: 1.3,
          home: WalkaFavoritesReferenceV131(onExplore: () {}),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('1 item saved'), findsOneWidget);
    final Finder edit = find.byKey(
      const ValueKey<String>('reference-favorites-edit'),
    );
    await tester.ensureVisible(edit);
    final InkWell editControl = tester.widget<InkWell>(
      find.descendant(of: edit, matching: find.byType(InkWell)),
    );
    editControl.onTap!();
    await tester.pump();

    final Finder remove = find.byKey(const ValueKey<String>('reference-remove-gray'));
    await tester.ensureVisible(remove);
    final IconButton removeControl = tester.widget<IconButton>(remove);
    removeControl.onPressed!();
    await tester.pumpAndSettle();
    expect(favorites.isDrawerFavorite(gray: true), isFalse);
    expect(store.ids, isEmpty);
    expect(find.text('Save your favorites'), findsOneWidget);
    expect(find.textContaining(r'$'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
