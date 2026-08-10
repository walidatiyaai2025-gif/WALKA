import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_product_visual.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/catalog/catalog_state.dart';
import 'package:walka/features/storefront/discovery_premium_v122.dart';

void main() {
  testWidgets(
    'premium Categories is product-led on 320x568',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final WalkaCatalogController controller = WalkaCatalogController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildWalkaTheme(),
          home: WalkaCatalogScope(
            controller: controller,
            child: const Scaffold(body: WalkaCategoriesPremiumV122()),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('discovery-family-drawer')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('discovery-family-lunch')),
        findsOneWidget,
      );
      expect(find.byType(WalkaProductVisual), findsWidgets);
      expect(
        find.byKey(
          const ValueKey<String>(
            'discovery-category-drawer-organizer:white',
          ),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'premium Search preserves query semantics and product visuals',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final WalkaCatalogController controller = WalkaCatalogController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildWalkaTheme(),
          home: WalkaCatalogScope(
            controller: controller,
            child: const Scaffold(body: WalkaSearchPremiumV122()),
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(
        find.byKey(const ValueKey<String>('premium-discovery-search-field')),
        'pink',
      );
      await tester.pump();

      expect(find.text('1 result'), findsOneWidget);
      expect(
        find.byKey(
          const ValueKey<String>('discovery-search-lunch-box:pink'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey<String>('discovery-search-lunch-box:blue'),
        ),
        findsNothing,
      );
      expect(find.byType(WalkaProductVisual), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'premium Search family filter keeps released filtering behavior',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final WalkaCatalogController controller = WalkaCatalogController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildWalkaTheme(),
          home: WalkaCatalogScope(
            controller: controller,
            child: const Scaffold(body: WalkaSearchPremiumV122()),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(
        find.byKey(const ValueKey<String>('premium-family-Drawer')),
      );
      await tester.pump();

      expect(find.text('2 results'), findsOneWidget);
      expect(
        find.byKey(
          const ValueKey<String>('discovery-search-drawer-organizer:white'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey<String>('discovery-search-lunch-box:blue'),
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'premium Search empty state can reset query and filters',
    (WidgetTester tester) async {
      final WalkaCatalogController controller = WalkaCatalogController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildWalkaTheme(),
          home: WalkaCatalogScope(
            controller: controller,
            child: const Scaffold(body: WalkaSearchPremiumV122()),
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(
        find.byKey(const ValueKey<String>('premium-discovery-search-field')),
        'does-not-exist',
      );
      await tester.pump();

      expect(find.text('0 results'), findsOneWidget);
      final Finder reset = find.byKey(
        const ValueKey<String>('premium-discovery-reset'),
      );
      expect(reset, findsOneWidget);

      await tester.ensureVisible(reset);
      await tester.pumpAndSettle();
      await tester.tap(reset);
      await tester.pump();

      expect(find.text('5 results'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
