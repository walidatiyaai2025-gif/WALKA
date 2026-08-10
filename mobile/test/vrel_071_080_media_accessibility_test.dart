import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/media/walka_product_media_resolver.dart';
import 'package:walka/design_system/walka_product_visual.dart';
import 'package:walka/features/products/presentation/widgets/walka_pdp_fullscreen_gallery.dart';
import 'package:walka/features/products/presentation/widgets/walka_pdp_gallery_indicator.dart';
import 'package:walka/features/storefront/presentation/widgets/home/walka_home_hero.dart';

void main() {
  testWidgets('missing registered media boundary can render visible deterministic fallback', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 240,
            height: 180,
            child: WalkaResolvedProductMedia(
              variantId: 'drawer-organizer:white',
              kind: WalkaProductVisualKind.drawerOrganizer,
              primaryColor: Color(0xFFF7F4EC),
              semanticLabel: 'WALKA Drawer Organizer White',
              resolver: WalkaProductMediaResolver(),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(WalkaProductVisual), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion keeps gallery selected semantics and removes transition time', (
    WidgetTester tester,
  ) async {
    int selected = 1;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: WalkaPdpGalleryIndicator(
              selectedIndex: selected,
              itemCount: 3,
              onSelected: (int value) => selected = value,
            ),
          ),
        ),
      ),
    );

    final Iterable<AnimatedContainer> indicators =
        tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));
    expect(indicators, hasLength(3));
    expect(indicators.every((AnimatedContainer item) => item.duration == Duration.zero), isTrue);
    expect(find.bySemanticsLabel('Gallery view 2'), findsOneWidget);
  });

  testWidgets('Home media remains layout-safe at compact 1.3x text scale', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 760),
            textScaler: TextScaler.linear(1.3),
          ),
          child: Scaffold(
            body: WalkaHomeHero(
              lunchSemanticLabel: 'WALKA Lunch Box hero',
              drawerSemanticLabel: 'WALKA Drawer Organizer hero',
              onOpenLunch: () {},
              onShopAll: () {},
              onSearch: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('SHOP ALL'), findsOneWidget);
    expect(find.text('SEARCH'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fullscreen PDP media preserves representative iOS SafeArea', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(390, 844),
            padding: EdgeInsets.only(top: 47, bottom: 34),
          ),
          child: WalkaPdpFullscreenGallery(
            initialIndex: 0,
            title: 'WALKA Drawer Organizer White',
            variantId: 'drawer-organizer:white',
            kind: WalkaProductVisualKind.drawerOrganizer,
            primaryColor: Color(0xFFF7F4EC),
            surface: Color(0xFFF4EEDF),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('owner-visible tappable media surfaces remain Material InkWell based', () {
    final List<String> paths = <String>[
      'lib/features/storefront/presentation/widgets/home/walka_home_hero.dart',
      'lib/features/storefront/presentation/widgets/discovery/walka_category_card.dart',
      'lib/features/storefront/presentation/widgets/favorites/walka_saved_drawer_card.dart',
    ];
    for (final String path in paths) {
      expect(File(path).readAsStringSync(), contains('InkWell'));
    }
  });

  test('visual-only alpha separation checks remain explicitly pending real assets', () {
    final String checklist = File(
      '../docs/ui/PRODUCT_MEDIA_ACCESSIBILITY_CHECKLIST.md',
    ).readAsStringSync();
    expect(checklist, contains('VREL-072'));
    expect(checklist, contains('VREL-073'));
    expect(checklist, contains('PENDING REAL-ASSET ACCEPTANCE'));
    expect(checklist, contains('can never prove alpha-edge quality'));
  });
}
