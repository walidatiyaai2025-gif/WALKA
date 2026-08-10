import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_product_visual.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/favorites/favorites_state.dart';
import 'package:walka/features/storefront/secondary_premium_v130.dart';

void main() {
  testWidgets(
    'empty Favorites stays premium on 320x568 at 1.3x text scale',
    (WidgetTester tester) async {
      _setCompactViewport(tester);

      final _MemoryFavoritesStore store = _MemoryFavoritesStore();
      final WalkaFavoritesController favorites = WalkaFavoritesController(store);
      await favorites.load();
      addTearDown(favorites.dispose);

      await tester.pumpWidget(
        WalkaFavoritesScope(
          controller: favorites,
          child: _app(
            home: WalkaFavoritesPremiumV130(onExplore: () {}),
            textScale: 1.3,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('CURATE YOUR EDIT'), findsOneWidget);
      expect(find.text('EXPLORE COLLECTIONS'), findsOneWidget);
      expect(find.bySemanticsLabel('WALKA Drawer Organizer preview'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'saved Drawer favorite preserves product open and removal behavior',
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
            home: WalkaFavoritesPremiumV130(onExplore: () {}),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('GRAY'), findsOneWidget);
      expect(find.textContaining('8 compartments'), findsOneWidget);
      final Finder visualFinder = find.byType(WalkaProductVisual);
      expect(visualFinder, findsOneWidget);
      final WalkaProductVisual visual = tester.widget<WalkaProductVisual>(
        visualFinder,
      );
      expect(visual.semanticLabel, 'WALKA Drawer Organizer Gray favorite');

      await tester.tap(find.text('VIEW PRODUCT'));
      await tester.pumpAndSettle();

      expect(find.text('WALKA Drawer Organizer'), findsOneWidget);
      expect(find.text('BUY ON AMAZON'), findsOneWidget);
      expect(find.text('GRAY'), findsWidgets);
      expect(tester.takeException(), isNull);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Remove Gray from Favorites'));
      await tester.pumpAndSettle();

      expect(favorites.isDrawerFavorite(gray: true), isFalse);
      expect(store.ids, isEmpty);
      expect(find.text('CURATE YOUR EDIT'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Account stays readable on compact width and exposes corrected app info',
    (WidgetTester tester) async {
      _setCompactViewport(tester);

      await tester.pumpWidget(
        _app(
          home: const WalkaAccountPremiumV130(),
          textScale: 1.3,
        ),
      );
      await tester.pump();

      expect(find.text('YOUR WALKA SPACE'), findsOneWidget);
      expect(
        find.textContaining('No account or sign-in is required'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      final Finder scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('PRODUCT & SUPPORT'),
        180,
        scrollable: scrollable,
      );
      expect(find.text('PRODUCT & SUPPORT'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('OFFICIAL DESTINATIONS'),
        180,
        scrollable: scrollable,
      );
      expect(find.text('OFFICIAL DESTINATIONS'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('LEGAL & APP'),
        180,
        scrollable: scrollable,
      );
      expect(find.text('LEGAL & APP'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final Finder appInfo = find.text('App Information');
      await tester.scrollUntilVisible(
        appInfo,
        180,
        scrollable: scrollable,
      );
      await tester.tap(appInfo);
      await tester.pumpAndSettle();

      expect(find.text('1.2.0+120'), findsOneWidget);
      expect(find.text('Versioned WALKA API + local fallback'), findsOneWidget);
      expect(find.text('Official Amazon handoff'), findsOneWidget);
      expect(find.text('1.0.0'), findsNothing);
      expect(
        find.text('Design-first visual freeze before backend integration.'),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );
}

MaterialApp _app({
  required Widget home,
  double textScale = 1,
}) {
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
