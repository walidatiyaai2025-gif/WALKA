import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_product_visual.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/favorites/favorites_state.dart';
import 'package:walka/features/storefront/favorites_reference_v131.dart';

void main() {
  testWidgets(
    'reference Favorites empty state survives 320x568 at 1.3x text scale',
    (WidgetTester tester) async {
      _setCompactViewport(tester);
      final _MemoryFavoritesStore store = _MemoryFavoritesStore();
      final WalkaFavoritesController favorites = WalkaFavoritesController(store);
      await favorites.load();
      addTearDown(favorites.dispose);
      int exploreCount = 0;

      await tester.pumpWidget(
        WalkaFavoritesScope(
          controller: favorites,
          child: _app(
            home: WalkaFavoritesReferenceV131(
              onExplore: () => exploreCount += 1,
            ),
            textScale: 1.3,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('My Favorites'), findsOneWidget);
      expect(find.text('0 items saved'), findsOneWidget);
      expect(find.text('Save your favorites'), findsOneWidget);
      expect(find.text('CONTINUE SHOPPING'), findsOneWidget);
      expect(find.text('Add to Cart'), findsNothing);
      expect(find.textContaining(r'$'), findsNothing);
      expect(tester.takeException(), isNull);

      final Finder explore = find.text('CONTINUE SHOPPING');
      await tester.scrollUntilVisible(
        explore,
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(explore);
      await tester.pump();
      expect(exploreCount, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'reference Favorites renders only persisted Drawer variants honestly',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

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

      expect(find.text('2 items saved'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('reference-favorite-white')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('reference-favorite-gray')),
        findsOneWidget,
      );
      expect(find.byType(WalkaProductVisual), findsNWidgets(2));
      expect(find.text('Lunch Boxes'), findsOneWidget);
      expect(find.text('Add to Cart'), findsNothing);
      expect(find.text('4.8'), findsNothing);
      expect(find.text('4.7'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'reference Favorites keeps edit removal persistence',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

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
            home: WalkaFavoritesReferenceV131(onExplore: () {}),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(
        find.byKey(const ValueKey<String>('reference-favorites-edit')),
      );
      await tester.pump();
      expect(find.text('DONE'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey<String>('reference-remove-gray')),
      );
      await tester.pumpAndSettle();

      expect(favorites.isDrawerFavorite(gray: true), isFalse);
      expect(store.ids, isEmpty);
      expect(find.text('Save your favorites'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'saved favorite still opens final stable Drawer PDP',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final _MemoryFavoritesStore store = _MemoryFavoritesStore(
        <String>{WalkaFavoritesController.drawerWhiteId},
      );
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

      await tester.tap(find.text('VIEW PRODUCT'));
      await tester.pumpAndSettle();

      expect(find.text('WALKA Drawer Organizer'), findsOneWidget);
      expect(find.text('BUY ON AMAZON'), findsOneWidget);
      expect(find.text('WHITE'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
}

MaterialApp _app({required Widget home, double textScale = 1}) {
  return MaterialApp(
    theme: buildWalkaTheme(),
    builder: (BuildContext context, Widget? child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      );
    },
    home: home,
  );
}

void _setCompactViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

class _MemoryFavoritesStore implements WalkaFavoritesStore {
  _MemoryFavoritesStore([Set<String>? initialIds])
      : ids = Set<String>.from(initialIds ?? const <String>{});

  Set<String> ids;

  @override
  Future<Set<String>> readFavoriteIds() async => Set<String>.from(ids);

  @override
  Future<void> writeFavoriteIds(Set<String> favoriteIds) async {
    ids = Set<String>.from(favoriteIds);
  }
}
