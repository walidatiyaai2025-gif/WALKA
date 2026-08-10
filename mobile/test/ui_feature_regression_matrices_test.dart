import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/features/catalog/catalog_state.dart';
import 'package:walka/features/favorites/favorites_state.dart';
import 'package:walka/features/lunch/lunch_box_v6.dart';
import 'package:walka/features/products/product_experience_v100.dart';
import 'package:walka/features/storefront/discovery_reference_v123.dart';
import 'package:walka/features/storefront/favorites_reference_v131.dart';
import 'package:walka/features/storefront/home_premium_v122.dart';

import 'support/walka_test_harness.dart';

void main() {
  const List<WalkaTestDevice> homeDevices = <WalkaTestDevice>[
    WalkaTestDevice.androidCompact,
    WalkaTestDevice.androidStandard,
    WalkaTestDevice.androidComfortable,
    WalkaTestDevice.iosPhone,
    WalkaTestDevice.desktop1280,
    WalkaTestDevice.desktop1440,
  ];

  for (final WalkaTestDevice device in homeDevices) {
    testWidgets('HOME-013 Home survives ${device.name}',
        (WidgetTester tester) async {
      final _HarnessState state = await _state(
        favorites: <String>{WalkaFavoritesController.drawerWhiteId},
      );
      addTearDown(state.dispose);

      await tester.pumpWidget(
        _app(
          state: state,
          device: device,
          textScale: device.size.width <= 320 ? 1.3 : 1,
          child: WalkaHomePremiumV122(onShopAll: () {}, onSearch: () {}),
        ),
      );
      await tester.pump();

      expect(find.text('WALKA'), findsWidgets);
      expect(find.textContaining('Organize Better.'), findsOneWidget);
      expect(find.textContaining('Premium drawer organizers'), findsOneWidget);
      await _scroll(tester, 4);
      expect(tester.takeException(), isNull, reason: device.name);
    });
  }

  testWidgets('CAT-015 Categories/Search matrix covers compact iOS and desktop',
      (WidgetTester tester) async {
    for (final WalkaTestDevice device in <WalkaTestDevice>[
      WalkaTestDevice.androidCompact,
      WalkaTestDevice.androidStandard,
      WalkaTestDevice.iosPhone,
      WalkaTestDevice.desktop1280,
    ]) {
      final _HarnessState state = await _state();
      addTearDown(state.dispose);

      await tester.pumpWidget(
        _app(
          state: state,
          device: device,
          textScale: device.size.width <= 320 ? 1.3 : 1,
          child: const WalkaCategoriesPremiumV123(),
        ),
      );
      await tester.pump();
      expect(
        find.byKey(const ValueKey<String>('reference-categories-title')),
        findsOneWidget,
      );
      await _scroll(tester, 4);
      expect(tester.takeException(), isNull, reason: 'Categories ${device.name}');

      await tester.pumpWidget(
        _app(
          state: state,
          device: device,
          textScale: device.size.width <= 320 ? 1.3 : 1,
          child: const WalkaSearchPremiumV123(),
        ),
      );
      await tester.pump();
      expect(find.text('Search WALKA'), findsWidgets);
      expect(find.byType(TextField), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Search ${device.name}');
    }
  });

  testWidgets('PDP-017 Drawer/Lunch matrix preserves gallery actions and Amazon CTA',
      (WidgetTester tester) async {
    for (final WalkaTestDevice device in <WalkaTestDevice>[
      WalkaTestDevice.androidCompact,
      WalkaTestDevice.androidStandard,
      WalkaTestDevice.iosPhone,
      WalkaTestDevice.desktop1280,
    ]) {
      final _HarnessState state = await _state();
      addTearDown(state.dispose);

      for (final Widget product in <Widget>[
        const WalkaDrawerProductDetailV100(initialGray: true),
        const WalkaLunchProductDetailV100(
          initialVariant: WalkaLunchVariant.green,
        ),
      ]) {
        await tester.pumpWidget(
          _app(
            state: state,
            device: device,
            textScale: device.size.width <= 320 ? 1.3 : 1,
            child: product,
            scaffold: false,
          ),
        );
        await tester.pump();

        expect(find.text('BUY ON AMAZON'), findsOneWidget);
        expect(find.byTooltip('Share product'), findsOneWidget);
        expect(find.byTooltip('View fullscreen'), findsOneWidget);
        expect(find.text('1 / 3'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'PDP ${device.name}');
      }
    }
  });

  testWidgets('PDP-017 variant and favorite behavior remain interactive',
      (WidgetTester tester) async {
    final _HarnessState state = await _state();
    addTearDown(state.dispose);

    await tester.pumpWidget(
      _app(
        state: state,
        device: WalkaTestDevice.androidStandard,
        child: const WalkaDrawerProductDetailV100(),
        scaffold: false,
      ),
    );
    await tester.pump();

    expect(find.byTooltip('Add favorite'), findsOneWidget);
    await tester.tap(find.byTooltip('Add favorite'));
    await tester.pumpAndSettle();
    expect(state.favorites.isDrawerFavorite(gray: false), isTrue);
    expect(find.byTooltip('Remove favorite'), findsOneWidget);

    final Finder gray = find.byKey(const ValueKey<String>('premium-drawer-gray'));
    await tester.ensureVisible(gray);
    await tester.tap(gray);
    await tester.pump();
    expect(find.textContaining('Gray finish'), findsOneWidget);
  });

  testWidgets('FAV-011 empty/saved matrix is stable on compact iOS and desktop',
      (WidgetTester tester) async {
    for (final WalkaTestDevice device in <WalkaTestDevice>[
      WalkaTestDevice.androidCompact,
      WalkaTestDevice.iosPhone,
      WalkaTestDevice.desktop1280,
    ]) {
      final _HarnessState empty = await _state();
      addTearDown(empty.dispose);
      await tester.pumpWidget(
        _app(
          state: empty,
          device: device,
          textScale: device.size.width <= 320 ? 1.3 : 1,
          child: WalkaFavoritesReferenceV131(onExplore: () {}),
        ),
      );
      await tester.pump();
      expect(find.text('Save your favorites'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'empty ${device.name}');

      final _HarnessState saved = await _state(
        favorites: <String>{
          WalkaFavoritesController.drawerWhiteId,
          WalkaFavoritesController.drawerGrayId,
        },
      );
      addTearDown(saved.dispose);
      await tester.pumpWidget(
        _app(
          state: saved,
          device: device,
          textScale: device.size.width <= 320 ? 1.3 : 1,
          child: WalkaFavoritesReferenceV131(onExplore: () {}),
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
      expect(tester.takeException(), isNull, reason: 'saved ${device.name}');
    }
  });

  testWidgets('FAV-011 removal persists through controller reload',
      (WidgetTester tester) async {
    final _MemoryFavoritesStore store = _MemoryFavoritesStore(<String>{
      WalkaFavoritesController.drawerWhiteId,
      WalkaFavoritesController.drawerGrayId,
    });
    final _HarnessState state = await _state(store: store);
    addTearDown(state.dispose);

    await tester.pumpWidget(
      _app(
        state: state,
        device: WalkaTestDevice.androidStandard,
        child: WalkaFavoritesReferenceV131(onExplore: () {}),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey<String>('reference-remove-white')));
    await tester.pumpAndSettle();
    expect(state.favorites.isDrawerFavorite(gray: false), isFalse);

    final WalkaFavoritesController reloaded = WalkaFavoritesController(store);
    await reloaded.load();
    addTearDown(reloaded.dispose);
    expect(reloaded.isDrawerFavorite(gray: false), isFalse);
    expect(reloaded.isDrawerFavorite(gray: true), isTrue);
  });
}

Widget _app({
  required _HarnessState state,
  required WalkaTestDevice device,
  required Widget child,
  double textScale = 1,
  bool scaffold = true,
}) {
  return WalkaTestHarness(
    device: device,
    textScale: textScale,
    child: WalkaCatalogScope(
      controller: state.catalog,
      child: WalkaFavoritesScope(
        controller: state.favorites,
        child: scaffold ? Scaffold(body: child) : child,
      ),
    ),
  );
}

Future<_HarnessState> _state({
  Set<String> favorites = const <String>{},
  _MemoryFavoritesStore? store,
}) async {
  final WalkaCatalogController catalog = WalkaCatalogController();
  final _MemoryFavoritesStore actualStore =
      store ?? _MemoryFavoritesStore(favorites);
  final WalkaFavoritesController favoriteController =
      WalkaFavoritesController(actualStore);
  await favoriteController.load();
  return _HarnessState(catalog, favoriteController);
}

Future<void> _scroll(WidgetTester tester, int passes) async {
  final Finder scroll = find.byType(CustomScrollView);
  if (scroll.evaluate().isEmpty) return;
  for (int index = 0; index < passes; index += 1) {
    await tester.drag(scroll.first, const Offset(0, -320));
    await tester.pumpAndSettle();
  }
}

class _HarnessState {
  _HarnessState(this.catalog, this.favorites);

  final WalkaCatalogController catalog;
  final WalkaFavoritesController favorites;

  void dispose() {
    favorites.dispose();
    catalog.dispose();
  }
}

class _MemoryFavoritesStore implements WalkaFavoritesStore {
  _MemoryFavoritesStore([Set<String>? initial])
      : ids = Set<String>.from(initial ?? const <String>{});

  Set<String> ids;

  @override
  Future<Set<String>> readFavoriteIds() async => Set<String>.from(ids);

  @override
  Future<void> writeFavoriteIds(Set<String> favoriteIds) async {
    ids = Set<String>.from(favoriteIds);
  }
}
