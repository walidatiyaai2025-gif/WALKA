import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_product_visual.dart';
import 'package:walka/features/catalog/catalog_state.dart';
import 'package:walka/features/storefront/presentation/widgets/discovery/walka_categories_benefits.dart';
import 'package:walka/features/storefront/presentation/widgets/discovery/walka_category_card.dart';
import 'package:walka/features/storefront/presentation/widgets/discovery/walka_discovery_header.dart';
import 'package:walka/features/storefront/presentation/widgets/discovery/walka_discovery_product_row.dart';
import 'package:walka/features/storefront/presentation/widgets/discovery/walka_search_empty_state.dart';
import 'package:walka/features/storefront/presentation/widgets/discovery/walka_search_field.dart';
import 'package:walka/features/storefront/presentation/widgets/discovery/walka_search_filters.dart';
import 'package:walka/features/storefront/storefront_catalog_v120.dart';

void main() {
  Widget app(Widget child, {double width = 360, double textScale = 1}) =>
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, 760),
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(width: width, child: child),
            ),
          ),
        ),
      );

  testWidgets('discovery header preserves trailing callback',
      (WidgetTester tester) async {
    var taps = 0;
    await tester.pumpWidget(
      app(
        WalkaDiscoveryHeader(
          trailingIcon: Icons.search,
          trailingTooltip: 'Search WALKA',
          onTrailing: () => taps += 1,
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey<String>('reference-discovery-trailing')));
    expect(taps, 1);
  });

  testWidgets('category card and product row preserve caller taps',
      (WidgetTester tester) async {
    var categoryTap = 0;
    var productTap = 0;
    final WalkaCatalogController controller = WalkaCatalogController();
    final WalkaCatalogViewItem item = walkaCatalogViewItems(controller.snapshot).first;
    await tester.pumpWidget(
      app(
        Column(
          children: <Widget>[
            SizedBox(
              width: 170,
              child: WalkaCategoryCard(
                title: 'Drawer Organizers',
                subtitle: '2 finishes',
                kind: WalkaProductVisualKind.drawerOrganizer,
                primaryColor: Colors.white,
                surface: const Color(0xFFF1E6CF),
                badge: '8 compartments',
                onTap: () => categoryTap += 1,
              ),
            ),
            WalkaDiscoveryProductRow(
              item: item,
              onTap: () => productTap += 1,
            ),
          ],
        ),
        textScale: 1.3,
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Drawer Organizers'));
    await tester.tap(find.text(item.title));
    expect(categoryTap, 1);
    expect(productTap, 1);
    controller.dispose();
  });

  testWidgets('search field types and clears through caller contract',
      (WidgetTester tester) async {
    final TextEditingController controller = TextEditingController();
    var query = '';
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => app(
          WalkaSearchField(
            controller: controller,
            query: query,
            onChanged: (String value) => setState(() => query = value),
            onClear: () => setState(() {
              controller.clear();
              query = '';
            }),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'drawer');
    await tester.pump();
    expect(controller.text, 'drawer');
    await tester.tap(find.byKey(const ValueKey<String>('reference-search-clear')));
    await tester.pump();
    expect(controller.text, isEmpty);
    controller.dispose();
  });

  testWidgets('filter chips and empty reset stay compact-safe',
      (WidgetTester tester) async {
    WalkaCatalogFamily? selected;
    var resets = 0;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => app(
          Column(
            children: <Widget>[
              WalkaSearchFilters(
                selectedFamily: selected,
                onChanged: (WalkaCatalogFamily? value) =>
                    setState(() => selected = value),
              ),
              WalkaSearchEmptyState(onReset: () => resets += 1),
              const WalkaCategoriesBenefits(),
            ],
          ),
          width: 280,
          textScale: 1.3,
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Drawer'));
    await tester.pump();
    expect(selected, WalkaCatalogFamily.drawer);
    await tester.tap(find.text('RESET SEARCH'));
    expect(resets, 1);
    expect(find.text('Official Amazon'), findsOneWidget);
  });
}
