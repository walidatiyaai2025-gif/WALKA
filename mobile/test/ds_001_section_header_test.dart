import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/typography/walka_section_header.dart';
import 'package:walka/design_system/walka_theme.dart';

void main() {
  testWidgets('renders WALKA eyebrow and title hierarchy',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildWalkaTheme(),
        home: const Scaffold(
          body: WalkaSectionHeader(
            eyebrow: 'OUR COLLECTION',
            title: 'Everything in Its Place',
          ),
        ),
      ),
    );

    expect(find.text('OUR COLLECTION'), findsOneWidget);
    expect(find.text('Everything in Its Place'), findsOneWidget);
    expect(find.bySemanticsLabel('Everything in Its Place'), findsOneWidget);

    final Text eyebrow = tester.widget<Text>(find.text('OUR COLLECTION'));
    final Text title = tester.widget<Text>(find.text('Everything in Its Place'));

    expect(eyebrow.textAlign, TextAlign.center);
    expect(eyebrow.style?.color, WalkaColors.gold);
    expect(eyebrow.style?.fontSize, 10);
    expect(title.textAlign, TextAlign.center);
    expect(title.style?.color, WalkaColors.navy);
    expect(title.style?.fontSize, 27);
    expect(title.style?.fontFamily, 'serif');
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports start alignment and optional action',
      (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildWalkaTheme(),
        home: Scaffold(
          body: WalkaSectionHeader(
            eyebrow: 'DISCOVER',
            title: 'Organize your space',
            alignment: WalkaSectionHeaderAlignment.start,
            action: TextButton(
              onPressed: () => tapped = true,
              child: const Text('VIEW ALL'),
            ),
          ),
        ),
      ),
    );

    final Text eyebrow = tester.widget<Text>(find.text('DISCOVER'));
    final Text title = tester.widget<Text>(find.text('Organize your space'));
    expect(eyebrow.textAlign, TextAlign.start);
    expect(title.textAlign, TextAlign.start);

    await tester.tap(find.text('VIEW ALL'));
    await tester.pump();
    expect(tapped, isTrue);
    expect(tester.takeException(), isNull);
  });
}
