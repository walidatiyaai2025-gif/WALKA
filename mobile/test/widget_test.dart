import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_adaptive.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/catalog/catalog_v3.dart';
import 'package:walka/features/catalog/catalog_v6.dart';
import 'package:walka/features/lifestyle/favorites_v5.dart';
import 'package:walka/features/lifestyle/lifestyle_v4.dart';
import 'package:walka/features/lunch/lunch_box_v6.dart';
import 'package:walka/features/storefront/storefront_shell_v6.dart';
import 'package:walka/features/storefront/storefront_v2.dart';
import 'package:walka/main.dart';

void main() {
  test('WALKA 0.7 exposes the complete visual destination set', () {
    expect(const WalkaApp(), isA<WalkaApp>());
    expect(const WalkaStorefrontSplashV6(), isA<WalkaStorefrontSplashV6>());
    expect(const WalkaStorefrontShellV6(), isA<WalkaStorefrontShellV6>());
    expect(const WalkaHomeV2(), isA<WalkaHomeV2>());
    expect(const WalkaCategoriesV6(), isA<WalkaCategoriesV6>());
    expect(const WalkaCollectionScreenV3(), isA<WalkaCollectionScreenV3>());
    expect(const WalkaLunchCollectionV6(), isA<WalkaLunchCollectionV6>());
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

  test('lunch collection exposes all three approved product colors', () {
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

  testWidgets('storefront v6 renders on a compact mobile viewport',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildWalkaTheme(),
        home: const WalkaStorefrontShellV6(),
      ),
    );
    await tester.pump();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lunch PDP renders locked usage guidance',
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
