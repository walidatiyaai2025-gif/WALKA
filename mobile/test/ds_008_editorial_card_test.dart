import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/cards/walka_editorial_card.dart';
import 'package:walka/design_system/components/cards/walka_surface_card.dart';
import 'package:walka/design_system/walka_theme.dart';

void main() {
  Widget app(Widget child, {double width = 320}) {
    return MaterialApp(
      theme: buildWalkaTheme(),
      home: Scaffold(
        body: Center(child: SizedBox(width: width, child: child)),
      ),
    );
  }

  testWidgets('renders editorial hierarchy and optional slots',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        WalkaEditorialCard(
          eyebrow: 'OUR STORY',
          title: 'Designed for calmer spaces',
          body: 'Thoughtful organization should feel simple every day.',
          visual: const SizedBox(
            key: ValueKey<String>('editorial-visual'),
            height: 48,
          ),
          action: TextButton(onPressed: () {}, child: const Text('EXPLORE')),
        ),
      ),
    );

    expect(find.byType(WalkaSurfaceCard), findsOneWidget);
    expect(find.text('OUR STORY'), findsOneWidget);
    expect(find.text('Designed for calmer spaces'), findsOneWidget);
    expect(
      find.text('Thoughtful organization should feel simple every day.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey<String>('editorial-visual')), findsOneWidget);
    expect(find.text('EXPLORE'), findsOneWidget);

    final Finder titleSemantics = find.ancestor(
      of: find.text('Designed for calmer spaces'),
      matching: find.byType(Semantics),
    );
    final Semantics semantics = tester.widget<Semantics>(titleSemantics.first);
    expect(semantics.properties.header, isTrue);
  });

  testWidgets('optional slots stay optional and centered mode is supported',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        const WalkaEditorialCard(
          title: 'Minimal hierarchy',
          body: 'No visual, eyebrow or action is required.',
          textAlign: TextAlign.center,
        ),
      ),
    );

    expect(find.text('Minimal hierarchy'), findsOneWidget);
    expect(find.byType(TextButton), findsNothing);

    final Finder columnFinder = find.descendant(
      of: find.byType(WalkaEditorialCard),
      matching: find.byType(Column),
    );
    final Column column = tester.widget<Column>(columnFinder.first);
    expect(column.crossAxisAlignment, CrossAxisAlignment.center);
  });

  testWidgets('long editorial content stays overflow-free on compact width',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        WalkaEditorialCard(
          title: 'A deliberately longer editorial heading for compact phones',
          body:
              'This supporting paragraph intentionally wraps across several lines so the shared card proves that compact layouts stay flexible.',
          action: OutlinedButton(
            onPressed: () {},
            child: const Text('LEARN MORE'),
          ),
        ),
        width: 240,
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
