import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_product_visual.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/catalog/catalog_state.dart';
import 'package:walka/features/storefront/discovery_reference_v123.dart';

void main() {
  testWidgets(
    'reference Categories follows Android hierarchy on 320x568',
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
            child: const Scaffold(body: WalkaCategoriesPremiumV123()),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Categories'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('reference-category-lunch')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('reference-category-drawer')),
        findsOneWidget,
      );
      expect(find.byType(WalkaProductVisual), findsWidgets);
      expect(find.text('3 colors'), findsOneWidget);
      expect(find.text('2 finishes'), findsOneWidget);
      expect(find.text('Accessories'), findsNothing);
      expect(find.text('Sale'), findsNothing);
      expect(find.text('12 Products'), findsNothing);
      expect(find.text('8 Products'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'reference Categories exposes all five real variants through scroll',
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
            child: const Scaffold(body: WalkaCategoriesPremiumV123()),
          ),
        ),
      );
      await tester.pump();

      final List<String> ids = <String>[
        'drawer-organizer:white',
        'drawer-organizer:gray',
        'lunch-box:blue',
        'lunch-box:pink',
        'lunch-box:green',
      ];
      for (final String id in ids) {
        final Finder target = find.byKey(ValueKey<String>('reference-category-$id'));
        await tester.scrollUntilVisible(
          target,
          220,
          scrollable: find.byType(Scrollable).first,
        );
        expect(target, findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Categories header search action remains functional',
    (WidgetTester tester) async {
      final WalkaCatalogController controller = WalkaCatalogController();
      addTearDown(controller.dispose);
      int searchCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildWalkaTheme(),
          home: WalkaCatalogScope(
            controller: controller,
            child: Scaffold(
              body: WalkaCategoriesPremiumV123(
                onSearch: () => searchCount += 1,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(
        find.byKey(const ValueKey<String>('reference-discovery-trailing')),
      );
      await tester.pump();

      expect(searchCount, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'reference Search preserves query semantics and product visuals',
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
            child: const Scaffold(body: WalkaSearchPremiumV123()),
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
        find.byKey(const ValueKey<String>('discovery-search-lunch-box:pink')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('discovery-search-lunch-box:blue')),
        findsNothing,
      );
      expect(find.byType(WalkaProductVisual), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'reference Search family filter keeps released filtering behavior',
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
            child: const Scaffold(body: WalkaSearchPremiumV123()),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(
        find.byKey(const ValueKey<String>('premium-family-Drawer')),
      );
      await tester.pump();

      expect(find.text('2 results'), findsOneWidget);
      final Finder white = find.byKey(
        const ValueKey<String>('discovery-search-drawer-organizer:white'),
      );
      await tester.scrollUntilVisible(
        white,
        180,
        scrollable: find.byType(Scrollable).first,
      );
      expect(white, findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('discovery-search-lunch-box:blue')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'reference Search empty state can reset query and filters',
    (WidgetTester tester) async {
      final WalkaCatalogController controller = WalkaCatalogController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildWalkaTheme(),
          home: WalkaCatalogScope(
            controller: controller,
            child: const Scaffold(body: WalkaSearchPremiumV123()),
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

  testWidgets(
    'reference discovery survives 1.3x text scaling on 320x568',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final WalkaCatalogController controller = WalkaCatalogController();
      addTearDown(controller.dispose);
      final MediaQueryData scaledMedia = MediaQueryData.fromView(
        tester.view,
      ).copyWith(textScaler: const TextScaler.linear(1.3));

      await tester.pumpWidget(
        MaterialApp(
          theme: buildWalkaTheme(),
          home: MediaQuery(
            data: scaledMedia,
            child: WalkaCatalogScope(
              controller: controller,
              child: const Scaffold(body: WalkaCategoriesPremiumV123()),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('reference-category-lunch')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildWalkaTheme(),
          home: MediaQuery(
            data: scaledMedia,
            child: WalkaCatalogScope(
              controller: controller,
              child: const Scaffold(body: WalkaSearchPremiumV123()),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('premium-discovery-search-field')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
