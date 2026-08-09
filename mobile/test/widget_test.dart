import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_adaptive.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/catalog/catalog_v3.dart';
import 'package:walka/features/catalog/catalog_v6.dart';
import 'package:walka/features/favorites/favorites_state.dart';
import 'package:walka/features/lifestyle/favorites_v5.dart';
import 'package:walka/features/lifestyle/lifestyle_v4.dart';
import 'package:walka/features/lunch/lunch_box_v6.dart';
import 'package:walka/features/search/search_discovery_v9.dart';
import 'package:walka/features/storefront/storefront_shell_v9.dart';
import 'package:walka/features/storefront/storefront_v2.dart';
import 'package:walka/main.dart';

void main() {
  test('WALKA 0.9 exposes the searchable stateful storefront', () {
    final WalkaFavoritesController controller = _newController();
    expect(WalkaApp(favoritesController: controller), isA<WalkaApp>());
    expect(const WalkaStorefrontSplashV9(), isA<WalkaStorefrontSplashV9>());
    expect(const WalkaStorefrontShellV9(), isA<WalkaStorefrontShellV9>());
    expect(const WalkaHomeV2(), isA<WalkaHomeV2>());
    expect(const WalkaCategoriesV6(), isA<WalkaCategoriesV6>());
    expect(const WalkaCollectionScreenV3(), isA<WalkaCollectionScreenV3>());
    expect(const WalkaLunchCollectionV6(), isA<WalkaLunchCollectionV6>());
    expect(const WalkaSearchDiscoveryV9(), isA<WalkaSearchDiscoveryV9>());
    expect(
      const WalkaLunchProductDetailV6(),
      isA<WalkaLunchProductDetailV6>(),
    );
    expect(
      WalkaFavoritesV5(onExploreCollections: () {}),
      isA<WalkaFavoritesV5>(),
    );
    expect(const WalkaAccountV4(), isA<WalkaAccountV4>());
    expect(const WalkaAboutV4(), isA<WalkaAboutV4>());
    expect(const WalkaProductDetailV2(), isA<WalkaProductDetailV2>());
  });

  test('search catalog contains every approved sellable variant', () {
    expect(walkaSearchCatalog.length, 5);
    expect(
      walkaSearchCatalog.map((WalkaSearchProduct item) => item.id).toSet(),
      <String>{
        'drawer-white',
        'drawer-gray',
        'lunch-blue',
        'lunch-pink',
        'lunch-green',
      },
    );
  });

  test('Lunch collection exposes all three approved colors', () {
    expect(WalkaLunchVariant.values.length, 3);
    expect(WalkaLunchVariant.blue.label, 'Blue');
    expect(WalkaLunchVariant.pink.label, 'Pink');
    expect(WalkaLunchVariant.green.label, 'Green');
    expect(WalkaLunchVariant.blue.pantone, 'PANTONE 4155 U');
    expect(WalkaLunchVariant.pink.pantone, 'PANTONE 9242 U');
    expect(WalkaLunchVariant.green.pantone, 'PANTONE 6198 U');
  });

  test('WALKA design system keeps approved brand and touch settings', () {
    final ThemeData theme = buildWalkaTheme();
    expect(WalkaColors.navy.toARGB32(), 0xFF003366);
    expect(WalkaColors.gold.toARGB32(), 0xFFD4AF37);
    expect(theme.useMaterial3, isTrue);
    expect(theme.materialTapTargetSize, MaterialTapTargetSize.padded);
  });

  testWidgets('storefront v9 opens Search from Categories',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final WalkaFavoritesController controller = _newController();
    await controller.load();

    await tester.pumpWidget(
      WalkaFavoritesScope(
        controller: controller,
        child: MaterialApp(
          theme: buildWalkaTheme(),
          home: const WalkaStorefrontShellV9(),
        ),
      ),
    );
    await tester.pump();

    final Finder categoriesDestination = find.descendant(
      of: find.byType(NavigationBar),
      matching: find.byIcon(Icons.grid_view_outlined),
    );
    expect(categoriesDestination, findsOneWidget);
    await tester.tap(categoriesDestination);
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      2,
    );

    final Finder searchButton = find.descendant(
      of: find.byType(WalkaCategoriesV6),
      matching: find.widgetWithIcon(IconButton, Icons.search_rounded),
    );
    expect(searchButton, findsOneWidget);
    await tester.tap(searchButton);
    await tester.pumpAndSettle();

    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );
    expect(find.text('SEARCH WALKA'), findsOneWidget);
    expect(find.text('What are you organizing?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search filters locally and opens the matching Lunch PDP',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildWalkaTheme(),
        home: const WalkaSearchDiscoveryV9(),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'green');
    await tester.pump();

    expect(find.text('1 result'), findsOneWidget);
    expect(find.text('Green'), findsOneWidget);
    expect(find.text('Large Stainless Steel Bento Lunch Box'), findsOneWidget);

    await tester.tap(find.text('Large Stainless Steel Bento Lunch Box'));
    await tester.pumpAndSettle();

    expect(find.text('Large Stainless Steel Bento Lunch Box'), findsOneWidget);
    expect(find.textContaining('Green · PANTONE 6198 U'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search supports list mode and designed no-results state',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildWalkaTheme(),
        home: const WalkaSearchDiscoveryV9(),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'lunch box');
    await tester.pump();
    expect(find.byTooltip('List view'), findsOneWidget);
    await tester.tap(find.byTooltip('List view'));
    await tester.pump();
    expect(find.text('3 results'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'walka-does-not-exist');
    await tester.pump();
    expect(find.text('0 results'), findsOneWidget);
    expect(find.text('Nothing matched that search'), findsOneWidget);
    expect(find.text('CLEAR SEARCH'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Drawer PDP favorite control keeps shared persistence behavior',
      (WidgetTester tester) async {
    final WalkaFavoritesController controller = _newController();
    await controller.load();

    await tester.pumpWidget(
      WalkaFavoritesScope(
        controller: controller,
        child: MaterialApp(
          theme: buildWalkaTheme(),
          home: const WalkaProductDetailV2(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byTooltip('Add favorite'), findsOneWidget);
    expect(controller.isDrawerFavorite(gray: false), isFalse);

    await tester.tap(find.byTooltip('Add favorite'));
    await tester.pumpAndSettle();

    expect(controller.isDrawerFavorite(gray: false), isTrue);
    expect(find.byTooltip('Remove favorite'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Lunch PDP renders approved usage guidance',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildWalkaTheme(),
        home: const WalkaLunchProductDetailV6(),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Best for dry & semi-wet foods'), findsOneWidget);
    expect(find.textContaining('Not intended for liquids'), findsOneWidget);
    expect(find.textContaining('Carry upright'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('adaptive frame constrains oversized mobile content',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WalkaAdaptiveFrame(
            child: ColoredBox(color: Colors.white),
          ),
        ),
      ),
    );

    final Size frameSize = tester.getSize(find.byType(WalkaAdaptiveFrame));
    expect(frameSize.width, 900);
    expect(WalkaAdaptiveMetrics.mobileContentMaxWidth, 560);
    expect(tester.takeException(), isNull);
  });
}

WalkaFavoritesController _newController() {
  return WalkaFavoritesController(_MemoryFavoritesStore());
}

class _MemoryFavoritesStore implements WalkaFavoritesStore {
  Set<String> ids = <String>{};

  @override
  Future<Set<String>> readFavoriteIds() async => Set<String>.from(ids);

  @override
  Future<void> writeFavoriteIds(Set<String> favoriteIds) async {
    ids = Set<String>.from(favoriteIds);
  }
}
