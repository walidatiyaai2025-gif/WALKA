import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/buttons/walka_secondary_button.dart';
import 'package:walka/design_system/walka_theme.dart';

void main() {
  Widget app(Widget child) {
    return MaterialApp(
      theme: buildWalkaTheme(),
      home: Scaffold(
        body: SizedBox(width: 320, child: child),
      ),
    );
  }

  testWidgets('inherits outlined-button theme and invokes callback',
      (WidgetTester tester) async {
    var taps = 0;
    await tester.pumpWidget(
      app(
        Center(
          child: WalkaSecondaryButton(
            label: 'SEARCH',
            onPressed: () => taps += 1,
          ),
        ),
      ),
    );

    final OutlinedButton button = tester.widget(find.byType(OutlinedButton));
    expect(button.style, isNull);
    expect(tester.getSize(find.byType(OutlinedButton)).height, greaterThanOrEqualTo(52));

    await tester.tap(find.text('SEARCH'));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('supports icon and expanded width', (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        WalkaSecondaryButton(
          label: 'FILTERS',
          icon: Icons.tune_rounded,
          isExpanded: true,
          onPressed: () {},
        ),
      ),
    );

    expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
    expect(tester.getSize(find.byType(OutlinedButton)).width, 320);
  });

  testWidgets('passes disabled state to OutlinedButton',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(const Center(child: WalkaSecondaryButton(label: 'DISABLED', onPressed: null))),
    );

    final OutlinedButton button = tester.widget(find.byType(OutlinedButton));
    expect(button.onPressed, isNull);
  });
}
