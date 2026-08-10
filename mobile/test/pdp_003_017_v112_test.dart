import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/features/favorites/favorites_state.dart';
import 'package:walka/features/lunch/lunch_box_v6.dart';
import 'package:walka/features/products/presentation/walka_pdp_model.dart';
import 'package:walka/features/products/product_experience_v100.dart';

class _MemoryFavoritesStore implements WalkaFavoritesStore {
  Set<String> ids = <String>{};

  @override
  Future<Set<String>> readFavoriteIds() async => Set<String>.from(ids);

  @override
  Future<void> writeFavoriteIds(Set<String> ids) async {
    this.ids = Set<String>.from(ids);
  }
}

void main() {
  test('presentation models keep stable variant IDs and verified facts', () {
    final WalkaPdpPresentationModel drawer =
        WalkaPdpPresentationModel.drawer(gray: false);
    final WalkaPdpPresentationModel lunch =
        WalkaPdpPresentationModel.lunch(WalkaLunchVariant.green);

    expect(drawer.variantId, 'drawer-organizer:white');
    expect(drawer.factsLine, contains('8 compartments'));
    expect(drawer.factsLine, contains('22.4 in'));
    expect(lunch.variantId, 'lunch-box:green');
    expect(lunch.factsLine, contains('1200 ml'));
    expect(lunch.factsLine, contains('SUS304'));
    expect(lunch.showLunchUsage, isTrue);
  });

  Future<WalkaFavoritesController> pumpProduct(
    WidgetTester tester,
    Widget product, {
    Size size = const Size(320, 568),
    double textScale = 1,
    TargetPlatform platform = TargetPlatform.android,
    EdgeInsets padding = EdgeInsets.zero,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final WalkaFavoritesController controller =
        WalkaFavoritesController(_MemoryFavoritesStore());
    await controller.load();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: platform),
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            padding: padding,
            textScaler: TextScaler.linear(textScale),
          ),
          child: WalkaFavoritesScope(controller: controller, child: product),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return controller;
  }

  testWidgets('Drawer V100 uses modular gallery, sticky Amazon CTA and zoom',
      (WidgetTester tester) async {
    await pumpProduct(
      tester,
      const WalkaDrawerProductDetailV100(),
      textScale: 1.3,
    );

    expect(
      find.byKey(const ValueKey<String>('walka-pdp-gallery-page-view')),
      findsOneWidget,
    );
    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.text('BUY ON AMAZON'), findsOneWidget);
    expect(find.text('8 compartments'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.tap(
      find.byKey(const ValueKey<String>('walka-pdp-gallery-fullscreen')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('walka-pdp-fullscreen-gallery')),
      findsOneWidget,
    );
    expect(find.byType(InteractiveViewer), findsWidgets);
  });

  testWidgets('Drawer persistent favorite contract remains wired',
      (WidgetTester tester) async {
    final WalkaFavoritesController controller = await pumpProduct(
      tester,
      const WalkaDrawerProductDetailV100(initialGray: true),
      size: const Size(390, 844),
    );

    expect(controller.isDrawerFavorite(gray: true), isFalse);
    await tester.tap(
      find.byKey(const ValueKey<String>('walka-pdp-favorite')),
    );
    await tester.pumpAndSettle();
    expect(controller.isDrawerFavorite(gray: true), isTrue);
  });

  testWidgets('Lunch V100 keeps iOS safe area, usage wording and variant state',
      (WidgetTester tester) async {
    await pumpProduct(
      tester,
      const WalkaLunchProductDetailV100(),
      size: const Size(390, 844),
      textScale: 1.3,
      platform: TargetPlatform.iOS,
      padding: const EdgeInsets.fromLTRB(0, 47, 0, 34),
    );

    expect(find.text('Best suited for dry meals & snacks.'), findsOneWidget);
    expect(find.textContaining('Not intended for liquids'), findsOneWidget);
    expect(find.textContaining('PANTONE 4155 U'), findsOneWidget);

    final Finder pink = find.text('Pink');
    await tester.ensureVisible(pink);
    await tester.pumpAndSettle();
    await tester.tap(pink);
    await tester.pumpAndSettle();
    expect(find.textContaining('PANTONE 9242 U'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Amazon disclosure is explicit and no in-app checkout is exposed',
      (WidgetTester tester) async {
    await pumpProduct(
      tester,
      const WalkaLunchProductDetailV100(initialVariant: WalkaLunchVariant.green),
      size: const Size(430, 900),
    );

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('walka-pdp-amazon-trust')),
      350,
    );
    expect(find.textContaining('official Amazon listing'), findsOneWidget);
    expect(find.textContaining('CHECKOUT'), findsNothing);
    expect(find.textContaining('ADD TO CART'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
