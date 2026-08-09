import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/favorites/favorites_state.dart';
import 'package:walka/features/lunch/lunch_box_v6.dart';
import 'package:walka/features/products/product_experience_v100.dart';
import 'package:walka/features/storefront/storefront_v101.dart';
import 'package:walka/main.dart';

void main() {
  test('1.0 exposes the final visual-freeze surface', () {
    final WalkaFavoritesController controller = _controller();
    expect(WalkaApp(favoritesController: controller), isA<WalkaApp>());
    expect(const WalkaStorefrontSplashV101(), isA<WalkaStorefrontSplashV101>());
    expect(const WalkaStorefrontShellV101(), isA<WalkaStorefrontShellV101>());
    expect(const WalkaSearchV101(), isA<WalkaSearchV101>());
    expect(const WalkaCategoriesV101(), isA<WalkaCategoriesV101>());
    expect(const WalkaDrawerProductDetailV100(), isA<WalkaDrawerProductDetailV100>());
    expect(const WalkaLunchProductDetailV100(), isA<WalkaLunchProductDetailV100>());
  });

  test('final product copy is locked to the repository product master', () async {
    final String master = await File('../docs/PRODUCT_MASTER.md').readAsString();
    final String productUi = await File(
      'lib/features/products/product_experience_v100.dart',
    ).readAsString();
    final String storefront = await File(
      'lib/features/storefront/storefront_v101.dart',
    ).readAsString();

    expect(master, contains('Product weight: 1.72 lb'));
    expect(master, contains('Outer body: BPA-free PP'));
    expect(master, contains('Lid and silicone gasket: hand wash'));
    expect(master, contains('dishwasher safe on the top rack'));
    expect(master, contains('stainless sauce cup with lid'));

    expect(productUi, contains("('Product weight', '1.72 lb')"));
    expect(productUi, contains("('Outer body', 'BPA-free PP')"));
    expect(productUi, contains("('Lid & gasket', 'Hand wash')"));
    expect(productUi, contains("('SUS304 tray', 'Dishwasher safe · top rack')"));
    expect(productUi, contains('Secure Lock | Helps Prevent Spills'));
    expect(productUi, contains('Best for dry & semi-wet foods'));
    expect(productUi, contains('Not intended for liquids'));
    expect(productUi, contains('Carry upright'));

    expect(storefront, contains('Hand wash the lid and silicone gasket'));
    expect(storefront, contains('stainless sauce cup with lid'));
    expect(storefront, isNot(contains('WalkaProductDetailV2')));
    expect(storefront, isNot(contains('WalkaLunchProductDetailV6')));
  });

  testWidgets('Search Green result opens the final Green Lunch PDP',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildWalkaTheme(),
        home: const WalkaSearchV101(),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'green');
    await tester.pump();

    expect(find.text('1 result'), findsOneWidget);
    expect(find.text('Green'), findsOneWidget);
    await tester.tap(find.text('Large Stainless Steel Bento Lunch Box'));
    await tester.pumpAndSettle();

    expect(find.byType(WalkaLunchProductDetailV100), findsOneWidget);
    expect(find.textContaining('Green · PANTONE 6198 U'), findsOneWidget);
    expect(find.text('BUY ON AMAZON'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('final Drawer PDP preserves persistent favorite behavior',
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
    expect(find.byTooltip('Add favorite'), findsOneWidget);
    await tester.tap(find.byTooltip('Add favorite'));
    await tester.pumpAndSettle();

    expect(controller.isDrawerFavorite(gray: true), isTrue);
    expect(find.byTooltip('Remove favorite'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('final Lunch PDP keeps approved use guidance',
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

    expect(find.textContaining('Pink · PANTONE 9242 U'), findsOneWidget);
    expect(find.text('Secure Lock | Helps Prevent Spills'), findsOneWidget);
    expect(find.text('Best for dry & semi-wet foods'), findsOneWidget);
    expect(find.text('Not intended for liquids'), findsOneWidget);
    expect(find.text('Carry upright'), findsOneWidget);
    expect(find.text('BUY ON AMAZON'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('FAQ presents the verified care model',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildWalkaTheme(),
        home: const WalkaFaqV101(),
      ),
    );
    await tester.pump();

    expect(find.text('Frequently Asked Questions'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('How should I wash the lunch box?'),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('How should I wash the lunch box?'));
    await tester.pumpAndSettle();

    expect(find.textContaining('dishwasher safe on the top rack'), findsOneWidget);
    expect(find.textContaining('Hand wash the lid and silicone gasket'), findsOneWidget);
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
          home: const WalkaStorefrontShellV101(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('WALKA'), findsWidgets);
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
