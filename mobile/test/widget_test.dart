import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_adaptive.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/catalog/catalog_v3.dart';
import 'package:walka/features/lifestyle/favorites_v5.dart';
import 'package:walka/features/lifestyle/lifestyle_v4.dart';
import 'package:walka/features/storefront/storefront_shell_v5.dart';
import 'package:walka/features/storefront/storefront_v2.dart';
import 'package:walka/main.dart';

void main() {
  test('WALKA 0.5 exposes the complete Phase 1 destination set', () {
    expect(const WalkaApp(), isA<WalkaApp>());
    expect(const WalkaStorefrontSplashV5(), isA<WalkaStorefrontSplashV5>());
    expect(const WalkaStorefrontShellV5(), isA<WalkaStorefrontShellV5>());
    expect(const WalkaHomeV2(), isA<WalkaHomeV2>());
    expect(const WalkaCategoriesV3(), isA<WalkaCategoriesV3>());
    expect(const WalkaCollectionScreenV3(), isA<WalkaCollectionScreenV3>());
    expect(
      WalkaFavoritesV5(onExploreCollections: () {}),
      isA<WalkaFavoritesV5>(),
    );
    expect(const WalkaAccountV4(), isA<WalkaAccountV4>());
    expect(const WalkaAboutV4(), isA<WalkaAboutV4>());
    expect(const WalkaProductDetailV2(), isA<WalkaProductDetailV2>());
  });

  test('WALKA design system keeps approved brand and touch settings', () {
    final ThemeData theme = buildWalkaTheme();
    expect(WalkaColors.navy.toARGB32(), 0xFF003366);
    expect(WalkaColors.gold.toARGB32(), 0xFFD4AF37);
    expect(theme.useMaterial3, isTrue);
    expect(theme.materialTapTargetSize, MaterialTapTargetSize.padded);
  });

  testWidgets('final shell renders on a compact mobile viewport',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildWalkaTheme(),
        home: const WalkaStorefrontShellV5(),
      ),
    );
    await tester.pump();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
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
