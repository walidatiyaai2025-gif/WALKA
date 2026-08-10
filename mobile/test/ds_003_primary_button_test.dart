import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/buttons/walka_primary_button.dart';
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

  testWidgets('inherits elevated-button theme and invokes callback',
      (WidgetTester tester) async {
    var taps = 0;
    await tester.pumpWidget(
      app(
        Center(
          child: WalkaPrimaryButton(
            label: 'SHOP NOW',
            onPressed: () => taps += 1,
          ),
        ),
      ),
    );

    final ElevatedButton button = tester.widget(find.byType(ElevatedButton));
    expect(button.style, isNull);
    expect(tester.getSize(find.byType(ElevatedButton)).height, greaterThanOrEqualTo(54));

    await tester.tap(find.text('SHOP NOW'));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('supports icon and expanded width', (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        WalkaPrimaryButton(
          label: 'CONTINUE',
          icon: Icons.arrow_forward_rounded,
          isExpanded: true,
          onPressed: () {},
        ),
      ),
    );

    expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    expect(tester.getSize(find.byType(ElevatedButton)).width, 320);
  });

  testWidgets('passes disabled state to ElevatedButton',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(const Center(child: WalkaPrimaryButton(label: 'DISABLED', onPressed: null))),
    );

    final ElevatedButton button = tester.widget(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });
}
