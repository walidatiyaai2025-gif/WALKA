import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/accessibility/walka_accessibility.dart';
import 'package:walka/design_system/components/layout/walka_content_width.dart';
import 'package:walka/design_system/walka_theme.dart';

void main() {
  test('content width tiers are explicit and deterministic', () {
    expect(WalkaContentWidthMetrics.tierForWidth(719), WalkaContentTier.mobile);
    expect(WalkaContentWidthMetrics.tierForWidth(720), WalkaContentTier.tablet);
    expect(WalkaContentWidthMetrics.tierForWidth(1024), WalkaContentTier.desktop);
    expect(WalkaContentWidthMetrics.desktopMaxWidth, 1200);
  });

  test('typography roles preserve hierarchy', () {
    expect(WalkaType.pageTitle.fontSize, greaterThan(WalkaType.cardTitle.fontSize!));
    expect(WalkaType.metric.fontWeight, FontWeight.w700);
    expect(WalkaType.label.color, WalkaColors.navy);
    expect(WalkaType.caption.color, WalkaColors.muted);
    expect(WalkaType.body.fontSize, 15);
  });

  test('semantics label helper removes empty fragments', () {
    expect(
      WalkaA11y.joinLabels(<String?>['Favorites', null, '  ', '3 saved']),
      'Favorites. 3 saved',
    );
  });

  testWidgets('touch target expands undersized visual to at least 48px',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: WalkaTouchTarget(
              semanticLabel: 'Favorite action',
              button: true,
              enabled: false,
              child: SizedBox(width: 16, height: 16),
            ),
          ),
        ),
      ),
    );

    final Size size = tester.getSize(find.byType(WalkaTouchTarget));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
    expect(find.bySemanticsLabel('Favorite action'), findsOneWidget);
  });

  testWidgets('content width constrains desktop content and keeps gutters',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(1440, 900)),
          child: Scaffold(
            body: SizedBox(
              width: 1440,
              child: WalkaContentWidth(
                child: SizedBox(key: ValueKey('content'), height: 40),
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byKey(const ValueKey('content'))).width,
        lessThanOrEqualTo(WalkaContentWidthMetrics.desktopMaxWidth));
  });
}
