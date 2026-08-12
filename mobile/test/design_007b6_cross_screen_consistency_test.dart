import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_product_visual.dart';
import 'package:walka/design_system/walka_reference_ui.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/catalog/catalog_state.dart';
import 'package:walka/features/favorites/favorites_state.dart';
import 'package:walka/features/storefront/account_about_reference_v131.dart';
import 'package:walka/features/storefront/discovery_reference_v123.dart';
import 'package:walka/features/storefront/favorites_reference_v131.dart';
import 'package:walka/features/storefront/home_premium_v122.dart';

void main() {
  testWidgets(
    'primary reference screens share one WALKA chrome contract at compact scale',
    (WidgetTester tester) async {
      _setViewport(tester, const Size(320, 568));
      final WalkaCatalogController catalog = WalkaCatalogController();
      addTearDown(catalog.dispose);
      final _MemoryFavoritesStore store = _MemoryFavoritesStore(
        <String>{WalkaFavoritesController.drawerWhiteId},
      );
      final WalkaFavoritesController favorites =
          WalkaFavoritesController(store);
      await favorites.load();
      addTearDown(favorites.dispose);

      final List<Widget> catalogScreens = <Widget>[
        WalkaHomePremiumV122(onShopAll: () {}, onSearch: () {}),
        const WalkaCategoriesPremiumV123(),
        const WalkaSearchPremiumV123(),
      ];
      for (final Widget screen in catalogScreens) {
        await tester.pumpWidget(
          _app(
            child: WalkaCatalogScope(controller: catalog, child: screen),
            textScale: 1.3,
          ),
        );
        await tester.pump();
        _expectReferenceWordmarkContract(tester);
        expect(tester.takeException(), isNull);
      }

      await tester.pumpWidget(
        _app(
          child: WalkaFavoritesScope(
            controller: favorites,
            child: WalkaFavoritesReferenceV131(onExplore: () {}),
          ),
          textScale: 1.3,
        ),
      );
      await tester.pump();
      _expectReferenceWordmarkContract(tester);
      // This fixture contains only Drawer White, which is now admitted media.
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(WalkaProductVisual), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        _app(
          child: WalkaAccountReferenceV131(onFavorites: () {}),
          textScale: 1.3,
        ),
      );
      await tester.pump();
      _expectReferenceWordmarkContract(tester);
      expect(tester.takeException(), isNull);
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );

  testWidgets(
    'shared reference header component locks geometry and action semantics',
    (WidgetTester tester) async {
      _setViewport(tester, const Size(390, 844));
      int leadingCount = 0;
      int trailingCount = 0;

      await tester.pumpWidget(
        _app(
          child: WalkaReferenceViewport(
            child: Align(
              alignment: Alignment.topCenter,
              child: WalkaReferenceHeader(
                headerKey: const ValueKey<String>('contract-header'),
                leadingIcon: Icons.menu_rounded,
                leadingKey: const ValueKey<String>('contract-leading'),
                leadingTooltip: 'Browse',
                onLeading: () => leadingCount += 1,
                trailingIcon: Icons.search_rounded,
                trailingKey: const ValueKey<String>('contract-trailing'),
                trailingTooltip: 'Search',
                onTrailing: () => trailingCount += 1,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final Finder header = find.byKey(
        const ValueKey<String>('contract-header'),
      );
      expect(header, findsOneWidget);
      expect(tester.getSize(header).height, WalkaReferenceUi.headerExtent);
      _expectReferenceWordmarkContract(tester, screenWidth: 390);

      await tester.tap(
        find.byKey(const ValueKey<String>('contract-leading')),
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('contract-trailing')),
      );
      await tester.pump();
      expect(leadingCount, 1);
      expect(trailingCount, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'reference product media remains present across Home Categories and Favorites',
    (WidgetTester tester) async {
      _setViewport(tester, const Size(390, 844));
      final WalkaCatalogController catalog = WalkaCatalogController();
      addTearDown(catalog.dispose);
      final _MemoryFavoritesStore store = _MemoryFavoritesStore(
        <String>{WalkaFavoritesController.drawerGrayId},
      );
      final WalkaFavoritesController favorites =
          WalkaFavoritesController(store);
      await favorites.load();
      addTearDown(favorites.dispose);

      await tester.pumpWidget(
        _app(
          child: WalkaCatalogScope(
            controller: catalog,
            child: WalkaHomePremiumV122(onShopAll: () {}, onSearch: () {}),
          ),
        ),
      );
      await tester.pump();
      // Owner-visible surfaces may show admitted Image media or quarantined
      // painted fallback media depending on the exact variants visible.
      expect(
        find.byType(Image).evaluate().isNotEmpty ||
            find.byType(WalkaProductVisual).evaluate().isNotEmpty,
        isTrue,
      );
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        _app(
          child: WalkaCatalogScope(
            controller: catalog,
            child: const WalkaCategoriesPremiumV123(),
          ),
        ),
      );
      await tester.pump();
      expect(
        find.byType(Image).evaluate().isNotEmpty ||
            find.byType(WalkaProductVisual).evaluate().isNotEmpty,
        isTrue,
      );
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        _app(
          child: WalkaFavoritesScope(
            controller: favorites,
            child: WalkaFavoritesReferenceV131(onExplore: () {}),
          ),
        ),
      );
      await tester.pump();
      // This Favorites fixture persists Gray only, so it remains quarantined.
      expect(find.byType(WalkaProductVisual), findsWidgets);
      expect(find.byType(Image), findsNothing);
      expect(tester.takeException(), isNull);
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}

Widget _app({required Widget child, double textScale = 1}) {
  return MaterialApp(
    theme: buildWalkaTheme(),
    builder: (BuildContext context, Widget? builtChild) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
        ),
        child: builtChild!,
      );
    },
    home: Scaffold(body: child),
  );
}

void _expectReferenceWordmarkContract(
  WidgetTester tester, {
  double screenWidth = 320,
}) {
  final Finder wordmarkFinder = find.text('WALKA').first;
  expect(wordmarkFinder, findsOneWidget);
  final Text wordmark = tester.widget<Text>(wordmarkFinder);
  expect(wordmark.style, WalkaReferenceUi.wordmarkStyle);

  final Offset topLeft = tester.getTopLeft(wordmarkFinder);
  final Size size = tester.getSize(wordmarkFinder);
  final double center = topLeft.dx + (size.width / 2);
  expect((center - (screenWidth / 2)).abs(), lessThan(1.0));
  expect(topLeft.dy, lessThan(40));
}

void _setViewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

class _MemoryFavoritesStore implements WalkaFavoritesStore {
  _MemoryFavoritesStore(Set<String> initialIds)
      : ids = Set<String>.from(initialIds);

  Set<String> ids;

  @override
  Future<Set<String>> readFavoriteIds() async => Set<String>.from(ids);

  @override
  Future<void> writeFavoriteIds(Set<String> favoriteIds) async {
    ids = Set<String>.from(favoriteIds);
  }
}
