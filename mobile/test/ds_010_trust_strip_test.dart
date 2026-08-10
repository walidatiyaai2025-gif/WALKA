import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/cards/walka_trust_strip.dart';
import 'package:walka/design_system/walka_theme.dart';

void main() {
  Widget app(Widget child, {double width = 500}) {
    return MaterialApp(
      theme: buildWalkaTheme(),
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, child: child),
        ),
      ),
    );
  }

  List<Widget> items() => const <Widget>[
        SizedBox(
          key: ValueKey<String>('trust-one'),
          height: 40,
          child: Text('First benefit'),
        ),
        SizedBox(
          key: ValueKey<String>('trust-two'),
          height: 40,
          child: Text('Second benefit'),
        ),
      ];

  testWidgets('uses WALKA premium trust surface and preserves children',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(WalkaTrustStrip(children: items(), semanticLabel: 'Product benefits')),
    );

    expect(find.text('First benefit'), findsOneWidget);
    expect(find.text('Second benefit'), findsOneWidget);

    final Finder decoratedFinder = find.descendant(
      of: find.byType(WalkaTrustStrip),
      matching: find.byType(DecoratedBox),
    );
    final DecoratedBox decorated =
        tester.widget<DecoratedBox>(decoratedFinder.first);
    final BoxDecoration decoration = decorated.decoration as BoxDecoration;
    expect(decoration.color, WalkaColors.navy);
    expect(decoration.borderRadius, BorderRadius.circular(WalkaRadius.md));

    final Finder semanticsFinder = find.descendant(
      of: find.byType(WalkaTrustStrip),
      matching: find.byType(Semantics),
    );
    final Semantics semantics = tester.widget<Semantics>(semanticsFinder.first);
    expect(semantics.properties.label, 'Product benefits');
  });

  testWidgets('uses two columns when width allows it',
      (WidgetTester tester) async {
    await tester.pumpWidget(app(WalkaTrustStrip(children: items()), width: 500));
    await tester.pump();

    final Offset first =
        tester.getTopLeft(find.byKey(const ValueKey<String>('trust-one')));
    final Offset second =
        tester.getTopLeft(find.byKey(const ValueKey<String>('trust-two')));
    expect(first.dy, second.dy);
    expect(second.dx, greaterThan(first.dx));
    expect(tester.takeException(), isNull);
  });

  testWidgets('stacks safely on compact width', (WidgetTester tester) async {
    await tester.pumpWidget(app(WalkaTrustStrip(children: items()), width: 320));
    await tester.pump();

    final Offset first =
        tester.getTopLeft(find.byKey(const ValueKey<String>('trust-one')));
    final Offset second =
        tester.getTopLeft(find.byKey(const ValueKey<String>('trust-two')));
    expect(second.dy, greaterThan(first.dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('provides default white text and gold icon themes',
      (WidgetTester tester) async {
    await tester.pumpWidget(app(WalkaTrustStrip(children: items())));

    final Finder textStyleFinder = find.descendant(
      of: find.byType(WalkaTrustStrip),
      matching: find.byType(DefaultTextStyle),
    );
    final DefaultTextStyle textStyle =
        tester.widget<DefaultTextStyle>(textStyleFinder.first);
    expect(textStyle.style.color, WalkaColors.white);

    final Finder iconThemeFinder = find.descendant(
      of: find.byType(WalkaTrustStrip),
      matching: find.byType(IconTheme),
    );
    final IconTheme iconTheme = tester.widget<IconTheme>(iconThemeFinder.first);
    expect(iconTheme.data.color, WalkaColors.gold);
  });
}
