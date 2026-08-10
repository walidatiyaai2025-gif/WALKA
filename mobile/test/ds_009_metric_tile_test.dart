import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/cards/walka_metric_tile.dart';
import 'package:walka/design_system/walka_theme.dart';

void main() {
  Widget app(Widget child, {double width = 180}) {
    return MaterialApp(
      theme: buildWalkaTheme(),
      home: Scaffold(
        body: Center(child: SizedBox(width: width, child: child)),
      ),
    );
  }

  testWidgets('renders value label and optional supporting text',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        const WalkaMetricTile(
          value: '5',
          label: 'CATALOG VARIANTS',
          supportingText: 'Released products',
        ),
      ),
    );

    expect(find.text('5'), findsOneWidget);
    expect(find.text('CATALOG VARIANTS'), findsOneWidget);
    expect(find.text('Released products'), findsOneWidget);

    final Finder semanticsFinder = find.descendant(
      of: find.byType(WalkaMetricTile),
      matching: find.byType(Semantics),
    );
    final Semantics semantics = tester.widget<Semantics>(semanticsFinder.first);
    expect(
      semantics.properties.label,
      'CATALOG VARIANTS, 5, Released products',
    );
  });

  testWidgets('supports start alignment and omits supporting text cleanly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        const WalkaMetricTile(
          value: '2',
          label: 'FINISHES',
          alignment: WalkaMetricTileAlignment.start,
        ),
      ),
    );

    final Finder columnFinder = find.descendant(
      of: find.byType(WalkaMetricTile),
      matching: find.byType(Column),
    );
    final Column column = tester.widget<Column>(columnFinder.first);
    expect(column.crossAxisAlignment, CrossAxisAlignment.start);
    expect(find.byType(Text), findsNWidgets(2));
  });

  testWidgets('compact metric content wraps without overflow',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        const WalkaMetricTile(
          value: '13–22.4 in',
          label: 'EXPANDABLE WIDTH',
          supportingText: 'Drawer organizer range',
        ),
        width: 110,
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom semantic label overrides generated wording',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        const WalkaMetricTile(
          value: '1200 ml',
          label: 'CAPACITY',
          semanticLabel: 'Lunch box capacity is 1200 milliliters',
        ),
      ),
    );

    final Finder semanticsFinder = find.descendant(
      of: find.byType(WalkaMetricTile),
      matching: find.byType(Semantics),
    );
    final Semantics semantics = tester.widget<Semantics>(semanticsFinder.first);
    expect(
      semantics.properties.label,
      'Lunch box capacity is 1200 milliliters',
    );
  });
}
