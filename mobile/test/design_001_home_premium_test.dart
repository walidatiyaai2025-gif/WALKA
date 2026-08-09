import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_product_visual.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/catalog/catalog_state.dart';
import 'package:walka/features/storefront/home_premium_v121.dart';

void main() {
  testWidgets('DESIGN-001 premium Home is product-led on compact Android width',
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

    expect(find.text('A place for everything.'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('home-hero-drawer-visual')),
      findsOneWidget,
    );
    expect(find.byType(WalkaProductVisual), findsWidgets);
    expect(find.byIcon(Icons.grid_view_rounded), findsNothing);
    expect(find.byIcon(Icons.lunch_dining_rounded), findsNothing);
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
