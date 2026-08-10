import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_product_visual.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/catalog/catalog_state.dart';
import 'package:walka/features/storefront/home_premium_v121.dart';

void main() {
  testWidgets(
      'DESIGN-007B.1 Home follows Android reference hierarchy on compact width',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final WalkaCatalogController controller = WalkaCatalogController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      WalkaCatalogScope(
        controller: controller,
        child: MaterialApp(
          theme: buildWalkaTheme(),
          home: Scaffold(
            body: WalkaHomePremiumV121(
              onShopAll: () {},
              onSearch: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Organize Better.\nLive Better.'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('home-hero-lunch-visual')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('home-hero-drawer-visual')),
      findsOneWidget,
    );
    expect(find.textContaining('10K'), findsNothing);
    expect(find.textContaining('4.8/5'), findsNothing);
    expect(find.textContaining('LEAK RESISTANT'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.drag(
      find.byType(CustomScrollView),
      const Offset(0, -650),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('home-reference-benefits')),
      findsOneWidget,
    );
    expect(find.text('Everything in Its Place'), findsOneWidget);
    expect(find.byType(WalkaProductVisual), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reference Home keeps browse and search callbacks functional',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final WalkaCatalogController controller = WalkaCatalogController();
    addTearDown(controller.dispose);
    int browseCount = 0;
    int searchCount = 0;

    await tester.pumpWidget(
      WalkaCatalogScope(
        controller: controller,
        child: MaterialApp(
          theme: buildWalkaTheme(),
          home: Scaffold(
            body: WalkaHomePremiumV121(
              onShopAll: () => browseCount += 1,
              onSearch: () => searchCount += 1,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(
      find.byKey(const ValueKey<String>('home-reference-browse')),
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('home-reference-search')),
    );
    await tester.pump();

    expect(browseCount, 1);
    expect(searchCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('premium product visual supports Drawer and Lunch families',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              height: 180,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: WalkaProductVisual(
                      kind: WalkaProductVisualKind.drawerOrganizer,
                      primaryColor: Color(0xFFF7F4EC),
                      semanticLabel: 'Drawer visual test',
                    ),
                  ),
                  Expanded(
                    child: WalkaProductVisual(
                      kind: WalkaProductVisualKind.lunchBox,
                      primaryColor: Color(0xFFB9D2E4),
                      semanticLabel: 'Lunch visual test',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(WalkaProductVisual), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
