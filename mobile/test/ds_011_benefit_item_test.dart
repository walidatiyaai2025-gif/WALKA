import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/cards/walka_benefit_item.dart';
import 'package:walka/design_system/walka_theme.dart';

void main() {
  Widget app(Widget child, {double width = 240}) {
    return MaterialApp(
      theme: buildWalkaTheme(),
      home: Scaffold(
        backgroundColor: WalkaColors.navy,
        body: Center(child: SizedBox(width: width, child: child)),
      ),
    );
  }

  testWidgets('renders stacked icon title and supporting copy',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        const WalkaBenefitItem(
          icon: Icons.layers_outlined,
          title: 'Thoughtful design',
          body: 'Every detail supports a calmer routine.',
        ),
      ),
    );

    expect(find.byKey(const ValueKey<String>('walka-benefit-stacked')), findsOneWidget);
    expect(find.text('Thoughtful design'), findsOneWidget);
    expect(find.text('Every detail supports a calmer routine.'), findsOneWidget);

    final Icon icon = tester.widget<Icon>(find.byIcon(Icons.layers_outlined));
    expect(icon.color, WalkaColors.gold);
  });

  testWidgets('supports compact horizontal composition',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        const WalkaBenefitItem(
          icon: Icons.grid_view_rounded,
          title: 'Organized layout',
          body: 'Compact copy remains flexible.',
          layout: WalkaBenefitItemLayout.compact,
        ),
      ),
    );

    expect(find.byKey(const ValueKey<String>('walka-benefit-compact')), findsOneWidget);
    expect(find.byType(Expanded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('exposes one concise semantic label', (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        const WalkaBenefitItem(
          icon: Icons.check_circle_outline,
          title: 'Verified detail',
          body: 'Approved supporting wording.',
        ),
      ),
    );

    final Finder semanticsFinder = find.descendant(
      of: find.byType(WalkaBenefitItem),
      matching: find.byType(Semantics),
    );
    final Semantics semantics = tester.widget<Semantics>(semanticsFinder.first);
    expect(
      semantics.properties.label,
      'Verified detail. Approved supporting wording.',
    );
  });

  testWidgets('long compact copy remains overflow-free',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        const WalkaBenefitItem(
          icon: Icons.inventory_2_outlined,
          title: 'Longer benefit heading',
          body:
              'A deliberately longer support sentence verifies wrapping on narrow compact layouts without fixed heights.',
          layout: WalkaBenefitItemLayout.compact,
        ),
        width: 150,
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
