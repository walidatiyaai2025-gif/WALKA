import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/catalog/catalog_v10.dart';
import 'package:walka/features/favorites/favorites_state.dart';
import 'package:walka/features/lunch/lunch_box_v6.dart';
import 'package:walka/features/products/product_experience_v10.dart';
import 'package:walka/features/storefront/storefront_shell_v10.dart';

void main() {
  test('0.10 exposes the product-experience storefront', () {
    expect(const WalkaStorefrontSplashV10(), isA<WalkaStorefrontSplashV10>());
    expect(const WalkaStorefrontShellV10(), isA<WalkaStorefrontShellV10>());
    expect(const WalkaCategoriesV10(), isA<WalkaCategoriesV10>());
    expect(
      const WalkaDrawerProductDetailV10(),
      isA<WalkaDrawerProductDetailV10>(),
    );
    expect(
      const WalkaLunchProductDetailV10(),
      isA<WalkaLunchProductDetailV10>(),
    );
  });

  testWidgets('Drawer v10 renders gallery, sticky Amazon CTA and related edit',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
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
          home: const WalkaDrawerProductDetailV10(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('WALKA Drawer Organizer'), findsOneWidget);
    expect(find.byTooltip('View fullscreen'), findsOneWidget);
    expect(find.text('BUY ON AMAZON'), findsOneWidget);
    expect(find.text('CONTINUE THE WALKA EDIT'), findsOneWidget);
    expect(find.byTooltip('Add favorite'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Drawer v10 keeps verified 1.72 lb product weight',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
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
          home: const WalkaDrawerProductDetailV10(),
        ),
      ),
    );
    await tester.pump();

    final Finder scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Dimensions & capacity'),
      420,
      scrollable: scrollable,
    );
    await tester.tap(find.text('Dimensions & capacity'));
    await tester.pumpAndSettle();

    expect(find.text('1.72 lb'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Drawer v10 fullscreen gallery opens and supports zoom surface',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
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
          home: const WalkaDrawerProductDetailV10(initialGray: true),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('View fullscreen'));
    await tester.pumpAndSettle();

    expect(find.text('Drawer Organizer'), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Drawer v10 favorite uses the persistent controller',
      (WidgetTester tester) async {
    final WalkaFavoritesController controller = _controller();
    await controller.load();

    await tester.pumpWidget(
      WalkaFavoritesScope(
        controller: controller,
        child: MaterialApp(
          theme: buildWalkaTheme(),
          home: const WalkaDrawerProductDetailV10(initialGray: true),
        ),
      ),
    );
    await tester.pump();

    expect(controller.isDrawerFavorite(gray: true), isFalse);
    await tester.tap(find.byTooltip('Add favorite'));
    await tester.pumpAndSettle();
    expect(controller.isDrawerFavorite(gray: true), isTrue);
    expect(find.byTooltip('Remove favorite'), findsOneWidget);
  });

  testWidgets('Lunch v10 keeps approved usage copy and share treatment',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildWalkaTheme(),
        home: const WalkaLunchProductDetailV10(
          initialVariant: WalkaLunchVariant.green,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Large Stainless Steel Bento Lunch Box'), findsOneWidget);
    expect(find.textContaining('Green · PANTONE 6198 U'), findsOneWidget);
    expect(find.textContaining('Best for dry & semi-wet foods'), findsOneWidget);
    expect(find.textContaining('Not intended for liquids'), findsOneWidget);
    expect(find.textContaining('Carry upright'), findsOneWidget);

    await tester.tap(find.byTooltip('Share product'));
    await tester.pumpAndSettle();
    expect(find.text('SHARE WALKA'), findsOneWidget);
    expect(find.text('COPY PRODUCT LINK'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Lunch v10 keeps verified tray and lid care guidance',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildWalkaTheme(),
        home: const WalkaLunchProductDetailV10(),
      ),
    );
    await tester.pump();

    final Finder scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Care & use'),
      500,
      scrollable: scrollable,
    );
    await tester.tap(find.text('Care & use'));
    await tester.pumpAndSettle();

    expect(find.text('Dishwasher · top rack'), findsOneWidget);
    expect(find.text('Hand wash'), findsOneWidget);
    expect(find.text('Remove stainless tray'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Legacy Lunch v6 keeps hand-wash lid and gasket guidance',
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

    final Finder scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Lid and silicone gasket: hand wash.'),
      550,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();

    expect(find.text('Lid and silicone gasket: hand wash.'), findsOneWidget);
    expect(find.text('Stainless steel tray: dishwasher, top rack.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Categories v10 exposes every Drawer and Lunch finish',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildWalkaTheme(),
        home: const Scaffold(body: WalkaCategoriesV10()),
      ),
    );
    await tester.pump();

    expect(find.text('Collections'), findsOneWidget);
    expect(find.text('White'), findsOneWidget);
    expect(find.text('Gray'), findsOneWidget);

    final Finder scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Blue'),
      420,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
    expect(find.text('Blue'), findsOneWidget);
    expect(find.text('Pink'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Green'),
      260,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
    expect(find.text('Green'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Drawer v10 stays overflow-free on compact 320px phones',
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
          home: const WalkaDrawerProductDetailV10(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('BUY ON AMAZON'), findsOneWidget);
    expect(find.byTooltip('View fullscreen'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Lunch v10 remains stable on a large mobile viewport',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildWalkaTheme(),
        home: const WalkaLunchProductDetailV10(
          initialVariant: WalkaLunchVariant.blue,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('BUY ON AMAZON'), findsOneWidget);
    expect(find.byTooltip('View fullscreen'), findsOneWidget);
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
