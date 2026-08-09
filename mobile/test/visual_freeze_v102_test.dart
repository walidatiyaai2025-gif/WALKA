import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/favorites/favorites_state.dart';
import 'package:walka/features/information/information_v102.dart';
import 'package:walka/features/lunch/lunch_box_v6.dart';
import 'package:walka/features/products/product_experience_v100.dart';
import 'package:walka/features/products/product_experience_v10.dart';
import 'package:walka/features/storefront/storefront_v101.dart';
import 'package:walka/features/storefront/storefront_v102.dart';
import 'package:walka/main.dart';

void main() {
  test('1.0 exposes the reconciled visual-freeze surface', () {
    final WalkaFavoritesController controller = _controller();
    expect(WalkaApp(favoritesController: controller), isA<WalkaApp>());
    expect(const WalkaStorefrontSplashV102(), isA<WalkaStorefrontSplashV102>());
    expect(const WalkaStorefrontShellV102(), isA<WalkaStorefrontShellV102>());
    expect(const WalkaSearchV101(), isA<WalkaSearchV101>());
    expect(const WalkaCategoriesV101(), isA<WalkaCategoriesV101>());
    expect(const WalkaDrawerProductDetailV100(), isA<WalkaDrawerProductDetailV100>());
    expect(const WalkaLunchProductDetailV100(), isA<WalkaLunchProductDetailV100>());
  });

  test('final product copy follows docs/PRODUCT_MASTER.md', () async {
    final String master = await File('../docs/PRODUCT_MASTER.md').readAsString();
    final String finalProduct = await File(
      'lib/features/products/product_experience_v100.dart',
    ).readAsString();
    final String information = await File(
      'lib/features/information/information_v102.dart',
    ).readAsString();
    final String app = await File('lib/main.dart').readAsString();

    expect(master, contains('Do not publish a product weight'));
    expect(
      master,
      contains('Lid and silicone gasket: dishwasher safe on the top rack'),
    );
    expect(
      master,
      contains(
        'PP outer body: microwave safe only after removing the stainless tray, lid, and silicone gasket',
      ),
    );

    expect(finalProduct, contains('WalkaDrawerProductDetailV10'));
    expect(finalProduct, contains('WalkaLunchProductDetailV10'));
    expect(finalProduct, isNot(contains('1.72 lb')));
    expect(finalProduct, isNot(contains('Hand wash')));

    expect(
      information,
      contains('lid and silicone gasket are dishwasher safe on the top rack'),
    );
    expect(
      information,
      contains('Microwave only the PP outer body after removing all three'),
    );
    expect(information, isNot(contains('Hand wash the lid')));
    expect(information, isNot(contains('1.72 lb')));

    expect(app, contains('storefront_v102.dart'));
    expect(app, contains('WalkaStorefrontSplashV102'));
  });

  testWidgets('Search Green result opens final Product-Master-safe Lunch PDP',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildWalkaTheme(),
        home: const Scaffold(body: WalkaSearchV101()),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'green');
    await tester.pump();

    expect(find.text('1 result'), findsOneWidget);
    await tester.tap(find.text('Large Stainless Steel Bento Lunch Box'));
    await tester.pumpAndSettle();

    expect(find.byType(WalkaLunchProductDetailV100), findsOneWidget);
    expect(find.byType(WalkaLunchProductDetailV10), findsOneWidget);
    expect(find.textContaining('Green · PANTONE 6198 U'), findsOneWidget);
    expect(find.text('BUY ON AMAZON'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('final Drawer route preserves persistent Favorites',
      (WidgetTester tester) async {
    final WalkaFavoritesController controller = _controller();
    await controller.load();

    await tester.pumpWidget(
      WalkaFavoritesScope(
        controller: controller,
        child: MaterialApp(
          theme: buildWalkaTheme(),
          home: const WalkaDrawerProductDetailV100(initialGray: true),
        ),
      ),
    );
    await tester.pump();

    expect(controller.isDrawerFavorite(gray: true), isFalse);
    expect(find.byType(WalkaDrawerProductDetailV10), findsOneWidget);
    expect(find.byTooltip('Add favorite'), findsOneWidget);
    await tester.tap(find.byTooltip('Add favorite'));
    await tester.pumpAndSettle();

    expect(controller.isDrawerFavorite(gray: true), isTrue);
    expect(find.byTooltip('Remove favorite'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('final FAQ exposes approved care and microwave guidance',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildWalkaTheme(),
        home: const WalkaFaqV102(),
      ),
    );
    await tester.pump();

    expect(find.text('Frequently Asked Questions'), findsOneWidget);
    await tester.tap(find.text('What can go in the dishwasher?'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('dishwasher safe on the top rack'),
      findsOneWidget,
    );

    await tester.tap(find.text('What can go in the microwave?'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Microwave only the PP outer body'),
      findsOneWidget,
    );
    expect(find.textContaining('Hand wash'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Account routes to the verified FAQ surface',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildWalkaTheme(),
        home: const Scaffold(body: WalkaAccountV102()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('FAQ'));
    await tester.pumpAndSettle();
    expect(find.byType(WalkaFaqV102), findsOneWidget);
    expect(find.text('Frequently Asked Questions'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('visual freeze fits a compact 320 by 568 handset',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final WalkaFavoritesController controller = _controller();
    await controller.load();

    await tester.pumpWidget(
      WalkaFavoritesScope(
        controller: controller,
        child: MaterialApp(
          theme: buildWalkaTheme(),
          home: const WalkaStorefrontShellV102(),
        ),
      ),
    );
    await tester.pump();

    final Finder navigation = find.byType(NavigationBar);
    expect(navigation, findsOneWidget);
    expect(tester.widget<NavigationBar>(navigation).selectedIndex, 0);
    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('final Lunch route preserves approved use guidance',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildWalkaTheme(),
        home: const WalkaLunchProductDetailV100(
          initialVariant: WalkaLunchVariant.pink,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(WalkaLunchProductDetailV10), findsOneWidget);
    expect(find.textContaining('Pink · PANTONE 9242 U'), findsOneWidget);
    expect(find.textContaining('Best for dry & semi-wet foods'), findsOneWidget);
    expect(find.textContaining('Not intended for liquids'), findsOneWidget);
    expect(find.textContaining('Carry upright'), findsOneWidget);
    expect(find.text('BUY ON AMAZON'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

WalkaFavoritesController _controller() {
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
